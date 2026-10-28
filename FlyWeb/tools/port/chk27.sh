#!/bin/bash
# chk27.sh <desde> <hasta> <cabeza>: por cada commit de bc y cada .patch que cambia, mira si su cambio sigue en <cabeza>. MOTOR-28.
cd /home/user/brave-core; CR=/tmp/claude-0/port/cr128; H=/home/user/chromium/hist; T=/tmp/claude-0/port/chk27; rm -rf $T; mkdir -p $T
mk(){ d=$T/$3; rm -rf $d; mkdir -p $d; f=$(git show $1:$2 2>/dev/null | sed -n '1s#^diff --git a/\([^ ]*\) .*#\1#p'); [ -z "$f" ] && f=$4
  mkdir -p $d/$(dirname $f); if [ -f $CR/$f ]; then cp $CR/$f $d/$f; else git -C $H show 128.0.6613.138:$f > $d/$f 2>/dev/null || : > $d/$f; fi
  git show $1:$2 > $T/$3.p 2>/dev/null && [ -s $T/$3.p ] && patch -s -p1 -d $d < $T/$3.p >/dev/null 2>&1; echo $f; }
for c in $(git rev-list --reverse $1..$2); do for p in $(git diff --name-only $c~1 $c -- patches/ | grep -v '^patches/v8/\|json5'); do
  f=$(mk $c $p b); mk $c~1 $p a $f >/dev/null; mk $3 $p h $f >/dev/null
  (cd $T && diff -u a/$f b/$f > d.diff); [ -s $T/d.diff ] || continue
  (cd $T/h && patch -R --dry-run -s -p1 < ../d.diff >/dev/null 2>&1) || echo "REVISAR $(git log -1 --format=%h $c) $p"; done; done; echo FIN
