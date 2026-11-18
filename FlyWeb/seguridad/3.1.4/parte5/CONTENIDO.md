# FlyWeb 3.1.4, parte 5: los medios de Chrome 157 que aplican a Mac

SEGURIDAD-PORTES-27, 18-11-2026, por orden de COORDINACIÓN-49 (decisión de Titín, 18-11: en la 3.1.4 entra toda la
seguridad que aplica a Mac). Es el encargo de [`../../3.1.5/MEDIOS-157.md`](../../3.1.5/MEDIOS-157.md) (76 medios).
**Nada compilado: compila LOCAL-19 al final.**

**De 76 medios: entran 46**, **8 ya estaban** (en `local/313` o en la serie, aunque no salgan en las notas de la
Extended de la 156), **1 va en la parte 4**, **18 quedan fuera** (13 no se compilan en Mac o no son del navegador, 5
tocan código apagado) y **3 sin arreglo que portar** (2 revertidos por upstream, 1 no localizado). Todos tienen su
commit localizado (`search/commits` por número de bug en `chromium/chromium`, `v8/v8`, `google/angle`, `google/skia`,
`google/dawn` y `ChromeDevTools/devtools-frontend`; los parches salen de gitiles).

## Orden de aplicación y árboles (comprobados)

La parte 5 va **después de la parte 4** (la base es `main`) y **antes de la 6** (orden de integración 4 → 5 → 6, que
hace SEGURIDAD-PORTES-29).

| Repositorio | Base | Serie | Resultado |
|---|---|---|---|
| chromium | árbol `986d591616` + `parte4/chromium/` 0001–0018 = **`ef5cec7033`** | `chromium/` 0001–0048 | árbol **`4bfd3a5707`** (`git am` de los 48 sobre `ef5cec7033`) |
| brave-core | `15c050d35a` + `parte4/brave-core/0001` = **`d328e2f909`** | `brave-core/` 0001 (V8) | árbol **`f4ae16e77c`** (`git am`); V8 .66 con todos los `patches/v8`: **`9785de2624`** |
| Skia | gitlink `27c31ca415` + `parte4/skia/0001` = `c4c611066c` | `skia/` 0001 | árbol **`a934afed14`** (solo la parte 5 sobre `27c31ca415`: `8c6214d355`) |
| devtools-frontend | gitlink `904b77f9fc` + `parte4/devtools-frontend/0001` = `c70d811144` | `devtools-frontend/` 0001–0005 | árbol **`e365b6b8a8`** |

ANGLE, Dawn, FFmpeg, WebRTC y PDFium no cambian. Skia y devtools-frontend no tienen fork: LOCAL aplica `skia/` en
`src/third_party/skia` y `devtools-frontend/` en `src/third_party/devtools-frontend/src` (`git am -3`) y anota el hash,
como con ANGLE.

**Época de caché de V8:** `brave-core/0001` **no la toca** (orden de COORDINACIÓN-49): los dos arreglos cambian código
generado, así que la época final de la 3.1.4 tiene que quedar por encima de la de la parte 4 (35); la pone la -29 al
integrar.

### Encima va la parte 6: dos choques, resueltos en `integracion/`

Comprobado aplicando la parte 6 completa sobre la 5:
- **chromium:** sus 32 parches entran salvo **`parte6/chromium/0007`** (LNA y `<link rel="prerender">`), que añade
  `IsNoStatePrefetch()` justo donde `0021` (05fcbe537a) añade `IsExemptFromWindowSizeCheck()` en
  `content_browser_client.{h,cc}` y `chrome_content_browser_client.{h,cc}`. Se conservan los dos métodos:
  [`integracion/chromium/0001`](integracion/chromium/) es ese 0007 rehecho sobre la parte 5. Con él, 4 → 5 → 6 da el
  árbol **`ab06a2ae15`**.
