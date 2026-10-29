#!/bin/bash
# gd.sh <sha> : diff de un commit de Chromium por Gitiles (resuelve sha corto) -> /tmp/claude-0/port/diffs/<sha>.diff
s=$1; d=/tmp/claude-0/port/diffs; mkdir -p $d
full=$(curl -s "https://chromium.googlesource.com/chromium/src/+/$s?format=JSON" | tail -n +2 | python3 -c 'import json,sys; print(json.load(sys.stdin)["commit"])')
for i in 1 2 3; do curl -s "https://chromium.googlesource.com/chromium/src/+/$full%5E%21/?format=TEXT" | base64 -d > $d/$s.diff 2>/dev/null && [ -s $d/$s.diff ] && break; sleep 3; done
wc -l < $d/$s.diff
