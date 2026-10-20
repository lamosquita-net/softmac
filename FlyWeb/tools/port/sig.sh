#!/bin/bash
# sig.sh <área> <lista>: aplica en orden (paso.sh); en un commit con rechazos prueba m3.sh y, si la fusión a tres
# bandas no deja conflictos, hace commit «[m3]» y sigue. Se para en el primero con conflictos y los enseña. MOTOR-13.
A=$1; L=$2; P=/tmp/claude-0/port; W=$P/w-$A; nl=0
# Controles acumulados frente al commit «brave» (API de la 116), tras cada tanda de paso.sh y cada commit m3.
J=$W/third_party/blink/renderer/core/css/css_properties.json5
controles() {
  git -C $W show HEAD:third_party/blink/renderer/core/css/css_properties.json5 | grep -n 'wrapper_pointer_name: "Member"\|valid_for_permission_element' && { echo "PARADA: json5 con Member/valid_for_permission_element (116: Persistent, sin ese campo)"; exit 1; }
  (cd $W && git diff a0f41ed HEAD -U0 -- third_party/blink/renderer/core/css/properties | grep "^+" | grep -n "CSSParserTokenStream& stream\|<CSSParserTokenStream>\|, value_phase)\|CSSValuePhase value_phase") && { echo "PARADA: API de upstream (stream/value_phase) en properties/"; exit 1; }
  return 0
}
while :; do
  out=$($P/paso.sh $A $L); nl=$((nl+$(echo "$out" | grep -c '^ok ')))
  controles
  c=$(echo "$out" | sed -n 's/^== \([0-9a-f]*\) .*/\1/p'); [ -z "$c" ] && { echo "limpios: $nl; fin de la lista"; exit 0; }
  SKIP='stylable_select.css\|selectlist.css\|permission_shadow_element\|selectmenu\|about_flags\|flag_descriptions\|flag-metadata\|android_webview\|fieldtrial_testing_config'
  if echo "$out" | grep 'does not exist\|No such file' | grep -qv "$SKIP"; then echo "limpios: $nl"; echo "$out"; exit 1; fi
  m=$($P/m3.sh $A $c)
  if echo "$m" | grep -qv ': 0 conflictos'; then
    echo "limpios: $nl"; echo "$out" | head -1; echo "$m"
    cd $W; for f in $(git diff --name-only); do grep -q '^<<<<<<< area' $f 2>/dev/null || continue
      echo "##### $f"; awk '/^<<<<<<< /{p=1} p{print NR": "$0} /^>>>>>>> /{p=0}' $f; done; exit 1; fi
  $P/ok.sh $A $c m3 >/dev/null; echo "m3 $c"
  controles
  $P/fmtdelta.sh $A || { echo "PARADA: revisar formato de $c (posible bloque mal colocado)"; exit 1; }
done
