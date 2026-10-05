#!/bin/bash
# SV.1, paso DNS (SERVIDOR-LOCAL, 05-10-2026): registro A sync.flyweb.lamosquita.net -> 51.91.19.170 en ns1 (maestro),
# justo después del de proxy.flyweb, y la serie al alza. ns2 y ns3 lo copian por NOTIFY.
#
#   ssh ns1 'bash -s' < FlyWeb/servidor/e2/03-sync-dns.sh                   # comprobar (no cambia nada)
#   ssh ns1 'bash -s -- aplicar' < FlyWeb/servidor/e2/03-sync-dns.sh
#   ssh ns1 'bash -s -- deshacer' < FlyWeb/servidor/e2/03-sync-dns.sh       # quita la línea y vuelve a SUBIR la serie
# Solo órdenes de acceso/sudoers-ns1. No lee named.conf (claves rndc/TSIG).
set -euo pipefail
MODO=${1:-comprobar}
Z=/etc/bind/zones/lamosquita.net.hosts
D=$HOME/sv1-dns; mkdir -p -m 0700 "$D"
REG=$'sync.flyweb.lamosquita.net.\t\t3600\tIN\tA\t51.91.19.170'

# Sube la serie (primer número de 10 cifras tras el SOA) a max(serie+1, AAAAMMDD01).
subir_serie () {
  awk -v hoy="$(date -u +%Y%m%d)01" '
    /IN[[:space:]]+SOA/ { soa=1 }
    soa && !hecho && match($0, /[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]/) {
      s=substr($0, RSTART, 10); n=(s+1 > hoy+0) ? s+1 : hoy+0; n=sprintf("%.0f", n)
      $0=substr($0,1,RSTART-1) n substr($0,RSTART+10); hecho=1
      printf "serie %s -> %s\n", s, n > "/dev/stderr" }
    { print }
    END { if (!hecho) exit 3 }'
}
con_sync () { awk -v r="$REG" '{ print } /^proxy\.flyweb\.lamosquita\.net\./ { print r; n++ } END { if (n!=1) exit 3 }' "$Z" | subir_serie; }
sin_sync () { grep -v '^sync\.flyweb\.lamosquita\.net\.' "$Z" | subir_serie; }
mirar () {
  for s in 127.0.0.1 ns2.lamosquita.net ns3.lamosquita.net; do
    printf '%s: serie %s  sync=%s\n' "$s" "$(dig +short @$s lamosquita.net SOA | awk '{print $3}')" \
      "$(dig +short @$s sync.flyweb.lamosquita.net A | tr '\n' ' ')"; done
}

[[ -e $Z.jnl ]] && { echo "La zona tiene diario (.jnl): no se edita a mano. Parar y avisar."; exit 1; }
case $MODO in
comprobar)
  grep -q '^sync\.flyweb\.lamosquita\.net\.' "$Z" && { echo "Ya existe el registro"; mirar; exit 0; }
  con_sync > "$D/zona.nueva"; diff "$Z" "$D/zona.nueva" || true
  /usr/bin/named-checkzone lamosquita.net "$D/zona.nueva" | tail -2
  echo "== antes"; mirar ;;
aplicar)
  grep -q '^sync\.flyweb\.lamosquita\.net\.' "$Z" && { echo "Ya existe el registro"; exit 0; }
  cp -p "$Z" "$D/zona.antes"; con_sync > "$D/zona.nueva"
  /usr/bin/named-checkzone lamosquita.net "$D/zona.nueva" >/dev/null
  SUDO_EDITOR="cp $D/zona.nueva" sudo -n sudoedit "$Z"
  sudo -n /usr/bin/named-checkzone lamosquita.net "$Z" | tail -1
  sudo -n /usr/sbin/rndc reload lamosquita.net
  sleep 15; echo "== después"; mirar; stat -c '%a %U:%G %n' "$Z"; sha256sum "$Z" ;;
deshacer)
  grep -q '^sync\.flyweb\.lamosquita\.net\.' "$Z" || { echo "No hay registro sync"; exit 0; }
  sin_sync > "$D/zona.sin-sync"; /usr/bin/named-checkzone lamosquita.net "$D/zona.sin-sync" >/dev/null
  SUDO_EDITOR="cp $D/zona.sin-sync" sudo -n sudoedit "$Z"
  sudo -n /usr/bin/named-checkzone lamosquita.net "$Z" | tail -1; sudo -n /usr/sbin/rndc reload lamosquita.net
  sleep 15; mirar ;;
*) echo "modo: comprobar | aplicar | deshacer"; exit 2 ;;
esac
