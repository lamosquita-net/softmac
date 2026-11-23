# Seguridad: tanda siguiente-2 (base 3.2.1)

Lo que llegue después de la 3.2.1 y **no** sea Alto, Crítico o KEV se prepara aquí (orden de COORDINACIÓN-59/60). Lo
prepara SEGURIDAD-PORTES (-33). **En qué versión entra lo decide Titín**; hasta entonces, sin fusionar y sin versión.

## Base

| Repo | Base | Parches | Árbol resultante |
|---|---|---|---|
| brave-core | árbol **`de0b6a69c9`** (la 3.2.1 sin el commit de versión, = resultado de `siguiente/brave-core/0001`–`0003`) | `brave-core/0001`–`0003` | **`5551162dbe`** (hasta `0001`: `c881f8b1b3`; hasta `0002`: `85d15c77a6`) |
| chromium | árbol **`a2ffc0a48f`** (la 3.2.1 sin VERSION, = resultado de `siguiente/chromium/0001`–`0010`) | `chromium/0001`–`0003` | **`1b197b1e48`** (hasta `0001`: `ff91be10d6`; hasta `0002`: `37bf78cffd`) |

Comprobado: `git am` de `brave-core/0001` sobre `de0b6a69c9` da `c881f8b1b3`, con `0002` detrás, `85d15c77a6`, y con `0003`, `5551162dbe`; `git am` de `chromium/0001`–`0002` sobre `a2ffc0a48f` da `37bf78cffd`, y con `0003`, `1b197b1e48`; `git diff --diff-filter=D` vacío; los
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

## `brave-core/0002`: [M159] V8, Turboshaft solo pliega cargas de mapa etiquetadas (crbug 585625644)

Puerto del merge **`a92c222bca`** de V8 15.9.128.29 (bugs 588195794 y 585625644; cherry-pick de `a7644692f0` de main).
**Gravedad no publicada; aún no está en la 15.6** (punta `f08ef923d3` sin el arreglo).
- **El fallo:** `MachineOptimizationReducer::ReduceLoad` convertía en el mapa del objeto (constante etiquetada) cualquier
  carga con desplazamiento 0 sobre una constante HeapObject. En código inalcanzable, la eliminación de cargas puede
  dejar ahí una carga cruda o no etiquetada (p. ej. un `Float64` cuyo desplazamiento se pliega a 0). Resultado: un
  valor etiquetado donde se esperaba un `Float64`.
- **Aplica en Mac:** Turboshaft es el backend de TurboFan y de Wasm en la 15.6, encendido por defecto. El código de la
  15.6.75.66 es idéntico al de la punta de la 15.6 y al de la 15.9 antes del arreglo. Ningún otro `patches/v8` toca el fichero.
- **El parche** (en `patches/v8/` de brave-core):
  - `src-compiler-turboshaft-machine-optimization-reducer.h.patch`: el mismo cambio que upstream para el mapa (solo
    con `kind.tagged_base`, no atómica y `loaded_rep` `TaggedPointer` o `AnyTagged`). **No se lleva** la guarda del
    plegado de la longitud de `String`, porque la 15.6 no tiene ese plegado (los hunks 3 y 4 de upstream no aplican por eso).
  - Prueba mjsunit `wasm/turboshaft/regress-585625644.js`, tal cual.
  - **`kFlyWebCacheEpoch` 39 → 40** (cambia el código optimizado), una vez para la versión que lleve `siguiente-2`.
  - `FLYWEB-SECURITY.md` al día.
- Comprobado: los identificadores que usa existen en la 15.6.75.66 (`LoadOp::Kind::is_atomic`, `tagged_base`,
  `MemoryRepresentation::TaggedPointer/AnyTagged`, `matcher_.TryCast`). **No compilado ni probado aquí.**

**Para D8-LINUX / LOCAL:** `d8` y mjsunit `wasm/turboshaft/regress-585625644`, más `compiler/*` y `wasm/*` con y sin Maglev.

## `chromium/0002`: [M159] UrlListManager avisa a sus observadores al destruirse (crbug 583313828)

Puerto del merge **`0750c01c21`** de 8154 (cherry-pick de `b3e0c16998`). **Gravedad no publicada.**
- **El fallo (uso tras liberar, en el navegador):** `PopupBlockerTabHelper` y `FramebustBlockTabHelper` cuelgan de
  `tabs::TabFeatures`, que se destruye al cerrar la pestaña **antes** que el `WebContents` que cierra la burbuja
  abierta. Las burbujas «Ventanas emergentes bloqueadas» y «Redirección bloqueada» observan el `UrlListManager` del
  helper y pueden sobrevivirle.
- **Aplica en Mac:** en el árbol 156, `FramebustBlockTabHelper` ya lo crea `TabFeatures` (`tab_features.cc`), y el
  código de las burbujas es el mismo. Brave no toca esos ficheros.
