#!/bin/sh
# Compila FlyWeb (x86_64) con el SDK de macOS 13.3.
# Uso: build.sh [Static|Component|Release|Debug]   (por defecto Static)
#   Static     sin componentes y sin ThinLTO: .app autocontenido para probar en la 6,1/5,1. Uso diario.
#   Component  .dylib por componente: enlazado incremental muy rápido, solo se ejecuta en la 7,1.
#   Release    is_official_build (ThinLTO, enlazado lento y con mucha RAM): solo para publicar.
#
# Variables opcionales:
#   FLYWEB_SCCACHE=/ruta/sccache | off   caché de compilación (por defecto, sccache del PATH si existe)
#   FLYWEB_SERVICES_KEY_FILE=/ruta       clave de servicio para components.flyweb.lamosquita.net (F2.6).
#                                        Por defecto ~/proyectos/softmac/claves/flyweb-services-key, FUERA
#                                        del repo. Sin fichero se usa "flyweb" y el servidor rechaza las consultas.
#   FLYWEB_BUILD_NUMBER=N                número de esta versión de FlyWeb (1.0 = 0, 1.0.1 = 1, 1.1 = 2…). Obligatorio en
#                                        Release cuando hay clave de actualizaciones (FlyWeb/servidor/actualizaciones).
#                                        La versión visible (1.1) y el nivel de motor (117) están en brave-core,
#                                        build/config.gni (flyweb_version, flyweb_engine_level).
# Al terminar deja out/<modo>/flyweb-build-info.txt y, en builds sin firmar (no Release), las claves
# FlyWebCommit, FlyWebBraveBrowserCommit, FlyWebChromium, FlyWebBuildDate y FlyWebBuildConfig en el Info.plist.
set -eu
# Raíz del repo softmac (antes de cualquier cd).
REPO=$(cd "$(dirname "$0")/../.." && pwd)

# Con NODE_ENV=production, npm omite las devDependencies, y ahí están las herramientas de build de Brave
# (dotenv…). En la MacPro7,1 esa variable llega del entorno de la app, no del perfil del shell.
unset NODE_ENV

# depot_tools fijado al commit del DEPS de Chromium 116: con uno más reciente, su vpython ya no resuelve las
# dependencias de los hooks de la 116 (p. ej. numpy==1.21.1+supported.1). Y sin autoactualizaciones.
export DEPOT_TOOLS_UPDATE=0
DEPOT_TOOLS_PIN=fc75af35d41df6c7742caef751428aa875199990

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
DT="$BUILD/brave-browser/src/brave/vendor/depot_tools"
if [ -d "$DT/.git" ] && [ "$(git -C "$DT" rev-parse HEAD)" != "$DEPOT_TOOLS_PIN" ]; then
  echo "depot_tools no está en $DEPOT_TOOLS_PIN: lo vuelvo a fijar"
  git -C "$DT" checkout -q "$DEPOT_TOOLS_PIN"
fi

# sccache (brave-core lo lee como npm config "sccache" y lo usa de CC_WRAPPER).
SCCACHE="${FLYWEB_SCCACHE:-$(command -v sccache || true)}"
if [ -n "$SCCACHE" ] && [ "$SCCACHE" != "off" ]; then
  export npm_config_sccache="$SCCACHE"
  echo "sccache: $SCCACHE"
fi

