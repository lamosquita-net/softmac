#!/bin/bash
# syncf.sh <área> <fichero>...  Pone en w-<área> el fichero de la 116 + el parche ACTUAL de brave-core (para no pisar
# lo que otro porte ya cambió en el mismo fichero desde que se montó el área). MOTOR-10.
W=/tmp/claude-0/port/w-$1; shift; CR=/home/user/chromium/chromium; BC=/home/user/brave-core
for f in "$@"; do (cd $CR && git show 116.0.5845.188:$f) > $W/$f || exit 1
  p=$BC/patches/$(echo $f|tr / -).patch; [ -f $p ] && (cd $W && git apply $p) || true; done
