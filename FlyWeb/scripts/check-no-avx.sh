#!/bin/sh
# Comprueba que el build de FlyWeb no exige AVX (la MacPro5,1, Westmere, no lo tiene).
#
# Chromium SIEMPRE contiene código AVX/AVX2 (Skia, libyuv, BoringSSL…) que se elige en tiempo de ejecución
# según la CPU, así que buscar instrucciones AVX en el binario no sirve. Lo peligroso es un flag GLOBAL
# (-mavx, -march=haswell, target-cpu=native…) que haga que TODO el código las use. Este script revisa los
# comandos de compilación:
#   - FALLA si aparece -march=native / -mtune=native / target-cpu=native en cualquier comando.
#   - FALLA si más del umbral (5 %) de los comandos de C/C++/ObjC o de Rust llevan flags AVX
#     (indicio de flag global en lugar de ficheros concretos con selección en tiempo de ejecución).
#   - Lista los directorios que usan flags AVX, para revisarlos a mano.
# No sustituye a la prueba de arranque en la 5,1: es una alarma temprana.
#
# Uso: check-no-avx.sh [out_dir] [target]   (por defecto: ~/proyectos/flyweb-build/brave-browser/src/out/Release brave)
set -eu

OUT="${1:-$HOME/proyectos/flyweb-build/brave-browser/src/out/Release}"
TARGET="${2:-brave}"
THRESHOLD_PCT="${AVX_THRESHOLD_PCT:-5}"
AVX_RE='(-mavx[0-9a-z]*|-mfma|-mbmi2?|-march=(haswell|skylake[a-z-]*|icelake[a-z-]*|cascadelake|x86-64-v[34]|native)|target-feature=[^ ]*\+avx|target-cpu=(haswell|skylake|native|x86-64-v[34]))'
NATIVE_RE='(-march=native|-mtune=native|target-cpu=native)'

command -v ninja >/dev/null || { echo "Falta ninja en el PATH (depot_tools)" >&2; exit 2; }
[ -f "$OUT/build.ninja" ] || { echo "No existe $OUT/build.ninja (¿se ha configurado el build?)" >&2; exit 2; }

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
ninja -C "$OUT" -t commands "$TARGET" > "$tmp/all"

grep -E '(clang\+\+|clang) ' "$tmp/all" | grep -E ' -c ' > "$tmp/cc" || true
grep -E '(^| |/)rustc( |$)|rustc_wrapper' "$tmp/all" > "$tmp/rs" || true

status=0
if grep -qE "$NATIVE_RE" "$tmp/all"; then
  echo "FALLO: flags *native* en el build (el binario dependería de la CPU de la MacPro7,1):"
  grep -oE "$NATIVE_RE" "$tmp/all" | sort | uniq -c
  status=1
fi

check_share() {
  kind=$1; file=$2
  total=$(wc -l < "$file" | tr -d ' ')
  [ "$total" -gt 0 ] || { echo "$kind: 0 comandos (¿target correcto?)"; return; }
  avx=$(grep -cE "$AVX_RE" "$file" || true)
  pct=$(( avx * 100 / total ))
  echo "$kind: $avx de $total comandos con flags AVX (${pct} %)"
  if [ "$pct" -gt "$THRESHOLD_PCT" ]; then
    echo "FALLO: $kind supera el ${THRESHOLD_PCT} %: parece un flag global."
    status=1
  fi
}
check_share "C/C++/ObjC" "$tmp/cc"
check_share "Rust" "$tmp/rs"

echo "Directorios con flags AVX (esperado: código SIMD con selección en tiempo de ejecución):"
grep -E "$AVX_RE" "$tmp/cc" | grep -oE ' -c [^ ]+' | sed 's/ -c //; s#^\.\./\.\./##' \
  | xargs -n1 dirname 2>/dev/null | sort | uniq -c | sort -rn | head -25

[ "$status" -eq 0 ] && echo "OK: no hay indicios de AVX obligatorio." || true
exit "$status"
