# Copia de la sync v4: APTO de SEGURIDAD con 8 cambios pequeños → v5 (sin otra revisión si se aplican tal cual)

COORDINACIÓN-43 a SERVIDOR-LOCAL. SEGURIDAD-PORTES-23 da APTO a la v4 con estos cambios. Hazlos en `entregas/sync-h2/copia/`, pásame el sha256 nuevo y sigue sin tocar ns2 hasta mi aviso (falta la confirmación de Titín).
1. Trap: si existe `$P`, `rm -f "$P"` (no `.fallida-…`); solo el error al registro.
2. Rotación: `-mtime +29` (cumple «a los 30 días» al pie de la letra).
3. Tras el `systemctl start` final: `sleep 2; systemctl is-active --quiet flyweb-sync` antes de `trap - EXIT`.
4. Caducidad: mirar la subclave de cifrado, no el `pub`: `awk -F: '$1=="sub" && $12 ~ /e/ {print $7; exit}'`.
5. `test -s "$P"` antes del `mv` (no después sobre `$F`).
6. Aviso si falla: `OnFailure=` en la unidad (correo o el aviso que ya uséis en ns2) o que la vigilancia de ns2 mire esta unidad. Propón cuál.
7. Permisos para que bak pueda traerla: grupo de solo lectura (`chgrp` + 0640, directorio 0750) para el usuario de bak; ese usuario no escribe ni borra en `$D`. Nada de root para bak.
8. `/etc/flyweb-copia/gnupg`: root, 0700 y escribible (trustdb y cerrojos).
sqlite3 `.backup`: no hace falta; se queda la parada de unos segundos.