- **devtools-frontend:** **`parte6/devtools-frontend/0002`** (852dcde1bd, *workers* sin marco padre) no aplica sobre
  `0002` (c637ae5f74), que lleva esa lógica a `#resolveFrameTarget()`. Upstream hizo lo mismo: la comprobación va dentro
  de `#resolveFrameTarget()` y devuelve el *target* del propio *worker*.
  [`integracion/devtools-frontend/0001`](integracion/devtools-frontend/) es ese 0002 rehecho (condición
  `!(initiator.frameId ?? parentFrameId)`, como el `candidateFrameId` de upstream). Con 4 → 5 → 6: árbol
  **`dc4e4cd416`**.
- Parte 4: solo comparte `tools/metrics/histograms/metadata/extensions/enums.xml` (la serie ya va encima).

## Lo que entra

### chromium 0001–0048 (orden de upstream)

| Parche | Original | Bug, CVE | Qué | Cómo entra |
|---|---|---|---|---|
| 0001 | ea6b96ccdc | 562158081, CVE-2026-121088 (PerformanceAPIs) | LoAF: posiciones de scripts opacos ocultas en la atribución de promesas | limpio |
| 0002 | 2a556d9b98 | 556221528, CVE-2026-121163 (Browser) | Caché de disco: se ignoran valores de `kDiskCacheDir` puestos por el usuario o no válidos, de forma coherente | limpio |
| 0003 | db2e7db91c | 566935544, CVE-2026-121202 (Autofill) | Autorrelleno: `WeakPtr` en las *callbacks* de las burbujas de guardar/actualizar dirección | limpio |
| 0004 | 2387f1267e | 496187630, CVE-2026-121062 (API) | Extensiones: `MessagePort::PostMessage` exige un marco activo | limpio |
| 0005 | d5c0ecb9c7 | 566683019, CVE-2026-121194 (SiteIsolation) | PDF: el proceso del PDF no puede crear `WebSocketConnector` | limpio |
| 0006 | f7ed6d6b8f | 553309390, CVE-2026-121170 (WebCodecs) | WebCodecs: las promesas de `flush()` se crean en el *realm* del que llama | a mano solo la prueba (`audio_encoder_test.cc`: se conservan las dos pruebas) |
| 0007 | fcdd22e332 | 562221093, CVE-2026-121033 (GPU) | GPU: el *backbuffer* fuera de pantalla se pone a cero en `ResizeOffscreenFramebuffer` | limpio |
| 0008 | 24e2447526 | 533454968, CVE-2026-121039 (Proxy Auth) | Proxy: histograma de esquemas permitidos por la política (prerrequisito de los dos siguientes) | limpio |
| 0009 | a72f49dd63 | 533454968, CVE-2026-121039 (Proxy Auth) | Proxy: `AllHttpAuthSchemesAllowedForOrigins` se evalúa contra el proxy (no contra el servidor) en los retos de proxy | limpio |
| 0010 | 411664f61d | 533454968, CVE-2026-121039 (Proxy Auth) | Proxy: política nueva `AllHttpAuthSchemesAllowedForProxies` | a mano los ids: `1490: ""` (DynamicPatchingEnabled no existe en la 156) y `1491` en `policies.yaml` y `enums.xml` |
| 0011 | 8fb25ad8ba | 562225118, CVE-2026-121254 (Select) | Formularios: el estado de autorrelleno no se desincroniza del valor sugerido (que no debe ser legible por la página) | limpio |
| 0012 | 2bbd07a96a | 566660676, CVE-2026-121212 (Core) | Clear-Site-Data: un `fetch` de otro sitio no borra datos sin particionar | limpio |
| 0013 | 03f071e538 | 507351304, CVE-2026-121066 (Extensions) | Extensiones: se quitan las preferencias controladas al meter una extensión en la lista negra | limpio |
| 0014 | 1d22369192 | 507351304, CVE-2026-121066 (Extensions) | Extensiones: los ajustes de contenido controlados siguen al estado de la extensión | limpio |
| 0015 | 561cb55520 | 567611695, CVE-2026-121070 (WTF) | CSS: sin porcentajes en `calc()` de `<length>` (evita `CalcHandles()` fuera del hilo principal) y `CHECK(IsMainThread())` | a mano `length.cc`: la 156 no tiene el mapa `Persistent`; solo `DCHECK` → `CHECK` |
| 0016 | 3775d8283c | 517435285, CVE-2026-121248 (API) | WebRequest: el iniciador se comprueba contra las restricciones de *hosts* del usuario | limpio |
| 0017 | 4e1d830e06 | 553158297, CVE-2026-121220 (Core) | Idle Detection: se rechazan orígenes opacos en `HasPermission` | limpio |
| 0018 | 32d4f02a00 | 503201581, CVE-2026-121237 (FileSystem) | FSA: las comprobaciones posteriores a la escritura corren tras cerrar el *popup* | limpio |
| 0019 | ae0e78b3dc | 499181801, CVE-2026-121063 (CacheStorage) | CacheStorage: las respuestas opacas cuentan como con credenciales para CORP | a mano el contexto de `CreateResponse()` (`cache_storage_cache.cc`); código igual que upstream |
| 0020 | fa52619e51 | 569012366, CVE-2026-121042 (Permissions) | Permisos: la comprobación de peticiones duplicadas tiene en cuenta el tipo de geolocalización | limpio |
| 0021 | 05fcbe537a | 479258455, CVE-2026-121244 (FileAPI) | Selector de ficheros: se cancela si la ventana es demasiado pequeña (suplantación) | limpio |
| 0022 | d06dbff79b | 533454968, CVE-2026-121039 (Proxy Auth) | Proxy: solo un TODO (completa la serie de 533454968) | limpio |
| 0023 | 2ab85ceb78 | 514542988, CVE-2026-121193 (Extensions) | `chrome.management`: no se activan extensiones fuera de la lista permitida | limpio |
| 0024 | 92d55a1ffd | 497950736, CVE-2026-121031 (PDF) | PDF: `executeScript` no expone los marcos de la extensión del PDF | limpio |
| 0025 | 8becb88e1c | 550245671, CVE-2026-121183 (Extensions) | Extensiones: `ScriptInjectionTracker` respeta los permisos de *host* en tiempo de ejecución | limpio |
| 0026 | 02864d5fbb | 553138801, CVE-2026-121103 (Extensions) | Extensiones: aviso de `mime_types_handler` al instalar | limpio |
| 0027 | 0356d260e6 | 565092623, CVE-2026-121067 (PermissionElement) | Elementos de capacidad (`<geolocation>`…): con un antecesor de transformación singular (rectángulo vacío) cuentan como no visibles | limpio |
| 0028 | e78f23821c | 568988525, CVE-2026-121128 (Scheduling) | Planificador: `~EventLoop` quita la *callback* de microtareas | limpio |
| 0029 | 06464c2236 | 553138801, CVE-2026-121103 (Extensions) | GN: `profiles` depende de `//extensions/browser` (lo necesita la siguiente de 553138801) | limpio |
| 0030 | 0738a7018a | 479258455, CVE-2026-121244 (FileAPI) | Selector de ficheros: métrica `CancelledByWindowResize` a falso (sigue a 05fcbe537a) | limpio |
| 0031 | ba106c4d3b | 553138801, CVE-2026-121103 (Extensions) | Extensiones: el aviso de `mime_types_handler` se incluye en el de «todos los sitios» (reland; 704e0e9913 y su revert no se llevan) | limpio |
| 0032 | 14367349ae | 492163889, CVE-2026-121120 (Prerender) | Prerender: se ignoran `OpenURL` sin id de árbol de marcos | limpio |
| 0033 | 9f85e24675 | 566384898, CVE-2026-125342 (GPU) | GPU: errores de GL antes de marcar como limpia la imagen de destino de `CopySharedImage` | a mano: se conserva el `success &=` de `3.1.4/chromium/0016` y se añade `DrainGLErrors()` |
| 0034 | b14fedffff | 569659190, CVE-2026-121238 (Source) | MediaSource: fin de un *worker* durante la conexión | limpio |
| 0035 | 4bc51678fe | 548943621, CVE-2026-121231 (DevTools) | DevTools: la política restrictiva se aplica a la URL visible y a la confirmada | limpio |
| 0036 | 9d3a2a8f56 | 536163128, CVE-2026-121122 (Prompts) | Permisos: `GetViewBoundsInScreen()` virtual pura (el aviso de acceso exclusivo informa de sus límites) | limpio |
| 0037 | 3b7bd2a67f | 568972388, CVE-2026-121164 (Views) | Mac: tiempo mínimo abierto antes de aceptar un diálogo de ficheros (como ya hace Windows) | limpio |
| 0038 | dfc2c70c0c | 553154932, CVE-2026-121075 (DevTools) | DevTools: un *frontend* remoto no ve las extensiones | limpio |
| 0039 | ba0938fa1d | 553152519, CVE-2026-121030 (DevTools) | DevTools: solo se hereda el *host* del *frontend* de abridores locales | limpio |
| 0040 | d5dd3e048b | 540020706, CVE-2026-121255 (Autofill AI) | Autofill AI: sin sugerencias de pedidos y envíos en iframes de otro origen | limpio |
| 0041 | e2fde55926 | 568999538, CVE-2026-121216 (UI) | Media Session: el estado de PiP es por reproductor, no por `WebContents` | limpio |
| 0042 | 8fcd656962 | 566857543, CVE-2026-121242 (WebPackaging) | Web Bundles: SRI por firma también en `WebBundleURLLoaderFactory` | limpio |
| 0043 | 200411e474 | 553145250, CVE-2026-121136 (DevTools) | DevTools: el *dispatcher* comprueba que el *frontend* es local | limpio |
| 0044 | 6d0582d264 | 553148542, CVE-2026-121040 (Core); 571195939, CVE-2026-121091 (Permissions); 571960472, CVE-2026-121167 (Permissions) | Permisos: con un origen opaco en el marco principal no se usa la URL visible | limpio |
| 0045 | 58be3f2baf | 567672825, CVE-2026-121257 (TabStrip) | Pestañas: caída al desagrupar un grupo efímero con el foco | limpio |
| 0046 | a60eca9cfa | 566384898, CVE-2026-125342 (GPU) | GPU: errores de GL antes de marcar como limpias las imágenes del respaldo Skia de WebGPU | limpio |
| 0047 | 972a571016 | 566384898, CVE-2026-125342 (GPU) | GPU: errores de GL antes de marcar como limpia una imagen compartida *passthrough* | limpio |
| 0048 | f028e1234f | 479258455, CVE-2026-121244 (FileAPI) | Selector de ficheros: la prueba `ShowOpenFileThenResizeSmall` vuelve en Mac (solo prueba) | a mano la prueba |

