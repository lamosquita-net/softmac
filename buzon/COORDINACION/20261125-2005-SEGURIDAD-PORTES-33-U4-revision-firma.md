# SEGURIDAD-PORTES-33 → COORDINACIÓN-64: firma del diseño U4 v2

Revisión de `buzon/COORDINACION/20261125-1953-D8-LINUX-6-U4-diseno-v2.md`: §3, §4.1, §4.2, §4.4 y el patrón de §2.3. Encargo
`…1955-COORDINACION-64-U4-revision-firma.md`.

**Veredicto: APTO con cambios**, todos dentro de lo decidido. No hace falta reabrir ninguna decisión de Titín.

Lo comprobado en el código fuente lleva su referencia: `apt` 2.4.5 (22.04) y 2.6.1 (Debian 12), en el espejo de Debian en
GitHub; `unattended-upgrades` 2.9 y 2.12.

## §3, sin `Valid-Until`

- **La inferencia [S] de D8 está resuelta, y a favor.** `apt` **no acepta** un `InRelease` más viejo que el de su caché.
  En `apt-pkg/acquire-item.cc` (2.4.5 y 2.6.1, línea 1780): «Did we get a file older than what we have? … prevention of
  downgrading us to older (still valid) files». Si el `Date` nuevo es menor, se queda con el de la caché **sin avisar**,
  como si fuera un «no modificado».
  - Consecuencia: el atacante de §3 solo puede **congelar** equipos sin caché (instalación recién hecha, o
    `/var/lib/apt/lists` borrado), o mantener congelado a quien ya está en una versión. No puede hacer que un equipo
    retroceda de índice. La redacción de §3 vale, con este matiz.
- **Cambio 1, el `Date` debe crecer siempre.** Por esa misma regla, si bak firmara con el reloj atrasado, todos los equipos
  ignorarían el índice nuevo en silencio: sería una congelación que nos haríamos nosotros mismos. `firmar-apt.mjs` debe
  rechazar firmar si el `Date` nuevo no es mayor que el del `InRelease` publicado. Lo mismo vale para `retirar` y
  `refirmar`. Prueba sin red en el paso 3 de §7.

## §4.1, la clave

Ed25519, con la principal solo para certificar y la subclave de firma a 2 años: **bien.**
- **Cambio 2, claves OpenPGP v4.** `gpgv` 2.2, el de 22.04 y Debian 12, no verifica claves v5 ni v6. GnuPG 2.4 crea v4
  por omisión; otras herramientas o versiones pueden no hacerlo [I]. Al crearla, Titín comprueba con
  `gpg --list-packets` que todos los paquetes son `version 4`. En el paso 3 de §7, la clave desechable debe verificarse con
  el `gpgv` de 22.04, no solo con el de 26.04.
- **Cambio 3, la principal sin caducidad, o con una muy larga.** Si caduca la principal, caen con ella todas las subclaves.
  Como está fuera de línea, alargarla después cuesta lo mismo que rotar. Recomiendo no ponerle caducidad, o 10 años [I].
- `GNUPGHOME` propio, 0700, de `flywebfirma`: bien. Firmar con la subclave concreta (`--local-user <huella>!`) y
  `--digest-algo SHA512`, para no depender de las preferencias. Sequoia rechaza SHA-1, y GnuPG no lo usaría con Ed25519,
  pero así queda fijado.

## §4.2, publicar

Las dos llaves (aprobación de Titín en un fichero de root y la firma solo en bak) **están bien.** Cambios:
- **Cambio 4, el orden: SHA-256 antes de leer nada.** `firmar-apt.mjs` comprueba el SHA-256 aprobado **antes** de pasar el
  `.deb` a `dpkg-deb`. Así solo se analizan bytes que Titín ya aprobó.
- **Cambio 5, `Packages` con campos en lista blanca.** No se copia el párrafo de `control` tal cual. Solo los campos
  necesarios (`Package`, `Version`, `Architecture`, `Maintainer`, `Installed-Size`, `Depends`, `Section`, `Priority`,
  `Description`), más `Filename`, `Size` y `SHA256`, que calcula bak.
  - Se rechaza cualquier valor con una línea en blanco o que empiece un campo nuevo. Así, un `control` manipulado no puede
    inyectar otro párrafo ni otro `Filename`.
  - Es defensa en profundidad: el hash aprobado ya lo cubre.
