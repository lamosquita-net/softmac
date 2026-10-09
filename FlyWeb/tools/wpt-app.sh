#!/bin/zsh
# Uso: wpt-app.sh <FlyWeb.app> <lista> <salida.json>   (servidor de tests en 127.0.0.1:8117)
# Las WPT dan por hecho que la fuente Ahem está instalada en el sistema (como en las máquinas de pruebas de Chromium):
# /fonts/ahem.css pide primero local('Ahem') y muchos tests miden de forma síncrona, sin esperar a la fuente web.
# Sin ella fallan tests que en Chrome pasan (p. ej. cap/rcap de container-queries/font-relative-units-dynamic.html).
WPT=${WPT_ROOT:-$PWD}
if ! fc-list 2>/dev/null | grep -qi ahem && [ ! -f ~/Library/Fonts/Ahem.ttf ]; then
  if [ -f "$WPT/fonts/Ahem.ttf" ]; then cp "$WPT/fonts/Ahem.ttf" ~/Library/Fonts/ && echo "Ahem instalada en ~/Library/Fonts"
  else echo "Falta la fuente Ahem: copiar <raíz de wpt>/fonts/Ahem.ttf a ~/Library/Fonts (o WPT_ROOT=<raíz de wpt>)"; exit 1; fi
fi
APP=$1; T=$(mktemp -d); EXE=$(ls "$APP"/Contents/MacOS/* | head -1); PORT=9339
"$EXE" --user-data-dir=$T --use-mock-keychain --no-first-run --remote-debugging-port=$PORT about:blank >/dev/null 2>&1 &
PID=$!; for i in {1..30}; do curl -s localhost:$PORT/json >/dev/null && break; sleep 1; done
python3 ~/proyectos/softmac/herramientas/wpt-cdp.py $PORT http://127.0.0.1:8117 $2 $3
kill $PID; sleep 2; rm -rf $T
