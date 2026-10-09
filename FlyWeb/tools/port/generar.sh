#!/bin/bash
# Uso: generar.sh <nombre>  → escribe los .patch de w-<nombre> en brave-core/patches
W=/tmp/claude-0/port/w-$1; cd $W; find . -name "*.rej" | grep -q . && { echo "QUEDAN .rej"; exit 1; }
BASE=$(git rev-list --max-parents=0 HEAD); for f in $(git diff --name-only $BASE HEAD); do git diff --full-index $BASE HEAD -- $f > /home/user/brave-core/patches/$(echo $f | tr / -).patch; done
for P in /home/user/brave-core/patches/*.patch; do /tmp/claude-0/port/fixnew.sh $P; done
cd /home/user/brave-core && git status --short | wc -l
