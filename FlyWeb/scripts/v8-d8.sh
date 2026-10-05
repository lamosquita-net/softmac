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

CR_TAG=116.0.5845.188

W=${1:?uso: v8-d8.sh <carpeta> [<brave-core>]}
BC=${2:-}
mkdir -p "$W"
W=$(cd "$W" && pwd)

# V8: la de FlyWeb/v8-revision de la rama de brave-core (niveles 118+, FM.5); si no hay, la de la 116.
V8_REV=11.6.189.20
if [ -n "$BC" ] && [ -f "$BC/FlyWeb/v8-revision" ]; then
  V8_REV=$(grep -v '^#' "$BC/FlyWeb/v8-revision" | grep -m1 -o '[0-9a-f.]\{7,\}')
fi
echo "V8: $V8_REV"

if [ ! -d "$W/v8/.git" ]; then
  git init -q "$W/v8"
  case "$V8_REV" in
    *.*) git -C "$W/v8" fetch -q --depth=1 https://github.com/v8/v8 "refs/tags/$V8_REV" ;;
    *) git -C "$W/v8" fetch -q --depth=1 https://github.com/v8/v8 "$V8_REV" ;;
  esac
  git -C "$W/v8" checkout -q -b flyweb-backports FETCH_HEAD
fi

# Directorios de Chromium que la V8 trae por DEPS: los de la propia 116 (mismo build/ y misma configuración de clang).
# abseil-cpp: la piden las V8 de los niveles 118+ (11.8 en adelante).
CR_DIRS="build buildtools tools/clang base/trace_event/common third_party/zlib third_party/jinja2 third_party/markupsafe
  third_party/abseil-cpp"
if [ ! -d "$W/chromium/.git" ]; then
  git clone -q --filter=blob:none --no-checkout --depth=1 --branch "$CR_TAG" \
    https://github.com/chromium/chromium "$W/chromium"
fi
# shellcheck disable=SC2046
git -C "$W/chromium" sparse-checkout set --no-cone $(for d in $CR_DIRS; do echo "/$d/"; done)
git -C "$W/chromium" checkout -q
cd "$W/v8"
for d in $CR_DIRS; do
  if [ ! -e "$d/.flyweb-copied" ]; then
    mkdir -p "$d" && cp -a "$W/chromium/$d/." "$d/" && touch "$d/.flyweb-copied"
  fi
done
[ -f build/config/gclient_args.gni ] || echo '# FlyWeb: the V8 DEPS gclient_gn_args is empty' > build/config/gclient_args.gni

GTEST_REV=$(grep -A1 "'third_party/googletest/src'" DEPS | grep -o '[0-9a-f]\{40\}' | head -1)
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
    if grep -q '//brave/\|"brave/\|BRAVE_' "$p"; then echo "omitido (necesita brave/): $(basename "$p")"; continue; fi
    git apply "$p"
  done
fi

# Con la libstdc++ del sistema (no la libc++ de Chromium) algunos ficheros de las V8 11.8+ no incluyen <limits>.
# Arreglo solo del entorno de la d8, no forma parte de los parches de FlyWeb.
for f in src/compiler/turboshaft/utils.h; do
  if [ -f "$f" ] && ! grep -q '#include <limits>' "$f"; then
    sed -i '0,/^#include </s//#include <limits>\n#include </' "$f"
  fi
done

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
