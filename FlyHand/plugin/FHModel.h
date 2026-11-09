// SPDX-License-Identifier: MPL-2.0
// FlyHand: intermediate model between libfreehand (librevenge callbacks) and Illustrator.
// Independent from the Illustrator SDK so it can be tested with a command-line tool.
#pragma once

#include <string>
#include <vector>

namespace flyhand {

struct Pt { double x = 0, y = 0; };   // inches, origin top-left of the page, y down

struct Anchor {
  Pt p, in, out;
  bool corner = true;
};

struct SubPath {
  std::vector<Anchor> anchors;
  bool closed = false;
};

struct RGB { double r = 0, g = 0, b = 0; };

struct Style {
  bool fill = false;
  RGB fillColor;
  bool stroke = false;
  RGB strokeColor;
  double strokeWidth = 0;   // inches
  int cap = 0;              // 0 butt, 1 round, 2 square
  int join = 0;             // 0 miter, 1 round, 2 bevel
  bool evenOdd = false;
};

struct Item {
  enum Kind { GroupOpen, GroupClose, Path } kind = Path;
  std::vector<SubPath> subPaths;
  Style style;
};

struct Stats {
  int pages = 0, groups = 0, paths = 0, subPaths = 0, anchors = 0;
  int gradientFills = 0, bitmapFills = 0, arcs = 0;
  int textObjects = 0, graphicObjects = 0, connectors = 0, masterPages = 0;
};

struct Model {
  double pageWidth = 0, pageHeight = 0;  // inches, first page
  std::vector<Item> items;
  Stats stats;
};

}  // namespace flyhand
