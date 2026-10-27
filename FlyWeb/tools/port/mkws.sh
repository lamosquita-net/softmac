#!/bin/bash
# Uso: mkws.sh <nombre> <fichero>...  → w-<nombre> con los ficheros de la 116 + los .patch actuales de brave-core (para portes a mano)
set -u
N=$1; shift; CR=/home/user/chromium/chromium; BC=/home/user/brave-core; W=/tmp/claude-0/port/w-$N
rm -rf "${W:?}"; mkdir -p "$W"
for f in "$@"; do mkdir -p "$W/$(dirname $f)"; (cd $CR && timeout 200 git show 116.0.5845.188:$f) > "$W/$f" 2>/dev/null || { rm -f "${W:?}/${f:?}"; echo "NUEVO $f"; }; done
cd "$W"; git init -q; git config gc.auto 0; git add .; git -c user.email=x -c user.name=x commit -qm raw116
for f in "$@"; do p=$BC/patches/$(echo $f|tr / -).patch; [ -f $p ] && { git apply $p || echo "PARCHE BRAVE NO APLICA: $f"; }; done
git add -A; git -c user.email=x -c user.name=x commit -qm brave
