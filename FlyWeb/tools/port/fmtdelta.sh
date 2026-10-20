#!/bin/bash
# fmtdelta.sh <área> [rev]: por cada .cc/.h del commit <rev> (HEAD), cuántas líneas más reindenta clang-format después
# que antes. Imprime los que suben más de UMBRAL (6) y sale con 1 si hay alguno. MOTOR-13.
A=$1; R=${2:-HEAD}; W=/tmp/claude-0/port/w-$A; cd $W; t=$(mktemp -d); bad=0
for f in $(git show --name-only --format= $R -- '*.cc' '*.h'); do
  ext=${f##*.}
  git show $R~1:"$f" > $t/o.$ext 2>/dev/null || : > $t/o.$ext
  git show $R:"$f" > $t/n.$ext 2>/dev/null || continue
  o=$(clang-format --style=Chromium $t/o.$ext | diff $t/o.$ext - | grep -c '^>')
  n=$(clang-format --style=Chromium $t/n.$ext | diff $t/n.$ext - | grep -c '^>')
  [ $((n-o)) -gt ${UMBRAL:-6} ] && { echo "FORMATO $f: $o→$n"; bad=1; }
done; rm -rf $t; exit $bad
