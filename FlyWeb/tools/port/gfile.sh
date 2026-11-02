#!/bin/bash
# gfile.sh <ref> <ruta> : fichero de Chromium en <ref> desde gitiles (caché gf/). Sale 1 si no existe (MOTOR-43).
K=/tmp/claude-0/port/gf/$1/$2
if [ ! -e "$K" ] && [ ! -e "$K.404" ]; then mkdir -p "$(dirname "$K")"
  for i in 1 2 3 4 5; do code=$(curl -sS -o "$K.t" -w '%{http_code}' "https://chromium.googlesource.com/chromium/src/+/$1/$2?format=TEXT")
    [ "$code" = 200 ] && { base64 -d "$K.t" > "$K"; rm -f "$K.t"; break; }
    [ "$code" = 404 ] && { touch "$K.404"; rm -f "$K.t"; break; }; sleep 3; done; fi
[ -e "$K" ] && cat "$K" || exit 1
