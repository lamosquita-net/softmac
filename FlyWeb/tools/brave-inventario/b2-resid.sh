#!/bin/bash
# Residuales de un directorio borrado (B2, MOTOR-31). Uso: b2-resid.sh CHECKOUT_BRAVE_CORE DIR_RELATIVO
cd "$1" || exit 1; d="$2"; b=$(basename "$d")
echo "## ruta brave/$d"
rg -n --hidden --glob '!.git/**' --glob '!android/**' --glob '!ios/**' -e "brave/$d([/\":' ]|\$)" -e "\"$d/" -e "'$d/" .
echo "## android/ios (informativo)"
rg -c -e "brave/$d([/\":' ]|\$)" android ios 2>/dev/null | wc -l
