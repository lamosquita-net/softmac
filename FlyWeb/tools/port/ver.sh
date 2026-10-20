#!/bin/bash
# ver.sh <ruta>: el fichero como queda en brave-core HEAD (116 + su parche, si lo tiene). MOTOR-13.
f=$1; p=/home/user/brave-core/patches/$(echo $f|tr / -).patch; T=$(mktemp -d); mkdir -p $T/$(dirname $f)
cp /home/user/cr116/$f $T/$f 2>/dev/null || (cd /home/user/chromium/chromium && git show 116.0.5845.188:$f > $T/$f)
[ -f $p ] && (cd $T && git apply $p); cat $T/$f; rm -rf $T
