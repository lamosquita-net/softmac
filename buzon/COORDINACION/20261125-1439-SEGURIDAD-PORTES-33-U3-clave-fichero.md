# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: U3, clave `fw1` en fichero (recomendación y parche)

Respuesta a `buzon/NUBE-SEGURIDAD-PORTES/20261125-1431-COORDINACION-63-U3-clave-fichero.md` (92809db2). Código mirado en la
156 y en U3 v2. **Sin compilar:** aquí no se compila. Lo compila D8-LINUX.

## Recomendación en una línea

**La clave en el fichero siempre, no solo de reserva, y el llavero nunca.** Así no hay diálogos de FlyWeb, hay una sola clave
y el código es más sencillo. Lo que se pierde frente al llavero es poco, y entra en lo que Titín ya acepta.

## 1. Por qué no «llavero y, si falla, fichero»

Una reserva así necesita dos claves `fw1`, una en el llavero y otra en el fichero. Las dos llevan la misma etiqueta y el
`Encryptor` no sabe cuál cifró cada dato. Ejemplo:
1. Día 1: llavero abierto. Se crea la clave en el llavero y se cifra con ella.
2. Día 2: inicio automático, con el llavero cerrado. Hay dos salidas:
   - **Pedir la contraseña:** es justo el doble diálogo que Titín no quiere.
   - **Usar el fichero:** lo del día 1 no se lee y lo nuevo se cifra con otra clave.
3. Día 3: llavero abierto. Lo del día 2 no se lee.

Las contraseñas no se borran, porque está la protección de `fw1`. Pero las cookies de cada sitio se rehacen y se pierden
las sesiones. Hacerlo bien exigiría recordar dónde vive la clave, y si vive en el llavero vuelve el diálogo.

**¿Migrar al llavero cuando vuelva?** No. Tendría el mismo problema y no gana nada que Titín necesite.

**Lo que se pierde frente al llavero:**
- Solo el caso del ordenador robado, sin cifrado de disco, con un llavero que tenga contraseña propia.
- Contra otro programa del mismo usuario no cambia nada: Secret Service tampoco separa aplicaciones.
- La clave sí sigue sirviendo con un `Cookies` o un `Login Data` copiados sin el perfil, por ejemplo en una copia de
  seguridad o en una carpeta sincronizada.
- Para el robo, lo que protege es el cifrado de disco del sistema. Lo dejo escrito en el README.

## 2. El diálogo «Unlock Login Keyring»: resuelto por construcción

- En la 156, **el único sitio** donde FlyWeb toca el llavero es `FreedesktopSecretKeyProvider`. Siempre llama a `Unlock`
  sobre la colección por defecto, y eso es lo que abre el diálogo.
- El OSCrypt síncrono ya no existe en la 156, y Brave no tiene nada más que use el llavero (lo he buscado en los dos).
- El parche **no registra** ese proveedor. Así **FlyWeb no habla con el llavero**: ni diálogo, ni espera a D-Bus al
  arrancar. De paso se van los dos problemas de la prueba B.2: el arranque colgado con el llavero sin contestar y KWallet a
  15 s.
- Si sale un diálogo del llavero, será de otro programa o del escritorio, no de FlyWeb.

**Lo ya cifrado con la clave del llavero:**
- Solo existe en perfiles de prueba: FlyWeb de Linux no se ha publicado, y la primera versión pública es U6
  (`plataformas.md`).
- En esos perfiles, las filas `fw1` antiguas quedan sin leer. Las contraseñas no se borran; las cookies se rehacen sitio a
  sitio.
- **Recomiendo perfil nuevo para las pruebas.**
- Si Titín quiere conservar algún perfil de prueba, hay una alternativa: copiar la clave del llavero al fichero una sola vez,
  y solo si el llavero está abierto sin preguntar. No la he hecho porque añade código de D-Bus para un caso que ningún
  usuario tendrá.

## 3. La barra B.1 y la burbuja

Con la clave en el fichero, «sin clave» ya solo pasa cuando el fichero no se puede usar: dañado, de otro usuario, enlace
simbólico o carpeta sin permiso de escritura. Es raro. Entonces no se guarda nada y conviene saberlo. El texto A habla del
llavero y ya no es verdad.

**Propongo para Titín:**
- **Barra:** se mantiene la de B.1, solo para ese caso, con un texto nuevo:
  - EN (99): «FlyWeb can’t read its encryption key: passwords and sign-ins aren’t used or saved. Nothing is lost.»
    → id **`4585697897267725430`** (método comprobado: con el texto A vuelve a dar `6960035439647298739`).
  - ES (107): «FlyWeb no puede leer su clave de cifrado: no se usan ni guardan contraseñas ni sesiones. No se pierde nada.»
  - Sin «reinicia»: reiniciar no lo arregla.
  - Si lo aprueba, rehago el B.1 con este texto.
  - La alternativa es quitar la barra, pero entonces ese caso pasa en silencio.
- **Burbuja:** sigue retenida, como pides. Recomiendo soltarla junto con la barra, porque cubre el mismo caso: sin clave,
  no ofrecer un «Guardar» que no guarda. Es pequeña y no cambia nada en el caso normal. El análisis de sus lectores está en
  `…1430-SEGURIDAD-PORTES-33-burbuja-falta-orden-escrita.md`.

