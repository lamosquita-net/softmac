#!/bin/bash
# fin133.sh <área> <mensaje>: generar128 y commit en brave-core con el trailer de la sesión (SESION=<id>; por defecto MOTOR-28: pasar siempre SESION).
A=$1; M=$2; P=/tmp/claude-0/port; S=${SESION:-session_01MwmK2mPzyrf5do67riZaYB}
(cd $P/w-$A && git add -A && git -c user.email=x -c user.name=x commit -qm final >/dev/null; true)
$P/generar128.sh $A | grep -v '^[0-9]*$'
cd /home/user/brave-core && git add -A patches && git -c user.name=Claude -c user.email=noreply@anthropic.com commit -qm "$M

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/$S" && git log --oneline -1 && $P/chk128.sh HEAD~1 | tail -1
