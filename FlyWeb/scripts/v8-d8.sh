#!/usr/bin/env bash
# Compila un d8 de Linux x64 con la V8 de FlyWeb (11.6.189.20, la de Chromium 116.0.5845.188), para probar portes de
# V8 en la nube sin el checkout de Chromium. Solo usa GitHub y commondatastorage (googlesource y CIPD suelen estar
# bloqueados en el contenedor). Agente SEGURIDAD, 05-10-2026.
#
# Uso: v8-d8.sh <carpeta> [<brave-core>]
#   <carpeta>     se crea si no existe; deja el árbol en <carpeta>/v8 (git, rama flyweb-backports) y d8 en out/x64.
#   <brave-core>  opcional: aplica sus patches/v8/*.patch (como el GitPatcher de Brave) antes de compilar.
# FLYWEB_D8_NO_BUILD=1 se queda en `gn gen`. La primera compilación tarda ~35 min con 4 núcleos; las siguientes son
# incrementales: `git apply` + `ninja -C out/x64 d8`.
#
# Diferencias con la V8 de FlyWeb en el Mac: Linux, dcheck_always_on (encuentra más), sin Intl (sin ICU), libstdc++ del
# sistema. Igual: compresión de punteros, sandbox, TurboFan/Maglev/Wasm, build/ y clang de Chromium 116.
# Pruebas: tools/run-tests.py --outdir=out/x64 'mjsunit/compiler/*' (aplica las // Flags: de cada fichero).
set -euo pipefail

V8_TAG=11.6.189.20
CR_TAG=116.0.5845.188
GTEST_REV=af29db7ec28d6df1c7f0f745186884091e602e07  # el del DEPS de la 11.6

W=${1:?uso: v8-d8.sh <carpeta> [<brave-core>]}
BC=${2:-}
mkdir -p "$W"
W=$(cd "$W" && pwd)

if [ ! -d "$W/v8/.git" ]; then
  git init -q "$W/v8"
  git -C "$W/v8" fetch -q --depth=1 https://github.com/v8/v8 "refs/tags/$V8_TAG"
  git -C "$W/v8" checkout -q -b flyweb-backports FETCH_HEAD
fi

# Directorios de Chromium que la V8 trae por DEPS: los de la propia 116 (mismo build/ y misma configuración de clang).
if [ ! -d "$W/chromium/build" ]; then
  git clone -q --filter=blob:none --no-checkout --depth=1 --branch "$CR_TAG" \
    https://github.com/chromium/chromium "$W/chromium"
  git -C "$W/chromium" sparse-checkout set --no-cone /build/ /buildtools/ /tools/clang/ /base/trace_event/common/ \
    /third_party/zlib/ /third_party/jinja2/ /third_party/markupsafe/
  git -C "$W/chromium" checkout -q
fi
cd "$W/v8"
for d in build buildtools tools/clang base/trace_event/common third_party/zlib third_party/jinja2 \
         third_party/markupsafe; do
  if [ ! -e "$d/.flyweb-copied" ]; then
    mkdir -p "$d" && cp -a "$W/chromium/$d/." "$d/" && touch "$d/.flyweb-copied"
  fi
done
[ -f build/config/gclient_args.gni ] || echo '# FlyWeb: the V8 DEPS gclient_gn_args is empty' > build/config/gclient_args.gni

if [ ! -d third_party/googletest/src/.git ]; then
  git init -q third_party/googletest/src
  git -C third_party/googletest/src fetch -q --depth=1 https://github.com/google/googletest "$GTEST_REV"
  git -C third_party/googletest/src checkout -q FETCH_HEAD
fi

# clang de Chromium 116 (la versión exacta de tools/clang/scripts/update.py).
rev=$(sed -n "s/^CLANG_REVISION = '\(.*\)'/\1/p" tools/clang/scripts/update.py)
sub=$(sed -n 's/^CLANG_SUB_REVISION = \([0-9]*\)/\1/p' tools/clang/scripts/update.py)
llvm=third_party/llvm-build/Release+Asserts
if [ "$(cat "$llvm/cr_build_revision" 2>/dev/null)" != "$rev-$sub" ]; then
  mkdir -p "$llvm"
  curl -fsSL "https://commondatastorage.googleapis.com/chromium-browser-clang/Linux_x64/clang-$rev-$sub.tar.xz" \
    | tar -xJ -C "$llvm"
  echo "$rev-$sub" > "$llvm/cr_build_revision"
fi

if ! command -v gn >/dev/null; then
  echo "Falta gn: sudo apt-get install -y generate-ninja (la de 2024 sirve para estos BUILD.gn)" >&2
  exit 1
fi

if [ -n "$BC" ]; then
  for p in "$BC"/patches/v8/*.patch; do
    # Los de Brave que incluyen código de brave/ (seguimiento de scripts) no compilan fuera de su checkout.
    if grep -q '//brave/\|"brave/' "$p"; then echo "omitido (necesita brave/): $(basename "$p")"; continue; fi
    git apply "$p"
  done
fi

mkdir -p out/x64
cat > out/x64/args.gn <<'EOF'
is_debug = false
dcheck_always_on = true
is_component_build = false
target_cpu = "x64"
symbol_level = 0
treat_warnings_as_errors = false
v8_enable_i18n_support = false
v8_use_external_startup_data = false
use_custom_libcxx = false
use_sysroot = false
EOF
gn gen out/x64
[ "${FLYWEB_D8_NO_BUILD:-}" = 1 ] && exit 0
ninja -C out/x64 d8
out/x64/d8 -e 'print(version())'
