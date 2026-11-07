#!/bin/sh
# Pruebas de backupdrive-ctl.sh con un remoto local de rclone (sin Google). Uso:
#   BACKUPDRIVE_BIN=/ruta/a/rclone tests/test-ctl.sh   (en CI, el rclone de Linux)
# Cubre: conectar (con un remoto local en lugar de Drive), comprobar, carpetas, perfiles (alta con validación, cambio,
# baja, conservando comentarios), el bloqueo compartido con la sincronización, versiones (lista y restaurar sin perder
# nada) y el plan de una simulación.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
CTL="$HERE/../scripts/backupdrive-ctl.sh"
SYNC="$HERE/../scripts/backupdrive-sync.sh"
BACKUPDRIVE_BIN=${BACKUPDRIVE_BIN:?define BACKUPDRIVE_BIN con el binario de rclone}
export BACKUPDRIVE_BIN

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
APP="$T/app"; MAC="$T/mac"; DRIVE="$T/drive"
export BACKUPDRIVE_DIR="$APP" BACKUPDRIVE_LOG_DIR="$T/logs" BACKUPDRIVE_NOTIFY=0 HOME="$T/home"
mkdir -p "$MAC" "$DRIVE" "$HOME" "$T/otra"

n=0; fails=0
ok()   { n=$((n + 1)); echo "ok   $n $*"; }
fail() { n=$((n + 1)); fails=$((fails + 1)); echo "FAIL $n $*"; }
ctl()  { sh "$CTL" "$@" >"$T/out" 2>"$T/err"; }
code() { ctl "$@"; echo $?; }
# expect código descripción orden...
expect() { c=$1; d=$2; shift 2; r=$(code "$@"); [ "$r" = "$c" ] && ok "$d" || fail "$d (código $r: $(cat "$T/err"))"; }
out_has() { grep -qF -- "$1" "$T/out" && ok "$2" || fail "$2 (salida: $(cat "$T/out"))"; }
sync_() { sleep 1; sh "$SYNC" "$@" >"$T/sync.out" 2>&1 || true; }

# --- Conectar: sin cuenta, con clave incompleta, y con un remoto local en lugar de Drive ---
expect 6 "check sin cuenta conectada" check
expect 6 "sin clave propia" connect
expect 6 "ID de cliente con otro formato" connect --client-id solo-id
expect 6 "clave propia sin secreto" connect --client-id 123-abc.apps.googleusercontent.com </dev/null
BACKUPDRIVE_CONNECT_TYPE=local BACKUPDRIVE_CLIENT_SECRET=s expect 0 "connect crea la cuenta" connect --client-id 123-abc.apps.googleusercontent.com
out_has '"ok":true' "connect comprueba la cuenta"
grep -q '^\[gdrive\]' "$APP/backupdrive.conf" && ok "remoto gdrive en backupdrive.conf" || fail "remoto gdrive en backupdrive.conf"
grep -qx 'client_secret = s' "$APP/backupdrive.conf" && ok "el secreto queda en backupdrive.conf" || fail "falta el secreto en backupdrive.conf"
# El secreto no debe ir en los argumentos de rclone (se ven con ps), sino por su variable de entorno.
{
  echo '#!/bin/sh'
  echo 'case " $* " in *" config create "*) echo "$*" > "$ARGV_LOG"; env | grep "^RCLONE_CONFIG_GDRIVE_CLIENT_SECRET=" > "$ENV_LOG" ;; esac'
  echo 'exec "$REAL_BIN" "$@"'
} > "$T/rclone-mira"
chmod +x "$T/rclone-mira"
ARGV_LOG="$T/argv" ENV_LOG="$T/env" REAL_BIN="$BACKUPDRIVE_BIN" BACKUPDRIVE_BIN="$T/rclone-mira" \
  BACKUPDRIVE_CONNECT_TYPE=local BACKUPDRIVE_CLIENT_SECRET=SECRETO-X expect 0 "connect con otro secreto" \
  connect --client-id 123-abc.apps.googleusercontent.com
