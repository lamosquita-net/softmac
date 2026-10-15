#!/bin/zsh
# Uso: apagados.sh <exe> <salida> <puerto>   Los cuatro apagados que se escaparon (FM.20) en un perfil temporal limpio.
EXE=$1; OUT=$2; PORT=$3; D=${0:A:h}; T=$(mktemp -d)
"$EXE" --user-data-dir=$T --use-mock-keychain --no-first-run --no-default-browser-check --enable-logging=stderr --remote-debugging-port=$PORT about:blank >$OUT.app.log 2>&1 &
PID=$!; for i in {1..60}; do curl -s 127.0.0.1:$PORT/json >/dev/null && break; sleep 1; done
SH='(a)=>{const d=new DOMParser().parseFromString(`<div id=h><template ${a}="open"><p>x</p></template></div>`,"text/html",{includeShadowRoots:true});const h=d.getElementById("h");return !!(h&&h.shadowRoot)}'
python3 -I $D/evalua.py $PORT http://127.0.0.1:8117/css/css-ruby/block-ruby-003.html \
  'isSecureContext' 'typeof openDatabase' 'typeof HTMLVideoElement.prototype.webkitEnterFullscreen' \
  'typeof HTMLVideoElement.prototype.webkitRequestFullscreen' 'typeof HTMLVideoElement.prototype.webkitSupportsFullscreen' \
  "CSS.supports('selector(:--x)')" "CSS.supports('selector(:state(x))')" \
  "($SH)('shadowroot')" "($SH)('shadowrootmode')" 'typeof Document.parseHTMLUnsafe' > $OUT.txt 2>&1
echo "Check failed: $(grep -c "Check failed" $OUT.app.log)  señales: $(grep -c "Received signal" $OUT.app.log)" >> $OUT.txt
kill $PID; sleep 3; kill -9 $PID 2>/dev/null; rm -rf $T