- **El parche:** `UrlListManager::Observer::OnUrlListManagerDestroying()`, que llama el destructor; las dos burbujas
  dejan de observar, y `OnListItemClicked()` comprueba que el helper siga ahí. Más la prueba unitaria
  `url_list_manager_unittest.cc` y dos pruebas de navegador. **Única adaptación:** en
  `components/blocked_content/BUILD.gn` de la 156 el objetivo `unit_tests` no tiene `//testing/gmock`, así que
  `//url` va detrás de `//testing/gtest`. Comprobado que existen en la 156 `TabInterface::MaybeGetFromContents` y
  `url_list_observation_` en las dos burbujas.

**Para LOCAL:** `components_unittests --gtest_filter='UrlListManager*'`; `browser_tests` de
`ContentSettingBubbleModel*` y `*FramebustBlock*`.

## `chromium/0003`: [M159] PermissionRequestManager, uso tras liberar en los selectores (crbug 577322954)

Puerto del merge **`06450631d5`** de 8154 (cherry-pick de `c99313dbf8`). **Gravedad no publicada.**
- **El fallo (uso tras liberar, en el navegador):** `DequeueRequestIfNeeded()` resuelve los selectores de interfaz
  de permisos de forma síncrona. Si uno llama a `ShowPrompt()`, que sale de pantalla completa
  (`ForSecurityDropFullscreen()`), y eso destruye el `WebContents`, el bucle de selectores sigue leyendo
  `permission_ui_selectors_` del gestor ya liberado.
- **Aplica en Mac:** el código de `permission_request_manager.cc` es el mismo en la 156 (el cambio entra sin tocar), y
  Brave no lo sobrescribe.
- **El parche:** un `WeakPtr` que corta el bucle si el gestor se ha destruido tras una llamada síncrona, más una prueba
  unitaria que solo corre con ASan. **Única adaptación:** en la prueba de la 156 no está el include de
  `base/test/mock_callback.h`, así que `base/test/run_until.h` va detrás de `histogram_tester.h`. Comprobado que
  existen en la 156 `add_permission_ui_selector_for_testing`, `MockNotificationGeolocationPermissionUiSelector::CreateForManager`
  con `async_delay` y `MockPermissionRequestState`.

**Para LOCAL:** `components_unittests --gtest_filter='PermissionRequestManagerTest.*'` (la prueba nueva solo con ASan).

## `brave-core/0003`: [M156] V8, TryReuseDispatch con FrameState muerto (crbug 585614985)

Puerto del merge **`df4a1dd5f5`**, que V8 publicó en la **15.6** como 15.6.75.77 (bugs 588740103 y 585614985;
cherry-pick de `cb621e4b70`). **Gravedad no publicada**, pero es una lectura y escritura **fuera de límites** en el
compilador (builds de release), y Google lo lleva a la 156.
- **El fallo:** durante el inlining, DeadCodeElimination puede cambiar por `DeadValue` el FrameState de un
  Checkpoint (o sus locals) mientras ese nodo sigue en la pila del GraphReducer.
  `JSInliningHeuristic::TryReuseDispatch` lo envolvía y leía y escribía fuera de límites.
- **El parche** (`patches/v8/`): el diff de upstream tal cual (aplica limpio a la 15.6.75.66), en
  `common-operator.h` y `js-inlining-heuristic.cc`, más las pruebas mjsunit `compiler/regress-585614985-1.js` y `-2.js`.
  Lo cubre la subida de `kFlyWebCacheEpoch` a 40 de `0002`.

**Para D8-LINUX / LOCAL:** `d8` y mjsunit `compiler/regress-585614985-*` y `compiler/*`, con y sin Maglev.

## Revisados y no aplicables

- **V8 15.9 `a38f990ac8`** ([M159] [turbolev] Remap replaced header phis in peeled loop backedge KNA; crbug
  587040689, gravedad no publicada; 15.9.128.28). El código afectado (`MaglevLoopPeeler::RewireDownstreamPhiRefs`)
  está en la 15.6 casi igual: el parche entra en `maglev-loop-peeler.cc` y en el `.h`, pero no en el `.cc` de KNA,
  que en la 15.6 es más antiguo. **No se porta:** el peeler solo corre en `turbolev-frontend-pipeline.cc`, y
  `turbolev` está apagado en la 15.6 (`false`), Chrome 156 no lo enciende desde gin, y el estudio `V8Turbolev` de
  `fieldtrial_testing_config` no se aplica porque compilamos con `disable_fieldtrial_testing_config = true`. Se
  revisa de nuevo si algún día se enciende turbolev.
- **V8 15.9 `e0b94eeddc`** ([M159] [maglev] Keep single-input Phis tagged in phi untagging; crbug 587040688). El fallo
  sale de `PrePhiUntaggingPhase`, que en la 15.6 solo existe en la tubería de turbolev (`turbolev-frontend-pipeline.cc`);
  Maglev normal no pasa el optimizador antes de destipar los phi. Su prueba pide `--turbolev`, y Google no lo ha
  llevado a la M156. **No se porta** mientras turbolev siga apagado (ver `a38f990ac8`).
