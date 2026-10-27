#!/bin/bash
# E2-02 (SERVIDOR-LOCAL, 05-10-2026): /descargas/ da 403 (sin índice) y FlyWeb 1.1.2 enlaza a /descargas/#novedades
# (Información) y a /descargas/. Redirección 302 a la portada, que tiene id="novedades"; el navegador conserva el
# fragmento al seguir la redirección. Los DMG de /descargas/<fichero> no cambian.
#
#   ssh ns2 'bash -s' < FlyWeb/servidor/e2/02-descargas.sh                  # comprobar (no cambia nada)
#   ssh ns2 'bash -s -- aplicar' < FlyWeb/servidor/e2/02-descargas.sh
#   ssh ns2 'bash -s -- deshacer' < FlyWeb/servidor/e2/02-descargas.sh
# Solo órdenes de acceso/sudoers-ns2. Nunca imprime Define ni claves.
set -euo pipefail
MODO=${1:-comprobar}
CONF=/etc/apache2/sites-available/lamosquita.conf
D=$HOME/e2-02; mkdir -p -m 0700 "$D"
LINEA='        RedirectMatch 302 "^/descargas/$" "/"'

nuevo_conf () {
  awk -v linea="$LINEA" '
    /^[[:space:]]*<VirtualHost[[:space:]]+\*:443>/ { v="" }
    /^[[:space:]]*ServerName[[:space:]]+flyweb\.lamosquita\.net[[:space:]]*$/ && v=="" { v="w" }
    /^[[:space:]]*<\/VirtualHost>/ { v="-" }
    { print }
    v=="w" && /^[[:space:]]*CustomLog[[:space:]]+\/var\/log\/flyweb\/flyweb\.lamosquita\.net\// {
      print "        # E2-02: FlyWeb enlaza a /descargas/ y /descargas/#novedades; sin índice daba 403."
      print linea; n++ }
    END { printf "insertadas=%d\n", n > "/dev/stderr"; if (n!=1) exit 3 }
  ' "$CONF"
}

web () {
  for u in https://flyweb.lamosquita.net/descargas/ https://flyweb.lamosquita.net/descargas/FlyWeb-1.1.2.dmg \
           https://flyweb.lamosquita.net/ https://flyweb.lamosquita.net/privacidad.html; do
    curl -skI -o /dev/null -w "%{http_code} %{redirect_url} $u\n" --resolve flyweb.lamosquita.net:443:127.0.0.1 "$u" || true; sleep 1
  done
}

case $MODO in
comprobar)
  grep -qF 'RedirectMatch 302 "^/descargas/$"' "$CONF" && { echo "Ya aplicado"; web; exit 0; }
  nuevo_conf > "$D/lamosquita.conf.nuevo"; diff "$CONF" "$D/lamosquita.conf.nuevo" || true
  echo "== antes"; web ;;
aplicar)
  grep -qF 'RedirectMatch 302 "^/descargas/$"' "$CONF" && { echo "Ya aplicado"; exit 0; }
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
