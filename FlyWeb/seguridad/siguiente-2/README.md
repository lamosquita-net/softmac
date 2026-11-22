# Seguridad: tanda siguiente-2 (base 3.2.1)

Lo que llegue después de la 3.2.1 y **no** sea Alto, Crítico o KEV se prepara aquí (orden de COORDINACIÓN-59/60). Lo
prepara SEGURIDAD-PORTES (-33). **En qué versión entra lo decide Titín**; hasta entonces, sin fusionar y sin versión.

## Base

| Repo | Base | Parches | Árbol resultante |
|---|---|---|---|
| brave-core | árbol **`de0b6a69c9`** (la 3.2.1 sin el commit de versión, = resultado de `siguiente/brave-core/0001`–`0003`) | `brave-core/0001` | **`c881f8b1b3`** |
| chromium | sin cambios (árbol de la 3.2.1 sin VERSION, `a2ffc0a48f`) | — | — |

Comprobado: `git am` de `brave-core/0001` sobre `de0b6a69c9` da `c881f8b1b3`; `git diff --diff-filter=D` vacío; los
cuatro `patches/*.patch` que toca se aplican limpios sobre los ficheros de Chromium de la 3.2.1 sin VERSION y dan el mismo
resultado que se editó. **No compilado ni probado aquí** (no hay árbol de compilación en la nube).

## `brave-core/0001`: cookies con clave temporalmente ausente

Encargo de COORDINACIÓN-60 (22-11), a raíz del papel U3 de Linux de D8-LINUX-5 (`buzon/COORDINACION/20261122-1548-…`
y su v2) y de las notas `…-1600` y `…-1623-SEGURIDAD-PORTES-33.md`.

**El fallo:** al cargar, una cookie cifrada cuyo proveedor de claves solo está **temporalmente** sin clave (llavero o
Secret Service bloqueado o denegado en ese arranque) se perdía para siempre, aunque la clave vuelva en el siguiente arranque:
- valor `fw1`: nuestro parche borraba su fila;
- cualquier otro formato: upstream pone `ok = false` y `LoadCookiesForDomains` borra **todo el grupo eTLD+1**
  («For data consistency, we drop the entire eTLD group»).

**El arreglo:**
1. `net::CookieCryptoDelegate::DecryptStringWithTemporaryFailure()` (nuevo, `patches/net-extras-sqlite-cookie_crypto_delegate.h.patch`):
   como `DecryptString()` y además dice si el fallo es temporal. Por defecto, nunca lo es (otros delegados no cambian).
2. `CookieOSCryptAsyncDelegate` (`patches/services-network-network_context.cc.patch`) lo implementa con
   `os_crypt_async::Encryptor::DecryptFlags::temporarily_unavailable`, que el `Encryptor` pone cuando el prefijo del dato
   es de un proveedor que devolvió `kTemporarilyUnavailable` (`key_ring_[tag] = nullopt`).
3. `SQLitePersistentCookieStore` (`patches/net-extras-sqlite-sqlite_persistent_cookie_store.cc.patch`), si el fallo es temporal:
   - **no carga la fila, no la borra y no pone `ok = false`** (no cae el eTLD+1);
   - la apunta por `host_key`. En la **primera escritura** de la sesión (alta, borrado o acceso) para ese `host_key`,
     borra antes esas filas exactas, con la clave única y el mismo mecanismo que las no canónicas de la 156. Así la
     escritura no choca con el índice único y no reaparece el valor viejo.
   - Un `fw1` ilegible **con la clave presente** (valor corrupto, o proveedor no registrado) se sigue borrando solo, como antes.
4. Prueba unitaria `SQLitePersistentCookieStoreTest.TemporarilyUndecryptableRowIsKept`, en el parche del `_unittest.cc`, en tres pasos:
   1. sin clave y sin escritura, la fila se queda y el resto del eTLD+1 carga;
   2. con clave, vuelve con su valor;
   3. sin clave y con una escritura de esa cookie, el valor nuevo se guarda y el viejo no vuelve.
   La prueba de la 3.2.1 `UndecryptableFw1DropsOnlyItsRow` sigue igual.
5. `components/flyweb_os_crypt/README.md` al día.

**Alcance: Mac y Linux.** El cambio es de código compartido (`net`, servicio de red), sin `#if`.
- **Mac:** el proveedor `fw1` ya devuelve `kTemporarilyUnavailable` ante cualquier fallo del llavero (README de
  `flyweb_os_crypt`), así que con el llavero denegado las cookies `fw1` dejan de perderse. Si el `KeychainKeyProvider`
  de Chromium también lo hace, igual con las `v10`. Lo segundo no lo he comprobado.
- **Linux:** es la condición que puse para la opción B de U3 antes de U5.

**Límite conocido (para U5):** sin ninguna escritura para ese `host_key` en la sesión, un cierre de sesión que solo
caduque esa cookie no genera operación en el almacén. El valor viejo reaparecerá en el siguiente arranque con clave.
Casi siempre un cierre de sesión escribe otra cookie del mismo host, y eso ya lo borra.

**Para LOCAL:** `net_unittests --gtest_filter='SQLitePersistentCookieStoreTest.*'` en la 7,1.
En U5, la prueba con el llavero cerrado y denegado: ninguna cookie borrada.
