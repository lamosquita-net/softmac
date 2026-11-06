#!/bin/zsh
# FlyWeb: prueba una compilación en la MacPro6,1 desde la máquina que compila, sin parar la compilación.
#
# Uso:   FW61=<alias-ssh> prueba-remota.sh <zip con la .app> <etiqueta> [pruebas…]
#   pruebas (por defecto «gpu motor138»): gpu, motor138, gpuinfo, o pruebas sueltas de gpu (1a, 3c, 9…).
#   Ejemplo: FW61=mac61 zsh prueba-remota.sh entregas/b1-local16/chromium-156-b1d-oficial-7.zip of7 gpu motor138
#
# Variables:
#   FW61          destino ssh de la 6,1: un alias de ~/.ssh/config o usuario@máquina (obligatorio).
#   FW61_OPCIONES opciones extra de ssh, p. ej. «-i <clave> -o IdentitiesOnly=yes».
#                 Ni FW61 ni FW61_OPCIONES se guardan en el repo: se ponen en el entorno de quien lo lanza.
#   FW_QUIEN      quién prueba, para el fichero de bloqueo /tmp/<quien>-61-en-uso (por defecto «fw»).
#   FW_PUERTO     puerto de DevTools, en la 6,1 y por el túnel (por defecto 9491).
#   FW_FLAGS      flags extra para el navegador.
#   FW_ENV        variables de entorno para el navegador («A=1 B=2»), p. ej. FLYWEB_MTL_DUMP=1.
#   FW_LLAVERO=1  prueba M1 del llavero: sin --use-mock-keychain y contando los ítems «… Safe Storage» del llavero
#                 antes y después. Con FW_PERFIL=<ruta en la 6,1> se usa una COPIA de ese perfil (el original no se toca).
#   FW_RESULTADOS carpeta local de resultados (por defecto ./resultados-61).
#
# Reglas de la 6,1 que cumple: una sesión SSH por paso y nunca dos a la vez; no lanza si hay un Chromium o FlyWeb
# abierto; perfil en /tmp; cierra lo que lanza. Espera mientras otra sesión tenga /tmp/*-61-en-uso o el puerto ocupado.
# LuLu retiene cada binario nuevo hasta que se aprueba en la 6,1: si la red no llega, se avisa y no se relanza.
set -u
[ -n "${FW61:-}" ] || { echo "Falta FW61 (alias de ~/.ssh/config de la 6,1)"; exit 2; }
ZIP=${1:?zip}; TAG=${2:?etiqueta}; shift 2; PRUEBAS=(${@:-gpu motor138})
AQUI=${0:A:h}; PUERTO=${FW_PUERTO:-9491}; QUIEN=${FW_QUIEN:-fw}; RES=${FW_RESULTADOS:-$PWD/resultados-61}
BLOQUEO=/tmp/$QUIEN-61-en-uso; OUT=$RES/$TAG.txt; CAP=$RES/$TAG-capturas
SSH=(ssh -o BatchMode=yes -o ConnectTimeout=8 -o ServerAliveInterval=60 ${=FW61_OPCIONES:-})
mkdir -p $RES; : > $OUT
log() { echo "$*" | tee -a $OUT; }

