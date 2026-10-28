#!/bin/bash
# generar128.sh <nombre> : escribe los .patch de w-<nombre> en brave-core/patches: diff --full-index de cada fichero
# cambiado del área frente a 128.0.6613.138 (cr128 o la historia; vacío si es nuevo), incluye lo de Brave. Borra el
# parche de un fichero que vuelve a quedar como en la 128. Los ficheros se pueden añadir al área en cualquier momento.
W=/tmp/claude-0/port/w-$1; cd $W; find . -name "*.rej*" | grep -q . && { echo "QUEDAN .rej"; exit 1; }
CR=/tmp/claude-0/port/cr128; CH=/home/user/chromium/hist; T=$(mktemp -d)
# MOTOR-29: también los ficheros del área que tienen parche y han vuelto a quedar como en la 128 (si no, su parche se queda).
for f in $( (git diff --name-only $(git rev-list --max-parents=0 HEAD); git status --porcelain | cut -c4-; R=$(git rev-list --max-parents=0 HEAD); for g in $(cat /tmp/claude-0/port/files-$1.txt 2>/dev/null); do [ -e /home/user/brave-core/patches/$(echo $g | tr / -).patch ] && git diff --quiet $R -- $g 2>/dev/null && echo $g; done) | sort -u); do
  P=/home/user/brave-core/patches/$(echo $f | tr / -).patch
  mkdir -p $T/a/$(dirname $f) $T/b/$(dirname $f); rm -f $T/a/$f $T/b/$f
  if [ -e $CR/$f ]; then cp $CR/$f $T/a/$f; else git -C $CH show 128.0.6613.138:$f > $T/a/$f 2>/dev/null || rm -f $T/a/$f; fi
  [ -e $f ] && cp $f $T/b/$f
  A=a/$f; B=b/$f; [ -e $T/$A ] || A=/dev/null; [ -e $T/$B ] || B=/dev/null
  if [ $A != /dev/null ] && [ $B != /dev/null ] && cmp -s $T/$A $T/$B; then
    [ -e $P ] && { rm -f $P; echo "igual que la 128, borrado: $(basename $P)"; }; continue; fi
  [ $B = /dev/null ] && { echo "AVISO borrado del área: $f"; continue; }
  (cd $T && git diff --no-index --full-index $A $B | sed "s#^diff --git a/a/#diff --git a/#; s# b/b/# b/#; s#^--- a/a/#--- a/#; s#^+++ b/b/#+++ b/#; s#^diff --git a/dev/null b/b/\(.*\)#diff --git a/\1 b/\1#; s#^diff --git a/b/#diff --git a/#") > $P
done; rm -rf $T
cd /home/user/brave-core && git status --short | wc -l
