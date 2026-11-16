#!/bin/zsh
# FlyWeb para publicar: firma (G2), notariza y grapa la app; DMG con el fondo del HUMANO; firma, notariza y grapa el DMG.
# Uso: publicar-flyweb.sh <versión, p. ej. 1.0> <SHA-1 identidad G2> <fondo.png>
# Necesita el perfil de notarytool "flyweb-notario" en el llavero.
set -eu
VER=$1; ID=$2; FONDO=$3
H=~/proyectos/softmac/herramientas
R=${FLYWEB_OUT:-~/proyectos/flyweb-build/brave-browser/src/out/Release}
W=~/proyectos/softmac/entregas/FlyWeb-$VER; rm -rf $W; mkdir -p $W
OUT=$W/FlyWeb-$VER.dmg
echo "== $(date +%T) copia y firma"
ditto "$R/FlyWeb.app" "$W/FlyWeb.app"
# Sparkle quita la cuarentena de la app descargada como usuario normal; quitar un xattr exige poder escribir el
# fichero, y el build deja gpu_shader_cache.bin en -r--r--r--: sin esto, cada actualización pedía la contraseña de
# administrador («FlyWeb quiere realizar cambios», hasta la 1.7.1). Antes de firmar, todo escribible por el dueño.
chmod -R u+w "$W/FlyWeb.app"
[ -z "$(find "$W/FlyWeb.app" ! -perm -u+w | head -1)" ] || { echo "ERROR: quedan ficheros de solo lectura en la app"; exit 1; }
cp "$R/flyweb-build-info.txt" "$W/" 2>/dev/null || true
$H/firmar-flyweb.sh "$W/FlyWeb.app" "$ID"

echo "== $(date +%T) notarización de la app"
ditto -c -k --keepParent "$W/FlyWeb.app" "$W/app.zip"
xcrun notarytool submit "$W/app.zip" --keychain-profile flyweb-notario --keychain ~/Library/Keychains/login.keychain-db --wait --timeout 2h | tee $W/notario-app.log | tail -3
grep -q "status: Accepted" $W/notario-app.log || { echo "NOTARIZACIÓN DE LA APP RECHAZADA"; id=$(grep -m1 -o 'id: [0-9a-f-]*' $W/notario-app.log | cut -d' ' -f2); xcrun notarytool log "$id" --keychain-profile flyweb-notario --keychain ~/Library/Keychains/login.keychain-db > $W/notario-app-detalle.json; exit 2; }
xcrun stapler staple "$W/FlyWeb.app" | tail -1; rm -f "$W/app.zip"

echo "== $(date +%T) DMG"
$H/dmg-flyweb.sh "$W/FlyWeb.app" $OUT "$FONDO" "$ID"

echo "== $(date +%T) notarización del DMG"
xcrun notarytool submit $OUT --keychain-profile flyweb-notario --keychain ~/Library/Keychains/login.keychain-db --wait --timeout 2h | tee $W/notario-dmg.log | tail -3
grep -q "status: Accepted" $W/notario-dmg.log || { echo "NOTARIZACIÓN DEL DMG RECHAZADA"; exit 3; }
xcrun stapler staple $OUT | tail -1

echo "== $(date +%T) comprobaciones"
xcrun stapler validate $OUT | tail -1
M=$(mktemp -d); hdiutil attach -nobrowse -readonly -mountpoint $M $OUT >/dev/null && {
  n=$(find $M/FlyWeb.app ! -perm -u+w | wc -l | tr -d ' '); hdiutil detach $M >/dev/null
  [ "$n" = 0 ] && echo "DMG: todos los ficheros escribibles por el dueño (Sparkle no pedirá contraseña)" \
               || { echo "ERROR: $n ficheros de solo lectura en el DMG (Sparkle pediría contraseña)"; exit 4; }; }
spctl -a -vvv -t install $OUT 2>&1 | head -3
spctl -a -vvv -t exec "$W/FlyWeb.app" 2>&1 | head -3
shasum -a 256 $OUT
ls -la $OUT
