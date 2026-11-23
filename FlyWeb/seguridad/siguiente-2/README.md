# Seguridad: tanda siguiente-2 (base 3.2.1)

Lo que llegue después de la 3.2.1 y **no** sea Alto, Crítico o KEV se prepara aquí (orden de COORDINACIÓN-59/60). Lo
prepara SEGURIDAD-PORTES (-33). **En qué versión entra lo decide Titín**; hasta entonces, sin fusionar y sin versión.

## Base

| Repo | Base | Parches | Árbol resultante |
|---|---|---|---|
| brave-core | árbol **`de0b6a69c9`** (la 3.2.1 sin el commit de versión, = resultado de `siguiente/brave-core/0001`–`0003`) | `brave-core/0001` | **`c881f8b1b3`** |
| chromium | árbol **`a2ffc0a48f`** (la 3.2.1 sin VERSION, = resultado de `siguiente/chromium/0001`–`0010`) | `chromium/0001` | **`ff91be10d6`** |

Comprobado: `git am` de `brave-core/0001` sobre `de0b6a69c9` da `c881f8b1b3`; `git diff --diff-filter=D` vacío; los
cuatro `patches/*.patch` que toca se aplican limpios sobre los ficheros de Chromium de la 3.2.1 sin VERSION y dan el mismo
resultado que se editó. **No compilado ni probado aquí** (no hay árbol de compilación en la nube).

## `chromium/0001`: [M159] [security] Disable SendEarlyFinalBeginMainFrame

- **Origen:** `branch-heads/8154` `ce5896ca0a` (22-11 23:08 UTC; main `48f78635b5`). Bugs 576628035 y 588864961, **restringidos**:
  la gravedad no es pública y no hay CVE ni boletín todavía. **Aún no ha llegado a la 8078.**
- **Qué cambia:** el *killswitch* `features::kSendEarlyFinalBeginMainFrame` de `cc/base/features.cc` pasa a desactivado
  por defecto. Así `LayerTreeHost::RequestImmediateBeginMainFrame` deja de mandar el *BeginMainFrame* final adelantado
  (`cc/trees/layer_tree_host.cc`). La prueba `LayerTreeHostProxyTestRequestImmediateBeginMainFrame` activa la función
  explícitamente para seguir probando ese camino.
- **¿Mac?** Sí: `cc` es común a todas las plataformas. En la 156 la función existe y está **activada** por defecto.
- **Aplicación:** mismo diff que upstream, solo con desplazamientos de líneas (-20 y -18). No hay parches de brave-core
  ni `chromium_src` para estos ficheros. `git am` sobre `a2ffc0a48f` da `ff91be10d6`.
- **Riesgo funcional:** bajo. Es el valor que llevará Chrome 159 estable, y el camino de la función queda como estaba
  antes de que existiera.

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

## Revisados y no aplicables

- **V8 15.9 `a38f990ac8`** ([M159] [turbolev] Remap replaced header phis in peeled loop backedge KNA; crbug
  587040689, gravedad no publicada; 15.9.128.28). El código afectado (`MaglevLoopPeeler::RewireDownstreamPhiRefs`)
  está en la 15.6 casi igual: el parche entra en `maglev-loop-peeler.cc` y en el `.h`, pero no en el `.cc` de KNA,
  que en la 15.6 es más antiguo. **No se porta:** el peeler solo corre en `turbolev-frontend-pipeline.cc`, y
  `turbolev` está apagado en la 15.6 (`false`), Chrome 156 no lo enciende desde gin, y el estudio `V8Turbolev` de
  `fieldtrial_testing_config` no se aplica porque compilamos con `disable_fieldtrial_testing_config = true`. Se
  revisa de nuevo si algún día se enciende turbolev.
