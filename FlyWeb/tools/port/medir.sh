#!/bin/bash
# medir.sh <nombre> <commit>... : mide un porte antes de hacerlo (MOTOR-8, nivel 129). Monta /tmp/claude-0/port/medir/w-<nombre>
# con los ficheros que tocan los commits (sin pruebas): 116 + el parche de la rama de brave-core que haya en
# /home/user/brave-core; aplica la serie en orden (un commit del área por paso) y cuenta hunks, rechazos y fuzz.
# Necesita la historia de Chromium desde la 116 en /tmp/claude-0/port/chromium/chromium y cr116 (mkcr.sh).
CH=/tmp/claude-0/port/chromium/chromium; C116=/tmp/claude-0/port/cr116; BC=/home/user/brave-core/patches
n=$1; shift; W=/tmp/claude-0/port/medir/w-$n; mkdir -p /tmp/claude-0/port/medir; rm -rf $W; mkdir -p $W; cd $W; git init -q .
EXC=(':!*_test.cc' ':!*unittest*' ':!*/web_tests/*' ':!*/test/*' ':!AUTHORS' ':!content/public/android/*' ':!*browsertest*' ':!*/data/*')
for c in "$@"; do git -C $CH show --format= --name-only $c -- . "${EXC[@]}"; done | sort -u > files.txt
while read f; do
  mkdir -p "$(dirname "$f")"
  if [ -e "$C116/$f" ]; then cp "$C116/$f" "$f"; p="$BC/$(echo "$f" | sed 's#/#-#g').patch"; [ -e "$p" ] && patch -s -p1 < "$p" > /dev/null 2>&1 && echo "$f" >> parcheados.txt; fi
done < files.txt
git add -A >/dev/null 2>&1; git commit -qm base >/dev/null 2>&1
tot=0; totf=0
for c in "$@"; do
  git -C $CH show --format= $c -- . "${EXC[@]}" > $W.diff
  h=$(grep -c '^@@' $W.diff)
  out=$(patch -p1 -f --no-backup-if-mismatch -r - < $W.diff 2>&1)
  f=$(echo "$out" | grep -c 'FAILED'); z=$(echo "$out" | grep -c 'fuzz'); m=$(echo "$out" | grep -c "can't find file")
  tot=$((tot+h)); totf=$((totf+f))
  echo "  $(git -C $CH log -1 --format='%h' $c): $h hunks, $f rechazados, $z con fuzz, $m ficheros nuevos/ausentes"
  git add -A >/dev/null 2>&1; git commit -qm "$c" >/dev/null 2>&1
done
echo "== $n: $tot hunks, $totf rechazados; ficheros $(wc -l < files.txt) (con parche nuestro: $(cat parcheados.txt 2>/dev/null | wc -l))"
