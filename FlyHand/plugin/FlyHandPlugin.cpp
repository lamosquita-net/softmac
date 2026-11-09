// SPDX-License-Identifier: MPL-2.0
// FlyHand: Illustrator file format plug-in that opens FreeHand 3–11/MX documents.
//
// Phase 2: paths, fills and strokes. The plug-in keeps no state between calls: every call
// acquires the suites it needs from the message and releases them before returning.

#include "SPConfig.h"
#include "SPBasic.h"
#include "SPBlocks.h"
#include "SPInterf.h"
#include "SPAccess.h"
#include "AIArt.h"
#include "AIArtboard.h"
#include "AIDocument.h"
#include "AIFileFormat.h"
#include "AIFilePath.h"
#include "AIPath.h"
#include "AIPathStyle.h"
#include "AIUnicodeString.h"
#include "IAIArtboards.hpp"
#include "IAIFilePath.hpp"
#include "IAIUnicodeString.h"

#include "FlyHandSuiteVersions.h"

#include <algorithm>
#include <cstdarg>
#include <cstdio>
#include <cstring>
#include <ctime>
#include <string>
#include <vector>

#include <libfreehand/libfreehand.h>
#include <librevenge-stream/librevenge-stream.h>

#include "FHPainter.h"

extern "C" {
SPBasicSuite *sSPBasic = nullptr;
SPBlocksSuite *sSPBlocks = nullptr;
AIArtSuite *sAIArt = nullptr;
AIArtboardSuite *sAIArtboard = nullptr;
AIDocumentSuite *sAIDocument = nullptr;
AIFileFormatSuite *sAIFileFormat = nullptr;
AIFilePathSuite *sAIFilePath = nullptr;
AIPathSuite *sAIPath = nullptr;
AIPathStyleSuite *sAIPathStyle = nullptr;
AIUnicodeStringSuite *sAIUnicodeString = nullptr;
}

namespace {

const char *kLogPath = "/tmp/flyhand.log";
const ASErr kFlyHandReadErr = 'FHR!';

void logLine(const char *fmt, ...) __attribute__((format(printf, 1, 2)));
void logLine(const char *fmt, ...) {
  FILE *f = std::fopen(kLogPath, "a");
  if (!f) return;
  char when[32];
  const std::time_t t = std::time(nullptr);
  std::strftime(when, sizeof when, "%Y-%m-%d %H:%M:%S", std::localtime(&t));
  std::fprintf(f, "%s ", when);
  va_list ap;
  va_start(ap, fmt);
  std::vfprintf(f, fmt, ap);
  va_end(ap);
  std::fputc('\n', f);
  std::fclose(f);
}

struct SuiteRef {
  const char *name;
  ai::int32 version;
  const void **ptr;
};

SuiteRef gSuites[] = {
    {kSPBlocksSuite, kSPBlocksSuiteVersion, (const void **)&sSPBlocks},
    {kAIUnicodeStringSuite, kAIUnicodeStringSuiteVersion, (const void **)&sAIUnicodeString},
    {kAIFilePathSuite, kAIFilePathSuiteVersion, (const void **)&sAIFilePath},
    {kAIFileFormatSuite, kAIFileFormatSuiteVersion, (const void **)&sAIFileFormat},
    {kAIArtSuite, kAIArtSuiteVersion, (const void **)&sAIArt},
    {kAIPathSuite, kAIPathSuiteVersion, (const void **)&sAIPath},
    {kAIPathStyleSuite, kAIPathStyleSuiteVersion, (const void **)&sAIPathStyle},
    {kAIDocumentSuite, kAIDocumentSuiteVersion, (const void **)&sAIDocument},
    {kAIArtboardSuite, kAIArtboardSuiteVersion, (const void **)&sAIArtboard},
};
const size_t kSuiteCount = sizeof gSuites / sizeof gSuites[0];

// Acquires every suite on construction and releases them on destruction.
class Suites {
public:
  explicit Suites(SPBasicSuite *basic) {
    sSPBasic = basic;
    for (size_t i = 0; i < kSuiteCount; ++i) {
      if (basic->AcquireSuite(gSuites[i].name, gSuites[i].version, gSuites[i].ptr) != kNoErr) {
        logLine("suite missing: %s v%d", gSuites[i].name, int(gSuites[i].version));
        *gSuites[i].ptr = nullptr;
        m_error = kCantHappenErr;
        break;
      }
      m_acquired = i + 1;
    }
  }
  ~Suites() {
    for (size_t i = m_acquired; i > 0; --i) {
      sSPBasic->ReleaseSuite(gSuites[i - 1].name, gSuites[i - 1].version);
      *gSuites[i - 1].ptr = nullptr;
    }
  }
  ASErr error() const { return m_error; }

private:
  size_t m_acquired = 0;
  ASErr m_error = kNoErr;
};

std::string pathOf(const AIFileFormatMessage *msg) {
  return msg->GetFilePath().GetFullPath().as_UTF8();
}

// ---- writing the model into the current Illustrator document ----

class Writer {
public:
  Writer(const flyhand::Model &model, const AIRealRect &artboard) : m_model(model) {
    m_left = artboard.left;
    m_top = artboard.top;
    m_ySign = artboard.top > artboard.bottom ? -1.0 : 1.0;  // API y axis direction
  }

