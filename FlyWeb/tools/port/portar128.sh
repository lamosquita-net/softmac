#!/bin/bash
# portar128.sh <nombre> <commit>... : como portar.sh, sobre la base 128 (MOTOR-15, Fase 3 clase D). Monta w-<nombre> con
# los ficheros de 128.0.6613.138 (cr128; si faltan, de la historia) + los .patch de la rama actual de brave-core, aplica
# los commits (sin tests) y da los rechazos por commit. Con STEP=1 solo monta.
set -u
N=$1; shift; L="$@"
CH=/home/user/chromium/hist; CR=/tmp/claude-0/port/cr128; T=128.0.6613.138; BC=/home/user/brave-core; W=/tmp/claude-0/port/w-$N
dif() { case $1 in fw:*) /tmp/claude-0/port/fwdiff.sh ${1#fw:} ;; *) git -C $CH show --format= $1 -- $F ;; esac; }
F=$(for c in $L; do case $c in fw:*) /tmp/claude-0/port/fwdiff.sh ${c#fw:} | sed -n 's#^+++ b/##p' ;; *) git -C $CH show --name-only --format= $c ;; esac; done | grep -v "web_tests/\|_test\.cc\|_test\.mm\|browsertest\|/test/\|devtools-frontend\|perftest\|perf_tests\|_unittest\|tools/metrics\|\.md$\|DEPS$\|OWNERS$\|^AUTHORS$\|/data/" | sort -u)
echo "$F" > /tmp/claude-0/port/files-$N.txt
rm -rf "${W:?}"; mkdir -p "$W"
for f in $F; do mkdir -p "$W/$(dirname $f)"
  if [ -e "$CR/$f" ]; then cp "$CR/$f" "$W/$f"; else git -C $CH show $T:$f > "$W/$f" 2>/dev/null || { rm -f "${W:?}/${f:?}"; echo "NUEVO $f"; }; fi; done
cd "$W"; git init -q; git config gc.auto 0; git add .; git -c user.email=x -c user.name=x commit -qm raw128
for f in $F; do p=$BC/patches/$(echo $f|tr / -).patch; [ -f $p ] && { git apply $p || echo "PARCHE BC NO APLICA: $f"; }; done
git add -A; git -c user.email=x -c user.name=x commit -qm bc
[ -n "${STEP:-}" ] && exit 0
for c in $L; do dif $c > /tmp/claude-0/port/$c.diff
  out=$(git apply --reject --whitespace=nowarn /tmp/claude-0/port/$c.diff 2>&1); r=$(echo "$out" | grep -c "Rejected hunk")
  files=$(echo "$out" | grep "error: patch failed" | sed 's/.*renderer\///; s/error: patch failed: //; s/:[0-9]*$//' | sort -u | tr '\n' ' ')
  for x in $(find . -name "*.rej"); do mv $x $x.${c#fw:}; done
  git add -A; git -c user.email=x -c user.name=x commit -qm $c
  echo "$c rechazos=$r $files"; done
find . -name "*.rej*" | sed 's#^\./##'
