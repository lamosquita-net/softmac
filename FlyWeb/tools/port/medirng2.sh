#!/bin/bash
# medirng.sh <nombre> <commit>... : como medir.sh, pero traduce cada diff con ngtraducir.py (LayoutNG de la 116). MOTOR-9.
CH=${CH:-/home/user/chromium/chromium}; C116=/tmp/claude-0/port/cr116; BC=/home/user/brave-core/patches; P=/tmp/claude-0/port
n=$1; shift; W=$P/medir/w-$n; mkdir -p $P/medir; rm -rf $W; mkdir -p $W; cd $W; git init -q .
EXC=(':!*_test.cc' ':!*unittest*' ':!*/web_tests/*' ':!*/test/*' ':!AUTHORS' ':!content/public/android/*' ':!*browsertest*' ':!*/data/*' ':!tools/metrics/*')
for c in "$@"; do git -C $CH show --format= $c -- . "${EXC[@]}" | python3 $P/ngtraducir.py $P/ngmap.json 2>/dev/null > $W/$c.ng.diff; sed -n 's#^+++ b/##p' $W/$c.ng.diff; done | sort -u > files.txt
while read f; do mkdir -p "$(dirname "$f")"; if [ -e "$C116/$f" ]; then cp "$C116/$f" "$f"; p="$BC/$(echo "$f" | sed 's#/#-#g').patch"; [ -e "$p" ] && patch -s -p1 < "$p" > /dev/null 2>&1 && echo "$f" >> parcheados.txt; fi; done < files.txt
git add -A >/dev/null 2>&1; git commit -qm base >/dev/null 2>&1
tot=0; totf=0
for c in "$@"; do
  h=$(grep -c '^@@' $W/$c.ng.diff)
  out=$(patch -p1 -f --no-backup-if-mismatch -r - < $W/$c.ng.diff 2>&1); echo "$out" > $W/$c.out
  f=$(echo "$out" | grep -c 'Hunk #.* FAILED'); z=$(echo "$out" | grep -c 'fuzz'); m=$(echo "$out" | grep -c "can't find file")
  tot=$((tot+h)); totf=$((totf+f))
  echo "  $c: $h hunks, $f rechazados, $z con fuzz, $m ausentes"
  git add -A >/dev/null 2>&1; git commit -qm "$c" >/dev/null 2>&1
done
echo "== $n: $tot hunks, $totf rechazados; ficheros $(wc -l < files.txt)"
