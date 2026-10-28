#!/bin/bash
# ap1.sh <área> <commit>: aplica un commit de upstream (sin tests) sobre w-<área> con --reject; lista rechazos. MOTOR-28.
A=$1; c=$2; P=/tmp/claude-0/port; cd $P/w-$A
F=$(cat $P/files-$A.txt)
git -C /home/user/chromium/hist show --format= $c -- $F > $P/$c.diff
git apply --reject --whitespace=nowarn $P/$c.diff 2>&1 | grep -E 'Rejected|error: (patch failed|.*does not exist)' 
find . -name '*.rej' | sed 's#^\./##'
