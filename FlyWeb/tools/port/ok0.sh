#!/bin/bash
# ok0.sh <área> <commit>: como ok1.sh pero permite paso vacío (todo ya estaba o se descartó). MOTOR-37.
cd /tmp/claude-0/port/w-$1 && find . -name '*.rej' -delete && git add -A && git -c user.email=x -c user.name=x commit -q --allow-empty -m $2 && echo "ok $2"
