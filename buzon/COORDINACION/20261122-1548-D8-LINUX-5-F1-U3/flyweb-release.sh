#!/usr/bin/env bash
# F1 de FlyWeb/docs/plataformas.md: guion único de la Release de la 3.x (Mac y Linux). BORRADOR de D8-LINUX (22-11-2026),
# sin estrenar con una compilación real. Parte de FlyWeb/tools/release-f1.sh (2.7.0) y de brave-core de la 3.2.1.
#
# Uso: flyweb-release.sh <manifiesto> comprobar|parches|gn|compilar|revisar|todo
#   comprobar  solo lee: commits y árboles, estado de brave-core, perfil PGO, RAM, intercambio y disco
#   parches    apply_patches y árbol de V8 resultante
#   gn         gn gen sin compilar, valores efectivos y diferencia con los args de referencia
#   compilar   Release con registro sin claves
#   revisar    salida, AVX, build-info y sumas
#   todo       los cinco, en ese orden, parando al primer fallo
#
# No baja fuentes, no hace checkout, no firma, no empaqueta, no sube y no publica. Vale en el bash 3.2 de macOS.
set -u -o pipefail

paro() { echo "PARO: $*" >&2; exit 1; }
paso() { echo "== $* $(date '+%T')"; }
M=${1:-}; PASO=${2:-}
[ -f "$M" ] && [ -n "$PASO" ] || paro "uso: $0 <manifiesto> comprobar|parches|gn|compilar|revisar|todo"
# El manifiesto se lee, no se ejecuta: una clave=valor por línea, sin comillas.
de() { sed -n "s/^$1=//p" "$M" | tail -1; }
pide() { [ -n "$(de "$1")" ] || paro "falta $1 en $M"; }
for k in version build src out softmac chromium_commit chromium_arbol core_commit core_arbol v8_arbol; do pide $k; done

