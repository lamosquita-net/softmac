#!/bin/sh
# Órdenes de BackupDrive que no son sincronizar: conectar con Google Drive, carpetas de Drive, perfiles, versiones y
# el plan de una pasada. La app de barra de menús solo lanza este guion y backupdrive-sync.sh y lee lo que escriben;
# todo lo que hace la app se puede hacer también desde el terminal (B.6/B.7, plan en BackupDrive/docs/plan-b6-b7.md).
#
# Uso: backupdrive-ctl.sh <orden> [argumentos]
#   connect --client-id ID [--name gdrive]   (o --shared)
#                  crea la cuenta de Google Drive en backupdrive.conf sin preguntas: abre el navegador para autorizar
#                  (rclone espera en 127.0.0.1:53682). Cada usuario usa SU clave de Google Cloud (Titín, 03-11; por qué y
#                  cómo: BackupDrive/docs/clave-google.md). El secreto se pregunta sin eco o va en BACKUPDRIVE_CLIENT_SECRET
#                  (--client-secret S también vale, pero queda en el historial). --shared: la clave compartida de rclone,
#                  solo para pruebas. Si la cuenta ya existe, la sustituye; si la autorización falla, la deja como estaba.
#   check [--name gdrive]           comprueba la conexión (rclone about); imprime JSON con el espacio de Drive
#   folders <remoto:ruta>           carpetas de esa ruta de Drive, en JSON (lsjson --dirs-only)
#   mkdir <remoto:ruta>             crea una carpeta en Drive
#   profile list                    perfiles con su último resultado, en JSON
#   profile add <carpeta> <remoto:ruta> [--days N] [--pct P] [--count N]
#   profile set <carpeta> [--days N] [--pct P] [--count N]
#   profile remove <carpeta>        quita el perfil; no borra nada en el Mac, en Drive ni en versiones
#   versions list <carpeta>         versiones de los dos lados, en JSON (más reciente primero)
#   versions restore <carpeta> <mac|drive> <ruta de la versión>
#                  copia la versión a su sitio en el Mac; si allí hay un fichero, va antes a versiones. La versión se
#                  queda donde estaba. La siguiente pasada sube lo restaurado a Drive (y lo de Drive va a versiones).
#   conflicts list <carpeta>        copias en conflicto (fichero cambiado en los dos lados; bisync conserva las dos como
#                  «nombre.conflicto-macN.ext» y «.conflicto-driveN»), en JSON: ruta, original, lado (por el nombre;
#                  «?» en las copias antiguas «nombre.conflictN»), tamaño y fecha
#   conflicts keep <carpeta> <ruta de la copia elegida>
#                  la copia elegida vuelve a su nombre; las demás copias de ese fichero (y lo que hubiera con su nombre)
#                  van a versiones del Mac. La siguiente pasada lo lleva a Drive (allí las copias van a versiones de Drive)
#   plan <carpeta>                  último plan simulado del perfil (de un --dry-run de backupdrive-sync.sh), en JSON:
#                  lo nuevo, cambiado y borrado en cada lado (se copia al otro; lo que se borra o se sobrescribe allí
#                  va a versiones) y los conflictos (se conservan los dos)
#
# Códigos de salida: 0 bien; 1 error de rclone; 2 uso; 5 hay una sincronización en curso (reintentar luego);
# 6 datos no válidos (el mensaje, en castellano llano, va a stderr para que la app lo enseñe tal cual).
# Las órdenes que escriben (connect, profile add/set/remove, versions restore) toman el mismo bloqueo que
# backupdrive-sync.sh, así que nunca coinciden con una sincronización.
set -eu

APP_DIR="${BACKUPDRIVE_DIR:-$HOME/Library/Application Support/BackupDrive}"
BIN="${BACKUPDRIVE_BIN:-/usr/local/bin/backupdrive}"
CONF="$APP_DIR/backupdrive.conf"
PROFILES="$APP_DIR/profiles"
STATE_DIR="$APP_DIR/state"
LOCK="$APP_DIR/run.lock"
DEFAULT_DAYS=90
DEFAULT_MOD_PCT=20
DEFAULT_MOD_N=50

