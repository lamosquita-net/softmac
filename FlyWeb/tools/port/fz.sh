#!/bin/bash
# fz.sh <área>: reintenta cada .rej de w-<área> con patch -F3 -l y dice dónde cae (offset/fuzz). MOTOR-29.
cd /tmp/claude-0/port/w-$1
for r in $(find . -name '*.rej' | sed 's#^\./##' | sort); do f=${r%.rej}
  out=$( (echo "--- a/$f"; echo "+++ b/$f"; sed 1d $r) | patch -p1 -F3 -l -N --no-backup-if-mismatch -r /tmp/claude-0/port/fz.rej 2>&1)
  if echo "$out" | grep -q "FAILED\|ignored\|Reversed"; then echo "QUEDA $r: $(echo "$out" | grep -o 'Hunk #[0-9]* FAILED' | tr '\n' ' ')"; mv /tmp/claude-0/port/fz.rej $r
  else echo "ENTRA $r: $(echo "$out" | grep -o 'with fuzz [0-9]\|offset -\?[0-9]*' | tr '\n' ' ')"; rm -f $r; fi; done
