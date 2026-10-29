#!/bin/bash
# ap1gd.sh <área> <commit>: aplica un commit (diff de Gitiles, solo ficheros del área) con --reject; rechazos. MOTOR-32.
A=$1; c=$2; P=/tmp/claude-0/port; cd $P/w-$A
[ -s $P/diffs/$c.diff ] || $P/gd.sh $c >/dev/null
inc=$(sed 's/^/--include=/' $P/files-$A.txt | tr '\n' ' ')
echo "== $c"; git apply --reject --whitespace=nowarn $inc $P/diffs/$c.diff 2>&1 | grep -E 'Rejected|error: (patch failed|.*does not exist)'
find . -name '*.rej' | sed 's#^\./##'
