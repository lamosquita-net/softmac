#!/bin/bash
# Uso: addfiles.sh <área> <commit>...  → añade al área los ficheros de los commits que falten (116 + parche de Brave)
set -u
W=/tmp/claude-0/port/w-$1; shift; CR=/home/user/chromium/chromium; BC=/home/user/brave-core
F=$(cd $CR && for c in "$@"; do git show --name-only --format= $c; done | grep -v "web_tests/\|_test\.cc\|browsertest\|/test/\|perftest\|_unittest\|tools/metrics\|\.md$\|DEPS$\|OWNERS$" | sort -u)
cd $W; n=0
for f in $F; do [ -e "$f" ] && continue; mkdir -p "$(dirname $f)"
  (cd $CR && git show 116.0.5845.188:$f) > "$f" 2>/dev/null || { rm -f "$f"; echo "NUEVO $f"; continue; }
  p=$BC/patches/$(echo $f|tr / -).patch; [ -f $p ] && { git apply $p || echo "PARCHE BRAVE NO APLICA: $f"; }; n=$((n+1)); done
git add -A; git -c user.email=x -c user.name=x commit -qm "add files: $*" && echo "añadidos $n"
for c in "$@"; do (cd $CR && git show --format= $c -- $F) > /tmp/claude-0/port/$c.diff; done