die() { echo "$2" >&2; exit "$1"; }
usage() { sed -n '/^# Uso:/,/^# Códigos/p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2; }
json_str() { printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\t' ' ')"; }
rc_() { "$BIN" --config "$CONF" "$@" </dev/null; }
need_bin() { [ -x "$BIN" ] || die 1 "No encuentro el programa de BackupDrive ($BIN)."; }
need_conf() { [ -f "$CONF" ] || die 6 "Aún no hay ninguna cuenta de Google Drive conectada."; }

# Mismo cálculo que backupdrive-sync.sh (las pruebas comprueban que coinciden).
profile_id() { printf '%s|%s' "$1" "$2" | cksum | cut -d' ' -f1; }
versions_mac() { echo "$APP_DIR/versions/$(basename "$1")-$(profile_id "$1" "$2")"; }
versions_drive() { echo "${2%/} (versiones)"; }

# Bloqueo compartido con backupdrive-sync.sh (mkdir es atómico; uno de un proceso muerto se recupera).
# lock [segundos]: con segundos, espera ese tiempo a que termine una sincronización en curso antes de rendirse
# (connect: justo después de instalar, launchd lanza una pasada y el usuario no tiene por qué saberlo).
lock() {
  mkdir -p "$APP_DIR"
  waited=0
  until mkdir "$LOCK" 2>/dev/null; do
    pid=$(cat "$LOCK/pid" 2>/dev/null || true)
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      [ "$waited" -lt "${1:-0}" ] || die 5 "BackupDrive está sincronizando ahora. Vuelve a intentarlo cuando termine."
      sleep 1; waited=$((waited + 1))
    else
      # Bloqueo abandonado (proceso muerto): se quita y se vuelve a intentar una vez.
      rm -rf "$LOCK"
      mkdir "$LOCK" 2>/dev/null && break
      die 5 "BackupDrive está sincronizando ahora. Vuelve a intentarlo cuando termine."
    fi
  done
  echo $$ > "$LOCK/pid"
  trap 'rm -rf "$LOCK"' EXIT
  trap 'rm -rf "$LOCK"; exit 130' INT TERM
}

# Línea del perfil de esa carpeta (sin la barra final), o nada.
find_profile() {
  [ -f "$PROFILES" ] || return 0
  want=${1%/}
  while IFS= read -r line; do
    case "$line" in ''|'#'*) continue ;; esac
    l=${line%%|*}
    [ "${l%/}" = "$want" ] && { printf '%s\n' "$line"; return 0; }
  done < "$PROFILES"
  return 0
}
field() { printf '%s\n' "$1" | cut -d'|' -f"$2"; }
get_profile() { # carpeta -> PL PR PD PP PN (o error 6)
  line=$(find_profile "$1")
  [ -n "$line" ] || die 6 "No hay ninguna carpeta configurada en $1."
  PL=$(field "$line" 1); PR=$(field "$line" 2); PD=$(field "$line" 3); PP=$(field "$line" 4); PN=$(field "$line" 5)
  case "$PD" in ''|*[!0-9]*) PD=$DEFAULT_DAYS ;; esac
  case "$PP" in ''|*[!0-9]*) PP=$DEFAULT_MOD_PCT ;; esac
  case "$PN" in ''|*[!0-9]*) PN=$DEFAULT_MOD_N ;; esac
}

# Reescribe profiles de forma atómica: $1 = carpeta a sustituir (vacío: ninguna), $2 = línea nueva (vacío: quitar).
# Los comentarios y el resto de líneas se conservan tal cual.
rewrite_profiles() {
  tmp=$(mktemp "$APP_DIR/.profiles.XXXXXX")
  done_=0
  if [ -f "$PROFILES" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
      case "$line" in ''|'#'*) printf '%s\n' "$line" >> "$tmp"; continue ;; esac
      # rl, no l: las órdenes que llaman a esta función usan $l (sh no tiene variables locales).
      rl=${line%%|*}
      if [ -n "$1" ] && [ "${rl%/}" = "${1%/}" ]; then
        [ -z "$2" ] || printf '%s\n' "$2" >> "$tmp"
        done_=1
      else
        printf '%s\n' "$line" >> "$tmp"
      fi
    done < "$PROFILES"
  fi
  [ "$done_" = 1 ] || [ -z "$2" ] || printf '%s\n' "$2" >> "$tmp"
  mv "$tmp" "$PROFILES"
}

