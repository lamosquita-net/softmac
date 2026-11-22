#!/bin/bash
# Corre prueba.html sin ventana (--headless=new), un navegador nuevo y un perfil temporal por caso.
# Uso: FlyWeb/tools/hls/correr.sh <binario> <etiqueta> [carpeta-de-medios]
#   binario:  p. ej. /Applications/FlyWeb.app/Contents/MacOS/FlyWeb, o el «Google Chrome for Testing» 156.
#   etiqueta: nombre de la tanda (p. ej. flyweb-321, cft-156); sale en salida/<etiqueta>/.
#   PASADAS_APPLE: pasadas de cada caso apple-* (por defecto 8). bipbop_4x3 es intermitente también en Chrome 156 sin
#     parches (LOCAL-23, 22-11), así que esos casos se juzgan por el recuento, nunca por una sola pasada. Los locales, 1.
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
 n=1; case "$c" in apple-*) n="${PASADAS_APPLE:-8}";; esac
 for i in $(seq "$n"); do
  L="$c"; SUF=""; [ "$n" -gt 1 ] && { L="$c.$i"; SUF=" #$i"; }
  mkdir -p "$SAL/perfiles"; P=$(mktemp -d "$SAL/perfiles/$L.XXXXXX")
  "$BIN" --headless=new --user-data-dir="$P" --no-first-run --no-default-browser-check \
    --use-mock-keychain --password-store=basic --autoplay-policy=no-user-gesture-required \
    --enable-logging=stderr --v=0 ${EXTRA:-} \
    --disable-brave-update --disable-component-update --disable-background-networking \
    --host-resolver-rules="MAP lamosquita.net ~NOTFOUND,MAP *.lamosquita.net ~NOTFOUND" \
    --vmodule='hls*=3,manifest_demuxer*=3,multi_buffer*=2,resource_multi_buffer*=2,url_index*=2,web_media_player_impl*=1,demuxer_manager*=2' \
    "http://127.0.0.1:8471/prueba.html?caso=$c" > "$SAL/$L.log" 2>&1 &
  N=$!
  for _ in $(seq 60); do [ "$(grep -c "\"caso\": \"__fin__\", \"filtro\": \"$c\"" resultados.jsonl)" -ge "$i" ] && break; sleep 0.5; done
  kill $N 2>/dev/null; sleep 0.5; kill -9 $N 2>/dev/null; wait $N 2>/dev/null
  grep "\"caso\": \"$c\"" resultados.jsonl | tail -n +"$i" | head -1 | SUF="$SUF" python3 -c 'import json,os,sys
for l in sys.stdin:
  r=json.loads(l); e=r.get("error") or {}
  print("%-40s %-15s %s" % (r["caso"]+os.environ["SUF"], r["resultado"], ((str(e.get("code",""))+" "+e.get("message","")) if e else "")))' \
    || echo "$L  (sin resultado: ver $SAL/$L.log)"
  # Las causas de HLS salen en el registro como WARNING aunque no haya --vmodule.
  grep -h -o -E "(HlsDemuxerStatus|HlsDataSourceProvider|PipelineStatus|ParseStatus)::[^\[]*" "$SAL/$L.log" | sort -u | sed 's/^/    /'
 done
done
grep -v __fin__ resultados.jsonl > "$SAL/resultados.jsonl"
python3 - "$SAL/resultados.jsonl" <<'PY'
import collections, json, sys
n = collections.Counter(); ok = collections.Counter()
for l in open(sys.argv[1]):
    r = json.loads(l); n[r["caso"]] += 1; ok[r["caso"]] += r["resultado"] == "reproduce"
print("Recuento (reproduce / pasadas):")
for c in n:
    print("  %-40s %d/%d" % (c, ok[c], n[c]))
PY
echo "Resultados: $SAL/resultados.jsonl; registros por caso en $SAL/"
