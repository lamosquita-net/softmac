#!/bin/bash
# fwf.sh <fichero>...: deja en /tmp/claude-0/port/fw/<fichero> la versión de FlyWeb (128 + parche de brave-core) y
# escribe su ruta. MOTOR-32.
P=/tmp/claude-0/port; BC=/home/user/brave-core
for f in "$@"; do mkdir -p $P/fw/$(dirname $f); o=$P/fw/$f
  $P/g128.sh $f > $o 2>/dev/null || : > $o
  p=$BC/patches/$(echo $f|tr / -).patch
  [ -f $p ] && (cd $P/fw && git apply --unsafe-paths --directory= $p 2>/dev/null || patch -s -p1 -d $P/fw < $p >/dev/null || echo "NO APLICA $f" >&2)
  echo $o; done