  ASErr write() {
    std::vector<AIArtHandle> parents;
    for (const flyhand::Item &it : m_model.items) {
      AIArtHandle parent = parents.empty() ? nullptr : parents.back();
      ASErr err = kNoErr;
      switch (it.kind) {
        case flyhand::Item::GroupOpen: {
          AIArtHandle group = nullptr;
          err = newArt(kGroupArt, parent, &group);
          if (!err) parents.push_back(group);
          break;
        }
        case flyhand::Item::GroupClose:
          if (!parents.empty()) parents.pop_back();
          break;
        case flyhand::Item::Path:
          err = writePath(it, parent);
          break;
      }
      if (err) return err;
    }
    return kNoErr;
  }

  int truncated = 0;

private:
  ASErr newArt(ai::int16 type, AIArtHandle parent, AIArtHandle *out) {
    return parent ? sAIArt->NewArt(type, kPlaceInsideOnTop, parent, out)
                  : sAIArt->NewArt(type, kPlaceAboveAll, nullptr, out);
  }

  AIRealPoint map(const flyhand::Pt &p) const {
    AIRealPoint r;
    r.h = AIReal(m_left + p.x * 72.0);
    r.v = AIReal(m_top + m_ySign * p.y * 72.0);
    return r;
  }

  static void cmyk(const flyhand::RGB &c, AIColor &out) {
    // Provisional until phase 3 keeps the original CMYK values: naive RGB -> CMYK.
    const double k = 1.0 - std::max(c.r, std::max(c.g, c.b));
    out.kind = kFourColor;
    out.c.f.black = AIReal(k);
    out.c.f.cyan = AIReal(k < 1.0 ? (1.0 - c.r - k) / (1.0 - k) : 0.0);
    out.c.f.magenta = AIReal(k < 1.0 ? (1.0 - c.g - k) / (1.0 - k) : 0.0);
    out.c.f.yellow = AIReal(k < 1.0 ? (1.0 - c.b - k) / (1.0 - k) : 0.0);
  }

  static void style(const flyhand::Style &s, AIPathStyle &ps) {
    ps.Init();
    ps.fillPaint = s.fill;
    if (s.fill) cmyk(s.fillColor, ps.fill.color);
    ps.strokePaint = s.stroke;
    if (s.stroke) {
      cmyk(s.strokeColor, ps.stroke.color);
      ps.stroke.width = AIReal(s.strokeWidth * 72.0);
      ps.stroke.cap = s.cap == 1 ? kAIRoundCap : s.cap == 2 ? kAIProjectingCap : kAIButtCap;
      ps.stroke.join = s.join == 1 ? kAIRoundJoin : s.join == 2 ? kAIBevelJoin : kAIMiterJoin;
      ps.stroke.miterLimit = AIReal(4);
    }
    ps.evenodd = s.evenOdd;
  }

  ASErr writeSubPath(const flyhand::SubPath &sp, const AIPathStyle &ps, AIArtHandle parent) {
    AIArtHandle path = nullptr;
    ASErr err = newArt(kPathArt, parent, &path);
    if (err) return err;
    size_t n = sp.anchors.size();
    if (n > 32767) { n = 32767; truncated++; }
    std::vector<AIPathSegment> segs(n);
    for (size_t i = 0; i < n; ++i) {
      const flyhand::Anchor &a = sp.anchors[i];
      segs[i].p = map(a.p);
      segs[i].in = map(a.in);
      segs[i].out = map(a.out);
      segs[i].corner = a.corner;
    }
    if (!err) err = sAIPath->SetPathSegmentCount(path, ai::int16(n));
    if (!err) err = sAIPath->SetPathSegments(path, 0, ai::int16(n), segs.data());
    if (!err) err = sAIPath->SetPathClosed(path, sp.closed);
    if (!err) err = sAIPathStyle->SetPathStyle(path, &ps);
    return err;
  }

  ASErr writePath(const flyhand::Item &it, AIArtHandle parent) {
    AIPathStyle ps;
    style(it.style, ps);
    if (it.subPaths.size() == 1) return writeSubPath(it.subPaths[0], ps, parent);
    AIArtHandle compound = nullptr;
    ASErr err = newArt(kCompoundPathArt, parent, &compound);
    for (size_t i = 0; !err && i < it.subPaths.size(); ++i) err = writeSubPath(it.subPaths[i], ps, compound);
    return err;
  }

