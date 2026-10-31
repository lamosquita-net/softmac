#!/bin/sh
# Compila FlyWeb (x86_64). Base 128 (2.x, por defecto) o 116 (1.x, FLYWEB_BASE=116).
# Uso: build.sh [Static|Component|Release|Debug]   (por defecto Static)
#   Static     sin componentes y sin ThinLTO: .app autocontenido para probar en la 6,1/5,1. Uso diario.
#   Component  .dylib por componente: enlazado incremental muy rápido, solo se ejecuta en la 7,1.
#   Release    is_official_build (ThinLTO, enlazado lento y con mucha RAM): solo para publicar.
#
# Variables:
#   FLYWEB_BASE=128|116                  base de Chromium (por defecto 128 = FlyWeb 2.x). Fija checkout, SDK y depot_tools:
#                                          128: ~/proyectos/brave-128, SDK 14.5, depot_tools 31e21628, mínimo 10.14, Metal
#                                          116: ~/proyectos/flyweb-build, SDK 13.3, depot_tools de la 116, rama flyweb
#   FLYWEB_BRANCH=rama|sha               brave-core que se compila. En 1.x, por defecto flyweb (y la misma rama en
#                                        brave-browser). En 2.x es obligatoria (p. ej. nube/base-128-motor-p19): brave-browser
#                                        no se toca (etiqueta de Brave 1.69 del checkout).
#   FLYWEB_SDK=/ruta, FLYWEB_BUILD=/ruta SDK de macOS y checkout, si no son los de la base.
#   FLYWEB_METAL_BIN=/ruta/usr/bin/      (solo 2.x) carpeta con metal y metallib para los shaders de ANGLE Metal: la del
#                                        toolchain de Xcode 15.4 (por defecto ~/proyectos/sdk/Xcode-15.4.app).
#   FLYWEB_SCCACHE=/ruta/sccache | off   caché de compilación (por defecto, sccache del PATH si existe)
#   FLYWEB_SERVICES_KEY_FILE=/ruta       clave de servicio para components.flyweb.lamosquita.net (F2.6).
#                                        Por defecto ~/proyectos/softmac/claves/flyweb-services-key, FUERA
#                                        del repo. Sin fichero se usa "flyweb" y el servidor rechaza las consultas.
#   FLYWEB_BUILD_NUMBER=N                número de esta versión de FlyWeb (1.0 = 0, 1.0.1 = 1, 1.1 = 2…). Obligatorio en
#                                        Release cuando hay clave de actualizaciones (FlyWeb/servidor/actualizaciones).
#                                        La versión visible (1.1) y el nivel de motor (117) están en brave-core,
#                                        build/config.gni (flyweb_version, flyweb_engine_level).
#   FLYWEB_EXTRA_ARGS="…"                argumentos extra para el build de Brave (ASan: "--is_asan -C StaticAsan").
#   FLYWEB_OUT=nombre                    carpeta de out/ si -C la cambia (ASan: StaticAsan); por defecto, el modo.
#   FLYWEB_SYMBOL_LEVEL=0|1|2            símbolos (por defecto 0); 1 para backtraces legibles en lldb, en un out/ aparte.
# Al terminar deja out/<modo>/flyweb-build-info.txt y, en builds sin firmar (no Release), las claves
# FlyWebCommit, FlyWebBraveBrowserCommit, FlyWebChromium, FlyWebBuildDate y FlyWebBuildConfig en el Info.plist.
set -eu
# Raíz del repo softmac (antes de cualquier cd).
REPO=$(cd "$(dirname "$0")/../.." && pwd)

# Con NODE_ENV=production, npm omite las devDependencies, y ahí están las herramientas de build de Brave
# (dotenv…). En la MacPro7,1 esa variable llega del entorno de la app, no del perfil del shell.
unset NODE_ENV