cd "$BUILD/brave-browser"
# Si cambian los .patch de brave-core sin cambiar DEPS, basta con reaplicarlos.
npm run apply_patches
# "Revisión" de brave://version: Brave la toma del último commit de versión ("1.57.64") con el hook
# brave_lastchange de DEPS, que aquí no se ejecuta. Se pone el commit de flyweb que se compila (--filter ""
# = cualquier commit). lastchange.py solo reescribe el fichero si cambia: sin commits nuevos no recompila nada.
python3 src/build/util/lastchange.py --output src/build/util/LASTCHANGE --source-dir src/brave --filter ""
# Servicios de Brave: ver FlyWeb/docs/rebranding.md §4.
# - Componentes: nuestro servidor (components.flyweb.lamosquita.net, F2.6). Brave exige su clave privada (403).
#   Las listas de Shields son propias (FlyWeb/servidor/componentes). Los de Google (Widevine, CRLSet…) no llegan
#   mientras go-update corra con FLYWEB_NO_REDIRECT=1: decisión pendiente del HUMANO (ver componentes/README.md).
# - Sync: nuestro servidor (sync.flyweb.lamosquita.net, FlyWeb/servidor/sync; F7.5). Solo se usa si el usuario activa
#   Sincronizar; los datos van cifrados de extremo a extremo.
# - Estadísticas y variations: URL inertes (son obligatorias en Release).
# - Sparkle: solo en Release y con clave (ver más abajo). Actualizador de Brave (Omaha), P3A, Leo, VPN: desactivados.
# - Safe Browsing: NO se puede quitar al compilar en 1.57 (safe_browsing_mode:0 deja sin resolver dependencias de
#   //chrome/test:unit_tests); se apaga con FlyWeb/policies/flyweb-policies.mobileconfig.
# - Wallets y Rewards: quitados en el propio brave-core (rama nube/no-wallet), sin argumentos aquí.
UPDATER="${FLYWEB_UPDATER_URL:-https://components.flyweb.lamosquita.net/extensions}"
# Proxy propio en ns2 para Safe Browsing (y, desde brave-core, comprobación de descargas, lista de extensiones y
# diccionarios): Google ve la IP de ns2, no la del usuario, y nada pasa por Brave. FlyWeb/servidor/e0, vhost proxy.
PROXY="${FLYWEB_PROXY_HOST:-proxy.flyweb.lamosquita.net}"
# Clave de servicio (cabecera BraveServiceKey de cada consulta de componentes). Nunca se imprime.
KEYFILE="${FLYWEB_SERVICES_KEY_FILE:-$HOME/proyectos/softmac/claves/flyweb-services-key}"
if [ -r "$KEYFILE" ]; then
  SERVICES_KEY=$(tr -d ' \t\r\n' < "$KEYFILE")
  # Mismo formato que exige Apache en components. (openssl rand -hex 32)
  printf '%s' "$SERVICES_KEY" | grep -Eq '^[0-9a-f]{64}$' || {
    echo "Clave de servicio no válida en $KEYFILE (64 caracteres hexadecimales: openssl rand -hex 32)" >&2; exit 1; }
  echo "Clave de servicio: $KEYFILE"
else
  SERVICES_KEY=flyweb
  echo "AVISO: sin $KEYFILE; clave \"flyweb\": el servidor de componentes rechazará las consultas" >&2
