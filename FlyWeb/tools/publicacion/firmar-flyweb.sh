#!/bin/zsh
# Firma FlyWeb.app con el Developer ID de la G2, de dentro hacia fuera, con hardened runtime y sello de tiempo.
# Uso: firmar-flyweb.sh <FlyWeb.app> <SHA-1 de la identidad G2>
# Solo entitlements que no exigen perfil de aprovisionamiento (los de Chromium para app y helpers; nada de
# keychain-access-groups, associated-domains, passkeys ni VPN).
set -eu
APP=$1; ID=$2
SRC=${FLYWEB_SRC:-~/proyectos/flyweb-build/brave-browser/src}
ENT=$(mktemp -d)
cp $SRC/chrome/app/app-entitlements.plist $ENT/app.plist
cp $SRC/chrome/app/helper-renderer-entitlements.plist $ENT/renderer.plist
cp $SRC/chrome/app/helper-gpu-entitlements.plist $ENT/gpu.plist
cp $SRC/chrome/app/helper-plugin-entitlements.plist $ENT/plugin.plist
cp $SRC/brave/app/helper-entitlements.plist $ENT/helper.plist
# Las plantillas de Chromium llevan variables de compilación (${…}); se quitan las claves que las usen.
for f in $ENT/*.plist; do plutil -lint "$f" >/dev/null || { echo "plist no válido: $f"; exit 1; }; done

firma() { codesign --force --timestamp --options runtime --sign "$ID" "$@"; }

FW=$(ls -d "$APP"/Contents/Frameworks/*Framework.framework)
VER=$(ls -d "$FW"/Versions/[0-9]*); echo "framework: $VER"
# 1) librerías y ejecutables sueltos del framework
find "$VER" -type f \( -name "*.dylib" -o -name "*.so" \) -print0 | while IFS= read -r -d '' f; do firma "$f"; done
for x in "$VER"/Helpers/*; do [ -f "$x" ] && [ -x "$x" ] && firma "$x"; done
# 1b) Sparkle (desde la 1.0.1), de dentro hacia fuera: fileop y Autoupdate.app, luego el framework
SP="$VER/Frameworks/Sparkle.framework"
if [ -d "$SP" ]; then
  AU="$SP/Versions/A/Resources/Autoupdate.app"
  firma "$AU/Contents/MacOS/fileop"; firma "$AU"; firma "$SP"; echo "  Sparkle.framework"
fi
# 2) helpers .app, cada uno con sus permisos
for h in "$VER"/Helpers/*.app; do
  case "$h" in
    *"(Renderer).app") e=$ENT/renderer.plist ;;
    *"(GPU).app")      e=$ENT/gpu.plist ;;
    *"(Plugin).app")   e=$ENT/plugin.plist ;;
    *"(Alerts).app")   e="" ;;
    *)                 e=$ENT/helper.plist ;;
  esac
  if [ -n "$e" ]; then firma --entitlements "$e" "$h"; else firma "$h"; fi
  echo "  $(basename "$h") ${e:+(+$(basename $e))}"
done
# 3) el framework y 4) la app
firma "$FW"
firma --entitlements $ENT/app.plist "$APP"
rm -rf $ENT
codesign --verify --deep --strict --verbose=2 "$APP" 2>&1 | tail -2
codesign -dvvv "$APP" 2>&1 | grep -E "^Authority|^Timestamp|flags="
