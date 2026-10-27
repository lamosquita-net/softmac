#!/bin/bash
# f16.sh <fichero de Chromium> : contenido del fichero en la 1.15.2 (116 + parche de nube/motor-131-anchor-f16).
f=$1; T=$(mktemp -d); mkdir -p $T/$(dirname $f)
git -C /home/user/chromium/hist show 116.0.5845.188:$f > $T/$f 2>/dev/null || rm -f $T/$f
p=patches/$(echo $f | tr / -).patch
git -C /home/user/brave-core show origin/nube/motor-131-anchor-f16:$p > $T/p 2>/dev/null && (cd $T && patch -s -p1 -f < p >/dev/null)
cat $T/$f; rm -rf $T
