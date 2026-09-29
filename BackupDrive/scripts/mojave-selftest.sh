#!/bin/sh
# Autodiagnóstico de BackupDrive en el Mac (pensado para Mojave, antes de la primera sincronización real).
# Solo LEE: no sincroniza ni modifica nada. Uso: mojave-selftest.sh
# Resultado: OK / AVISO / FALLO por comprobación; sale con 1 si hay algún FALLO.
set -u

APP_DIR="${BACKUPDRIVE_DIR:-$HOME/Library/Application Support/BackupDrive}"
BIN="${BACKUPDRIVE_BIN:-/usr/local/bin/backupdrive}"
CONF="$APP_DIR/backupdrive.conf"
PROFILES="$APP_DIR/profiles"
fails=0
ok()   { echo "OK     $*"; }
warn() { echo "AVISO  $*"; }
fail() { echo "FALLO  $*"; fails=$((fails + 1)); }

# 1. Sistema
if command -v sw_vers >/dev/null; then
  v=$(sw_vers -productVersion)
  case "$v" in
    10.14*) ok "macOS $v (objetivo garantizado)" ;;
    10.15*|11.*|12.*) warn "macOS $v: debería funcionar, sin garantía" ;;
    *) warn "macOS $v: fuera de lo probado" ;;
  esac
  ok "CPU: $(sysctl -n machdep.cpu.brand_string 2>/dev/null)"
else
  warn "no es macOS (sw_vers no existe): se omiten las comprobaciones del sistema"
fi

# 2. Binario
if [ -x "$BIN" ]; then
  ver=$("$BIN" version 2>/dev/null | head -1)
  case "$ver" in
    *backupdrive*) ok "binario: $ver" ;;
    "") fail "$BIN no arranca (¿binario de otra arquitectura o bloqueado por Gatekeeper? prueba: xattr -d com.apple.quarantine $BIN)" ;;
    *) warn "binario sin marca BackupDrive: $ver" ;;
  esac
  if command -v otool >/dev/null; then
    minos=$(otool -l "$BIN" | awk '/LC_VERSION_MIN_MACOSX/{f=1} /LC_BUILD_VERSION/{f=2} f==1&&/version/{print $2; exit} f==2&&/minos/{print $2; exit}')
    case "$minos" in
      10.1[0-4]*|10.[0-9]) ok "versión mínima de macOS del binario: $minos" ;;
      "") warn "no se pudo leer la versión mínima de macOS del binario" ;;
      *) fail "el binario exige macOS $minos (más nuevo que Mojave)" ;;
    esac
  fi
else
  fail "no encuentro $BIN (instalar según BackupDrive/README.md)"
fi

# 3. Certificados y hora: Go usa los certificados del sistema; Mojave es de 2018.
for url in https://oauth2.googleapis.com https://www.googleapis.com; do
  out=$("$BIN" --config /dev/null lsf --http-url "$url" :http: 2>&1)
  if printf '%s' "$out" | grep -qi 'x509\|certificate'; then
    fail "TLS con $url: $(printf '%s' "$out" | grep -i -m1 'x509\|certificate')"
  else
    ok "TLS con $url"
  fi
done
if command -v curl >/dev/null; then
  remote_date=$(curl -sI https://www.googleapis.com 2>/dev/null | tr -d '\r' | awk -F': ' 'tolower($1)=="date"{print $2}')
  if [ -n "$remote_date" ]; then
    r=$(date -j -f "%a, %d %b %Y %H:%M:%S %Z" "$remote_date" +%s 2>/dev/null || date -d "$remote_date" +%s 2>/dev/null)
    l=$(date +%s)
    if [ -n "$r" ]; then
      d=$((l > r ? l - r : r - l))
      [ "$d" -le 120 ] && ok "hora del sistema (desfase ${d}s)" || fail "la hora del sistema se desvía ${d}s: OAuth fallará; activa la hora automática"
    fi
  fi
fi

# 4. Configuración y acceso a Drive (solo lectura)
if [ -f "$CONF" ]; then
  ok "configuración: $CONF"
  for r in $("$BIN" --config "$CONF" listremotes 2>/dev/null); do
    if "$BIN" --config "$CONF" about "$r" >/dev/null 2>&1; then
      ok "acceso a $r (token válido)"
    else
      fail "no se puede acceder a $r: revisa el token con '$BIN --config \"$CONF\" config reconnect $r'"
    fi
  done
else
  fail "falta $CONF"
fi

# 5. Perfiles
if [ -f "$PROFILES" ]; then
  while IFS='|' read -r local_dir remote; do
    case "$local_dir" in ''|'#'*) continue ;; esac
    [ -d "$local_dir" ] && ok "carpeta local: $local_dir" || fail "no existe la carpeta local: $local_dir"
    if [ -n "$remote" ] && "$BIN" --config "$CONF" lsf --max-depth 1 "$remote" >/dev/null 2>&1 </dev/null; then
      ok "remoto accesible: $remote"
    else
      warn "remoto no accesible o vacío: $remote (normal si aún no existe; se crea en --resync)"
    fi
  done < "$PROFILES"
else
  fail "falta $PROFILES (formato: carpeta|remoto:ruta)"
fi

# 6. Programación
if command -v launchctl >/dev/null; then
  launchctl list 2>/dev/null | grep -q net.lamosquita.backupdrive \
    && ok "agente de launchd cargado" || warn "agente de launchd no cargado (paso 4 del README)"
fi

echo
[ "$fails" -eq 0 ] && echo "Listo: sin fallos." || echo "$fails fallo(s): corrígelos antes de sincronizar."
[ "$fails" -eq 0 ]
