#!/bin/bash
# chk128.sh <base> : comprueba que los .patch cambiados desde <base> aplican sobre la 128 (cr128 o la historia).
cd /home/user/brave-core; CR=/tmp/claude-0/port/cr128; CH=/home/user/chromium; n=0; bad=0
for p in $(git diff --name-only --diff-filter=AM $1 HEAD -- patches/ | grep '\.patch$' | grep -v '^patches/v8/'); do
  n=$((n+1)); f=$(sed -n '1s#^diff --git a/\([^ ]*\) .*#\1#p' $p); T=$(mktemp -d); mkdir -p $T/$(dirname $f)
  if [ -e $CR/$f ]; then cp $CR/$f $T/$f; else git -C $CH show 128.0.6613.138:$f > $T/$f 2>/dev/null || rm -f $T/$f; fi
  (cd $T && git init -q && git apply --check $OLDPWD/$p 2>/dev/null) || { echo "NO APLICA: $p"; bad=$((bad+1)); }; rm -rf $T
done; echo "$n parches, $bad problemas"
