#!/bin/bash
# Uso: addfilesng.sh <área> <commit>...  Como addfiles.sh, pero con la traducción de LayoutNG (ngtraducir.py): escribe
# <commit>.ng.diff y añade al área los ficheros de la 116 (+ parche de Brave) que esos diffs tocan y aún no estén.
# Después se aplica cada diff con `git apply --reject` (ap.sh) y se resuelven los rechazos commit a commit.
set -u
W=/tmp/claude-0/port/w-$1; shift; CR=/home/user/chromium/chromium; BC=/home/user/brave-core; P=/tmp/claude-0/port
EXCL="web_tests/\|_test\.cc\|browsertest\|/test/\|devtools-frontend\|perftest\|perf_tests\|_unittest\|tools/metrics\|\.md$\|DEPS$\|OWNERS$\|TestExpectations\|VirtualTestSuites"
for c in "$@"; do
  F=$(cd $CR && timeout 300 git show --name-only --format= $c | grep -v "$EXCL")
  [ -z "$F" ] && { : > $P/$c.ng.diff; continue; }
  (cd $CR && timeout 300 git show --format= $c -- $F) | python3 $P/ngtraducir.py $P/ngmap.json > $P/$c.ng.diff
done
F=$(for c in "$@"; do sed -n 's#^+++ b/##p; s#^--- a/##p' $P/$c.ng.diff; done | grep -v '^/dev/null' | sort -u)
cd $W; n=0
for f in $F; do [ -e "$f" ] && continue; mkdir -p "$(dirname $f)"
  (cd $CR && timeout 200 git show 116.0.5845.188:$f) > "$f" 2>/dev/null || { rm -f "$f"; echo "NUEVO $f"; continue; }
  p=$BC/patches/$(echo $f|tr / -).patch; [ -f $p ] && { git apply $p || echo "PARCHE BRAVE NO APLICA: $f"; }; n=$((n+1)); done
git add -A; git -c user.email=x -c user.name=x commit -qm "add files: $*" && echo "añadidos $n"
