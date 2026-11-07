#!/bin/bash
# Overrides muertos en chromium_src (MOTOR-41, 07-11-2026): un fichero de
# chromium_src que hace `#define X ...` y luego `#include "src/<ruta>"` no hace
# nada si X ya no sale en el original de Chromium 156 ni en el parche de ese
# fichero. Ni el compilador ni el P2 lo ven (así se perdió el DNS seguro apagado
# de la 3.0.0: stub_resolver_config_reader.cc → default_dns_over_https_config_source.cc).
# Uso: check-overrides-156.sh [<brave-core>] (por defecto /home/user/brave-core).
# Salida: <override>\t<macro>\tMUERTO (0 apariciones en el original y en el parche).
# Ojo: una macro puede apuntar a una cabecera que incluye el original; lo que
# salga se revisa a mano antes de tocar nada.
BC=${1:-/home/user/brave-core}; CR=$(dirname "$0")/b2-cr156
# Guarda fija: el valor por defecto del DNS seguro (FlyWeb: apagado).
f=$(bash "$CR" chrome/browser/net/default_dns_over_https_config_source.cc) || exit 1
n=$(grep -c 'ModeToString(' "$f")
[ "$n" = 1 ] || echo -e "chromium_src/chrome/browser/net/default_dns_over_https_config_source.cc\tModeToString\tLLAMADAS=$n (se espera 1)"
check1() {
  BC=$1; CR=$2; o=$3; rel=${o#chromium_src/}
  for src in $(grep -oE '#include "src/[^"]+"' "$BC/$o" | sed 's/#include "src\///; s/"$//'); do
    orig=$(bash "$CR" "$src" 2>/dev/null) || { echo -e "$o\t$src\tNO_EXISTE_EN_156"; continue; }
    pat="$BC/patches/$(echo "$src" | tr / -).patch"
    for m in $(grep -E '^\s*#\s*define\s+[A-Za-z_][A-Za-z0-9_]*' "$BC/$o" | sed -E 's/^\s*#\s*define\s+([A-Za-z_][A-Za-z0-9_]*).*/\1/' | sort -u); do
      case "$m" in *_H_|*_H) continue;; esac
      t=$m
      case "$m" in
        BUILDFLAG_INTERNAL_*) t=${m#BUILDFLAG_INTERNAL_};;  # BUILDFLAG(X) en el original
        *_OLD) grep -qE "define\s+$m\s+${m%_OLD}\b" "$BC/$o" && t=${m%_OLD};;  # alias del valor de antes
      esac
      c=$(grep -cw -- "$t" "$orig")
      [ -f "$pat" ] && c=$((c + $(grep -E '^\+' "$pat" | grep -cw -- "$t")))
      [ "$c" = 0 ] && echo -e "$o\t$m\tMUERTO"
    done
  done
}
export -f check1
cd "$BC" && grep -rlE '#include "src/' chromium_src --include='*.cc' --include='*.h' --include='*.mm' | xargs -P 16 -I{} bash -c 'check1 "$0" "$1" "$2"' "$BC" "$(realpath "$CR")" {} | sort
