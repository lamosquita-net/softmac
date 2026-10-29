#!/bin/bash
# fz3.sh <área>: reintenta cada .rej con patch -F3 -l; borra los que entran del todo; deja el resto (MOTOR-33).
cd /tmp/claude-0/port/w-$1
for r in $(find . -name "*.rej" | sed 's#^\./##' | sort); do f=${r%.rej}
  out=$( (echo "--- a/$f"; echo "+++ b/$f"; sed 1d $r) | patch -p1 -F3 -l -N --no-backup-if-mismatch -r /tmp/claude-0/port/fz.rej 2>&1)
  if echo "$out" | grep -q "FAILED\|ignored\|Skipping\|Reversed"; then echo "QUEDA $r"; mv /tmp/claude-0/port/fz.rej $r
  else echo "ENTRA $r $(echo "$out" | grep -o 'fuzz [0-9]' | sort -u | tr '\n' ' ')"; rm -f $r /tmp/claude-0/port/fz.rej; fi
done