# 0. Turno: nadie más en la 6,1 y el puerto libre aquí.
while true; do
  otros=(/tmp/*-61-en-uso(N)); otros=(${otros:#$BLOQUEO})
  if (( ${#otros} )) || lsof -nP -iTCP:$PUERTO -sTCP:LISTEN >/dev/null 2>&1; then sleep 30; else break; fi
done
touch $BLOQUEO; trap 'rm -f $BLOQUEO' EXIT
log "== $TAG $(date '+%F %T') · zip $(basename $ZIP) $(stat -f %z $ZIP) B · sha256 $(shasum -a 256 $ZIP | cut -c1-16)…"

# 1. Copia del zip (una sesión).
"${SSH[@]}" $FW61 "mkdir -p ~/fw-remota && cat > ~/fw-remota/$TAG.zip" < $ZIP || { log "No se pudo copiar el zip"; exit 3; }
log "== zip copiado $(date +%T)"

# 2. Ejecución (una sesión, con el túnel de DevTools). motor-138.html viaja dentro del guion.
MOTOR=$(base64 < $AQUI/../motor-138.html | tr -d '\n')
"${SSH[@]}" -o ExitOnForwardFailure=yes -L $PUERTO:127.0.0.1:$PUERTO $FW61 'bash -s' > $RES/$TAG-ssh.log 2>&1 <<REMOTO &
if pgrep -fl "Chromium.app|FlyWeb.app" | grep -v pgrep; then echo "6,1 OCUPADA: no lanzo nada"; exit 3; fi
R=~/fw-remota; A=\$R/$TAG; rm -rf "\$A"; mkdir -p "\$A"; ditto -x -k "\$R/$TAG.zip" "\$A" && rm -f "\$R/$TAG.zip"
APP=\$(ls -d "\$A"/*.app | head -1); xattr -dr com.apple.quarantine "\$APP" 2>/dev/null; X=\$(ls "\$APP/Contents/MacOS/" | head -1)
D=\$(mktemp -d /tmp/fwr.XXXXXX); mkdir -p "\$D/web"; echo "$MOTOR" | base64 -D > "\$D/web/motor-138.html"
( cd "\$D/web" && if command -v python3 >/dev/null; then exec python3 -m http.server 9492 --bind 127.0.0.1; else exec python -m SimpleHTTPServer 9492; fi ) >/dev/null 2>&1 &
WEB=\$!
llavero() { for n in "FlyWeb Safe Storage" "Chromium Safe Storage" "Chrome Safe Storage"; do echo "\$n: \$(security dump-keychain 2>/dev/null | grep -c "\"svce\"<blob>=\"\$n\"")"; done; }
PERFIL="\$D/perfil"; MOCK=--use-mock-keychain
if [ -n "${FW_LLAVERO:-}" ]; then MOCK=; echo "--- llavero antes"; llavero; [ -n "${FW_PERFIL:-}" ] && cp -R "${FW_PERFIL:-}" "\$PERFIL"; fi
echo "app: \$APP"; touch "\$D/inicio"
env ${FW_ENV:-} "\$APP/Contents/MacOS/\$X" --disable-field-trial-config \$MOCK --no-first-run --no-default-browser-check \
  --disable-features=MediaRouter,DialMediaRouteProvider --window-size=1400,900 --window-position=0,0 --enable-logging=stderr \
  --user-data-dir="\$PERFIL" --remote-debugging-port=$PUERTO ${FW_FLAGS:-} about:blank > "\$D/err.txt" 2>&1 &
P=\$!; T0=\$(date +%s)
while kill -0 \$P 2>/dev/null && [ \$(( \$(date +%s) - T0 )) -lt 5400 ]; do sleep 3; done
kill \$P 2>/dev/null; sleep 3; kill -9 \$P 2>/dev/null; pkill -9 -f "user-data-dir=\$PERFIL" 2>/dev/null; kill \$WEB 2>/dev/null
echo "--- caídas"
echo "MTLCompilerService: \$(find ~/Library/Logs/DiagnosticReports -name 'MTLCompilerService*' -newer "\$D/inicio" | wc -l | tr -d ' ')"
echo "navegador o ayudantes: \$(find ~/Library/Logs/DiagnosticReports \( -name 'Chromium*' -o -name 'FlyWeb*' \) -newer "\$D/inicio" | wc -l | tr -d ' ')"
for p in 'GPU process exited unexpectedly' 'context lost' 'Check failed' 'FATAL' 'unrecognized selector' 'Network service crashed' 'pipeline creation failed' 'library compilation failed'; do echo "\$p: \$(grep -c "\$p" "\$D/err.txt")"; done
echo "--- errores más repetidos"; grep -E 'ERROR|FATAL' "\$D/err.txt" | sed -E 's/^\[[0-9:\/.]+//' | sort | uniq -c | sort -rn | head -10 | cut -c1-200
if [ -n "${FW_LLAVERO:-}" ]; then echo "--- llavero después"; llavero; fi
cp "\$D/err.txt" "\$R/$TAG.err"; rm -rf "\$D"; echo FIN61
REMOTO
S=$!

# 3. Pruebas por el túnel.
for i in {1..100}; do curl -s --max-time 2 http://127.0.0.1:$PUERTO/json/version | grep -q Browser && break; kill -0 $S 2>/dev/null || break; sleep 3; done
if kill -0 $S 2>/dev/null; then
  log "== DevTools $(date +%T)"
  # Red: si LuLu retiene el binario, la primera página no carga. Se avisa una vez y se sigue esperando, sin relanzar.
  for k in {1..60}; do python3 -I - $PUERTO <<'PY' && break
import json, sys, urllib.request
p = sys.argv[1]
t = json.load(urllib.request.urlopen(urllib.request.Request(f'http://127.0.0.1:{p}/json/new?https://example.com/', method='PUT'), timeout=20))
import time; time.sleep(6)
ok = any('example.com' in x.get('url', '') and 'Example' in x.get('title', '') for x in json.load(urllib.request.urlopen(f'http://127.0.0.1:{p}/json/list', timeout=10)))
urllib.request.urlopen(f'http://127.0.0.1:{p}/json/close/{t["id"]}', timeout=5).read()
sys.exit(0 if ok else 1)
PY
    (( k == 2 )) && log "AVISO: la 6,1 aún no tiene red para este binario (¿LuLu?). Hay que aprobarlo allí; sigo esperando."
    sleep 30; done
  log "== red $(date +%T)"
  python3 -I $AQUI/bateria.py $PUERTO $CAP ${PRUEBAS[@]} 2>&1 | tee -a $OUT
  python3 -I $AQUI/bateria.py $PUERTO $CAP cerrar
fi
wait $S; cat $RES/$TAG-ssh.log | cut -c1-220 >> $OUT
log "== fin $(date +%T) · resultado en $OUT"
