#!/bin/sh
# Pruebas de backupdrive-sync.sh (bisync 1.67 configurado para «nunca perder nada») con un remoto local de rclone
# (dos carpetas), sin Drive. Uso: BACKUPDRIVE_BIN=/ruta/a/rclone tests/test-sync-safe.sh   (en CI, el rclone de Linux)
# Cubre: primera sincronización, borrado deliberado en cada lado (borrado blando), editar en un lado, editar en los
# dos, el caso de la 5,1 (fichero viejo con fecha nueva), carpeta vacía/desmontada, freno de borrados, estado
# perdido y caducidad de versiones.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SYNC="$HERE/../scripts/backupdrive-sync.sh"
BACKUPDRIVE_BIN=${BACKUPDRIVE_BIN:?define BACKUPDRIVE_BIN con el binario de rclone}
export BACKUPDRIVE_BIN

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
MAC="$T/mac"; DRIVE="$T/drive"; VD="$T/drive (versiones)"; VM_ROOT="$T/app/versions"
export BACKUPDRIVE_DIR="$T/app" BACKUPDRIVE_LOG_DIR="$T/logs" BACKUPDRIVE_NOTIFY=0 HOME="$T/home"
mkdir -p "$MAC" "$DRIVE" "$BACKUPDRIVE_DIR" "$HOME"
printf '[fake]\ntype = local\n' > "$BACKUPDRIVE_DIR/backupdrive.conf"
printf '%s\n' "$MAC|fake:$DRIVE|90|20|5" > "$BACKUPDRIVE_DIR/profiles"
printf -- '- .DS_Store\n' > "$BACKUPDRIVE_DIR/filters.txt"

