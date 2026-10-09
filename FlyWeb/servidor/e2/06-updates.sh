#!/bin/bash
# E2-06 (SERVIDOR-LOCAL, 09-10-2026): updates.flyweb.lamosquita.net sirve solo lo que usa Sparkle: los DMG de la raíz
# (FlyWeb-<versión>.dmg) y stable/appcast.xml. Todo lo demás, 403. Hoy sirve cualquier fichero de su carpeta; bak sube ahí
# por rsync y una copia suelta (un .json de estado, un .bak) quedaría pública. Lo pedido en los registros de updates.
# (7 días, 09-10): /stable/appcast.xml y /FlyWeb-N.dmg (GET y HEAD); lo demás son sondeos (.env, .git/config, phpinfo…).
#
#   ssh ns2 'bash -s' < FlyWeb/servidor/e2/06-updates.sh                  # comprobar (no cambia nada)
#   ssh ns2 'bash -s -- aplicar' < FlyWeb/servidor/e2/06-updates.sh
#   ssh ns2 'bash -s -- deshacer' < FlyWeb/servidor/e2/06-updates.sh
#   bash FlyWeb/servidor/e2/06-updates.sh generar <lamosquita.conf|e0/apache/flyweb-vhosts.conf>   # solo imprime el resultado
# Solo órdenes de acceso/sudoers-ns2. Nunca imprime Define ni claves. "aplicar" vuelve atrás solo si falla configtest o
# si alguna de las comprobaciones de después no da lo esperado.
set -euo pipefail
MODO=${1:-comprobar}
CONF=/etc/apache2/sites-available/lamosquita.conf
D=$HOME/e2-06
MARCA='# E2-06: updates. sirve solo'

nuevo_conf () {
  awk '
    /^[[:space:]]*<VirtualHost[[:space:]]+\*:443>/ { v="" }
    /^[[:space:]]*ServerName[[:space:]]+updates\.flyweb\.lamosquita\.net[[:space:]]*$/ && v=="" { v="u" }
    /^[[:space:]]*<\/VirtualHost>/ { v="-" }
    v=="u" && !r && /^[[:space:]]*Require all granted[[:space:]]*$/ {
      print "            Require all denied"
      print "            # E2-06: updates. sirve solo los DMG de la raíz y stable/appcast.xml (lo que usa Sparkle); lo demás, 403."
      print "            <FilesMatch \"^FlyWeb-[0-9]+(\\.[0-9]+)*\\.dmg$\">"
      print "                Require all granted"
      print "            </FilesMatch>"
      r=1; next }
    v=="u" && r && !d && /^[[:space:]]*<\/Directory>/ {
      print "        </Directory>"
      print "        <Directory /var/www/FlyWeb/updates/stable>"
      print "            Require all denied"
      print "            <Files \"appcast.xml\">"
      print "                Require all granted"
      print "            </Files>"
      print "        </Directory>"
      d=1; next }
    { print }
    END { printf "bloques=%d,%d\n", r, d > "/dev/stderr"; if (r!=1 || d!=1) exit 3 }
  ' "${1:-$CONF}"
}

# Comprobación: ruta y código esperado. Peticiones de una en una y con pausa, desde el propio servidor.
M=updates.flyweb.lamosquita.net
cabecera () { curl -sk -I --max-time 10 --resolve "$M:443:127.0.0.1" "https://$M$1" | head -1 | tr -d '\r' | cut -d' ' -f2; }
LTS=$(ls /var/www/FlyWeb/updates/FlyWeb-*.dmg 2>/dev/null | sort -V | tail -1 | xargs -n1 basename 2>/dev/null || true)
probar () {  # $1=escribir esperado ("si"/"no")
  local malas=0 p e c
  for par in "/stable/appcast.xml 200" "/$LTS 200" "/ 403" "/.env 403" "/stable/ 403" "/stable/appcast.json 403" "/$LTS.bak 403"; do
    p=${par% *}; e=${par#* }; c=$(cabecera "$p")
    printf '%-34s %s' "$p" "$c"
    [[ $1 == si && $c != "$e" ]] && { printf '   (esperado %s)' "$e"; malas=$((malas+1)); }
    echo; sleep 1
  done
  return $malas
}

volver () {  # restaura la copia, comprueba y recarga
  SUDO_EDITOR="cp $D/lamosquita.conf.antes" sudo -n sudoedit "$CONF"
  sudo -n /usr/sbin/apachectl configtest 2>&1 | tail -1; sudo -n /usr/bin/systemctl reload apache2; sleep 2
}

case $MODO in
generar) nuevo_conf "${2:?fichero}" ;;
comprobar)
  [[ -z $LTS ]] && { echo "no hay DMG en updates/"; exit 2; }
  mkdir -p -m 0700 "$D"
  grep -qF "$MARCA" "$CONF" && { echo "Ya aplicado"; probar si || true; exit 0; }
  nuevo_conf > "$D/lamosquita.conf.nuevo"; diff "$CONF" "$D/lamosquita.conf.nuevo" || true
  echo "== antes"; probar no || true ;;
aplicar)
  [[ -z $LTS ]] && { echo "no hay DMG en updates/"; exit 2; }
  mkdir -p -m 0700 "$D"
  grep -qF "$MARCA" "$CONF" && { echo "Ya aplicado"; exit 0; }
  cp -p "$CONF" "$D/lamosquita.conf.antes"; nuevo_conf > "$D/lamosquita.conf.nuevo"
  SUDO_EDITOR="cp $D/lamosquita.conf.nuevo" sudo -n sudoedit "$CONF"
  if ! sudo -n /usr/sbin/apachectl configtest 2>&1 | tail -1 | grep -q 'Syntax OK'; then
    volver; echo "FALLO configtest: vuelto atrás"; exit 1
  fi
  sudo -n /usr/bin/systemctl reload apache2; sleep 2
  echo "== después"
  if ! probar si; then volver; echo "FALLO en las comprobaciones: vuelto atrás"; exit 1; fi
  sha256sum "$CONF" ;;
deshacer)
  [[ -f $D/lamosquita.conf.antes ]] || { echo "no hay copia en $D"; exit 2; }
  volver; probar no || true ;;
*) echo "modo: comprobar | aplicar | deshacer | generar <fichero>"; exit 2 ;;
esac
