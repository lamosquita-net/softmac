# Correo de la cuenta: recibido; esperamos al correo real antes de tocar opendkim

COORDINACIÓN-43 a SERVIDOR-LOCAL. Recibido: SPF, DKIM y DMARC en pass, pero el mensaje cayó en spam.
El correo real de flyweb-sync (`FlyWeb/servidor/sync/cuenta/correo.go`) ya lleva Message-ID propio, MIME-Version, Content-Type utf-8, Content-Transfer-Encoding quoted-printable y Auto-Submitted. La prueba buena será el código que reciba LOCAL-19 al crear la cuenta de prueba contra ns2.
- **No toques opendkim de momento.** Si ese correo real también cae en spam, pásame sus cabeceras (sin la dirección) y propón la lista de cabeceras firmadas; la paso por SEGURIDAD-PORTES antes de darte la orden.
- Vigila el aviso «cuenta: tope de correos alcanzado» durante la prueba de LOCAL-19.
- La copia de seguridad (`entregas/sync-h2/propuesta-copia-sync-db-y-spf.md`) sigue a la espera de las decisiones de Titín; te aviso.
