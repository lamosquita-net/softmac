#!/bin/zsh
# LOCAL-20, 06-11: H4 de FM.54 F1 = la 2.7.0 compilada desde el árbol propio (paso de COORDINACIÓN-31, buzón 1959).
# Calcado de temp/local16/release-270.sh (misma Release, mismos args de gn), con estas diferencias:
#   - checkout ~/proyectos/flynk-f1 (copia APFS de brave-128, out/Release incluido: incremental);
#   - brave-core = rama del corte local/fm54-f1 (sin .patch de src/v8 ni v8-revision);
#   - src y src/v8 = flynk y flynk-v8 (reconvertidas), prestadas del repo bare local, no parcheadas;
#   - sin los arreglos a mano de release-270.sh (css_*, common.sb, V8 por v8-revision): el árbol ya es el final;
#   - a los ficheros con el mismo contenido que en brave-128 se les devuelve su fecha (touch -r) para que ninja
#     no recompile por el checkout; brave-128 solo se lee;
#   - avisa si los args de gn cambian frente a la 2.7.0 (args_generated.gni) y no publica: deja la .app en entregas.
# No se publica nada.
set -u
CORE_REF=local/fm54-f1; BUILDNO=40
B=~/proyectos/flynk-f1/brave-browser; S=$B/src; O=$S/out/Release; T=${0:A:h}; L=$T/release-f1-build.log
R128=~/proyectos/brave-128/brave-browser/src
F=~/proyectos/flynk
XBIN=$HOME/proyectos/sdk/Xcode-15.4.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/
K=~/proyectos/flyweb-build/temp/LOCK; SDK=~/proyectos/sdk/MacOSX14.5.sdk
SM=~/proyectos/softmac/temp/local20/wt; E=/Volumes/googledrive/clientes/software/entregas/FlyWeb-2.7.0-flynk-f1
[ -e $K ] && { echo "PARO: cerrojo ya puesto: $(cat $K)"; exit 1; }
[ "$(ps -Ao command | grep -E 'build\.sh|autoninja|/ninja |release-.*\.sh' | grep -v grep | grep -vc release-f1.sh)" -gt 0 ] && { echo "PARO: hay otra compilación en marcha"; exit 1; }
[ "$(ps -Ao command | grep -iE 'headless|motionmark|speedometer|jetstream' | grep -vc grep)" -gt 0 ] && { echo "PARO: hay benchmarks en marcha"; exit 1; }
[ -e $E ] && { echo "PARO: ya existe $E"; exit 1; }
mkdir -p ${K:h}
echo "LOCAL-20 (Compilación Local (20)), Release 2.7.0 desde el árbol flynk (FM.54 F1, H4), ~/proyectos/flynk-f1 out/Release, desde $(date '+%d-%m %H:%M'), PID $$" > $K; trap 'rm -f $K' EXIT
export DEPOT_TOOLS_METRICS=0 DEPOT_TOOLS_UPDATE=0; unset NODE_ENV
paso() { echo "== $1 $(date '+%T')"; }
[ -z "$(git -C $S/brave status --porcelain)" ] || { echo "PARO: src/brave con cambios locales"; exit 1; }

paso "brave-core a $CORE_REF"
git -C $S/brave fetch -q origin || { echo "PARO: fetch de brave-core"; exit 1; }
git -C $S/brave checkout -q --detach origin/$CORE_REF || { echo "PARO: checkout de brave-core"; exit 1; }
SHA=$(git -C $S/brave rev-parse HEAD)
echo "brave-core: $(git -C $S/brave log -1 --format='%h %s')"
[ -f $S/brave/FlyWeb/v8-revision ] && { echo "PARO: brave-core aún tiene FlyWeb/v8-revision"; exit 1; }