553138801 (0026, 0029, 0031): upstream subió 704e0e9913, lo revirtió (85d4ead5a7) y lo volvió a subir (ba106c4d3b);
aquí entra solo el *reland*.

### Skia, V8 y devtools-frontend

| Parche | Original | Bug, CVE | Qué | Cómo entra |
|---|---|---|---|---|
| skia 0001 | ffae953f7e | 553130328, CVE-2026-121072 (Skia) | Ganesh: si falla una subida diferida (`writePixels`), los dibujos que dependen de ella se saltan en vez de muestrear memoria sin escribir | a mano solo `GrOpFlushState::reset()`: se conserva el avance de *tokens* de nuestra rama y se añade `fDeferredUploadFailed = false` |
| brave-core 0001 | V8 42d78d0f3d | 564190098, CVE-2026-121132 (V8) | Wasm: un `Script` en caché solo se reutiliza con la misma URL de origen | limpio; sin la prueba unitaria |
| brave-core 0001 | V8 b1457bd47a | 568010379, CVE-2026-121218 (V8) | Maglev: las cargas de `PREVIOUS_INDEX` solo se tratan como sin alias desde el contexto de entrada | limpio, con `turbolev/regress-568010379.js`; 41c77763fd (mismo bug como «Bug:», una optimización) no hace falta |
| devtools 0001 | 82b871b8ea | 562233597, CVE-2026-121065 (DevTools) | *Local Overrides*: un `sourceURL` de CSS no suplanta el origen | limpio, sin las pruebas (`*.test.ts` y `front_end/testing/`, que FlyWeb no compila) |
| devtools 0002 | c637ae5f74 | 562238690, CVE-2026-121171 (DevTools) | `PageResourceLoader`: el respaldo por *host bindings* solo para iniciadores del mismo origen | ídem |
| devtools 0003 | fe0866266d | 562233597 | `StyleFile.addHeader` también marca el `sourceURL` como sintético | ídem |
| devtools 0004 | 91f0dd0b4e | 528485835, CVE-2026-121200 (DevTools) | *Automapping*: se valida el *source map* antes de mapear | ídem |
| devtools 0005 | 6ddb961d96 | 562233597 | `ParsedURL`: IPv6 generales (0001 fallaba cerrado con ellos) | ídem |

