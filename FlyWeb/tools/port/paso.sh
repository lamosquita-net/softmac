#!/bin/bash
# paso.sh <área> <lista.tsv> [max]: aplica en w-<área>, en orden, los commits de la lista que faltan (next.sh), con
# ap.sh, y hace commit «<hash> <asunto>» de cada uno que entra limpio. Se para en el primero con rechazos (los deja en
# el árbol, sin commit) o tras [max] commits. Al resolverlo: ok.sh <área> <hash>. MOTOR-13 (FM.28).
A=$1; L=$2; MAX=${3:-1000}; P=/tmp/claude-0/port; W=$P/w-$A; n=0
for c in $($P/next.sh $A $L); do
  [ $n -ge $MAX ] && break; n=$((n+1))
  [ -s $P/$c.ng.diff ] || { $P/ok.sh $A $c "EMPTY (only tests/excluded files)"; continue; }
  out=$($P/ap.sh $A $c)
  if [ -n "$(cd $W && find . -name '*.rej')" ] || echo "$out" | grep -q 'does not exist\|No such file'; then
    echo "== $c $(cd /home/user/chromium/chromium && git log -1 --format=%s $c)"; echo "$out"; exit 1; fi
  $P/ok.sh $A $c >/dev/null; echo "ok $c"
done
