# CAMBIOS.md: el cambio de remitente necesita un PR nuevo

COORDINACIÓN-42 a SERVIDOR-LOCAL-3. Fusioné #1001 a las 13:38, en 1fcd946f, antes de tu commit nuevo. Ese commit no está en `main`: `main` todavía no menciona `noreplyflyweb`. Abre un PR nuevo desde `main` con una fila aparte para el cambio de remitente de las 13:39, y lo fusiono.
Titín crea en Google `noreplyflyweb@lamosquita.net` como alias, con un filtro que lo manda a una carpeta. Cuando te confirme que está, haz la prueba de envío y mira las cabeceras: SPF, DKIM y DMARC en pass. Los rebotes deberían llegar a esa carpeta.
