#!/bin/zsh
# Uso: [FEATURES=…] superficie.sh <exe> <salida.txt> <puerto>   Pasada de FlyWeb/tools/superficie.html (copia en web/,
# servida en 127.0.0.1:8125) con perfil temporal limpio; guarda el volcado del textarea.
EXE=$1; OUT=$2; PORT=$3; D=${0:A:h}; T=$(mktemp -d)
"$EXE" --user-data-dir=$T --use-mock-keychain --no-first-run --no-default-browser-check --enable-logging=stderr ${=FEATURES} --remote-debugging-port=$PORT about:blank >$OUT.app.log 2>&1 &
PID=$!; for i in {1..60}; do curl -s 127.0.0.1:$PORT/json >/dev/null && break; sleep 1; done
python3 -I $D/evalua.py $PORT http://127.0.0.1:8125/superficie.html 'navigator.userAgent' 'document.getElementById("out").value' > $OUT.raw 2>&1
python3 -I -c "
import sys,ast
t=open(sys.argv[1]).read().split('\n')
l=[x for x in t if x.startswith('document.getElementById')][0]
print(ast.literal_eval(l.split('  =>  ',1)[1]), end='')" $OUT.raw > $OUT
echo "$(wc -l < $OUT) líneas; Check failed: $(grep -c 'Check failed' $OUT.app.log)"
kill $PID; sleep 3; kill -9 $PID 2>/dev/null; rm -rf $T
