#!/bin/bash
# g128.sh <fichero> [tag]: contenido de un fichero de Chromium en la 128 (cr128 o Gitiles) a stdout; falla si no existe. MOTOR-32.
f=$1; t=${2:-128.0.6613.138}; CR=/tmp/claude-0/port/cr128
[ "$t" = 128.0.6613.138 ] && [ -e $CR/$f ] && { cat $CR/$f; exit 0; }
for i in 1 2 3; do o=$(curl -s -w '%{http_code}' -o /tmp/claude-0/port/.g128 "https://chromium.googlesource.com/chromium/src/+/refs/tags/$t/$f?format=TEXT")
  [ "$o" = 200 ] && { base64 -d /tmp/claude-0/port/.g128; exit 0; }; [ "$o" = 404 ] && exit 1; sleep 3; done; exit 1
