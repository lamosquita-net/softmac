#!/bin/bash
# seq.sh <área> <lista>: aplica en orden los commits de <lista> que aún no tengan paso en w-<área>; para en el primero con .rej. MOTOR-28.
A=$1; P=/tmp/claude-0/port
for c in $(cat $2); do
  git -C $P/w-$A log --format=%s | grep -qx "$c" && continue
  out=$($P/ap1.sh $A $c)
  if find $P/w-$A -name '*.rej' | grep -q .; then echo "PARA en $c"; echo "$out"; exit 1; fi
  $P/ok1.sh $A $c >/dev/null; echo -n "$c "
done; echo; echo FIN
