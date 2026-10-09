#!/bin/bash
# Uso: portar.sh <nombre> <commit>...   (en el orden de llegada)
# Monta /tmp/claude-0/port/w-<nombre> con los ficheros de la 116 + los .patch actuales de brave-core,
# aplica los commits (sin tests) y dice los rechazos por commit.
set -u
N=$1; shift; L="$@"
CR=/home/user/chromium/chromium; BC=/home/user/brave-core; W=/tmp/claude-0/port/w-$N
cd $CR
F=$(for c in $L; do timeout 300 git show --name-only --format= $c; done | grep -v "web_tests/\|_test\.cc\|/test/\|devtools-frontend\|perftest\|perf_tests\|_unittest\|tools/metrics\|\.md$\|DEPS$\|OWNERS$" | sort -u)
echo "$F" > /tmp/claude-0/port/files-$N.txt
rm -rf "${W:?}"; mkdir -p "$W"
for f in $F; do mkdir -p "$W/$(dirname $f)"; timeout 200 git show 116.0.5845.188:$f > "$W/$f" 2>/dev/null || { rm -f "${W:?}/${f:?}"; echo "NUEVO $f"; }; done
cd "$W"; git init -q; git config gc.auto 0; git add .; git -c user.email=x -c user.name=x commit -qm raw116
for f in $F; do p=$BC/patches/$(echo $f|tr / -).patch; [ -f $p ] && { git apply $p || echo "PARCHE BRAVE NO APLICA: $f"; }; done
git add -A; git -c user.email=x -c user.name=x commit -qm brave
[ -n "${STEP:-}" ] && { for c in $L; do (cd $CR && timeout 300 git show --format= $c -- $F) > /tmp/claude-0/port/$c.diff; done; exit 0; }
for c in $L; do (cd $CR && timeout 300 git show --format= $c -- $F) > /tmp/claude-0/port/$c.diff
  out=$(git apply --reject --whitespace=nowarn /tmp/claude-0/port/$c.diff 2>&1); r=$(echo "$out" | grep -c "Rejected hunk")
  files=$(echo "$out" | grep "error: patch failed" | sed 's/.*renderer\///; s/error: patch failed: //; s/:[0-9]*$//' | sort -u | tr '\n' ' ')
  git add -A; git -c user.email=x -c user.name=x commit -qm $c
  echo "$(cd $CR && git log -1 --format='%h' --abbrev=12 $c) rechazos=$r $files"; done
find . -name "*.rej" | sed 's#^\./##'
