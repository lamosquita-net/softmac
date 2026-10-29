#!/bin/bash
# msg.sh <sha>...: fecha, sha completo y asunto (y Bug) de commits de Chromium por Gitiles. MOTOR-32.
for s in "$@"; do curl -s "https://chromium.googlesource.com/chromium/src/+/$s?format=JSON" | tail -n +2 | python3 -c '
import json,sys; d=json.load(sys.stdin); m=d["message"].splitlines()
print(d["committer"]["time"], d["commit"][:12], m[0]); [print("   ",l) for l in m if l.startswith(("Bug:","Fixed:"))]'; done
