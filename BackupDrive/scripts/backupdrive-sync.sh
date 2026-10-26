#!/bin/sh
# Sincroniza cada perfil de BackupDrive con Google Drive. Pensado para launchd, pero se puede lanzar a mano.
#
# Modo predeterminado, «seguro» (Titín, 26-10): NUNCA SE PIERDE NADA.
#   - Lo nuevo o cambiado en un lado se copia al otro (gana el más reciente).
#   - Un borrado en un lado NO borra en el otro, y lo borrado no vuelve a bajar/subir mientras el otro lado no cambie.
#   - Lo que se sobrescribe se guarda en una carpeta de versiones y caduca a los N días (90 por defecto).
#   - Si un fichero cambió en los dos lados desde la última pasada, se conservan los dos
#     (el del Mac se renombra «… (conflicto Mac AAAAMMDD-HHMMSS)»).
#   Son dos «rclone copy --update» (Drive→Mac y Mac→Drive); no se usa nunca «sync» ni «--delete*».
# Modo avanzado «bisync» (opcional, por perfil): PROPAGA LOS BORRADOS en los dos sentidos.
#
# Configuración en ~/Library/Application Support/BackupDrive/:
#   backupdrive.conf   remotos (se crea con: backupdrive --config <esa ruta> config)
#   profiles           una línea por perfil:  <carpeta local>|<remoto:ruta>[|<días de versiones>[|<modo>]]
#                      (# = comentario; modo = seguro (por defecto) | bisync; días 0 = las versiones no caducan)
#   filters.txt        opcional: filtros de rclone comunes a todos los perfiles
# Versiones: en el Mac, <config>/versions/<carpeta>-<id>/; en Drive, <remoto:ruta>/.backupdrive-versions/
#   (ninguna de las dos se sincroniza). Estado de cada perfil en state/ (listas de la última pasada).
#
# Estado para la app de barra de menús: status.json en la misma carpeta (se escribe de forma atómica):
#   {"state":"running|idle","started":…,"finished":…,"result":"ok|error|running|interrupted",
#    "profiles":[{"local":…,"remote":…,"result":…,"exit":N,"finished":…,"mode":…}],"log":…}
# "profiles" lista todos los perfiles del fichero, cada uno con su último resultado (aunque esta ejecución
# no lo haya tocado, p. ej. con --profile): ok | error | skipped (carpeta inexistente o línea incompleta) |
# needs-resync (falta la primera sincronización) | never (nunca se ha ejecutado). Se guarda en state/.
# Bloqueo: si ya hay una ejecución en curso, esta sale sin hacer nada (código 0).
# Avisos: notificación de macOS si algún perfil falla (BACKUPDRIVE_NOTIFY=0 para desactivarlos).
# Registro: ~/Library/Logs/BackupDrive/backupdrive.log, rotado a 5 MB (se guardan 4 anteriores).
#
# Uso: backupdrive-sync.sh [--resync] [--dry-run] [--profile <carpeta local>]
#   --resync    primera sincronización de un perfil nuevo (obligatoria la primera vez, en los dos modos; sin
#               ella el perfil queda «needs-resync» y no se toca nada). Haz antes --resync --dry-run.
#               En bisync, si un fichero difiere en los dos lados gana el más reciente (--resync-mode newer).
#   --dry-run   no cambia nada (ni renombra, ni caduca versiones, ni guarda el estado)
#   --profile   solo el perfil de esa carpeta local
set -eu

RESYNC=0
DRY=0
ONLY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --resync) RESYNC=1 ;;
    --dry-run) DRY=1 ;;
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
VERSIONS_NAME=.backupdrive-versions
DEFAULT_DAYS=90
TAB=$(printf '\t')

