#!/bin/sh
# Sincroniza cada perfil de BackupDrive con Google Drive. Pensado para launchd, pero se puede lanzar a mano.
#
# Diseño (Titín, 26-10): «nunca perder nada». Es `rclone bisync` (1.67) bien configurado, sin reinventarlo:
#   - Cambio por lado contra el estado de la última pasada (listas de bisync), por tamaño + fecha + hash (MD5 de Drive;
#     en local solo para lo que cambió). Nunca se decide por «el más reciente» entre los dos lados.
#     Cambió un lado → se copia; cambiaron los dos y son distintos → conflicto: se conservan LOS DOS
#     (--conflict-resolve none renombra cada uno con sufijo y los copia a los dos lados).
#   - Un borrado deliberado en un lado mueve la copia del otro lado a la carpeta de versiones (--backup-dir1/2);
#     lo que se sobrescribe también va allí. Las versiones caducan a los N días (90 por defecto) por la fecha del nombre.
#   - Freno: si una pasada fuera a borrar más del 10 % de los ficheros de un lado (disco desmontado, carpeta vacía),
#     se detiene sin tocar nada (--max-delete). bisync también se niega a sincronizar con un lado vacío.
#   - Estado perdido o corrupto: la pasada siguiente solo copia y nunca borra (un --resync automático, con backup).
#   - Documentos nativos de Google (Docs, Hojas): se saltan (--drive-skip-gdocs).
#
# Configuración en ~/Library/Application Support/BackupDrive/:
#   backupdrive.conf   remotos (se crea con: backupdrive --config <esa ruta> config)
#   profiles           una línea por perfil:  <carpeta local>|<remoto:ruta>[|<días de versiones>]
#                      (# = comentario; días 0 = las versiones no caducan; el remoto debe llevar una carpeta, no la raíz)
#   filters.txt        opcional: filtros de rclone comunes a todos los perfiles
# Versiones: en el Mac, <config>/versions/<carpeta>-<id>/; en Drive, la carpeta «<remoto:ruta> (versiones)» al lado de la
#   sincronizada (bisync exige que no estén dentro). Estado de bisync en <config>/bisync/; resultado por perfil en state/.
#
# Estado para la app de barra de menús: status.json en la misma carpeta (se escribe de forma atómica):
#   {"state":"running|idle","started":…,"finished":…,"result":"ok|error|running|interrupted",
#    "profiles":[{"local":…,"remote":…,"result":…,"exit":N,"finished":…}],"log":…}
# "profiles" lista todos los perfiles del fichero, cada uno con su último resultado (aunque esta ejecución
# no lo haya tocado, p. ej. con --profile): ok | error | skipped (carpeta inexistente o línea incompleta) |
# needs-resync (falta la primera sincronización) | blocked (el freno de borrados se activó) | never (nunca se ha ejecutado).
# Bloqueo: si ya hay una ejecución en curso, esta sale sin hacer nada (código 0).
# Avisos: notificación de macOS si algún perfil falla (BACKUPDRIVE_NOTIFY=0 para desactivarlos).
# Registro: ~/Library/Logs/BackupDrive/backupdrive.log, rotado a 5 MB (se guardan 4 anteriores).
#
# Uso: backupdrive-sync.sh [--resync] [--dry-run] [--force] [--profile <carpeta local>]
#   --resync    primera sincronización de un perfil nuevo (obligatoria la primera vez; sin ella el perfil queda
#               «needs-resync» y no se toca nada). Haz antes --resync --dry-run. Solo copia, nunca borra; si un
#               fichero difiere en los dos lados no hay historia que consultar y se usa el más reciente (--resync-mode
#               newer), pero el perdedor se guarda en versiones.
#   --dry-run   no cambia nada (ni caduca versiones)
#   --force     salta el freno de borrados (solo tras revisar con --dry-run que los borrados son lo que quieres)
#   --profile   solo el perfil de esa carpeta local
set -eu

RESYNC=0
DRY=0
FORCE=0
ONLY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --resync) RESYNC=1 ;;
    --dry-run) DRY=1 ;;
    --force) FORCE=1 ;;
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
LOG_DIR="${BACKUPDRIVE_LOG_DIR:-$HOME/Library/Logs/BackupDrive}"
LOG="$LOG_DIR/backupdrive.log"
LOG_MAX=${BACKUPDRIVE_LOG_MAX:-5242880}
DEFAULT_DAYS=90
MAX_DELETE=${BACKUPDRIVE_MAX_DELETE:-10}
BISYNC_DIR="$APP_DIR/bisync"

mkdir -p "$APP_DIR" "$LOG_DIR" "$STATE_DIR" "$BISYNC_DIR"
[ -x "$BIN" ] || { echo "No encuentro $BIN" >&2; exit 1; }
[ -f "$CONF" ] || { echo "Falta $CONF. Créalo con: $BIN --config \"$CONF\" config" >&2; exit 1; }
[ -f "$PROFILES" ] || { echo "Falta $PROFILES (formato: carpeta|remoto:ruta[|días])" >&2; exit 1; }

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

