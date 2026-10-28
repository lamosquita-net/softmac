#!/bin/bash
# ok1.sh <área> <commit>: commit del paso en w-<área> (falla si quedan .rej). MOTOR-28.
cd /tmp/claude-0/port/w-$1 && { find . -name '*.rej' | grep -q . && { echo "QUEDAN .rej"; find . -name '*.rej'; exit 1; }; git add -A; git -c user.email=x -c user.name=x commit -qm $2; echo ok $2; }
