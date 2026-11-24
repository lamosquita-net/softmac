# Seguridad: tanda siguiente-3 (base 3.2.2)

Lo que llegue después del corte de la 3.2.2 (23-11, ~18:57 UTC) y **no** sea Alto, Crítico o KEV se prepara aquí (orden
de COORDINACIÓN-61, buzón `5bab5221`). Lo prepara SEGURIDAD-PORTES (-33). **En qué versión entra lo decide Titín**; hasta
entonces, sin fusionar y sin versión. Lo que sea Alto, Crítico o KEV se avisa enseguida a COORDINACIÓN (Titín decide si
entra en la 3.2.2 o sale aparte).

## Base

La 3.2.2 = la 3.2.1 más `seguridad/siguiente-2` entera (PR #1210, parches en `0901b22b39`).

| Repo | Base | Parches | Árbol resultante |
|---|---|---|---|
| brave-core | árbol **`7b51fc45f9`** de la 3.2.2 (`local/321-final` `f204a99733` + `siguiente-2/brave-core/0001`–`0006`) | `brave-core/0001` | **`3861451d5b`** |
| chromium | árbol **`7e6c74e256`** (resultado de `siguiente-2/chromium/0001`–`0005`) | `chromium/0001`–`0007` | **`e70ea1f2a9`** (hasta `0006`: `5c5893384f`; hasta `0005`: `13d5ed72d4`; solo `0001`: `f43b3399c7`) |

Comprobado: `git am` de `chromium/0001`–`0005` sobre `7e6c74e256` da `13d5ed72d4` (solo `0001`: `f43b3399c7`), `0006` encima
da `5c5893384f` y `0007`, `e70ea1f2a9`; y de
`brave-core/0001` sobre `7b51fc45f9`, `3861451d5b`; `git diff --diff-filter=D` vacío en los dos. El árbol `7b51fc45f9` se
rehízo aquí: `siguiente-2/brave-core/0001`–`0006` sobre `f204a99733` (que lleva además #1171 y el commit de versión).
Antes se había comprobado sobre `3667349f16` (los mismos parches sobre `de0b6a69c9`, sin #1171 ni versión), que da
`a52e854758`; el parche aplica igual en los dos.
**No compilado ni probado aquí** (no hay árbol de compilación en la nube).

**No entra en la 3.2.2** (ya compilada; regla del corte, DIRECTIVAS 23-11). Si el boletín de Chrome da Alto, Crítico o
KEV a alguno de estos arreglos, se avisa enseguida a COORDINACIÓN para una 3.2.3 rápida.

**Época de caché de V8:** la 3.2.2 la deja en 40; `brave-core/0001` la sube a **41**, una vez para toda la tanda.

## `chromium/0001`: [M159] Blink, texto de scripts «parkable» fijado entre hilos (crbug 584952095)

Puerto del merge **`11d7cebfdf`** de 8154 (cherry-pick de main; bugs 589156867 y 584952095). **Gravedad no publicada.**
- **El fallo (uso tras liberar, en el renderer):** un módulo de script con texto `ParkableString` se pasaba tal cual a un
  worklet que corre en otro hilo. El envejecimiento del hilo principal podía «aparcar» (comprimir y liberar) el búfer
  mientras el isolate del worklet aún lo leía.
- **El parche:** `ModuleScriptCreationParams::IsolatedCopy()` hace una copia no aparcable
  (`ParkableString::CreateNonParkableCopy()`), que retiene el búfer mientras haya referencias fuera del hilo principal.
  `IsSafeToSendToAnotherThread()` exige que el texto no sea aparcable. `WorkletModuleResponsesMap` reutiliza esa copia.
  Las cadenas externas de V8 sin caché quedan solo para `ParkableString` aparcables del hilo principal. Trae pruebas en
  `module_script_test.cc` y `parkable_string_test.cc`.
- **Aplica en Mac:** el código es el de la 156 y Brave no toca esos ficheros.
- **Única adaptación:** en `module_script_creation_params.h` de la 156, `IsSafeToSendToAnotherThread()` aún no mira
  `cache_consumer_`. La condición nueva (`kWasm` o `!GetSourceText().may_be_parked()`) se añade a la expresión de la 156.
  Comprobado que existen en la 156 `may_be_parked()`, `ResolvedModuleType::kWasm`, el constructor que usa la prueba y
  `features::kCompressParkableStrings`.

**Para LOCAL:** `blink_unittests --gtest_filter='ModuleScriptTest.IsolatedCopyCreatesNonParkableSource:ParkableStringTest.*'`.

## `chromium/0002`: [M156] Extensions, `ScriptInjectionTracker` valida la inyección pendiente

El merge **`efd6465a7b`** de la propia **8078**. **Gravedad no publicada.**
- **El fallo:** `ScriptInjectionTracker::WillExecuteCode()` apuntaba que un proceso del renderer había ejecutado scripts
  de contenido de una extensión aunque el navegador no le hubiera mandado ninguna inyección retenida, o aunque la
  extensión no tuviera scripts que casaran. Ese registro da al renderer permisos de la extensión.
- **El arreglo:** `ScriptExecutor` y `RequestContentScript` apuntan las inyecciones retenidas como pendientes, y el
  tracker solo las acepta si están ahí.
- **Única adaptación:** el bloque de `#include` de `script_injection_tracker_browsertest.cc` es más viejo en la 156. Se
  añaden a mano los mismos includes que upstream; comprobado que los `.mojom` existen en la 156. Brave no toca estos
  ficheros.

## `chromium/0003`: [M156] Blink, referencias entre mundos serializadas en su reino de origen (crbug 584758944)

El merge **`2b43666310`** de la **8078**, tal cual. **Gravedad no publicada.**
- **El fallo:** el clonado estructurado entre mundos (página ↔ scripts aislados de extensiones) entraba en el contexto de
  destino antes de serializar. Trampas `Proxy`, el formateo de pilas de error y otras rutas controlables podían filtrar
  referencias del reino de destino al de origen.
- **El arreglo:** serializar en el contexto de origen y deserializar en el de destino. Además falla en cerrado con
  contextos desconectados, exige que el `SharedArrayBuffer` se pueda transferir al destino y protege la resolución de
  promesas.

## `chromium/0004`: [M156] optimization_guide, `SetInput()` diferido (crbugs 570347667, 562796602)

El merge **`6c0126a13b`** de la **8078**, tal cual. **Gravedad no publicada.**
- **El fallo:** uso tras liberar en `AIManager`/`SessionImpl` (ejecución de modelos en el dispositivo) al ejecutar o
  soltar la callback de `SetInput()` con `this` aún en la pila.
- **¿Se alcanza en FlyWeb?** Dudoso. Brave apaga la ejecución en servidor (`kOptimizationGuideModelExecution`), pero no
  la ruta en el dispositivo, que además necesita un modelo descargado. Se porta porque aplica limpio y es barato.

## `chromium/0005`: [M159] PageInfo, el diálogo de datos del sitio comprueba su `WebContents` (crbug 579921184)

Puerto del merge **`e9dfc63967`** de 8154, tal cual. **Gravedad no publicada.**
- **El arreglo:** todos los métodos de `PageSpecificSiteDataDialogModelDelegate` comprueban `web_contents_` y
  `BrowsingDataModel`, por si el `WebContents` se destruye mientras el diálogo se cierra.
- El `chromium_src` de Brave sobre `page_specific_site_data_dialog.cc` es solo un `#define` de un nombre; el parche entra
  igual.

## `chromium/0006`: [M156] menús FOR_DROP como en la 8078 (crbug 565066840), y fuera lo que la M156 revirtió

Merge **`66ed8d17e9`** de la **8078** (23-11 23:47 UTC; bugs 588203706 y 565066840). **Gravedad no publicada.** Cambia lo
que llevan la 3.2.1 y la 3.2.2.
- **Lo que llevamos desde la 3.2.1** (`siguiente/chromium/0009` y `0010`): los merges de la M159 `041491e936` (crrev
  8613791, «Defer MenuRunnerImpl destruction when released in OnMenuClosed», 574516887 y 576121898) y `afa45b8e16` (el
  arreglo de FOR_DROP, 565066840).
- **Lo que hizo la M156:** metió 8613791 (`55cbf1ac7c`, 8078@{#1399}) y lo **revirtió** el 22-10 (`b0cd918806`,
  8078@{#1449}) por **b/576555601**, un bug interno sin detalle público. Ahora mete el arreglo de FOR_DROP con un «M156
  delta»: `controller_` se conserva en `MenuRunnerImpl::OnMenuClosed` **solo en los menús FOR_DROP**, para no afectar al
  resto (el commit cita AppMenu).
- **El parche** deja `ui/views/controls/menu` como la 8078 en `66ed8d17e9`. Comprobado contra los ficheros de la 8078:
  - `menu_runner_impl.cc` y `.h`, `menu_controller.h` y `menu_runner_unittest.cc` quedan iguales.
  - `menu_controller.cc` no cambia: el nuestro ya tiene ese arreglo. Además lleva guardas `ScopedDeletionGuard` y
    `ViewTracker` que la 8078 no tiene.
  - Cambio neto: `OnMenuClosed` vuelve a poner `controller_ = nullptr` en los menús que no son FOR_DROP; la prueba pasa a
    ser la de la M156; se corrige un comentario.
- **Lo que se gana y lo que se pierde:**
  - Se evita la regresión por la que la M156 revirtió el cambio. No sabemos qué es ni si se da en Mac.
  - A cambio, los menús que no son FOR_DROP vuelven a estar como en la M156 frente al UAF de 574516887. Es lo que Chrome
    ha elegido para su rama de la 156.

**Para LOCAL:** `views_unittests --gtest_filter='MenuRunner*:MenuController*'`. A mano, en la 7,1 y en la 5,1: menú de la
app, menús contextuales, menús de marcadores, y arrastrar un marcador a la barra y a una carpeta abierta (FOR_DROP).

## `chromium/0007`: [M156] Blink, el CSP recuerda que un script lo creó el parser (crbug 585891788)

Cherry-pick **`2cbfd2f722`** de la **8078** (24-11 00:12 UTC; bug del merge 589156559), tal cual. **Gravedad no
publicada.**
- **El fallo (salto de CSP):** un script creado por el parser que se prepara desconectado (por ejemplo, si el parser lo
  saca del documento a través de `<selectedcontent>`) perdía su marca de «insertado por el parser». Al volver a
  conectarlo, CSP le daba el trato de `strict-dynamic` reservado a los scripts creados dinámicamente, y podía ejecutarse
  en una página con `script-src 'nonce-…' 'strict-dynamic'` sin nonce.
- **El arreglo:** `ScriptLoader` guarda esa procedencia solo para CSP (comprobación de inline, y fetch externo o de
  módulo) sin cambiar la planificación. Trae pruebas en `html_script_element_test.cc` y
  `html_document_parser_loading_test.cc`, y una WPT nueva.
- **Brave:** su `chromium_src` de `script_loader.cc` solo redefine `kWebbundle`, que el parche no toca. Los de
  `html_script_element` solo envuelven `supports()`.

## `brave-core/0001`: [M159] V8, la etiqueta de `Intl.Locale` pasa por `ToStdString` (crbug 585869521)

Puerto del merge **`1faf157db2`** de V8 15.9.128.34. **Aún no está en la 15.6. Gravedad no publicada; es una salida del
sandbox de V8.**
- **El fallo:** `ApplyOptionsToTag` acortaba a `int32_t` la longitud UTF-8. Con una cadena corrupta dentro del sandbox,
  ICU escribía un NUL fuera de él.
- **El arreglo:** la etiqueta pasa por `String::ToStdString()`. Su tope `SBXCHECK_LE(length, String::kMaxLength)` es el
  merge a la 15.6 de `133ba8e4a90` (579314138), que FlyWeb ya lleva en `patches/v8/src-objects-string.cc.patch`. Así que
  el arreglo queda completo en nuestra base.
- **Lo que lleva el parche** (`patches/v8/`):
  - `js-locale.cc` tal cual;
  - en `mjsunit.status`, la misma línea `[PASS, SLOW]` que upstream, puesta en la lista de la 15.6;
  - la prueba `sandbox/regress/regress-585869521.js`;
  - **`kFlyWebCacheEpoch` 40 → 41**.

## Pruebas para LOCAL y D8-LINUX

Nada se ha compilado ni probado en la nube.
- `blink_unittests --gtest_filter='ModuleScriptTest.IsolatedCopyCreatesNonParkableSource:ParkableStringTest.*:WorldSafeV8Reference*:ScriptPromiseResolver*'`
  (chromium/0001 y 0003).
- `unit_tests --gtest_filter='ExtensionActionRunner*:PageSpecificSiteDataDialog*'` y
  `browser_tests --gtest_filter='ScriptInjectionTracker*'` (chromium/0002 y 0005).
- `components_unittests --gtest_filter='SessionImpl*'` (chromium/0004).
- `views_unittests --gtest_filter='MenuRunner*:MenuController*'` y las pruebas a mano de menús (chromium/0006).
- `blink_unittests --gtest_filter='HTMLScriptElement*:HTMLDocumentParserLoading*'` y la WPT
  `html/semantics/forms/the-select-element/customizable-select/selectedcontent-parser-removal-csp-strict-dynamic.html`
  (chromium/0007).
- D8-LINUX: `d8` con las banderas de prueba del sandbox; mjsunit `sandbox/regress/regress-585869521` e `intl*/*`
  (brave-core/0001).

## Solo Linux

Arreglos que no afectan a Mac pero sí al porte a Linux (aprobado, DIRECTIVAS 22-11). **No se portan todavía**: se hará
cuando haya una versión de Linux que publicar (orden de COORDINACIÓN-61). Para cada uno: commit, crbug y si nuestra
configuración de Linux compila el código.

| Commit | crbug | Qué | ¿Lo compila nuestra Linux? |
|---|---|---|---|
| 8078 `97c8484b2c` [M156] | 577371305 | `ExternalVkImageBacking`: `ProduceGL()` falla si el backing guarda un `NativePixmap`, y la conversión a `NativePixmap` pasa antes, de modo que la creación falla si no se puede | **Sí se compila:** `external_vk_image_backing.cc` está en `gpu/command_buffer/service/BUILD.gn` bajo `enable_vulkan` y `is_linux \|\| is_fuchsia`. `enable_vulkan` es `true` por defecto en Linux y FlyWeb no lo cambia. **En la práctica casi no se usa:** Vulkan va apagado por defecto en Linux (`features::kVulkan`, `FEATURE_DISABLED_BY_DEFAULT` fuera de Android). Además, según el propio commit, el backing con `NativePixmap` solo se da en Fuchsia. |

## Revisados y no aplicables

- **8078 `b978da9de9`**: roll de V8 a 15.6.75.80, que solo trae `4db782064e` (ya en la 3.2.2, `siguiente-2/brave-core/0006`).
- **8154 `10650dd166`**: roll de Dawn en M159 con un solo commit, `18789416e6` «[M159] [opengl] Limit texture image units
  to 13 on PowerVR» (585802696, 580872855). Es el backend OpenGL de Dawn con GPU PowerVR: **no aplica** a Mac (Metal) ni a
  nuestro Linux de escritorio. Lo revisó COORDINACIÓN-61 desde la 7,1 (buzón, nota `…2208-COORDINACION-61-siguiente-3`).
- **8154 `09ba8e3f49`**: el mismo arreglo de `chromium/0003` (584758944) en la M159. El diff es idéntico salvo
  `info.DataV2()` en lugar de `info.Data()` (API de V8 más nueva); el de la 8078 es el que vale para la 156.
- **8154 `8604968dfb`** [HLS] (578689969): bloquea en el reproductor HLS todos los esquemas locales, no solo `file`. **En
  Mac y Linux no cambia nada**: el único esquema local de la 156 en escritorio es `file` (`url/url_util.cc`; `content://`
  solo en Android y `externalfile` solo en ChromeOS, `chrome_content_client.cc`; Brave no añade ninguno), y la 156 ya
  bloquea `file` en `hls_data_source_provider_impl.cc`.
- **8154 `4dddde3f03`**: roll de ANGLE con un solo commit, `4dd34493f8a2` «Vulkan: Disable rasterization-samples dynamic
  state on Intel/mesa» (fallo gráfico, no de seguridad; Mac usa Metal). La V8 de ese roll (15.9 hasta `90a5172104`) ya
  está revisada.
- **8078 `0c088ee100`** (y su gemelo M159, 8154 `e8dd7df98b`): roll de ANGLE con dos commits del backend **Vulkan** de
  texturas, `071b6109f3` «Don't reformat image to new base level's format» y `71dd013cb3` «Derive texture usage flags from
  the image's format». El primero evitaba muestrear memoria vieja de la GPU al cambiar el nivel base.
  - **En Mac, por defecto, no se usa:** ANGLE compila Vulkan en Mac (`gni/angle.gni`), pero solo para SwiftShader. En la
    156, el paso a SwiftShader está apagado (`kAllowSwiftShaderFallback`, `FEATURE_DISABLED_BY_DEFAULT` en
    `ui/gl/gl_features.cc`). Solo se usaría con `--enable-unsafe-swiftshader`; WebGL va por Metal.
  - **En Linux, por defecto, tampoco:** ANGLE va por OpenGL, y Vulkan está apagado (`features::kVulkan`).
  - Se recoge la 8078 entera con el siguiente cambio de base, si lo hay.