grep -q SECRETO-X "$T/argv" && fail "el secreto va en los argumentos de rclone: $(cat "$T/argv")" || ok "el secreto no va en los argumentos de rclone"
grep -qx 'RCLONE_CONFIG_GDRIVE_CLIENT_SECRET=SECRETO-X' "$T/env" && ok "rclone recibe el secreto por el entorno" || fail "rclone no recibe el secreto por el entorno"
[ "$(grep -c '^client_secret = ' "$APP/backupdrive.conf")" = 1 ] && grep -qx 'client_secret = SECRETO-X' "$APP/backupdrive.conf" \
  && ok "al volver a conectar, un solo secreto, el nuevo" || fail "secretos en backupdrive.conf: $(grep -c '^client_secret' "$APP/backupdrive.conf")"
expect 0 "check" check
expect 6 "check de una cuenta que no existe" check --name otra
cp "$APP/backupdrive.conf" "$T/conf.antes"
BACKUPDRIVE_CONNECT_TYPE=no-existe expect 1 "autorización fallida" connect --shared
cmp -s "$APP/backupdrive.conf" "$T/conf.antes" && ok "si la autorización falla, la cuenta anterior sigue" || fail "conf cambiado tras un fallo: $(cat "$APP/backupdrive.conf")"
# Cancelar mientras espera la autorización: un rclone falso que se queda esperando, como el de verdad.
{
  echo '#!/bin/sh'
  echo 'case " $* " in *" config create "*) echo "[gdrive]" >> "$BACKUPDRIVE_DIR/backupdrive.conf"; echo $$ > "$ESPERA_PID"; exec sleep 60 ;; esac'
  echo 'exec "$REAL_BIN" "$@"'
} > "$T/rclone-espera"
chmod +x "$T/rclone-espera"
ESPERA_PID="$T/espera.pid" REAL_BIN="$BACKUPDRIVE_BIN" BACKUPDRIVE_BIN="$T/rclone-espera" \
  sh "$CTL" connect --shared >/dev/null 2>&1 &
cpid=$!
i=0; while [ ! -s "$T/espera.pid" ] && [ $i -lt 50 ]; do sleep 0.1; i=$((i + 1)); done
kill -TERM "$cpid"; wait "$cpid"; crc=$?
[ "$crc" = 130 ] && ok "cancelar connect sale con 130" || fail "cancelar connect sale con $crc"
sleep 0.2
kill -0 "$(cat "$T/espera.pid")" 2>/dev/null && fail "rclone sigue esperando tras cancelar" || ok "cancelar para también a rclone"
cmp -s "$APP/backupdrive.conf" "$T/conf.antes" && ok "al cancelar, la cuenta anterior sigue" || fail "conf cambiado al cancelar"
[ -d "$APP/run.lock" ] && fail "el bloqueo no se suelta al cancelar" || ok "el bloqueo se suelta al cancelar"
# Para el resto, la cuenta «fake» apunta a la carpeta de pruebas.
printf '[fake]\ntype = local\n' >> "$APP/backupdrive.conf"

# --- Carpetas de Drive ---
mkdir -p "$DRIVE/Clientes" "$DRIVE/Fotos"
expect 0 "folders" folders "fake:$DRIVE"
out_has '"Name":"Clientes"' "folders lista Clientes"
expect 0 "mkdir" mkdir "fake:$DRIVE/Nueva"
[ -d "$DRIVE/Nueva" ] && ok "carpeta creada en Drive" || fail "carpeta creada en Drive"
expect 6 "folders sin cuenta en la ruta" folders "$DRIVE"