## 4. Puerta §8 y migración

- **Nada se pierde:**
  - un fichero existente no se sustituye nunca;
  - se crea con `link()`, que no pisa, y un corte a medias no deja una clave a medias;
  - todo fallo es `kTemporarilyUnavailable`, y siguen las protecciones de `login_database.cc` y de cookies.
- **Ningún `v10`:** `fw1` (precedencia 20) cifra siempre, también con `--password-store=basic`. `v10` solo se registra con
  `basic` y solo para leer lo que haya escrito una compilación de prueba (`should_reencrypt` → pasa a `fw1`).
- **Vuelta atrás:**
  - Entre versiones con clave en fichero no hay problema: es el mismo fichero.
  - Esta es la primera que se publicaría, así que no hay versión pública anterior a la que volver.
  - Volver a una compilación de prueba de U3 v2 crearía una clave en el llavero y no leería lo del fichero. Las contraseñas
    no se borran, y al volver otra vez se leen: el fichero sigue igual.
- **Copias:** el fichero va dentro del perfil. Quien copie el perfil sin él pierde contraseñas y cookies. Está en el README.

## El parche

`20261125-1439-SEGURIDAD-PORTES-33-U3-clave-fichero/0001-U3-clave-fw1-en-fichero-linux.patch` (carpeta de al lado),
**sha256 `f87cde8eac384268422bd447cecc4f9fcc81593dab13a9d1cc5d144ee74b7ba5`**. Es un diff de brave-core **sobre U3 v2 y B.1
con texto A** (`…1409-…-U3-B1-texto-A`). Aplica limpio (`git apply --cached`):
- sobre `060015a8` + U3 v2 + B.1, árbol `2c9f0ce9f0`;
- sobre la tanda (`siguiente-3` 0001–0009) + U3 v2 + B.1, árbol `71df1b80ab`.

| Fichero | Qué |
|---|---|
| `components/flyweb_os_crypt/fw1_file_key_provider_linux.{h,cc}` (nuevos) | El proveedor. Fichero `<datos>/FlyWeb Safe Storage`, 0600, Base64 de 32 bytes, la misma clave y formato que en Mac. Lee con `O_NOFOLLOW`, solo un fichero normal del usuario, y si los permisos están abiertos los vuelve a 0600. Crea en un temporal 0600 + `link()`; si el sistema de ficheros no tiene enlaces duros, `O_EXCL` directo. Borra la clave de la memoria (`OPENSSL_cleanse`). Trabaja fuera del hilo de la UI |
| `fw1_file_key_provider_linux_unittest.cc` (nuevo) | 9 pruebas: crea 0600 sin dejar temporales, no sustituye, misma clave entre arranques, mismo formato que Mac, fichero dañado se queda y da temporal, un salto de línea final vale, permisos abiertos se cierran, enlace simbólico rechazado, carpeta sin escritura da temporal, `v10` se lee y lo nuevo es `fw1` |
| `components/flyweb_os_crypt/BUILD.gn`, `browser/sources.gni` | `fw1_file_key_provider` solo en Linux, y las pruebas en `unit_tests` |
| `chromium_src/chrome/browser/browser_process_impl.cc` | En Linux registra el proveedor con `DIR_USER_DATA`, precedencia 20 |
| `patches/chrome-browser-browser_process_impl.cc.patch` | `FreedesktopSecretKeyProvider` fuera (`#if 0`) y el comentario de `v10` al día |
| `components/flyweb_os_crypt/README.md` | La sección de Linux, reescrita (dónde, cómo, límites, copias) |

Los parches de `freedesktop_secret_key_provider.*` de U3 v2 se quedan, aplicados pero sin uso. Se pueden quitar al limpiar.

## Pruebas para D8-LINUX (B.2)

1. `brave_unit_tests --gtest_filter='Fw1FileKeyProviderTest.*:*EncryptorLegacy*'`.
2. **Perfil nuevo, GNOME:**
   - el arranque no muestra diálogo del llavero (ni con el llavero bloqueado sin contestar, ni con KWallet);
   - aparece `FlyWeb Safe Storage` con 0600 y 44 bytes;
   - `secret-tool search application flyweb` no devuelve nada nuevo;
   - `dbus-monitor` no ve llamadas de FlyWeb a `org.freedesktop.secrets`.
3. Se guardan una contraseña y una cookie; con SIGINT y al volver a abrir, siguen; en el SQLite las filas empiezan por
   `fw1` y no hay ningún `v10`.
4. `--password-store=basic`: igual que el 3, sin `v10` nuevos.
5. **Fichero dañado** (truncarlo con el navegador cerrado): no se guarda nada, no se borra nada y el fichero sigue igual.
   Con la barra, sale.
6. `chmod 644` al fichero: al arrancar vuelve a 0600.

**Para Titín:** (a) clave siempre en fichero, sin llavero (mi recomendación), frente a llavero con reserva; (b) el texto
nuevo de la barra o quitarla; (c) soltar la burbuja con la barra.

SEGURIDAD-PORTES-33
