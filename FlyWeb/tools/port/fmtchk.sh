#!/bin/bash
# fmtchk.sh <área> [ref-base]: detecta estructura rota (llaves) en .cc/.h tocados por el área:
# compara cuántas líneas reindenta clang-format en la versión de 116 (raw116) y en la del área.
a=$1; base=${2:-brave}
cd /tmp/claude-0/port/w-$a || exit 1
b=$(git log --format=%H --grep="^$base\$" | tail -1); [ -z "$b" ] && b=$(git rev-list --max-parents=0 HEAD)
t=$(mktemp -d)
git diff --name-only $b -- '*.cc' '*.h' | while read f; do
  [ -f "$f" ] || continue
  ext=${f##*.}
  if git cat-file -e $b:"$f" 2>/dev/null; then git show $b:"$f" > $t/o.$ext; else : > $t/o.$ext; fi
  cp "$f" $t/n.$ext
  o=$(clang-format --style=Chromium $t/o.$ext | diff $t/o.$ext - | grep -c '^>')
  n=$(clang-format --style=Chromium $t/n.$ext | diff $t/n.$ext - | grep -c '^>')
  d=$((n-o)); [ $d -gt ${UMBRAL:-8} ] && echo "$d	$o→$n	$f"
done | sort -rn
rm -rf $t
