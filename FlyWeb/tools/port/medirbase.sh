#!/bin/bash
# medirbase.sh <nombre> <commit>... : como medir.sh, con la base y los parches configurables (MOTOR-14, Fase 3 de la
# migración a la 128). BASE = copia parcial de Chromium (mkcr.sh), BC = carpeta patches/ de brave-core que se aplica
# encima (p. ej. la de Brave v1.69.168), CH = historia de Chromium. Sin traductor de LayoutNG (la 128 ya usa los
# nombres nuevos). Salida: una línea por commit (hunks, rechazados, fuzz, ficheros ausentes) y el total.
CH=${CH:-/home/user/chromium/hist}; BASE=${BASE:-/tmp/claude-0/port/cr128}; BC=${BC:-/home/user/brave169/patches}
P=/tmp/claude-0/port; n=$1; shift; W=$P/medir/w-$n; mkdir -p $P/medir; rm -rf $W; mkdir -p $W; cd $W; git init -q .
EXC=(':!*_test.cc' ':!*unittest*' ':!*/web_tests/*' ':!*/test/*' ':!AUTHORS' ':!content/public/android/*' ':!*browsertest*' ':!*/data/*' ':!tools/metrics/*')
for c in "$@"; do git -C $CH show --format= --name-only $c -- . "${EXC[@]}"; done | sort -u > files.txt
while read f; do
  mkdir -p "$(dirname "$f")"
  if [ -e "$BASE/$f" ]; then cp "$BASE/$f" "$f"; p="$BC/$(echo "$f" | sed 's#/#-#g').patch"; [ -e "$p" ] && patch -s -p1 < "$p" > /dev/null 2>&1 && echo "$f" >> parcheados.txt; fi
done < files.txt
git add -A >/dev/null 2>&1; git commit -qm base >/dev/null 2>&1
tot=0; totf=0
for c in "$@"; do
  git -C $CH show --format= $c -- . "${EXC[@]}" > $W.diff
  h=$(grep -c '^@@' $W.diff)
  out=$(patch -p1 -f --no-backup-if-mismatch -r - < $W.diff 2>&1)
  f=$(echo "$out" | grep -c 'Hunk #.* FAILED'); z=$(echo "$out" | grep -c 'fuzz'); m=$(echo "$out" | grep -c "can't find file")
  tot=$((tot+h)); totf=$((totf+f))
  echo "  $c: $h hunks, $f rechazados, $z con fuzz, $m ausentes"
  git add -A >/dev/null 2>&1; git commit -qm "$c" >/dev/null 2>&1
done
echo "== $n: $tot hunks, $totf rechazados; ficheros $(wc -l < files.txt) (con parche de Brave: $(cat parcheados.txt 2>/dev/null | wc -l))"