## Lo que ya estaba (8 bugs)

No salen en las notas de la Extended de la 156, pero el arreglo ya está en `local/313` o en la serie de la 3.1.4:
el `cherry-pick` sale vacío (blob igual al de upstream) o el parche ya está en softmac.

| Bug | CVE | Arreglo | Dónde está |
|---|---|---|---|
| 536663516 | CVE-2026-125349 (GPU) | 1547936923 | `local/313` (`raster_decoder.cc` ya sin el borrado parcial; `cherry-pick` vacío) |
| 565681451 | CVE-2026-121184 (Media) | f03df8eaed | `3.0.1/chromium/0009` (su [M156]) |
| 568972975 | CVE-2026-121223 (Media) | 8132e3a4c4 | `3.1.5/chromium/0002` |
| 568986882 | CVE-2026-121176 (Media) | FFmpeg f4bee18 (roll a0add0878d) | `3.0.1/ffmpeg/0001`; sigue en el FFmpeg compilado `d62d9c00d7` |
| 495903812, 500171457 | CVE-2026-121161, -121108 (BackgroundFetch) | ed790a1a8e, 4519f82a82 | `3.0.1/chromium/0041`–`0042` (los mismos arreglos que los altos 121107 y 121174) |
| 567169222 | CVE-2026-121048 (V8) | dd1db91ac1 | V8 15.6.75.66 (b1b4519404; `cherry-pick` vacío) |
| 578671521 | CVE-2026-121135 (Platform) | 3d78624680 | `local/313` (`text_encoding_detector.cc`; `cherry-pick` vacío) |

