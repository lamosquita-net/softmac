#!/bin/bash
# ok.sh <área> <hash> [nota]: commit del paso <hash> en w-<área> (sin .rej). MOTOR-13.
A=$1; c=$2; P=/tmp/claude-0/port; W=$P/w-$A; cd $W
[ -z "$(find . -name '*.rej')" ] || { echo "QUEDAN .rej"; find . -name '*.rej'; exit 1; }
s=$(cd /home/user/chromium/chromium && git log -1 --format=%s $c)
git add -A && git -c user.email=x -c user.name=x commit -q --allow-empty -m "$c $s${3:+ [$3]}" && echo "commit $c"
