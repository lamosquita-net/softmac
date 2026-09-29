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
#    "profiles":[{"local":…,"remote":…,"result":…,"exit":N,"finished":…}],"log":…}
# "profiles" lista todos los perfiles del fichero, cada uno con su último resultado (aunque esta ejecución
# no lo haya tocado, p. ej. con --profile): ok | error | skipped (carpeta inexistente o línea incompleta) |
# needs-resync (falta la primera sincronización) | never (nunca se ha ejecutado). Se guarda en state/.
# Bloqueo: si ya hay una ejecución en curso, esta sale sin hacer nada (código 0).
# Avisos: notificación de macOS si algún perfil falla (BACKUPDRIVE_NOTIFY=0 para desactivarlos).
#
# Uso: backupdrive-sync.sh [--resync] [--dry-run] [--profile <carpeta local>]
#   --resync    primera sincronización de un perfil nuevo (obligatorio la primera vez). Si un fichero
#               difiere en los dos lados gana el más reciente (--resync-mode newer), como en el uso normal;
#               sin esto rclone da siempre la razón a la copia local.
#   --profile   solo el perfil de esa carpeta local
set -eu

EXTRA_ARGS=""
ONLY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --resync) EXTRA_ARGS="$EXTRA_ARGS --resync --resync-mode newer" ;;
    --dry-run) EXTRA_ARGS="$EXTRA_ARGS --dry-run" ;;
    --profile) [ $# -ge 2 ] || { echo "--profile necesita una carpeta" >&2; exit 2; }; ONLY=$2; shift ;;
    *) echo "Opción desconocida: $1" >&2; exit 2 ;;
  esac
  shift
done

APP_DIR="${BACKUPDRIVE_DIR:-$HOME/Library/Application Support/BackupDrive}"
BIN="${BACKUPDRIVE_BIN:-/usr/local/bin/backupdrive}"
CONF="$APP_DIR/backupdrive.conf"
PROFILES="$APP_DIR/profiles"
FILTERS="$APP_DIR/filters.txt"
STATUS="$APP_DIR/status.json"
STATE_DIR="$APP_DIR/state"
LOCK="$APP_DIR/run.lock"
LOG_DIR="$HOME/Library/Logs/BackupDrive"
LOG="$LOG_DIR/backupdrive.log"

mkdir -p "$APP_DIR" "$LOG_DIR" "$STATE_DIR"
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
RUN_LOG=$(mktemp "$APP_DIR/.run-log.XXXXXX")
cleanup() { rm -rf "$LOCK" "$TMP_PROFILES" "$RUN_LOG"; }
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
state_file() { # local remote -> fichero de estado del perfil
  printf '%s|%s' "$1" "$2" | cksum | cut -d' ' -f1 | sed "s|^|$STATE_DIR/|; s|$|.json|"
}
save_profile() { # local remote result exit
  printf '{"local":%s,"remote":%s,"result":%s,"exit":%s,"finished":%s}\n' \
    "$(json_str "$1")" "$(json_str "$2")" "$(json_str "$3")" "$4" "$(json_str "$(now)")" \
    > "$(state_file "$1" "$2")"
  collect_profiles
}
collect_profiles() { # todos los perfiles del fichero, en su orden, con su último resultado
  : > "$TMP_PROFILES"
  while IFS='|' read -r l r; do
    case "$l" in ''|'#'*) continue ;; esac
    f=$(state_file "$l" "$r")
    if [ -f "$f" ]; then
      cat "$f" >> "$TMP_PROFILES"
    else
      printf '{"local":%s,"remote":%s,"result":"never","exit":0,"finished":""}\n' \
        "$(json_str "$l")" "$(json_str "$r")" >> "$TMP_PROFILES"
    fi
  done < "$PROFILES"
}
notify() {
  [ "${BACKUPDRIVE_NOTIFY:-1}" = "1" ] && command -v osascript >/dev/null || return 0
  osascript -e "display notification \"$1\" with title \"BackupDrive\"" >/dev/null 2>&1 || true
}

collect_profiles
write_status running running ""
trap 'write_status idle interrupted "$(now)"; exit 130' INT TERM

status=0
failed=""
needs_resync=""
matched=0
while IFS='|' read -r local_dir remote; do
  case "$local_dir" in ''|'#'*) continue ;; esac
  [ -z "$ONLY" ] || [ "$local_dir" = "$ONLY" ] || continue
  matched=1
  if [ -z "$remote" ]; then
    echo "Perfil incompleto: $local_dir" >&2; status=1; failed="$failed $local_dir"
    save_profile "$local_dir" "" skipped 2; write_status running running ""; continue
  fi
  if [ ! -d "$local_dir" ]; then
    echo "No existe $local_dir" >&2; status=1; failed="$failed $local_dir"
    save_profile "$local_dir" "$remote" skipped 2; write_status running running ""; continue
  fi

  echo "== $(date '+%Y-%m-%d %H:%M:%S') $local_dir <-> $remote"
  set -- --config "$CONF" bisync "$local_dir" "$remote" \
    --resilient --recover --max-lock 2h \
    --compare size,modtime --create-empty-src-dirs \
    --conflict-resolve newer --conflict-loser num \
    --drive-skip-gdocs \
    --log-file "$RUN_LOG" --log-level INFO
  [ -f "$FILTERS" ] && set -- "$@" --filters-file "$FILTERS"
  for arg in $EXTRA_ARGS; do set -- "$@" "$arg"; done
  : > "$RUN_LOG"
  # </dev/null: que rclone no consuma las líneas restantes del fichero de perfiles.
  rc=0; "$BIN" "$@" </dev/null || rc=$?
  cat "$RUN_LOG" >> "$LOG"
  if [ "$rc" -eq 0 ]; then
    save_profile "$local_dir" "$remote" ok 0
  elif grep -qiE 'cannot find prior Path1 or Path2 listings|must run --resync' "$RUN_LOG"; then
    status=1; needs_resync="$needs_resync $local_dir"
    save_profile "$local_dir" "$remote" needs-resync "$rc"
  else
    status=1; failed="$failed $local_dir"
    save_profile "$local_dir" "$remote" error "$rc"
  fi
  write_status running running ""
done < "$PROFILES"

if [ -n "$ONLY" ] && [ "$matched" = 0 ]; then
  echo "No hay ningún perfil con la carpeta $ONLY" >&2
  write_status idle error "$(now)"
  exit 2
fi

if [ "$status" -eq 0 ]; then
  write_status idle ok "$(now)"
else
  write_status idle error "$(now)"
  [ -z "$failed" ] || notify "Fallo al sincronizar:$failed. Ver $LOG"
  [ -z "$needs_resync" ] || notify "Falta la primera sincronización de:$needs_resync (menú de BackupDrive)"
fi
exit $status