mkdir -p "$APP_DIR" "$LOG_DIR" "$STATE_DIR"
[ -x "$BIN" ] || { echo "No encuentro $BIN" >&2; exit 1; }
[ -f "$CONF" ] || { echo "Falta $CONF. Créalo con: $BIN --config \"$CONF\" config" >&2; exit 1; }
[ -f "$PROFILES" ] || { echo "Falta $PROFILES (formato: carpeta|remoto:ruta[|días[|modo]])" >&2; exit 1; }

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
norm_mode() { case "$1" in bisync) echo bisync ;; *) echo seguro ;; esac; }
save_profile() { # local remote result exit mode
  printf '{"local":%s,"remote":%s,"result":%s,"exit":%s,"finished":%s,"mode":%s}\n' \
    "$(json_str "$1")" "$(json_str "$2")" "$(json_str "$3")" "$4" "$(json_str "$(now)")" \
    "$(json_str "$(norm_mode "${5:-}")")" > "$(state_file "$1" "$2")"
  collect_profiles
}
collect_profiles() { # todos los perfiles del fichero, en su orden, con su último resultado
  : > "$TMP_PROFILES"
  while IFS='|' read -r l r d m; do
    case "$l" in ''|'#'*) continue ;; esac
    f=$(state_file "$l" "$r")
    if [ -f "$f" ]; then
      cat "$f" >> "$TMP_PROFILES"
    else
      printf '{"local":%s,"remote":%s,"result":"never","exit":0,"finished":"","mode":%s}\n' \
        "$(json_str "$l")" "$(json_str "$r")" "$(json_str "$(norm_mode "$m")")" >> "$TMP_PROFILES"
    fi
  done < "$PROFILES"
}
notify() {
  [ "${BACKUPDRIVE_NOTIFY:-1}" = "1" ] && command -v osascript >/dev/null || return 0
  osascript -e "display notification \"$1\" with title \"BackupDrive\"" >/dev/null 2>&1 || true
}
log() { echo "$*"; echo "$*" >> "$LOG"; }

rc_() { "$BIN" --config "$CONF" "$@" </dev/null; }
join_remote() { # remoto:ruta + nombre
  case "$1" in *:|*/) echo "$1$2" ;; *) echo "$1/$2" ;; esac
}
cutoff_date() { # días -> AAAAMMDD de hace N días (BSD date en macOS, GNU en las pruebas)
  date -v-"$1"d +%Y%m%d 2>/dev/null || date -d "-$1 days" +%Y%m%d
}
glob_escape() { sed 's/[][*?{}\\]/\\&/g'; }

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

# Lista de un lado: ruta<TAB>tamaño<TAB>fecha (a segundos). $1 raíz, $2 salida, $3 fichero de filtros
# Un error de listado aborta el perfil (una lista vacía por error parecería «todo borrado»); una carpeta que
# aún no existe (código 3 de rclone) es una lista vacía legítima, p. ej. en Drive la primera vez.
list_side() {
  lrc=0
  rc_ lsf -R --files-only --format pst --separator "$TAB" --time-format 2006-01-02T15:04:05 \
    --drive-skip-gdocs --filter-from "$3" "$1" > "$2.raw" 2>>"$RUN_LOG" || lrc=$?
  [ "$lrc" -eq 0 ] || [ "$lrc" -eq 3 ] || return 1
  [ "$lrc" -eq 0 ] || : > "$2.raw"
  LC_ALL=C sort "$2.raw" > "$2" && rm -f "$2.raw"
}

# Compara las listas actuales con las de la última pasada y escribe en $WORK/cmp:
#   C<TAB>ruta  cambió en los dos lados  -> conflicto
#   M<TAB>ruta  borrado en el Mac y sin cambios en Drive -> no volver a bajar
#   D<TAB>ruta  borrado en Drive y sin cambios en el Mac -> no volver a subir
compare_lists() { # SM SD CM CD
  {
    sed "s/^/SM$TAB/" "$1"; sed "s/^/SD$TAB/" "$2"
    sed "s/^/CM$TAB/" "$3"; sed "s/^/CD$TAB/" "$4"
  } | awk -F'\t' -v OFS='\t' '
    { v = $3 OFS $4; if ($1 == "SM") sm[$2] = v; else if ($1 == "SD") sd[$2] = v;
      else if ($1 == "CM") cm[$2] = v; else cd[$2] = v; }
    END {
      for (p in cm) if ((p in cd) && (p in sm) && (p in sd) && cm[p] != sm[p] && cd[p] != sd[p] && cm[p] != cd[p]) print "C", p
      for (p in sd) if (!(p in cm) && (p in cd) && cd[p] == sd[p]) print "M", p
      for (p in sm) if (!(p in cd) && (p in cm) && cm[p] == sm[p]) print "D", p
    }' | LC_ALL=C sort > "$WORK/cmp"
}

