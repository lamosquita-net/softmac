#!/bin/bash
# runfz.sh <área> <lista>: run.sh, y en cada parada fz3.sh; sigue si entran todos los .rej (MOTOR-36).
A=$1; L=$2; P=/tmp/claude-0/port
while true; do out=$($P/run.sh $A $L 2>&1); echo "$out" | grep -q FIN && { echo "$out" | tail -1; exit 0; }
  c=$(echo "$out" | grep -o '^== [0-9a-f]*' | tail -1 | cut -c4-); [ -z "$c" ] && c=$(echo "$out" | grep -o '== [0-9a-f]*' | tail -1 | cut -c4-)
  f=$($P/fz3.sh $A 2>&1); if echo "$f" | grep -q QUEDA; then echo "$out" | tail -12; echo "$f"; exit 1; fi
  echo "fuzz $c: $(echo "$f" | tr '\n' ' ')"; $P/ok1.sh $A $c >/dev/null; done
