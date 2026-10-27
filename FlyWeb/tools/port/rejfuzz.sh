#!/bin/bash
# rejfuzz.sh <área> : reintenta cada .rej.<commit> del área con patch -F3 -l; borra los que entran del todo (MOTOR-15).
cd /tmp/claude-0/port/w-$1
for r in $(find . -name "*.rej.*" | sed 's#^\./##' | sort); do f=${r%.rej.*}
  out=$( (echo "--- a/$f"; echo "+++ b/$f"; sed 1d $r) | patch -p1 -F0 -l -N --no-backup-if-mismatch -r /tmp/claude-0/port/fz.rej 2>&1)
  if echo "$out" | grep -q "FAILED\|ignored\|Skipping\|Reversed"; then n=$(echo "$out" | grep -c "FAILED at\|ignored"); echo "QUEDA $r ($n)"; mv /tmp/claude-0/port/fz.rej $r
  else echo "ENTRA $r"; rm -f $r; fi
done
