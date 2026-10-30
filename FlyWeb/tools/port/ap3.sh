#!/bin/bash
# ap3.sh <área> <commit>: aplica un commit de Chromium por fusión a tres bandas (git merge-file con c^ y c de la
# historia ligera) en los ficheros del área; deja marcas de conflicto y las lista (MOTOR-36).
A=$1; c=$2; P=/tmp/claude-0/port; H=/home/user/chromium/hist; cd $P/w-$A; T=$(mktemp -d)
for f in $(sed -n 's#^diff --git a/\([^ ]*\) b/.*#\1#p' $P/diffs/$c.diff | grep -xFf $P/files-$A.txt); do
  git -C $H show $c^:$f > $T/base 2>/dev/null || : > $T/base
  git -C $H show $c:$f > $T/theirs 2>/dev/null || { [ -e $f ] && git rm -q $f; echo "BORRADO $f"; continue; }
  if [ ! -e $f ]; then mkdir -p $(dirname $f); cp $T/theirs $f; echo "NUEVO $f"; continue; fi
  git merge-file -L fw -L base -L up $f $T/base $T/theirs; n=$?; [ $n -ne 0 ] && echo "CONFLICTO($n) $f"
done; rm -rf $T
