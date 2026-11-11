#!/bin/bash
# FlyWeb instalada en la MacPro5,1, con el perfil de quien la usa: Speedometer 3.1 y JetStream 3 con Maglev de serie y
# con --js-flags=--no-maglev, 3 pasadas de cada uno (LOCAL-19, 10-11-2026; B6, condición 2). MIT, como la raíz del repo.
# Doble clic y esperar (~1-1,5 h). Solo usa lo que trae Mojave: bash, osascript, open y /usr/bin/python 2.7.
#
# - Cierra FlyWeb (como Cmd-Q) y la vuelve a abrir con «open -a», con su perfil de siempre, en una página local
#   (fw51.html) que pasa los benchmarks en un iframe y manda cada resultado a srv51.py, en 127.0.0.1.
#   No se usa CDP: Chrome 136+ no lo permite con el perfil por defecto.
# - Benchmarks: carpeta bench/ junto a este guion, o la de la carpeta de red (entregas/bench-local).
# - Resultado: resultado-51-<fecha>.txt (y un .json por caso) junto a este guion. Al acabar, FlyWeb queda cerrada.
# Variables para pruebas: FW_APP (otra app), FW_EXTRA (flags extra, p. ej. --user-data-dir=/tmp/… para no usar el
# perfil de nadie), PASADAS, BENCH_DIR, PY, PUERTO.
cd "$(dirname "$0")" || exit 1
R="$PWD/resultado-51-$(date +%Y%m%d-%H%M)"; exec > >(tee "$R.txt") 2>&1
APP=${FW_APP:-/Applications/FlyWeb.app}; BIN="$APP/Contents/MacOS/FlyWeb"; NP=${PASADAS:-3}; PUERTO=${PUERTO:-8127}
export PYTHONIOENCODING=utf-8
if [ -z "$PY" ]; then if [ -x /usr/bin/python ]; then PY=/usr/bin/python; else PY=$(command -v python3); fi; fi
fin() { echo "$*"; [ -n "$SRV" ] && kill $SRV 2>/dev/null; echo "Se puede cerrar esta ventana."; read -n1; exit 1; }
abierta() { pgrep -f "^$BIN" >/dev/null; }
# Con la sesión bloqueada Chrome no pinta y Speedometer se queda parado (visto en la 6,1).
bloqueada() { "$PY" -c "import Quartz,sys;d=Quartz.CGSessionCopyCurrentDictionary() or {};sys.exit(0 if d.get('CGSSessionScreenIsLocked') else 1)" 2>/dev/null; }
cerrar() {
  abierta || return 0
  osascript -e "tell application \"$APP\" to quit" >/dev/null 2>&1
  for i in $(seq 1 60); do abierta || return 0; sleep 1; done
  return 1
}

VER=$(defaults read "$APP/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)
BLD=$(defaults read "$APP/Contents/Info.plist" CFBundleVersion 2>/dev/null)
echo "== $(date '+%d-%m %H:%M') $(sysctl -n machdep.cpu.brand_string) · macOS $(sw_vers -productVersion) · $(sysctl -n hw.ncpu) hilos"
echo "CPU: $(sysctl -n machdep.cpu.features | tr ' ' '\n' | grep -cx AVX1.0) AVX (0 = sin AVX) · Python: $PY ($("$PY" -V 2>&1))"
[ -n "$VER" ] || fin "No encuentro FlyWeb en $APP."
echo "FlyWeb: $APP · versión $VER ($BLD) · perfil: ${FW_EXTRA:-el de $(id -un)}"
case "$VER" in 1.*|2.*|3.0.*) echo "AVISO: en la $VER Maglev va APAGADO de serie; «serie» será sin Maglev.";; esac

BENCH=""
for b in "${BENCH_DIR:-}" "$PWD/bench" "/Volumes/googledrive/clientes/software/entregas/bench-local" \
         "/Volumes/USB3 6Tb/googledrive/clientes/software/entregas/bench-local"; do
  [ -n "$b" ] && [ -f "$b/speedometer3.1/index.html" ] && [ -f "$b/jetstream3/index.html" ] && { BENCH="$b"; break; }
done
[ -n "$BENCH" ] || fin "No encuentro los benchmarks: copia la carpeta entregas/bench-local de la carpeta de red junto a este guion, con el nombre bench."
echo "Benchmarks: $BENCH"
bloqueada && fin "La pantalla está bloqueada: desbloquéala y vuelve a empezar (con la sesión bloqueada FlyWeb no pinta)."
"$PY" srv51.py $PUERTO "$BENCH" "$PWD" "$R" >/dev/null 2>&1 & SRV=$!; sleep 2
curl -s -o /dev/null -m 5 "http://127.0.0.1:$PUERTO/fw51.html" || fin "El servidor local no arranca (¿puerto $PUERTO ocupado?)."

