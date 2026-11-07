#!/bin/bash
# SEGURIDAD-PORTES-18 (FS.41): comprobaciones de solo lectura de una build Mac de FlyWeb.
# Uso: sondeo-b5.sh /ruta/FlyWeb.app
# 1) frameworks de 10.15+ enlazados como débiles; 2) setter de pruebas del crx_verifier;
# 3) Privacy Sandbox y FedCM no expuestos a las webs (todo debe salir undefined o false).
set -u
APP="$1"; [ -d "$APP" ] || { echo "falta la app"; exit 1; }
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
echo "== 1. Frameworks de 10.15+ (todas deben salir LC_LOAD_WEAK_DYLIB)"
# otool-classic no abre rutas con espacios o paréntesis («FlyWeb Helper (GPU)»): se copia cada binario.
find "$APP" -type f -perm -111 -print0 | while IFS= read -r -d '' f; do
  file "$f" | grep -q Mach-O || continue
  cp "$f" "$T/bin"
  otool -l "$T/bin" | awk '/cmd LC_LOAD_(WEAK_)?DYLIB/{c=$2} / name /{print c, $2}' \
    | grep -E 'AuthenticationServices|ScreenCaptureKit|UniformTypeIdentifiers' | sed "s|^|${f#$APP/}: |"
done
echo "== 2. crx_verifier: setter de pruebas en la Release (debe salir 0)"
FW=$(find "$APP/Contents/Frameworks" -maxdepth 1 -name '*Framework.framework' | head -1)
cp "$FW/$(basename "$FW" .framework)" "$T/fw"
nm -U "$T/fw" 2>/dev/null | grep -c SetFlyWebPublisherKeyHashForTesting
echo "== 3. Privacy Sandbox y FedCM (todo debe salir undefined o false)"
cat > "$T/p.html" <<'H'
<script>var r={secure:isSecureContext,topics:typeof document.browsingTopics,sharedStorage:typeof window.sharedStorage,
joinAdInterestGroup:typeof navigator.joinAdInterestGroup,runAdAuction:typeof navigator.runAdAuction,
protectedAudience:typeof navigator.protectedAudience,getIGAdAuctionData:typeof navigator.getInterestGroupAdAuctionData,
fencedFrame:typeof window.HTMLFencedFrameElement,fencedFrameConfig:typeof window.FencedFrameConfig,
attributionSrc:('attributionSrc' in HTMLImageElement.prototype),identityCredential:typeof window.IdentityCredential,
hasPrivateToken:typeof document.hasPrivateToken,cookieDeprecationLabel:typeof navigator.cookieDeprecationLabel,
interestCohort:typeof document.interestCohort};console.log('B5='+JSON.stringify(r));</script>
H
# --dump-dom no da salida en la 156: se lee el console.log del registro (o hágase por CDP).
EXE="$APP/Contents/MacOS/$(defaults read "$APP/Contents/Info" CFBundleExecutable)"
"$EXE" --headless=new --disable-gpu --enable-logging=stderr --v=0 --user-data-dir="$T/perfil" \
  --timeout=5000 "file://$T/p.html" 2>&1 | grep -o 'B5={[^}]*}' | head -1
