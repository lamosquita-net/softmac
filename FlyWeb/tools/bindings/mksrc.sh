#!/bin/bash
# Uso: mksrc.sh <dir> → árbol <dir>/src/ para runbind.sh: third_party/blink (116) + generador + parches third_party-blink-* de /home/user/brave-core (rama actual); src/brave → copia de brave-core
set -eu
D=$1/src; C=/home/user/cr116; BC=/home/user/brave-core
rm -rf "${D:?}"; mkdir -p $D/third_party $D/tools $D/build
cp -r $C/third_party/blink $D/third_party/
cp -r $C/third_party/mako $C/third_party/ply $C/third_party/pyjson5 $D/third_party/
cp -r $C/tools/idl_parser $D/tools/; cp $C/build/*.py $D/build/
mkdir -p $D/brave; cp -r $BC/script $BC/chromium_src $D/brave/ 2>/dev/null
cd $D; git init -q; git add -A >/dev/null; git -c user.email=x -c user.name=x commit -qm raw116
bad=0; for P in $BC/patches/third_party-blink-*.patch; do f=$(sed -n 's#^+++ b/##p' $P | head -1); [ -e "$f" ] || head -4 $P | grep -q '^new file' || continue; git apply $P 2>/dev/null || { echo "NO APLICA: $(basename $P)"; bad=$((bad+1)); }; done
git add -A >/dev/null; git -c user.email=x -c user.name=x commit -qm brave; echo "árbol $D listo; parches que no aplican: $bad"
