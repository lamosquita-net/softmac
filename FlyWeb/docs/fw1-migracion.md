# `fw1` en la 2.5.0: código, migración `v10` → `fw1` y pruebas de LOCAL (FM.51, FS.25)

MOTOR-34, 30-10-2026. Primera parte de la 2.5.0 (nivel 136). Diseño: [`cifrado.md`](cifrado.md); receta:
[`fw1-receta.md`](fw1-receta.md) (sus rutas y líneas de la 128 se han comprobado contra el código: valen).

**Rama:** brave-core `nube/motor-136` = `local/240-arreglos` 778fd91ca9 + **841029d2** (un commit). Sin compilar.
**Subida** el 30-10 ~10:20 UTC (Titín aprobó `add_repo` con push en la sesión de MOTOR-34; comprobado con `git ls-remote`).

## 1. Qué hace

| Pieza | Dónde | Qué |
|---|---|---|
| Proveedor | `components/flyweb_os_crypt/fw1_key_provider_mac.{h,mm}` (nuevo) | Clave aleatoria de 256 bits en Base64 en el llavero clásico, servicio «FlyWeb Safe Storage», cuenta **«FlyWeb fw1»** (la de `v10` es «FlyWeb»). Etiqueta `fw1`, precedencia 20, `IsCompatibleWithOsCryptSync() == false`. Si no hay ítem, lo crea; si el ítem no es Base64 de 32 bytes, **no** construye la clave (el `Key` haría `CHECK`) y no lo toca. Con `--use-mock-keychain`, sin clave. Llavero en el *thread pool*. Histograma `FlyWeb.OSCrypt.Fw1KeyResult` (0 encontrada, 1 creada, 2 lectura fallida, 3 alta fallida, 4 ítem malo, 5 llavero falso) |
| Registro | `chromium_src/chrome/browser/browser_process_impl.cc` + `patches/chrome-browser-browser_process_impl.cc.patch` (1 línea, macro) | Añade el proveedor a la lista de `OSCryptAsync` en Mac |
| Guarda | `chromium_src/components/os_crypt/async/common/encryptor.cc` + `patches/components-os_crypt-async-common-encryptor.cc.patch` (1 línea, macro) | Un dato `fw1` que ninguna clave abre **falla**. Sin esto iría a OSCrypt síncrono, que en Mac devuelve tal cual lo que no empieza por `v10` («texto en claro antiguo»): el texto cifrado acabaría como valor de cookie o de contraseña |
| Contraseñas | `chromium_src/…/password_features.cc` | `kUseAsyncOsCryptInLoginDatabase` encendida en Mac: `Login Data` usa el `Encryptor` |
| Pruebas | `fw1_key_provider_mac_unittest.mm` en `brave_unit_tests` | 8 casos con un llavero en memoria (§3) |
| GN | `browser/sources.gni` (dep en Mac), `test/BUILD.gn`, `chromium_src/chrome/browser/DEPS` | — |

Cookies: no hace falta nada; `kUseOsCryptAsyncForCookieEncryption` ya está activa en la 128 y el servicio de red recibe el
`Encryptor` entero.

## 2. Migración `v10` → `fw1`

**Perezosa, como Windows con DPAPI:** no se reescribe nada al arrancar. Lo `v10` se sigue leyendo (el `Encryptor` cae a
OSCrypt síncrono con la clave «FlyWeb»); cada cookie o contraseña **nueva o modificada** se escribe `fw1`. Las cookies se
renuevan solas con el uso; las contraseñas que no se tocan se quedan en `v10` (siguen protegidas igual que hoy). La clave
`v10` no se borra nunca. Se queda en `v10` lo que no pasa por `os_crypt_async` en la 128: autorrelleno (`Web Data`),
metadatos de sync de contraseñas y lo que use `OSCrypt::` directamente.

Reescritura activa: fuera de la 2.5.0. Upstream la trae con `DecryptFlags::should_reencrypt` (ya está en el 136); se
portará cuando haga falta, no ahora.

**Vuelta atrás:** una versión sin `fw1` (2.4.0 o anterior) lee los datos `fw1` como basura (el defecto de OSCrypt de §1):
se pierden las sesiones de las webs cuyas cookies ya son `fw1` y las contraseñas `fw1` salen ilegibles. No cae. Sparkle no
baja de versión; solo pasa si alguien instala a mano una anterior. Para las notas de la versión.

## 3. Pruebas para LOCAL

Herramienta: [`FlyWeb/tools/fw1-perfil.sh`](../tools/fw1-perfil.sh) `[perfil]`: cuenta prefijos (`v10`, `fw1`, otro) en
`Cookies` y `Login Data` y dice si existen los dos ítems del llavero. No imprime claves ni valores.

0. **Compilación y unitarias:** `brave_unit_tests --gtest_filter='Fw1KeyProviderTest.*'` (8 en verde). Si `gn` se queja de
   `DEPS`/`include_rules` o de `Security.framework`, es de `components/flyweb_os_crypt/BUILD.gn`: arreglarlo en `local/*`
   y avisar.
1. **Perfil envejecido** (el mismo de la prueba de fijadas: 1.15 → 2.0 → 2.1.1 → 2.4.0), **copiado**; con sesión abierta en
   claude.ai y GitHub y al menos 2 contraseñas guardadas. `fw1-perfil.sh <copia>`: todo `v10`, sin ítem «FlyWeb fw1».
