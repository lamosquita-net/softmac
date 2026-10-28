#!/bin/bash
# jdiff.sh [<rev>] : diff a nivel de Chromium del runtime_enabled_features.json5 entre <rev>~1 y <rev> (por defecto HEAD).
R=${1:-HEAD}; J=third_party/blink/renderer/platform/runtime_enabled_features.json5; D=$(mktemp -d)
cat /tmp/claude-0/port/cr128/$J > $D/base
for r in "$R~1" "$R"; do n=$(echo $r | tr '~' '_'); cp $D/base $D/$n; (cd /home/user/brave-core && git show $r:patches/third_party-blink-renderer-platform-runtime_enabled_features.json5.patch) | sed "s#a/$J#a/x#; s#b/$J#b/x#" > $D/p; (cd $D && patch -s -o $n.out base < p && mv $n.out $n); done
diff $D/$(echo "$R~1" | tr '~' '_') $D/$R; rm -rf "${D:?}"
