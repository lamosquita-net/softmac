#!/bin/sh
# Ejecuta "bisync" para cada perfil de BackupDrive. Pensado para launchd, pero se puede lanzar a mano.
#
# Configuración en ~/Library/Application Support/BackupDrive/:
#   backupdrive.conf   remotos (se crea con: backupdrive --config <esa ruta> config)
#   profiles           una línea por perfil:  <carpeta local>|<remoto:ruta>   (# = comentario)
#   filters.txt        opcional: filtros de rclone comunes a todos los perfiles
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
LOG_DIR="$HOME/Library/Logs/BackupDrive"

mkdir -p "$APP_DIR" "$LOG_DIR"
[ -x "$BIN" ] || { echo "No encuentro $BIN" >&2; exit 1; }
[ -f "$CONF" ] || { echo "Falta $CONF. Créalo con: $BIN --config \"$CONF\" config" >&2; exit 1; }
[ -f "$PROFILES" ] || { echo "Falta $PROFILES (formato: carpeta|remoto:ruta)" >&2; exit 1; }

status=0
while IFS='|' read -r local_dir remote; do
  case "$local_dir" in ''|'#'*) continue ;; esac
  [ -n "$remote" ] || { echo "Perfil incompleto: $local_dir" >&2; status=1; continue; }
  [ -d "$local_dir" ] || { echo "No existe $local_dir" >&2; status=1; continue; }

  echo "== $(date '+%Y-%m-%d %H:%M:%S') $local_dir <-> $remote"
  set -- --config "$CONF" bisync "$local_dir" "$remote" \
    --resilient --recover --max-lock 2h \
    --compare size,modtime --create-empty-src-dirs \
    --conflict-resolve newer --conflict-loser num \
    --drive-skip-gdocs \
    --log-file "$LOG_DIR/backupdrive.log" --log-level INFO
  [ -f "$FILTERS" ] && set -- "$@" --filters-file "$FILTERS"
  for arg in $EXTRA_ARGS; do set -- "$@" "$arg"; done
  "$BIN" "$@" || status=1
done < "$PROFILES"
exit $status
