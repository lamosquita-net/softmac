#!/bin/sh
# Pruebas del modo seguro de backupdrive-sync.sh con un remoto local de rclone (dos carpetas), sin Drive.
# Uso: BACKUPDRIVE_BIN=/ruta/a/rclone tests/test-sync-safe.sh      (en CI, el rclone compilado para Linux)
# Cubre: primera sincronización, borrar en cada lado, editar en un lado, editar en los dos, caducidad.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SYNC="$HERE/../scripts/backupdrive-sync.sh"
BACKUPDRIVE_BIN=${BACKUPDRIVE_BIN:?define BACKUPDRIVE_BIN con el binario de rclone}
export BACKUPDRIVE_BIN

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
MAC="$T/mac"; DRIVE="$T/drive"
export BACKUPDRIVE_DIR="$T/app" BACKUPDRIVE_LOG_DIR="$T/logs" BACKUPDRIVE_NOTIFY=0 HOME="$T/home"
mkdir -p "$MAC" "$DRIVE" "$BACKUPDRIVE_DIR" "$HOME"
printf '[fake]\ntype = local\n' > "$BACKUPDRIVE_DIR/backupdrive.conf"
PROFILE="$MAC|fake:$DRIVE|90"
printf '%s\n' "$PROFILE" > "$BACKUPDRIVE_DIR/profiles"
printf -- '- .DS_Store\n' > "$BACKUPDRIVE_DIR/filters.txt"

fails=0; n=0
ok()   { n=$((n + 1)); echo "ok   $n $*"; }
fail() { n=$((n + 1)); fails=$((fails + 1)); echo "FAIL $n $*"; }
has()  { [ -e "$1" ] && ok "existe $2" || fail "falta $2"; }
hasnt(){ [ ! -e "$1" ] && ok "no existe $2" || fail "sobra $2"; }
content() { [ "$(cat "$1" 2>/dev/null)" = "$2" ] && ok "$3" || fail "$3 (hay: $(cat "$1" 2>/dev/null))"; }
run() { sleep 1; sh "$SYNC" "$@" >"$T/out" 2>&1 || true; }
result() { sed -n 's/.*"result":"\([a-z-]*\)","exit".*/\1/p' "$BACKUPDRIVE_DIR/status.json" | head -1; }
VM=$(ls -d "$T"/app/versions 2>/dev/null)
vdrive="$DRIVE/.backupdrive-versions"

# --- 1. Sin primera sincronización no se toca nada ---
echo a > "$MAC/a.txt"; mkdir -p "$MAC/dir"; echo c > "$MAC/dir/c.docx"; echo junk > "$MAC/.DS_Store"
echo d > "$DRIVE/d.txt"
touch -d 2026-01-01 "$MAC/a.txt" "$MAC/dir/c.docx" "$DRIVE/d.txt"
run
hasnt "$DRIVE/a.txt" "a.txt en Drive antes de la primera sincronización"
[ "$(sed -n 's/.*"result":"\(needs-resync\)".*/\1/p' "$BACKUPDRIVE_DIR/status.json" | head -1)" = needs-resync ] \
  && ok "perfil en needs-resync" || fail "perfil en needs-resync"

# --- 2. Primera sincronización: simulación y real ---
run --resync --dry-run
hasnt "$DRIVE/a.txt" "a.txt tras la simulación"
run
hasnt "$DRIVE/a.txt" "a.txt: la simulación no marca el perfil como iniciado"
run --resync
has "$DRIVE/a.txt" "a.txt subido"; has "$DRIVE/dir/c.docx" "dir/c.docx subido"; has "$MAC/d.txt" "d.txt bajado"
hasnt "$DRIVE/.DS_Store" ".DS_Store filtrado"
hasnt "$MAC/.backupdrive-versions" "carpeta de versiones fuera del Mac"
[ "$(result)" = ok ] && ok "resultado ok" || fail "resultado ok ($(result))"

# --- 3. Borrar en un lado no borra en el otro, y no vuelve ---
rm "$MAC/a.txt"; rm "$DRIVE/d.txt"
run; run
has "$DRIVE/a.txt" "a.txt sigue en Drive tras borrarlo en el Mac"
hasnt "$MAC/a.txt" "a.txt no vuelve al Mac"
has "$MAC/d.txt" "d.txt sigue en el Mac tras borrarlo en Drive"
hasnt "$DRIVE/d.txt" "d.txt no vuelve a Drive"

