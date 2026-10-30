#!/bin/bash
# run.sh <área> <lista>: aplica la lista desde el último commit del área; para en el primer .rej (MOTOR-35)
A=$1; Ls=$2; cd /tmp/claude-0/port; last=$(cd w-$A && git log -1 --format=%s | cut -d' ' -f1)
grep -qx "$last" $Ls && R=$(sed -n "/^$last\$/,\$p" $Ls | tail -n +2) || R=$(cat $Ls)
for c in $R; do out=$(./ap1gd.sh $A $c 2>&1); if (cd w-$A && find . -name '*.rej' | grep -q .); then echo "$out"; exit 1; else ./ok1.sh $A $c >/dev/null; echo -n "$c ok; "; fi; done; echo FIN
