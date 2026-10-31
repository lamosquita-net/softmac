#!/bin/zsh
# DMG de FlyWeb con el fondo del HUMANO: ventana sin barras, FlyWeb a la izquierda y Aplicaciones a la derecha.
# Uso: dmg-flyweb.sh <FlyWeb.app ya firmada y grapada> <salida.dmg> <fondo.png> <SHA-1 identidad G2>
# Usa dmgbuild (herramientas/venv-dmg), que escribe el .DS_Store directamente: maquetar con Finder por AppleScript
# no guarda el fondo ni las posiciones en macOS 15. Fondo @2x: si existe <fondo>@2x.png, se une en un TIFF.
set -eu
APP=$1; OUT=$2; FONDO=$3; ID=$4
H=~/proyectos/softmac/herramientas
T=$(mktemp -d)
F=$FONDO; X2=${FONDO%.png}@2x.png
[ -f "$X2" ] && { tiffutil -cathidpicheck "$FONDO" "$X2" -out $T/fondo.tiff >/dev/null; F=$T/fondo.tiff; }
cat > $T/ajustes.py <<PY
format = 'UDRW'
filesystem = 'HFS+'
size = '600M'
files = ['$APP']
symlinks = {'Aplicaciones': '/Applications'}
background = '$F'
show_status_bar = False
show_tab_view = False
show_toolbar = False
show_pathbar = False
show_sidebar = False
window_rect = ((200, 560), (602, 360))  # origen abajo a la izquierda (Cocoa)
default_view = 'icon-view'
arrange_by = None
icon_size = 128
text_size = 13
icon_locations = {'FlyWeb.app': (160, 160), 'Aplicaciones': (440, 160)}
PY
rm -f $OUT
RW=$T/rw.dmg
$H/venv-dmg/bin/dmgbuild -s $T/ajustes.py "${VOL:-FlyWeb}" $RW
# Finder de macOS 15 no pinta el fondo tal como lo deja dmgbuild (.background.png en la raíz y marcador pBBk al volumen
# temporal); Mojave sí. Se mueve a .background/fondo.<ext> (como el DMG de Brave) y se rehacen alias y marcador.
# Montado en /Volumes/<nombre> (no en una carpeta temporal): si no, el alias sale con una ruta de «..» que Finder 15 no resuelve.
V="${VOL:-FlyWeb}"; [ -e "/Volumes/$V" ] && { echo "Ya hay un /Volumes/$V montado: expúlsalo"; exit 1; }
M=$(hdiutil attach -readwrite -noverify -noautoopen -nobrowse $RW | grep -o "/Volumes/.*\$")
[ "$M" = "/Volumes/$V" ] || { echo "montado en $M"; hdiutil detach "$M" -quiet; exit 1; }
$H/venv-dmg/bin/python - "$M" <<'PY'
import sys, os, glob
from ds_store import DSStore
from mac_alias import Alias
m = sys.argv[1]
src = glob.glob(os.path.join(m, '.background.*'))[0]
os.mkdir(os.path.join(m, '.background'))
dst = os.path.join(m, '.background', 'fondo' + os.path.splitext(src)[1])
os.rename(src, dst)
ds = os.path.join(m, '.DS_Store')
with DSStore.open(ds, 'r') as d:
    bwsp = d['.']['bwsp']; icvp = d['.']['icvp']
    iloc = {e.filename: e.value for e in d if e.code == b'Iloc'}
icvp['backgroundImageAlias'] = Alias.for_file(dst).to_bytes()
icvp['viewOptionsVersion'] = 1
icvp['showIconPreview'] = True
os.remove(ds)
# .DS_Store nuevo solo con lo que lleva el de Brave (bwsp, icvp, Iloc): sin pBBk, vSrn ni icvl.
with DSStore.open(ds, 'w+') as d:
    d['.']['bwsp'] = bwsp
    d['.']['icvp'] = icvp
    for f, xy in iloc.items():
        d[f]['Iloc'] = xy
PY
hdiutil detach "$M" -quiet
hdiutil convert $RW -format UDZO -imagekey zlib-level=9 -o $OUT >/dev/null
rm -rf $T
codesign --force --timestamp --sign "$ID" $OUT
echo "DMG: $OUT"
