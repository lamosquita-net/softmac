#!/bin/bash
# rediff.sh <commit>...: vuelve a escribir <commit>.ng.diff con el ngtraducir.py y el ngmap.json actuales (como
# portarng.sh, sin montar área). MOTOR-13.
CR=/home/user/chromium/chromium; P=/tmp/claude-0/port
EXCL="web_tests/\|_test\.cc\|browsertest\|/test/\|devtools-frontend\|perftest\|perf_tests\|_unittest\|tools/metrics\|\.md$\|DEPS$\|OWNERS$\|TestExpectations\|VirtualTestSuites"
for c in "$@"; do
  F=$(cd $CR && git show --name-only --format= $c | grep -v "$EXCL")
  [ -z "$F" ] && { : > $P/$c.ng.diff; continue; }
  (cd $CR && git show --format= $c -- $F) | python3 $P/ngtraducir.py $P/ngmap.json > $P/$c.ng.diff 2>/dev/null
done
