# Seguridad: tanda siguiente-3 (base 3.2.2)

Lo que llegue después del corte de la 3.2.2 (23-11, ~18:57 UTC) y **no** sea Alto, Crítico o KEV se prepara aquí (orden
de COORDINACIÓN-61, buzón `5bab5221`). Lo prepara SEGURIDAD-PORTES (-33). **En qué versión entra lo decide Titín**; hasta
entonces, sin fusionar y sin versión. Lo que sea Alto, Crítico o KEV se avisa enseguida a COORDINACIÓN (Titín decide si
entra en la 3.2.2 o sale aparte).

## Base

La 3.2.2 = la 3.2.1 más `seguridad/siguiente-2` entera (PR #1210, parches en `0901b22b39`).

| Repo | Base | Parches | Árbol resultante |
|---|---|---|---|
| brave-core | árbol **`7b51fc45f9`** de la 3.2.2 (`local/321-final` `f204a99733` + `siguiente-2/brave-core/0001`–`0006`) | `brave-core/0001`–`0004` | **`90d7c52725`** (hasta `0003`: `905e7b72c3`; hasta `0002`: `07a6c5e899`; solo `0001`: `3861451d5b`) |
| chromium | árbol **`a8a41143c0`** (resultado de `siguiente-2/chromium/0001`–`0005` tras la corrección de pruebas del 24-11; antes `7e6c74e256`) | `chromium/0001`–`0009` | **`8db178bac4`** (hasta `0008`: `d774af4e36`; hasta `0007`: `87485ee224`; hasta `0006`: `fa42a88980`; hasta `0005`: `285d207b50`; solo `0001`: `f0b2710da1`) |

Comprobado: `git am` de `chromium/0001`–`0008` sobre `a8a41143c0` da, uno a uno, `f0b2710da1`, `da1b6bad0b`,
`a036036b92`, `1f9fb49f2f`, `285d207b50`, `fa42a88980`, `87485ee224`, `d774af4e36` y, con `0009`, `8db178bac4`. Sobre la base anterior, `7e6c74e256`,
daban `f43b3399c7` (`0001`), `13d5ed72d4` (`0005`), `5c5893384f` (`0006`), `e70ea1f2a9` (`0007`) y `c5a2b373aa` (`0008`).
Los parches son los mismos: la base solo cambia dos líneas de pruebas de `siguiente-2/chromium/0002`. Y de
`brave-core/0001` sobre `7b51fc45f9`, `3861451d5b`; con `0002`, `07a6c5e899`; con `0003`, `905e7b72c3`; y con `0004`,
`90d7c52725`; `git diff --diff-filter=D` vacío en todos. El árbol `7b51fc45f9` se
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

**Para LOCAL:** `views_unittests --gtest_filter='MenuRunner*:MenuController*'`. A mano, **en la 6,1** (no en la 7,1: nada que
robe el foco allí, DIRECTIVAS 21-11) y en la 5,1 cuando Titín pueda: menú de la app, menús contextuales, menús de marcadores, y arrastrar un marcador a la barra y a una carpeta abierta (FOR_DROP).

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

## `chromium/0008`: [M159] ServiceWorker, `ServiceWorkerVersion` protegida en llamadas reentrantes (crbug 583907056)

Puerto del merge **`942376f95b`** de 8154 (24-11 03:32 UTC; bug del merge 588740597). **Gravedad no publicada.**
- **El fallo (uso tras liberar, en el proceso del navegador):** si la versión activa estaba parándose, el registro podía
  tener la última referencia a ella. `NavigateClient()`, `OpenWindow()` y `OnNoWorkInBrowser()` podían activar de forma
  síncrona una versión en espera, o ejecutar la callback, y soltar esa referencia. Después seguían leyendo
  `script_url_`, `context_` u `observers_` de un objeto ya liberado. Un service worker de una página puede provocarlo con
  `clients.navigate()` y `clients.openWindow()`.
- **El arreglo:** un `scoped_refptr<ServiceWorkerVersion> protect(this)` en los tres puntos. Trae tres pruebas en
  `service_worker_version_unittest.cc`.
- **Adaptación:** ninguna en el código. Los tres hunks entran con desplazamiento, y el de `OnNoWorkInBrowser()` necesita
  `git apply -C1` porque las líneas de contexto de arriba son de otra función en la 156. Comprobado que va dentro de
  `OnNoWorkInBrowser()`.
  - Las ayudas de la prueba (`ActivateWithControllee`, `DelayedFakeEmbeddedWorkerInstanceClient`, `ResetWorkerHost`,
    `OnRequestTermination(uint64_t)`) existen en la 156.
  - El `chromium_src` de Brave en `content/browser/service_worker` solo toca `service_worker_content_settings_proxy_impl`.
- **Confirmado con la M156:** la 8078 recibió el mismo arreglo, **`eb6557f019`** (24-11 04:23 UTC; bug del merge
  588740238). Con este parche, `service_worker_version.cc` y su prueba quedan iguales byte a byte que en la 8078.

## `dawn/0001`: [M159] Dawn Metal, polyfill completo de `extractBits` (crbug 587021111)

**APARCADO** (COORDINACIÓN-62, 24-11, buzón `…0900-COORDINACION-62-dawn-aparcado`): solo afecta a GPU Apple. **No entra en
la tanda** salvo que el boletín le dé Alto o haya otro motivo para tocar Dawn. LOCAL no lo compila.

Roll de Dawn de la 8154 `c47f9d8c32` = un commit, **`e6ee1e5319`** «[M159] [metal] Enable full polyfill for extractBits»
(merge 588740235). Lo localizó COORDINACIÓN-62 desde la 7,1. Es cherry-pick de main **`ce281c466b`** (19-11).
**Gravedad no publicada.**
- **El fallo:** con `extractBits(x, 32u, 0u)` en una rama fuera de límites, el compilador Metal de Apple daba la rama por
  inalcanzable y quitaba la comprobación de límites (robustness) de **otro** acceso a búfer. Un shader WebGPU podía así
  leer o escribir fuera del búfer en la GPU.
- **El arreglo:** un toggle nuevo, `metal_polyfill_extract_bits`. Hace que Tint use el polyfill completo de `extractBits`
  en lugar del recorte. Dawn lo activa por defecto **solo con GPU Apple** (`gpu_info::IsApple(vendorId)` en
  `PhysicalDeviceMTL.mm`). Trae una prueba end2end y la opción del fuzzer.
- **¿Afecta a FlyWeb?** Casi nada:
  - En **10.14** Dawn no arranca: WebGPU y Graphite están apagados en código (B1d, `docs/b1d/README.md`). Con
    `parches/3.1.1-catalina/0004` el corte sube a macOS 11, así que en 10.15 tampoco arranca si ese parche está en la base.
    No lo he comprobado para la 3.2.x.
  - Donde WebGPU sí va por Dawn Metal (Monterey, el «debería funcionar»), el toggle solo se enciende con GPU Apple. Los
    Mac Intel (Intel, AMD o NVIDIA) **no cambian**.
  - Solo cambiaría algo en un Mac con Apple Silicon que ejecute FlyWeb x86_64 por Rosetta, que no es un objetivo.
- **La base del parche no es la real:**
  - `dawn.googlesource.com` está bloqueado aquí, y el espejo de GitHub (`google/dawn`) solo tiene `main`. Por eso el
    parche está hecho sobre el **punto de rama de la 8078**: Dawn `0a2c7df818`, el `dawn_revision` del DEPS de Chromium
    `c50edc4214`.
  - **No** está hecho sobre el Dawn de la rama 8078 (`c7cec856c9`, que no se ve desde aquí) ni sobre el Dawn de FlyWeb
    (`dawn/0001`–`0004` de la 3.1.3 más el de la 10.14).
  - Adaptación, solo de contexto: el toggle nuevo va al final de las listas de la 156 en `Toggles.cpp` y `Toggles.h`; lo
    demás entra con desplazamiento.
  - Comprobado: `git am` sobre `0a2c7df818` da el árbol `28c3382958`.
- **Para LOCAL**, si se mete:
  - `git am` sobre el Dawn del checkout; si choca, `cherry-pick -x` de `e6ee1e5319`, que sí ve.
  - Fijar `dawn_revision` como en la 3.1.3.
  - Prueba: `dawn_end2end_tests --gtest_filter='*ShaderTests.ExtractBitsInDeadBranchRobustness*'`. En las Mac Intel la
    prueba solo comprueba que no se rompe nada, porque allí el toggle no se enciende.
- **Recomendación:** baja prioridad, aceptada por COORDINACIÓN-62 (aparcado, arriba). Es barato e inofensivo, pero en el
  hardware objetivo no cambia nada.

## `chromium/0009`: [M156] COEP y COOP, los informes no filtran URL de otro origen (crbug 572310924)

Merge **`367e66bc19`** de la **8078** (24-11 10:21 UTC; bug del merge 589981486), tal cual. También está en la 8154
(`c34fd508c1`). **Gravedad no publicada.**
- **El fallo (fuga de información):**
  - Los informes COEP enviados al padre llevaban la URL inicial completa de la navegación del hijo, dando por hecho que
    la había elegido el padre. No es así en las navegaciones de historial, donde puede ser la URL de otro origen tras una
    redirección, ni en las que empieza un hijo de otro origen.
  - Los informes COOP exponían `nextResponseURL` en los recorridos del historial.
- **El arreglo:**
  - La URL completa solo se informa si la eligió un documento del mismo origen que el padre.
  - Las navegaciones de historial, restauración y recarga dejan de contar como origen de navegación para COOP.
  - Trae una prueba de navegador nueva (`cross_origin_embedder_policy_reporting_browsertest.cc`) y casos nuevos en la de
    COOP.
- **Brave:**
  - Su `patches/content-browser-renderer_host-navigation_request.cc.patch` sigue aplicando encima; comprobado, con
    desplazamientos.
  - Su `chromium_src` de `navigation_request.cc` solo añade `GetTopDocumentGURL()` antes del `#include`, sin macros.
  - Las cabeceras de la prueba nueva existen en la 156.

## `brave-core/0001`: [M159] V8, la etiqueta de `Intl.Locale` pasa por `ToStdString` (crbug 585869521)

Puerto del merge **`1faf157db2`** de V8 15.9.128.34. **Gravedad no publicada; es una salida del sandbox de V8.**
**Ya tiene merge M156:** V8 15.6 `2401f5f28b` (15.6.75.83, 24-11 12:43 UTC; bugs 587681388 y 585869521). Comparado sobre
15.6.75.66: `js-locale.cc` y la prueba, byte a byte iguales que nuestro parche; en `mjsunit.status`, la misma línea en el
mismo sitio (nuestro `.patch` solo difiere porque lleva más hunks). Nada que cambiar.
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
- **Probado (D8-LINUX-6, 24-11, d8 con ICU `5aa5262071` de la 15.6.75.66, árbol 3.2.2 + `0001`–`0002`;
  buzón `…1109-D8-LINUX-6-d8-icu`):** `intl` 311/311; `sandbox/regress/regress-585869521` pasa; los 8 de `sandbox` que
  fallaban solo por faltar Intl, 8/8. Ningún rojo.

## `brave-core/0002`: [M159] V8, el número dinámico de parámetros se lee al principio del builtin (crbug 581560002)

Puerto del merge **`c20e1a6e22`** de V8 15.9.128.35 (24-11; cherry-pick de main `30ec9a07`; bugs 465487205 y 581560002).
**Aún no está en la 15.6. Gravedad no publicada; es un fallo del sandbox de V8.**
- **El fallo:** los builtins trampolín TFJ leían el número dinámico de parámetros de la entrada de la `JSDispatchTable` del
  handle entrante tarde, después de la comprobación de pila o de una llamada que puede reservar memoria. Un GC en ese
  momento podía liberar la entrada, que no está enraizada. El número se leía entonces de una entrada liberada o
  reutilizada.
- **El arreglo:** `EmitBuiltinProlog` lee y guarda el número al principio del todo. `SetSupportsDynamicParameterCount` y
  `JSTrampolineAssembler::CompileLazy` usan ese valor; Torque lo pasa en lugar del tipo `DispatchHandle`; los sitios de
  lectura llevan `DCHECK(IsAtStart())`. Trae la prueba `sandbox/regress/regress-581560002.js` (Wasm con 1000 parámetros
  y un worker que cambia el handle).
- **Aplica en Mac:** el código de la 156 es el mismo.
  - Los 18 ficheros de código entran **sin cambios** sobre 15.6.75.66 y ningún otro `patches/v8` los toca.
  - Comprobado en el árbol completo de 15.6.75.66 que todas las llamadas a las firmas que cambian están en ficheros que
    el parche ya toca: `SetSupportsDynamicParameterCount` (`base.tq`, `js-to-wasm.tq` ×3, `wasm-interpreter-wrappers.tq`),
    `CompileLazy` (`js-trampoline-assembler.*`) y `GetDispatchHandleType`/`DISPATCH_HANDLE_TYPE_STRING` (Torque).
  - `mjsunit.status`: el `[SKIP]` nuevo va al bloque `not has_webassembly` de la 15.6, encima del hunk que ya llevamos.
- **Época de caché:** la cubre la subida a 41 de `brave-core/0001`. Nota en `patches/v8/FLYWEB-SECURITY.md`.
- **Riesgo de compilación:** es el cambio más grande de la tanda (Torque y builtins).
- **Compilado (D8-LINUX-6, 24-11):** entra limpio, `wasm/*` 518/518, ningún rojo de la serie. Pero `regress-581560002`
  **pasa también sin el parche**, por dos motivos:
  - Es una carrera.
  - Una entrada liberada se lee como 0 parámetros, y la función Wasm de la prueba los ignora.
- **Para demostrar el arreglo:** `--print-builtin-code` en una d8 con desensamblador. La lectura del número de parámetros
  debe quedar al principio del prólogo, antes de la comprobación de pila. Detalle en el buzón (`783621b1`).
- **Comprobado en el código generado (D8-LINUX-6, 24-11, `mksnapshot --print-builtin-code`, informe
  `…1125-D8-LINUX-6-0002-estructural`):**
  - En `JSToWasmWrapper`, con el parche, la lectura del número de parámetros pasa de después de la comprobación de pila al
    principio del prólogo.
  - En `CompileLazy` y en los builtins de tiering (`FunctionLogNextExecution`) el código generado es **idéntico** con y
    sin el parche, y es lo esperado: en la 15.6, igual que en la base de upstream antes del arreglo, ya leían el número
    como primera instrucción, sin llamadas antes. Ahí upstream solo reorganiza (`LoadIncomingParameterCount()` con
    `DCHECK(IsAtStart())`) para que no se pueda romper más adelante. No falta nada del porte.
  - El arreglo de verdad está en los builtins con número de parámetros dinámico: `EmitBuiltinProlog`,
    `SetSupportsDynamicParameterCount` (`JSToWasmWrapper` y demás de `js-to-wasm.tq`, y el envoltorio del intérprete de
    Wasm) y `builtins-internal-gen.cc`.

## `brave-core/0003`: [M156] V8, `ReducePhi` no convierte en `Select` un Phi de `TypeGuard` (crbug 585625640)

Merge **`7b49ecf357`** de la 15.6 (V8 15.6.75.81, 24-11; bugs 587681267 y 585625640). **Gravedad no publicada.**
- **El fallo:** `CommonOperatorReducer::ReducePhi` convertía un Phi del tipo `0 < v ? v : 0 - v` en un `Word32Select`.
  Si una entrada era un `TypeGuard`, que no tiene salida de control, el planificador lo subía por encima del Merge: un tipo
  válido en una sola rama se aplicaba a las dos. Es una confusión de tipos en código optimizado.
- **El arreglo:** no se reduce si las entradas son `TypeGuard` (función nueva en `node-properties.h`). Trae la prueba
  `regress/wasm/regress-585625640.js`.
- **Aplica tal cual** sobre 15.6.75.66; ningún otro `patches/v8` toca esos ficheros. Época de caché: la cubre `0001`.

## `brave-core/0004`: [M156] V8, `GraphReducer` actualiza `max_id` antes de cada reductor (crbug 585624821)

Merge **`7be38d96f9`** de la 15.6 (V8 15.6.75.82, 24-11; bugs 589981130 y 585624821; main `9bbff6a346`). **Gravedad no
publicada.**
- **El fallo:** `GraphReducer::Reduce` guardaba el `max_id` de antes del primer reductor. Si uno creaba nodos nuevos (por
  ejemplo el `ToBoolean` de `ReduceJSInstanceOf`) y otro posterior, en el mismo paso, devolvía `Replace(nodo)`, esos
  usuarios nuevos se quedaban en el nodo viejo mientras sus aristas de efecto y control pasaban al nuevo: grafo roto en
  código optimizado.
- **El arreglo:** `max_id` se toma antes de cada reductor y los reemplazos hechos por uno anterior se reducen de forma
  recursiva. Trae `compiler/regress-585624821.js` y `compiler/regress-585624821-fast-api.js`.
- **Aplica tal cual** sobre 15.6.75.66; ningún otro `patches/v8` toca `graph-reducer.*`. Época de caché: la cubre `0001`.

## Pruebas para LOCAL y D8-LINUX

Nada se ha compilado ni probado en la nube.
- `blink_unittests --gtest_filter='ModuleScriptTest.IsolatedCopyCreatesNonParkableSource:ParkableStringTest.*:WorldSafeV8Reference*:ScriptPromiseResolver*'`
  (chromium/0001 y 0003).
- `unit_tests --gtest_filter='ExtensionActionRunner*:PageSpecificSiteDataDialog*'` y
  `browser_tests --gtest_filter='ScriptInjectionTracker*'` (chromium/0002 y 0005).
- `components_unittests --gtest_filter='SessionImpl*'` (chromium/0004).
- `views_unittests --gtest_filter='MenuRunner*:MenuController*'` y las pruebas a mano de menús, en la 6,1 (chromium/0006).
- `blink_unittests --gtest_filter='HTMLScriptElement*:HTMLDocumentParserLoading*'` y la WPT
  `html/semantics/forms/the-select-element/customizable-select/selectedcontent-parser-removal-csp-strict-dynamic.html`
  (chromium/0007).
- `content_unittests --gtest_filter='*ServiceWorkerVersionTest.*VersionDestroyedDuring*'` (chromium/0008).
- `content_browsertests --gtest_filter='*CrossOriginEmbedderPolicyReporting*:*CrossOriginOpenerPolicyReporting*'`
  (chromium/0009).
- D8-LINUX: `d8` con las banderas de prueba del sandbox; mjsunit `sandbox/regress/regress-585869521` e `intl*/*`
  (brave-core/0001).
- D8-LINUX: compilar `v8` (cambian Torque y los builtins) y pasar mjsunit `sandbox/regress/regress-581560002`, `wasm/*` y
  `sandbox/*` con las banderas de prueba del sandbox (brave-core/0002).
- D8-LINUX: mjsunit `regress/wasm/regress-585625640`, `compiler/regress-585624821*` y `compiler/*` (brave-core/0003
  y 0004).

## Solo Linux

Arreglos que no afectan a Mac pero sí al porte a Linux (aprobado, DIRECTIVAS 22-11). **No se portan todavía**: se hará
cuando haya una versión de Linux que publicar (orden de COORDINACIÓN-61). Para cada uno: commit, crbug y si nuestra
configuración de Linux compila el código.

| Commit | crbug | Qué | ¿Lo compila nuestra Linux? |
|---|---|---|---|
| 8078 `97c8484b2c` [M156] | 577371305 | `ExternalVkImageBacking`: `ProduceGL()` falla si el backing guarda un `NativePixmap`, y la conversión a `NativePixmap` pasa antes, de modo que la creación falla si no se puede | **Sí se compila:** `external_vk_image_backing.cc` está en `gpu/command_buffer/service/BUILD.gn` bajo `enable_vulkan` y `is_linux \|\| is_fuchsia`. `enable_vulkan` es `true` por defecto en Linux y FlyWeb no lo cambia. **En la práctica casi no se usa:** Vulkan va apagado por defecto en Linux (`features::kVulkan`, `FEATURE_DISABLED_BY_DEFAULT` fuera de Android). Además, según el propio commit, el backing con `NativePixmap` solo se da en Fuchsia. |

## Revisados y no aplicables

- **8078 `edb08e1df1`** (24-11 12:02 UTC): roll de V8 a 15.6.75.81, que trae `7b49ecf357` (`brave-core/0003`) y
  `34e1c83643` (ya en la 3.2.2). `7be38d96f9` (`brave-core/0004`) y el de Intl llegan en rolls posteriores.
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
- **8078 `2c523c18de`** (24-11 07:56 UTC): la M156 de «Notify UrlListManager observers on destruction» (583313828). Ya
  está en la 3.2.2 como `siguiente-2/chromium/0002`, merge M159. Comprobado fichero a fichero: los nueve ficheros quedan
  iguales que en la 8078, también las dos pruebas con `NEW_FOREGROUND_TAB` (la corrección del 24-11). Nada que portar.
- **V8 15.6 `34e1c83643`** (M156, 15.6.75.81; 585625644): **ya está en la 3.2.2.** Es byte a byte el porte de su gemelo M159
  `a92c222bca` que lleva `siguiente-2` (`machine-optimization-reducer.h` y la prueba `wasm/turboshaft/regress-585625644.js`;
  comparado con `cmp` sobre 15.6.75.66). Nada que portar.
