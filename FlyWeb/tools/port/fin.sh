#!/bin/bash
# fin.sh <flag> <prefijo> <add> [<rem>...] : termina a mano un porte de tanda.py (sin .rej en w-<flag>): genera, commit, chk.
# NOTE=... añade un párrafo al mensaje; MSGFILE=<fichero> usa ese mensaje entero (p. ej. para un grupo de flags).
set -u
F=$1; PR=$2; A=$3; shift 3; R="$*"; P=/tmp/claude-0/port; W=$P/w-$F
cd $W && find . -name "*.rej" | grep -q . && { echo "QUEDAN .rej"; exit 1; }
git add -A && git -c user.email=x -c user.name=x commit -qm fix >/dev/null
cd $P && BASE_REF=nube/motor-131-escapes ./generar.sh $F | grep -v "^[0-9]*$"
S=$(cd /home/user/chromium/chromium && git log -1 --format=%s $A)
{ echo "FM.22 $PR: $F"; echo; if [ -n "$R" ]; then echo "Port of $A (\"$S\") and its flag removal $R."; else echo "Port of $A (\"$S\"), flag stable."; fi
  [ -n "${NOTE:-}" ] && { echo; echo "$NOTE"; }
  echo; echo "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"; echo "Claude-Session: https://claude.ai/code/session_01E9YyQZz5fNhwE1HdRNzw6f"; } > $P/msg.txt
[ -n "${MSGFILE:-}" ] && cp "$MSGFILE" $P/msg.txt
cd /home/user/brave-core && git add -A patches && git commit -q -F $P/msg.txt && $P/chk.sh HEAD HEAD~1 | tail -1
