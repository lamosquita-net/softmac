// SPDX-License-Identifier: MPL-2.0
// fhdump: runs the FlyHand painter over a FreeHand document without Illustrator and prints a summary.
// Prints no file names, so the output can be shared without exposing client documents.

#include <cstdio>
#include <algorithm>
#include <limits>

#include <libfreehand/libfreehand.h>
#include <librevenge-stream/librevenge-stream.h>

#include "FHPainter.h"

int main(int argc, char **argv) {
  if (argc < 2) {
    std::fprintf(stderr, "usage: fhdump FILE\n");
    return 2;
  }
  librevenge::RVNGFileStream input(argv[1]);
  if (!libfreehand::FreeHandDocument::isSupported(&input)) {
    std::printf("supported=0\n");
    return 1;
  }
  flyhand::Model model;
  flyhand::Painter painter(model);
  const bool ok = libfreehand::FreeHandDocument::parse(&input, &painter);
  double minx = std::numeric_limits<double>::max(), miny = minx, maxx = -minx, maxy = -minx;
  int depth = 0, maxDepth = 0, unbalanced = 0;
  for (const flyhand::Item &it : model.items) {
    if (it.kind == flyhand::Item::GroupOpen) maxDepth = std::max(maxDepth, ++depth);
    if (it.kind == flyhand::Item::GroupClose && --depth < 0) { unbalanced++; depth = 0; }
    for (const flyhand::SubPath &sp : it.subPaths)
      for (const flyhand::Anchor &a : sp.anchors) {
        minx = std::min(minx, a.p.x); maxx = std::max(maxx, a.p.x);
        miny = std::min(miny, a.p.y); maxy = std::max(maxy, a.p.y);
      }
  }
  const flyhand::Stats &s = model.stats;
  std::printf("supported=1 parsed=%d page_in=%.2fx%.2f pages=%d groups=%d maxdepth=%d unbalanced=%d "
              "paths=%d subpaths=%d anchors=%d gradients=%d bitmaps=%d arcs=%d text=%d graphics=%d "
              "connectors=%d masters=%d bbox_in=%.2f,%.2f,%.2f,%.2f\n",
              ok ? 1 : 0, model.pageWidth, model.pageHeight, s.pages, s.groups, maxDepth, unbalanced + depth,
              s.paths, s.subPaths, s.anchors, s.gradientFills, s.bitmapFills, s.arcs, s.textObjects,
              s.graphicObjects, s.connectors, s.masterPages, minx, miny, maxx, maxy);
  return ok ? 0 : 1;
}
