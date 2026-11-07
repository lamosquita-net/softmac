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
# Guarda fija 2: en la 156, base_feature_status "disabled" (parche del json5)
# no apaga una feature de Blink "stable": el generador solo copia el estado del
# base::Feature si cuenta como overridden, es decir, si está también en
# OVERRIDE_FEATURE_DEFAULT_STATES de chromium_src/third_party/blink/common/features.cc.
JP="$BC/patches/third_party-blink-renderer-platform-runtime_enabled_features.json5.patch"
OV="$BC/chromium_src/third_party/blink/common/features.cc"
if [ -f "$JP" ]; then
  j=$(bash "$CR" third_party/blink/renderer/platform/runtime_enabled_features.json5) || exit 1
  grep -B3 '^+.*base_feature_status: "disabled"' "$JP" | grep -o 'name: "[A-Za-z0-9]*"' | cut -d'"' -f2 | sort -u | while read -r n; do
    e=$(awk -v n="\"$n\"" '$0 ~ "name: "n"," {p=1} p {printf "%s ", $0} p && /^    },?$/ {exit}' "$j")
    echo "$e" | grep -qE 'status: "stable"|"Mac": "stable"' || continue
    bf=$(echo "$e" | grep -o 'base_feature: "[A-Za-z0-9]*"' | cut -d'"' -f2); bf=${bf:-$n}
    # base_feature "none" en el original: el parche le pone uno; míralo en el parche.
    [ "$bf" = none ] && bf=$(grep -A3 "name: \"$n\"" "$JP" | grep -o '^+ *base_feature: "[A-Za-z0-9]*"' | cut -d'"' -f2)
    grep -qw "k$bf" "$OV" || echo -e "patches/…runtime_enabled_features.json5.patch\t$n\tSTABLE_SIN_OVERRIDE (añade k${bf:-?} a OVERRIDE_FEATURE_DEFAULT_STATES)"
  done
fi
check1() {
  BC=$1; CR=$2; o=$3; rel=${o#chromium_src/}
  for src in $(grep -oE '#include "src/[^"]+"' "$BC/$o" | sed 's/#include "src\///; s/"$//'); do
    orig=$(bash "$CR" "$src" 2>/dev/null) || { echo -e "$o\t$src\tNO_EXISTE_EN_156"; continue; }
    pat="$BC/patches/$(echo "$src" | tr / -).patch"
    for m in $(grep -E '^\s*#\s*define\s+[A-Za-z_][A-Za-z0-9_]*' "$BC/$o" | sed -E 's/^\s*#\s*define\s+([A-Za-z_][A-Za-z0-9_]*).*/\1/' | sort -u); do
      case "$m" in *_H_|*_H) continue;; esac
      # Marca vacía (#define X, para un #if defined(X)) o pieza de otra macro
      # del propio override (usada dentro de otro #define): no apunta al original.
      ov=$(sed -e :a -e '/\\$/N; s/\\\n//; ta' "$BC/$o")
      echo "$ov" | grep -qE "^\s*#\s*define\s+$m\s*$" && continue
      echo "$ov" | grep -E '^\s*#\s*define\b' | grep -vE "^\s*#\s*define\s+$m\b" | grep -qw -- "$m" && continue
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
