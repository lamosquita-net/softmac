#!/bin/bash
# skip.sh <área> <commit> <motivo>: deshace el paso y deja un commit vacío «<commit> SKIPPED: motivo». MOTOR-35.
cd /tmp/claude-0/port/w-$1 && git checkout -q . && git clean -fdq && git -c user.email=x -c user.name=x commit -q --allow-empty -m "$2 SKIPPED: $3" && echo "saltado $2"
