#!/bin/bash
# U4 en ns2 (SERVIDOR-LOCAL): vhost apt.flyweb, logrotate y pruebas, con las órdenes de acceso/sudoers-ns2.
# Antes: DNS (01-dns.sh) y los pasos de root de ORDENES-TITIN.md (carpetas, certificado, guion de la clave de la Ubuntu).
# El vhost y el guion se pasan por stdin junto a este script (ver abajo); se ejecuta desde la carpeta apt/ns2:
#   { printf 'VHOST_B64=%s\nPOOL_B64=%s\n' "$(base64 < vhost-apt.conf | tr -d '\n')" "$(base64 < flyweb-pool-rrsync | tr -d '\n')"; cat 02-vhost.sh; } | ssh ns2 'bash -s -- comprobar'
# Modos: comprobar | probar-pool | aplicar | deshacer
set -euo pipefail
MODO=${1:-comprobar}
CONF=/etc/apache2/sites-available/lamosquita.conf
ROT=/etc/logrotate.d/flyweb
H=apt.flyweb.lamosquita.net
D=$HOME/u4-apt; mkdir -p -m 0700 "$D"
printf '%s' "$VHOST_B64" | base64 -d > "$D/vhost-apt.conf"
printf '%s' "$POOL_B64"  | base64 -d > "$D/flyweb-pool-rrsync"

