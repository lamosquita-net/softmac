#!/bin/bash
# pres.sh <commit>...: ¿está ya en FlyWeb? git apply --check (inverso y directo) sobre fw/ (128 + parches) de los
# ficheros no-test del commit. rev=0 → ya está; fwd=0 → aplica limpio (MOTOR-36).
P=/tmp/claude-0/port; for c in "$@"; do [ -s $P/diffs/$c.diff ] || $P/gd.sh $c >/dev/null
F=$(sed -n 's#^diff --git a/\([^ ]*\) b/.*#\1#p' $P/diffs/$c.diff | grep -v "web_tests\|_test\.cc\|/test/\|_unittest\|\.md$\|OWNERS\|tools/metrics"); [ -z "$F" ] && { echo "$c solo-tests"; continue; }
rm -rf $P/fw; $P/fwf.sh $F >/dev/null 2>&1; inc=$(for f in $F; do echo -n "--include=$f "; done)
r=$(cd $P/fw && git apply --check -R $inc $P/diffs/$c.diff 2>&1 | grep -c "error: patch failed\|does not exist"); f=$(cd $P/fw && git apply --check $inc $P/diffs/$c.diff 2>&1 | grep -c "error: patch failed\|does not exist"); echo "$c rev=$r fwd=$f"; done
