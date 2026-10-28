#!/bin/bash
# p133.sh <área> <mensaje> <commit>... : portar128 + (si no hay .rej) generar128 + commit en brave-core. MOTOR-27.
A=$1; M=$2; shift 2; P=/tmp/claude-0/port
$P/portar128.sh $A "$@" | grep -v '^NUEVO'
if find $P/w-$A -name '*.rej*' | grep -q .; then echo "== QUEDAN .rej en w-$A"; exit 1; fi
$P/fin133.sh $A "$M"
