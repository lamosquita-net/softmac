#!/bin/bash
# v8edit.sh <patch> <script.py>: aplica el parche de patches/v8 a la V8 13.6, ejecuta el script python sobre el fichero y rehace el parche. MOTOR-35.
P=/home/user/brave-core/patches/v8/$1; f=$(grep -m1 "^+++ b/" $P | sed 's#^+++ b/##'); G=$(mktemp -d)
cd $G && git init -q && mkdir -p $(dirname $f) && git -C /home/user/v8 show 5297e56d:$f > $f && git add -A && git -c user.email=x -c user.name=x commit -qm b && git apply $P && python3 $2 $f && git diff --full-index > $P && echo "rehecho $1"; rm -rf $G
