#!/bin/sh
# Ejecuta "bisync" para cada perfil de BackupDrive. Pensado para launchd, pero se puede lanzar a mano.
#
# Configuración en ~/Library/Application Support/BackupDrive/:
#   backupdrive.conf   remotos (se crea con: backupdrive --config <esa ruta> config)
#   profiles           una línea por perfil:  <carpeta local>|<remoto:ruta>   (# = comentario)
#   filters.txt        opcional: filtros de rclone comunes a todos los perfiles
#
# Estado para la app de barra de menús: status.json en la misma carpeta (se escribe de forma atómica):
#   {"state":"running|idle","started":…,"finished":…,"result":"ok|error|running|interrupted",
#    "profiles":[{"local":…,"remote":…,"result":"ok|error|skipped","exit":N,"finished":…}],"log":…}
# Bloqueo: si ya hay una ejecución en curso, esta sale sin hacer nada (código 0).
# Avisos: notificación de macOS si algún perfil falla (BACKUPDRIVE_NOTIFY=0 para desactivarlos).
#
# Uso: backupdrive-sync.sh [--resync] [--dry-run]
#   --resync   primera sincronización de un perfil nuevo (obligatorio la primera vez)
set -eu

EXTRA_ARGS=""
for a in "$@"; do
  case "$a" in
    --resync|--dry-run) EXTRA_ARGS="$EXTRA_ARGS $a" ;;
    *) echo "Opción desconocida: $a" >&2; exit 2 ;;
  esac
done

APP_DIR="${BACKUPDRIVE_DIR:-$HOME/Library/Application Support/BackupDrive}"
BIN="${BACKUPDRIVE_BIN:-/usr/local/bin/backupdrive}"
CONF="$APP_DIR/backupdrive.conf"
PROFILES="$APP_DIR/profiles"
FILTERS="$APP_DIR/filters.txt"
STATUS="$APP_DIR/status.json"
LOCK="$APP_DIR/run.lock"
LOG_DIR="$HOME/Library/Logs/BackupDrive"
LOG="$LOG_DIR/backupdrive.log"

mkdir -p "$APP_DIR" "$LOG_DIR"
[ -x "$BIN" ] || { echo "No encuentro $BIN" >&2; exit 1; }
[ -f "$CONF" ] || { echo "Falta $CONF. Créalo con: $BIN --config \"$CONF\" config" >&2; exit 1; }
[ -f "$PROFILES" ] || { echo "Falta $PROFILES (formato: carpeta|remoto:ruta)" >&2; exit 1; }

now() { date -u +%Y-%m-%dT%H:%M:%SZ; }
json_str() { # cadena JSON con comillas; escapa \ y "
  printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"
}

# --- Bloqueo (mkdir es atómico). Un bloqueo de un proceso muerto se recupera. ---
if ! mkdir "$LOCK" 2>/dev/null; then
  pid=$(cat "$LOCK/pid" 2>/dev/null || true)
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    echo "BackupDrive ya se está ejecutando (pid $pid); no hago nada."
    exit 0
  fi
  rm -rf "$LOCK"
  mkdir "$LOCK"
fi
echo $$ > "$LOCK/pid"

TMP_PROFILES=$(mktemp "$APP_DIR/.profiles.XXXXXX")
cleanup() { rm -rf "$LOCK" "$TMP_PROFILES"; }
trap cleanup EXIT

STARTED=$(now)
write_status() { # $1 state, $2 result, $3 finished
  tmp=$(mktemp "$APP_DIR/.status.XXXXXX")
  {
    printf '{"state":%s,"started":%s,"finished":%s,"result":%s,"profiles":[' \
      "$(json_str "$1")" "$(json_str "$STARTED")" "$(json_str "$3")" "$(json_str "$2")"
    paste -sd, "$TMP_PROFILES" 2>/dev/null | tr -d '\n'
    printf '],"log":%s}\n' "$(json_str "$LOG")"
  } > "$tmp"
  mv "$tmp" "$STATUS"
}
add_profile() { # local remote result exit
  printf '{"local":%s,"remote":%s,"result":%s,"exit":%s,"finished":%s}\n' \
    "$(json_str "$1")" "$(json_str "$2")" "$(json_str "$3")" "$4" "$(json_str "$(now)")" >> "$TMP_PROFILES"
}
notify() {
  [ "${BACKUPDRIVE_NOTIFY:-1}" = "1" ] && command -v osascript >/dev/null || return 0
  osascript -e "display notification \"$1\" with title \"BackupDrive\"" >/dev/null 2>&1 || true
}

write_status running running ""
trap 'write_status idle interrupted "$(now)"; exit 130' INT TERM

status=0
failed=""
while IFS='|' read -r local_dir remote; do
  case "$local_dir" in ''|'#'*) continue ;; esac
  if [ -z "$remote" ]; then
    echo "Perfil incompleto: $local_dir" >&2; status=1; failed="$failed $local_dir"
    add_profile "$local_dir" "" skipped 2; write_status running running ""; continue
  fi
  if [ ! -d "$local_dir" ]; then
    echo "No existe $local_dir" >&2; status=1; failed="$failed $local_dir"
    add_profile "$local_dir" "$remote" skipped 2; write_status running running ""; continue
  fi

  echo "== $(date '+%Y-%m-%d %H:%M:%S') $local_dir <-> $remote"
  set -- --config "$CONF" bisync "$local_dir" "$remote" \
    --resilient --recover --max-lock 2h \
    --compare size,modtime --create-empty-src-dirs \
    --conflict-resolve newer --conflict-loser num \
    --drive-skip-gdocs \
    --log-file "$LOG" --log-level INFO
  [ -f "$FILTERS" ] && set -- "$@" --filters-file "$FILTERS"
  for arg in $EXTRA_ARGS; do set -- "$@" "$arg"; done
  # </dev/null: que rclone no consuma las líneas restantes del fichero de perfiles.
  rc=0; "$BIN" "$@" </dev/null || rc=$?
  if [ "$rc" -eq 0 ]; then
    add_profile "$local_dir" "$remote" ok 0
  else
    status=1; failed="$failed $local_dir"
    add_profile "$local_dir" "$remote" error "$rc"
  fi
  write_status running running ""
done < "$PROFILES"

if [ "$status" -eq 0 ]; then
  write_status idle ok "$(now)"
else
  write_status idle error "$(now)"
  notify "Fallo al sincronizar:$failed. Ver $LOG"
fi
exit $status