n=0; fails=0
ok()   { n=$((n + 1)); echo "ok   $n $*"; }
fail() { n=$((n + 1)); fails=$((fails + 1)); echo "FAIL $n $*"; }
has()  { [ -e "$1" ] && ok "existe $2" || fail "falta $2"; }
hasnt(){ [ ! -e "$1" ] && ok "no existe $2" || fail "sobra $2"; }
content() { [ "$(cat "$1" 2>/dev/null)" = "$2" ] && ok "$3" || fail "$3 (hay: $(cat "$1" 2>/dev/null))"; }
count() { find "$1" -type f 2>/dev/null | wc -l | tr -d ' '; }
run() { sleep 1; sh "$SYNC" "$@" >"$T/out" 2>&1 || true; }
result() { sed -n 's/.*"result":"\([a-z-]*\)","exit".*/\1/p' "$BACKUPDRIVE_DIR/status.json" | head -1; }
# versión guardada: carpeta, subruta sin extensión, extensión
version_of() { for f in "$1"/"$2"-[0-9]*"$3"; do [ -f "$f" ] && cat "$f" && return; done; }
vm() { ls -d "$VM_ROOT"/*/ 2>/dev/null | head -1; }

# --- 1. Sin primera sincronización no se toca nada ---
i=1; while [ $i -le 30 ]; do echo "f$i" > "$MAC/f$i.txt"; i=$((i + 1)); done
echo base > "$MAC/doc.docx"; echo junk > "$MAC/.DS_Store"; echo d > "$DRIVE/d.txt"
touch -d 2026-01-01 "$MAC"/* "$DRIVE/d.txt"
run
hasnt "$DRIVE/f1.txt" "f1.txt en Drive antes de la primera sincronización"
[ "$(result)" = needs-resync ] && ok "perfil en needs-resync" || fail "perfil en needs-resync ($(result))"

# --- 2. Primera sincronización: simulación y real ---
run --resync --dry-run
hasnt "$DRIVE/f1.txt" "f1.txt tras la simulación"
run
hasnt "$DRIVE/f1.txt" "la simulación no marca el perfil como iniciado"
run --resync
has "$DRIVE/f1.txt" "f1.txt subido"; has "$MAC/d.txt" "d.txt bajado"; hasnt "$DRIVE/.DS_Store" ".DS_Store filtrado"
[ "$(result)" = ok ] && ok "resultado ok" || fail "resultado ok ($(result))"
hasnt "$DRIVE/doc.docx (versiones)" "sin carpeta de versiones dentro de Drive"
run
[ "$(result)" = ok ] && ok "segunda pasada sin cambios: ok" || fail "segunda pasada ($(result))"
[ "$(count "$VD")" = 0 ] && [ "$(count "$VM_ROOT")" = 0 ] && ok "sin cambios no se crean versiones" || fail "se crearon versiones sin cambios"

# --- 3. Borrado deliberado: borrado blando en el otro lado, y no vuelve ---
rm "$MAC/f1.txt"; rm "$DRIVE/f2.txt"
run; run
hasnt "$DRIVE/f1.txt" "f1.txt borrado en el Mac se quita de Drive"
[ "$(version_of "$VD" f1 .txt)" = f1 ] && ok "copia de Drive de f1.txt en versiones (borrado blando)" || fail "copia de f1.txt en versiones de Drive"
hasnt "$MAC/f1.txt" "f1.txt no vuelve al Mac"
hasnt "$MAC/f2.txt" "f2.txt borrado en Drive se quita del Mac"
[ "$(version_of "$(vm)" f2 .txt)" = f2 ] && ok "copia del Mac de f2.txt en versiones (borrado blando)" || fail "copia de f2.txt en versiones del Mac"
hasnt "$DRIVE/f2.txt" "f2.txt no vuelve a Drive"

# --- 4. Editar en un lado: se copia y la versión anterior se guarda ---
echo c-mac > "$MAC/doc.docx"; touch -d 2026-04-01 "$MAC/doc.docx"
run
content "$DRIVE/doc.docx" c-mac "edición del Mac sube a Drive"
[ "$(version_of "$VD" doc .docx)" = base ] && ok "versión anterior en Drive conserva la extensión" || fail "versión anterior en Drive"
echo f3-drive > "$DRIVE/f3.txt"; touch -d 2026-05-01 "$DRIVE/f3.txt"
run
content "$MAC/f3.txt" f3-drive "edición de Drive baja al Mac"
[ "$(version_of "$(vm)" f3 .txt)" = f3 ] && ok "versión anterior en el Mac" || fail "versión anterior en el Mac"

# --- 5. Editar en los dos lados: se conservan los dos, en los dos lados ---
echo x-mac > "$MAC/f4.txt"; touch -d 2026-06-01 "$MAC/f4.txt"
echo x-drive > "$DRIVE/f4.txt"; touch -d 2026-06-02 "$DRIVE/f4.txt"
run
all_mac=$(cat "$MAC"/f4* | sort | tr '\n' ' '); all_drive=$(cat "$DRIVE"/f4* | sort | tr '\n' ' ')
[ "$all_mac" = "x-drive x-mac " ] && ok "conflicto: el Mac conserva las dos versiones" || fail "conflicto en el Mac ($all_mac)"
[ "$all_drive" = "x-drive x-mac " ] && ok "conflicto: Drive conserva las dos versiones" || fail "conflicto en Drive ($all_drive)"

# --- 6. Caso de la 5,1: copia vieja con fecha nueva ---
# a) el Mac cambió también (la fecha de Drive es posterior pero no manda): conflicto, se conservan los dos
echo good-mac > "$MAC/f5.txt"; touch -d 2026-07-01 "$MAC/f5.txt"
echo old-stale > "$DRIVE/f5.txt"; touch -d 2030-01-01 "$DRIVE/f5.txt"
run
all=$(cat "$MAC"/f5* | sort | tr '\n' ' ')
[ "$all" = "good-mac old-stale " ] && ok "5,1 con cambio en los dos: ninguno se pierde, no gana la fecha" || fail "5,1 conflicto ($all)"
# b) el Mac no cambió: la de Drive baja, pero la buena del Mac queda en versiones (recuperable)
echo stale > "$DRIVE/f6.txt"; touch -d 2030-01-01 "$DRIVE/f6.txt"
run
content "$MAC/f6.txt" stale "5,1 sin cambio en el Mac: baja la de Drive"
[ "$(version_of "$(vm)" f6 .txt)" = f6 ] && ok "5,1: la versión buena del Mac queda recuperable" || fail "5,1: versión del Mac"

# --- 7. Carpeta vacía o desmontada: no se toca nada ---
before=$(count "$DRIVE")
mv "$MAC" "$T/mac-off"; mkdir "$MAC"
run
[ "$(count "$DRIVE")" = "$before" ] && ok "Mac vacío: Drive intacto" || fail "Mac vacío: Drive cambió ($before -> $(count "$DRIVE"))"
[ "$(result)" != ok ] && ok "Mac vacío: la pasada falla" || fail "Mac vacío: la pasada no falló"
rmdir "$MAC"; mv "$T/mac-off" "$MAC"
run
[ "$(result)" = ok ] && ok "al volver la carpeta, se reanuda" || fail "al volver la carpeta ($(result))"

# --- 8. Freno de borrados masivos ---
before=$(count "$DRIVE")
i=10; while [ $i -le 17 ]; do rm "$MAC/f$i.txt"; i=$((i + 1)); done
run
[ "$(result)" = blocked ] && ok "freno: resultado blocked" || fail "freno ($(result))"
[ "$(count "$DRIVE")" = "$before" ] && ok "freno: Drive intacto" || fail "freno: Drive cambió"
run --dry-run
[ "$(result)" = ok ] && ok "--dry-run enseña el plan sin que lo corte el freno" || fail "--dry-run con borrados masivos ($(result))"
[ "$(count "$DRIVE")" = "$before" ] && ok "--dry-run no cambia Drive" || fail "--dry-run cambió Drive"
run --force
[ "$(result)" = ok ] && ok "con --force sigue" || fail "con --force ($(result))"
hasnt "$DRIVE/f10.txt" "con --force el borrado llega a Drive"
[ "$(version_of "$VD" f10 .txt)" = f10 ] && ok "y su copia queda en versiones" || fail "copia de f10.txt en versiones"

# --- 9. Estado perdido: la pasada siguiente solo copia, nunca borra ---
find "$BACKUPDRIVE_DIR/bisync" -type f -delete
rm "$MAC/f20.txt"; echo nuevo > "$MAC/nuevo.txt"; echo r > "$DRIVE/solo-drive.txt"
before=$(count "$DRIVE")
run
[ "$(result)" = ok ] && ok "estado perdido: se recupera solo" || fail "estado perdido ($(result))"
has "$DRIVE/nuevo.txt" "estado perdido: lo nuevo del Mac sube"; has "$MAC/solo-drive.txt" "estado perdido: lo nuevo de Drive baja"
has "$DRIVE/f20.txt" "estado perdido: f20.txt (borrado en el Mac) NO se borra en Drive"
[ "$(count "$DRIVE")" -ge "$before" ] && ok "estado perdido: Drive no pierde ficheros" || fail "estado perdido: Drive perdió ficheros"

# --- 9b. Modificaciones masivas (cifrado): el 50 % de un lado cambia de contenido ---
run
k=0
for f in "$MAC"/*.txt; do
  [ $((k % 2)) -eq 0 ] && echo "CIFRADO-$k" > "$f"
  k=$((k + 1))
done
run
[ "$(result)" = blocked ] && ok "cifrado del 50 %: resultado blocked" || fail "cifrado del 50 % ($(result))"
grep -rl CIFRADO "$DRIVE" >/dev/null 2>&1 && fail "cifrado: Drive recibió ficheros cifrados" || ok "cifrado: Drive intacto"
grep -rl CIFRADO "$VD" >/dev/null 2>&1 && fail "cifrado: se movieron versiones" || ok "cifrado: ninguna versión movida"
run --profile "$MAC" --force
[ "$(result)" = ok ] && ok "con --force sigue" || fail "cifrado con --force ($(result))"
grep -rl CIFRADO "$DRIVE" >/dev/null 2>&1 && ok "con --force sube" || fail "con --force no sube"
# el contenido bueno quedó en versiones de Drive
good=$(grep -rL CIFRADO "$VD" 2>/dev/null | grep -c 'f[0-9]*-[0-9]' || true)
[ "$good" -ge 1 ] && ok "los originales quedan en versiones" || fail "originales en versiones"

# --- 10. Caducidad: por la fecha del nombre, y solo dentro de las versiones ---
MV=$(vm); mkdir -p "$VD/dir"
touch -d 2020-01-01 "$VD/dir/viejo-20200101-000000.txt" "$MV/viejo-20200101-000000.txt"
recent=$(date +%Y%m%d)
echo r > "$VD/dir/reciente-$recent-000000.txt"; touch -d 2020-01-01 "$VD/dir/reciente-$recent-000000.txt"
echo s > "$VD/sin-fecha.txt"
echo k > "$DRIVE/viejo-20200101-000000.txt"
run
hasnt "$VD/dir/viejo-20200101-000000.txt" "versión vieja caducada en Drive"
hasnt "$MV/viejo-20200101-000000.txt" "versión vieja caducada en el Mac"
has "$VD/dir/reciente-$recent-000000.txt" "versión reciente (con fichero antiguo) se conserva"
has "$VD/sin-fecha.txt" "fichero sin fecha en el nombre no se toca"
[ "$(result)" = ok ] || fail "tras caducar ($(result))"
# el fichero normal con nombre parecido viaja al Mac como cualquier otro y no se borra
has "$DRIVE/viejo-20200101-000000.txt" "fichero normal con nombre parecido no se toca"

[ -n "${KEEP_LOG:-}" ] && cp "$BACKUPDRIVE_LOG_DIR/backupdrive.log" "$KEEP_LOG"
echo "$((n - fails))/$n correctas"
[ "$fails" -eq 0 ]