# depot_tools fijado: con uno más reciente, su vpython ya no resuelve las dependencias de los hooks
# (116: numpy==1.21.1+supported.1; 128: src/.vpython3 con el vpython de 2026). Y sin autoactualizaciones.
export DEPOT_TOOLS_UPDATE=0
BASE="${FLYWEB_BASE:-128}"
case "$BASE" in
  116)
    DEPOT_TOOLS_PIN=fc75af35d41df6c7742caef751428aa875199990
    BUILD="${FLYWEB_BUILD:-$HOME/proyectos/flyweb-build}"
    SDK="${FLYWEB_SDK:-$HOME/proyectos/sdk/MacOSX13.3.sdk}"
    BRANCH="${FLYWEB_BRANCH:-flyweb}"
    ;;
  128)
    DEPOT_TOOLS_PIN=31e21628
    BUILD="${FLYWEB_BUILD:-$HOME/proyectos/brave-128}"
    SDK="${FLYWEB_SDK:-$HOME/proyectos/sdk/MacOSX14.5.sdk}"
    BRANCH="${FLYWEB_BRANCH:-}"
    [ -n "$BRANCH" ] || { echo "2.x: falta FLYWEB_BRANCH (rama o sha de brave-core, p. ej. nube/base-128-motor-p19)" >&2; exit 1; }
    METAL_BIN="${FLYWEB_METAL_BIN:-$HOME/proyectos/sdk/Xcode-15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/}"
    [ -x "${METAL_BIN%/}/metal" ] || { echo "No hay metal en $METAL_BIN (FLYWEB_METAL_BIN)" >&2; exit 1; }
    ;;
  *) echo "FLYWEB_BASE: 128 o 116" >&2; exit 1 ;;
esac
CONFIG="${1:-Static}"

[ -d "$BUILD/brave-browser/src/brave" ] || { echo "Ejecuta antes setup-build.sh" >&2; exit 1; }
[ -d "$SDK" ] || { echo "No existe $SDK (ver setup-build.sh)" >&2; exit 1; }

# Poner el checkout de compilación en el último commit de la rama. Solo se compila lo que tiene commit.
# brave-browser: worktree del .git local. src/brave: clon --shared del .git local (ver setup-build.sh).
[ -d "$BUILD/brave-browser/src/brave/.git" ] || {
  echo "src/brave no es un clon (¿worktree antiguo o borrado?): rehacerlo con setup-build.sh" >&2; exit 1; }
# En 2.x brave-browser se queda en la etiqueta de Brave 1.69 del checkout (no tiene rama de FlyWeb).
[ "$BASE" = 116 ] && git -C "$BUILD/brave-browser" checkout -q --detach "$BRANCH"
git -C "$BUILD/brave-browser/src/brave" fetch -q origin
# Una rama de origin o un sha concreto.
CORE_REF="origin/$BRANCH"
git -C "$BUILD/brave-browser/src/brave" rev-parse -q --verify "$CORE_REF^{commit}" >/dev/null || CORE_REF="$BRANCH"
git -C "$BUILD/brave-browser/src/brave" checkout -q --detach "$CORE_REF"
for dir in "$BUILD/brave-browser" "$BUILD/brave-browser/src/brave"; do
  echo "$(basename "$dir"): $(git -C "$dir" log -1 --format='%h %s')"
done
DT="$BUILD/brave-browser/src/brave/vendor/depot_tools"
if [ -d "$DT/.git" ] && [ "$(git -C "$DT" rev-parse HEAD)" != "$(git -C "$DT" rev-parse "$DEPOT_TOOLS_PIN^{commit}" 2>/dev/null)" ]; then
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
# V8 por niveles (FM.5): cada nivel N lleva la V8 de Chrome N. La revisión la fija brave-core en
# FlyWeb/v8-revision (un commit o una etiqueta de V8, p. ej. 11.7.439.21); sin ese fichero, la de la 116
# (v8_revision de src/DEPS). Como aquí no se ejecuta gclient sync, se pone a mano antes de los parches.
V8_REV_FILE=src/brave/FlyWeb/v8-revision
if [ -f "$V8_REV_FILE" ]; then
  V8_REV=$(grep -v '^#' "$V8_REV_FILE" | head -1 | tr -d '[:space:]')
else
  V8_REV=$(sed -n "s/^ *'v8_revision': '\([0-9a-f]*\)',.*/\1/p" src/DEPS | head -1)
