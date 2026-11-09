#!/bin/zsh
# Genera el catálogo de activos de macOS (Assets.car) de FlyWeb para la base 156.
# Uso: generar-assets-car.sh <chromium-src> <destino> <app.icns de la 2.7.0>
#   <chromium-src>: árbol de Chromium 156 (plantillas Contents.json de chrome/app/theme/chromium/mac).
#   <destino>: carpeta donde quedan Assets.car y su fuente (Assets.xcassets); en brave-core,
#              app/theme/brave/mac (updateBranding lo copia a chrome/app/theme/brave/mac).
#   <app.icns de la 2.7.0>: FlyWeb.app/Contents/Resources/app.icns de la 2.7.0 (entregas/FlyWeb-2.7.0-release).
# Necesita Xcode (actool) y swiftc. La 156 pide chrome/app/theme/<marca>/mac/Assets.car (chrome/BUILD.gn) y pone
# CFBundleIconName=AppIcon en el Info.plist: desde macOS 10.13 (Mojave incluido) el Dock y el Finder toman entonces el
# AppIcon del Assets.car y no app.icns. El de Chromium no puede salir en una build de FlyWeb.
#
# Criterio (Titín, 09-11): el icono se ve IDÉNTICO al de la 2.7.0 en todos los sistemas. Por eso:
# - AppIcon: solo bitmaps, las imágenes del app.icns de la 2.7.0 tal cual (iconutil). Comprobado en Sequoia: el
#   icono que dibuja NSWorkspace sale igual píxel a píxel que el de la 2.7.0.
# - SIN AppIcon.icon de Icon Composer. En la 3.0.0 se metía uno (fondo naranja y la mosca en capas) y actool genera
#   con él las imágenes para macOS < 26, que pasan por delante de los bitmaps (con Xcode 26.2 la opción
#   --enable-icon-stack-fallback-generation=disabled de compile_car.py no lo evita): en Sequoia y Mojave salía un
#   cuadrado redondeado naranja con la mosca más grande en lugar del disco de siempre. En macOS 26 el sistema pone
#   el disco dentro de su forma, como hacía con la 2.7.0.
# - Icon (insignia de documentos, UTTypeIconBadgeName): M1-01 a sangre, 256 y 512.
set -eu
CR=${1:?chromium-src}; DEST=${2:?destino}; ICNS=${3:?app.icns de la 2.7.0}
D=${0:A:h}; M=$D/..
APP=$M/M1-01.svg
TMP=$(mktemp -d); trap 'rm -rf $TMP' EXIT
swiftc -O $D/rasterizar.swift -o $TMP/rasterizar 2>/dev/null
R=$TMP/rasterizar
W=$TMP/cat; mkdir -p $W
CRT=$CR/chrome/app/theme/chromium/mac/Assets.xcassets

echo "== Assets.xcassets (AppIcon de la 2.7.0 e insignia de documentos)"
X=$W/Assets.xcassets
mkdir -p $X/AppIcon.appiconset $X/Icon.iconset
cp $CRT/Contents.json $X/Contents.json
cp $CRT/AppIcon.appiconset/Contents.json $X/AppIcon.appiconset/Contents.json
iconutil -c iconset -o $TMP/app.iconset $ICNS
for p in 16:16x16 32:32x32 64:32x32@2x 128:128x128 256:256x256 512:512x512 1024:512x512@2x; do
  cp $TMP/app.iconset/icon_${p#*:}.png $X/AppIcon.appiconset/appicon_${p%%:*}.png
done
$R $APP 256 256 $X/Icon.iconset/icon_256x256.png
$R $APP 512 512 $X/Icon.iconset/icon_256x256@2x.png

echo "== actool (sin .icon)"
xcrun actool --output-format=human-readable-text --notices --warnings --errors --platform=macosx --target-device=mac \
  --lightweight-asset-runtime-mode=enabled --app-icon=AppIcon --minimum-deployment-target=10.14 \
  --output-partial-info-plist=$W/partial.plist --compile=$W $X
[ -f $W/Assets.car ] || { echo "actool no ha dejado Assets.car" >&2; exit 1; }

mkdir -p $DEST
rm -rf $DEST/Assets.xcassets $DEST/AppIcon.icon
cp -R $X $DEST/
cp $W/Assets.car $DEST/Assets.car
echo "  $DEST/Assets.car ($(stat -f %z $DEST/Assets.car) bytes)"
xcrun assetutil --info $DEST/Assets.car | grep -E '"(AssetType|Name)"' | sort | uniq -c