# --- 4. Si el otro lado cambia, el fichero vuelve ---
echo a2 > "$DRIVE/a.txt"; touch -d 2026-03-01 "$DRIVE/a.txt"
run
content "$MAC/a.txt" a2 "a.txt borrado en el Mac vuelve si cambia en Drive"

# --- 5. Editar en un lado: gana el más reciente y la versión anterior se guarda ---
echo c-mac > "$MAC/dir/c.docx"; touch -d 2026-04-01 "$MAC/dir/c.docx"
run
content "$DRIVE/dir/c.docx" c-mac "edición del Mac sube a Drive"
set -- "$vdrive"/dir/c-*.docx
[ -f "$1" ] && [ "$(cat "$1")" = c ] && ok "versión anterior en Drive (conserva la extensión)" || fail "versión anterior en Drive"
echo c-drive > "$DRIVE/dir/c.docx"; touch -d 2026-05-01 "$DRIVE/dir/c.docx"
run
content "$MAC/dir/c.docx" c-drive "edición de Drive baja al Mac"
set -- "$T"/app/versions/*/dir/c-*.docx
[ -f "$1" ] && [ "$(cat "$1")" = c-mac ] && ok "versión anterior en el Mac" || fail "versión anterior en el Mac"

# --- 6. Editar en los dos lados: se conservan los dos ---
echo base > "$MAC/x.txt"; touch -d 2026-01-01 "$MAC/x.txt"
run
echo x-mac > "$MAC/x.txt"; touch -d 2026-06-01 "$MAC/x.txt"
echo x-drive > "$DRIVE/x.txt"; touch -d 2026-06-02 "$DRIVE/x.txt"
run
content "$MAC/x.txt" x-drive "conflicto: x.txt es la versión de Drive"
set -- "$MAC"/x\ \(conflicto\ Mac\ *\).txt
[ -f "$1" ] && [ "$(cat "$1")" = x-mac ] && ok "conflicto: la del Mac se conserva renombrada" || fail "conflicto: la del Mac se conserva"
set -- "$DRIVE"/x\ \(conflicto\ Mac\ *\).txt
[ -f "$1" ] && [ "$(cat "$1")" = x-mac ] && ok "conflicto: la renombrada también está en Drive" || fail "conflicto en Drive"

# --- 7. Caducidad: por la fecha del nombre, no por la del fichero; solo dentro de las versiones ---
mkdir -p "$vdrive/dir" "$T"/app/versions/p
MV=$(ls -d "$T"/app/versions/*/ | grep -v '/p/$' | head -1)
touch -d 2020-01-01 "$vdrive/dir/viejo-20200101-000000.txt" "$MV/viejo-20200101-000000.txt"
recent=$(date +%Y%m%d)
echo r > "$vdrive/dir/reciente-$recent-000000.txt"; touch -d 2020-01-01 "$vdrive/dir/reciente-$recent-000000.txt"
echo s > "$vdrive/sin-fecha.txt"
echo k > "$DRIVE/viejo-20200101-000000.txt"   # fuera de versiones: nunca se toca
run
hasnt "$vdrive/dir/viejo-20200101-000000.txt" "versión vieja caducada en Drive"
hasnt "$MV/viejo-20200101-000000.txt" "versión vieja caducada en el Mac"
has "$vdrive/dir/reciente-$recent-000000.txt" "versión reciente (con fichero antiguo) se conserva"
has "$vdrive/sin-fecha.txt" "fichero sin fecha en el nombre no se toca"
has "$DRIVE/viejo-20200101-000000.txt" "fichero normal con nombre parecido no se toca"

# --- 8. Nada se perdió: ninguna pasada borró contenido ---
grep -q . "$BACKUPDRIVE_LOG_DIR/backupdrive.log" && ok "hay registro" || fail "hay registro"
# Lo único que rclone borra son versiones caducadas (nunca ficheros de los dos lados)
bad=$(grep -i ': Deleted' "$BACKUPDRIVE_LOG_DIR/backupdrive.log" | grep -v 'viejo-20200101-000000' || true)
[ -z "$bad" ] && ok "el registro solo muestra borradas las versiones caducadas" || fail "borrado inesperado: $bad"

echo "$((n - fails))/$n correctas"
[ "$fails" -eq 0 ]
