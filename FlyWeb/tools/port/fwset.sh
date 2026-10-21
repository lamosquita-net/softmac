#!/bin/bash
# fwset.sh <área> <commit de FlyWeb> <fichero>... : deja cada fichero del área como en «bc» (128 + parches de la rama) y le
# aplica el diff equivalente de ese commit de FlyWeb sobre la 116 (fwdiff.sh), con fuzz; deja .rej si no entra. Para
# llevar lo hecho a mano en la 116 cuando difiere de upstream (MOTOR-15). Ojo: descarta lo aplicado antes en esos ficheros.
W=/tmp/claude-0/port/w-$1; C=$2; shift 2; cd $W; B=$(git log --format=%H --grep='^bc$' | tail -1)
for f in "$@"; do
  if git cat-file -e $B:$f 2>/dev/null; then git show $B:$f > $f; else rm -f $f; fi
  /tmp/claude-0/port/fwdiff.sh $C $f > /tmp/claude-0/port/fw.diff
  [ -s /tmp/claude-0/port/fw.diff ] || { echo "SIN CAMBIOS en $C: $f"; continue; }
  mkdir -p $(dirname $f); patch -p1 -F3 --no-backup-if-mismatch -r $f.rej.fw < /tmp/claude-0/port/fw.diff | grep -v "^patching"
done
