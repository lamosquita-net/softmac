#!/bin/bash
# Uso: chk.sh <rama>  → comprueba que todos los patches/*.patch (sin v8) aplican sobre la 116; los de fichero nuevo, que el fichero no exista en la 116.
B=$1; cd /home/user/brave-core; bad=0; cnt=0
for P in $(git ls-tree --name-only $B patches/ | grep "\.patch$"); do cnt=$((cnt+1)); T=$(mktemp -d)
  f=$(git show $B:$P | sed -n 's#^+++ b/##p' | head -1); mkdir -p $T/$(dirname $f)
  if git show $B:$P | head -4 | grep -q "^new file mode"; then
    if timeout 60 git -C /home/user/chromium/chromium cat-file -e 116.0.5845.188:$f 2>/dev/null; then echo "$B NUEVO PERO EXISTE: $P"; bad=$((bad+1)); fi
  elif timeout 60 git -C /home/user/chromium/chromium show 116.0.5845.188:$f > $T/$f 2>/dev/null; then
    out=$(cd $T && git -C /home/user/brave-core show $B:$P | git apply --check - 2>&1 | grep -v "^warning")
    if [ -n "$out" ]; then echo "$B NO APLICA: $P: $(echo $out | head -c 200)"; bad=$((bad+1)); fi
  else echo "$B SIN BASE: $P"; bad=$((bad+1)); fi
  rm -rf $T; done
echo "$B: $cnt parches, $bad problemas"
