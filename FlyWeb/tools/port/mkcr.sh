#!/bin/bash
# mkcr.sh <dir> <tag> : copia parcial de Chromium en un tag (sparse, depth 1, blob:none; ~1 min, ~800 MB).
# Blink, gin, content, extensions, chrome/renderer, components, services/accessibility, DEPS y TestExpectations.
# Inventario de nivel: cr116, cr<N-1> y cr<N> en /tmp/claude-0/port/ (MOTOR-8).
set -e
d=$1; t=$2
mkdir -p $d && cd $d
git init -q
git remote add origin https://github.com/chromium/chromium 2>/dev/null || true
git sparse-checkout init --no-cone
cat > .git/info/sparse-checkout <<'S'
/DEPS
/third_party/blink/public/
/third_party/blink/renderer/
/third_party/blink/common/
/gin/
/content/common/
/content/public/renderer/
/content/public/common/
/content/renderer/
/extensions/renderer/
/pdf/
/chrome/renderer/
/components/
/services/accessibility/
/v8/
/third_party/pdfium/fxjs/
/third_party/blink/web_tests/TestExpectations
/content/browser/
/cc/
/components/viz/
/services/
/net/
/base/tracing/protos/
/third_party/blink/renderer/build/
/chrome/browser/about_flags.cc
/chrome/browser/flag_descriptions.h
/chrome/browser/flag_descriptions.cc
/chrome/browser/flag-metadata.json
/content/child/
/third_party/boringssl/
S
git fetch -q --depth 1 --filter=blob:none origin refs/tags/$t:refs/tags/$t
git checkout -q $t
echo "ok $d $t"
