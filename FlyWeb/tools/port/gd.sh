#!/bin/bash
# gd.sh <sha> : diff de un commit de Chromium -> /tmp/claude-0/port/diffs/<sha>.diff. Primero la historia local
# (/home/user/chromium/hist, sin árboles: baja lo que haga falta, ~5 s); si no, Gitiles (resuelve sha corto, ~40 s).
s=$1; d=/tmp/claude-0/port/diffs; mkdir -p $d; H=/home/user/chromium/hist
if git -C $H rev-parse -q --verify "$s^{commit}" >/dev/null 2>&1 && timeout 300 git -C $H show --format= $s > $d/$s.diff 2>/dev/null && [ -s $d/$s.diff ]; then
  wc -l < $d/$s.diff; exit 0; fi
full=$(curl -s "https://chromium.googlesource.com/chromium/src/+/$s?format=JSON" | tail -n +2 | python3 -c 'import json,sys; print(json.load(sys.stdin)["commit"])')
for i in 1 2 3; do curl -s "https://chromium.googlesource.com/chromium/src/+/$full%5E%21/?format=TEXT" | base64 -d > $d/$s.diff 2>/dev/null && [ -s $d/$s.diff ] && break; sleep 3; done
wc -l < $d/$s.diff
