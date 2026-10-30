#!/usr/bin/env bash
# Compila un d8 de Linux x64 con la V8 de FlyWeb (11.6.189.20, la de Chromium 116.0.5845.188), para probar portes de
# V8 en la nube sin el checkout de Chromium. Solo usa GitHub y commondatastorage (googlesource y CIPD suelen estar
# bloqueados en el contenedor). Agente SEGURIDAD, 05-10-2026.
#
# Uso: v8-d8.sh <carpeta> [<brave-core>]
#   <carpeta>     se crea si no existe; deja el árbol en <carpeta>/v8 (git, rama flyweb-backports) y d8 en out/x64.
#   <brave-core>  opcional: aplica sus patches/v8/*.patch (como el GitPatcher de Brave) antes de compilar.
# FLYWEB_D8_NO_BUILD=1 se queda en `gn gen`. La primera compilación tarda ~35 min con 4 núcleos (13.5: 6 min 37 s con
# 32 hilos); las siguientes son incrementales. Se puede relanzar sobre un árbol ya parcheado: los parches que ya están
# se saltan y solo se aplican los nuevos. Si un parche ya aplicado ha cambiado, FLYWEB_D8_RESET=1 devuelve el árbol de
# V8 a su revisión limpia (sin tocar build/, clang ni out/) y aplica todo de nuevo.
#
# Diferencias con la V8 de FlyWeb en el Mac: Linux, dcheck_always_on (encuentra más), sin Intl (sin ICU), libstdc++ del
# sistema. Igual: compresión de punteros, sandbox, TurboFan/Maglev/Wasm, build/ y clang de la base de FlyWeb (la 128,
# o el tag de package.json de <brave-core>; con el clang 17 de la 116 la V8 13.6 da segfault al compilar, MOTOR-36).
# Si <carpeta>/v8 es de otra revisión que FlyWeb/v8-revision, la cambia (fetch + checkout limpio y parches de nuevo);
# si <carpeta>/chromium es de otro tag, lo baja de nuevo y vuelve a copiar build/, clang, etc.
# Pruebas: tools/run-tests.py --outdir=out/x64 'mjsunit/compiler/*' (aplica las // Flags: de cada fichero).
set -euo pipefail

W=${1:?uso: v8-d8.sh <carpeta> [<brave-core>]}
BC=${2:-}
mkdir -p "$W"
W=$(cd "$W" && pwd)

# Chromium de la base de FlyWeb: config.projects.chrome.tag de package.json de brave-core (128.0.6613.138 en la 2.x).
# FLYWEB_CR_TAG fuerza otro (la V8 13.7 pide el build/ de 137.0.7151.122; con el de la 128, gn falla: D8-LINUX, 30-10).
CR_TAG=${FLYWEB_CR_TAG:-128.0.6613.138}
if [ -z "${FLYWEB_CR_TAG:-}" ] && [ -n "$BC" ] && [ -f "$BC/package.json" ]; then
  CR_TAG=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["config"]["projects"]["chrome"]["tag"])' \
    "$BC/package.json")
fi
echo "Chromium (build/ y clang): $CR_TAG"

# V8: la de FlyWeb/v8-revision de la rama de brave-core (niveles 118+, FM.5); si no hay, la de la 116.
V8_REV=11.6.189.20
if [ -n "$BC" ] && [ -f "$BC/FlyWeb/v8-revision" ]; then
  V8_REV=$(grep -v '^#' "$BC/FlyWeb/v8-revision" | grep -m1 -o '[0-9a-f.]\{7,\}')
fi
echo "V8: $V8_REV"

v8_fetch() {
  case "$V8_REV" in
    *.*) git -C "$W/v8" fetch -q --depth=1 https://github.com/v8/v8 "refs/tags/$V8_REV" ;;
    *) git -C "$W/v8" fetch -q --depth=1 https://github.com/v8/v8 "$V8_REV" ;;
  esac
}
if [ ! -d "$W/v8/.git" ]; then
  git init -q "$W/v8"
  v8_fetch
  git -C "$W/v8" checkout -q -b flyweb-backports FETCH_HEAD
  echo "$V8_REV" > "$W/v8/.git/flyweb-v8-rev"