2. **Primer arranque de la 2.5.0** con la copia (`--user-data-dir`): sigue la sesión en claude.ai y GitHub; las contraseñas
   se autorrellenan; `chrome://histograms/FlyWeb.OSCrypt` = 1 (creada) y `OSCrypt.AsyncInitialization.Result` = true.
   **Sin diálogo para «FlyWeb fw1»** (uno para «FlyWeb» con un binario de prueba es lo de siempre: ese ítem lo creó la
   Release firmada).
3. Navegar, guardar una contraseña nueva y cambiar otra; salir. `fw1-perfil.sh`: aparecen filas `fw1` en las dos bases,
   siguen las `v10` y existe «FlyWeb fw1».
4. **Segundo arranque:** todo sigue igual; histograma = 0 (encontrada); sin diálogo.
5. **Ítem corrupto:** `security add-generic-password -U -s "FlyWeb Safe Storage" -a "FlyWeb fw1" -w "malo"` y arrancar:
   **no cae**, histograma = 4, se pierden las sesiones de las cookies `fw1` y lo `v10` sigue. Las cookies nuevas, `v10`.
6. **Vuelta atrás** con la 2.4.0 sobre una copia de la copia: no cae, las webs con cookies `fw1` piden sesión (esperado, §2).
7. **6,1 (Mojave):** pasos 1–4 (el llavero clásico en 10.14). La 5,1, cuando se pueda (no bloquea).
8. **Arranque en frío:** `OSCrypt.AsyncInitialization.Time` con y sin ítem; anotar las cifras.
9. **Al terminar, borrar el ítem de prueba:** `security delete-generic-password -s "FlyWeb Safe Storage" -a "FlyWeb fw1"`
   en la 7,1 y la 6,1. **Obligatorio:** lo creó un binario de prueba, y su lista de acceso no incluye la Release firmada:
   el FlyWeb de diario de Titín pediría permiso al actualizarse (o, si lo deniega, se quedaría en `v10`).

Si algo de 1–4 falla, es bloqueante (se pierden datos); 5–8, no.

## 4. Revisión de seguridad (regla 17)

Hecha por MOTOR-34 comparando con upstream los dos ficheros de los que `fw1` depende (`encryptor.cc` y `os_crypt_async.cc`,
128 frente a 136.0.7103.113 y 140.0.7339.207). Pendiente la de SEGURIDAD-PORTES si COORDINACIÓN la pide aparte.

| # | Qué | Estado |
|---|---|---|
| 1 | **Dato `fw1` sin clave tratado como texto en claro** por el *fallback* a OSCrypt síncrono (Mac) | **Arreglado** (guarda de §1). Upstream lo corrigió a medias en el 136 («clave presente y fallo = permanente»); su caso «clave temporalmente no disponible» sigue cayendo a OSCrypt, el nuestro no |
| 2 | `CHECK` de longitud al construir `Key` con un ítem malo | Evitado: se valida antes; prueba `BadItemFallsBackToV10` |
| 3 | Borrado de contraseñas indescifrables | `DeleteUndecryptableLogins` solo mira `OSCrypt::IsEncryptionAvailable` (la clave `v10`). Con la guarda, si falta la clave `fw1` y sync está activo, `kClearUndecryptablePasswordsOnSync` (de serie en Mac) borra las `fw1` locales y sync las vuelve a bajar. Sin sync no se borran (`kClearUndecryptablePasswords` apagada). Aceptado: es el comportamiento de upstream |
| 4 | Nonce aleatorio de 96 bits | Límite de NIST SP 800-38D §8.3: 2³² cifrados por clave; muy por encima del uso de un perfil |
| 5 | Sin datos asociados (AAD) | Quien puede escribir la base puede cambiar un valor cifrado de fila; igual que `v10`. No se cambia (rompería el formato de upstream) |
| 6 | Clave en claro en memoria (sin `CryptProtectMemory` en Mac) y viaja por mojo al servicio de red | Paridad con `v10` y con Windows; no se presenta como defensa frente a un *infostealer* |
| 7 | Upstream endureció `os_crypt_async.cc`: solapes de etiqueta y precedencias repetidas, de `DCHECK` a `CHECK` | No aplica: un solo proveedor en Mac (sin solapes) |
| 8 | Lista de acceso del ítem | Lo crea el binario que lo usa (sin diálogo); el de una compilación de prueba hay que borrarlo (§3, paso 9) |

## 5. Para la web (regla 12)

FlyWeb 2.5.0 cifra las cookies y contraseñas nuevas con AES-256-GCM, cifrado autenticado con una clave propia de 256 bits
guardada en el llavero de macOS, acelerado por la CPU en todas las Mac compatibles (también en las Mac Pro sin AVX). Lo ya
guardado se sigue leyendo y pasa al formato nuevo a medida que se usa. No protege frente a un programa malicioso que corra
con tu usuario (ningún navegador lo hace); lo que mejora es que los datos cifrados no se pueden alterar sin que se note.
Si se vuelve a instalar a mano una versión anterior, habrá que iniciar sesión otra vez en algunas webs.

## 6. Estado de la entrega

- 841029d2 en `nube/motor-136` (subida tras aprobar Titín `add_repo`). Orden a LOCAL: `buzon/LOCAL/20261030-1020-MOTOR-34.md`.
- Los 3 arreglos de compilación de LOCAL de la 2.4.0 (679e7e5c) ya están en la base de la rama y quedan estandarizados en
  `FlyWeb/tools/port/api128.sh` + `api128-faltan.tsv` (aviso antes de entregar si un parche vuelve a usar esas APIs) y en
  `docs/TRAMPAS.md`.
