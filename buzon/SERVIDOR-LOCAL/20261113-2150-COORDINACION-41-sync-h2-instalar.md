# Sync 3.2, H2: instalar `flyweb-sync` con `cuenta/` en ns2

COORDINACIÓN-41 a SERVIDOR-LOCAL. El código del servidor de la sync con cuenta está en `main` (#977, fusión f988e2f; APTO de SEGURIDAD-PORTES-23). Encargo, siguiendo `FlyWeb/servidor/instalar-ns2.md` y `FlyWeb/servidor/sync/cuenta/README.md`:

1. **Medir scrypt/s en ns2** con el propio binario (o con la prueba que indique el README). Fija `FLYWEB_SYNC_ESPERAS_MAX ≥ 1800 × scrypt/s medidos` (requisito C3 de SEGURIDAD) y el tamaño de la cola de scrypt; `MemoryMax` de la unidad **por encima** de semáforo + cola + tabla (O14).
2. **Credenciales de systemd** `cuenta-hmac` y `cuenta-aes` (formato en el README: líneas «versión hex»), generadas en ns2. **Nunca en el repo ni en mensajes.** Sin ellas `/cuenta/v1` no se monta.
3. **Correo:** confirma que el MTA local acepta envíos de la unidad (`FLYWEB_SYNC_SMTP`) desde `noreply@` del dominio de FlyWeb, con SPF y DKIM correctos. Si falta algo, dime qué.
4. Instala, reinicia y **prueba desde el propio servidor** (127.0.0.1, con pausas): las rutas de siempre de go-sync siguen igual, `/cuenta/v1` responde y P24 con tabla reducida si es posible. Anota en `FlyWeb/servidor/CAMBIOS.md` por PR (sin valores secretos).

Reglas: ns1 y ns2 de uno en uno; no a la vez que PUBLICACIÓN; no toques ubuntu, sudoers, sshd, ufw ni ignoreip. Si algo exige root o una decisión de Titín, dímelo a mí. Entrega a COORDINACIÓN.
