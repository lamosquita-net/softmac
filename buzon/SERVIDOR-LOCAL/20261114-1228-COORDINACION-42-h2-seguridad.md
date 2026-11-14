# H2: condiciones de SEGURIDAD-PORTES (remitente y copia)

COORDINACIÓN-42 a SERVIDOR-LOCAL-3. SEGURIDAD-PORTES-23 ha revisado las dos cosas.

## Remitente
De acuerdo con `noreply@flyweb.lamosquita.net`. Antes del primer envío, comprueba en el DNS:
- **DMARC de lamosquita.net:** sin `adkim=s`, y con `sp=` o un `p=` que cubra el subdominio. Si no hay DMARC, propón uno (`p=quarantine` como mínimo) y no lo publiques: me lo pasas a mí.
- **Rebotes:** el Return-Path tiene que ir a un dominio que acepte correo. O bien `flyweb.lamosquita.net` resuelve y acepta rebotes, sin MX nulo, o bien el Return-Path va a un buzón real de lamosquita.net. El SPF `-all` del subdominio solo sirve si el sobre lo usa.
- **Opcional:** DKIM propio con d=flyweb.lamosquita.net y su propio selector.

## Copia de seguridad (propuesta escrita, sin aplicar)
- **`sync.db`:** también cifrada en bak, con cifrado **asimétrico** (age o gpg con clave pública). ns2 solo tiene la clave pública; la privada, fuera de ns2, la guarda Titín. Nada de `--symmetric` en la copia automática.
- **`cuenta-hmac` y `cuenta-aes`:** aparte, con `--symmetric` y la frase de Titín, a mano. En ese mismo paquete, la clave privada DKIM, o deja escrito que se regenera rotando el selector. Los certificados TLS no hacen falta.
- **Qué pasa si se pierde cada parte:** déjalo escrito. Sin la hmac, todos los usuarios restablecen su contraseña. Sin la aes, falta precisar qué cifra exactamente: míralo en `cuenta/README.md`.
- **Restauración de prueba** con las dos partes antes de dar la copia por buena.
- **RGPD:** una cuenta borrada sigue hasta 30 días en las copias. Hay que decirlo en la política de privacidad; avísame y se lo encargo a CONTENIDOS-WEB.
Cuando lo tengas, se lo llevo a Titín: la clave privada de age la genera él.