elif [ "$(cat "$W/v8/.git/flyweb-v8-rev" 2>/dev/null)" != "$V8_REV" ]; then
  # Otra revisión (o un árbol de antes de este marcador): cambio limpio. build/, third_party/*/src, clang y out/ están en
  # .gitignore y se quedan; out/x64 se compila de nuevo entero.
  echo "V8: el árbol es de $(cat "$W/v8/.git/flyweb-v8-rev" 2>/dev/null || echo 'revisión desconocida'); paso a $V8_REV"
  v8_fetch
  git -C "$W/v8" checkout -q -f -B flyweb-backports FETCH_HEAD
  git -C "$W/v8" clean -fdq
  rm -rf "$W/v8/third_party/simdutf" "$W/v8/out/x64"
  echo "$V8_REV" > "$W/v8/.git/flyweb-v8-rev"
fi

# Directorios de Chromium que la V8 trae por DEPS: los de la propia 116 (mismo build/ y misma configuración de clang).
# abseil-cpp: la piden las V8 de los niveles 118+ (11.8 en adelante).
CR_DIRS="build buildtools tools/clang base/trace_event/common third_party/zlib third_party/jinja2 third_party/markupsafe
  third_party/abseil-cpp"
if [ -d "$W/chromium/.git" ] && [ "$(cat "$W/chromium/.git/flyweb-cr-tag" 2>/dev/null)" != "$CR_TAG" ]; then
  echo "Chromium: la copia no es de $CR_TAG; la bajo de nuevo"
  rm -rf "$W/chromium"
fi
if [ ! -d "$W/chromium/.git" ]; then
  git clone -q --filter=blob:none --no-checkout --depth=1 --branch "$CR_TAG" \
    https://github.com/chromium/chromium "$W/chromium"
fi
# shellcheck disable=SC2046
git -C "$W/chromium" sparse-checkout set --no-cone $(for d in $CR_DIRS; do echo "/$d/"; done)
git -C "$W/chromium" checkout -q
echo "$CR_TAG" > "$W/chromium/.git/flyweb-cr-tag"
cd "$W/v8"
for d in $CR_DIRS; do
  if [ "$(cat "$d/.flyweb-copied" 2>/dev/null)" != "$CR_TAG" ]; then
    rm -rf "$d" && mkdir -p "$d" && cp -a "$W/chromium/$d/." "$d/" && echo "$CR_TAG" > "$d/.flyweb-copied"
  fi
done
[ -f build/config/gclient_args.gni ] || echo '# FlyWeb: the V8 DEPS gclient_gn_args is empty' > build/config/gclient_args.gni
# V8 13.x importa //third_party/icu/config.gni aunque no haya Intl: basta un stub (FS.24).
if [ ! -f third_party/icu/config.gni ]; then
  mkdir -p third_party/icu
  printf '# FlyWeb d8: stub (v8_enable_i18n_support = false)\nicu_use_data_file = false\nicu_use_stub_data = true\n' \
    > third_party/icu/config.gni
fi

GTEST_REV=$(grep -A1 "'third_party/googletest/src'" DEPS | grep -o '[0-9a-f]\{40\}' | head -1)
if [ ! -d third_party/googletest/src/.git ]; then
  git init -q third_party/googletest/src
  git -C third_party/googletest/src fetch -q --depth=1 https://github.com/google/googletest "$GTEST_REV"
  git -C third_party/googletest/src checkout -q FETCH_HEAD
fi

# highway: la piden las V8 13.3+ (third_party/highway/src del DEPS; en la 13.5, 00fe003d).
HWY_REV=$(grep -A1 "'third_party/highway/src'" DEPS | grep -o '[0-9a-f]\{40\}' | head -1 || true)
if [ -n "$HWY_REV" ] && [ ! -d third_party/highway/src/.git ]; then
  git init -q third_party/highway/src
  git -C third_party/highway/src fetch -q --depth=1 https://github.com/google/highway "$HWY_REV"
  git -C third_party/highway/src checkout -q FETCH_HEAD
fi

# FP16: la piden las V8 12.4+ (niveles 124 en adelante).
FP16_REV=$(grep -A1 "'third_party/fp16/src'" DEPS | grep -o '[0-9a-f]\{40\}' | head -1 || true)
if [ -n "$FP16_REV" ] && [ ! -d third_party/fp16/src/.git ]; then
  git init -q third_party/fp16/src
  git -C third_party/fp16/src fetch -q --depth=1 https://github.com/Maratyszcza/FP16 "$FP16_REV"
  git -C third_party/fp16/src checkout -q FETCH_HEAD