## Lo que queda fuera (motivo y comprobación)

**No se compila en Mac o no forma parte del navegador (13):**

| Bug | CVE | Arreglo | Comprobación |
|---|---|---|---|
| 502023614 | CVE-2026-121199 (Chromoting) | fa7decbc61 | `remoting/host/mac/`: el host de Chrome Remote Desktop se instala aparte; `chrome/BUILD.gn` no depende de `//remoting` |
| 505177525 | CVE-2026-121196 (Mobile) | 5d0ed75466 | `ios/` |
| 570026368 | CVE-2026-121077 (Mobile) | c6eef7733c, b13860b049 | `ios/` |
| 562656015 | CVE-2026-121116 (WebView) | 2976f67f8a | `android_webview/` |
| 513767200 | CVE-2026-121234 (Contacts) | 7b4aa320ac | `components/browser_ui/contacts_picker/android/` |
| 569006789 | CVE-2026-121110 (Shopping) | 783f66b760 | `chrome/browser/commerce/merchant_viewer/android/` (Java) |
| 511768565 | CVE-2026-121256 (GPU) | roll de minigbm a67fe088ff | minigbm es de Linux y ChromeOS |
| 536516239 | CVE-2026-121219 (GPU) | ff2c3ca968 | `gbm_wrapper` (Ozone, Linux) |
| 570104009 | CVE-2026-121049 (V8) | a2181b6968 | solo `src/d8/d8.cc` |
| 514077956 | CVE-2026-121177 (PageInfo) | 110f9ae46c, 2cc19d2f1a | `ios/` |
| 568978733 | CVE-2026-121186 (Passwords) | d31cb38423 | `ios/` |
| 517448378 | CVE-2026-121106 (Omnibox) | e6b57d91bf (y 39ea056a2a) | cabecera X-Geo de Android (`GeolocationHeader.java`, `OmniboxFeatures.java`) |
| 570029913 | CVE-2026-121245 (Autofill) | 7cf6239551, 89c59113cc (y e19aadf4d2) | OTP por SMS (`OneTimeTokenSource::kOnDeviceSms`): solo Android; `otp_manager_impl.cc` de la 156: «On non-Android platforms … the backend may be not initialized» |