# Con la pantalla dormida Chrome no pinta (sin requestAnimationFrame) y Speedometer no avanza: se despierta y se mantiene
# encendida mientras dure el guion.
caffeinate -u -t 5 >/dev/null 2>&1; caffeinate -d -i -w $$ >/dev/null 2>&1 &
echo "Cierro FlyWeb si está abierta (como Cmd-Q)…"
cerrar || fin "FlyWeb no se ha cerrado (¿una ventana pregunta algo?). Ciérrala y vuelve a empezar."
CP="$HOME/Library/Application Support/LaMosquita/FlyWeb/Crashpad"
MALAS=0
caso() { # caso ETIQUETA [flags]
  local E=$1; shift
  echo; echo "== $(date +%T) $E $*"
  touch "/tmp/fw51-marca-$E"; rm -f "$R-$E.json"
  open -a "$APP" --args $FW_EXTRA "$@" "http://127.0.0.1:$PUERTO/fw51.html?caso=$E&n=$NP"
  sleep 15
  local L=$(ps -axo command= | grep "^$BIN" | grep -v -- "--type=" | head -1)
  echo "  línea de órdenes: ${L#$BIN}"
  if [ $# -gt 0 ]; then echo "$L" | grep -q -- "$1" && echo "  $1: sí" || { echo "  OJO: $1 no está en la línea de órdenes (¿FlyWeb ya estaba abierta?)"; MALAS=$((MALAS+1)); }; fi
  local t=0 visto="" avisado=""
  while [ $t -lt 10800 ]; do
    if [ ! -f "$R-$E.json" ] && [ $t -ge 180 ]; then
      echo "  OJO: en 3 minutos FlyWeb no ha cargado la página local (http://127.0.0.1:$PUERTO/fw51.html)."
      echo "       ¿Un cortafuegos (LuLu, Little Snitch) la retiene? Permite la conexión de FlyWeb y vuelve a empezar."
      MALAS=$((MALAS+1)); break
    fi
    if [ -f "$R-$E.json" ]; then
      local ahora=$("$PY" -c "import json,sys;d=json.load(open(sys.argv[1]));print('%d %s' % (len(d['pasadas']), d.get('fin')))" "$R-$E.json" 2>/dev/null)
      [ "$ahora" != "$visto" ] && { visto=$ahora; "$PY" -c "import json,sys;p=json.load(open(sys.argv[1]))['pasadas'];x=p[-1];print('  %s %s: %s (%s s)%s' % (x['prueba'],x['n'],x['resultado'],x['seg'],(' en error: %s' % x['en_error']) if x.get('en_error') else ''))" "$R-$E.json" 2>/dev/null; }
      case "$ahora" in *True) break;; esac
    fi
    abierta || { echo "  FlyWeb se ha cerrado sola"; MALAS=$((MALAS+1)); break; }
    if bloqueada; then [ -z "$avisado" ] && { echo "  OJO: la pantalla está bloqueada; la medida está parada hasta que la desbloquees."; avisado=1; MALAS=$((MALAS+1)); }; fi
    sleep 20; t=$((t+20))
  done
  cerrar || { echo "  FlyWeb no se cierra: la fuerzo"; pkill -f "^$BIN"; sleep 3; }
  local D=$(find "$CP" -newer "/tmp/fw51-marca-$E" -name '*.dmp' 2>/dev/null | wc -l | tr -d ' ')
  echo "  volcados de caída: $D"; [ "$D" -gt 0 ] && MALAS=$((MALAS+1))
  rm -f "/tmp/fw51-marca-$E"
}
caso serie
caso no-maglev --js-flags=--no-maglev
kill $SRV 2>/dev/null
echo; echo "== RESUMEN (FlyWeb $VER, $BLD; medianas de $NP pasadas)"
for E in serie no-maglev; do
  "$PY" -c "
import json,sys
try: d=json.load(open(sys.argv[1]))
except Exception: print('%-10s sin resultado' % sys.argv[2]); sys.exit()
def m(n):
    x=sorted(float(p['resultado'].split()[0]) for p in d['pasadas'] if p['prueba']==n and p['resultado'])
    return x[len(x)//2] if x else None
e=sum(len(p.get('en_error') or []) for p in d['pasadas'])
print('%-10s Speedometer 3.1 = %s · JetStream 3 = %s · subpruebas con error: %d%s' % (sys.argv[2], m('Speedometer 3.1'), m('JetStream 3'), e, '' if d.get('fin') else ' · SIN ACABAR'))
if d.get('error'): print('           error de la página: %s' % d['error'][:300])
" "$R-$E.json" "$E"
done
[ $MALAS -eq 0 ] && echo "RESULTADO: sin caídas" || echo "RESULTADO: $MALAS aviso(s) o caída(s): ver arriba"
echo "Hecho. FlyWeb queda cerrada; ábrela cuando quieras. Se puede cerrar esta ventana."; read -n1