# --- Perfiles: validación ---
printf '# comentario de Titín\n' > "$APP/profiles"
expect 6 "ruta relativa" profile add mac "fake:$DRIVE/Clientes"
expect 6 "carpeta que no existe" profile add "$T/nada" "fake:$DRIVE/Clientes"
expect 6 "raíz de Drive" profile add "$MAC" "fake:"
expect 6 "carácter |" profile add "$MAC" "fake:$DRIVE/a|b"
expect 6 "carpeta de versiones de Drive" profile add "$MAC" "fake:$DRIVE/Clientes (versiones)"
expect 6 "carpeta de usuario entera" profile add "$HOME" "fake:$DRIVE/Clientes"
mkdir -p "$APP/versions/x"
expect 6 "carpeta de BackupDrive" profile add "$APP/versions/x" "fake:$DRIVE/Clientes"
expect 6 "porcentaje fuera de rango" profile add "$MAC" "fake:$DRIVE/Clientes" --pct 150
expect 0 "alta de un perfil" profile add "$MAC/" "fake:$DRIVE/Clientes" --days 30
grep -qx "$MAC|fake:$DRIVE/Clientes|30" "$APP/profiles" && ok "línea del perfil (sin barra final, con días)" || fail "línea del perfil: $(cat "$APP/profiles")"
grep -qx '# comentario de Titín' "$APP/profiles" && ok "comentario conservado" || fail "comentario conservado"
expect 6 "carpeta duplicada" profile add "$MAC" "fake:$DRIVE/Fotos"
mkdir -p "$MAC/sub"
expect 6 "carpeta del Mac dentro de otra configurada" profile add "$MAC/sub" "fake:$DRIVE/Fotos"
expect 6 "carpeta de Drive dentro de otra configurada" profile add "$T/otra" "fake:$DRIVE/Clientes/sub"
expect 6 "carpeta de Drive dentro de las versiones de otra" profile add "$T/otra" "fake:$DRIVE/Clientes (versiones)/a"
expect 0 "segundo perfil" profile add "$T/otra" "fake:$DRIVE/Fotos" --pct 10 --count 5
grep -qx "$T/otra|fake:$DRIVE/Fotos|90|10|5" "$APP/profiles" && ok "umbrales del freno en la línea" || fail "umbrales: $(cat "$APP/profiles")"
expect 0 "cambiar los días" profile set "$MAC" --days 0
grep -qx "$MAC|fake:$DRIVE/Clientes|0" "$APP/profiles" && ok "días cambiados" || fail "días: $(cat "$APP/profiles")"
expect 0 "volver a los valores por defecto" profile set "$MAC" --days 90
grep -qx "$MAC|fake:$DRIVE/Clientes" "$APP/profiles" && ok "línea mínima con los valores por defecto" || fail "línea: $(cat "$APP/profiles")"
expect 6 "set de una carpeta sin perfil" profile set "$T/nada" --days 1
expect 0 "lista" profile list
out_has "\"local\":\"$MAC\",\"remote\":\"fake:$DRIVE/Clientes\",\"days\":90,\"pct\":20,\"count\":50,\"result\":\"never\"" "lista con valores por defecto y nunca ejecutado"
out_has '"initialized":false' "lista: sin primera sincronización"
expect 0 "baja" profile remove "$T/otra"
grep -q "Fotos" "$APP/profiles" && fail "el perfil sigue en profiles" || ok "perfil quitado"
grep -qx '# comentario de Titín' "$APP/profiles" && ok "comentario conservado tras la baja" || fail "comentario tras la baja"
expect 6 "baja de una carpeta sin perfil" profile remove "$T/otra"

# --- Bloqueo compartido con backupdrive-sync.sh ---
mkdir "$APP/run.lock"; echo $$ > "$APP/run.lock/pid"
expect 5 "con una sincronización en curso no se tocan los perfiles" profile add "$T/otra" "fake:$DRIVE/Fotos"
rm -rf "$APP/run.lock"; mkdir "$APP/run.lock"; echo 999999 > "$APP/run.lock/pid"
expect 0 "un bloqueo de un proceso muerto se recupera" profile add "$T/otra" "fake:$DRIVE/Fotos"
[ -d "$APP/run.lock" ] && fail "el bloqueo no se suelta" || ok "el bloqueo se suelta al terminar"
sh "$CTL" profile remove "$T/otra" >/dev/null