# ¿$1 es $2 o está dentro de $2? (rutas sin barra final)
inside() { case "$1/" in "$2"/*) return 0 ;; esac; return 1; }

number_opts() { # --days/--pct/--count -> OD OP ON
  while [ $# -gt 0 ]; do
    case "$1" in
      --days|--pct|--count)
        [ $# -ge 2 ] || usage
        case "$2" in ''|*[!0-9]*) die 6 "$1 necesita un número entero." ;; esac
        case "$1" in --days) OD=$2 ;; --pct) OP=$2 ;; --count) ON=$2 ;; esac
        shift ;;
      *) usage ;;
    esac
    shift
  done
  [ -z "${OP:-}" ] || [ "$OP" -le 100 ] || die 6 "El porcentaje del freno debe estar entre 0 y 100."
}
profile_line() { # local remoto días % nº (los tres últimos solo si no son los de por defecto)
  out="$1|$2"
  if [ "$3" != "$DEFAULT_DAYS" ] || [ "$4" != "$DEFAULT_MOD_PCT" ] || [ "$5" != "$DEFAULT_MOD_N" ]; then
    out="$out|$3"
    { [ "$4" != "$DEFAULT_MOD_PCT" ] || [ "$5" != "$DEFAULT_MOD_N" ]; } && out="$out|$4|$5"
  fi
  printf '%s\n' "$out"
}

# Escribe client_secret en la sección [nombre] de backupdrive.conf sin pasarlo por argumentos (awk lo lee del entorno).
add_secret() {
  ( umask 077
    tmp=$(mktemp "$APP_DIR/.conf.XXXXXX") || exit 1
    BD_SECRET=$2 awk -v sec="[$1]" '
      { print }
      $0 == sec { print "client_secret = " ENVIRON["BD_SECRET"]; done = 1 }
      END { if (!done) exit 1 }' "$CONF" >"$tmp" || { rm -f "$tmp"; exit 1; }
    mv -f "$tmp" "$CONF" )
}

cmd_connect() {
  name=gdrive; cid=""; csec=${BACKUPDRIVE_CLIENT_SECRET:-}; shared=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --client-id) [ $# -ge 2 ] || usage; cid=$2; shift ;;
      --client-secret) [ $# -ge 2 ] || usage; csec=$2; shift ;;
      --shared) shared=1 ;;
      --name) [ $# -ge 2 ] || usage; name=$2; shift ;;
      *) usage ;;
    esac
    shift
  done
  case "$name" in ''|*[!A-Za-z0-9_-]*) die 6 "Nombre de cuenta no válido: $name" ;; esac
  if [ "$shared" = 0 ]; then
    [ -n "$cid" ] || die 6 "Falta tu ID de cliente de Google (--client-id). Cómo crearlo: BackupDrive/docs/clave-google.md."
    case "$cid" in *[!A-Za-z0-9._-]*|*' '*) die 6 "El ID de cliente no es válido: cópialo entero desde Google Cloud." ;; esac
    case "$cid" in *.apps.googleusercontent.com) ;; *) die 6 "El ID de cliente debe terminar en .apps.googleusercontent.com." ;; esac
    # El secreto no va en la línea de órdenes (quedaría en el historial): variable de entorno o se pregunta sin eco.
    if [ -z "$csec" ] && [ -r /dev/tty ] && [ -t 0 ]; then
      printf 'Secreto de cliente (no se ve al escribir): ' >/dev/tty
      stty -echo </dev/tty 2>/dev/null || true
      IFS= read -r csec </dev/tty || csec=""
      stty echo </dev/tty 2>/dev/null || true
      printf '\n' >/dev/tty
    fi
    [ -n "$csec" ] || die 6 "Falta el secreto de cliente (BACKUPDRIVE_CLIENT_SECRET o se pregunta en el terminal)."
  fi
  need_bin; lock "${BACKUPDRIVE_CONNECT_WAIT:-120}"
  # Tipo de remoto: drive; las pruebas usan «local» (BACKUPDRIVE_CONNECT_TYPE) porque no hay Google en la CI.
  type=${BACKUPDRIVE_CONNECT_TYPE:-drive}
  set -- config create "$name" "$type"
  if [ "$type" = drive ]; then
    set -- "$@" scope=drive
    [ "$shared" = 1 ] || set -- "$@" client_id="$cid"
  fi
  # El secreto tampoco va en los argumentos de rclone (cualquier usuario del Mac los ve con ps): rclone lo lee de su
  # variable de entorno durante la autorización y después se escribe en la sección de la cuenta (ver add_secret).
  envname=RCLONE_CONFIG_$(printf '%s' "$name" | tr 'a-z-' 'A-Z_')_CLIENT_SECRET
  # config create borra la cuenta anterior antes de autorizar: si algo falla (navegador cerrado), se deja como estaba.
  bak=""
  if [ -f "$CONF" ]; then bak=$(mktemp "$APP_DIR/.conf.XXXXXX"); cp -p "$CONF" "$bak"; fi
  restore_conf() { if [ -n "$bak" ]; then mv -f "$bak" "$CONF"; else rm -f "$CONF"; fi; }
  # Sin preguntas: rclone toma las respuestas por defecto y abre el navegador para autorizar. En segundo plano para que
  # Cancelar (la app manda SIGTERM) pare también a rclone, que si no se queda esperando en el puerto 53682.
  if [ -n "$csec" ]; then
    env "$envname=$csec" "$BIN" --config "$CONF" "$@" </dev/null >/dev/null &
  else
    "$BIN" --config "$CONF" "$@" </dev/null >/dev/null &
  fi
  cpid=$!
  trap 'kill "$cpid" 2>/dev/null || true; wait "$cpid" 2>/dev/null || true; restore_conf; rm -rf "$LOCK"; exit 130' INT TERM
  crc=0; wait "$cpid" || crc=$?
  trap 'rm -rf "$LOCK"; exit 130' INT TERM
  if [ "$crc" -ne 0 ]; then
    restore_conf
    die 1 "No se pudo conectar con Google Drive; no se ha cambiado nada. Si cerraste el navegador antes de autorizar, vuelve a intentarlo."
  fi
  if [ -n "$csec" ] && ! add_secret "$name" "$csec"; then
    restore_conf
    die 1 "No se pudo guardar el secreto en la configuración; no se ha cambiado nada."
  fi
  [ -z "$bak" ] || rm -f "$bak"
  chmod 600 "$CONF" 2>/dev/null || true
  cmd_check --name "$name"
}

cmd_check() {
  name=gdrive
  [ "${1:-}" != --name ] || { [ $# -ge 2 ] || usage; name=$2; }
  need_bin; need_conf
  rc_ listremotes | grep -qx "$name:" || die 6 "No hay ninguna cuenta llamada $name."
  out=$(rc_ about "$name:" --json 2>/dev/null) || die 1 "La cuenta $name no responde. Comprueba la conexión a Internet o vuelve a conectarla."
  printf '{"ok":true,"name":%s,"about":%s}\n' "$(json_str "$name")" "$(printf '%s' "$out" | tr -d '\n')"
}

remote_path() { # valida remoto:ruta
  case "$1" in *:*) ;; *) die 6 "Falta la cuenta en «$1» (p. ej. gdrive:Clientes)." ;; esac
}

cmd_folders() {
  [ $# -eq 1 ] || usage
  remote_path "$1"; need_bin; need_conf
  rc_ lsjson --dirs-only --no-modtime --no-mimetype "$1" 2>/dev/null \
    || die 1 "No se puede leer la carpeta $1 de Drive."
}

cmd_mkdir() {
  [ $# -eq 1 ] || usage
  remote_path "$1"; need_bin; need_conf
  rc_ mkdir "$1" || die 1 "No se pudo crear la carpeta $1 en Drive."
}

cmd_profile_list() {
  printf '['
  sep=""
  if [ -f "$PROFILES" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
      case "$line" in ''|'#'*) continue ;; esac
      l=$(field "$line" 1); r=$(field "$line" 2); d=$(field "$line" 3); p=$(field "$line" 4); n=$(field "$line" 5)
      case "$d" in ''|*[!0-9]*) d=$DEFAULT_DAYS ;; esac
      case "$p" in ''|*[!0-9]*) p=$DEFAULT_MOD_PCT ;; esac
      case "$n" in ''|*[!0-9]*) n=$DEFAULT_MOD_N ;; esac
      st="$STATE_DIR/$(profile_id "$l" "$r").json"
      res=never; fin=""
      if [ -f "$st" ]; then
        res=$(sed -n 's/.*"result":"\([a-z-]*\)".*/\1/p' "$st"); fin=$(sed -n 's/.*"finished":"\([^"]*\)".*/\1/p' "$st")
      fi
      init=false; [ -f "$STATE_DIR/$(profile_id "$l" "$r").init" ] && init=true
      nconf=0; [ -d "$l" ] && nconf=$(find "$l" -type f \( -name '*.conflict[0-9]*' -o -name '*.conflicto-mac[0-9]*' \
        -o -name '*.conflicto-drive[0-9]*' \) 2>/dev/null | wc -l | tr -d ' ')
      printf '%s{"local":%s,"remote":%s,"days":%s,"pct":%s,"count":%s,"result":%s,"finished":%s,"initialized":%s,"conflicts":%s,"versions_mac":%s,"versions_drive":%s}' \
        "$sep" "$(json_str "$l")" "$(json_str "$r")" "$d" "$p" "$n" "$(json_str "${res:-never}")" "$(json_str "$fin")" "$init" "${nconf:-0}" \
        "$(json_str "$(versions_mac "$l" "$r")")" "$(json_str "$(versions_drive "$l" "$r")")"
      sep=","
    done < "$PROFILES"
  fi
  printf ']\n'
}