# Renombra en el Mac el fichero en conflicto; así los dos se conservan y viajan a los dos lados.
rename_conflict() { # carpeta local, ruta relativa, sello
  src="$1/$2"; dir=$(dirname "$src"); name=${2##*/}
  case "$name" in
    ?*.*) base=${name%.*}; ext=.${name##*.} ;;
    *) base=$name; ext="" ;;
  esac
  dst="$dir/$base (conflicto Mac $3)$ext"
  [ -e "$dst" ] && return 1
  mv "$src" "$dst"
}

# Perfil en modo seguro. Devuelve 0 bien, 1 error, 3 falta la primera sincronización.
sync_safe() { # local remote días
  ldir=$1; rem=$2; days=$3
  id=$(profile_id "$ldir" "$rem")
  snap="$STATE_DIR/$id"
  vm="$APP_DIR/versions/$(basename "$ldir")-$id"
  vr=$(join_remote "$rem" "$VERSIONS_NAME")
  stamp=$(date +%Y%m%d-%H%M%S)

  if [ "$RESYNC" = 0 ] && [ ! -f "$snap.init" ]; then
    log "Falta la primera sincronización de $ldir (haz antes --resync --dry-run y revisa el registro)"
    return 3
  fi

  # Filtros base: nunca sincronizar la carpeta de versiones + los del usuario.
  printf -- '- /%s/**\n' "$VERSIONS_NAME" > "$WORK/base.rules"
  [ -f "$FILTERS" ] && cat "$FILTERS" >> "$WORK/base.rules"

  list_side "$ldir" "$WORK/cm" "$WORK/base.rules" || return 1
  list_side "$rem" "$WORK/cd" "$WORK/base.rules" || return 1

  : > "$WORK/cmp"
  if [ -f "$snap.mac.tsv" ] && [ -f "$snap.drive.tsv" ]; then
    compare_lists "$snap.mac.tsv" "$snap.drive.tsv" "$WORK/cm" "$WORK/cd"
  fi

  # Reglas de las pasadas: base + lo borrado en un lado, que no se restaura desde el otro.
  cp "$WORK/base.rules" "$WORK/pass.rules"
  ex=$(awk -F'\t' '$1 == "M" || $1 == "D" { n++ } END { print n + 0 }' "$WORK/cmp")
  if [ "$ex" -gt 0 ]; then
    awk -F'\t' '$1 == "M" || $1 == "D" { print $2 }' "$WORK/cmp" | glob_escape | sed 's|^|- /|' > "$WORK/tomb.rules"
    cat "$WORK/tomb.rules" "$WORK/base.rules" > "$WORK/pass.rules"
    log "Borrados en un lado que no se propagan (el otro lado los conserva): $ex"
  fi

  nconf=0
  while IFS="$TAB" read -r kind p; do
    [ "$kind" = C ] || continue
    nconf=$((nconf + 1))
    if [ "$DRY" = 1 ]; then
      log "Conflicto (simulación; se conservarían los dos): $p"
    elif rename_conflict "$ldir" "$p" "$stamp"; then
      log "Conflicto: cambió en los dos lados, se conservan los dos: $p"
    else
      log "Conflicto sin resolver (ya existe el nombre de conflicto): $p"; return 1
    fi
  done < "$WORK/cmp"

  # --update: gana el más reciente; --backup-dir/--suffix: la versión sobrescrita se guarda con la fecha.
  common="--update --create-empty-src-dirs --drive-skip-gdocs --suffix -$stamp --suffix-keep-extension \
--filter-from $WORK/pass.rules --log-file $RUN_LOG --log-level INFO"
  [ "$DRY" = 1 ] && common="$common --dry-run"
  # shellcheck disable=SC2086
  rc_ copy "$rem" "$ldir" $common --backup-dir "$vm" || return 1
  # shellcheck disable=SC2086
  rc_ copy "$ldir" "$rem" $common --backup-dir "$vr" || return 1

  [ "$DRY" = 1 ] && return 0

  expire_versions "$vm" "$days" || return 1
  expire_versions "$vr" "$days" || return 1

  # Estado de la última pasada: con filtros base (los borrados que no se propagan siguen apareciendo en un lado).
  list_side "$ldir" "$snap.mac.tsv.new" "$WORK/base.rules" || return 1
  list_side "$rem" "$snap.drive.tsv.new" "$WORK/base.rules" || return 1
  mv "$snap.mac.tsv.new" "$snap.mac.tsv"; mv "$snap.drive.tsv.new" "$snap.drive.tsv"
  : > "$snap.init"
  [ "$nconf" -eq 0 ] || notify "$nconf fichero(s) cambiaron en los dos lados: se han conservado los dos (busca «conflicto Mac»)"
  return 0
}

