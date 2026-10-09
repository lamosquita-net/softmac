#!/bin/bash
# Uso: fixnew.sh <ruta .patch absoluta>  → si es de «fichero nuevo» y el fichero existe en la 116, lo rehace como diff 116 → contenido.
P=$1; head -4 $P | grep -q "^new file mode" || exit 0
f=$(sed -n 's#^+++ b/##p' $P | head -1)
timeout 120 git -C /home/user/chromium/chromium cat-file -e 116.0.5845.188:$f 2>/dev/null || exit 0
T=$(mktemp -d); mkdir -p $T/new $T/g/$(dirname $f)
(cd $T/new && patch -s -p1 < $P) || { echo "FALLO al leer $P"; exit 1; }
timeout 120 git -C /home/user/chromium/chromium show 116.0.5845.188:$f > $T/g/$f
(cd $T/g && git init -q && git add -A && git -c user.email=x -c user.name=x commit -qm b && cp $T/new/$f $f && git diff --full-index) > $P
[ -s $P ] || { rm -f $P; echo "vacío, borrado: $(basename $P)"; rm -rf $T; exit 0; }
echo "rehecho como modificación: $(basename $P)"; rm -rf $T