  const flyhand::Model &m_model;
  double m_left = 0, m_top = 0, m_ySign = -1;
};

ASErr resizeFirstArtboard(const flyhand::Model &model, AIRealRect &rect) {
  ai::ArtboardList list;
  ai::ArtboardProperties props = list.GetArtboardProperties(0);
  ASErr err = props.GetPosition(rect);
  if (err) return err;
  if (model.pageWidth <= 0 || model.pageHeight <= 0) return kNoErr;
  const double sign = rect.top > rect.bottom ? -1.0 : 1.0;
  rect.right = AIReal(rect.left + model.pageWidth * 72.0);
  rect.bottom = AIReal(rect.top + sign * model.pageHeight * 72.0);
  err = props.SetPosition(rect);
  if (!err) err = list.Update(0, props);
  return err;
}

// ---- selectors ----

ASErr startup(SPInterfaceMessage *msg) {
  Suites suites(msg->d.basic);
  if (suites.error()) return suites.error();
  PlatformAddFileFormatData data;
  data.type = 'AGD3';
  data.title = ai::UnicodeString("FreeHand 3-11/MX (FlyHand)");
  data.titleOrder = 0;
  data.extension = ai::UnicodeString("fh3,fh5,fh7,fh8,fh9,fh10,fh11");
  AIFileFormatHandle handle = nullptr;
  ASErr err = sAIFileFormat->AddFileFormat(msg->d.self, "FlyHand FreeHand", &data, kFileFormatRead, &handle,
                                           kNoExtendedOptions);
  logLine("startup: AddFileFormat=%d", int(err));
  return err;
}

ASErr check(AIFileFormatMessage *msg) {
  Suites suites(msg->d.basic);
  if (suites.error()) return suites.error();
  librevenge::RVNGFileStream input(pathOf(msg).c_str());
  return libfreehand::FreeHandDocument::isSupported(&input) ? kNoErr : kUnknownFormatErr;
}

ASErr read(AIFileFormatMessage *msg) {
  Suites suites(msg->d.basic);
  if (suites.error()) return suites.error();
  const std::string path = pathOf(msg);
  const std::clock_t t0 = std::clock();
  flyhand::Model model;
  try {
    librevenge::RVNGFileStream input(path.c_str());
    if (!libfreehand::FreeHandDocument::isSupported(&input)) return kUnknownFormatErr;
    flyhand::Painter painter(model);
    if (!libfreehand::FreeHandDocument::parse(&input, &painter)) {
      logLine("read: libfreehand could not parse the document");
      return kFlyHandReadErr;
    }
  } catch (...) {
    logLine("read: exception while parsing");
    return kFlyHandReadErr;
  }
  sAIDocument->SetDocumentColorModel(kDocCMYKColor);
  AIRealRect rect = {0, 0, 0, 0};
  ASErr err = resizeFirstArtboard(model, rect);
  if (err) logLine("read: artboard error %d", int(err));
  Writer writer(model, rect);
  err = writer.write();
  const flyhand::Stats &s = model.stats;
  logLine("read: err=%d page=%.2fx%.2fin artboard=%.0f,%.0f,%.0f,%.0f groups=%d paths=%d anchors=%d "
          "gradients=%d bitmaps=%d text_skipped=%d graphics_skipped=%d truncated=%d %.2fs",
          int(err), model.pageWidth, model.pageHeight, double(rect.left), double(rect.top), double(rect.right),
          double(rect.bottom), s.groups, s.paths, s.anchors, s.gradientFills, s.bitmapFills, s.textObjects,
          s.graphicObjects, writer.truncated, double(std::clock() - t0) / CLOCKS_PER_SEC);
  return err;
}

}  // namespace

extern "C" ASAPI ASErr PluginMain(char *caller, char *selector, void *message) {
  try {
    if (!std::strcmp(caller, kSPInterfaceCaller)) {
      if (!std::strcmp(selector, kSPInterfaceStartupSelector)) return startup((SPInterfaceMessage *)message);
      return kNoErr;
    }
    if (!std::strcmp(caller, kSPAccessCaller)) return kNoErr;
    if (!std::strcmp(caller, kCallerAIFileFormat)) {
      AIFileFormatMessage *msg = (AIFileFormatMessage *)message;
      if (!std::strcmp(selector, kSelectorAICheckFileFormat)) return check(msg);
      if (!std::strcmp(selector, kSelectorAIGoFileFormat) && (msg->option & kFileFormatRead)) return read(msg);
      return kNoErr;
    }
  } catch (...) {
    logLine("PluginMain: exception in %s / %s", caller, selector);
    return kFlyHandReadErr;
  }
  return kSPUnimplementedError;
}
