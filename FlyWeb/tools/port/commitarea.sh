#!/bin/bash
# commitarea.sh <área> <mensaje>: commit del área, generar.sh y commit en brave-core, con chk.sh de lo cambiado. MOTOR-10.
# BASE_REF (por defecto, la rama actual de brave-core) va a generar.sh. TRAILER (opcional): líneas que se añaden al
# mensaje (Co-Authored-By y Claude-Session de la sesión).
set -e
A=$1; MSG=$2; P=/tmp/claude-0/port; BC=/home/user/brave-core
BASE_REF=${BASE_REF:-$(git -C $BC rev-parse --abbrev-ref HEAD)}
cd $P/w-$A; [ -z "$(find . -name '*.rej')" ] || { echo "QUEDAN .rej"; exit 1; }
git add -A; git -c user.email=x -c user.name=x commit -qm "final $A" || true
cd $P && BASE_REF=$BASE_REF ./generar.sh $A | tail -1
cd $BC && git add -A patches && git commit -q -m "$MSG${TRAILER:+

$TRAILER}" && $P/chk.sh HEAD HEAD~1 | tail -1 && git log --oneline -1
