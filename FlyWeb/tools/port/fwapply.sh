#!/bin/bash
# fwapply.sh <área> <commit de FlyWeb> [<fichero>...] : aplica sobre el estado actual del área el diff equivalente de un
# commit de FlyWeb sobre la 116 (fwdiff.sh), con fuzz; los rechazos quedan en <fichero>.rej.fw (MOTOR-15).
W=/tmp/claude-0/port/w-$1; C=$2; shift 2; cd $W
/tmp/claude-0/port/fwdiff.sh $C "$@" > /tmp/claude-0/port/fw.diff
for f in $(sed -n 's#^+++ b/##p' /tmp/claude-0/port/fw.diff); do mkdir -p $(dirname $f); done
patch -p1 -F3 --no-backup-if-mismatch -r - < /tmp/claude-0/port/fw.diff > /tmp/claude-0/port/fw.out 2>&1
grep -B1 "FAILED\|fuzz\|offset" /tmp/claude-0/port/fw.out | grep -v "^--$"
