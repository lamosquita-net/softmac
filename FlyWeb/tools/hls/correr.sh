#!/bin/bash
# Corre prueba.html sin ventana (--headless=new), un navegador nuevo y un perfil temporal por caso.
# Uso: FlyWeb/tools/hls/correr.sh <binario> <etiqueta> [carpeta-de-medios]
#   binario:  p. ej. /Applications/FlyWeb.app/Contents/MacOS/FlyWeb, o el «Google Chrome for Testing» 156.
#   etiqueta: nombre de la tanda (p. ej. flyweb-321, cft-156); sale en salida/<etiqueta>/.
#   EXTRA: banderas añadidas para el navegador (p. ej. EXTRA="--no-sandbox" en Linux como root).
# Necesita servir.py en marcha (lo arranca si no responde). No toca el perfil de nadie.
set -uo pipefail
BIN="$1"; ETQ="$2"; MED="${3:-medios}"
AQUI="$(cd "$(dirname "$0")" && pwd)"
SAL="$PWD/salida/$ETQ"; mkdir -p "$SAL"
if ! curl -s -o /dev/null http://127.0.0.1:8471/prueba.html; then
  python3 "$AQUI/servir.py" "$MED" > "$SAL/servidor.log" 2>&1 &
  SRV=$!; trap 'kill $SRV 2>/dev/null' EXIT; sleep 1
fi
CASOS=$(grep -o "^  \['[a-z0-9-]*'" "$AQUI/prueba.html" | tr -d " ['")
: > resultados.jsonl
for c in $CASOS; do
  P=$(mktemp -d)
  "$BIN" --headless=new --user-data-dir="$P" --no-first-run --no-default-browser-check \
    --use-mock-keychain --password-store=basic --autoplay-policy=no-user-gesture-required \
    --enable-logging=stderr --v=0 ${EXTRA:-} \
    --vmodule='hls*=3,manifest_demuxer*=3,multi_buffer*=2,resource_multi_buffer*=2,url_index*=2,web_media_player_impl*=1,demuxer_manager*=2' \
    "http://127.0.0.1:8471/prueba.html?caso=$c" > "$SAL/$c.log" 2>&1 &
  N=$!
  for _ in $(seq 60); do grep -q "\"caso\": \"__fin__\", \"filtro\": \"$c\"" resultados.jsonl && break; sleep 0.5; done
  kill $N 2>/dev/null; sleep 0.5; kill -9 $N 2>/dev/null; wait $N 2>/dev/null
  rm -rf "$P"
  grep "\"caso\": \"$c\"" resultados.jsonl | python3 -c 'import json,sys
for l in sys.stdin:
  r=json.loads(l); e=r.get("error") or {}
  print("%-40s %-15s %s" % (r["caso"], r["resultado"], ((str(e.get("code",""))+" "+e.get("message","")) if e else "")))' \
    || echo "$c  (sin resultado: ver $SAL/$c.log)"
  # Las causas de HLS salen en el registro como WARNING aunque no haya --vmodule.
  grep -h -o -E "(HlsDemuxerStatus|HlsDataSourceProvider|PipelineStatus|ParseStatus)::[^\[]*" "$SAL/$c.log" | sort -u | sed 's/^/    /'
done
grep -v __fin__ resultados.jsonl > "$SAL/resultados.jsonl"
echo "Resultados: $SAL/resultados.jsonl; registros por caso en $SAL/"