requisitos () {
  local ok=0
  [[ $(dig +short @127.0.0.1 $H A) == 51.91.19.170 ]] && echo "DNS: ok" || { echo "FALTA: DNS"; ok=1; }
  echo | openssl s_client -connect 127.0.0.1:443 -servername flyweb.lamosquita.net 2>/dev/null | openssl x509 -noout -ext subjectAltName | grep -q "DNS:$H" \
    && echo "certificado: incluye apt." || { echo "FALTA: certificado con apt. (Titín)"; ok=1; }
  for x in /var/www/FlyWeb/apt/dists/stable/main/binary-amd64/by-hash/SHA256 /var/www/FlyWeb/apt/dists/pruebas/main/binary-amd64/by-hash/SHA256 \
           /var/www/FlyWeb/apt/pool/main/f/flyweb /var/log/flyweb/apt; do
    [[ -d $x ]] && echo "carpeta: $(stat -c '%a %U:%G %n' "$x")" || { echo "FALTA: $x (Titín)"; ok=1; }
  done
  return $ok
}
# Prueba de la clave de la Ubuntu sin ssh ni red: rsync local con un «ssh» falso, en una carpeta de ~servidor.
probar_pool () {
  local T; T=$D/prueba-$(date +%H%M%S); mkdir -p "$T/pool/main/f/flyweb" "$T/origen" "$T/bajada"
  cp "$D/flyweb-pool-rrsync" "$T/orden"; chmod 0755 "$T/orden"
  printf '#!/bin/sh\nshift\nSSH_ORIGINAL_COMMAND="$*" FLYWEB_POOL=%q exec %q\n' "$T/pool" "$T/orden" > "$T/ssh-falso"; chmod 0755 "$T/ssh-falso"
  r () { rsync -e "$T/ssh-falso" "$@" >/dev/null 2>&1; }
  echo uno > "$T/origen/a.deb"; r "$T/origen/a.deb" x:main/f/flyweb/ && grep -qx uno "$T/pool/main/f/flyweb/a.deb" && echo "1 sube un fichero nuevo: ok" || echo "1 sube un fichero nuevo: FALLA"
  echo dos-distinto > "$T/origen/a.deb"; r -I "$T/origen/a.deb" x:main/f/flyweb/ || true; grep -qx uno "$T/pool/main/f/flyweb/a.deb" && echo "2 no sobrescribe: ok" || echo "2 no sobrescribe: FALLA"
  r --inplace "$T/origen/a.deb" x:main/f/flyweb/ || true; grep -qx uno "$T/pool/main/f/flyweb/a.deb" && echo "3 no sobrescribe con --inplace: ok" || echo "3 --inplace: FALLA"
  r -r --delete "$T/origen/" x:main/f/ && echo "4 --delete rechazado: FALLA" || echo "4 --delete rechazado: ok"
  r x:main/f/flyweb/a.deb "$T/bajada/" && echo "5 no se puede descargar: FALLA" || echo "5 no se puede descargar: ok"
  r "$T/origen/a.deb" x:../../fuera.deb || true; [[ -e $T/fuera.deb ]] && echo "6 no sale de pool: FALLA" || echo "6 no sale de pool: ok"
  echo "(restos de la prueba en $T; no se borran)"
}
probar_web () {
  for u in / /dists/ /dists/pruebas/ /pool/main/f/flyweb/ /dists/pruebas/Release; do
    curl -sk -o /dev/null -w "%{http_code} https $u\n" --resolve $H:443:127.0.0.1 "https://$H$u" || true; sleep 1; done
  curl -s -o /dev/null -w "%{http_code} %{redirect_url} http (301)\n" --resolve $H:80:127.0.0.1 "http://$H/" || true; sleep 1
  for u in https://flyweb.lamosquita.net/ https://updates.flyweb.lamosquita.net/stable/appcast.xml https://components.flyweb.lamosquita.net/_estado.json; do
    x=${u#https://}; x=${x%%/*}; curl -sk -o /dev/null -w "%{http_code} $u\n" --resolve "$x:443:127.0.0.1" "$u" || true; sleep 1; done
  printf 'líneas con IPv4 en los registros de apt: '; cat /var/log/flyweb/apt/*.log 2>/dev/null | grep -cE '([0-9]{1,3}\.){3}[0-9]{1,3}' || true
}

case $MODO in
comprobar)
  requisitos || echo "== faltan requisitos: no se puede aplicar todavía"
  grep -q "ServerName $H" "$CONF" && echo "OJO: el vhost ya está" || echo "vhost: no está (bien)"
  sudo -n /usr/sbin/apachectl configtest 2>&1 | tail -1 ;;
probar-pool) probar_pool ;;
aplicar)
  requisitos || { echo "Faltan requisitos: no se toca nada"; exit 1; }
  grep -q "ServerName $H" "$CONF" && { echo "El vhost ya existe: parar"; exit 1; }
  cp -p "$CONF" "$D/lamosquita.conf.antes"; cp -p "$ROT" "$D/logrotate.antes"
  { cat "$CONF"; echo; cat "$D/vhost-apt.conf"; } > "$D/lamosquita.conf.nuevo"
  SUDO_EDITOR="cp $D/lamosquita.conf.nuevo" sudo -n sudoedit "$CONF"
  if ! sudo -n /usr/sbin/apachectl configtest 2>&1 | tail -1 | grep -q 'Syntax OK'; then
    SUDO_EDITOR="cp $D/lamosquita.conf.antes" sudo -n sudoedit "$CONF"; echo "FALLO configtest: vhost vuelto atrás"; exit 1
  fi
  sudo -n /usr/bin/systemctl reload apache2; sleep 2
  sed 's#/var/log/flyweb/sync/\*\.log {#/var/log/flyweb/sync/*.log /var/log/flyweb/apt/*.log {#' "$ROT" > "$D/logrotate.nuevo"
  grep -q '/var/log/flyweb/apt/' "$D/logrotate.nuevo" || { echo "logrotate: no encuentro la línea esperada"; exit 1; }
  SUDO_EDITOR="cp $D/logrotate.nuevo" sudo -n sudoedit "$ROT"
  stat -c '%a %U:%G %n' "$CONF" "$ROT"; sha256sum "$CONF" "$ROT"
  probar_web ;;
deshacer)
  [[ -f $D/lamosquita.conf.antes ]] || { echo "No hay copia anterior"; exit 1; }
  SUDO_EDITOR="cp $D/lamosquita.conf.antes" sudo -n sudoedit "$CONF"
  SUDO_EDITOR="cp $D/logrotate.antes" sudo -n sudoedit "$ROT"
  sudo -n /usr/sbin/apachectl configtest 2>&1 | tail -1; sudo -n /usr/bin/systemctl reload apache2 ;;
*) echo "modo: comprobar | probar-pool | aplicar | deshacer"; exit 2 ;;
esac