# --- Registro rotado: backupdrive.log -> .1 -> … -> .4 ---
if [ -f "$LOG" ] && [ "$(wc -c < "$LOG")" -gt "$LOG_MAX" ]; then
  i=3
  while [ $i -ge 1 ]; do
    [ -f "$LOG.$i" ] && mv -f "$LOG.$i" "$LOG.$((i + 1))"
    i=$((i - 1))
  done
  mv -f "$LOG" "$LOG.1"
fi

TMP_PROFILES=$(mktemp "$APP_DIR/.profiles.XXXXXX")
RUN_LOG=$(mktemp "$APP_DIR/.run-log.XXXXXX")
WORK=$(mktemp -d "$APP_DIR/.work.XXXXXX")
cleanup() { rm -rf "$LOCK" "$TMP_PROFILES" "$RUN_LOG" "$WORK"; }
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
profile_id() { # local remote -> identificador numérico del perfil
  printf '%s|%s' "$1" "$2" | cksum | cut -d' ' -f1
}
state_file() { # local remote -> fichero de estado del perfil
  echo "$STATE_DIR/$(profile_id "$1" "$2").json"
}
save_profile() { # local remote result exit
  printf '{"local":%s,"remote":%s,"result":%s,"exit":%s,"finished":%s}\n' \
    "$(json_str "$1")" "$(json_str "$2")" "$(json_str "$3")" "$4" "$(json_str "$(now)")" \
    > "$(state_file "$1" "$2")"
  collect_profiles
}
collect_profiles() { # todos los perfiles del fichero, en su orden, con su último resultado
  : > "$TMP_PROFILES"
  while IFS='|' read -r l r d; do
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
log() { echo "$*"; echo "$*" >> "$LOG"; }

rc_() { "$BIN" --config "$CONF" "$@" </dev/null; }
cutoff_date() { # días -> AAAAMMDD de hace N días (BSD date en macOS, GNU en las pruebas)
  date -v-"$1"d +%Y%m%d 2>/dev/null || date -d "-$1 days" +%Y%m%d
}

# Caduca las versiones de $1 (carpeta o remoto) más viejas que $2 días. La fecha sale del NOMBRE
# (…-AAAAMMDD-HHMMSS[.ext]), no de la fecha del fichero: rclone conserva la fecha de modificación original al
# mover a la carpeta de versiones, y un fichero viejo sobrescrito hoy no debe caducar hoy. Lo que no
# lleva fecha en el nombre no se toca. Solo borra dentro de la carpeta de versiones.
expire_versions() { # raíz de versiones, días
  [ "$2" -gt 0 ] || return 0
  cut=$(cutoff_date "$2")
  rc_ lsf -R --files-only "$1" > "$WORK/ver.all" 2>/dev/null || return 0
  awk -v cut="$cut" '
    match($0, /-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9](\.[^.\/]*)?$/) {
      if (substr($0, RSTART + 1, 8) + 0 < cut + 0) print
    }' "$WORK/ver.all" > "$WORK/ver.old"
  n=$(wc -l < "$WORK/ver.old" | tr -d ' ')
  [ "$n" -gt 0 ] || return 0
  log "Versiones caducadas (más de $2 días): $n en $1"
  [ "$DRY" = 1 ] && return 0
  # En Drive se borran de verdad (no a la papelera): son nuestras versiones y la papelera ocuparía cuota.
  rc_ delete "$1" --files-from-raw "$WORK/ver.old" --rmdirs --drive-use-trash=false \
    --log-file "$RUN_LOG" --log-level INFO || return 1
  rc_ rmdirs "$1" --leave-root --log-file "$RUN_LOG" --log-level INFO 2>/dev/null || true
}

# Carpeta de versiones de Drive: al lado de la sincronizada (nunca dentro: bisync lo prohíbe).
versions_remote() {
  r=${1%/}
  case "$r" in *:|'') return 1 ;; esac
  echo "$r (versiones)"
}

