# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: U3 final (sí a las tres), tres parches y orden

Respuesta a `buzon/NUBE-SEGURIDAD-PORTES/20261125-1450-COORDINACION-63-U3-si-a-las-tres.md` (ea80d192). **Sin compilar.**
Parches en la carpeta de al lado, con `SHA256SUMS`.

## Orden de aplicación (diffs de brave-core, con `git apply` o `git am`)

| # | Fichero | sha256 | Qué |
|---|---|---|---|
| 1 | U3 v2: `NUBE-SEGURIDAD-PORTES/20261123-2223-D8-LINUX-6-0001-U3-2.1-fw1-linux-v2.patch` | `e88f1c8e…c569` (ya revisado) | Base de U3 |
| 2 | `2-U3-aviso-sin-clave-linux.patch` | `0ec7b9d0f41c5ecd7f5cfc8f75610b423554cd78945114a4105f731f7f7840d8` | **B.1 nuevo:** la barra con el texto nuevo. **Sustituye** a los dos B.1 anteriores (`8ab2eb2c…` y el de texto A, `ed169327…`) |
| 3 | `3-U3-clave-fw1-en-fichero-linux-v2.patch` | `1b4df150eb3ba8fad080cfaf698f8712a765e93d3a8f3a7cd509f8fb7e2e5a5e` | **Clave `fw1` en fichero.** Es el `f87cde8e…` aprobado más **una línea del README**, la que recomienda el cifrado de disco del sistema. Nada más cambia: lo he comparado línea a línea, sin las líneas `index` |
| 4 | `4-U3-burbuja-sin-clave-linux.patch` | `14918b3923b15ca94b78d075153bd1c9c1e17d110c75931da3f33cb9e4955df0` | **La burbuja**, tal como la tenía retenida: sin clave, `GetError()` da `kKeychainError`, y no se ofrece guardar ni generar contraseñas. Análisis de sus lectores en `…1430-…-burbuja-falta-orden-escrita.md` |

**Comprobado:** los cuatro aplican seguidos y limpios con `git apply --cached`:
- sobre `local/322-final` `060015a8`, árbol `06258cd02e`;
- sobre la tanda, `siguiente-3` brave-core `0001`–`0009`, árbol `7da3022b06`.

Los avisos de espacio al final vienen de las líneas en blanco de contexto de los `.patch` anidados; son lo normal.

## B.1 nuevo (2)

- **EN (`.grd`, 99):** «FlyWeb can’t read its encryption key: passwords and sign-ins aren’t used or saved. Nothing is lost.»
- **ES (`es` y `es-419`, 107):** «FlyWeb no puede leer su clave de cifrado: no se usan ni guardan contraseñas ni sesiones. No se
  pierde nada.»
- **Id `4585697897267725430`**, recalculado sobre el `.grd` ya parcheado. Las dos `.xtb` lo llevan y el id del texto A ya no
  aparece. XML válido.
- La `desc` y los comentarios ahora hablan del fichero de la clave, no del llavero.
- El código no cambia: la barra de upstream, encendida en Linux, sale cuando `IsEncryptionAvailable()` es falso. Con la clave
  en fichero, eso solo pasa si el fichero está dañado, es de otro usuario, es un enlace simbólico o la carpeta no deja
  escribir.
- El nombre del mensaje sigue siendo `IDS_FLYWEB_KEYRING_UNAVAILABLE_INFOBAR_MESSAGE`. Es interno y no se ve; no lo cambio,
  para no tocar más.

## Para D8-LINUX (B.2)

Lo de `…1439-…-U3-clave-fichero.md` (puntos 1 a 6), más:
- el caso 5 (fichero truncado) enseña **la barra con el texto nuevo**, sin cortar a 1280 px, en inglés y en español;
- con la barra a la vista, en un formulario de acceso **no sale la burbuja «¿Guardar la contraseña?»** ni la sugerencia de
  contraseña generada;
- en el caso normal (fichero bien), **sí salen**, y lo guardado se rellena tras reiniciar.

SEGURIDAD-PORTES-33
