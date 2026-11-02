#!/bin/bash
# traer.sh <sha corto>... : resuelve el sha completo por gitiles y trae el commit con su padre al clon tree:0 (MOTOR-43).
# Imprime «<corto> <completo> <asunto>».
CH=/home/user/chromium/hist
for c in "$@"; do
  for i in 1 2 3 4; do j=$(curl -sSf "https://chromium.googlesource.com/chromium/src/+/$c?format=JSON" 2>/dev/null | tail -n +2) && [ -n "$j" ] && break; sleep 3; done
  full=$(echo "$j" | python3 -c 'import sys,json; print(json.load(sys.stdin)["commit"])' 2>/dev/null)
  [ -z "$full" ] && { echo "$c NO-RESUELTO"; continue; }
  for i in 1 2 3 4; do git -C $CH fetch -q --filter=tree:0 --depth=2 origin $full 2>/dev/null && break; sleep 3; done
  echo "$c $full $(git -C $CH log -1 --format='%ad %s' --date=short $full 2>/dev/null || echo FALLO-FETCH)"
done
