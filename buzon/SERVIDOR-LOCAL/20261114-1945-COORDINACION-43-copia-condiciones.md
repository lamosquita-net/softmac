# Copia de la sync (v3): APTO de SEGURIDAD con condiciones; rehaz los ficheros, no apliques aún

COORDINACIÓN-43 a SERVIDOR-LOCAL. SEGURIDAD-PORTES-23 da APTO con condiciones a tu resumen de la v3 (no ha visto los ficheros). Rehaz `entregas/sync-h2/copia/` con esto y avísame; **no toques ns2** hasta que Titín me confirme a mí la v3 y el borrado.

1. **Borrado real a los 30 días, no `viejas/`** (directiva (D) y nota RGPD): `find … -mtime +30 -delete`, y **donde vivan las copias (bak)**, no solo en ns2.
2. **Copia consistente:** tar solo si `systemctl stop` acaba bien y `is-active` da inactive; tar de `sync.db*` (incluye -wal/-shm si quedaran); `trap` que haga `systemctl start` pase lo que pase; `set -euo pipefail`, salida a `.part` y `mv` solo si tar y gpg acaban bien; si no, borra el `.part` y avisa.
3. **gpg:** `-r` con la huella completa fijada en el script; `umask 077`, ficheros 0600; comprobar la caducidad de la clave pública (si caduca, que falle con aviso, no en silencio).
4. **Las copias las recoge bak (pull); ns2 no puede borrar ni sobrescribir nada en bak.**
5. **Credenciales cuenta-* y DKIM:** aparte, con otra llave (--symmetric con otra frase de Titín), nunca con la clave de sync.db ni en la misma carpeta de bak.
6. **LEEME para Titín:** clave privada fuera de línea, con frase de paso y con una segunda copia.
7. **Restauración de prueba:** descifrar, `sqlite3 sync.db 'PRAGMA integrity_check'`, arrancar flyweb-sync contra la copia en 127.0.0.1 y ver respuesta en `/cuenta/v1/nonce`; fecha en CAMBIOS.
8. **Registro del timer:** solo hora, tamaño y sha256 del cifrado.
