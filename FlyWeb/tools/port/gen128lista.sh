#!/bin/bash
# gen128lista.sh <lista de ficheros>: como generar128.sh, pero solo para los ficheros de la lista (w-all frente a la 128).
W=/tmp/claude-0/port/w-all; CR=/tmp/claude-0/port/cr128; T=$(mktemp -d)
for f in $(cat $1); do
  P=/home/user/brave-core/patches/$(echo $f | tr / -).patch
  mkdir -p $T/a/$(dirname $f) $T/b/$(dirname $f); rm -f $T/a/$f $T/b/$f
  [ -e $CR/$f ] && cp $CR/$f $T/a/$f
  [ -e $W/$f ] && cp $W/$f $T/b/$f
  A=a/$f; B=b/$f; [ -e $T/$A ] || A=/dev/null; [ -e $T/$B ] || B=/dev/null
  if [ $A != /dev/null ] && [ $B != /dev/null ] && cmp -s $T/$A $T/$B; then [ -e $P ] && { rm -f $P; echo "igual que la 128, borrado: $(basename $P)"; }; continue; fi
  [ $B = /dev/null ] && { echo "AVISO borrado: $f"; continue; }
  (cd $T && git diff --no-index --full-index $A $B | sed "s#^diff --git a/a/#diff --git a/#; s# b/b/# b/#; s#^--- a/a/#--- a/#; s#^+++ b/b/#+++ b/#; s#^diff --git a/dev/null b/b/\(.*\)#diff --git a/\1 b/\1#; s#^diff --git a/b/#diff --git a/#") > $P
done; rm -rf $T