fi
# fast_float: lo piden las V8 13.x (FS.24).
FF_REV=$(grep -A1 "'third_party/fast_float/src'" DEPS | grep -o '[0-9a-f]\{40\}' | head -1 || true)
if [ -n "$FF_REV" ] && [ ! -d third_party/fast_float/src/.git ]; then
  git init -q third_party/fast_float/src
  git -C third_party/fast_float/src fetch -q --depth=1 https://github.com/fastfloat/fast_float "$FF_REV"
  git -C third_party/fast_float/src checkout -q FETCH_HEAD
fi

# clang de la base (la versión exacta de tools/clang/scripts/update.py).
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
  echo "Falta gn: paquete generate-ninja (la de 2024 sirve para estos BUILD.gn)" >&2
  exit 1
fi

# Aplica un parche solo si no está ya (para relanzar sobre un árbol parcheado).
aplicar() {
  if git apply --check "$1" 2>/dev/null; then git apply "$1"
  elif git apply -R --check "$1" 2>/dev/null; then echo "ya aplicado: $(basename "$1")"
  else echo "no aplica ni está aplicado: $1 (¿cambió? relanzar con FLYWEB_D8_RESET=1)" >&2; return 1
  fi
}

if [ "${FLYWEB_D8_RESET:-}" = 1 ]; then
  # Solo lo que siguen git y los parches: build/, third_party/*/src, clang y out/ están en .gitignore y se quedan.
  git reset -q --hard && git clean -fdq && rm -rf third_party/simdutf
fi

if [ -n "$BC" ]; then
  # simdutf: las V8 13.4+ usan //third_party/simdutf, que en el DEPS viene de googlesource (bloqueado). brave-core lo
  # trae como parches de ficheros nuevos (6.0.2, el de Chromium 134/135), que se aplican en la raíz de V8.
  if grep -q "'third_party/simdutf'" DEPS; then
    for p in "$BC"/patches/third_party-simdutf-*.patch; do [ -e "$p" ] && aplicar "$p"; done
  fi
  for p in "$BC"/patches/v8/*.patch; do
    # Los trozos que usan código de brave/ (seguimiento de scripts) no compilan fuera de su checkout: se quitan esos
    # trozos y se aplica el resto, que puede adaptar firmas que otros parches cambian (FS.38: StartDeserializeOffThread
    # en src-codegen-compiler.cc.patch; D8-LINUX, 30-10).
    if grep -q '//brave/\|"brave/\|BRAVE_' "$p"; then
      f="$W/sin-brave-$(basename "$p")"
      python3 - "$p" "$f" <<'PY'
import re, sys
pat = re.compile(r'//brave/|"brave/|BRAVE_')
out, fich, trozo = [], [], []
def cerrar_trozo():
    if trozo and not any(pat.search(l) for l in trozo): fich.extend(trozo)
    trozo.clear()
def cerrar_fich():
    cerrar_trozo()
    if any(l.startswith('@@') for l in fich): out.extend(fich)
    fich.clear()
for l in open(sys.argv[1], encoding='utf-8', errors='surrogateescape').read().splitlines(keepends=True):
    if l.startswith('diff --git '): cerrar_fich(); fich.append(l)
    elif l.startswith('@@'): cerrar_trozo(); trozo.append(l)
    elif trozo: trozo.append(l)
    else: fich.append(l)
cerrar_fich()
open(sys.argv[2], 'w', encoding='utf-8', errors='surrogateescape').write(''.join(out))
PY
      if [ -s "$f" ]; then echo "sin los trozos de brave/: $(basename "$p")"; aplicar "$f"
      else echo "omitido (todo necesita brave/): $(basename "$p")"; fi
      continue
    fi
    aplicar "$p"
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
v8_enable_fuzztest = false
enable_rust = false
EOF
# V8 13.5+: la d8 independiente usaría //third_party/partition_alloc (googlesource, no lo bajamos); FlyWeb no lo usa
# en V8 (lo pone Chromium). Las V8 anteriores no conocen el argumento.
if grep -q "v8_enable_partition_alloc" BUILD.gn; then
  echo 'v8_enable_partition_alloc = false' >> out/x64/args.gn
fi
gn gen out/x64
[ "${FLYWEB_D8_NO_BUILD:-}" = 1 ] && exit 0
ninja -C out/x64 d8
out/x64/d8 -e 'print(version())'