# bisync de un perfil. Devuelve 0 bien, 1 error, 3 falta la primera sincronización, 4 frenado por borrados.
sync_profile() { # local remote días
  ldir=$1; rem=$2; days=$3
  id=$(profile_id "$ldir" "$rem")
  init="$STATE_DIR/$id.init"
  vm="$APP_DIR/versions/$(basename "$ldir")-$id"
  vr=$(versions_remote "$rem") || { log "El remoto $rem debe llevar una carpeta (no la raíz): la carpeta de versiones va al lado"; return 1; }
  stamp=$(date +%Y%m%d-%H%M%S)

  if [ "$RESYNC" = 0 ] && [ ! -f "$init" ]; then
    log "Falta la primera sincronización de $ldir (haz antes --resync --dry-run y revisa el registro)"
    return 3
  fi

  # Mismos ajustes en todas las pasadas; la carpeta de versiones de Drive nunca está dentro de la sincronizada.
  set -- --config "$CONF" bisync "$ldir" "$rem" --workdir "$BISYNC_DIR" \
    --compare size,modtime,checksum --slow-hash-sync-only --create-empty-src-dirs \
    --resilient --recover --max-lock 2h --max-delete "$MAX_DELETE" --conflict-resolve none \
    --backup-dir1 "$vm" --backup-dir2 "$vr" --suffix "-$stamp" --suffix-keep-extension \
    --drive-skip-gdocs --log-file "$RUN_LOG" --log-level INFO
  [ -f "$FILTERS" ] && set -- "$@" --filters-file "$FILTERS"
  [ "$DRY" = 1 ] && set -- "$@" --dry-run
  [ "$FORCE" = 1 ] && set -- "$@" --force
  if [ "$RESYNC" = 1 ]; then
    # Solo copia. Sin historia no se puede decidir de otra forma; el perdedor queda en versiones.
    set -- "$@" --resync --resync-mode newer
  fi
  : > "$RUN_LOG"
  # </dev/null: que rclone no consuma las líneas restantes del fichero de perfiles.
  prc=0; "$BIN" "$@" </dev/null || prc=$?
  if [ "$prc" -ne 0 ] && [ "$RESYNC" = 0 ] && [ "$DRY" = 0 ] && [ -f "$init" ] \
     && grep -qiE 'cannot find prior Path1 or Path2 listings|must run --resync' "$RUN_LOG"; then
    # Estado perdido o corrupto con el perfil ya iniciado: una pasada que solo copia y no borra nada.
    log "Se perdió el estado de bisync de $ldir: pasada de recuperación (solo copia, nada se borra)"
    cat "$RUN_LOG" >> "$LOG"
    set -- "$@" --resync --resync-mode newer
    : > "$RUN_LOG"
    prc=0; "$BIN" "$@" </dev/null || prc=$?
  fi
  if [ "$prc" -ne 0 ]; then
    grep -qiE 'too many deletes|max-delete|exceeds' "$RUN_LOG" && return 4
    return "$prc"
  fi
  [ "$DRY" = 1 ] && return 0
  [ "$RESYNC" = 0 ] || : > "$init"

  expire_versions "$vm" "$days" || return 1
  expire_versions "$vr" "$days" || return 1
  return 0
}

collect_profiles
write_status running running ""
trap 'write_status idle interrupted "$(now)"; exit 130' INT TERM

status=0
failed=""
needs_resync=""
blocked=""
matched=0
while IFS='|' read -r local_dir remote days; do
  case "$local_dir" in ''|'#'*) continue ;; esac
  [ -z "$ONLY" ] || [ "$local_dir" = "$ONLY" ] || continue
  matched=1
  case "$days" in ''|*[!0-9]*) days=$DEFAULT_DAYS ;; esac
  if [ -z "$remote" ]; then
    echo "Perfil incompleto: $local_dir" >&2; status=1; failed="$failed $local_dir"
    save_profile "$local_dir" "" skipped 2; write_status running running ""; continue
  fi
  if [ ! -d "$local_dir" ]; then
    echo "No existe $local_dir" >&2; status=1; failed="$failed $local_dir"
    save_profile "$local_dir" "$remote" skipped 2; write_status running running ""; continue
  fi

  log "== $(date '+%Y-%m-%d %H:%M:%S') $local_dir <-> $remote (versiones $days días)$([ "$DRY" = 1 ] && echo ', SIMULACIÓN')"
  : > "$RUN_LOG"
  rc=0; sync_profile "$local_dir" "$remote" "$days" || rc=$?
  cat "$RUN_LOG" >> "$LOG"
  case "$rc" in
    0) save_profile "$local_dir" "$remote" ok 0 ;;
    3) status=1; needs_resync="$needs_resync $local_dir"
       save_profile "$local_dir" "$remote" needs-resync 3 ;;
    4) status=1; blocked="$blocked $local_dir"
       log "FRENADO: la pasada borraría más del $MAX_DELETE % de los ficheros de $local_dir; no se ha tocado nada. Si es lo que quieres: backupdrive-sync.sh --profile \"$local_dir\" --dry-run y luego --force"
       save_profile "$local_dir" "$remote" blocked 4 ;;
    *) status=1; failed="$failed $local_dir"
       save_profile "$local_dir" "$remote" error "$rc" ;;
  esac
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
  [ -z "$blocked" ] || notify "Frenado por seguridad (demasiados borrados):$blocked. No se ha tocado nada."
  [ -z "$needs_resync" ] || notify "Falta la primera sincronización de:$needs_resync (menú de BackupDrive)"
fi
exit $status