fi
[ -n "$V8_REV" ] || { echo "No se pudo saber la revisión de V8" >&2; exit 1; }
if ! git -C src/v8 rev-parse -q --verify "$V8_REV^{commit}" >/dev/null; then
  echo "V8: trayendo $V8_REV"
  git -C src/v8 fetch -q https://chromium.googlesource.com/v8/v8.git "$V8_REV" "+refs/tags/$V8_REV:refs/tags/$V8_REV" 2>/dev/null ||
    git -C src/v8 fetch -q https://chromium.googlesource.com/v8/v8.git "$V8_REV"
fi
V8_WANT=$(git -C src/v8 rev-parse "$V8_REV^{commit}" 2>/dev/null || git -C src/v8 rev-parse FETCH_HEAD)
if [ "$(git -C src/v8 rev-parse HEAD)" != "$V8_WANT" ]; then
  echo "V8: $(git -C src/v8 describe --tags --always HEAD) -> $V8_REV"
  # -f descarta los parches aplicados a la V8 anterior; apply_patches los vuelve a poner sobre la nueva.
  git -C src/v8 checkout -q -f --detach "$V8_WANT"
  rm -f src/brave/patches/v8/*.patchinfo
fi
echo "V8: $(git -C src/v8 describe --tags --always HEAD)"
# fast_float (V8 13.0+, nivel 130; FM.20): V8 depende de //third_party/fast_float, que la 116 no tiene. El BUILD.gn y
# el README.chromium (licencia para about:credits) los pone un parche de brave-core; el código se trae aquí, como V8,
# en el commit de src/brave/FlyWeb/fast_float-revision («<commit> <suma>»). La suma es la sha256 de las sha256 de
# include/ y las tres licencias (LC_ALL=C, en orden); si el commit o la suma no cuadran, se para. Sin el fichero
# (niveles anteriores al 130), no se hace nada.
FF_REV_FILE=src/brave/FlyWeb/fast_float-revision
if [ -f "$FF_REV_FILE" ]; then
  FF_REV=$(grep -v '^#' "$FF_REV_FILE" | awk 'NF{print $1; exit}')
  FF_SUM=$(grep -v '^#' "$FF_REV_FILE" | awk 'NF{print $2; exit}')
  [ -n "$FF_REV" ] && [ -n "$FF_SUM" ] || { echo "fast_float: $FF_REV_FILE sin commit o sin suma" >&2; exit 1; }
  FF_DIR=src/third_party/fast_float/src
  [ -d "$FF_DIR/.git" ] || { mkdir -p "$FF_DIR"; git -C "$FF_DIR" init -q; }
  if [ "$(git -C "$FF_DIR" rev-parse -q --verify 'HEAD^{commit}' 2>/dev/null || true)" != "$FF_REV" ]; then
    echo "fast_float: trayendo $FF_REV"
    git -C "$FF_DIR" fetch -q --depth 1 \
      https://chromium.googlesource.com/external/github.com/fastfloat/fast_float.git "$FF_REV"
    git -C "$FF_DIR" checkout -q -f --detach FETCH_HEAD
  fi
  [ "$(git -C "$FF_DIR" rev-parse HEAD)" = "$FF_REV" ] || { echo "fast_float: el commit no es $FF_REV" >&2; exit 1; }
  if command -v shasum >/dev/null 2>&1; then FF_SHA="shasum -a 256"; else FF_SHA=sha256sum; fi
  FF_GOT=$(cd "$FF_DIR" && git ls-files -z include LICENSE-MIT LICENSE-APACHE LICENSE-BOOST |
    LC_ALL=C sort -z | xargs -0 $FF_SHA | $FF_SHA | cut -d' ' -f1)
  [ "$FF_GOT" = "$FF_SUM" ] || { echo "fast_float: suma $FF_GOT, esperada $FF_SUM" >&2; exit 1; }
  echo "fast_float: $FF_REV (suma comprobada)"
fi
# Con una V8 más nueva que la de la 116, el código de Chromium 116 usa APIs que esa V8 marca como obsoletas;
# con -Werror serían errores. Se apagan esos avisos (v8_deprecation_warnings más abajo): solo cuentan las APIs
# que la V8 nueva ha quitado de verdad, y esas se arreglan con parches de Blink en cada nivel.
# Si cambian los .patch de brave-core sin cambiar DEPS, basta con reaplicarlos.
npm run apply_patches
# Enums numerados de Blink con los parches puestos: un valor fuera de orden delante de kNumberOfFeatures hace abortar
# a UseCounter (2.6.0, Speedometer; MOTOR-41). Corta aquí, antes de horas de compilación.
python3 "$REPO/FlyWeb/scripts/comprobar-enums.py" src
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
    --gn "uphold_production_oauth_url:$INERT" \
    --gn "service_key_aichat:flyweb" --gn "brave_services_key_id:flyweb" \
    --gn "zebpay_production_api_url:$INERT" --gn "zebpay_production_client_id:flyweb" \
    --gn "zebpay_production_client_secret:flyweb" --gn "zebpay_production_oauth_url:$INERT"
  # Las 6 últimas las exige Brave 1.69 (2.x) en oficial (LOCAL-10, FM.39); en la 1.x gn solo avisa de que no tienen efecto.
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
    echo "Actualizaciones: activadas (FlyWeb build $FLYWEB_BUILD_NUMBER, CFBundleVersion <base Brave>.$FLYWEB_BUILD_NUMBER: 157.64 en 1.x, 169.168 en 2.x)"
  else
    SPARKLE=false
    echo "AVISO: sin clave pública válida en $EDKEY_FILE: Release SIN actualizaciones automáticas" >&2
  fi
else
  SPARKLE=false
  set --
fi
# 2.x: mínimo 10.14 (la 128 sube a 10.15 por defecto) y metal/metallib del toolchain de Xcode 15.4 para ANGLE Metal
# (patches/third_party/angle/…metal-BUILD.gn.patch; sin él, ruta absoluta de otro Mac).
if [ "$BASE" = 128 ]; then
  # La Release de la 128 da ~30 avisos -Wunguarded-availability-new (APIs de 10.15 en código de Chromium) que
  # cortan el build si los avisos son errores (LOCAL-10, 26-10).
  set -- "$@" --gn mac_deployment_target:10.14 --gn mac_min_system_version:10.14 \
    --gn "flyweb_metal_bin_path:$METAL_BIN" --gn treat_warnings_as_errors:false
fi
# Argumentos extra para el build de Brave (p. ej. ASan: FLYWEB_EXTRA_ARGS="--is_asan -C StaticAsan" con
# FLYWEB_OUT=StaticAsan, para no pisar out/Static). Sin ellas, nada cambia.
if [ -n "${FLYWEB_EXTRA_ARGS:-}" ]; then
  # shellcheck disable=SC2086
  set -- "$@" $FLYWEB_EXTRA_ARGS
fi
# Commit de brave-core que se compila: «Información» enlaza a su código fuente (obligación de la MPL-2.0;
# brave-core paso 47). Sin ese paso, gn solo avisa de que el argumento no tiene efecto.
CORE_SRC_COMMIT=$(git -C src/brave rev-parse HEAD)
npm run build -- "$CONFIG" --target_arch=x64 "$@" \
  --gn "flyweb_source_commit:$CORE_SRC_COMMIT" \
  --gn "webcompat_report_api_endpoint:$INERT" \
  --gn "mac_sdk_path:$SDK" \
  --gn "symbol_level:${FLYWEB_SYMBOL_LEVEL:-0}" \
  --gn v8_deprecation_warnings:false \
  --gn v8_imminent_deprecation_warnings:false \
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

OUT="$BUILD/brave-browser/src/out/${FLYWEB_OUT:-$CONFIG}"
CORE="$BUILD/brave-browser/src/brave"
VERSION=$(node -p "require('$CORE/package.json').version")
CHROMIUM=$(node -p "require('$CORE/package.json').config.projects.chrome.tag")
CORE_COMMIT=$(git -C "$CORE" rev-parse --short=12 HEAD)
BROWSER_COMMIT=$(git -C "$BUILD/brave-browser" rev-parse --short=12 HEAD)
DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
mkdir -p "$OUT"
cat > "$OUT/flyweb-build-info.txt" <<INFO
FlyWeb $VERSION ($CONFIG)
brave-core ($BRANCH): $CORE_COMMIT
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
