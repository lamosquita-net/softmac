#!/bin/bash
# SV.1 en ns2 (SERVIDOR-LOCAL, 05-10-2026): flyweb-sync (unidad, binario) y vhost sync.flyweb.lamosquita.net.
# Sustituye a los pasos 3-5 de sync/instalar-ns2.md con las órdenes de acceso/sudoers-ns2 y flyweb-desplegar.
#
# Requisitos que pone el HUMANO antes (el modo comprobar los mira): DNS de sync. (e2/03-sync-dns.sh), certificado
# ampliado con sync. (certbot --expand) y la carpeta de registros: sudo install -d -m 0755 /var/log/flyweb/sync
#
#   ssh ns2 'bash -s' < FlyWeb/servidor/e2/04-sync.sh                       # comprobar (no cambia nada)
#   ssh ns2 'bash -s -- aplicar <commit>' < FlyWeb/servidor/e2/04-sync.sh
#   ssh ns2 'bash -s -- deshacer' < FlyWeb/servidor/e2/04-sync.sh
# Nunca imprime Define ni claves (aquí no hay ninguna).
set -euo pipefail
MODO=${1:-comprobar}; COMMIT=${2:-}
CONF=/etc/apache2/sites-available/lamosquita.conf
UNIT=/etc/systemd/system/flyweb-sync.service
D=$HOME/sv1-sync; mkdir -p -m 0700 "$D"
RAW=https://raw.githubusercontent.com/lamosquita-net/softmac
BIN_SHA=6b690b21467c3637b9e655a72c7888585aca974270d330c460876c3872b0007c    # release flyweb-sync (sync/instalar-ns2.md)
UNIT_SHA=e9b1b783cc6c2a7bf8f4b052ebe2c23a445231cfe38a2bd84037075963d2f417   # systemd/flyweb-sync.service
VH_SHA=7275a5b32b1bf3d9913ef9b02a7b545d69549bc59755c1ca33ed14493a45708a     # e0/apache/flyweb-sync-vhost.conf (con LogLevel, E2-01)

requisitos () {
  local ok=0
  printf 'DNS sync.: %s\n' "$(dig +short @127.0.0.1 sync.flyweb.lamosquita.net A | tr '\n' ' ')"
  [[ $(dig +short @127.0.0.1 sync.flyweb.lamosquita.net A) == 51.91.19.170 ]] || { echo "  FALTA: DNS"; ok=1; }
  sudo -n /usr/bin/certbot certificates 2>/dev/null | grep -A3 'Certificate Name: flyweb.lamosquita.net' | grep -q 'sync\.flyweb' \
    && echo "certificado: incluye sync." || { echo "  FALTA: certificado con sync. (HUMANO: certbot --expand)"; ok=1; }
  [[ -d /var/log/flyweb/sync ]] && echo "registros: /var/log/flyweb/sync existe" \
    || { echo "  FALTA: /var/log/flyweb/sync (HUMANO: sudo install -d -m 0755 /var/log/flyweb/sync)"; ok=1; }
  sudo -n /usr/bin/ss -ltnp | grep -q ':8295 ' && { echo "  OCUPADO: puerto 8295"; ok=1; } || echo "puerto 8295 libre"
  [[ -d /var/www/FlyWeb/proxy-vacio ]] || { echo "  FALTA: /var/www/FlyWeb/proxy-vacio"; ok=1; }
  printf 'NTP: %s\n' "$(timedatectl show -p NTPSynchronized --value)"
  ls /etc/apache2/mods-enabled/ | grep -cE '^(rewrite|proxy_http|ssl|http2)\.load$' | sed 's/^/módulos (4): /'
  return $ok
}
web () {
  local h=sync.flyweb.lamosquita.net
  curl -sk -o /dev/null -w "%{http_code} POST /v2/command/ (401)\n" -X POST --resolve $h:443:127.0.0.1 https://$h/v2/command/ || true; sleep 1
  curl -sk -o /dev/null -w "%{http_code} GET / (404)\n" --resolve $h:443:127.0.0.1 https://$h/ || true; sleep 1
  curl -s -o /dev/null -w "%{http_code} %{redirect_url} http (301)\n" --resolve $h:80:127.0.0.1 http://$h/ || true; sleep 1
  for u in https://flyweb.lamosquita.net/ https://components.flyweb.lamosquita.net/_estado.json \
           https://proxy.flyweb.lamosquita.net/ https://updates.flyweb.lamosquita.net/stable/appcast.xml; do
    local x=${u#https://}; x=${x%%/*}
    curl -sk -o /dev/null -w "%{http_code} $u\n" --resolve "$x:443:127.0.0.1" "$u" || true; sleep 1; done
}
servicio () {
  printf 'flyweb-sync: %s / %s\n' "$(systemctl is-active flyweb-sync || true)" "$(systemctl is-enabled flyweb-sync 2>&1 || true)"
  sudo -n /usr/bin/ss -ltnp | grep ':8295 ' || echo "(nada en 8295)"
  curl -s -o /dev/null -w "%{http_code} directo POST (401)\n" -X POST http://127.0.0.1:8295/v2/command/ || true
  curl -s -o /dev/null -w "%{http_code} directo GET / (404)\n" http://127.0.0.1:8295/ || true
  sudo -n /usr/bin/ls -l /var/lib/private/flyweb-sync/ || true
}
bajar () {  # bajar <ruta en el repo> <sha> <destino>
  curl -fsSL --proto =https -o "$3" "$RAW/$COMMIT/FlyWeb/servidor/$1"
  echo "$2  $3" | sha256sum -c --quiet
}

case $MODO in
comprobar)
  requisitos || echo "== faltan requisitos: no se puede aplicar todavía"
  [[ -e $UNIT ]] && echo "OJO: $UNIT ya existe" || echo "unidad: no existe (bien)"
  grep -q 'ServerName sync.flyweb.lamosquita.net' "$CONF" && echo "OJO: el vhost de sync. ya está" || echo "vhost: no está (bien)"
  sudo -n /usr/sbin/apachectl configtest 2>&1 | tail -1 ;;
