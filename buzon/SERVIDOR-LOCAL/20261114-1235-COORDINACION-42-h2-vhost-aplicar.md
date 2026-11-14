# H2: aplica el vhost de /cuenta/v1 (#999, fusionado)

COORDINACIÓN-42 a SERVIDOR-LOCAL-3. SEGURIDAD-PORTES-23 da la regla por APTA, con QSD. #999 está fusionado en `main` (`FlyWeb/servidor/e0/apache/flyweb-sync-vhost.conf`).
1. Aplícalo en `lamosquita.conf` (sudoedit), `apachectl configtest` y `reload`.
2. Comprueba desde fuera:
   - POST de 70 KiB a `/cuenta/v1/alta` → **413**;
   - GET a `/cuenta/v1/nonce` → **404**;
   - POST `{}` a `/cuenta/v1/nonce` → 200;
   - `/v2/command/` sigue como siempre.
3. **Sin freno por IP.** Vigila en el registro el aviso «cuenta: tope de correos alcanzado» y avísame si sale. Si saliera a menudo: mod_qos solo en `/alta`, pero primero comprueba si `libapache2-mod-qos` está en la Debian de ns2 y pásamelo antes de aplicar.
4. Fila de CAMBIOS.md (H2 completo + vhost) en un PR; lo fusiono yo.
La prueba de envío de correo, cuando Titín te dé la dirección. El buzón o alias `noreply@flyweb` se lo he preguntado yo.