cmd_profile_add() {
  [ $# -ge 2 ] || usage
  l=${1%/}; r=${2%/}; shift 2
  OD=$DEFAULT_DAYS; OP=$DEFAULT_MOD_PCT; ON=$DEFAULT_MOD_N
  number_opts "$@"
  case "$l" in /*) ;; *) die 6 "La carpeta del Mac debe ser una ruta completa (empieza por /)." ;; esac
  case "$l$r" in *'|'*) die 6 "Los nombres no pueden llevar el carácter |." ;; esac
  [ -d "$l" ] || die 6 "No existe la carpeta $l."
  [ "$l" != "$HOME" ] && [ "$l" != / ] || die 6 "Elige una carpeta concreta, no toda tu carpeta de usuario ni el disco."
  remote_path "$r"
  case "${r#*:}" in ''|/) die 6 "Elige una carpeta de Drive, no la raíz: la carpeta de versiones va a su lado." ;; esac
  inside "$l" "${APP_DIR%/}" && die 6 "Esa carpeta es de BackupDrive (configuración o versiones)."
  case "$r" in *' (versiones)'|*' (versiones)/'*) die 6 "Esa carpeta de Drive es de versiones de BackupDrive." ;; esac
  lock
  if [ -f "$PROFILES" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
      case "$line" in ''|'#'*) continue ;; esac
      ol=$(field "$line" 1); ol=${ol%/}; or_=$(field "$line" 2); or_=${or_%/}
      [ "$ol" = "$l" ] && die 6 "La carpeta $l ya está configurada."
      { inside "$l" "$ol" || inside "$ol" "$l"; } && die 6 "La carpeta $l se solapa con $ol, que ya está configurada."
      { inside "$r" "$or_" || inside "$or_" "$r"; } && die 6 "La carpeta de Drive $r se solapa con $or_, que ya está configurada."
      inside "$r" "$or_ (versiones)" && die 6 "Esa carpeta de Drive es de versiones de BackupDrive."
    done < "$PROFILES"
  fi
  [ -f "$PROFILES" ] || mkdir -p "$APP_DIR"
  rewrite_profiles "" "$(profile_line "$l" "$r" "$OD" "$OP" "$ON")"
  echo "Añadida $l ↔ $r. Falta la primera sincronización (primero simulada)."
}

cmd_profile_set() {
  [ $# -ge 1 ] || usage
  get_profile "$1"; shift
  OD=$PD; OP=$PP; ON=$PN
  number_opts "$@"
  lock
  rewrite_profiles "$PL" "$(profile_line "${PL%/}" "$PR" "$OD" "$OP" "$ON")"
  echo "Guardado."
}

cmd_profile_remove() {
  [ $# -eq 1 ] || usage
  get_profile "$1"
  lock
  rewrite_profiles "$PL" ""
  echo "Quitada $PL. No se ha borrado nada: los ficheros y las versiones siguen en el Mac y en Drive."
}

# Versión → fichero original: quita el sufijo -AAAAMMDD-HHMMSS antes de las extensiones (--suffix-keep-extension
# conserva también las compuestas conocidas: a.tar.gz → a-AAAAMMDD-HHMMSS.tar.gz).
VERSION_RE='-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9](\.[^\/]*)?$'
original_of() { printf '%s\n' "$1" | sed -E 's/-[0-9]{8}-[0-9]{6}(\.[^\/]*)?$/\1/'; }

cmd_versions_list() {
  [ $# -eq 1 ] || usage
  get_profile "$1"; need_bin; need_conf
  vm=$(versions_mac "$PL" "$PR"); vd=$(versions_drive "$PL" "$PR")
  tmp=$(mktemp); trap 'rm -f "$tmp"' EXIT
  { [ -d "$vm" ] && rc_ lsf -R --files-only --format ps --separator '	' "$vm" 2>/dev/null | sed 's/^/mac	/'; } >> "$tmp" || true
  rc_ lsf -R --files-only --format ps --separator '	' "$vd" 2>/dev/null | sed 's/^/drive	/' >> "$tmp" || true
  # lado, ruta de la versión, tamaño -> JSON, más reciente primero (la fecha sale del nombre)
  # (el patrón va literal: pasado con -v, algunos awk quitan la barra de «\.»)
  awk -F'	' '
    function esc(s) { gsub(/\\/, "\\\\", s); gsub(/"/, "\\\"", s); return s }
    match($2, /-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9](\.[^\/]*)?$/) {
      stamp = substr($2, RSTART + 1, 15); orig = substr($2, 1, RSTART - 1) substr($2, RSTART + 16)
      d = substr(stamp,1,4) "-" substr(stamp,5,2) "-" substr(stamp,7,2) "T" substr(stamp,10,2) ":" substr(stamp,12,2) ":" substr(stamp,14,2)
      printf "%s\t{\"side\":\"%s\",\"path\":\"%s\",\"original\":\"%s\",\"date\":\"%s\",\"size\":%s}\n", stamp, $1, esc($2), esc(orig), d, ($3 == "" ? 0 : $3)
    }' "$tmp" | sort -r | cut -f2- | awk 'BEGIN { printf "[" } { printf "%s%s", (NR > 1 ? "," : ""), $0 } END { print "]" }'
}

cmd_versions_restore() {
  [ $# -eq 3 ] || usage
  get_profile "$1"; side=$2; vpath=$3; need_bin; need_conf
  case "$vpath" in /*|*../*|..*) die 6 "Ruta de versión no válida." ;; esac
  printf '%s\n' "$vpath" | grep -qE -- "$VERSION_RE" || die 6 "Eso no es una versión de BackupDrive: $vpath"
  vm=$(versions_mac "$PL" "$PR"); vd=$(versions_drive "$PL" "$PR")
  case "$side" in
    mac) src="$vm/$vpath" ;;
    drive) src="$vd/$vpath" ;;
    *) usage ;;
  esac
  orig=$(original_of "$vpath")
  dest="${PL%/}/$orig"
  lock
  rc_ lsf "$src" >/dev/null 2>&1 || die 6 "Esa versión ya no existe (¿caducó?)."
  stamp=$(date +%Y%m%d-%H%M%S)
  sub=$(dirname "$orig")
  mkdir -p "$(dirname "$dest")"
  # Si ya hay un fichero, rclone lo mueve antes a versiones del Mac con el mismo nombre que pondría bisync
  # (--backup-dir + sufijo; misma subcarpeta). --ignore-times: copiar siempre, aunque coincidan tamaño y fecha.
  rc_ copyto "$src" "$dest" --ignore-times --backup-dir "$vm/$sub" --suffix "-$stamp" --suffix-keep-extension \
    || die 1 "No se pudo restaurar la versión."
  touch "$dest"
  echo "Restaurado $orig. Se subirá a Drive en la próxima sincronización."
}

# Copias en conflicto (bisync 1.67, --conflict-resolve none): «nombre.conflicto-macN[.ext]» (la del Mac) y
# «nombre.conflicto-driveN[.ext]» (la de Drive), con --conflict-suffix. El lado va en el nombre: el número no sirve,
# porque bisync lo desplaza si queda una copia anterior (fallo 10 de la 6,1: «conflict2» era la del Mac).
# Las de antes, «nombre.conflictN[.ext]», se siguen reconociendo, pero sin lado.
conflict_original() { printf '%s\n' "$1" | sed -E 's/\.(conflict|conflicto-mac|conflicto-drive)[0-9]+//'; }
conflict_side() {
  case "${1##*/}" in
    *.conflicto-mac[0-9]*) echo mac ;;
    *.conflicto-drive[0-9]*) echo drive ;;
    *) echo '?' ;;
  esac
}