# --- Plan: sin simulación, primera sincronización simulada y una pasada con cambios ---
D="$DRIVE/Clientes"
i=1; while [ $i -le 12 ]; do echo "f$i" > "$MAC/f$i.txt"; i=$((i + 1)); done
echo base > "$MAC/doc.docx"; echo d > "$D/d.txt"
expect 6 "plan sin simulación" plan "$MAC"
sync_ --resync --dry-run
expect 0 "plan de la primera sincronización" plan "$MAC"
out_has '"resync":true' "plan: es primera sincronización"
out_has '"date":"20' "plan: con la fecha de la simulación"
out_has '"drive":{"new":["d.txt"]' "plan: d.txt bajará"
out_has '"doc.docx"' "plan: doc.docx subirá"
sync_ --resync
sync_
rm "$MAC/f1.txt"; echo f2-mac > "$MAC/f2.txt"; echo f3-drive > "$D/f3.txt"; echo nuevo > "$D/nuevo.txt"
echo f4-mac > "$MAC/f4.txt"; echo f4-drive > "$D/f4.txt"
sync_ --dry-run
expect 0 "plan de una pasada" plan "$MAC"
out_has '"resync":false' "plan: pasada normal"
out_has '"mac":{"new":[],"changed":["f2.txt"],"deleted":["f1.txt"]}' "plan: cambios del Mac (sin el conflicto)"
out_has '"drive":{"new":["nuevo.txt"],"changed":["f3.txt"]' "plan: cambios de Drive"
out_has '"conflicts":["f4.txt"]' "plan: conflicto"
[ -f "$D/f1.txt" ] && ok "la simulación no ha tocado nada" || fail "la simulación ha borrado f1.txt"

