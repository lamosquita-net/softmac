#!/bin/bash
# Overrides que no han llegado al binario (MOTOR-41, 07-11-2026). En la 7,1,
# tras compilar: un .cc/.mm de chromium_src que se añade cuando el .o del
# original ya existe no hace recompilar nada (ninja no sabe de él) y la build
# sale en verde con el original de Chromium. Lo delata `ninja -t deps`: el
# original aparece como dependencia de algún .o y el override no.
# Uso: check-overrides-o.sh <out dir> [<brave-core>]   (p. ej. src/out/Release, src/brave)
# Salida: <override>\tSIN_COMPILAR → borra ese .o (o el out entero) y recompila.
OUT=${1:?out dir}; BC=${2:-$OUT/../../brave}
D=$(mktemp); ninja -C "$OUT" -t deps > "$D" || exit 1
cd "$BC" || exit 1
find chromium_src -name '*.cc' -o -name '*.mm' | while read -r o; do
  rel=${o#chromium_src/}
  grep -q "^ *\.\./\.\./$rel\$" "$D" || continue          # el original no se compila aquí
  grep -q "brave/chromium_src/$rel\$" "$D" || echo -e "$o\tSIN_COMPILAR"
done
rm -f "$D"
