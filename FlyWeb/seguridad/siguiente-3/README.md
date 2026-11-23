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
| chromium | árbol **`7e6c74e256`** (resultado de `siguiente-2/chromium/0001`–`0005`) | `chromium/0001`–`0005` | **`13d5ed72d4`** (solo `0001`: `f43b3399c7`) |

Comprobado: `git am` de `chromium/0001`–`0005` sobre `7e6c74e256` da `13d5ed72d4` (solo `0001`: `f43b3399c7`), y de
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
