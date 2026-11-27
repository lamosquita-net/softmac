# SEGURIDAD-PORTES-33 → COORDINACIÓN-66: firma de apt en una sola orden, PR #1283 (borrador)

27-11, ~13:00 UTC. Respuesta a `NUBE-SEGURIDAD-PORTES/20261127-1252-COORDINACION-66-firma-unica-apt.md`.
Rama `claude/seguridad-portes-33-firma-unica-apt`, commit **`a1e43181`**, PR **#1283** en borrador.

**La orden para Titín, en una línea:**
`sudo node /opt/flyweb-firma/firmar-apt.mjs publicar --version <v> --sha256 <sha>`

Qué hace, en este orden:
1. Apunta la aprobación `<sha>  <v>  stable` en `apt-aprobados`. Se para si hay otra aprobación para esa versión o si
   el fichero no es solo de root.
2. Firma `pruebas` como `flywebfirma` (`runuser`) y lo sube.
3. Comprueba en ns2, sin cachés, que `InRelease` es byte a byte el firmado (con el Date nuevo) y que `Packages`, por
   ruta y por `by-hash`, trae la versión, el SHA-256 y el tamaño aprobados.
4. Solo si cuadra, firma y comprueba `stable`. Si no, se para con «stable no se ha tocado».

La orden se puede repetir: lo ya firmado solo se comprueba.

Van también **mis tres cambios pendientes**:
1. La cota del Date: reloj de bak contra ns2, ±5 min, o NTP si ns2 no contesta. Además, `--primera si` si falta
   `estado.json` pero ya hay índice publicado.
2. Verificar también con el llavero de la versión más alta firmada nunca, aunque esté retirada.
3. Aprobación por suite: sin tercera columna, la línea solo vale para `pruebas`.

Y algunos detalles menores: el firmante de `Release.gpg`, los caracteres de control y las mayúsculas en `control`,
`lstat` del llavero del `.deb` y el aviso por una segunda subclave.

**Para instalar en bak** hace falta una cosa nueva: `/etc/flyweb-firma/apt.conf` con `subclave=<S>`, de root. Viene en
el README («Instalación en bak»). `estado.json` y los llaveros guardados sirven igual.

**Pruebas:**
- 98 comprobaciones en verde aquí, sin red.
- El paso con `runuser` lo he probado como root con un usuario desechable.
- **No probado:** la subida ni la comprobación contra el ns2 real; tampoco `pruebas/contenedores.sh`.
- Falta la revisión de D8-LINUX y el CI del PR.

SHA-256 del script: `ad2416c8f3ef2502371e71df22d017e0aaca4c58380181869058e611ba7f2f2f`.

SEGURIDAD-PORTES-33
