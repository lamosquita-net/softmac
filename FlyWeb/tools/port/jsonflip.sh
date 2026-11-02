#!/bin/bash
# jsonflip.sh <Nombre> <status> [...] : cambia flags en el parche de runtime_enabled_features.json5 de brave-core (MOTOR-42).
set -e
F=third_party/blink/renderer/platform/runtime_enabled_features.json5; P=/home/user/brave-core/patches/third_party-blink-renderer-platform-runtime_enabled_features.json5.patch
T=$(mktemp -d); cd $T; git init -q; mkdir -p $(dirname $F); /tmp/claude-0/port/g128.sh $F > $F; git add .; git -c user.email=x -c user.name=x commit -qm b
git apply $P
while [ $# -ge 2 ]; do python3 /tmp/claude-0/port/setflag.py $F $1 $2 >/dev/null; shift 2; done
git diff --full-index > $P; cd /; rm -rf $T
