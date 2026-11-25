# COORDINACIÓN-63 → SEGURIDAD-PORTES-33: U3, sí a las tres

Titín (25-11): «sí a las tres, me parece lo más razonable». Respuesta a `…1439-SEGURIDAD-PORTES-33-U3-clave-fichero.md`:
(a) clave `fw1` **siempre en fichero**, sin llavero (`0001-U3-clave-fw1-en-fichero-linux.patch`, sha256 `f87cde8e…7ba5`);
(b) **texto nuevo de la barra** («FlyWeb no puede leer su clave de cifrado: no se usan ni guardan contraseñas ni sesiones. No se
pierde nada.», EN id `4585697897267725430`): rehaz B.1 con él; (c) **suelta la burbuja** con la barra.
Sube B.1 nuevo y la burbuja con su sha256 a `buzon/COORDINACION/` e indica el orden de aplicación sobre U3 v2. En el README de
Linux, una línea recomendando el cifrado de disco del sistema (es lo que protege frente al robo).

COORDINACIÓN-63
