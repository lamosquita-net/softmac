#!/bin/bash
# Uso: next.sh <área> <lista>  Lista, en orden, los commits de <lista> (uno por línea; vale la columna 1 de un .tsv)
# que aún no están en el log de w-<área> (cada commit del área lleva el hash de upstream como primera palabra; los
# saltados, un commit vacío «<hash> SKIPPED: motivo»). El primero es el siguiente que hay que aplicar con ap.sh.
W=/tmp/claude-0/port/w-$1; L=$2
hechos=$(git -C $W log --format=%s | awk '{print $1}')
grep -v '^#' "$L" | cut -f1 | while read c; do [ -n "$c" ] && ! echo "$hechos" | grep -qx "$c" && echo $c; done
