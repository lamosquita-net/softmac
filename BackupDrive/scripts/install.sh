#!/bin/sh
# Instala BackupDrive en este Mac (macOS 10.14+). Se ejecuta desde el zip de la CI o desde el repositorio.
#
#   install.sh              instala o actualiza: binario y motor en /usr/local/bin, LaunchAgent, app
#   install.sh --uninstall  lo quita todo salvo la configuración, los perfiles y los registros
#
# No toca backupdrive.conf ni profiles y NO activa la sincronización automática: la primera vez hay que
# hacer --resync a mano (ver los pasos que imprime al final). Pide sudo solo si /usr/local/bin no es
# escribible. Variables para pruebas: PREFIX, APPS_DIR, BACKUPDRIVE_DIR, LAUNCH_AGENTS.
set -eu

HERE=$(cd "$(dirname "$0")" && pwd)
PREFIX="${PREFIX:-/usr/local/bin}"
APP_DIR="${BACKUPDRIVE_DIR:-$HOME/Library/Application Support/BackupDrive}"
LAUNCH_AGENTS="${LAUNCH_AGENTS:-$HOME/Library/LaunchAgents}"
LABEL=net.lamosquita.backupdrive
PLIST="$LAUNCH_AGENTS/$LABEL.plist"
if [ -z "${APPS_DIR:-}" ]; then
  APPS_DIR=/Applications
  [ -w "$APPS_DIR" ] || APPS_DIR="$HOME/Applications"
fi

# Busca un fichero en la estructura del zip (todo junto) o en la del repositorio.
find_file() { # nombre, rutas relativas candidatas...
  name=$1; shift
  for rel in "$@"; do
    [ -e "$HERE/$rel" ] && { echo "$HERE/$rel"; return 0; }
  done
  echo "No encuentro $name junto a install.sh" >&2
  return 1
}

run_priv() { # ejecuta con sudo solo si hace falta
  if [ -w "$PREFIX" ] || { [ ! -e "$PREFIX" ] && [ -w "$(dirname "$PREFIX")" ]; }; then
    "$@"
  else
    sudo "$@"
  fi
}

unload_agent() {
  if command -v launchctl >/dev/null && launchctl list "$LABEL" >/dev/null 2>&1; then
    launchctl unload -w "$PLIST" 2>/dev/null || true
    echo "LaunchAgent descargado"
  fi
}

if [ "${1:-}" = "--uninstall" ]; then
  unload_agent
  rm -f "$PLIST"
  run_priv rm -f "$PREFIX/backupdrive" "$PREFIX/backupdrive-sync.sh" "$PREFIX/backupdrive-selftest.sh"
  for d in /Applications "$HOME/Applications" "$APPS_DIR"; do rm -rf "$d/BackupDrive.app"; done
  echo "BackupDrive desinstalado. Se conservan $APP_DIR y ~/Library/Logs/BackupDrive."
  exit 0
fi
[ $# -eq 0 ] || { echo "Uso: install.sh [--uninstall]" >&2; exit 2; }

BIN=$(find_file backupdrive backupdrive ../build/backupdrive)
SYNC=$(find_file backupdrive-sync.sh backupdrive-sync.sh ../scripts/backupdrive-sync.sh)
SELFTEST=$(find_file mojave-selftest.sh mojave-selftest.sh ../scripts/mojave-selftest.sh)
AGENT=$(find_file "$LABEL.plist" "$LABEL.plist" "../launchd/$LABEL.plist")
APP=$(find_file BackupDrive.app BackupDrive.app ../build/BackupDrive.app 2>/dev/null) || APP=""

# Si launchd está sincronizando ahora, no reemplazar el motor a medias.
if [ -d "$APP_DIR/run.lock" ] && kill -0 "$(cat "$APP_DIR/run.lock/pid" 2>/dev/null || echo 0)" 2>/dev/null; then
  echo "Hay una sincronización en curso; vuelve a ejecutar install.sh cuando termine." >&2
  exit 1
fi

echo "Instalando en $PREFIX"
run_priv mkdir -p "$PREFIX"
run_priv install -m 755 "$BIN" "$PREFIX/backupdrive"
run_priv install -m 755 "$SYNC" "$PREFIX/backupdrive-sync.sh"
run_priv install -m 755 "$SELFTEST" "$PREFIX/backupdrive-selftest.sh"
"$PREFIX/backupdrive" version 2>/dev/null | head -1 || echo "Aviso: el binario no arranca en este sistema" >&2

# LaunchAgent: se copia, pero solo se recarga si ya estaba activo (actualización).
was_loaded=0
command -v launchctl >/dev/null && launchctl list "$LABEL" >/dev/null 2>&1 && was_loaded=1
mkdir -p "$LAUNCH_AGENTS"
[ "$was_loaded" = 1 ] && launchctl unload "$PLIST" 2>/dev/null || true
cp "$AGENT" "$PLIST"
[ "$was_loaded" = 1 ] && launchctl load -w "$PLIST" && echo "LaunchAgent actualizado y activo"

if [ -n "$APP" ]; then
  mkdir -p "$APPS_DIR"
  rm -rf "$APPS_DIR/BackupDrive.app"
  cp -R "$APP" "$APPS_DIR/"
  # Descargada de la CI (sin firma de Apple): quitar la cuarentena solo a lo que instalamos nosotros.
  command -v xattr >/dev/null && xattr -dr com.apple.quarantine "$APPS_DIR/BackupDrive.app" 2>/dev/null || true
  echo "App: $APPS_DIR/BackupDrive.app"
else
  echo "Aviso: no hay BackupDrive.app junto a install.sh; se instala solo el motor" >&2
fi

mkdir -p "$APP_DIR"
if [ ! -f "$APP_DIR/profiles" ]; then
  cat > "$APP_DIR/profiles" <<'EOF'
# Un perfil por línea:  carpeta local|remoto:ruta
# Ejemplo:
# /Users/yo/Documents/Clientes|gdrive:Clientes
EOF
  echo "Creado $APP_DIR/profiles (vacío, con un ejemplo)"
fi

CONF="$APP_DIR/backupdrive.conf"
cat <<EOF

Instalado. Pasos siguientes:
EOF
n=1
if [ ! -f "$CONF" ]; then
  echo "  $n. Crear el remoto de Google Drive:  backupdrive --config \"$CONF\" config"; n=$((n + 1))
fi
cat <<EOF
  $n. Autodiagnóstico:                    backupdrive-selftest.sh
  $((n + 1)). Añadir perfiles:                    open -e "$APP_DIR/profiles"
  $((n + 2)). Primera sincronización, simulada:   backupdrive-sync.sh --resync --dry-run
  $((n + 3)). Primera sincronización, de verdad:  backupdrive-sync.sh --resync
  $((n + 4)). Abrir BackupDrive.app y marcar "Sincronizar cada hora"
EOF
