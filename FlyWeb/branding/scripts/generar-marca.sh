#!/bin/zsh
# Genera en brave-core todos los recursos de marca de macOS desde los maestros elegidos (imagenes.md).
# Uso: generar-marca.sh <brave-core>
# Sustituye a render-brand.js (que partía de un único SVG provisional). Necesita swiftc, iconutil y cwebp.
set -eu
B=${1:?brave-core}
D=${0:A:h}; M=$D/..
TMP=$(mktemp -d); trap 'rm -rf $TMP' EXIT
swiftc -O $D/rasterizar.swift -o $TMP/rasterizar 2>/dev/null
R=$TMP/rasterizar
r() { $R "$@"; print -r -- "  $4"; }   # r <svg> <ancho> <alto> <salida> [tinte] [margen]

APP=$M/M1-01.svg; DEV=$M/O1-01.svg; DOC=$M/O2-02.svg
SYM=$M/M2.svg; MONO=$M/M3_1.svg
LOGO=$M/M4-fondo-claro.svg; LOGO_W=$M/M4-fondo-oscuro.svg; LOGO_S=$M/M4-fondo-claro-pequeño.svg

# .icns con todos los tamaños de macOS (16–512 a 1x y 2x)
icns() {
  local set=$TMP/i.iconset; rm -rf $set; mkdir $set
  for s in 16 32 128 256 512; do
    $R $1 $s $s $set/icon_${s}x${s}.png; $R $1 $((s*2)) $((s*2)) $set/icon_${s}x${s}@2x.png
  done
  iconutil -c icns $set -o $2; print -r -- "  $2"
}
echo "== Icono de la app (M1-01; canal development: O1-01), documento (O2-02) y volumen del DMG"
T=$B/app/theme/brave
for c in "" beta dev nightly; do icns $APP $T/mac/${c:+$c/}app.icns; done
icns $DEV $T/mac/development/app.icns
icns $DOC $T/mac/document.icns
icns $APP $B/build/mac/dmg.icns
for c in beta dev nightly; do icns $APP $B/build/mac/dmg-$c.icns; done
icns $DEV $B/build/mac/dmg-development.icns

echo "== product_logo_* (M1-01 / O1-01) y el monocromo de 22 (M3_1)"
for s in 22 24 48 64 128 256; do r $APP $s $s $T/product_logo_$s.png; done
for c in beta dev nightly; do r $APP 128 128 $T/product_logo_128_$c.png; done
r $DEV 128 128 $T/product_logo_128_development.png
r $MONO 22 22 $T/product_logo_22_mono.png '#000000' 0.05

echo "== Pestañas de las páginas internas (M2, todos los canales)"
for c in "" _beta _dev _development _nightly; do
  for s in 16 32; do
    for dir sc in default_100_percent 1 default_200_percent 2; do
      f=$B/app/theme/$dir/brave/product_logo_$s$c.png
      [ -f $f ] && r $SYM $((s*sc)) $((s*sc)) $f
    done
  done
done

echo "== Logotipos con nombre (M4): 22 de alto con el pequeño, 48 y blanco con el normal"
A=$B/app/theme
r $LOGO_S 77 22 $A/default_100_percent/brave/product_logo_name_22.png
r $LOGO_S 154 44 $A/default_200_percent/brave/product_logo_name_22.png
r $LOGO 164 48 $A/default_100_percent/brave/product_logo_name_48.png
r $LOGO 328 96 $A/default_200_percent/brave/product_logo_name_48.png
r $LOGO_W 214 64 $A/default_100_percent/brave/product_logo_white.png
r $LOGO_W 428 128 $A/default_200_percent/brave/product_logo_white.png
# brave://version: 180 pt de ancho (#logo en about_version.css); claro y oscuro
C=$B/components/resources
for dir w h in default_100_percent 180 53 default_200_percent 360 106; do
  r $LOGO $w $h $C/$dir/brave/product_logo.png
  r $LOGO_W $w $h $C/$dir/brave/product_logo_white.png
done

echo "== Iconos vectoriales (.icon) desde M3_1"
python3 $D/svg2icon.py $MONO 32 $B/vector_icons/components/omnibox/browser/vector_icons/product.icon $TMP/pv32.svg
python3 $D/svg2icon.py $MONO 96 $B/vector_icons/ui/message_center/vector_icons/product.icon $TMP/pv96.svg
python3 $D/svg2icon.py $MONO 24 $B/components/vector_icons/brave/product.icon $TMP/pv24.svg

echo "== Leo (Ajustes): monocromo de M3_1; color = M1-01 tal cual (ya lleva su disco)"
L=$B/ui/webui/resources/flyweb_icons
python3 $D/leo-icons.py $MONO $L >/dev/null
tr -d '\n' < $APP > $L/product-brave-color.svg; echo >> $L/product-brave-color.svg
print -r -- "  $L"

echo "== Extensión interna (M2) y favicon de la bienvenida"
E=$B/components/brave_extension/extension/brave_extension/assets/img
for s in 16 32 48 64 128 256; do r $SYM $s $s $E/icon-$s.png; done
r $SYM 32 32 $TMP/fav32.png; sips -s format ico $TMP/fav32.png --out $B/components/img/welcome/favicon.ico >/dev/null
print -r -- "  $B/components/img/welcome/favicon.ico"

echo "== Bienvenida (M1-01), 300×358 para que en Retina no se amplíe"
r $APP 300 358 $TMP/welcome.png - 0.05
cwebp -quiet -lossless $TMP/welcome.png -o $B/components/brave_welcome_ui/assets/brave_logo_3d@2x.webp
print -r -- "  $B/components/brave_welcome_ui/assets/brave_logo_3d@2x.webp"

echo "== Botón de Escudos: escudo PROVISIONAL (hasta M6) con la mosca de M3_1 en blanco"
d=$(grep -o '<path d="[^"]*"' $MONO | head -1 | cut -d'"' -f2)
S=$B/components/brave_shields/resources
for name fill in icon '#1E8E3E' icon-off '#80868B'; do
  cat > $TMP/$name.svg <<EOF
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 36 36"><path d="M18 1.5 L32 6.5 V17 C32 25.5 26 31.5 18 34.5 C10 31.5 4 25.5 4 17 V6.5 Z" fill="$fill"/><g transform="translate(8.5 8) scale(1.19)"><path fill="#ffffff" d="$d"/></g></svg>
EOF
  r $TMP/$name.svg 18 18 $S/$name-18.png
  r $TMP/$name.svg 36 36 $S/$name-36.png
  r $TMP/$name.svg 64 64 $S/$name.png
done