collect_profiles
write_status running running ""
trap 'write_status idle interrupted "$(now)"; exit 130' INT TERM

status=0
failed=""
needs_resync=""
matched=0
while IFS='|' read -r local_dir remote days mode; do
  case "$local_dir" in ''|'#'*) continue ;; esac
  [ -z "$ONLY" ] || [ "$local_dir" = "$ONLY" ] || continue
  matched=1
  mode=$(norm_mode "$mode")
  case "$days" in ''|*[!0-9]*) days=$DEFAULT_DAYS ;; esac
  if [ -z "$remote" ]; then
    echo "Perfil incompleto: $local_dir" >&2; status=1; failed="$failed $local_dir"
    save_profile "$local_dir" "" skipped 2 "$mode"; write_status running running ""; continue
  fi
  if [ ! -d "$local_dir" ]; then
    echo "No existe $local_dir" >&2; status=1; failed="$failed $local_dir"
    save_profile "$local_dir" "$remote" skipped 2 "$mode"; write_status running running ""; continue
  fi

  : > "$RUN_LOG"
  if [ "$mode" = seguro ]; then
    log "== $(date '+%Y-%m-%d %H:%M:%S') $local_dir <-> $remote (seguro, versiones $days días)$([ "$DRY" = 1 ] && echo ', SIMULACIÓN')"
    rc=0; sync_safe "$local_dir" "$remote" "$days" || rc=$?
    cat "$RUN_LOG" >> "$LOG"
    case "$rc" in
      0) save_profile "$local_dir" "$remote" ok 0 "$mode" ;;
      3) status=1; needs_resync="$needs_resync $local_dir"
         save_profile "$local_dir" "$remote" needs-resync 3 "$mode" ;;
      *) status=1; failed="$failed $local_dir"
         save_profile "$local_dir" "$remote" error "$rc" "$mode" ;;
    esac
    write_status running running ""
    continue
  fi

  # --- Modo avanzado: bisync (PROPAGA LOS BORRADOS en los dos sentidos) ---
  log "== $(date '+%Y-%m-%d %H:%M:%S') $local_dir <-> $remote (bisync: AVISO, los borrados se propagan)"
  set -- --config "$CONF" bisync "$local_dir" "$remote" \
    --resilient --recover --max-lock 2h \
    --compare size,modtime --create-empty-src-dirs \
    --conflict-resolve newer --conflict-loser num \
    --drive-skip-gdocs \
    --log-file "$RUN_LOG" --log-level INFO
  [ -f "$FILTERS" ] && set -- "$@" --filters-file "$FILTERS"
  [ "$RESYNC" = 1 ] && set -- "$@" --resync --resync-mode newer
  [ "$DRY" = 1 ] && set -- "$@" --dry-run
  # </dev/null: que rclone no consuma las líneas restantes del fichero de perfiles.
  rc=0; "$BIN" "$@" </dev/null || rc=$?
  cat "$RUN_LOG" >> "$LOG"
  if [ "$rc" -eq 0 ]; then
    save_profile "$local_dir" "$remote" ok 0 "$mode"
  elif grep -qiE 'cannot find prior Path1 or Path2 listings|must run --resync' "$RUN_LOG"; then
    status=1; needs_resync="$needs_resync $local_dir"
    save_profile "$local_dir" "$remote" needs-resync "$rc" "$mode"
  else
    status=1; failed="$failed $local_dir"
    save_profile "$local_dir" "$remote" error "$rc" "$mode"
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
