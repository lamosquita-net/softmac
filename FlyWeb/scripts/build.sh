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
npm run build -- "$CONFIG" --target_arch=x64 \
  --gn "mac_sdk_path:$SDK" \
  --gn symbol_level:0

echo "Resultado en: $BUILD/brave-browser/src/out/$CONFIG"
