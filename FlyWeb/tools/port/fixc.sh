#!/bin/bash
# fixc.sh <área> <mensaje>: commit de un arreglo a mano en w-<área>; se niega si hay .rej (paso a medio aplicar). MOTOR-13.
cd /tmp/claude-0/port/w-$1 || exit 1
[ -z "$(find . -name '*.rej')" ] || { echo "HAY .rej: el siguiente commit está a medio aplicar; resuélvelo antes"; find . -name '*.rej'; exit 1; }
git add -A && git -c user.email=x -c user.name=x commit -qm "$2" && echo "commit: $2"