# --- Versiones: lista y restaurar ---
sync_
echo doc-v2 > "$MAC/doc.docx"
sync_
expect 0 "lista de versiones" versions list "$MAC"
out_has '"side":"drive","path":"f1-' "versión de Drive de f1.txt (borrado en el Mac)"
out_has '"original":"f1.txt"' "nombre original de f1.txt"
out_has '"side":"mac","path":"f3-' "versión del Mac de f3.txt (cambiado en Drive)"
out_has '"original":"doc.docx"' "versión de doc.docx con su extensión"
vdoc=$(sed -n 's/.*"side":"drive","path":"\(doc-[0-9-]*\.docx\)".*/\1/p' "$T/out" | head -1)
[ -n "$vdoc" ] && ok "ruta de la versión de doc.docx" || fail "ruta de la versión de doc.docx: $(cat "$T/out")"
vmac=$(ls -d "$APP"/versions/*/ | head -1)
expect 6 "restaurar algo que no es una versión" versions restore "$MAC" drive doc.docx
expect 6 "restaurar con ../" versions restore "$MAC" drive "../doc-20260101-000000.docx"
expect 6 "restaurar una versión que no existe" versions restore "$MAC" drive "doc-20000101-000000.docx"
expect 0 "restaurar doc.docx" versions restore "$MAC" drive "$vdoc"
[ "$(cat "$MAC/doc.docx")" = base ] && ok "doc.docx vuelve a la versión anterior" || fail "doc.docx: $(cat "$MAC/doc.docx")"
[ -f "$D (versiones)/$vdoc" ] && ok "la versión sigue en su sitio" || fail "la versión ha desaparecido"
found=""; for f in "$vmac"doc-*.docx; do [ "$(cat "$f" 2>/dev/null)" = doc-v2 ] && found=1; done
[ -n "$found" ] && ok "lo que había (doc-v2) se ha guardado en versiones del Mac" || fail "doc-v2 perdido"
sync_
[ "$(cat "$D/doc.docx")" = base ] && ok "la siguiente pasada sube lo restaurado a Drive" || fail "Drive: $(cat "$D/doc.docx")"
expect 0 "restaurar f1.txt (borrado)" versions restore "$MAC" drive "$(ls "$D (versiones)" | grep '^f1-' | head -1)"
[ "$(cat "$MAC/f1.txt")" = f1 ] && ok "f1.txt recuperado" || fail "f1.txt no recuperado"
mkdir -p "$MAC/sub"; echo s1 > "$MAC/sub/a.tar.gz"; sync_; echo s2 > "$MAC/sub/a.tar.gz"; sync_
ctl versions list "$MAC"
out_has '"original":"sub/a.tar.gz"' "versión en subcarpeta con extensión compuesta"
va=$(sed -n 's/.*"side":"drive","path":"\(sub\/a-[0-9-]*\.tar\.gz\)".*/\1/p' "$T/out" | head -1)
expect 0 "restaurar sub/a.tar.gz" versions restore "$MAC" drive "$va"
[ "$(cat "$MAC/sub/a.tar.gz")" = s1 ] && ok "sub/a.tar.gz restaurado" || fail "sub/a.tar.gz: $(cat "$MAC/sub/a.tar.gz")"
found=""; for f in "$vmac"sub/a-*.tar.gz; do [ "$(cat "$f" 2>/dev/null)" = s2 ] && found=1; done
[ -n "$found" ] && ok "lo que había va a versiones del Mac en su subcarpeta, con la extensión compuesta" || fail "s2: $(ls -R "$vmac")"

# --- Conflictos: f4.txt cambió en los dos lados (sección del plan) y bisync dejó las dos copias ---
expect 0 "lista de conflictos" conflicts list "$MAC"
out_has '"path":"f4.conflict1.txt","original":"f4.txt","side":"mac"' "conflicto: copia del Mac"
out_has '"path":"f4.conflict2.txt","original":"f4.txt","side":"drive"' "conflicto: copia de Drive"
ctl profile list
out_has '"conflicts":2' "profile list cuenta las copias en conflicto"
expect 6 "keep de algo que no es una copia en conflicto" conflicts keep "$MAC" f2.txt
expect 6 "keep de una copia que no existe" conflicts keep "$MAC" nada.conflict1.txt
expect 0 "quedarse con la copia de Drive" conflicts keep "$MAC" f4.conflict2.txt
[ "$(cat "$MAC/f4.txt")" = f4-drive ] && ok "f4.txt es la copia de Drive" || fail "f4.txt: $(cat "$MAC/f4.txt" 2>/dev/null)"
ls "$MAC"/f4.conflict* >/dev/null 2>&1 && fail "quedan copias en conflicto en el Mac" || ok "sin copias en conflicto en el Mac"
found=""; for f in "$vmac"f4-*.txt; do [ "$(cat "$f" 2>/dev/null)" = f4-mac ] && found=1; done
[ -n "$found" ] && ok "la copia del Mac está en versiones como f4-FECHA.txt" || fail "copia del Mac perdida: $(ls "$vmac")"
# En una carpeta tan pequeña, quitar dos copias pasa del 10 % y salta el freno de borrados (como debe): se continúa a
# propósito, igual que tras revisar «Ver qué cambia».
sync_
[ "$(sed -n 's/.*"result":"\([a-z-]*\)","exit".*/\1/p' "$APP/status.json" | head -1)" = blocked ] \
  && ok "en una carpeta pequeña, resolver un conflicto activa el freno" || fail "sin freno: $(cat "$APP/status.json")"
sync_ --force
[ "$(cat "$D/f4.txt" 2>/dev/null)" = f4-drive ] && ok "Drive queda con f4.txt elegido" || fail "Drive f4.txt: $(cat "$D/f4.txt" 2>/dev/null)"
ls "$D"/f4.conflict* >/dev/null 2>&1 && fail "quedan copias en conflicto en Drive" || ok "Drive sin copias en conflicto"
ls "$D (versiones)"/f4.conflict* >/dev/null 2>&1 && ok "las copias de Drive van a versiones de Drive" || fail "copias de Drive perdidas"
ctl conflicts list "$MAC"
[ "$(cat "$T/out")" = "[]" ] && ok "lista de conflictos vacía" || fail "conflictos: $(cat "$T/out")"

echo "$((n - fails))/$n correctas"
[ "$fails" -eq 0 ]