**Código apagado o quitado en FlyWeb (5):**

| Bug | CVE | Arreglo | Interruptor |
|---|---|---|---|
| 565902952 | CVE-2026-121215 (Bluetooth) | 5afb57e5c7 | `requestLEScan()` exige `WebBluetoothScanning`, `status: "experimental"` (`runtime_enabled_features.json5`) |
| 502385220 | CVE-2026-121099 (PrivateTokens) | 45ef04e162 | `PrivateStateTokens` pasa a `experimental` en `patches/third_party-blink-renderer-platform-runtime_enabled_features.json5.patch` y `BindTrustTokenQueryAnswerer` da `ReportBadMessage` (`chromium_src/content/browser/renderer_host/render_frame_host_impl.cc`) |
| 513426189 | CVE-2026-121115 (Shopping) | 29b5cb8b2b | `commerce::kPriceInsights` `FEATURE_DISABLED_BY_DEFAULT` (`commerce_feature_list.cc`) y los datos vienen del *optimization guide* de Google |
| 563359033 | CVE-2026-121187 (Paint) | 6f91e49f00 | HTML-in-canvas (`CanvasDrawElement`, `experimental`, y su *origin trial*, apagados desde la 3.0.1) |
| 569005114 | CVE-2026-121158 (Paint) | c1828611b9 | HTML-in-canvas, ídem |

**Arreglo retirado por upstream (2), decisión de COORDINACIÓN-49 (18-11):** 553652456 y 563355450 (CVE-2026-121059 y
-121239, Core). El único arreglo, 605619b342 («Sanitize cross-origin URLs in UpdateRendererOnMixedContentFound()»), se
revirtió el mismo día (4cfe090bf7, por una prueba en el bot `linux-oi-rel`) y no hay *reland*. La 157.0.8103.38 tiene
`content/browser/renderer_host/mixed_content_checker.cc` idéntico al nuestro: Chrome no lo lleva. **Fuera**; se reabre si
sale un *reland* (lo vigila la -29).

**Arreglo no localizado (1), decisión de COORDINACIÓN-49:** 565490229 (CVE-2026-121096, V8): solo ebf82f3623
(«[wasm][fuzzer] Speed up memory comparison on Windows», `test/` de wasm, no se compila).

**En la parte 4 (1):** 571058818 (CVE-2026-121105, Network), 7b99dd29ba = `parte4/chromium/0015`.


## Cruce con brave-core

- `patches/`: los de `profile_network_context_service.cc`, `system_network_context_manager.cc`,
  `components/permissions/BUILD.gn`, `permission_util.cc`, `render_frame_host_impl.cc` y `web_contents_impl.cc` se
  aplican con `git apply --check` sobre `4bfd3a5707`.
- `chromium_src/`: ninguno redefine lo que cambia la serie.
  - `permission_request.{h,cc}` renombra `IsDuplicateOf` a `_ChromiumImpl` y el de Brave lo llama, así que 0020 entra
    por ahí.
  - `file_system_access_handle_base.{h,cc}` envuelve `DoMove`/`DoRename`; 0018 cambia `DoPerformMoveOperation()`, que
    no está envuelto.
  - Los de `network_service_network_delegate.cc`, `chrome_content_browser_client.cc`,
    `configuration_policy_handler_list_factory.cc`, `tab_strip_model.h`, `chrome_permission_message_rules.h`,
    `render_frame_host_impl.h` y los `.mojom` (`[BraveExtend]`) tocan otras funciones.
