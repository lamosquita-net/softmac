#!/bin/bash
# api128.sh <base> : busca en las líneas añadidas de los .patch cambiados desde <base> las APIs que la 128 no tiene
# (api128-faltan.tsv, una por arreglo de compilación de LOCAL). Se pasa antes de entregar un nivel; cada aviso se mira
# a mano (puede ser otro método con el mismo nombre). Añadir al .tsv cada arreglo nuevo de LOCAL de este tipo.
L=$(cd "$(dirname "$0")" && pwd)/api128-faltan.tsv; cd /home/user/brave-core; n=0
while IFS=$'\t' read -r pat fix org; do
  [[ -z $pat || $pat == \#* ]] && continue
  hits=$(git diff $1 HEAD -- patches/ ':!patches/v8/' | grep -E '^\+\+[^+]' | grep -vE '^\+\+\s*//' | grep -E -- "$pat" | head -5)
  [ -n "$hits" ] && { echo "== $fix ($org)"; echo "$hits"; n=$((n+1)); }
done < "$L"; echo "$n avisos"
