#!/bin/bash
# U4, paso DNS (SERVIDOR-LOCAL, 26-11-2026): registro A apt.flyweb.lamosquita.net -> 51.91.19.170 en ns1,
# justo después del de sync.flyweb, y la serie al alza. ns2 y ns3 lo copian por NOTIFY.
#
#   ssh ns1 'bash -s' < FlyWeb/servidor/apt/ns2/01-dns.sh                   # comprobar (no cambia nada)
#   ssh ns1 'bash -s -- aplicar' < FlyWeb/servidor/apt/ns2/01-dns.sh
#   ssh ns1 'bash -s -- deshacer' < FlyWeb/servidor/apt/ns2/01-dns.sh       # quita la línea y vuelve a SUBIR la serie
# Solo órdenes de acceso/sudoers-ns1. No lee named.conf (claves rndc/TSIG).
set -euo pipefail
MODO=${1:-comprobar}
Z=/etc/bind/zones/lamosquita.net.hosts
D=$HOME/u4-dns; mkdir -p -m 0700 "$D"
REG=$'apt.flyweb.lamosquita.net.\t\t3600\tIN\tA\t51.91.19.170'

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
con_apt () { awk -v r="$REG" '{ print } /^sync\.flyweb\.lamosquita\.net\./ { print r; n++ } END { if (n!=1) exit 3 }' "$Z" | subir_serie; }
sin_apt () { grep -v '^apt\.flyweb\.lamosquita\.net\.' "$Z" | subir_serie; }
mirar () {
  for s in 127.0.0.1 ns2.lamosquita.net ns3.lamosquita.net; do
    printf '%s: serie %s  apt=%s\n' "$s" "$(dig +short @$s lamosquita.net SOA | awk '{print $3}')" \
      "$(dig +short @$s apt.flyweb.lamosquita.net A | tr '\n' ' ')"; done
}

[[ -e $Z.jnl ]] && { echo "La zona tiene diario (.jnl): no se edita a mano. Parar y avisar."; exit 1; }
case $MODO in
comprobar)
  grep -q '^apt\.flyweb\.lamosquita\.net\.' "$Z" && { echo "Ya existe el registro"; mirar; exit 0; }
  con_apt > "$D/zona.nueva"; diff "$Z" "$D/zona.nueva" || true
  /usr/bin/named-checkzone lamosquita.net "$D/zona.nueva" | tail -2
  echo "== antes"; mirar ;;
aplicar)
  grep -q '^apt\.flyweb\.lamosquita\.net\.' "$Z" && { echo "Ya existe el registro"; exit 0; }
  cp -p "$Z" "$D/zona.antes"; con_apt > "$D/zona.nueva"
  /usr/bin/named-checkzone lamosquita.net "$D/zona.nueva" >/dev/null
  SUDO_EDITOR="cp $D/zona.nueva" sudo -n sudoedit "$Z"
  sudo -n /usr/bin/named-checkzone lamosquita.net "$Z" | tail -1
  sudo -n /usr/sbin/rndc reload lamosquita.net
  sleep 15; echo "== después"; mirar; stat -c '%a %U:%G %n' "$Z"; sha256sum "$Z" ;;
deshacer)
  grep -q '^apt\.flyweb\.lamosquita\.net\.' "$Z" || { echo "No hay registro apt"; exit 0; }
  sin_apt > "$D/zona.sin-apt"; /usr/bin/named-checkzone lamosquita.net "$D/zona.sin-apt" >/dev/null
  SUDO_EDITOR="cp $D/zona.sin-apt" sudo -n sudoedit "$Z"
  sudo -n /usr/bin/named-checkzone lamosquita.net "$Z" | tail -1; sudo -n /usr/sbin/rndc reload lamosquita.net
  sleep 15; mirar ;;
*) echo "modo: comprobar | aplicar | deshacer"; exit 2 ;;
esac