fi
# Sincronización propia (go-sync con SQLite en ns2). go-sync atiende en /v2/command/; Chromium añade "/command/".
SYNC="${FLYWEB_SYNC_URL:-https://sync.flyweb.lamosquita.net/v2}"
INERT="https://flyweb.invalid"
# Release (is_official_build) exige que no estén vacías las claves de servicios que FlyWeb quita o desactiva
# (Rewards, cartera, Leo). Valores inertes: no llevan a ningún sitio. Solo en Release, para no recompilar Static.
if [ "$CONFIG" = "Release" ]; then
  set -- \
    --gn "brave_ai_chat_endpoint:flyweb.invalid" \
    --gn "brave_zero_ex_api_key:flyweb" --gn "sardine_client_id:flyweb" --gn "sardine_client_secret:flyweb" \
    --gn "rewards_grant_dev_endpoint:$INERT" --gn "rewards_grant_staging_endpoint:$INERT" \
    --gn "rewards_grant_prod_endpoint:$INERT" \
    --gn "bitflyer_production_client_id:flyweb" --gn "bitflyer_production_client_secret:flyweb" \
    --gn "bitflyer_production_fee_address:flyweb" --gn "bitflyer_production_url:$INERT" \
    --gn "gemini_production_api_url:$INERT" --gn "gemini_production_client_id:flyweb" \
    --gn "gemini_production_client_secret:flyweb" --gn "gemini_production_fee_address:flyweb" \
    --gn "gemini_production_oauth_url:$INERT" \
    --gn "uphold_production_api_url:$INERT" --gn "uphold_production_client_id:flyweb" \
    --gn "uphold_production_client_secret:flyweb" --gn "uphold_production_fee_address:flyweb" \
    --gn "uphold_production_oauth_url:$INERT"
  # Actualizaciones (Sparkle, solo funciona en Release): appcast propio y clave EdDSA pública de bak
  # (FlyWeb/servidor/actualizaciones; necesita brave-core paso 45). FLYWEB_BUILD_NUMBER = número de versión de FlyWeb
  # (1.0 = 0, 1.0.1 = 1…): va a CFBundleVersion (157.64.N) y cada versión publicada debe subirlo.
  EDKEY_FILE="$REPO/FlyWeb/servidor/actualizaciones/clave-publica.txt"
  EDKEY=$(tr -d ' \t\r\n' < "$EDKEY_FILE" 2>/dev/null || true)
  if printf '%s' "$EDKEY" | grep -Eq '^[A-Za-z0-9+/]{43}=$'; then
    if [ -z "${FLYWEB_BUILD_NUMBER:-}" ] || ! printf '%s' "$FLYWEB_BUILD_NUMBER" | grep -Eq '^[0-9]{1,4}$'; then
      echo "Release con actualizaciones: falta FLYWEB_BUILD_NUMBER (número de esta versión de FlyWeb, p. ej. FLYWEB_BUILD_NUMBER=1 para 1.0.1)" >&2
      exit 1
    fi
    SPARKLE=true
    set -- "$@" --gn "sparkle_eddsa_public_key:$EDKEY" --gn "flyweb_build_number:$FLYWEB_BUILD_NUMBER"
    echo "Actualizaciones: activadas (FlyWeb build $FLYWEB_BUILD_NUMBER, CFBundleVersion 157.64.$FLYWEB_BUILD_NUMBER)"
  else
    SPARKLE=false
    echo "AVISO: sin clave pública válida en $EDKEY_FILE: Release SIN actualizaciones automáticas" >&2
  fi
else
  SPARKLE=false
  set --
fi
# Commit de brave-core que se compila: «Información» enlaza a su código fuente (obligación de la MPL-2.0;
# brave-core paso 50). Sin ese paso, gn solo avisa de que el argumento no tiene efecto.
CORE_SRC_COMMIT=$(git -C src/brave rev-parse HEAD)
npm run build -- "$CONFIG" --target_arch=x64 "$@" \
  --gn "flyweb_source_commit:$CORE_SRC_COMMIT" \
  --gn "webcompat_report_api_endpoint:$INERT" \
  --gn "mac_sdk_path:$SDK" \
  --gn symbol_level:0 \
  --gn "updater_prod_endpoint:$UPDATER" \
  --gn "updater_dev_endpoint:$UPDATER" \
  --gn "safebrowsing_api_endpoint:$PROXY" \
  --gn "brave_stats_updater_url:$INERT" \
  --gn "brave_sync_endpoint:$SYNC" \
  --gn "brave_variations_server_url:$INERT" \
  --gn "brave_services_key:$SERVICES_KEY" \
  --gn "enable_sparkle:$SPARKLE" \
  --gn enable_updater:false \
  --gn brave_p3a_enabled:false \
  --gn enable_ai_chat:false \
  --gn enable_brave_vpn:false \
  --gn enable_brave_vpn_panel:false \
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

# La app principal, no los «Helper» (en Release salen todos en out/Release y find no los ordena).
APP=$(find "$OUT" -maxdepth 1 -name "*.app" -type d ! -name "* Helper*" | head -1)
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