conflict_rows() { # carpeta -> «ruta<TAB>tamaño<TAB>fecha» de cada copia en conflicto
  rc_ lsjson -R --files-only --no-mimetype --include '*.conflict[0-9]*' --include '*.conflicto-mac[0-9]*' \
    --include '*.conflicto-drive[0-9]*' "$1" 2>/dev/null \
    | sed -nE 's/.*"Path":"(([^"\\]|\\.)*)".*"Size":([0-9-]*).*"ModTime":"([^"]*)".*/\1	\3	\4/p'
}

cmd_conflicts_list() {
  [ $# -eq 1 ] || usage
  get_profile "$1"; need_bin
  conflict_rows "$PL" | while IFS='	' read -r path size mtime; do
    orig=$(conflict_original "$path")
    side=$(conflict_side "$path")
    printf '%s\t{"path":%s,"original":%s,"side":"%s","size":%s,"date":%s}\n' \
      "$orig" "$(json_str "$path")" "$(json_str "$orig")" "$side" "${size:-0}" "$(json_str "$mtime")"
  done | sort | cut -f2- | awk 'BEGIN { printf "[" } { printf "%s%s", (NR > 1 ? "," : ""), $0 } END { print "]" }'
}

cmd_conflicts_keep() {
  [ $# -eq 2 ] || usage
  get_profile "$1"; keep=$2; need_bin
  case "$keep" in /*|*../*|..*) die 6 "Ruta no válida." ;; esac
  case "${keep##*/}" in *.conflict[0-9]*|*.conflicto-mac[0-9]*|*.conflicto-drive[0-9]*) ;; *) die 6 "Eso no es una copia en conflicto: $keep" ;; esac
  [ -f "${PL%/}/$keep" ] || die 6 "Ya no existe $keep (¿se resolvió ya?)."
  orig=$(conflict_original "$keep")
  vm=$(versions_mac "$PL" "$PR")
  lock
  tmp=$(mktemp "$APP_DIR/.conflicts.XXXXXX")
  conflict_rows "$PL" | cut -f1 > "$tmp"
  # Lo que no se elige va a versiones del Mac, con el nombre del original y la fecha (como cualquier versión).
  to_versions() { # ruta relativa
    ext=""; case "${orig##*/}" in *.*) ext=".${orig##*.}" ;; esac
    base=${orig%"$ext"}
    while :; do
      target="$vm/$base-$(date +%Y%m%d-%H%M%S)$ext"
      [ -e "$target" ] || break
      sleep 1
    done
    mkdir -p "$(dirname "$target")"
    rc_ moveto "${PL%/}/$1" "$target" || { rm -f "$tmp"; die 1 "No se pudo guardar $1 en versiones."; }
  }
  while IFS= read -r other; do
    [ "$other" != "$keep" ] || continue
    [ "$(conflict_original "$other")" = "$orig" ] || continue
    to_versions "$other"
  done < "$tmp"
  rm -f "$tmp"
  [ ! -e "${PL%/}/$orig" ] || to_versions "$orig"
  rc_ moveto "${PL%/}/$keep" "${PL%/}/$orig" || die 1 "No se pudo devolver $keep a su nombre."
  echo "Te quedas con $keep como $orig. Las otras copias están en versiones; Drive se pondrá igual en la próxima sincronización."
}

