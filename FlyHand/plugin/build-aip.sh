#!/bin/bash
# SPDX-License-Identifier: MPL-2.0
# Builds FlyHand.aip (Illustrator 2021 plug-in) and the fhdump test tool for macOS 10.14, x86_64.
# Needs Xcode 11.3.1 (or newer), perl and gperf. The Illustrator SDK is NOT in the repository:
# point AI_SDK to your own copy.
#
#   AI_SDK         Illustrator 2021 SDK            (default /Users/Shared/SDK/Illustrator-2021-v5)
#   FLYHAND_DEPS   prefix with static librevenge 0.0.5 and lcms2 (lib/ and include/)
#   BOOST_INCLUDE  Boost headers (only headers are used)
#   ICU_INCLUDE    directory that contains unicode/utf8.h and unicode/utf16.h (headers only)
set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SDK=${AI_SDK:-/Users/Shared/SDK/Illustrator-2021-v5}
DEPS=${FLYHAND_DEPS:-$HOME/flyhand/prefix}
BOOST=${BOOST_INCLUDE:-$HOME/flyhand/src/boost_1_83_0}
ICU=${ICU_INCLUDE:-$HOME/flyhand/src/icu}
B=${BUILD_DIR:-$ROOT/build}
VERSION=${FLYHAND_VERSION:-0.2.0}

export DEVELOPER_DIR=${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}
export MACOSX_DEPLOYMENT_TARGET=10.14
SYSROOT=$(xcrun --show-sdk-path)
CXX=$(xcrun -f clang++)
COMMON=(-arch x86_64 -mmacosx-version-min=10.14 -isysroot "$SYSROOT" -O2 -std=c++14 -stdlib=libc++)

for f in "$SDK/illustratorapi/illustrator/AIFileFormat.h" "$DEPS/lib/librevenge-0.0.a" "$DEPS/lib/liblcms2.a" \
         "$BOOST/boost/version.hpp" "$ICU/unicode/utf8.h"; do
  [ -e "$f" ] || { echo "missing: $f" >&2; exit 2; }
done

rm -rf "$B"; mkdir -p "$B/gen" "$B/obj"

echo "== tokens"
perl "$ROOT/libfreehand/src/lib/gentoken.pl" "$ROOT/libfreehand/src/lib/tokens.txt" "$B/gen/tokens.h" "$B/gen/tokens.gperf"
gperf --compare-strncmp -C -m 20 "$B/gen/tokens.gperf" \
  | sed -e 's/(char\*)0/(char\*)0, 0/g' -e 's/register //g' > "$B/gen/tokenhash.h"

REVENGE_INC=(-I"$DEPS/include/librevenge-0.0" -I"$DEPS/include")
LF_FLAGS=(-DLIBFREEHAND_BUILD=1 -DNDEBUG -I"$ROOT/libfreehand/inc" -I"$B/gen" "${REVENGE_INC[@]}"
          -I"$ICU" -I"$BOOST" -w)
SDK_INC=(-I"$SDK/illustratorapi/illustrator" -I"$SDK/illustratorapi/illustrator/actions"
         -I"$SDK/illustratorapi/pica_sp" -I"$SDK/illustratorapi/ate")
PL_FLAGS=(-I"$ROOT/plugin" -I"$ROOT/libfreehand/inc" "${REVENGE_INC[@]}" "${SDK_INC[@]}"
          -Wno-four-char-constants -Wno-deprecated-declarations)

compile() {  # src obj flags...
  local src=$1 obj=$2; shift 2
  "$CXX" "${COMMON[@]}" "$@" -c "$src" -o "$obj"
}

echo "== libfreehand"
LF_OBJS=()
for s in "$ROOT"/libfreehand/src/lib/*.cpp; do
  o="$B/obj/lf_$(basename "${s%.cpp}").o"; compile "$s" "$o" "${LF_FLAGS[@]}"; LF_OBJS+=("$o")
done

echo "== painter"
compile "$ROOT/plugin/FHPainter.cpp" "$B/obj/FHPainter.o" -I"$ROOT/plugin" "${REVENGE_INC[@]}" -Wall
compile "$ROOT/tools/fhdump.cpp" "$B/obj/fhdump.o" -I"$ROOT/plugin" -I"$ROOT/libfreehand/inc" "${REVENGE_INC[@]}" -Wall

LIBS=("$DEPS/lib/librevenge-stream-0.0.a" "$DEPS/lib/librevenge-0.0.a" "$DEPS/lib/liblcms2.a" -lz)

echo "== fhdump"
"$CXX" "${COMMON[@]}" -o "$B/fhdump" "$B/obj/fhdump.o" "$B/obj/FHPainter.o" "${LF_OBJS[@]}" "${LIBS[@]}"

echo "== plugin"
PL_OBJS=("$B/obj/FHPainter.o")
compile "$ROOT/plugin/FlyHandPlugin.cpp" "$B/obj/FlyHandPlugin.o" "${PL_FLAGS[@]}" -Wall; PL_OBJS+=("$B/obj/FlyHandPlugin.o")
for s in IAIUnicodeString IAIFilePath IAIArtboards; do
  compile "$SDK/illustratorapi/illustrator/$s.cpp" "$B/obj/sdk_$s.o" "${PL_FLAGS[@]}" -w; PL_OBJS+=("$B/obj/sdk_$s.o")
done

A="$B/FlyHand.aip/Contents"
mkdir -p "$A/MacOS" "$A/Resources/pipl"
"$CXX" "${COMMON[@]}" -bundle -dead_strip -Wl,-exported_symbol,_PluginMain -o "$A/MacOS/FlyHand" \
  "${PL_OBJS[@]}" "${LF_OBJS[@]}" "${LIBS[@]}" -framework CoreFoundation -framework Foundation
sed "s/@VERSION@/$VERSION/g" "$ROOT/plugin/Info.plist" > "$A/Info.plist"
printf 'ARPIART5' > "$A/PkgInfo"
perl "$ROOT/plugin/make-pipl.pl" FlyHand PluginMain "$A/Resources/pipl/plugin.pipl"

echo "== check"
for f in "$A/MacOS/FlyHand" "$B/fhdump"; do
  lipo -info "$f"
  otool -l "$f" | grep -A4 LC_BUILD_VERSION | grep -E 'minos'
  echo "ymm: $(otool -tv "$f" | grep -c ymm)"
  otool -L "$f" | tail -n +2
done
nm -gU "$A/MacOS/FlyHand"
echo "== OK $B/FlyHand.aip"
