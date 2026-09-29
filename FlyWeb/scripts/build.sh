#!/bin/sh
# Compila FlyWeb (x86_64) con el SDK de macOS 13.3.
# Uso: build.sh [Static|Component|Release|Debug]   (por defecto Static)
#   Static     sin componentes y sin ThinLTO: .app autocontenido para probar en la 6,1/5,1. Uso diario.
#   Component  .dylib por componente: enlazado incremental muy rápido, solo se ejecuta en la 7,1.
#   Release    is_official_build (ThinLTO, enlazado lento y con mucha RAM): solo para publicar.
#
# Variables opcionales:
#   FLYWEB_SCCACHE=/ruta/sccache | off   caché de compilación (por defecto, sccache del PATH si existe)
# Al terminar deja out/<modo>/flyweb-build-info.txt y, en builds sin firmar (no Release), las claves
# FlyWebCommit, FlyWebBraveBrowserCommit, FlyWebChromium, FlyWebBuildDate y FlyWebBuildConfig en el Info.plist.
set -eu

# Con NODE_ENV=production, npm omite las devDependencies, y ahí están las herramientas de build de Brave
# (dotenv…). En la MacPro7,1 esa variable llega del entorno de la app, no del perfil del shell.
unset NODE_ENV

BUILD="${FLYWEB_BUILD:-$HOME/proyectos/flyweb-build}"
SDK="${FLYWEB_SDK:-$HOME/proyectos/sdk/MacOSX13.3.sdk}"
BRANCH="${FLYWEB_BRANCH:-flyweb}"
CONFIG="${1:-Static}"

[ -d "$BUILD/brave-browser/src/brave" ] || { echo "Ejecuta antes setup-build.sh" >&2; exit 1; }
[ -d "$SDK" ] || { echo "No existe $SDK (ver setup-build.sh)" >&2; exit 1; }

# Poner el checkout de compilación en el último commit de la rama. Solo se compila lo que tiene commit.
# brave-browser: worktree del .git local. src/brave: clon --shared del .git local (ver setup-build.sh).
[ -d "$BUILD/brave-browser/src/brave/.git" ] || {
  echo "src/brave no es un clon (¿worktree antiguo o borrado?): rehacerlo con setup-build.sh" >&2; exit 1; }
git -C "$BUILD/brave-browser" checkout -q --detach "$BRANCH"
git -C "$BUILD/brave-browser/src/brave" fetch -q origin
git -C "$BUILD/brave-browser/src/brave" checkout -q --detach "origin/$BRANCH"
for dir in "$BUILD/brave-browser" "$BUILD/brave-browser/src/brave"; do
  echo "$(basename "$dir"): $(git -C "$dir" log -1 --format='%h %s')"
done

# sccache (brave-core lo lee como npm config "sccache" y lo usa de CC_WRAPPER).
SCCACHE="${FLYWEB_SCCACHE:-$(command -v sccache || true)}"
if [ -n "$SCCACHE" ] && [ "$SCCACHE" != "off" ]; then
  export npm_config_sccache="$SCCACHE"
  echo "sccache: $SCCACHE"
fi

cd "$BUILD/brave-browser"
# Si cambian los .patch de brave-core sin cambiar DEPS, basta con reaplicarlos.
npm run apply_patches
# Servicios de Brave: ver FlyWeb/docs/rebranding.md §4.
# - Componentes (listas de Shields, Widevine): se mantienen los servidores de Brave (decisión "a").
# - Sync, estadísticas y variations: URL inertes (son obligatorias en Release).
# - Sparkle, actualizador, P3A, Leo, VPN, Safe Browsing (necesita clave de Google), wallets: desactivados.
UPDATER="${FLYWEB_UPDATER_URL:-https://go-updater.brave.com/extensions}"
INERT="https://flyweb.invalid"
npm run build -- "$CONFIG" --target_arch=x64 \
  --gn "mac_sdk_path:$SDK" \
  --gn symbol_level:0 \
  --gn "updater_prod_endpoint:$UPDATER" \
  --gn "updater_dev_endpoint:$UPDATER" \
  --gn "brave_stats_updater_url:$INERT" \
  --gn "brave_sync_endpoint:$INERT" \
  --gn "brave_variations_server_url:$INERT" \
  --gn brave_services_key:flyweb \
  --gn enable_sparkle:false \
  --gn enable_updater:false \
  --gn brave_p3a_enabled:false \
  --gn enable_ai_chat:false \
  --gn enable_brave_vpn:false \
  --gn enable_brave_vpn_panel:false \
  --gn safe_browsing_mode:0 \
  --gn ethereum_remote_client_enabled:false \
  --gn enable_gemini_wallet:false

OUT="$BUILD/brave-browser/src/out/$CONFIG"
CORE="$BUILD/brave-browser/src/brave"
VERSION=$(node -p "require('$CORE/package.json').version")
CHROMIUM=$(node -p "require('$CORE/package.json').config.projects.chrome.tag")
CORE_COMMIT=$(git -C "$CORE" rev-parse --short=12 HEAD)
BROWSER_COMMIT=$(git -C "$BUILD/brave-browser" rev-parse --short=12 HEAD)
DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
mkdir -p "$OUT"
cat > "$OUT/flyweb-build-info.txt" <<INFO
FlyWeb $VERSION ($CONFIG)
brave-core (flyweb): $CORE_COMMIT
brave-browser:       $BROWSER_COMMIT
Chromium:            $CHROMIUM
Compilado:           $DATE en $(hostname -s)
INFO

APP=$(find "$OUT" -maxdepth 1 -name "*.app" -type d | head -1)
if [ -n "$APP" ] && [ "$CONFIG" != "Release" ]; then
  # Solo en builds sin firmar: editar el Info.plist invalidaría la firma de un Release.
  PLIST="$APP/Contents/Info.plist"
  for kv in "FlyWebCommit:$CORE_COMMIT" "FlyWebBraveBrowserCommit:$BROWSER_COMMIT" \
            "FlyWebChromium:$CHROMIUM" "FlyWebBuildDate:$DATE" "FlyWebBuildConfig:$CONFIG"; do
    key=${kv%%:*}; val=${kv#*:}
    /usr/libexec/PlistBuddy -c "Delete :$key" "$PLIST" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :$key string $val" "$PLIST"
  done
fi

cat "$OUT/flyweb-build-info.txt"
echo "Resultado en: ${APP:-$OUT}"