# Mismo método que build.sh (traer_flynk) para origen local.
prestar() {  # <repo> <bare> <rama>
  local GD=$(git -C $1 rev-parse --path-format=absolute --git-common-dir)
  touch $GD/objects/info/alternates
  grep -qxF "$2/objects" $GD/objects/info/alternates || echo "$2/objects" >> $GD/objects/info/alternates
  [ -f $2/shallow ] && { cat $2/shallow $GD/shallow 2>/dev/null | sort -u > $GD/shallow.flynk; mv $GD/shallow.flynk $GD/shallow; }
  git -C $1 update-ref refs/remotes/flynk/$3 $(git --git-dir=$2 rev-parse "refs/heads/$3^{commit}") || return 1
  git -C $1 checkout -q -f --detach refs/remotes/flynk/$3
}
paso "src y V8 del árbol propio"
prestar $S $F/chromium.git flynk || { echo "PARO: src"; exit 1; }
prestar $S/v8 $F/v8.git flynk-v8 || { echo "PARO: v8"; exit 1; }
rm -f $S/brave/patches/*.patchinfo $S/brave/patches/v8/*.patchinfo
echo "src: $(git -C $S log -1 --format='%h %s' | cut -c1-90)"
echo "V8:  $(git -C $S/v8 log -1 --format='%h %s' | cut -c1-90)"

paso "fechas de brave-128 en los ficheros con el mismo contenido"
n=0; m=0
for d in "$S:d6209c7e65" "$S/v8:0b23496f52"; do
  r=${d%%:*}; base=${d##*:}; rel=${r#$S}; rel=${rel#/}
  git -C $r diff --name-only $base HEAD | while read f; do
    a=$r/$f; b=$R128/${rel:+$rel/}$f
    [ -f $a ] && [ -f $b ] || continue
    if cmp -s $a $b; then touch -r $b $a; n=$((n+1)); else m=$((m+1)); fi
  done
done
echo "  hecho (los distintos, si los hay, se recompilan)"

FF_REV=$(grep -v '^#' $S/brave/FlyWeb/fast_float-revision | awk 'NF{print $1; exit}'); FF_SUM=$(grep -v '^#' $S/brave/FlyWeb/fast_float-revision | awk 'NF{print $2; exit}')
FF=$S/third_party/fast_float/src
[ "$(git -C $FF rev-parse HEAD)" = "$FF_REV" ] || { echo "PARO: fast_float no está en $FF_REV"; exit 1; }
FF_GOT=$(cd $FF && git ls-files -z include LICENSE-MIT LICENSE-APACHE LICENSE-BOOST | LC_ALL=C sort -z | xargs -0 shasum -a 256 | shasum -a 256 | cut -d' ' -f1)
[ "$FF_GOT" = "$FF_SUM" ] || { echo "PARO: fast_float, suma $FF_GOT, esperada $FF_SUM"; exit 1; }
DB_REV=$(grep -v '^#' $S/brave/FlyWeb/dragonbox-revision | awk 'NF{print $1; exit}'); DB_SUM=$(grep -v '^#' $S/brave/FlyWeb/dragonbox-revision | awk 'NF{print $2; exit}')
DB=$S/third_party/dragonbox/src
[ "$(git -C $DB rev-parse HEAD)" = "$DB_REV" ] || { echo "PARO: dragonbox no está en $DB_REV"; exit 1; }
DB_GOT=$(cd $DB && git ls-files -z include LICENSE-Apache2-LLVM LICENSE-Boost | LC_ALL=C sort -z | xargs -0 shasum -a 256 | shasum -a 256 | cut -d' ' -f1)
[ "$DB_GOT" = "$DB_SUM" ] || { echo "PARO: dragonbox, suma $DB_GOT, esperada $DB_SUM"; exit 1; }
echo "fast_float y dragonbox: sumas comprobadas"

cd $B || exit 1
paso "apply_patches (solo subrepos)"; npm run apply_patches > $T/release-f1-apply.log 2>&1 || { echo "PARO: apply_patches"; tail -20 $T/release-f1-apply.log; exit 1; }
grep -i -E "fail|error|conflict" $T/release-f1-apply.log | head -5
SU=$(grep -E '#define SIMDUTF_VERSION ' $S/third_party/simdutf/simdutf.h | head -1); echo "simdutf: $SU"
case "$SU" in *'"7.0.0"'*) ;; *) echo "PARO: simdutf no es 7.0.0"; exit 1;; esac
paso "comprobar-enums"; (cd $B && python3 -I $SM/FlyWeb/scripts/comprobar-enums.py src) > $T/release-f1-enums.txt 2>&1 || { echo "PARO: comprobar-enums"; cat $T/release-f1-enums.txt; exit 1; }
cat $T/release-f1-enums.txt
EDKEY=$(tr -d ' \t\r\n' < $SM/FlyWeb/servidor/actualizaciones/clave-publica.txt)
printf '%s' "$EDKEY" | grep -Eq '^[A-Za-z0-9+/]{43}=$' || { echo "PARO: clave pública de Sparkle no válida"; exit 1; }
SERVICES_KEY=flyweb; KEYFILE=~/proyectos/softmac/claves/flyweb-services-key
[ -r $KEYFILE ] && SERVICES_KEY=$(tr -d ' \t\r\n' < $KEYFILE)
INERT="https://flyweb.invalid"
cp $O/args_generated.gni $T/args-270.gni
cd $B || exit 1
paso "npm run build Release (registro: release-f1-build.log)"
npm run build -- Release --target_arch=x64 --ninja k:0 \
  --gn "mac_sdk_path:$SDK" --gn 'mac_deployment_target:"10.14"' --gn 'mac_min_system_version:"10.14"' \
  --gn enable_precompiled_headers:false --gn treat_warnings_as_errors:false --gn dcheck_always_on:false --gn symbol_level:0 \
  --gn v8_deprecation_warnings:false --gn v8_imminent_deprecation_warnings:false --gn v8_enable_temporal_support:false \
  --gn "updater_prod_endpoint:https://components.flyweb.lamosquita.net/extensions" \
  --gn "updater_dev_endpoint:https://components.flyweb.lamosquita.net/extensions" \
  --gn "safebrowsing_api_endpoint:proxy.flyweb.lamosquita.net" --gn "brave_stats_updater_url:$INERT" \
  --gn "brave_variations_server_url:$INERT" --gn "webcompat_report_api_endpoint:$INERT" \
  --gn "brave_sync_endpoint:https://sync.flyweb.lamosquita.net/v2" --gn "brave_services_key:$SERVICES_KEY" \
  --gn enable_updater:false --gn brave_p3a_enabled:false --gn enable_ai_chat:false --gn enable_brave_vpn:false \
  --gn enable_brave_vpn_panel:false --gn enable_gemini_wallet:false --gn "flyweb_metal_bin_path:$XBIN" \
  --gn "flyweb_source_commit:$SHA" \
  --gn "brave_ai_chat_endpoint:flyweb.invalid" --gn "service_key_aichat:flyweb" --gn "brave_services_key_id:flyweb" \
  --gn "zebpay_production_api_url:$INERT" --gn "zebpay_production_client_id:flyweb" \
  --gn "zebpay_production_client_secret:flyweb" --gn "zebpay_production_oauth_url:$INERT" \
  --gn "brave_zero_ex_api_key:flyweb" --gn "sardine_client_id:flyweb" --gn "sardine_client_secret:flyweb" \
  --gn "rewards_grant_dev_endpoint:$INERT" --gn "rewards_grant_staging_endpoint:$INERT" --gn "rewards_grant_prod_endpoint:$INERT" \
  --gn "bitflyer_production_client_id:flyweb" --gn "bitflyer_production_client_secret:flyweb" \
  --gn "bitflyer_production_fee_address:flyweb" --gn "bitflyer_production_url:$INERT" \
  --gn "gemini_production_api_url:$INERT" --gn "gemini_production_client_id:flyweb" \
  --gn "gemini_production_client_secret:flyweb" --gn "gemini_production_fee_address:flyweb" --gn "gemini_production_oauth_url:$INERT" \
  --gn "uphold_production_api_url:$INERT" --gn "uphold_production_client_id:flyweb" \
  --gn "uphold_production_client_secret:flyweb" --gn "uphold_production_fee_address:flyweb" --gn "uphold_production_oauth_url:$INERT" \
  --gn enable_sparkle:true --gn "sparkle_eddsa_public_key:$EDKEY" --gn "flyweb_build_number:$BUILDNO" > $L 2>&1
R=$?
paso "args de gn frente a la 2.7.0"
diff $T/args-270.gni $O/args_generated.gni | sed 's/^/  /' | grep -v 'flyweb_source_commit' || true
echo "  (flyweb_source_commit cambia a propósito: $SHA, la rama del corte)"
paso "build terminado (salida $R); errores: $(grep -c ' error:' $L); FAILED: $(grep -c '^FAILED' $L); pasos: $(grep -oE '^\[[0-9,]+/[0-9,]+\]' $L | tail -1)"
grep -E '^[^ ]+:[0-9]+:[0-9]+: error:|undefined symbol|ERROR at|assert' $L | sed -E 's#^(\.\./)+##' | sort -u > $T/release-f1-errores.txt; head -30 $T/release-f1-errores.txt
[ $R -eq 0 ] || exit 1
NFW=$(( $(sed 's#//.*##' $S/third_party/blink/public/mojom/use_counter/metrics/web_feature.mojom | grep -oE '= *[0-9]+' | tr -dc '0-9\n' | sort -n | tail -1) + 1 ))
NF=$(grep -E 'kNumberOfFeatures = ' $O/gen/third_party/blink/public/mojom/use_counter/metrics/web_feature.mojom-shared.h | head -1); echo "  generado: $NF (esperado $NFW)"; case "$NF" in *"= $NFW,"*) ;; *) echo "PARO: kNumberOfFeatures no es $NFW"; exit 1;; esac
rm -f $K; trap - EXIT
A=$O/FlyWeb.app; P=$A/Contents/Info.plist
[ -d $A ] || { echo "PARO: no está $A"; ls $O/*.app; exit 1; }
cat > $O/flyweb-build-info.txt <<INFO
FlyWeb $(node -p "require('$S/brave/package.json').version") (Release, 2.7.0 desde el árbol flynk, FM.54 F1)
brave-core ($CORE_REF): $(git -C $S/brave rev-parse --short=12 HEAD)
Chromium (flynk):    $(git -C $S rev-parse --short=12 HEAD)
V8 (flynk-v8):       $(git -C $S/v8 rev-parse --short=12 HEAD)
brave-browser:       $(git -C $B rev-parse --short=12 HEAD)
Compilado:           $(date -u +%Y-%m-%dT%H:%M:%SZ) en $(hostname -s)
INFO
paso "comprobaciones estáticas (sin arrancar)"
cat $O/flyweb-build-info.txt
for k in CFBundleIdentifier CFBundleShortVersionString CFBundleVersion SUPublicEDKey SUFeedURL LSMinimumSystemVersion; do
  echo "  $k = $(/usr/libexec/PlistBuddy -c "Print :$k" $P 2>&1)"; done
echo "  args.gn: $(grep -E '^(flyweb_source_commit|flyweb_build_number|is_official_build|enable_sparkle|brave_channel) ' $O/args_generated.gni | tr '\n' ' ')"
echo "  arquitectura: $(lipo -archs "$A/Contents/MacOS/FlyWeb")"
PATH=$S/third_party/ninja:$PATH $SM/FlyWeb/scripts/check-no-avx.sh $O brave 2>&1 | tail -6
du -sh $A; du -sh $R128/out/Release/FlyWeb.app
paso "copia sin firmar en $E (no se publica)"
mkdir -p $E && ditto $A $E/FlyWeb.app && cp $O/flyweb-build-info.txt $E/ && ls -la $E
paso "FIN"
