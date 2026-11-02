#!/bin/bash
# gdiff.sh <sha> : diff del commit (contra su primer padre) desde gitiles, con caché en gd/ (MOTOR-43). Sin git local.
D=/tmp/claude-0/port/gd/$1.diff
if [ ! -s "$D" ]; then
  for i in 1 2 3 4 5; do curl -sSf "https://chromium.googlesource.com/chromium/src/+/$1%5E%21/?format=TEXT" 2>/dev/null | base64 -d > "$D.t" 2>/dev/null && [ -s "$D.t" ] && mv "$D.t" "$D" && break; sleep 3; done
fi
[ -s "$D" ] || { echo "gdiff: no se pudo traer $1" >&2; exit 1; }
cat "$D"
