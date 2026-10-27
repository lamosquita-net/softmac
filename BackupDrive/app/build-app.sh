#!/bin/sh
# Compila la app de barra de menús: build/BackupDrive.app (x86_64, macOS 10.14+).
# Solo necesita las herramientas de línea de comandos de Xcode (Xcode 11 en Mojave vale), sin proyecto.
# -Werror=unguarded-availability hace fallar la compilación si se usa una API posterior a 10.14.
set -eu
cd "$(dirname "$0")"
OUT=../build/BackupDrive.app
rm -rf "$OUT"
mkdir -p "$OUT/Contents/MacOS" "$OUT/Contents/Resources"

clang -fobjc-arc -arch x86_64 -mmacosx-version-min=10.14 \
  -Wall -Werror -Wunguarded-availability -Werror=unguarded-availability \
  -framework Cocoa -o "$OUT/Contents/MacOS/BackupDrive" main.m

cp Info.plist "$OUT/Contents/"
plutil -lint "$OUT/Contents/Info.plist" >/dev/null
cp Resources/*.png "$OUT/Contents/Resources/"
iconutil -c icns Resources/AppIcon.iconset -o "$OUT/Contents/Resources/AppIcon.icns"
# Firma ad hoc: sin certificado. Al descargarla de la CI, abrirla la primera vez con clic derecho > Abrir.
codesign --force --sign - "$OUT"

lipo -info "$OUT/Contents/MacOS/BackupDrive"
otool -l "$OUT/Contents/MacOS/BackupDrive" | grep -A3 -E 'LC_VERSION_MIN_MACOSX|LC_BUILD_VERSION' | grep -E 'version|minos' || true
echo "OK: $OUT"