aplicar)
  [[ $COMMIT =~ ^[0-9a-f]{40}$ ]] || { echo "falta el commit (40 hex)"; exit 2; }
  requisitos || { echo "Faltan requisitos: no se toca nada"; exit 1; }
  [[ -e $UNIT ]] && { echo "La unidad ya existe: parar"; exit 1; }
  grep -q 'ServerName sync.flyweb.lamosquita.net' "$CONF" && { echo "El vhost ya existe: parar"; exit 1; }
  bajar systemd/flyweb-sync.service "$UNIT_SHA" "$D/flyweb-sync.service"
  bajar e0/apache/flyweb-sync-vhost.conf "$VH_SHA" "$D/flyweb-sync-vhost.conf"
  echo "== 1. unidad"
  SUDO_EDITOR="cp $D/flyweb-sync.service" sudo -n sudoedit "$UNIT"
  stat -c '%a %U:%G %n' "$UNIT"; sha256sum "$UNIT"
  sudo -n /usr/bin/systemctl daemon-reload
  sudo -n /usr/bin/systemctl enable flyweb-sync
  echo "== 2. binario (flyweb-desplegar: comprueba la suma, instala y arranca)"
  sudo -n /usr/local/sbin/flyweb-desplegar binario sync "$BIN_SHA"
  sleep 2; servicio
  systemctl is-active --quiet flyweb-sync || { echo "El servicio no arranca: parar (deshacer)"; exit 1; }
  echo "== 3. vhost"
  cp -p "$CONF" "$D/lamosquita.conf.antes"
  { cat "$CONF"; echo; cat "$D/flyweb-sync-vhost.conf"; } > "$D/lamosquita.conf.nuevo"
  SUDO_EDITOR="cp $D/lamosquita.conf.nuevo" sudo -n sudoedit "$CONF"
  if ! sudo -n /usr/sbin/apachectl configtest 2>&1 | tail -1 | grep -q 'Syntax OK'; then
    SUDO_EDITOR="cp $D/lamosquita.conf.antes" sudo -n sudoedit "$CONF"; echo "FALLO configtest: vhost vuelto atrás"; exit 1
  fi
  sudo -n /usr/bin/systemctl reload apache2; sleep 2
  echo "== 4. comprobaciones"; web
  sha256sum "$CONF"
  printf 'IP en registros de sync.: '; cat /var/log/flyweb/sync/*.log 2>/dev/null | grep -cE '([0-9]{1,3}\.){3}[0-9]{1,3}' || true ;;
deshacer)
  if [[ -f $D/lamosquita.conf.antes ]] && grep -q 'ServerName sync.flyweb.lamosquita.net' "$CONF"; then
    SUDO_EDITOR="cp $D/lamosquita.conf.antes" sudo -n sudoedit "$CONF"
    sudo -n /usr/sbin/apachectl configtest 2>&1 | tail -1; sudo -n /usr/bin/systemctl reload apache2; sleep 2
  fi
  sudo -n /usr/bin/systemctl stop flyweb-sync || true
  sudo -n /usr/bin/systemctl disable flyweb-sync || true
  servicio
  echo "HUMANO, para borrar del todo: $UNIT, /opt/flyweb-sync, /var/log/flyweb/sync (y, solo si se abandona, /var/lib/private/flyweb-sync)" ;;
*) echo "modo: comprobar | aplicar <commit> | deshacer"; exit 2 ;;
esac
