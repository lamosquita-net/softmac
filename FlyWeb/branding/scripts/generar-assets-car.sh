#!/bin/zsh
# Genera el catálogo de activos de macOS (Assets.car) de FlyWeb para la base 156 desde el maestro M1-01.
# Uso: generar-assets-car.sh <chromium-src> <destino>
#   <chromium-src>: árbol de Chromium 156 (usa tools/mac/icons/compile_car.py y su mac_sdk.gni).
#   <destino>: carpeta donde quedan Assets.car y sus fuentes (Assets.xcassets y AppIcon.icon); en brave-core,
#              app/theme/brave/mac (updateBranding lo copia a chrome/app/theme/brave/mac).
# Necesita Xcode 26 (actool >= 24112) y swiftc. La 156 pide chrome/app/theme/<marca>/mac/Assets.car
# (chrome/BUILD.gn); el de Chromium no puede salir en una build de FlyWeb.
#
# Qué lleva el catálogo (ver docs/mac/icons.md de Chromium):
# - AppIcon (bitmaps, macOS 11–15): M1-01 con margen de ~100/1024 por lado, la rejilla de 824 de los iconos de
#   Apple (en Mojave se sigue usando app.icns, a sangre, que genera generar-marca.sh).
# - AppIcon (macOS 26+, Icon Composer): fondo naranja #f90 y la mosca de M1-01 en dos capas (alas blancas
#   translúcidas y cuerpo negro). Variante oscura: fondo gris oscuro y cuerpo naranja. Variante teñida: grises, como
#   Chromium.
# - Icon (insignia de documentos, UTTypeIconBadgeName): M1-01 a sangre, 256 y 512.
set -eu
CR=${1:?chromium-src}; DEST=${2:?destino}
D=${0:A:h}; M=$D/..
APP=$M/M1-01.svg
TMP=$(mktemp -d); trap 'rm -rf $TMP' EXIT
swiftc -O $D/rasterizar.swift -o $TMP/rasterizar 2>/dev/null
R=$TMP/rasterizar
W=$TMP/cat; mkdir -p $W
CRT=$CR/chrome/app/theme/chromium/mac/Assets.xcassets

echo "== Assets.xcassets (bitmaps para macOS 11–15 e insignia de documentos)"
X=$W/Assets.xcassets
mkdir -p $X/AppIcon.appiconset $X/Icon.iconset
cp $CRT/Contents.json $X/Contents.json
cp $CRT/AppIcon.appiconset/Contents.json $X/AppIcon.appiconset/Contents.json
for s in 16 32 64 128 256 512 1024; do $R $APP $s $s $X/AppIcon.appiconset/appicon_$s.png - 0.0977; done
$R $APP 256 256 $X/Icon.iconset/icon_256x256.png
$R $APP 512 512 $X/Icon.iconset/icon_256x256@2x.png

echo "== AppIcon.icon (macOS 26+): capas sacadas de M1-01"
I=$W/AppIcon.icon; mkdir -p $I/Assets
python3 - $APP $I/Assets <<'EOF'
import re, sys
src, out = sys.argv[1], sys.argv[2]
s = open(src).read()
paths = re.findall(r'<path(?: class="(cls-\d)")? d="([^"]+)"/>', s)
# M1-01: cls-1 = disco naranja (circle, fuera), cls-2 = ala blanca 0.8, cls-3 = alas blancas 0.4, sin clase = cuerpo.
alas = [(c, d) for c, d in paths if c in ('cls-2', 'cls-3')]
cuerpo = [d for c, d in paths if not c]
assert alas and cuerpo, 'M1-01 ha cambiado: revisar las clases de las capas'
op = {'cls-2': 0.8, 'cls-3': 0.4}
hdr = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">'
open(f'{out}/alas.svg', 'w').write(hdr + ''.join(
    f'<path fill="#fff" fill-opacity="{op[c]}" d="{d}"/>' for c, d in alas) + '</svg>\n')
open(f'{out}/cuerpo.svg', 'w').write(hdr + ''.join(f'<path d="{d}"/>' for d in cuerpo) + '</svg>\n')
EOF
cat > $I/icon.json <<'EOF'
{
  "fill" : {
    "solid" : "srgb:1.00000,0.60000,0.00000,1.00000"
  },
  "fill-specializations" : [
    {
      "appearance" : "dark",
      "value" : {
        "solid" : "srgb:0.13000,0.13000,0.14000,1.00000"
      }
    },
    {
      "appearance" : "tinted",
      "value" : {
        "solid" : "extended-gray:0.20000,1.00000"
      }
    }
  ],
  "groups" : [
    {
      "layers" : [
        {
          "fill-specializations" : [
            {
              "appearance" : "dark",
              "value" : {
                "solid" : "srgb:1.00000,0.60000,0.00000,1.00000"
              }
            },
            {
              "appearance" : "tinted",
              "value" : {
                "solid" : "extended-gray:1.00000,1.00000"
              }
            }
          ],
          "glass" : false,
          "image-name" : "cuerpo.svg",
          "name" : "cuerpo"
        },
        {
          "glass" : true,
          "image-name" : "alas.svg",
          "name" : "alas"
        }
      ],
      "shadow" : {
        "kind" : "neutral",
        "opacity" : 0.5
      },
      "translucency" : {
        "enabled" : true,
        "value" : 0.4
      }
    }
  ],
  "supported-platforms" : {
    "squares" : [
      "macOS"
    ]
  }
}
EOF

echo "== actool (compile_car.py de Chromium)"
python3 $CR/tools/mac/icons/compile_car.py $X
[ -f $W/Assets.car ] || { echo "actool no ha dejado Assets.car" >&2; exit 1; }

mkdir -p $DEST
rm -rf $DEST/Assets.xcassets $DEST/AppIcon.icon
cp -R $X $I $DEST/
cp $W/Assets.car $DEST/Assets.car
echo "  $DEST/Assets.car ($(stat -f %z $DEST/Assets.car) bytes)"
xcrun assetutil --info $DEST/Assets.car | grep -E '"(AssetType|Name|Appearance)"' | sort | uniq -c
