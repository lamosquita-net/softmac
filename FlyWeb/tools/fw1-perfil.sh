#!/bin/bash
# fw1-perfil.sh [perfil] : cuenta los prefijos de cifrado (v10, fw1, otros) de cookies y contraseñas de un perfil de
# FlyWeb y dice si existe el ítem `fw1` del llavero. No imprime ni la clave ni ningún valor (FM.51, fw1-migracion.md).
# El perfil se copia antes a un temporal: con FlyWeb abierto, la base de datos está bloqueada.
P=${1:-"$HOME/Library/Application Support/LaMosquita/FlyWeb/Default"}
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
cuenta() {  # <fichero> <tabla> <columna>
  [ -f "$P/$1" ] || { echo "  $1: no existe"; return; }
  cp "$P/$1" "$T/db"; [ -f "$P/$1-wal" ] && cp "$P/$1-wal" "$T/db-wal"
  echo "  $1 ($2.$3):"
  sqlite3 "$T/db" "SELECT CASE WHEN length($3)=0 THEN 'vacío'
                                 WHEN CAST(substr($3,1,3) AS TEXT) IN ('v10','fw1') THEN CAST(substr($3,1,3) AS TEXT)
                                 ELSE 'otro' END AS p, count(*) FROM $2 GROUP BY p ORDER BY p;" | sed 's/^/    /'
  rm -f "$T"/db*
}
echo "Perfil: $P"
cuenta Cookies cookies encrypted_value
cuenta "Login Data" logins password_value
for a in "FlyWeb" "FlyWeb fw1"; do
  if security find-generic-password -s "FlyWeb Safe Storage" -a "$a" >/dev/null 2>&1; then e=sí; else e=no; fi
  echo "  Llavero «FlyWeb Safe Storage» / «$a»: $e"
done