- brave-core no hereda de `PermissionPromptDesktop` (0036 la deja virtual pura) ni incluye
  `web_contents_based_canceller.h` (0021 lo mueve a `content/public/browser/`).
- V8: ningún `patches/v8` existente toca `wasm-engine.cc` ni `maglev-known-node-aspects.cc`.

## Revisión

- **Firmas (la trampa de 0018/0030):** tres revisores independientes compararon con la 156 cada llamada, tipo, campo de
  mojom, *include* y dependencia de GN nuevos, más todas las sobrescrituras y llamadas de las firmas que cambian.
  - Código de producción: sin problemas.
  - Pruebas: dos `flush(es)` de `audio_encoder_test.cc` y dos de `video_encoder_test.cc` venían de pruebas que ya tenía la
    156 (`3.1.5/chromium/0008`) y que el padre de upstream no tenía. Corregidas en 0006 (`flush(script_state, es)`, anotado
    en el mensaje).
- **Arreglos posteriores de upstream** (`search/commits` por el hash de cada original): ningún *revert* ni arreglo de lo
  portado.
- **8078 y serie:** lo que ya estaba se detectó con `cherry-pick` vacío (blob igual al de upstream) o por el parche en
  softmac.
- **Huella:** nada toca TLS, Client Hints ni cabeceras de petición. Cambios visibles para las webs, iguales que en Chrome
  157:
  - `calc()` con porcentaje deja de valer como `<length>` (0015).
  - Las promesas de `flush()` de WebCodecs nacen en el *realm* del que llama (0006).
  - CacheStorage trata las respuestas opacas como con credenciales para CORP (0019, `kCacheStorageOpaqueResponseCredentialedForCorp`, activa).
  - LoAF oculta las posiciones de scripts opacos (0001).
  - Política nueva `AllHttpAuthSchemesAllowedForProxies` (0010; FlyWeb no la pone).

## Veredicto (regla 17): **APTO**, parte 5

Revisado el código de cada parche contra la 156. Riesgos para LOCAL:
- **0015:** `CalcHandles()` pasa de `DCHECK` a `CHECK(IsMainThread())`. Si la 156 tuviera otro camino fuera del hilo
  principal, ahora se cae en vez de competir. Probar texto en `OffscreenCanvas` en un *worker* con `font` que use
  `calc()`.
- **0021, 0030 y 0037 (selector de ficheros):** se cancela si la ventana es menor que 400×300 y, en Mac, el diálogo exige
  un tiempo mínimo abierto antes de aceptar. Probar a subir un fichero en una pestaña normal y en un *popup* pequeño.
- **0021:** mueve `web_contents_based_canceller.h` a `content/public/browser/`. Si algo de la 156 que no vimos incluye
  la ruta antigua, falla con «file not found»: se arregla cambiando el `#include`.
- **0012:** cambia el mojom de `OnClearSiteData`. Probar un `Clear-Site-Data: "storage"` desde un iframe de otro sitio.
- **skia 0001:** si falla una subida de textura, los dibujos que dependen de ella se saltan. Probar páginas con mucho
  texto y SVG, y WebGL.
- **0033, 0046 y 0047 (GPU):** WebGL, vídeo en `<canvas>` y la 5,1 (sin AVX) con el respaldo GL.
- **V8:** el verde de D8-LINUX (encargo único que reúne la -29), sobre todo con y sin Maglev.
- Pruebas:
  - `blink_unit_tests --gtest_filter='AudioEncoderTest.*:VideoEncoderTest.*:*CapabilityElement*:CSSPrimitiveValueTest.*'`
  - `content_unittests --gtest_filter='*ClearSiteData*:IdleManager*:CacheStorageCache*:*WebContentsBasedCanceller*'`
  - `unit_tests --gtest_filter='ExtensionPrefValueMap*:ContentSettingsService*:PermissionRequest*:*MimeTypesHandler*'`
  - `gpu_unittests --gtest_filter='*CopySharedImage*:*Passthrough*SharedImage*'`
