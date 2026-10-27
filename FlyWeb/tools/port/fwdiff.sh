#!/bin/bash
# fwdiff.sh <commit de brave-core> [<fichero de Chromium>...] : diff de Chromium equivalente a un commit de FlyWeb
# sobre la 116 (cambia .patch enteros): para cada parche, 116+parche del padre frente a 116+parche del commit.
# Sirve para llevar a la 128 lo hecho a mano en la 116 (MOTOR-15). Salida por stdout.
C=$1; shift; BC=/home/user/brave-core; CH=/home/user/chromium/hist
T=$(mktemp -d)
for p in $(git -C $BC diff --name-only $C^ $C -- 'patches/*.patch' | grep -v '^patches/v8/'); do
  for side in a b; do rev=$C; [ $side = a ] && rev=$C^
    mkdir -p $T/$side; git -C $BC show $rev:$p > $T/p.$side 2>/dev/null || : > $T/p.$side
  done
  f=$(sed -n 's#^+++ b/##p' $T/p.b | head -1); [ -z "$f" ] && f=$(sed -n 's#^--- a/##p' $T/p.a | head -1)
  [ $# -gt 0 ] && ! printf '%s\n' "$@" | grep -qx "$f" && continue
  for side in a b; do mkdir -p $T/$side/$(dirname $f); git -C $CH show 116.0.5845.188:$f > $T/$side/$f 2>/dev/null || rm -f $T/$side/$f
    [ -s $T/p.$side ] && (cd $T/$side && patch -s -p1 -f < $T/p.$side >/dev/null) ; done
  A=a/$f; B=b/$f; [ -e $T/$A ] || A=/dev/null; [ -e $T/$B ] || B=/dev/null
  (cd $T && git diff --no-index --full-index $A $B | sed "s#a/a/#a/#g; s#b/b/#b/#g; s#a/b/#a/#; s#b/a/#b/#")
done
rm -rf $T
