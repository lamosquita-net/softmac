#!/bin/sh
# Compila FlyWeb (Release, x86_64) con el SDK de macOS 13.3.
# Uso: build.sh [Release|Component|Debug]   (por defecto Release)
set -eu

BUILD="${FLYWEB_BUILD:-$HOME/proyectos/flyweb-build}"
SDK="${FLYWEB_SDK:-$HOME/proyectos/sdk/MacOSX13.3.sdk}"
BRANCH="${FLYWEB_BRANCH:-flyweb}"
CONFIG="${1:-Release}"

[ -d "$BUILD/brave-browser/src/brave" ] || { echo "Ejecuta antes setup-build.sh" >&2; exit 1; }
[ -d "$SDK" ] || { echo "No existe $SDK (ver setup-build.sh)" >&2; exit 1; }

# Poner los worktrees de compilación en el último commit de la rama. Solo se compila lo que tiene commit.
for dir in "$BUILD/brave-browser" "$BUILD/brave-browser/src/brave"; do
  git -C "$dir" checkout -q --detach "$BRANCH"
  echo "$(basename "$dir"): $(git -C "$dir" log -1 --format='%h %s')"
done

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

echo "Resultado en: $BUILD/brave-browser/src/out/$CONFIG"
