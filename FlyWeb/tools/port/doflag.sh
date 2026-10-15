#!/bin/bash
# doflag.sh <área> "<Flag[:status]> ..." <mensaje>: pone en el área el json5 de flags actual de brave-core (syncf.sh),
# añade las flags (status por defecto: stable) y llama a commitarea.sh. MOTOR-10.
set -e
A=$1; FLAGS=$2; MSG=$3; P=/tmp/claude-0/port; J=third_party/blink/renderer/platform/runtime_enabled_features.json5
cd $P/w-$A; [ -z "$(find . -name '*.rej')" ] || { echo "QUEDAN .rej"; exit 1; }
if [ -n "$FLAGS" ]; then $P/syncf.sh $A $J; for f in $FLAGS; do n=${f%%:*}; s=${f#*:}; [ "$s" = "$f" ] && s=stable
  python3 $P/addflag.py $J $n $s; done; fi
exec $P/commitarea.sh $A "$MSG"