# Plan de la última simulación (backupdrive-sync.sh --dry-run lo guarda en state/<id>.plan.log).
cmd_plan() {
  [ $# -eq 1 ] || usage
  get_profile "$1"
  f="$STATE_DIR/$(profile_id "$PL" "$PR").plan.log"
  [ -f "$f" ] || die 6 "Aún no hay ninguna simulación de $PL."
  when=$(date -u -r "$(stat -f %m "$f" 2>/dev/null)" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null \
         || date -u -r "$f" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")
  frc=$(head -1 "$f" | sed -n 's/.* error=\([0-9]*\).*/\1/p')
  [ -z "$frc" ] || die 1 "La última simulación de $PL falló (código $frc); no hay plan. Mira el registro: ~/Library/Logs/BackupDrive/backupdrive.log"
  resync=false; head -1 "$f" | grep -q '^BACKUPDRIVE-PLAN resync' && resync=true
  # Líneas de bisync 1.67 (las del análisis, con rutas relativas):
  #   «- Path1  File is new - x», «- Path1  File changed: … - x», «- Path1  File was deleted - x» (Path1 = Mac),
  #   «- WARNING  New or changed in both paths - x» (conflicto: se conservarán los dos).
  # En una primera sincronización: «- Path1  Resync is copying files to - Path2» y luego «x: Skipped copy as --dry-run».
  # Salida: lo que ha cambiado en cada lado (y por tanto se copiará al otro; lo borrado va a versiones del otro lado).
  awk -v when="$when" -v resync="$resync" '
    function esc(s) { gsub(/\\/, "\\\\", s); gsub(/"/, "\\\"", s); return s }
    function item(s) { sub(/^.* - /, "", s); return s }
    function add(k, s) { if (!seen[k, s]++) { n[k]++; v[k, n[k]] = s } }
    function out(k,   i, r) { r = ""; for (i = 1; i <= n[k]; i++) if (!((k ~ /changed/) && conflict[v[k, i]])) r = r (r == "" ? "" : ",") "\"" esc(v[k, i]) "\""; return "[" r "]" }
    /Resync is copying files to +- Path2/ { dir = "mac"; next }
    /Resync is copying files to +- Path1/ { dir = "drive"; next }
    dir != "" && /: Skipped copy as --dry-run is set/ { s = $0; sub(/^[0-9\/]+ [0-9:]+ NOTICE: /, "", s); sub(/: Skipped copy as --dry-run is set.*$/, "", s); add(dir "_new", s); next }
    / - Path1 +File is new/ { add("mac_new", item($0)); next }
    / - Path2 +File is new/ { add("drive_new", item($0)); next }
    / - Path1 +File changed/ { add("mac_changed", item($0)); next }
    / - Path2 +File changed/ { add("drive_changed", item($0)); next }
    / - Path1 +File was deleted/ { add("mac_deleted", item($0)); next }
    / - Path2 +File was deleted/ { add("drive_deleted", item($0)); next }
    /New or changed in both paths/ { s = item($0); conflict[s] = 1; add("conflicts", s); next }
    END {
      printf "{\"date\":\"%s\",\"resync\":%s", when, resync
      printf ",\"mac\":{\"new\":%s,\"changed\":%s,\"deleted\":%s}", out("mac_new"), out("mac_changed"), out("mac_deleted")
      printf ",\"drive\":{\"new\":%s,\"changed\":%s,\"deleted\":%s}", out("drive_new"), out("drive_changed"), out("drive_deleted")
      printf ",\"conflicts\":%s}\n", out("conflicts")
    }' "$f"
}

[ $# -ge 1 ] || usage
cmd=$1; shift
case "$cmd" in
  connect) cmd_connect "$@" ;;
  check) cmd_check "$@" ;;
  folders) cmd_folders "$@" ;;
  mkdir) cmd_mkdir "$@" ;;
  profile)
    [ $# -ge 1 ] || usage; sub=$1; shift
    case "$sub" in
      list) cmd_profile_list ;;
      add) cmd_profile_add "$@" ;;
      set) cmd_profile_set "$@" ;;
      remove) cmd_profile_remove "$@" ;;
      *) usage ;;
    esac ;;
  versions)
    [ $# -ge 1 ] || usage; sub=$1; shift
    case "$sub" in
      list) cmd_versions_list "$@" ;;
      restore) cmd_versions_restore "$@" ;;
      *) usage ;;
    esac ;;
  conflicts)
    [ $# -ge 1 ] || usage; sub=$1; shift
    case "$sub" in
      list) cmd_conflicts_list "$@" ;;
      keep) cmd_conflicts_keep "$@" ;;
      *) usage ;;
    esac ;;
  plan) cmd_plan "$@" ;;
  -h|--help|help) usage ;;
  *) usage ;;
esac
