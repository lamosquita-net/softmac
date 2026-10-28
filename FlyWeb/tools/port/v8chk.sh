#!/bin/bash
# v8chk.sh [rev]: git apply --check de cada patches/v8/*.patch sobre V8 <rev> (13.4.114.21). MOTOR-29.
TO=${1:-13.4.114.21}; n=0; bad=0
for p in /home/user/brave-core/patches/v8/*.patch; do n=$((n+1)); f=$(grep -m1 '^+++ b/' $p | sed 's#^+++ b/##'); T=$(mktemp -d)
  (cd $T && git init -q && mkdir -p $(dirname $f) && { git -C /home/user/v8 show $TO:$f > $f 2>/dev/null || rm -f $f; } && git apply --check $p 2>/dev/null) || { echo "NO APLICA $(basename $p)"; bad=$((bad+1)); }; rm -rf $T; done
echo "$n parches, $bad problemas"
