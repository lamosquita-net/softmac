#!/bin/bash
# Uso: addf.sh <área> <ruta>...  Añade a w-<área> ficheros de la 116 (+ su parche de brave-core) que necesita un
# arreglo a mano y no traía ningún diff de upstream (p. ej. un requisito previo), y hace commit «add files».
W=/tmp/claude-0/port/w-$1; shift; CR=/home/user/chromium/chromium; BC=/home/user/brave-core
cd $W; for f in "$@"; do [ -e "$f" ] && { echo "ya está $f"; continue; }; mkdir -p "$(dirname $f)"
  (cd $CR && timeout 200 git show 116.0.5845.188:$f) > "$f" 2>/dev/null || { rm -f "$f"; echo "NO EXISTE en 116: $f"; continue; }
  p=$BC/patches/$(echo $f|tr / -).patch; [ -f $p ] && { git apply $p || echo "PARCHE BRAVE NO APLICA: $f"; }; done
git add -A; git -c user.email=x -c user.name=x commit -qm "add files: $*" && echo ok