VERSION=$(de version); BUILD=$(de build); SRC=$(de src); NOMBRE=$(de out); SM=$(de softmac)
case "$NOMBRE" in */*|.*) paro "out es un nombre dentro de src/out, sin barras";; esac
OUT=$SRC/out/$NOMBRE; CORE=$SRC/brave; L=$OUT/flyweb-release
case "$(uname -s)" in
  Darwin) SO=mac; GN=$SRC/buildtools/mac/gn;;
  Linux)  SO=linux; GN=$SRC/buildtools/linux64/gn;;
  *) paro "sistema sin receta: $(uname -s)";;
esac
J=$(de trabajos); [ -n "$J" ] || { if [ $SO = linux ]; then J=12; else J=24; fi; }
export DEPOT_TOOLS_METRICS=0 DEPOT_TOOLS_UPDATE=0
unset NODE_ENV
CLAVE=flyweb; F=$(de clave_servicios_fichero)
if [ -n "$F" ]; then [ -r "$F" ] || paro "no puedo leer clave_servicios_fichero"; CLAVE=$(tr -d ' \t\r\n' < "$F"); fi

tapar() {  # la clave de servicios no llega a ningún registro
  local l
  while IFS= read -r l || [ -n "$l" ]; do
    [ "$CLAVE" = flyweb ] || l=${l//"$CLAVE"/***}
    printf '%s\n' "$l"
  done
}
suma() { if command -v sha256sum > /dev/null; then sha256sum "$@"; else shasum -a 256 "$@"; fi; }
igual() {  # <qué> <real> <esperado, completo o prefijo de 10 o más>
  [ ${#3} -ge 10 ] || paro "$1: el valor esperado necesita 10 caracteres o más"
  case "$2" in "$3"*) echo "  $1 $3 OK";; *) paro "$1 es $2, se esperaba $3";; esac
}
identidad() {
  igual "chromium commit" "$(git -C "$SRC" rev-parse HEAD)" "$(de chromium_commit)"
  igual "chromium árbol" "$(git -C "$SRC" rev-parse 'HEAD^{tree}')" "$(de chromium_arbol)"
  igual "brave-core commit" "$(git -C "$CORE" rev-parse HEAD)" "$(de core_commit)"
  igual "brave-core árbol" "$(git -C "$CORE" rev-parse 'HEAD^{tree}')" "$(de core_arbol)"
  [ -z "$(git -C "$CORE" status --porcelain)" ] || paro "src/brave con cambios locales"
}
arbol_v8() {  # índice aparte: no toca el del checkout
  local i t
  i=$(mktemp "${TMPDIR:-/tmp}/flyweb-v8.XXXXXX") || paro "mktemp"
  t=$(export GIT_INDEX_FILE="$i.idx"; git -C "$SRC/v8" read-tree HEAD && git -C "$SRC/v8" add -A && git -C "$SRC/v8" write-tree)
  rm -f "$i" "$i.idx"
  echo "$t"
}

comprobar() {
  paso comprobar
  local c p mem swap min libre
  for c in git node npm python3 ninja autoninja; do command -v $c > /dev/null || paro "falta $c en el PATH"; done
  [ -x "$GN" ] || paro "falta $GN"
  identidad
  p=$SRC/chrome/build/$SO.pgo.txt
  [ -s "$p" ] || paro "falta $p"
  [ -s "$SRC/chrome/build/pgo_profiles/$(cat "$p")" ] || paro "falta el perfil PGO (checkout_pgo_profiles y runhooks)"
  if [ $SO = linux ]; then
    mem=$(awk '/^MemTotal:/{print int($2/1048576)}' "${FLYWEB_MEMINFO:-/proc/meminfo}")
    swap=$(awk '/^SwapTotal:/{print int($2/1048576)}' "${FLYWEB_MEMINFO:-/proc/meminfo}")
    min=$(de intercambio_min_gb); min=${min:-32}
    echo "  RAM ${mem} GiB, intercambio ${swap} GiB"
    [ "$swap" -ge "$min" ] || paro "hacen falta $min GiB de intercambio: un enlace ThinLTO de Linux pide hasta 30 GB"
  fi
  libre=$(df -Pk "$SRC" | awk 'NR==2{print int($4/1048576)}'); min=$(de disco_min_gb); min=${min:-60}
  [ "$libre" -ge "$min" ] || paro "quedan ${libre} GiB de disco y hacen falta $min"
}

parches() {
  paso parches; mkdir -p "$L"; identidad
  (cd "$CORE" && npm run apply_patches) > "$L/parches.log" 2>&1 || { tail -20 "$L/parches.log" >&2; paro "apply_patches"; }
  igual "V8 con parches" "$(arbol_v8)" "$(de v8_arbol)"
}

args_de_gn() {
  local inerte=https://flyweb.invalid c=https://components.flyweb.lamosquita.net/extensions a ed
  A=(
    "flyweb_source_commit:$(git -C "$CORE" rev-parse HEAD)" "flyweb_build_number:$BUILD" symbol_level:0
    dcheck_always_on:false treat_warnings_as_errors:false enable_precompiled_headers:false
    v8_deprecation_warnings:false v8_imminent_deprecation_warnings:false v8_enable_temporal_support:false
    "updater_prod_endpoint:$c" "updater_dev_endpoint:$c" safebrowsing_api_endpoint:proxy.flyweb.lamosquita.net
    brave_sync_endpoint:https://sync.flyweb.lamosquita.net/v2 "brave_services_key:$CLAVE"
    brave_services_key_id:flyweb service_key_aichat:flyweb brave_ai_chat_endpoint:flyweb.invalid
    enable_updater:false brave_p3a_enabled:false enable_ai_chat:false enable_brave_vpn:false
    enable_brave_vpn_panel:false enable_gemini_wallet:false
  )
  for a in brave_stats_updater_url brave_variations_server_url webcompat_report_api_endpoint zebpay_production_api_url \
    zebpay_production_oauth_url rewards_grant_dev_endpoint rewards_grant_staging_endpoint rewards_grant_prod_endpoint \
    bitflyer_production_url gemini_production_api_url gemini_production_oauth_url uphold_production_api_url \
    uphold_production_oauth_url; do A+=("$a:$inerte"); done
  for a in zebpay_production_client_id zebpay_production_client_secret brave_zero_ex_api_key sardine_client_id \
    sardine_client_secret bitflyer_production_client_id bitflyer_production_client_secret bitflyer_production_fee_address \
    gemini_production_client_id gemini_production_client_secret gemini_production_fee_address \
    uphold_production_client_id uphold_production_client_secret; do A+=("$a:flyweb"); done
  if [ $SO = mac ]; then
    pide mac_sdk; pide metal_bin
    ed=$(tr -d ' \t\r\n' < "$SM/FlyWeb/servidor/actualizaciones/clave-publica.txt")
    printf '%s' "$ed" | grep -Eq '^[A-Za-z0-9+/]{43}=$' || paro "clave pública de Sparkle no válida"
    A+=("mac_sdk_path:$(de mac_sdk)" 'mac_deployment_target:"10.14"' 'mac_min_system_version:"10.14"'
      "flyweb_metal_bin_path:$(de metal_bin)" enable_sparkle:true "sparkle_eddsa_public_key:$ed")
  else
    A+=(enable_sparkle:false)
  fi
}

brave_build() {  # <registro> [opciones de npm run build]
  local log=$1 a; shift
  args_de_gn
  local orden=(npm run build -- Release -C "$NOMBRE" --target_arch=x64)
  for a in "${A[@]}"; do orden+=(--gn "$a"); done
  orden+=("$@")
  if [ $SO = linux ] && [ -n "$(de memoria_tope)" ]; then
    orden=(systemd-run --user --scope -q -p "MemoryHigh=$(de memoria_tope)" "${orden[@]}")
  fi
  (cd "$CORE" && "${orden[@]}") 2>&1 | tapar > "$log"
}

efectivo() {  # <arg> <valor esperado>: gn args da también los que nadie pasa, como chrome_pgo_phase
  local v
  v=$("$GN" args "$OUT" "--root=$SRC" "--list=$1" --short | sed -n "s/^$1 = //p")
  [ "$v" = "$2" ] || paro "$1 vale '$v', se esperaba '$2'"
  echo "  $1 = $v OK"
}

generar() {
  paso gn; mkdir -p "$L"; identidad
  brave_build "$L/gn.log" --force_gn_gen --target build.ninja || { tail -20 "$L/gn.log" >&2; paro "gn gen"; }
  efectivo is_official_build true
  efectivo is_component_build false
  efectivo dcheck_always_on false
  efectivo chrome_pgo_phase 2
  efectivo use_thin_lto true
  efectivo enable_updater false
  efectivo flyweb_build_number "$BUILD"
  efectivo flyweb_version "\"$VERSION\""
  [ $SO = mac ] || efectivo is_cfi true
  grep -vE '_key |_secret |password|private' "$OUT/args_generated.gni" > "$L/args.gni"
  local r d; r=$(de args_referencia)
  if [ -n "$r" ]; then
    [ -r "$r" ] || paro "no puedo leer args_referencia"
    d=$(diff <(grep -vE '_key |_secret |password|private|flyweb_source_commit|flyweb_build_number|chrome_version_string' "$r" | sort) \
      <(grep -vE 'flyweb_source_commit|flyweb_build_number|chrome_version_string' "$L/args.gni" | sort)) \
      || { echo "$d" >&2; paro "los args cambian frente a args_referencia"; }
    echo "  args iguales a los de referencia"
  fi
}

compilar() {
  paso compilar
  identidad
  igual "V8 con parches" "$(arbol_v8)" "$(de v8_arbol)"
  [ -f "$L/args.gni" ] || paro "antes va el paso gn"
  rm -f "$L/compilado"
  local s; s=$(date +%s)
  brave_build "$L/build.log" --ninja "j:$J" || { grep -E ' error: |^FAILED|undefined symbol|Killed|out of memory' "$L/build.log" | sort -u | head -30 >&2; paro "la compilación (registro: $L/build.log)"; }
  echo "$(git -C "$SRC" rev-parse HEAD) $(git -C "$CORE" rev-parse HEAD) $(arbol_v8) $BUILD" > "$L/compilado"
  echo "  segundos: $(( $(date +%s) - s ))"
}

revisar() {
  paso revisar
  local hecho bin
  hecho="$(git -C "$SRC" rev-parse HEAD) $(git -C "$CORE" rev-parse HEAD) $(arbol_v8) $BUILD"
  [ "$(cat "$L/compilado" 2> /dev/null)" = "$hecho" ] || paro "out/$NOMBRE no es una compilación terminada de este manifiesto"
  if [ $SO = mac ]; then
    local p=$OUT/FlyWeb.app/Contents/Info.plist
    plist() { /usr/libexec/PlistBuddy -c "Print :$1" "$p"; }
    case "$(plist CFBundleVersion)" in *".$BUILD") ;; *) paro "CFBundleVersion no acaba en .$BUILD";; esac
    [ "$(plist CFBundleIdentifier)" = net.lamosquita.flyweb ] || paro "bundle id"
    [ "$(plist LSMinimumSystemVersion)" = 10.14 ] || paro "LSMinimumSystemVersion"
    bin=$OUT/FlyWeb.app/Contents/MacOS/FlyWeb
    [ "$(lipo -archs "$bin")" = x86_64 ] || paro "arquitectura"
  else
    bin=$OUT/brave
    for f in brave brave_sandbox chrome_crashpad_handler resources.pak brave_resources.pak icudtl.dat; do
      [ -s "$OUT/$f" ] || paro "falta out/$NOMBRE/$f"
    done
  fi
  sh "$SM/FlyWeb/scripts/check-no-avx.sh" "$OUT" brave > "$L/avx.log" 2>&1 || { tail -6 "$L/avx.log" >&2; paro "AVX"; }
  cat > "$OUT/flyweb-build-info.txt" <<INFO
FlyWeb $VERSION build $BUILD (Release, $SO x64)
brave-core:      $(git -C "$CORE" rev-parse HEAD)
Chromium:        $(git -C "$SRC" rev-parse HEAD)
V8 con parches:  $(arbol_v8)
Compilado:       $(date -u +%Y-%m-%dT%H:%M:%SZ)
INFO
  (cd "$OUT" && suma "${bin#"$OUT"/}" flyweb-build-info.txt) > "$L/SHA256SUMS" || paro "sumas"
  cat "$OUT/flyweb-build-info.txt"
  paso "FIN: sin firmar, sin empaquetar y sin publicar"
}

if [ "$PASO" != comprobar ]; then
  mkdir -p "$SRC/out"
  CERROJO=$SRC/out/.flyweb-release.lock
  mkdir "$CERROJO" 2> /dev/null || paro "cerrojo puesto: $CERROJO"
  trap 'rmdir "$CERROJO"' EXIT
  ! pgrep -x ninja > /dev/null || paro "hay otro ninja en marcha"
fi
case "$PASO" in
  comprobar) comprobar;;
  parches) parches;;
  gn) generar;;
  compilar) compilar;;
  revisar) revisar;;
  todo) comprobar; parches; generar; compilar; revisar;;
  *) paro "paso desconocido: $PASO";;
esac
