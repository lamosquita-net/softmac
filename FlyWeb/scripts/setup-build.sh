#!/bin/sh
# Prepara el checkout de compilación de FlyWeb en la MacPro7,1 (una sola vez).
#
#   ~/proyectos/flyweb-build/brave-browser/            worktree de brave-browser.git (commit de "flyweb")
#   ~/proyectos/flyweb-build/brave-browser/src/        Chromium 116 (gclient, ~100 GB)
#   ~/proyectos/flyweb-build/brave-browser/src/brave/  clon --shared de brave-core.git (commit de "flyweb")
#
# brave-browser es un worktree "detached"; src/brave es un CLON --shared (con carpeta .git real, sin copiar
# objetos), no un worktree: gclient decide qué es un repo mirando si existe la carpeta .git, y con un
# worktree (.git es un fichero) "gclient sync -D" lo borró y clonó el Brave original. build.sh hace
# "git fetch" de ese clon desde el .git local antes de compilar. NUNCA usar "gclient sync -D" aquí.
set -eu

# Con NODE_ENV=production, npm omite las devDependencies, y ahí están las herramientas de build de Brave
# (dotenv…). En la MacPro7,1 esa variable llega del entorno de la app, no del perfil del shell.
unset NODE_ENV

BUILD="${FLYWEB_BUILD:-$HOME/proyectos/flyweb-build}"
GITDIRS="${FLYWEB_GITDIRS:-$HOME/proyectos/softmac/FlyWeb}"
SDK="${FLYWEB_SDK:-$HOME/proyectos/sdk/MacOSX13.3.sdk}"
BRANCH="${FLYWEB_BRANCH:-flyweb}"

die() { echo "ERROR: $*" >&2; exit 1; }

for tool in git node npm python3; do
  command -v "$tool" >/dev/null || die "falta '$tool' en el PATH"
done
xcode-select -p >/dev/null 2>&1 || die "faltan las Command Line Tools (xcode-select --install)"

[ -d "$SDK" ] || die "no existe $SDK
  1. Descarga Xcode_14.3.1.xip de https://developer.apple.com/download/all/
  2. xip -x Xcode_14.3.1.xip   (en una carpeta temporal)
  3. mkdir -p $(dirname "$SDK") && cp -R Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX13.3.sdk $(dirname "$SDK")/
  4. Borra Xcode.app y el .xip: solo hace falta el SDK."

for repo in brave-browser brave-core; do
  git --git-dir="$GITDIRS/$repo.git" rev-parse --verify -q "$BRANCH" >/dev/null \
    || die "$GITDIRS/$repo.git no tiene la rama '$BRANCH'"
done

mkdir -p "$BUILD"
avail_gb=$(df -g "$BUILD" | awk 'NR==2 {print $4}')
[ "$avail_gb" -ge 200 ] || die "solo hay ${avail_gb} GB libres en $BUILD; hacen falta unos 200 GB"

if [ ! -e "$BUILD/brave-browser/.git" ]; then
  git --git-dir="$GITDIRS/brave-browser.git" worktree add --detach "$BUILD/brave-browser" "$BRANCH"
fi
mkdir -p "$BUILD/brave-browser/src"
# scripts/init.js no clona brave-core si src/brave/.git ya existe.
if [ ! -d "$BUILD/brave-browser/src/brave/.git" ]; then
  git clone -q --shared --no-checkout "$GITDIRS/brave-core.git" "$BUILD/brave-browser/src/brave"
  git -C "$BUILD/brave-browser/src/brave" checkout -q --detach "origin/$BRANCH"
fi

cd "$BUILD/brave-browser"
npm install
# Descarga depot_tools y Chromium 116.0.5845.188 (fijado en src/brave/package.json). Tarda horas.
npm run init -- --target_os=mac --target_arch=x64

echo "Listo. Compila con: $(dirname "$0")/build.sh"
