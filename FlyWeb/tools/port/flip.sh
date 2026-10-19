#!/bin/bash
# flip.sh <flag> <prefijo> <nivel> [nota] : pasa a stable un flag que ya existe en la 116 con su código completo
# (solo el json5), con su commit y chk.sh. El mensaje dice el nivel de Chrome en que pasó a stable.
set -eu
F=$1; PR=$2; N=$3; NOTA=${4:-}; P=/tmp/claude-0/port; J=third_party/blink/renderer/platform/runtime_enabled_features.json5
$P/mkws.sh $F $J >/dev/null
cd $P/w-$F && python3 - "$J" "$F" <<'PY'
import re,sys
J,F=sys.argv[1:]; s=open(J).read()
m=re.search(r'\n    \{\n(?:      //.*\n)*      name: "'+re.escape(F)+r'",\n(?:      .*\n|        .*\n)*?    \},', s)
assert m, 'no está '+F
blk=m.group(0); nb=re.sub(r'status: (\{[^}]*\}|"[^"]*")', 'status: "stable"', blk, count=1)
if 'status:' not in nb: nb=nb.replace('name: "'+F+'",\n', 'name: "'+F+'",\n      status: "stable",\n')
assert nb!=blk, 'ya estaba'
open(J,'w').write(s.replace(blk,nb))
PY
{ echo "FM.22 $PR: $F"; echo; echo "Status stable, as in Chrome $N. The code behind the flag is already complete in 116."
  [ -n "$NOTA" ] && { echo; echo "$NOTA"; }
  echo; echo "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"; echo "Claude-Session: https://claude.ai/code/session_01E9YyQZz5fNhwE1HdRNzw6f"; } > $P/msg-flip.txt
MSGFILE=$P/msg-flip.txt $P/fin.sh $F $PR none
