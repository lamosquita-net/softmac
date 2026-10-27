#!/bin/zsh
# Pasa FlyWeb/tools/motor-N.html por una app de FlyWeb (perfil temporal) y escribe ok/FALLO por línea.
# Uso: motor-nivel.sh <FlyWeb.app> <N> [puerto]
APP=$1; N=$2; PORT=${3:-9336}
H=~/proyectos/softmac/herramientas; T=$(mktemp -d)
cp /Volumes/googledrive/clientes/software/softmac/FlyWeb/tools/motor-$N.html $T/
EXE=$(ls "$APP"/Contents/MacOS/* | head -1)
"$EXE" --user-data-dir=$T/perfil --use-mock-keychain --no-first-run --remote-debugging-port=$PORT about:blank >/dev/null 2>&1 &
PID=$!; for i in {1..30}; do curl -s localhost:$PORT/json >/dev/null && break; sleep 1; done
python3 $H/cdp.py $PORT '' nav "file://$T/motor-$N.html" >/dev/null 2>&1; sleep 4
python3 $H/cdp.py $PORT "motor-$N" eval 'navigator.userAgent.match(/Chrome\/[\d.]+/)[0]+"\n"+[...document.querySelectorAll("#res li")].map(l=>(l.className=="ok"?"ok    ":"FALLO ")+l.textContent).join("\n")' 2>&1 | tail -40
kill $PID; sleep 1; rm -rf $T