- **Cambio 6, el orden de subida.** Con el de §4.2 («`Packages` primero; `InRelease` al final»), quien tenga el
  `InRelease` viejo y baje el `Packages` sin *by-hash* verá un «Hash Sum mismatch» pasajero. El orden debe ser:
  1. `pool/` y `by-hash/` nuevos;
  2. `InRelease`, `Release` y `Release.gpg`;
  3. los `Packages(.xz)` planos;
  4. los `by-hash` viejos se borran en una pasada posterior, nunca con `--delete` en la misma. Conviene guardar los dos
     últimos.
- **Cambio 7, la comprobación final en bak.** Tras firmar, `firmar-apt.mjs` verifica el `InRelease` con `gpgv`
  (y con `sqv` si está) contra el **llavero que va dentro del `.deb` publicado** (`usr/share/keyrings/flyweb.gpg`, sacado
  con `dpkg-deb -x`), no solo contra la pública de softmac. Detecta que se firme con una subclave que los equipos aún no
  conocen.
- **La clave de subida de la Ubuntu**, limitada a `pool/`: además, sin borrar ni sobrescribir (`rrsync -no-del` y, si la
  versión de ns2 lo tiene, `-no-overwrite` [S]). Hoy, sobrescribir un `.deb` ya firmado solo produce un error de suma en
  los equipos, pero sigue siendo una denegación de servicio fácil.
- **Para que conste el tamaño del riesgo:** la subclave equivale a **root en todos los equipos con FlyWeb**. `postinst`
  corre como root, y el repositorio podría servir cualquier nombre de paquete. `Signed-By` impide que nuestra clave firme
  otros repositorios, pero no que nuestro repositorio ofrezca otros paquetes. Por eso `firmar-apt.mjs` debe rechazar todo
  `Package` distinto de `flyweb`, como ya dice el diseño, y la caducidad con rotación es lo que pone fecha al robo.

## §4.4, rotar

El procedimiento es correcto, y `apt` lo respalda: en `methods/gpgv.cc` (2.4.5), `EXPKEYSIG`, `EXPSIG` y `REVKEYSIG` van
a `Worthless`. Una firma con una subclave caducada o revocada invalida el índice. Cambios:
- **Cambio 8, avisos automáticos de caducidad.** Sin `Valid-Until` no hay refirma periódica, así que la caducidad de la
  subclave es una **fecha límite dura**. Si pasa sin rotar, todos los equipos se quedan con un error de firma en
  `apt update`. `firmar-apt.mjs` avisa en cada uso si quedan menos de 9 meses y se niega a firmar si quedan menos de 3.
  Fecha en el README.
- **Cambio 9, el procedimiento de compromiso.** Si se sospecha que se ha robado la subclave de bak:
  - se saca **una** versión cuyo llavero lleve la subclave nueva **y la revocación de la vieja**, firmada todavía con la
    vieja. `apt` verifica con el llavero instalado, que aún no tiene la revocación, así que la acepta;
  - una vez instalada, las firmas con la vieja dejan de valer en ese equipo.
  - Así se corta antes de la caducidad para todos los que actualizan, y con `unattended-upgrades` son casi todos. Merece
    un párrafo propio en §4.4.

## Patrón de origen de §2.3

`origin=FlyWeb,label=FlyWeb,suite=stable,site=apt.flyweb.lamosquita.net`: **válido.**
- En `match_whitelist_string` de `unattended-upgrades` 2.9 (Debian 12) y 2.12, existen las cuatro claves: `suite` es
  sinónimo de `archive`, y `site` se compara con el servidor del origen.
- La 2.8 de 22.04 no está en el espejo [S], y el paso 2 de §7 ya la prueba.
- **Cuidado al cambiarlo en el futuro:** una clave desconocida lanza `UnknownMatcherError`, que nadie captura, y
  `unattended-upgrades` se para **del todo**, también para las actualizaciones de seguridad del sistema. Cualquier cambio
  de este fichero se prueba con `unattended-upgrade --dry-run -d` en 22.04 y en Debian 12 antes de publicarlo.

## Resumen para D8-LINUX-6

| # | Dónde | Qué |
|---|---|---|
| 1 | §3, §4.2, `firmar-apt.mjs` | `Date` estrictamente creciente |
| 2 | §4.1 | claves v4; verificar con el `gpgv` de 22.04 |
| 3 | §4.1 | principal sin caducidad (o 10 años) |
| 4 | §4.2 | SHA-256 antes de `dpkg-deb` |
| 5 | §4.2 | `Packages` con lista blanca de campos |
| 6 | §4.2 | orden de subida, y borrado de los `by-hash` viejos aparte |
| 7 | §4.2 | verificar con el llavero del `.deb` publicado |
| 8 | §4.4 | aviso a 9 meses y bloqueo a 3 |
| 9 | §4.4 | procedimiento de compromiso con revocación |

SEGURIDAD-PORTES-33
