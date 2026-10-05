#!/bin/bash
# E2-01 (SERVIDOR-LOCAL, 05-10-2026): privacidad de los registros de FlyWeb en ns2. Hallazgos 1, 3 y 4 de ESTADO.md.
#   1. LogLevel proxy_http:crit en los vhost 443 de components. y proxy.: mod_proxy_http escribe la IP del cliente
#      dentro del mensaje de sus errores (AH01095…) y ErrorLogFormat no la quita.
#   3. Quita del vhost 443 de components. el bloque sobrante copiado de updates. (DMG y appcast.xml).
#   4. /etc/logrotate.d/flyweb con «create 0640 root adm» (los ficheros nuevos dejan de ser legibles por todos).
#
# Lo ejecuta SERVIDOR-LOCAL desde la 7,1, en una sola sesión, con el commit revisado:
#   ssh ns2 'bash -s' < FlyWeb/servidor/e2/01-registros.sh                      # comprobar (por defecto): no cambia nada
#   ssh ns2 'bash -s -- aplicar <commit>' < FlyWeb/servidor/e2/01-registros.sh
#   ssh ns2 'bash -s -- deshacer' < FlyWeb/servidor/e2/01-registros.sh
# Solo usa órdenes de acceso/sudoers-ns2. Nunca imprime Define ni claves.
set -euo pipefail
MODO=${1:-comprobar}; COMMIT=${2:-}
CONF=/etc/apache2/sites-available/lamosquita.conf
LR=/etc/logrotate.d/flyweb
D=$HOME/e2-01; mkdir -p -m 0700 "$D"
LR_SHA=a4dcc88e9b3afd2c316ef935aa0431bab51c7f5b46737fdb4fef3c76faba2262   # sha256 de e0/logrotate/flyweb en el commit aplicado
RAW=https://raw.githubusercontent.com/lamosquita-net/softmac

nuevo_conf () {
  awk '
    /^[[:space:]]*<VirtualHost[[:space:]]+\*:443>/ { v="" }
    /^[[:space:]]*ServerName[[:space:]]+components\.flyweb\.lamosquita\.net[[:space:]]*$/ && v=="" { v="c" }
    /^[[:space:]]*ServerName[[:space:]]+proxy\.flyweb\.lamosquita\.net[[:space:]]*$/      && v=="" { v="p" }
    /^[[:space:]]*<\/VirtualHost>/ { v="-" }
    # 3. bloque sobrante en components. (desde el comentario de Range hasta el </Files> de appcast.xml)
    v=="c" && /# Apache sirve Range \(descargas reanudables\) por defecto/ { quitar=1 }
    quitar { q++; if (/<\/Files>/ && appcast) { quitar=0; appcast=0 } if (/<Files "appcast.xml">/) appcast=1; next }
    { print }
    # 1. LogLevel tras el ErrorLogFormat de components. y proxy.
    (v=="c" || v=="p") && /^[[:space:]]*ErrorLogFormat / {
      print "        # Sin IP también dentro de los mensajes: mod_proxy_http la escribe en el texto de sus errores (AH01095,"
      print "        # AH01097, AH02609) y ErrorLogFormat no la quita. Los fallos de conexión con el servicio (mod_proxy) siguen."
      print "        LogLevel proxy_http:crit"
      n[v]++
    }
    END { printf "insertados components=%d proxy=%d quitadas=%d\n", n["c"], n["p"], q > "/dev/stderr"
          if (n["c"]!=1 || n["p"]!=1 || q!=8) exit 3 }
  ' "$CONF"
}

comprobar_web () {
  for u in https://components.flyweb.lamosquita.net/_estado.json https://components.flyweb.lamosquita.net/extensions \
           https://proxy.flyweb.lamosquita.net/edgedl/chrome/dict/es-es-3-0.bdic https://proxy.flyweb.lamosquita.net/ \
           https://updates.flyweb.lamosquita.net/stable/appcast.xml https://flyweb.lamosquita.net/; do
    h=${u#https://}; h=${h%%/*}
    curl -sk -o /dev/null -w "%{http_code} $u\n" --resolve "$h:443:127.0.0.1" "$u"; sleep 1
  done
}

case $MODO in
comprobar)
  grep -q 'LogLevel proxy_http:crit' "$CONF" && { echo "Ya aplicado"; exit 0; }
  nuevo_conf > "$D/lamosquita.conf.nuevo"
  echo "== diff (solo FlyWeb)"; diff "$CONF" "$D/lamosquita.conf.nuevo" || true
  echo "== antes"; comprobar_web
  echo "== permisos"; stat -c '%a %U:%G %n' /var/log/flyweb/*/*.log ;;
aplicar)
  [[ $COMMIT =~ ^[0-9a-f]{40}$ ]] || { echo "falta el commit (40 hex)"; exit 2; }
  grep -q 'LogLevel proxy_http:crit' "$CONF" && { echo "Ya aplicado"; exit 0; }
  cp -p "$CONF" "$D/lamosquita.conf.antes"; cp -p "$LR" "$D/logrotate-flyweb.antes"
  nuevo_conf > "$D/lamosquita.conf.nuevo"
  curl -fsSL --proto =https -o "$D/logrotate-flyweb.nuevo" "$RAW/$COMMIT/FlyWeb/servidor/e0/logrotate/flyweb"
  echo "$LR_SHA  $D/logrotate-flyweb.nuevo" | sha256sum -c --quiet
  sudo -n /usr/sbin/apachectl configtest 2>&1 | tail -1
  SUDO_EDITOR="cp $D/lamosquita.conf.nuevo" sudo -n sudoedit "$CONF"
  if ! sudo -n /usr/sbin/apachectl configtest 2>&1 | tail -1 | grep -q 'Syntax OK'; then
    SUDO_EDITOR="cp $D/lamosquita.conf.antes" sudo -n sudoedit "$CONF"; echo "FALLO configtest: vuelto atrás"; exit 1
  fi
  sudo -n /usr/bin/systemctl reload apache2; sleep 2
  SUDO_EDITOR="cp $D/logrotate-flyweb.nuevo" sudo -n sudoedit "$LR"
  echo "== después"; comprobar_web
  echo "== sumas"; sha256sum "$CONF" "$LR"
  echo "== logrotate -d"; /usr/sbin/logrotate -d "$LR" 2>&1 | grep -iE 'error|create' | head -5 || true ;;
deshacer)
  [[ -f $D/lamosquita.conf.antes && -f $D/logrotate-flyweb.antes ]] || { echo "no hay copias en $D"; exit 2; }
  SUDO_EDITOR="cp $D/lamosquita.conf.antes" sudo -n sudoedit "$CONF"
  sudo -n /usr/sbin/apachectl configtest 2>&1 | tail -1
  sudo -n /usr/bin/systemctl reload apache2; sleep 2
  SUDO_EDITOR="cp $D/logrotate-flyweb.antes" sudo -n sudoedit "$LR"
  comprobar_web; sha256sum "$CONF" "$LR" ;;
*) echo "modo: comprobar | aplicar <commit> | deshacer"; exit 2 ;;
esac
