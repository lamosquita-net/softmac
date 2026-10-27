#!/bin/bash
# Uso: portarng.sh <nombre> <commit>...   Como portar.sh, pero pasa cada diff de upstream por ngtraducir.py (rutas y
# nombres de LayoutNG de la 116; mapa en /tmp/claude-0/port/ngmap.json, de ngmap.py). Sin tests. Con STEP=1 solo
# monta el área de trabajo y guarda los diffs traducidos (<commit>.ng.diff), para aplicarlos paso a paso.
set -u
N=$1; shift; L="$@"
CR=/home/user/chromium/chromium; BC=/home/user/brave-core; P=/tmp/claude-0/port; W=$P/w-$N; MAP=$P/ngmap.json
EXCL="web_tests/\|_test\.cc\|browsertest\|/test/\|devtools-frontend\|perftest\|perf_tests\|_unittest\|tools/metrics\|\.md$\|DEPS$\|OWNERS$\|TestExpectations\|VirtualTestSuites"
for c in $L; do
  F=$(cd $CR && timeout 300 git show --name-only --format= $c | grep -v "$EXCL")
  [ -z "$F" ] && { : > $P/$c.ng.diff; continue; }
  (cd $CR && timeout 300 git show --format= $c -- $F) | python3 $P/ngtraducir.py $MAP > $P/$c.ng.diff
done
F=$(for c in $L; do sed -n 's#^+++ b/##p; s#^--- a/##p' $P/$c.ng.diff; done | grep -v '^/dev/null' | sort -u)
echo "$F" > $P/files-$N.txt
rm -rf "${W:?}"; mkdir -p "$W"
for f in $F; do mkdir -p "$W/$(dirname $f)"; (cd $CR && timeout 200 git show 116.0.5845.188:$f) > "$W/$f" 2>/dev/null || { rm -f "${W:?}/${f:?}"; echo "NUEVO $f"; }; done
cd "$W"; git init -q; git config gc.auto 0; git add .; git -c user.email=x -c user.name=x commit -qm raw116
for f in $F; do p=$BC/patches/$(echo $f|tr / -).patch; [ -f $p ] && { git apply $p || echo "PARCHE BRAVE NO APLICA: $f"; }; done
git add -A; git -c user.email=x -c user.name=x commit -qm brave
[ -n "${STEP:-}" ] && exit 0
for c in $L; do
  out=$(git apply --reject --whitespace=nowarn $P/$c.ng.diff 2>&1); r=$(echo "$out" | grep -c "Rejected hunk")
  files=$(echo "$out" | grep "error: patch failed\|does not exist" | sed 's/.*renderer\///; s/error: patch failed: //; s/:[0-9]*$//' | sort -u | tr '\n' ' ')
  git add -A; git -c user.email=x -c user.name=x commit -qm $c
  echo "$(cd $CR && git log -1 --format='%h' --abbrev=10 $c) rechazos=$r $files"; done
find . -name "*.rej" | sed 's#^\./##'
