#!/bin/zsh
# Uso: wpt-app.sh <FlyWeb.app> <lista> <salida.json>   (servidor de tests en 127.0.0.1:8117)
APP=$1; T=$(mktemp -d); EXE=$(ls "$APP"/Contents/MacOS/* | head -1); PORT=9339
"$EXE" --user-data-dir=$T --use-mock-keychain --no-first-run --remote-debugging-port=$PORT about:blank >/dev/null 2>&1 &
PID=$!; for i in {1..30}; do curl -s localhost:$PORT/json >/dev/null && break; sleep 1; done
python3 ~/proyectos/softmac/herramientas/wpt-cdp.py $PORT http://127.0.0.1:8117 $2 $3
kill $PID; sleep 2; rm -rf $T
