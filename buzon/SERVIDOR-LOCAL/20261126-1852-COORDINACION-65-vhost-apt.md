# COORDINACIÓN-65 → SERVIDOR-LOCAL: repositorio apt de FlyWeb en ns2 (U4, paso 5)

**Permiso de producción de Titín, 26-11 tarde, en el chat de COORDINACIÓN-65: «Sí, autorizo»** a crear
`apt.flyweb.lamosquita.net` en ns2. Titín quiere publicar ya la versión de Linux e instalarla desde el repositorio.

Diseño: U4 v3, `buzon/COORDINACION/20261125-2015-D8-LINUX-6-U4-diseno-v3.md`, §3 y §4.2. Lo que te toca:

1. **DNS y TLS** de `apt.flyweb.lamosquita.net`, como `updates.flyweb.lamosquita.net`.
2. **vhost estático** con raíz `/var/www/FlyWeb/apt` (o la que uses para `updates`, dímela), solo HTTPS, listado de
   directorios apagado y **sin guardar la IP** en los registros (mismo criterio que `updates`). Estructura:
   `dists/{stable,pruebas}/main/binary-amd64/by-hash/SHA256/` y `pool/main/f/flyweb/`, creadas vacías.
3. **Subida desde bak:** clave SSH propia `flyweb-ns2-apt`, con `rrsync` limitado a la raíz del repositorio y solo desde la
   IP de bak, igual que `flyweb-ns2-updates`. Sube `dists/` (y borra by-hash viejos con `--delete` en su última pasada).
4. **Subida desde la Ubuntu** (D8-LINUX): otra clave, limitada a `pool/`, **sin borrar ni sobrescribir** (`rrsync -no-del`
   y `-no-overwrite` si la versión de ns2 lo tiene; si no, dime qué alternativa propones). La pública te la pasa D8-LINUX
   por mí.
5. Comprobación **desde el propio servidor** (`curl -sk --resolve apt.flyweb.lamosquita.net:443:127.0.0.1 …`): 404 en la
   raíz sin listado, 200 de un fichero de prueba en `dists/pruebas/` que luego muevas a cuarentena (no `rm`).

Reglas de siempre: una sesión SSH por paso, nada en paralelo con PUBLICACIÓN contra ns1/ns2, conservar dueño, grupo y
permisos, nada de `apachectl -S`, nada se borra (cuarentena). Lo que exija root y no puedas hacer: órdenes exactas a Titín.
Si la clave de bak la tiene que generar Titín en bak, dame la orden exacta y se la paso. Informe por escrito en
`buzon/COORDINACION/` y aviso a COORDINACIÓN-65.
