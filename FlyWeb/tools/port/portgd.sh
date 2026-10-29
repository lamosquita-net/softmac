#!/bin/bash
# portgd.sh <área> <commit>...: portar128.sh sin historia local (diffs de Gitiles con gd.sh, ficheros de cr128 o Gitiles).
# STEP=1 solo monta; luego ap1gd.sh/ok1.sh paso a paso. MOTOR-32.
set -u
N=$1; shift; L="$@"; P=/tmp/claude-0/port; BC=/home/user/brave-core; W=/tmp/claude-0/port/w-$N
EXC='web_tests/\|_test\.cc\|_test\.mm\|browsertest\|/test/\|devtools-frontend\|perftest\|perf_tests\|_unittest\|tools/metrics\|\.md$\|DEPS$\|OWNERS$\|^AUTHORS$\|/data/\|_test_\|test_util\|/testing/'
for c in $L; do [ -s $P/diffs/$c.diff ] || $P/gd.sh $c >/dev/null; done
F=$(for c in $L; do sed -n 's#^diff --git a/\([^ ]*\) b/\(.*\)#\1\n\2#p' $P/diffs/$c.diff; done | grep -v "$EXC" | sort -u)
echo "$F" > $P/files-$N.txt
[ -d /tmp/claude-0/port/w-$N ] && rm -rf /tmp/claude-0/port/w-$N; mkdir -p "$W"
cd "$W"
for f in $F; do mkdir -p "$(dirname $f)"; $P/g128.sh $f > "$f" 2>/dev/null || { rm -f "./$f"; echo "NUEVO $f"; }; done
git init -q; git config gc.auto 0; git add .; git -c user.email=x -c user.name=x commit -qm raw128
for f in $F; do p=$BC/patches/$(echo $f|tr / -).patch; [ -f $p ] && { git apply $p || echo "PARCHE BC NO APLICA: $f"; }; done
git add -A; git -c user.email=x -c user.name=x commit -qm bc
[ -n "${STEP:-}" ] && exit 0
for c in $L; do $P/ap1gd.sh $N $c; git add -A; git -c user.email=x -c user.name=x commit -qm $c; done
