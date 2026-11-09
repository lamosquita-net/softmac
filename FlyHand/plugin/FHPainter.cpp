// SPDX-License-Identifier: MPL-2.0
// FlyHand: conversion of librevenge drawing callbacks into the flyhand::Model.

#include "FHPainter.h"

#include <cmath>
#include <cstdlib>
#include <string>

namespace flyhand {

namespace {

const double kKappa = 0.5522847498307936;  // cubic approximation of a quarter circle

bool parseHex(const librevenge::RVNGProperty *prop, RGB &out) {
  if (!prop) return false;
  std::string s = prop->getStr().cstr();
  if (s.size() != 7 || s[0] != '#') return false;
  const long v = std::strtol(s.c_str() + 1, nullptr, 16);
  out.r = ((v >> 16) & 0xff) / 255.0;
  out.g = ((v >> 8) & 0xff) / 255.0;
  out.b = (v & 0xff) / 255.0;
  return true;
}

std::string str(const librevenge::RVNGPropertyList &pl, const char *key) {
  const librevenge::RVNGProperty *p = pl[key];
  return p ? std::string(p->getStr().cstr()) : std::string();
}

double num(const librevenge::RVNGPropertyList &pl, const char *key, double def = 0) {
  const librevenge::RVNGProperty *p = pl[key];
  return p ? p->getDouble() : def;
}

Anchor corner(double x, double y) {
  Anchor a;
  a.p.x = a.in.x = a.out.x = x;
  a.p.y = a.in.y = a.out.y = y;
  a.corner = true;
  return a;
}

bool same(const Pt &a, const Pt &b) {
  return std::fabs(a.x - b.x) < 1e-6 && std::fabs(a.y - b.y) < 1e-6;
}

// A point is smooth when its two handles are collinear with it and on opposite sides.
void markCorners(SubPath &sp) {
  for (Anchor &a : sp.anchors) {
    const double ix = a.in.x - a.p.x, iy = a.in.y - a.p.y;
    const double ox = a.out.x - a.p.x, oy = a.out.y - a.p.y;
    const double li = std::hypot(ix, iy), lo = std::hypot(ox, oy);
    if (li < 1e-9 || lo < 1e-9) { a.corner = true; continue; }
    const double cross = (ix * oy - iy * ox) / (li * lo);
    const double dot = (ix * ox + iy * oy) / (li * lo);
    a.corner = !(std::fabs(cross) < 1e-3 && dot < 0);
  }
}

}  // namespace

void Painter::startPage(const librevenge::RVNGPropertyList &propList) {
  if (m_model.stats.pages++ == 0) {
    m_model.pageWidth = num(propList, "svg:width");
    m_model.pageHeight = num(propList, "svg:height");
  }
}

void Painter::openGroup(const librevenge::RVNGPropertyList &) {
  Item it;
  it.kind = Item::GroupOpen;
  m_model.items.push_back(it);
  m_model.stats.groups++;
}

void Painter::closeGroup() {
  Item it;
  it.kind = Item::GroupClose;
  m_model.items.push_back(it);
}

Style Painter::currentStyle(const librevenge::RVNGPropertyList &shapeProps) {
  // Properties on the shape itself win over the last setStyle().
  auto get = [&](const char *key) -> const librevenge::RVNGProperty * {
    if (shapeProps[key]) return shapeProps[key];
    return m_style[key];
  };
  Style st;
  const std::string fill = get("draw:fill") ? get("draw:fill")->getStr().cstr() : "none";
  if (fill == "solid") {
    st.fill = true;  // libfreehand writes #000000 when the colour is missing
    parseHex(get("draw:fill-color"), st.fillColor);
  } else if (fill == "gradient") {
    // Gradients arrive in phase 3; meanwhile use the start colour as a flat fill.
    m_model.stats.gradientFills++;
    st.fill = parseHex(get("draw:start-color"), st.fillColor) || parseHex(get("draw:fill-color"), st.fillColor);
  } else if (fill == "bitmap") {
    m_model.stats.bitmapFills++;
  }
  const std::string stroke = get("draw:stroke") ? get("draw:stroke")->getStr().cstr() : "none";
  if (stroke != "none") {
    st.stroke = true;
    if (!parseHex(get("svg:stroke-color"), st.strokeColor)) st.strokeColor = RGB();
    st.strokeWidth = get("svg:stroke-width") ? get("svg:stroke-width")->getDouble() : 0;
    const std::string cap = get("svg:stroke-linecap") ? get("svg:stroke-linecap")->getStr().cstr() : "";
    st.cap = cap == "round" ? 1 : cap == "square" ? 2 : 0;
    const std::string join = get("svg:stroke-linejoin") ? get("svg:stroke-linejoin")->getStr().cstr() : "";
    st.join = join == "round" ? 1 : join == "bevel" ? 2 : 0;
  }
  st.evenOdd = get("svg:fill-rule") && std::string(get("svg:fill-rule")->getStr().cstr()) == "evenodd";
  return st;
}

void Painter::addPath(std::vector<SubPath> &&subPaths, const librevenge::RVNGPropertyList &shapeProps) {
  Item it;
  it.kind = Item::Path;
  it.style = currentStyle(shapeProps);
  for (SubPath &sp : subPaths) {
    if (sp.anchors.empty()) continue;
    markCorners(sp);
    m_model.stats.subPaths++;
    m_model.stats.anchors += int(sp.anchors.size());
    it.subPaths.push_back(std::move(sp));
  }
  if (it.subPaths.empty()) return;
  m_model.stats.paths++;
  m_model.items.push_back(std::move(it));
}

void Painter::drawPath(const librevenge::RVNGPropertyList &propList) {
  const librevenge::RVNGPropertyListVector *d = propList.child("svg:d");
  if (!d) return;
  std::vector<SubPath> subs;
  for (unsigned long i = 0; i < d->count(); ++i) {
    const librevenge::RVNGPropertyList &e = (*d)[i];
    const std::string act = str(e, "librevenge:path-action");
    const double x = num(e, "svg:x"), y = num(e, "svg:y");
    if (act == "M" || subs.empty() || (subs.back().closed && act != "Z")) {
      subs.push_back(SubPath());
      if (act == "M") { subs.back().anchors.push_back(corner(x, y)); continue; }
    }
    SubPath &sp = subs.back();
    if (act == "Z") {
      sp.closed = true;
      if (sp.anchors.size() > 1 && same(sp.anchors.front().p, sp.anchors.back().p)) {
        sp.anchors.front().in = sp.anchors.back().in;
        sp.anchors.pop_back();
      }
      continue;
    }
    if (sp.anchors.empty()) sp.anchors.push_back(corner(x, y));
    Anchor &prev = sp.anchors.back();
    if (act == "C") {
      prev.out = Pt{num(e, "svg:x1"), num(e, "svg:y1")};
      Anchor a = corner(x, y);
      a.in = Pt{num(e, "svg:x2"), num(e, "svg:y2")};
      sp.anchors.push_back(a);
    } else if (act == "Q") {
      const Pt q{num(e, "svg:x1"), num(e, "svg:y1")};
      prev.out = Pt{prev.p.x + 2.0 / 3.0 * (q.x - prev.p.x), prev.p.y + 2.0 / 3.0 * (q.y - prev.p.y)};
      Anchor a = corner(x, y);
      a.in = Pt{x + 2.0 / 3.0 * (q.x - x), y + 2.0 / 3.0 * (q.y - y)};
      sp.anchors.push_back(a);
    } else {
      if (act == "A") m_model.stats.arcs++;  // arcs are rare in FreeHand; drawn as a line for now
      sp.anchors.push_back(corner(x, y));
    }
  }
  addPath(std::move(subs), propList);
}

void Painter::drawRectangle(const librevenge::RVNGPropertyList &propList) {
  const double x = num(propList, "svg:x"), y = num(propList, "svg:y");
  const double w = num(propList, "svg:width"), h = num(propList, "svg:height");
  SubPath sp;
  sp.closed = true;
  sp.anchors = {corner(x, y), corner(x + w, y), corner(x + w, y + h), corner(x, y + h)};
  std::vector<SubPath> subs(1, sp);
  addPath(std::move(subs), propList);
}

void Painter::drawEllipse(const librevenge::RVNGPropertyList &propList) {
  const double cx = num(propList, "svg:cx"), cy = num(propList, "svg:cy");
  const double rx = num(propList, "svg:rx"), ry = num(propList, "svg:ry");
  const double rot = num(propList, "librevenge:rotate") * M_PI / 180.0;
  const double c = std::cos(rot), s = std::sin(rot);
  auto tp = [&](double ux, double uy) { return Pt{cx + ux * c - uy * s, cy + ux * s + uy * c}; };
  SubPath sp;
  sp.closed = true;
  const double ux[4] = {rx, 0, -rx, 0}, uy[4] = {0, ry, 0, -ry};
  for (int i = 0; i < 4; ++i) {
    Anchor a;
    a.p = tp(ux[i], uy[i]);
    // Tangent direction for counter-clockwise order in local coordinates.
    const double tx = -uy[i] / (ry ? ry : 1) * rx, ty = ux[i] / (rx ? rx : 1) * ry;
    a.out = tp(ux[i] + kKappa * tx, uy[i] + kKappa * ty);
    a.in = tp(ux[i] - kKappa * tx, uy[i] - kKappa * ty);
    a.corner = false;
    sp.anchors.push_back(a);
  }
  std::vector<SubPath> subs(1, sp);
  addPath(std::move(subs), propList);
}

void Painter::drawPoints(const librevenge::RVNGPropertyList &propList, bool closed) {
  const librevenge::RVNGPropertyListVector *pts = propList.child("svg:points");
  if (!pts) return;
  SubPath sp;
  sp.closed = closed;
  for (unsigned long i = 0; i < pts->count(); ++i)
    sp.anchors.push_back(corner(num((*pts)[i], "svg:x"), num((*pts)[i], "svg:y")));
  std::vector<SubPath> subs(1, sp);
  addPath(std::move(subs), propList);
}

}  // namespace flyhand
