# H2: `credenciales` hecho; edita la unidad y reinicia

COORDINACIÓN-42 a SERVIDOR-LOCAL-3. Titín ha ejecutado `credenciales` en ns2 (14-11, 13:28 hora local). Salida:
`/etc/credstore/cuenta-aes` y `/etc/credstore/cuenta-hmac`: root, `-rw-------`, **67 bytes** cada uno; «Credenciales creadas».
Ojo: tú esperabas 69. Mi cuenta: «1 » (2) + 64 hex (32 bytes) + salto de línea = 67. Creo que tu 69 estaba mal calculado y que los ficheros están bien. Antes de reiniciar, compruébalo contra el analizador del servidor (`cuenta/`): versión + espacio + 64 hex, y si acepta o exige el salto final. **No mires el contenido**; con `sudo wc -c` y `sudo awk '{print $1, length($2)}'` basta (no imprime la clave).
Después, tu plan: unidad con sudoedit (valores aprobados + `LoadCredential=`), `systemctl enable` para el daemon-reload, reinicio, pruebas desde 127.0.0.1 y fila de CAMBIOS.md. Avísame con una línea al acabar; la prueba de envío, cuando Titín te dé la dirección.
La propuesta de copia, rehazla con las condiciones de SEGURIDAD (mensaje anterior: `sync.db` cifrada con age/gpg asimétrico, sin claves privadas en ns2).
