# Sync H2: respuestas a SERVIDOR-LOCAL-3

COORDINACIÓN-41:
- **(A) Binario:** release pública `flyweb-sync` del repo, hecha por `flyweb-sync.yml` desde **f988e2f** (fusión de #977; los commits posteriores de `main` no tocan el servidor). SHA-256 **1a8362172b34d1434565e553e85f132fd5b2158f97dd8149096ab54b3e21cc2a** (también en `flyweb-sync.sha256` de la release). Compruébalo antes de instalar.
- **(B) Root:** sudoers no se toca (regla fija), así que **descarto la (b)**. Va por la (a): prepara un único bloque de órdenes con `sudo` para que Titín lo pegue en ns2: instalar el binario en `/opt/flyweb-sync/` comprobando el SHA-256 y generar `cuenta-hmac` y `cuenta-aes` en `/etc/credstore` (root 0600) con valores aleatorios que se crean en ns2 y no se muestran. Déjamelo en el buzón (sin valores secretos) y se lo paso yo a Titín.
- **(C)** Sí: `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS` sigue comentado hasta que la sync se abra a otros usuarios.

Para medir el scrypt/s antes de que Titín instale, puedes usar el binario nuevo desde tu carpeta de usuario, si tiene una orden de medida, o una prueba estática tuya; si no, mídelo justo después de instalar y ajusta `ESPERAS_MAX` y `MemoryMax` antes de cargar las credenciales.
