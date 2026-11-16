#!/bin/bash
# FlyHand fase 1: lcms2, librevenge y libfreehand estáticas x86_64 para 10.14, en la 6,1 (cuenta craft).
set -eu
for s in /tmp/local19-61-en-uso /tmp/local20-61-en-uso; do
  if [ -e "$s" ]; then echo "6,1 ocupada: $s"; exit 3; fi
done
touch /tmp/flyhand-61-en-uso; trap 'rm -f /tmp/flyhand-61-en-uso' EXIT

S=$HOME/flyhand/src
P=$HOME/flyhand/prefix
BOOST=$S/boost_1_83_0
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
export MACOSX_DEPLOYMENT_TARGET=10.14
export SDKROOT=$(xcrun --show-sdk-path)
export CC=$(xcrun -f clang) CXX=$(xcrun -f clang++)
F="-arch x86_64 -mmacosx-version-min=10.14 -O2"
export CFLAGS="$F" CXXFLAGS="$F" LDFLAGS="-arch x86_64 -mmacosx-version-min=10.14"
J=8
echo "== $(date) SDK=$SDKROOT CC=$CC"
rm -rf "$P"; mkdir -p "$P"

echo "== lcms2"
cd $S/lcms2-2.16
./configure --prefix=$P --enable-static --disable-shared --without-jpeg --without-tiff --without-zlib >/dev/null
make -j$J >/dev/null
make install >/dev/null

echo "== librevenge"
cd $S/librevenge-0.0.5
ZLIB_CFLAGS=" " ZLIB_LIBS="-lz" CPPFLAGS="-I$BOOST" \
  ./configure --prefix=$P --enable-static --disable-shared --disable-tests --without-docs --disable-werror >/dev/null
make -j$J >/dev/null
make install >/dev/null

echo "== libfreehand"
cd $S/libfreehand
touch aclocal.m4; sleep 1; touch configure; find . -name Makefile.in -exec touch {} +; touch config.h.in 2>/dev/null || true
RI="-I$P/include/librevenge-0.0"
REVENGE_CFLAGS="$RI" REVENGE_LIBS="-L$P/lib -lrevenge-0.0" \
REVENGE_STREAM_CFLAGS="$RI" REVENGE_STREAM_LIBS="-L$P/lib -lrevenge-stream-0.0" \
REVENGE_GENERATORS_CFLAGS="$RI" REVENGE_GENERATORS_LIBS="-L$P/lib -lrevenge-generators-0.0" \
ZLIB_CFLAGS=" " ZLIB_LIBS="-lz" ICU_CFLAGS="-I$S/icu" ICU_LIBS=" " \
LCMS2_CFLAGS="-I$P/include" LCMS2_LIBS="-L$P/lib -llcms2" CPPFLAGS="-I$BOOST" \
  ./configure --prefix=$P --enable-static --disable-shared --disable-tests --without-docs --disable-werror --enable-tools >/dev/null
make -j$J >/dev/null
make install >/dev/null

echo "== resultado"
ls -l $P/lib/*.a $P/bin/
for f in $P/lib/*.a $P/bin/*; do lipo -info "$f"; done
for f in $P/bin/*; do echo "-- $f"; otool -L "$f"; otool -l "$f" | grep -A4 -E 'LC_BUILD_VERSION|LC_VERSION_MIN' | grep -E 'minos|version'; echo "ymm: $(otool -tv "$f" | grep -c ymm)"; done
echo "== FIN $(date)"
