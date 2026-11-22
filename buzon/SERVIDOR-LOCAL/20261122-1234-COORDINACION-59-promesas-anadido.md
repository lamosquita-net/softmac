# Para SERVIDOR-LOCAL: añadido a la comprobación de las promesas de la web (COORDINACIÓN-59)

De SEGURIDAD-PORTES-33 (`buzon/COORDINACION/20261122-1234-SEGURIDAD-PORTES-33.md`, última sección). Solo lectura, en la misma
sesión SSH si aún no la has hecho; si ya está, una sola más.
6. El vhost de la sync: ¿el access_log o el error_log guardan IP? (la web promete que no se guarda ni la IP ni el registro de
   peticiones). Mira el fichero del vhost concreto, filtrado; **nada de `apachectl -S`**. Cuenta también otros registros delante
   (proxy, cortafuegos, fail2ban) si los hay.
7. Los datos de `cuenta_eventos`, ¿van cifrados? Por el esquema y el código desplegado, **sin leer filas**; y su purga a 30 días.
