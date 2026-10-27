#!/bin/bash
# Corre las pruebas de go-sync (paquetes command y datastore, las que tocan la base de datos) contra el almacén
# SQLite y la caché en memoria de flyweb-sync, en una copia temporal de la versión fijada en go.mod.
# Uso: pruebas/go-sync.sh   (desde FlyWeb/servidor/sync; necesita Go y red para descargar módulos)
set -euo pipefail
cd "$(dirname "$0")/.."
VERSION=$(awk '$1=="github.com/brave/go-sync"{print $2; exit}' go.mod)
SQLITE=$(awk '$1=="modernc.org/sqlite"{print $2; exit}' go.mod)
ORIGEN=$(go mod download -json "github.com/brave/go-sync@$VERSION" | sed -n 's/.*"Dir": "\(.*\)",/\1/p')
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
cp -r "$ORIGEN/." "$TMP/"
chmod -R u+w "$TMP"
for paq in command datastore; do
  for f in sqlite.go cache.go; do
    sed "s/^package main$/package ${paq}_test/" "$f" > "$TMP/$paq/zz_flyweb_${f%.go}_test.go"
  done
  sed "s/^package PAQUETE$/package ${paq}_test/" pruebas/ayudas_test.go.txt > "$TMP/$paq/zz_flyweb_ayudas_test.go"
done
# Las pruebas de datastore/ fijan el mtime a mano y comparan entidades enteras: sin el reloj creciente.
printf 'package datastore_test\n\nfunc init() { relojCreciente = false }\n' > "$TMP/datastore/zz_flyweb_sin_reloj_test.go"
python3 pruebas/adaptar.py "$TMP"/command/command_test.go "$TMP"/command/server_defined_unique_entity_test.go \
  "$TMP"/datastore/sync_entity_test.go "$TMP"/datastore/item_count_test.go
cd "$TMP"
go get "modernc.org/sqlite@$SQLITE" >/dev/null 2>&1
go test -count=1 "$@" ./command/ ./datastore/
