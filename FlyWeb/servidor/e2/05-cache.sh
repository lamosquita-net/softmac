#!/bin/bash
# E2-05 (SERVIDOR-LOCAL, 06-10-2026): Cache-Control "no-cache" para HTML, CSS, JS, SVG, CSV y TXT en el vhost 443 de la
# web, justo después de la redirección de /descargas/ (E2-02). El navegador revalida (ETag → 304) y nunca mezcla una
# página nueva con un CSS o un JS viejos de su caché (pasó el 06-10 al publicar el diseño nuevo).
#
#   ssh ns2 'bash -s' < FlyWeb/servidor/e2/05-cache.sh                  # comprobar (no cambia nada)
#   ssh ns2 'bash -s -- aplicar' < FlyWeb/servidor/e2/05-cache.sh
#   ssh ns2 'bash -s -- deshacer' < FlyWeb/servidor/e2/05-cache.sh
# Solo órdenes de acceso/sudoers-ns2. Nunca imprime Define ni claves.
set -euo pipefail
MODO=${1:-comprobar}
CONF=/etc/apache2/sites-available/lamosquita.conf
D=$HOME/e2-05; mkdir -p -m 0700 "$D"
MARCA='# E2-05: los navegadores preguntan siempre'

nuevo_conf () {
  awk '
    /^[[:space:]]*<VirtualHost[[:space:]]+\*:443>/ { v="" }
    /^[[:space:]]*ServerName[[:space:]]+flyweb\.lamosquita\.net[[:space:]]*$/ && v=="" { v="w" }
    /^[[:space:]]*<\/VirtualHost>/ { v="-" }
    { print }
    v=="w" && /^[[:space:]]*RedirectMatch 302 "\^\/descargas\/\$" "\/"/ {
      print "        # E2-05: los navegadores preguntan siempre por HTML, CSS, JS, SVG y CSV (304 si no han cambiado), para que nunca"
      print "        # mezclen una página nueva con un CSS o un JS viejos. Las páginas además versionan sus recursos (web/versionar.py)."
      print "        <FilesMatch \"\\.(html|css|js|svg|csv|txt)$\">"
      print "            Header set Cache-Control \"no-cache\""
      print "        </FilesMatch>"
      n++ }
    END { printf "insertadas=%d\n", n > "/dev/stderr"; if (n!=1) exit 3 }
  ' "$CONF"
}

web () {
  for u in / /estilo.css /js/mosca.js /img/mosca.svg /descargas/ /descargas/FlyWeb-1.4.dmg; do
    printf '%s ' "$u"; curl -skI --resolve flyweb.lamosquita.net:443:127.0.0.1 "https://flyweb.lamosquita.net$u" \
      | tr -d '\r' | grep -iE '^(HTTP/|cache-control:)' | tr '\n' ' ' || true; echo; sleep 1
  done
}

case $MODO in
comprobar)
  grep -qF "$MARCA" "$CONF" && { echo "Ya aplicado"; web; exit 0; }
  nuevo_conf > "$D/lamosquita.conf.nuevo"; diff "$CONF" "$D/lamosquita.conf.nuevo" || true
  echo "== antes"; web ;;
aplicar)
  grep -qF "$MARCA" "$CONF" && { echo "Ya aplicado"; exit 0; }
  cp -p "$CONF" "$D/lamosquita.conf.antes"; nuevo_conf > "$D/lamosquita.conf.nuevo"
  SUDO_EDITOR="cp $D/lamosquita.conf.nuevo" sudo -n sudoedit "$CONF"
  if ! sudo -n /usr/sbin/apachectl configtest 2>&1 | tail -1 | grep -q 'Syntax OK'; then
    SUDO_EDITOR="cp $D/lamosquita.conf.antes" sudo -n sudoedit "$CONF"; echo "FALLO configtest: vuelto atrás"; exit 1
  fi
  sudo -n /usr/bin/systemctl reload apache2; sleep 2
  echo "== después"; web; sha256sum "$CONF" ;;
deshacer)
  [[ -f $D/lamosquita.conf.antes ]] || { echo "no hay copia en $D"; exit 2; }
  SUDO_EDITOR="cp $D/lamosquita.conf.antes" sudo -n sudoedit "$CONF"
  sudo -n /usr/sbin/apachectl configtest 2>&1 | tail -1; sudo -n /usr/bin/systemctl reload apache2; sleep 2; web ;;
*) echo "modo: comprobar | aplicar | deshacer"; exit 2 ;;
esac
