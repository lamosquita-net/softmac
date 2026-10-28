#!/bin/bash
# v8regen.sh <ruta en V8> <fichero con el contenido nuevo>: rehace patches/v8/<ruta>.patch frente a V8_TO (por defecto 13.4.114.21). MOTOR-29.
f=$1; n=$(readlink -f $2); TO=${V8_TO:-13.4.114.21}; T=$(mktemp -d); cd $T && git init -q && mkdir -p $(dirname $f)
git -C /home/user/v8 show $TO:$f > $f 2>/dev/null && git add -A && git -c user.email=x -c user.name=x commit -qm b
cp $n $f; git add -N $f; git diff --full-index > /home/user/brave-core/patches/v8/$(echo $f | tr / -).patch; rm -rf $T; echo ok $f
