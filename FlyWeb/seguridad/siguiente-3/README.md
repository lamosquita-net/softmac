# Seguridad: tanda siguiente-3 (base 3.2.2)

Lo que llegue después del corte de la 3.2.2 (23-11, ~18:57 UTC) y **no** sea Alto, Crítico o KEV se prepara aquí (orden
de COORDINACIÓN-61, buzón `5bab5221`). Lo prepara SEGURIDAD-PORTES (-33). **En qué versión entra lo decide Titín**; hasta
entonces, sin fusionar y sin versión. Lo que sea Alto, Crítico o KEV se avisa enseguida a COORDINACIÓN (Titín decide si
entra en la 3.2.2 o sale aparte).

## Base

La 3.2.2 = la 3.2.1 más `seguridad/siguiente-2` entera (PR #1210, parches en `0901b22b39`).

| Repo | Base | Parches | Árbol resultante |
|---|---|---|---|
| brave-core | árbol **`7b51fc45f9`** de la 3.2.2 (`local/321-final` `f204a99733` + `siguiente-2/brave-core/0001`–`0006`) | `brave-core/0001`–`0014` | **`5c4feeb327`** (hasta `0013`: `2e2ad230d2`; hasta `0012`: `1a7e31cd26`; hasta `0011`: `fdee71cc91`; hasta `0010`: `8dc666451e`; hasta `0009`: `8ad838f115`; hasta `0008`: `277835ca26`; hasta `0007`: `51fa7840a8`; hasta `0006`: `4576659642`; hasta `0005`: `84c41ddbec`; hasta `0004`: `90d7c52725`; hasta `0003`: `905e7b72c3`; hasta `0002`: `07a6c5e899`; solo `0001`: `3861451d5b`) |
| chromium | árbol **`a8a41143c0`** (resultado de `siguiente-2/chromium/0001`–`0005` tras la corrección de pruebas del 24-11; antes `7e6c74e256`) | `chromium/0001`–`0033` | **`68c1946f4c`** (hasta `0032`: `d11aeeddb0`; hasta `0031`: `7462abed8a`; hasta `0030`: `8e3f45e0fa`; hasta `0029`: `397104853a`; hasta `0028`: `9333257cbd`; hasta `0027`: `b1aa075097`; hasta `0026`: `f3c3d7fba8`; hasta `0025`: `0d484117f6`; hasta `0024`: `683ac43b54`; hasta `0023`: `79a89d9a44`; hasta `0022`: `3608da3c2f`; hasta `0021`: `325e5a221b`; hasta `0020`: `388dff3e93`; hasta `0019`: `2ffe7d5d87`; hasta `0018`: `e0d888ebec`; hasta `0017`: `aed1f81b7d`; hasta `0016`: `f5d5a97329`; hasta `0015`: `86c8e4b537`; hasta `0014`: `5d44536b7f`; hasta `0013`: `92487cbf3b`; hasta `0012`: `cd61904b3b`; hasta `0011`: `8ccd92e18d`; hasta `0010`: `a0d5962f4b`; hasta `0009`: `8db178bac4`; hasta `0008`: `d774af4e36`; hasta `0007`: `87485ee224`; hasta `0006`: `fa42a88980`; hasta `0005`: `285d207b50`; solo `0001`: `f0b2710da1`) |
| Skia | árbol **`1ef25455d7`** (fork `lamosquita-net/skia` `d361a1e371`, árbol `a934afed14`, + `pendiente/skia/0001`–`0003`, que entraron en la 3.2.0) | `skia/0001` | **`bc0519fc6a`** |

Comprobado: `git am` de `chromium/0001`–`0008` sobre `a8a41143c0` da, uno a uno, `f0b2710da1`, `da1b6bad0b`,
`a036036b92`, `1f9fb49f2f`, `285d207b50`, `fa42a88980`, `87485ee224`, `d774af4e36`, con `0009`, `8db178bac4`, con
`0010`, `a0d5962f4b`, con `0011`, `8ccd92e18d`, con `0012`, `cd61904b3b`, con `0013`, `92487cbf3b`, con `0014`, `5d44536b7f`, con `0015`, `86c8e4b537`, con `0016`, `f5d5a97329`, con `0017`, `aed1f81b7d`, con `0018`, `e0d888ebec`, con `0019`, `2ffe7d5d87`, con `0020`, `388dff3e93`, con `0021`, `325e5a221b`, con `0022`, `3608da3c2f`, con `0023`, `79a89d9a44`, con `0024`, `683ac43b54`, con `0025`, `0d484117f6`, con `0026`, `f3c3d7fba8`, con `0027`, `b1aa075097`, con `0028`, `9333257cbd`, con `0029`, `397104853a` (con la versión M159 de `0029`, que ya no se usa, daba `73c4b20769`) con `0030`, `8e3f45e0fa`, con `0031`, `7462abed8a`, con `0032`, `d11aeeddb0` y, con `0033`, `68c1946f4c`. Sobre la base anterior, `7e6c74e256`,
daban `f43b3399c7` (`0001`), `13d5ed72d4` (`0005`), `5c5893384f` (`0006`), `e70ea1f2a9` (`0007`) y `c5a2b373aa` (`0008`).
Los parches son los mismos: la base solo cambia dos líneas de pruebas de `siguiente-2/chromium/0002`. Y de
`brave-core/0001` sobre `7b51fc45f9`, `3861451d5b`; con `0002`, `07a6c5e899`; con `0003`, `905e7b72c3`; con `0004`,
`90d7c52725`; con `0005`, `84c41ddbec`; con `0006`, `4576659642`; con `0007`, `51fa7840a8`; con `0008`, `277835ca26`; con `0009`, `8ad838f115`; con `0010`, `8dc666451e`; con `0011`, `fdee71cc91`; con `0012`, `1a7e31cd26`; con `0013`, `2e2ad230d2`; y con `0014`, `5c4feeb327`; `git diff --diff-filter=D` vacío en todos. El árbol `7b51fc45f9` se
rehízo aquí: `siguiente-2/brave-core/0001`–`0006` sobre `f204a99733` (que lleva además #1171 y el commit de versión).
Antes se había comprobado sobre `3667349f16` (los mismos parches sobre `de0b6a69c9`, sin #1171 ni versión), que da
`a52e854758`; el parche aplica igual en los dos.
**No compilado ni probado aquí** (no hay árbol de compilación en la nube).

**No entra en la 3.2.2** (ya compilada; regla del corte, DIRECTIVAS 23-11). Si el boletín de Chrome da Alto, Crítico o
KEV a alguno de estos arreglos, se avisa enseguida a COORDINACIÓN para una 3.2.3 rápida.

**Época de caché de V8:** la 3.2.2 la deja en 40; `brave-core/0001` la sube a **41**, una vez para toda la tanda.

## `chromium/0001`: [M159] Blink, texto de scripts «parkable» fijado entre hilos (crbug 584952095)

Puerto del merge **`11d7cebfdf`** de 8154 (cherry-pick de main; bugs 589156867 y 584952095). **Gravedad no publicada.**
**Ya tiene merge M156:** 8078 `f539e19409` (24-11 21:33 UTC). Es **idéntico** a nuestro parche, adaptación de
`IsSafeToSendToAnotherThread()` incluida (solo cambian las cabeceras de los hunks; su `git apply -R` entra sobre nuestro
árbol). Nada que cambiar.
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
- **Corregido por `chromium/0026`:** fallar en cerrado con el contexto de origen desconectado rompía extensiones como
  Tampermonkey; la 159 lo relaja en `e924828acd`.

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

**Ya hay gemelo M156:** el roll de Dawn de la 8078 `0d1dc152be` es un solo commit, **`64d303d0bd`** «[M156] [metal] Enable
full polyfill for extractBits», sobre `c7cec856c9`, el Dawn real de la 8078 (lo miró COORDINACIÓN-62 desde la 7,1, buzón
`…-COORDINACION-62-dawn-8078`). **Si algún día se mete, usar `64d303d0bd` y no este parche**, que es el cherry-pick de main
sobre el punto de rama y no sobre la base real.

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

## `chromium/0010`: [M156] Blink, `StyleTimeline` saca el `Member` del `std::variant` (crbugs 570923792, 579581960)

**`468369bf38`** de la **8078** (24-11 13:48 UTC; bug del merge 588203731; cherry-pick de main `bcd8b6bddc`), tal cual.
**Gravedad no publicada.** Un solo fichero, `third_party/blink/renderer/core/style/style_timeline.h`.
- **El fallo:** `StyleTimeline` guardaba un `Member<const ScopedCSSName>` dentro de un `std::variant`. Al asignar entre
  alternativas distintas (por ejemplo al copiar un `HeapVector<StyleTimeline>`), el `Member` se construía por copia, sin
  la barrera de escritura de Oilpan durante el marcado incremental; y el marcado concurrente podía leer la variante
  mientras el hilo principal la cambiaba. El GC podía liberar un `ScopedCSSName` aún en uso: uso tras liberar.
- **El arreglo:** el nombre pasa a un campo `Member` propio, que siempre se traza; la variante gana `std::monostate`
  para el caso «es un nombre».
- **Comprobado:** `operator==` ya trata aparte el caso de dos nombres; Brave no toca `style_timeline.h` ni en `patches/`
  ni en `chromium_src/`.
- La réplica de gitiles aún no tenía el commit; se sacó con `git fetch --filter=blob:none --depth=2` del propio
  chromium/src, tras `ls-remote`.

## `chromium/0011`: Blink, el sanitizer en streaming con la pila vacía y `<script is>` (crbug 562404384); arregla un DCHECK de `3.1.4/parte6/chromium/0001`

Main **`d799fefdb4`** (#1708032, 30-09; Noam Rosenthal), tal cual. Está en la 159 (la 8154 sale de main #1739869); a la
8078 no se llevó. **Gravedad no publicada.** Lo pidió COORDINACIÓN-62 (buzón `…1415-COORDINACION-62-sanitizer-dcheck`).
- **El problema que encontró D8-LINUX-6** (piloto de la Ubuntu con DCHECK): nuestro `3.1.4/parte6/chromium/0001`
  (crrev 8559025, `is=` en el elemento raíz) llama a `ActiveSanitizer()` desde `InsertHTMLHtmlStartTagBeforeHTML` con la
  pila de elementos vacía, y `TopStackItem()` hace `DCHECK(top_)`. Con `DeclarativeFragment` (experimental, encendido en
  las pruebas) tumbaba 2765 `blink_unittests`.
- **Por qué:** ese CL entró en main (#1717444) cuando main ya llevaba `d799fefdb4` (#1708032), que añade a
  `ActiveSanitizer()` la guarda `|| IsEmpty()`. Lo portamos sin ese requisito previo. Comprobado por bisección en main
  (`5abc82b75a~N`): la guarda aparece justo en `d799fefdb4`. En main ya no existe `ActiveSanitizer()` (lo cambió la
  reforma de `DeclarativeFragment`); la 159 tiene la misma guarda que trae este parche.
- **Lo que trae:**
  - `html_construction_site.cc`: la guarda `IsEmpty()`. **En release no cambia nada:** con la pila vacía
    `TopStackItem()` devuelve `nullptr` y el código ya devolvía el sanitizer por defecto.
  - `sanitizer.cc`: `AllowIsAttribute()` devuelve `false` si el elemento no está permitido. Es un arreglo de seguridad
    propio (562404384): `<script is="x">` ejecutaba el constructor del elemento personalizado aunque el sanitizer
    prohibiera los scripts. **Este sí cambia el comportamiento en release:** `StreamingSanitizer` es `stable` en la 156.
  - La WPT `domparsing/tentative/stream-html-custom-element-sanitizer.html`.
- **Mejor que el arreglo local de D8-LINUX** (preguntar si la pila está vacía antes de llamar): es el código de upstream,
  cubre a todos los llamadores de `ActiveSanitizer()` y trae el arreglo de `AllowIsAttribute` que va con él.
- Entra tal cual: el fichero base es el blob `b97249b`, el mismo de upstream. `IsEmpty()` existe en la 156
  (`html_construction_site.h`). Brave no toca estos ficheros.
- **Probado (D8-LINUX-6, 24-11, buzón `…1444-D8-LINUX-6-0011-y-0006`):** `blink_unittests` entero con DCHECK, sin el
  arreglo local: 32399 pasan, ningún DCHECK de `html_element_stack.h`, vuelven las 2765, sin verdes perdidas. La única
  diferencia, `HTMLDomScenarioRunner.MathMLInHTML`, es intermitente y ajena (DCHECK de `style_resolver.cc`, falla 3 de 6
  veces sola).

## `chromium/0012`: [M156] accesibilidad, `BrowserAccessibilityManager` se obtiene con una conversión comprobada (crbug 560514888)

**`a49f8c060a`** de la **8078** (24-11 14:48 UTC; bug del merge 588203722; cherry-pick de main `5ff13fcde1`), tal cual.
Su gemelo M159 es 8154 `06ad4714eb`. **Gravedad no publicada.**
- **El fallo:** `BrowserAccessibilityManager::FromID()` y otros dos sitios hacían `static_cast` a
  `BrowserAccessibilityManager` de cualquier `AXTreeManager` marcado como `is_platform_tree_manager()`. Ese valor lo podía
  preparar un atacante y no todos los gestores de plataforma son `BrowserAccessibilityManager` (por ejemplo
  `views::AtomicViewAXTreeManager`): confusión de tipos en el proceso del navegador.
- **El arreglo:** `AXPlatformTreeManager` gana el virtual `AsBrowserAccessibilityManager()` (por defecto `nullptr`; el de
  `BrowserAccessibilityManager` devuelve `this`), y los tres sitios usan `FromAXTreeManager()`. Trae una prueba en
  `browser_accessibility_manager_unittest.cc`.
- **Aplica en Mac** (la accesibilidad es común a todas las plataformas). Entra tal cual; Brave no toca esos ficheros. En
  la 156 la única subclase de `AXPlatformTreeManager` en `ui/` y `content/` es `BrowserAccessibilityManager` (y sus
  derivadas por plataforma, que heredan el `this`).

## `chromium/0013`: [M159] GPU, `WritePixels` vacía y envía el trabajo aunque falle la escritura (crbug 574220546)

**`7b00562b3c`** de la **8154** (24-11 15:45 UTC; bug del merge 589981450; cherry-pick de main `0fb2fd26f2`, #1748463).
Aún no tiene merge a la 8078. **Gravedad no publicada.**
- **El fallo:** si `SkCanvas::writePixels()` fallaba en `RasterDecoderImpl::DoWritePixelsINTERNAL` (y en
  `CopySharedImageHelper`), se salía sin vaciar ni enviar el trabajo pendiente del `SkSurface`. El «descartar y limpiar»
  ya grabado podía impedir luego limpiar esa imagen compartida, y otro uso de la textura podía leer memoria de GPU sin
  inicializar. Es el proceso de la GPU, que en Mac también existe.
- **El arreglo:** siempre se vacía y se envía; el error se da después. Se ignora el resultado de `surface->wait()` (solo
  falla con el contexto abandonado).
- **Adaptación a la 156, solo de contexto:** el hunk de `raster_decoder.cc` de upstream quita dos llamadas
  `dest_scoped_access->ApplyBackendSurfaceEndState()` que la 156 no tiene. Las añadió main `d4d9150d1d` (#1722243,
  «grvk: Transition mutable texture state», Graphite con Vulkan en Android; no es un arreglo de seguridad). Comprobado:
  `DoWritePixelsINTERNAL` queda, desde `getCanvas()` hasta el final, **idéntica** a la de la 8154. `copy_shared_image_helper.cc`
  entra tal cual. Brave no toca estos ficheros.

## `chromium/0014`: [M159] el diálogo de autenticación HTTP solo sale si la navegación se confirmó (crbug 589215592)

**`ebd8eff681`** de la **8154** (24-11 18:02 UTC; bug del merge 589981986; cherry-pick de main `35216953ff`, #1752360),
tal cual. Aún sin merge a la 8078. **Gravedad no publicada.**
- **El fallo:** `LoginTabHelper::DidFinishNavigation()` mostraba el diálogo de usuario y contraseña (HTTP auth) también
  cuando la navegación terminaba **sin confirmarse**. Entonces sigue en pantalla el documento anterior, que puede ser de
  otro origen: el diálogo de un sitio aparecía sobre la página de otro (engaño de interfaz).
- **El arreglo:** si `!navigation_handle->HasCommitted()`, no se muestra. Trae una prueba en
  `login_handler_unittest.cc`.
- **Aplica en Mac.** Entra tal cual; Brave no toca `chrome/browser/ui/login`.
- **Ya tiene merge M156:** 8078 `42986b37d0` (24-11 18:22 UTC; bug del merge 589982118). Comparado con el de la 8154: el
  mismo cambio, solo cambian los números de línea (`git apply -R` del M156 entra sobre nuestro árbol). Nada que cambiar.

## `chromium/0015`: [M159] libvpx a `6f89cfbcc9`, como la 159 (crbug 586941063)

Orden de COORDINACIÓN-63 (buzón `…0433-COORDINACION-63-libvpx`, 6a86c113). Es la misma revisión de libvpx que la 8154
**`5c240af776`** («Cherry-pick libvpx 6f89cfbcc9 to m159», 25-11 03:23 UTC). **Gravedad no publicada.**
- **Gemelo M156 (25-11 19:58 UTC):** **`26330f521`** de la **8078** («Cherry-pick libvpx bb981e8c2d to m156»,
  `refs/branch-heads/8078@{#2433}`). La 156 **no sube** libvpx a `6f89cfbcc9`: pasa de `de61454cf8` a **`bb981e8c2d`**, que es
  `de61454cf8` más **un solo commit**, el mismo arreglo (cherry-pick de `1d448f4918`). Comparado línea a línea, su código
  de `vp9_pickmode.c`, `vp9_svc_layercontext.c` y `encode_api_test.cc` es **idéntico** a nuestra reserva
  `siguiente-3/libvpx/0001`. Así, la reserva es exactamente lo que lleva Chrome 156.
  - **No cambia la recomendación.** `chromium/0015` sigue siendo la opción por defecto, porque trae además los arreglos de
    libvpx que la 156 no recibe (las validaciones de VP8 y VP9 de la tabla de abajo). La reserva queda respaldada por la
    elección de upstream, por si la subida da guerra.
- **El arreglo principal:** libvpx `6f89cfbcc9` «vp9: Fix base_mv usage when lower SVC layers are skipped» (Marco Paniconi,
  cherry-pick de `1d448f4918`). El codificador VP9 en SVC leía el `base_mv` de una capa inferior que no se había
  codificado en ese fotograma. **Se alcanza desde una página:** WebRTC con `scalabilityMode` (p. ej. L3T3) y las capas
  inferiores desactivadas con `RTCRtpSender.setParameters`. Afecta a Mac: libvpx compila el codificador VP9 para WebRTC.
- **Lo que cambia el parche** (como el de upstream): `DEPS` y el gitlink `third_party/libvpx/source/libvpx`, de
  **`a00f6762db`** a **`6f89cfbcc9`**; `README.chromium` (`Revision`) y `source/config/vpx_version.h` (queda igual que el de
  la 8154). `a00f6762db` es la libvpx de FlyWeb desde la 3.1.4: `de61454cf8` (la de la 8078) más
  `3.1.4/parte6/libvpx/0001`, que es upstream `0a6d123f0c` y ya va dentro de `6f89cfbcc9`.
- **Sin regenerar nada:** `libvpx_srcs.gni` y los directorios `source/config/mac/x64` y `source/config/linux/x64` son
  **idénticos, blob a blob**, en la 8078 y la 8154. El `BUILD.gn` de la 159 solo añade la bandera de Chromium
  `libvpx_high_bit_depth`, que la 156 no necesita.
- **Para LOCAL:**
  - Traer la revisión nueva del subrepositorio con un `gclient sync` normal (**nunca `-D`**), o a mano
    (`git -C src/third_party/libvpx/source/libvpx fetch https://chromium.googlesource.com/webm/libvpx 6f89cfbcc9` y
    `checkout`).
  - **Ya no se aplica `3.1.4/parte6/libvpx/0001`**: va dentro (`0a6d123f0c`).
  - `vpx_version.h` dirá `v1.17.0-89-g6f89cfbcc`.
- **Reserva, por si la subida da guerra** al compilar o en `media_unittests`: `siguiente-3/libvpx/0001`, el arreglo
  suelto sobre la libvpx actual de FlyWeb (`a00f6762db`), para aplicar con `git am -3` en `src/third_party/libvpx/source/libvpx`
  como la parte 6. En ese caso no se aplica `chromium/0015`.
  - Código de `vp9_pickmode.c` y `vp9_svc_layercontext.c` tal cual. Solo cambia dónde va la prueba nueva
    (`EncodeAPI.SvcDeactivateLowerLayersBaseMv`): al final del bloque `CONFIG_VP9_ENCODER` del `encode_api_test.cc` de la
    156, que termina distinto. Trae sus propias funciones de ayuda.
  - El parche de la parte 6 no toca esos tres ficheros. `git am -3` limpio, comprobado sobre esos ficheros en `de61454cf8`.

**Lo que entra con la subida:** los 28 commits `de61454cf8..6f89cfbcc9`, del más antiguo al más nuevo. Los de AArch64 y
Neon no se compilan en x64.

| Commit | Qué | Bug | Ficheros (sin pruebas) |
|---|---|---|---|
| `a6d2b2afa6` | Fix incorrect stride for buffer access | — | `vp9_mfqe.c`, `vp9_rdopt.c` |
| `deaac25491` | vp8: Validate ss_number_layers and factor den in validate_config | 564326761 | `vp8_cx_iface.c` |
| `021170248a` | vp8: document handling of corrupt frames | chromium:561396583 | `simple_decoder.c`, `vp8dx.h` |
| `0a6f769e44` | vp8: Validate references in vp8e_set/get_reference | 564326909 | `vp8_cx_iface.c` |
| `ed2a5b572f` | vp8: clear cached resolution on thread restart failure | 571147583 | `vp8_dx_iface.c` |
| `2c6ece8c4a` | Use unfiltered source frame for PSNR with denoiser | 571976041 | `vp9_encoder.c`, `vp9_encoder.h` |
| `6a8917393d` | [vp8] Use unfiltered source frame for PSNR with denoiser | 571976041 | `onyx_if.c`, `onyx_int.h` |
| `63bcd588b5` | vp8, vp9: Validate references in set/copy/get_reference controls | 564326909 | `vp8_dx_iface.c`, `vp9_cx_iface.c`, `vp9_dx_iface.c` |
| `940d99c866` | vp9: Disallow svc config for 2-pass, remove legacy code | 574106931 | `vp9_encoder.c`, `vp9_svc_layercontext.c`, `vp9_svc_layercontext.h` … |
| `37f48364a7` | apply clang-format-21 | 569277013 | `bitstream.c`, `vp9_entropy.c`, `vp9_detokenize.c` … |
| `6cf3e2bea2` | vp9_set_roi_map: reject segment ids >= MAX_SEGMENTS | — | `vp9_encoder.c` |
| `0a6d123f0c` | vp9: Fix temporal denoiser buffer reallocation on resize | 573760540 | `vp9_denoiser.c`, `vp9_encoder.c` |
| `634423f3e7` | vp9: validate temporal_layer_id in ctrl_set_svc_layer_id | — | `vp9_cx_iface.c` |
| `fb1279dcc6` | vp9: validate fb_idx in ctrl_set_svc_ref_frame_config | — | `vp9_cx_iface.c` |
| `8c9ef99ff0` | vp9-Force ZEROMV on unscaled SVC references in pick_inter | 575939911 | `vp9_pickmode.c` |
| `aa334b8423` | AArch64: Use 8-bit in vpx_tm_predictor_*_neon | — | `intrapred_neon.c` |
| `15466827aa` | test: Add sum-of-squares speed test | — | solo pruebas |
| `c54f0f3422` | AArch64: Optimize Neon sum of squares | — | `sum_squares_neon.c` |
| `9ae223c6a6` | AArch64: Optimize Neon subtract | — | `subtract_neon.c` |
| `ec7a4f33db` | AArch64: Re-order register access for fdct32x32 | — | `fdct32x32_neon.c`, `fdct32x32_neon.h` |
| `4ca3a7c68a` | test: Enable Neon dot-product SAD skip tests | — | solo pruebas |
| `287b895827` | test: Improve SAD speed-test timing precision | — | solo pruebas |
| `8771e70cb4` | vpx_img_flip: do nothing for an empty viewport | — | `vpx_image.c` |
| `900b2a52b6` | vp8,update_golden_frame_stats: clamp gf_overspend_bits | 567288636, 454794528 | `onyx_if.c` |
| `23fbf91f68` | AArch64: Unroll loop to reduce stack access | — | `sad4d_neon_dotprod.c` |
| `50ede54a5c` | vp9: fix HBD input validation of flipped images | — | `vp9_cx_iface.c`, `vp9_iface_common.c` |
| `fb0a26ad92` | vp9: Fix LAST_FRAME check in get_estimated_pred for SVC | 575903327 | `vp9_encodeframe.c`, `vp9_speed_features.c` |
| `6f89cfbcc9` | vp9: Fix base_mv usage when lower SVC layers are skipped | 586941063 | `vp9_pickmode.c`, `vp9_svc_layercontext.c` |

## `chromium/0016`: [M159] File System Access, `Move`/`Rename` comprueban que el origen sigue siendo del mismo tipo (crbug 574804676)

**`975ba709be`** de la **8154** (25-11 06:54 UTC; bug del merge 587225612; cherry-pick de main `36a0f18351`, #1745262), tal
cual. Aún sin merge a la 8078. **Gravedad no publicada.**
- **El fallo:** `FileSystemAccessHandleBase::Move()`/`Rename()` no comprobaban que lo que hay en disco siguiera siendo del
  tipo del *handle*. Si un fichero se sustituía por un directorio, un `FileSystemFileHandle` viejo podía renombrar el
  directorio, y los permisos del destino y la lista de bloqueo se comprobaban como `kFile`.
- **El arreglo:** `GetHandleType()` (virtual puro, implementado en las tres subclases), que se pasa a la comprobación de
  permisos y de entradas sensibles. Además, con el bloqueo exclusivo ya tomado, comprueba que `url()` existe y es del tipo
  correcto antes de mover. Trae pruebas.
- **En FlyWeb ya estaba muy acotado:** el *override* de Brave (`chromium_src/.../file_system_access_handle_base.cc`) solo
  deja `Move`/`Rename` en la carpeta privada del sitio (OPFS, `kFileSystemTypeTemporary`); para ficheros locales devuelve
  `NotSupportedError` antes de llegar al código del fallo. Se porta igualmente, como defensa en profundidad y para no
  separarnos de upstream.
- **Encaja con el *override*:** sus macros solo renombran `DoMove`/`DoRename`, que el arreglo no toca. No hay más subclases
  de `FileSystemAccessHandleBase` en la 156 ni en Brave. Entra tal cual.

## `chromium/0017`: [M156] CacheStorage, sobrescribir con cuerpo vacío trunca los datos anteriores (crbug 583238770)

**`0423803672`** de la **8078** (25-11 08:04 UTC; bug del merge 588197443; cherry-pick de main `47f720b009`, #1748972,
que no está en la 159). Entra tal cual: es una 156 sobre una 156. **Gravedad no publicada.**
- **El fallo:** cuando `OpenOrCreateEntry` reabre una entrada de la caché de disco (por ejemplo, tras un desajuste del
  índice), `CacheStorageCache` no truncaba un flujo con datos (la comprobación de tamaño estaba al revés), y
  `CacheStorageBlobToDiskCache` daba por escrito un blob de cero bytes sin escribir nada. Si después se reescribían las
  cabeceras como respuesta no opaca, el cuerpo de una respuesta **opaca de otro origen** quedaba legible: una fuga de datos
  entre orígenes.
- **El arreglo:** invierte la comprobación en `cache_storage_cache.cc` y hace que el blob vacío haga una escritura de 0 bytes
  que trunca. Trae pruebas.
- **Aplica a Mac;** Brave no toca `content/browser/cache_storage`.

## `chromium/0018`: [M159] Media, `DecoderSelector` conserva el decodificador hasta entregarlo (b/589800510)

**`d388491bd2`** de la **8154** (25-11 09:36 UTC; bug del merge 590348156; main `ff0ac909fd`, #1753585). Entra tal cual.
**Gravedad no publicada.**
- **El fallo:** `DecoderSelector::RunSelectDecoderCB()` metía el decodificador elegido y el `DecryptingDemuxerStream` en
  una tarea del hilo de media. Hasta que esa tarea corría, nadie era su dueño. Si antes se desmontaba la canalización
  (`WebMediaPlayerImpl::Shutdown()`), el `CdmContext`/`AesDecryptor` se destruía en el hilo principal y luego
  `~DecryptingDemuxerStream()` lo usaba ya liberado: **uso tras liberar en el renderer**, reproducido con ASan.
- **El arreglo:** `DecoderSelector` es el dueño hasta que una tarea con `WeakPtr` (`DeliverSelectedDecoder()`) los entrega.
  Si se destruye antes, los destruye él mismo y aborta con `kFailed`. Trae pruebas.
- **Aplica a Mac:** el `AesDecryptor` es Clear Key (EME), y lo puede usar cualquier página. Brave no toca `media/filters`.
- **Ya hay gemelo M156:** 8078 **`0efe9d618`** (25-11 10:07 UTC; merge 590348671), con el mismo `patch-id` (`7915dcd3a1`).
  El parche no cambia.

## `chromium/0019`: [M159] PageInfo, la burbuja se cierra en el acto cuando se destruye la pestaña (crbug 587263538)

**`ac2c1b3ee9`** de la **8154** (25-11 13:45 UTC; bug del merge 589981304; main `6ababafece`, #1751797). **Adaptado a la
156.** **Gravedad no publicada.**
- **El fallo:** al pulsar «Configuración de sitios» en la burbuja de información del sitio se encola
  `PageInfoMainView::HandleMoreInfoRequestAsync`. Si en ese momento se cierra la pestaña, el `WebContents` se destruye de
  inmediato, pero la burbuja se cerraba de forma asíncrona (`Close()`). La burbuja y sus delegados seguían vivos apuntando a
  un `WebContents` ya liberado: **uso tras liberar en el proceso del navegador**. En la 156 ese camino es el mismo (con
  `weak_factory_.GetWeakPtr()` en `page_info_main_view.cc`).
- **El arreglo:** `WebContentsDestroyed()` deja de observar y llama a `CloseNow()`, que destruye la burbuja antes de
  que acabe el desmontaje. `RenderFrameDeleted()` y la de *safety tip* no llaman a `Close()` durante la destrucción.
  `WebContentsDestroyed` pasa a `final` y `PageInfoBubbleView` pierde su versión, que solo invalidaba sus `WeakPtr`. Además,
  los `raw_ptr<WebContents>` de los delegados ya no se marcan como colgantes.
- **Adaptación (todo lo demás entra tal cual):**
  - La 159 limpia además `PageInfoBubbleTracker`, que la 156 no tiene: llegó con una refactorización posterior. En la 156
    la burbuja se registra en dos variables globales de `page_info_bubble_view_base.cc`, que vacía `OnWidgetDestroying()`.
    `CloseNow()` lo llama en el acto, así que esa parte sobra.
  - La prueba nueva del navegador usa la API de la 156: `GetShownBubbleType()` y `GetPageInfoBubbleForTesting()` sin
    argumentos.
  - La nota está en el mensaje del commit.
- **Aplica a Mac.** Brave no sobrescribe `PageInfoBubbleViewBase` ni `WebContentsDestroyed` de estas clases. Sus
  `chromium_src` de PageInfo son de cookies y de la fábrica de vistas.

## `skia/0001`: [M156] Skia (Ganesh), `SoftwarePathRenderer` sin dominio de máscara (crbug 589186681)

**`afb64bc731`** de Skia `chrome/m156` (22-11), traído por el roll de la 8078 `fee3d01f00` (25-11 17:31 UTC; bug del merge
589982319). Entra tal cual. **Gravedad no publicada.**
- **El fallo:** `SoftwarePathRenderer::DrawToTargetWithShapeMask` pasaba a `GrTextureEffect::MakeSubset` un `maskDomain`
  calculado en CPU. Con traslaciones enormes y escalas no unitarias, el redondeo de `float32` podía meter el dominio hacia
  dentro y quitar el recorte del *shader*. Entonces se muestreaban texels viejos de texturas de máscara A8 reutilizadas:
  píxeles de otro dibujo, una fuga de contenido.
- **El arreglo:** se quita el `maskDomain`, así que esas máscaras siempre recortan a `maskSubset`. Trae
  `tests/SoftwarePathRendererTest.cpp` (en `gn/tests.gni`).
- **Aplica a Mac:** FlyWeb en Mojave dibuja con Ganesh sobre OpenGL (`docs/macos11-niveles.md`, `kSkiaGraphite` apagada), y
  el *software path renderer* es el respaldo de Ganesh para trazados que la GPU no hace.
- **Cómo entra** (como `pendiente/skia/`): nuestro Skia **no** es el `9d96dfeb45` de la 8078, sino el fork
  `lamosquita-net/skia` `d361a1e371` (una de las 8 dependencias fijadas en la 7,1, árbol `a934afed14`) más
  `pendiente/skia/0001`–`0003`, que ya incluían el `9d96dfeb45`. LOCAL lo aplica con `git am` en `src/third_party/skia` detrás
  de esos tres. **Comprobado aquí:** con el fork y los tres parches sale el árbol `1ef25455d7`, como en `pendiente/`, y este
  aplica limpio y da `bc0519fc6a`. Lo traje del espejo `github.com/google/skia`, porque skia.googlesource.com está bloqueado
  desde la nube. No se sube el `DEPS` a `afb64bc731` de upstream, porque perderíamos lo del fork.
- Revisado desde la 7,1 por COORDINACIÓN-63: es el único commit del roll.

## `chromium/0020`: [M159] Edición, la navegación entre líneas no ancla el cursor en un pseudoelemento (crbug 589812279)

**`6cf1220acf`** de la **8154** (25-11 18:32 UTC; bug del merge 590348660; main `a641294f5f`, #1753880). Entra tal cual, con
desplazamiento de líneas. **Gravedad no publicada.**
- **Gemelo M156 (26-11 09:16 UTC):** la **8078** `90364e40d8` (bug del merge 590348479). Es el mismo cambio, y
  `git apply -R` del M156 entra limpio sobre nuestro árbol. Nada que cambiar.
- **El fallo:** `AbstractLineBox::PositionForPoint()` no se saltaba las hojas en línea de pseudoelementos (`::before`/`::after`
  en *inline-block*, `::view-transition`) cuando la línea tenía también nodos reales. Al mover el cursor arriba o abajo
  (`NextLinePosition`/`PreviousLinePosition`), la selección podía quedar anclada en un pseudoelemento, lo que rompe los
  invariantes de selección y DOM de Blink.
- **El arreglo:** se salta esas hojas y toma el nodo con `NonPseudoNode()`. Va detrás de la función de Blink
  `SelectionLineSkipPseudoElement`, `stable` (encendida). Trae pruebas en `selection_modifier_test.cc`.
- **Aplica a Mac.** Brave no toca la edición. `NonPseudoNode()` e `InlineCursorPosition::GetLayoutObject()` existen en la 156.

## `chromium/0021`: [M159] Cast, el arranque de la sesión de duplicación usa `WeakPtr` (crbug 585215924)

**`d73b2ba647`** de la **8154** (25-11 22:24 UTC; bug del merge 590347287; main `ab65949134`, #1746466). Entra tal cual.
**Gravedad no publicada.**
- **Gemelo M156 (25-11 23:18 UTC):** la **8078** `4c677c2ca2` (bug del merge 590349150). Es el mismo cambio, línea a línea, y
  `git apply -R` del M156 entra limpio sobre nuestro árbol. Nada que cambiar.
- **El fallo:** `MirroringActivity::CreateMojoBindings` pide `ShouldFetchMirroringStats` y ata la respuesta con
  `base::Unretained(this)`. Si la actividad se destruye antes de la respuesta (se corta la duplicación o el receptor se
  va), `StartSession` corre sobre un objeto liberado: **uso tras liberar en el proceso del navegador**, según el propio
  commit.
- **El arreglo:** ata con `weak_ptr_factory_.GetWeakPtr()`. La respuesta de mojo llega en la misma secuencia, así que el
  `WeakPtr` es seguro. Quita el comentario viejo.
- **Aplica a Mac.** FlyWeb lleva Cast (Media Router), y para llegar hace falta duplicar una pestaña a un receptor. El código
  de la 156 es el mismo y `weak_ptr_factory_` ya existe en `mirroring_activity.h`. El diff del cherry-pick es idéntico al
  de main.

## `chromium/0022`: [M159] Extensiones, `events.addRules`/`getRules`/`removeRules` solo desde contextos privilegiados (crbug 574789262)

**`5bba75d662`** de la **8154** (26-11 00:33 UTC; bug del merge 587224619; main `50bbedecb3`, #1746194). **Gravedad no
publicada.** Aún sin merge a la 8078. La réplica de gitiles no tenía el cherry-pick: diff de main, adaptado.
- **Comprobado con el cherry-pick (26-11 02:15 UTC, ya en la réplica):** su diff es igual al de main. Con nuestro parche, en
  `declarative_api.cc` la función `RulesFunction::Run()`, el espacio de nombres anónimo y los `#include` quedan **idénticos**
  a los de la 8154.
- **El fallo:** la función interna `events` (`_api_features.json`) estaba abierta a `"contexts": "all"` y a `<all_urls>`. Un
  content script, o un renderer comprometido, podía llamar a `events.addRules`, `getRules` y `removeRules`.
  - `RulesFunction::Run()` reconocía el evento por **prefijo** (`declarativeContent.`, `declarativeWebRequest.`…).
  - Con un `web_view_instance_id` distinto de cero, recortaba el nombre del evento y pedía un registro de `<webview>`. Si el
    evento no era `onRequest`, solo lo paraba un `DCHECK` en `RulesRegistryService::GetRulesRegistry()`.
- **El arreglo:**
  - `events` pasa a `["privileged_extension"]`;
  - `Run()` exige una extensión y un contexto `kPrivilegedExtension`, y acepta solo los tres eventos con reglas, por nombre
    exacto;
  - el id de `<webview>` debe ir solo con su evento, desde un marco (nunca un *service worker*) y con el permiso `webview`;
  - se comprueba `ExtensionAPI::IsAvailable()` del evento, y si falla devuelve un error normal: el permiso puede ser
    opcional y estar retirado;
  - el `DCHECK` pasa a comprobación real (`return nullptr`). Lo que no cuadra es `BadMessage()`.
- **Adaptación a la 156:**
  - `declarative_api.cc` tiene en la 156 un `DCHECK(rules_registry_.get());` de más, que el arreglo también quita;
  - en `rules_registry_service_unittest.cc` solo se añade el `EXPECT_FALSE` de `kOnMessage`, porque la 156 no tiene el
    bloque de ids de registro no válidos de main;
  - en `chrome/browser/extensions/BUILD.gn` cambia el contexto de la lista.
  - El resto entra tal cual, con el test nuevo `declarative_api_unittest.cc` y los cambios de `declarative_apitest.cc` y
    `common_extension_api_unittest.cc`.
  - Las API que usa existen en la 156 (`source_context_type()`, `is_from_service_worker()`, `render_frame_host()`,
    `IsAvailable(…, context_id, ContextData)`, los `set_*` de `ExtensionFunction` del test, `ChildProcessId::GetUnsafeValue()`).
    Las dependencias de `//components/guest_view/buildflags` ya están en `extensions/browser/BUILD.gn`.
- **Brave no choca:**
  - su `chromium_src/extensions/common/api/_api_features.json` no toca `events`;
  - su `patches/chrome-browser-extensions-BUILD.gn.patch` cambia otra zona (línea 646).
- **Aplica a Mac.** **Para LOCAL**, además de compilar:
  - `unit_tests --gtest_filter='DeclarativeApiUnitTest.*:RulesRegistryServiceTest.*:ExtensionAPITest.*'`;
  - `browser_tests --gtest_filter='DeclarativeApiTest.*'`;
  - comprobar a mano una extensión con `declarativeContent` (p. ej. la acción de página de una extensión de la tienda).

## `chromium/0023`: [M159] gin, `PerContextData::From` comprueba que el contexto es el suyo (crbug 589478757)

**`455d306592`** de la **8154** (26-11 10:37 UTC; bug del merge 589982167; main `0441109f8c`, #1751939). **Gravedad no
publicada.** Aún sin merge a la 8078. Portado desde el diff de main. **Comprobado con el cherry-pick** (26-11 11:47 UTC,
ya en la réplica): su diff es igual al de main.
- **El fallo, del sandbox de V8:**
  - `PerContextData::From` lee de una ranura de datos del `v8::Context` un `CppHeapPointerHandle`, que está **dentro del
    sandbox**, y todos los `PerContextData` comparten la misma etiqueta de puntero;
  - un renderer que ya controle la memoria del sandbox puede cambiar el *handle* y hacer que el `PerContextData` de otro
    contexto pase por el de este. Sale de él con un `ContextHolder` ajeno.
- **El arreglo:**
  - tras leerlo, `From` comprueba con `ContextHolder::CheckContext()` (`CHECK(context_ == context)`) que el contexto que
    guarda es el mismo que se ha consultado, como ya hace `blink::ScriptState::From`;
  - si no coincide, el proceso se cierra de forma controlada.
- **Adaptación a la 156, solo en la prueba:**
  - V8 15.6 no tiene `SetAlignedPointerInEmbedderDataV2`. La prueba nueva usa `SetAlignedPointerInEmbedderData`, con la
    misma firma (`index, T*, CppHeapPointerTag`), que es la que usa `per_context_data.cc` en la 156;
  - el código de `per_context_data.cc` y `context_holder.h` entra tal cual: el `From` de la 156 es idéntico a la
    preimagen de main.
- **Aplica a Mac.** Brave no toca `gin`. **Para LOCAL:** `gin_unittests --gtest_filter='PerContextDataTest.*'`, con la
  prueba de muerte `ContextMismatchCrashes`.

## `chromium/0024`: [M159] Blink, los descriptores de rango de `FontFace` se evalúan una vez y se validan (crbug 589815780)

**`b9f25352e0`** de la **8154** (26-11 11:12 UTC; bug del merge 590699490; main `eb9f319b36`, #1754161). **Gravedad no
publicada.** **Ya hay gemelo M156:** 8078 **`b78985eb6f`** (27-11 03:47 UTC; bug del merge 590700294). Aplicado al revés
sobre nuestro árbol sale limpio: deja el mismo contenido que este parche, que se queda como está.
- **El fallo, un uso tras liberar en el renderer, alcanzable desde una página:**
  - `FontFace::GetFontSelectionCapabilities()` evaluaba varias veces cada extremo de los rangos `font-stretch`, `font-style`
    (oblicuo) y `font-weight`;
  - con una unidad como `1ch`, la evaluación puede lanzar la carga de una fuente web e invalidar las listas de reserva, y
    la evaluación siguiente devuelve otra cosa (0). Además, el peso no se comprobaba contra NaN ni en sus dos extremos;
  - si todo salía 0, la clave `FontSelectionCapabilities` coincidía con la clave vacía del `HeapHashMap` de
    `FontFaceCache`, Oilpan no trazaba el `CSSSegmentedFontFace` y quedaba liberado mientras se usaba.
- **El arreglo:**
  - cada extremo se evalúa una sola vez;
  - el peso tiene que estar en [1, 1000] en los dos extremos (y no ser NaN), y el ancho y el oblicuo no pueden ser NaN;
  - en `FontFaceCache::CapabilitiesSet::AddFontFace`, un `CHECK` de que la clave no es la vacía;
  - todo va tras la función de Blink `FontFaceCapabilitiesRangeValidation`, `stable` (encendida), como interruptor de
    emergencia. Trae pruebas WPT (`font-face-weight-calc-ch-crash.html` y `font-face-weight-calc-fallback.html`).
- **Adaptación a la 156:** solo el sitio de la entrada nueva en `runtime_enabled_features.json5`. La 156 no tiene la vecina
  `FontFallbackMultiplePriorityFonts`, así que entra en su orden alfabético, entre `FontDataServiceForCSSLocalFonts` y
  `FontFamilyPostscriptMatchingCTMigration`. `font_face.cc` y `font_face_cache.cc` entran tal cual.
  - `FontSelectionCapabilities` tiene `operator==` en la 156, de donde sale el `!=` (C++20).
  - El parche de Brave sobre ese `.json5` tiene sus trozos más cercanos en las líneas 3151 y 3913: no choca. Brave no
    toca `font_face*`.
- **Aplica a Mac.** **Para LOCAL:** las dos WPT nuevas (`css/css-fonts/crashtests/` y `css/css-fonts/`) y
  `blink_unit_tests --gtest_filter='*FontFace*'`.

## `chromium/0025`: [M159] Blink, `CSSSelectorList` sin carreras con el marcado concurrente de Oilpan (crbug 586990502)

**`23b863fe22`** de la **8154** (26-11 11:46 UTC; bug del merge 590699862; main `00c5967059`, #1754328). **Gravedad no
publicada.** Aún sin merge a la 8078. Portado desde el diff de main y **comparado con el cherry-pick `23b863fe22`** (26-11 13:00 UTC): el cambio es idéntico; solo difiere una línea de **contexto** de `AdoptSelectorVector()`, que en la 159 ya lleva `base::checked_cast<uint32_t>` y en la 156 no.
- **El fallo:**
  - Oilpan marca un objeto como «construido del todo» al terminar `MakeGarbageCollected()`, y eso ordena las escrituras
    del constructor antes del `Trace()` de un marcador concurrente;
  - `CSSSelectorList` rellenaba su vector de selectores **después** de `MakeGarbageCollected()` (en `Copy()`,
    `AdoptSelectorVector()` y `Empty()`). Un marcador concurrente podía trazar el objeto a medias, y `Trace()` leía la
    marca de fin de lista con el acceso normal, compitiendo con el hilo principal.
  - Esa carrera puede dejar objetos sin marcar, que se liberan mientras se usan.
- **El arreglo:**
  - los constructores de `CSSSelectorList` rellenan el vector dentro del propio constructor (`Empty()`, `Copy()` y
    `AdoptSelectorVector()`);
  - `Trace()` lee la marca de fin con `IsLastInSelectorListForOilpan()`, que ya existe en la 156.
- **Adaptación a la 156:** en `AdoptSelectorVector()` la 156 calcula `AdditionalBytes(sizeof(CSSSelector) * (n - 1))` sin el
  `base::checked_cast<uint32_t>` de main; se conserva la forma de la 156, que no es parte del arreglo. Lo demás entra
  tal cual. Brave no toca `css_selector_list`.
- **Aplica a Mac.** **Para LOCAL:** `blink_unit_tests --gtest_filter='*CSSSelector*'`; la carrera solo se ve con TSan.

## `chromium/0026`: [M159] Blink, el clonado entre mundos vuelve a funcionar desde reinos desconectados (crbug 590466856)

**`e924828acd`** de la **8154** (26-11 15:39 UTC; *pure cherry-pick* de main #1753743; bug original 584758944, cerrado
589373187). Entra tal cual sobre `0025` (solo desplazamientos de líneas). Aún sin merge a la 8078. **No es un arreglo
de seguridad nuevo: corrige la regresión que trajo el de `chromium/0003`.**
- **La regresión:**
  - `chromium/0003` (584758944) hacía fallar en cerrado el clonado entre mundos en cuanto el `ExecutionContext` del
    reino de origen estaba desconectado;
  - extensiones como Tampermonkey construyen `CustomEvent` entre mundos con primitivas capturadas de un `iframe`
    aislado que borran enseguida, y el `detail` de esos eventos llegaba `null` a los mundos aislados.
- **El arreglo:**
  - `WorldSafeV8Reference` serializa en el contexto V8 de origen mientras siga vivo (`v8::Context::Scope`, ya no
    `ScriptState::Scope`), aunque su `ExecutionContext` esté desconectado;
  - `V8ScriptValueSerializer` añade `HasValidExecutionContext()` y, con el contexto de ejecución desconectado, sigue
    negando `SharedArrayBuffer` y los valores JS compartidos, y ya no desreferencia un contexto de ejecución nulo
    (`UseCounter::Count` en vez de `execution_context->CountUse`);
  - el `MicrotasksScope` se crea con la cola del contexto V8 en lugar de `V8DoNotRunMicrotasksScope(script_state_)`.
- **Por qué entra en esta tanda:** sin él, `chromium/0003` rompe extensiones de usuario muy usadas. Las API que usa
  (`ScriptState::ContextIsValid`, `UseCounter::Count`, `mojom::blink::WebFeature`, `ScopedSharedArrayBufferForTest`)
  existen en la 156. Brave no toca estos ficheros.
- **Aplica a Mac.** **Para LOCAL:** `blink_unittests --gtest_filter='WorldSafeV8Reference*:V8ScriptValueSerializer*'`,
  y a mano: Tampermonkey con un script de usuario que use `CustomEvent` entre mundos.

## `chromium/0027`: [M159] EME, `MediaKeySession` sin uso tras liberar en `OnSessionKeysChange` (crbug 589815781)

**`d86157c50d`** de la **8154** (26-11 17:23 UTC; bug del merge 590699888; main `53c7631524`, #1754722). **Gravedad no
publicada.** Aún sin merge a la 8078. Portado desde el diff de main y **comparado después con el cherry-pick**: son iguales.
- **El fallo, dos usos tras liberar:**
  - `MediaKeys::createSession()` comprobaba el `ExecutionContext` de `MediaKeys` pero construía la sesión con el del
    reino del *wrapper* que recibía la llamada. Si el *wrapper* se recreaba en otro reino (un `iframe` ya quitado), la
    sesión observaba un contexto ya destruido cuyo `ContextDestroyed()` nunca llegaba;
  - `OnSessionKeysChange()` guardaba el `ukm::UkmRecorder*` (propiedad del `Document`) antes de `AddEntry()`, que reserva
    en Oilpan. Si esa reserva disparaba un GC que finalizaba el `Document`, el `Record()` usaba memoria liberada.
- **El arreglo:**
  - la sesión se construye con el `ExecutionContext` de `MediaKeys` (`createSession` deja de recibir `ScriptState`; el
    IDL pierde `CallWith=ScriptState`) y el constructor hace `CHECK` de que el contexto está vivo;
  - `OnSessionKeysChange()` hace `CHECK` del contexto y pide el `UkmRecorder` después de cada `AddEntry()`;
  - prueba nueva `MediaKeySessionTest.CreateSessionUsesMediaKeysExecutionContext`.
- **Adaptación a la 156 (cuatro trozos rehechos a mano, mismo cambio):**
  - el `action_timer_` de la 156 usa `TaskType::kMiscPlatformAPI` y no `kMediaElementEvent`: se conserva el de la 156;
  - en `media_keys.h`, el `#include` de `modules_export.h` va tras `encrypted_media_utils.h` (la 156 tiene además
    `dom_array_piece.h`);
  - en `media_keys.idl`, `setServerCertificate` no lleva `[PassAsSpan]` en la 156: solo se cambia la línea de
    `createSession`;
  - en `modules/BUILD.gn`, la prueba entra antes de `eventsource/event_source_parser_test.cc` (la 156 no tiene
    `encoding/text_*_test.cc`).
  - Lo demás entra tal cual. No hay más llamadas a `createSession` ni al constructor de `MediaKeySession`, y Brave no
    toca `encryptedmedia`. Comprobado a ojo que las interfaces que imita la prueba (`WebContentDecryptionModule*`,
    `MediaKeysConfig`, `MediaKeys(...)`, `WebData(span)`) son iguales en la 156; la prueba no se ha compilado.
- **Aplica a Mac** (EME con Widevine o Clear Key). **Para LOCAL:** `blink_unittests --gtest_filter='MediaKeySession*'`
  y una reproducción con Clear Key (p. ej. las WPT `encrypted-media/clearkey-*`).

## `chromium/0028`: [M156] IndexedDB, los *blobs* en memoria usan el comparador de claves de la base (crbug 589433703)

El merge **`668565aef7`** de la **8078** (26-11 18:27 UTC; bug del merge 590348260; main `541a1a626e`, #1752574;
gemelo M159 `34a2c35b85`), tal cual. **Gravedad no publicada.**
- **El fallo:**
  - el almacén LevelDB de IndexedDB guarda en memoria los *handles* de los *blobs* durante una transacción de
    escritura (y siempre en incógnito), en un `std::map` indexado por la clave serializada;
  - ese mapa comparaba byte a byte en lugar de usar el comparador de la base (`CompareKeys`). Dos claves
    equivalentes con distinta serialización (`0` y `-0`) acababan en entradas distintas, y el registro de cambios
    de *blobs* quedaba incoherente con la base.
- **El arreglo:** `ExternalObjectChangeMap`, un `std::map` con `EncodedKeyComparator` (`CompareKeys(a, b) < 0`), para
  `external_object_change_map_` e `in_memory_external_object_map_`. Prueba nueva
  `LevelDbBackingStoreTestWithBlobs.ExternalObjectsWithEquivalentKeys`. Brave no toca estos ficheros.
- **Aplica a Mac.** **Para LOCAL:** `content_unittests --gtest_filter='*LevelDbBackingStoreTestWithBlobs*'`.

## `chromium/0029`: [M156] Highlights, las capas de resaltado salen de los marcadores que se pintan (crbug 589817014)

El merge **`4e52785287`** de la **8078** (26-11 ~21:30 UTC; bug del merge 590700156; main `5b902e8c32`, #1753828;
gemelo M159 `084b5eb0a1`), tal cual sobre `0028`. **Gravedad no publicada.** Ya va en la versión publicada
156.0.8078.125: su tag apunta a este mismo commit.
- **Sustituye a la versión M159** (`084b5eb0a1`) que había entrado primero en la tanda. Las dos hacen el mismo cambio
  en el código. Difieren en una línea de la prueba: la 156 llama a `GetLayoutObject()->StyleRef()` porque su
  `LayoutObject::Style()` no devuelve la referencia que pide `HighlightOverlay::ComputeLayers()`, y con la versión
  M159 la prueba no habría compilado.
- **El fallo:**
  - al editar, los marcadores de la CSS Custom Highlight API pueden pasar a un nodo de texto nuevo antes de que se
    reconstruya el registro por nodo de `HighlightRegistry`;
  - si en ese hueco se pinta de forma síncrona (recursos SVG), `HighlightOverlay` llamaba a
    `GetActiveHighlights(node)`, que solo tenía un `DCHECK`. En Release hacía `find(&node)->value` sobre `end()`:
    una lectura fuera de la tabla.
- **El arreglo:**
  - el conjunto de resaltados activos se construye con los marcadores que se están pintando;
  - se elimina `GetActiveHighlights()`, y la caché por nodo queda solo para el *hit testing*;
  - prueba nueva en `highlight_overlay_test.cc`. Brave no toca estos ficheros.
- **Aplica a Mac.** **Para LOCAL:** `blink_unittests --gtest_filter='HighlightOverlayTest.*:HighlightRegistry*'` y las WPT
  `css/css-highlight-api/`.

## `chromium/0030`: [M159] Blink, las excepciones de los *worklets* de CSS Paint y Layout no salen al script de la página (crbug 589449226)

**`5033ef6a31`** de la **8154** (26-11 ~22:40 UTC; bug del merge 590700217; main `b9d8b3b890`, #1754193). **Gravedad no
publicada.** Aún sin merge a la 8078.
- **El fallo:**
  - `CSSPaintDefinition::Paint` llamaba a `MaybeCreatePaintInstance` antes de abrir su `v8::TryCatch`. Si el
    constructor de la clase de pintado lanzaba una excepción durante un pintado síncrono, la excepción se quedaba en
    el *isolate* de V8 y, al cerrar el ámbito del *worklet*, pasaba al script de la página;
  - `CSSLayoutDefinition` tenía lo mismo en `CreateInstance`, `Instance::Layout` e `Instance::IntrinsicSizes`: sin
    `v8::TryCatch`;
  - según el propio commit, eso puede provocar un cierre inesperado.
- **El arreglo:**
  - `Paint` comprueba `ContextIsValid()` antes del `ScriptState::Scope` y abre el `v8::TryCatch` (verboso) antes de
    construir la instancia;
  - `CSSLayoutDefinition` añade un `v8::TryCatch` verboso en los tres puntos, fuera de `V8RunMicrotasksScope`;
  - pruebas: `PaintWorkletTest.ConstructorExceptionDoesNotPropagate` y dos WPT nuevas.
- **Adaptación a la 156** (solo en la prueba; el código entra tal cual):
  - el trozo de `paint_worklet_test.cc` no aplicaba porque la 156 no tiene la última prueba de la 159. La prueba nueva
    va al final del fichero;
  - usa `layout_object.StyleRef()` en vez de `Style()`, como el resto de esa prueba en la 156, porque `Style()` no
    devuelve una referencia.
  - Brave no toca estos ficheros.
- **Aplica a Mac.** **Para LOCAL:** `blink_unittests --gtest_filter='PaintWorkletTest.*'` y las WPT
  `css/css-paint-api/constructor-error-synchronous.https.html` y `css/css-layout-api/fallback-synchronous-errors.https.html`.

## `chromium/0031`: [M156] Blink, los *floats* iniciales no se descuadran entre columnas de *ruby* (crbug 589800513)

El merge **`4f04f94c6c`** de la **8078** (27-11 03:49 UTC; bug del merge 590348310; main `dbefedf27b`, #1753881; gemelo
M159 `3d3935ca`), tal cual sobre `0030`. **Gravedad no publicada.**
- **El fallo:**
  - `InlineLayoutAlgorithm::PositionLeadingFloats` seguía de largo por `kOpenRubyColumn` (un elemento «vacío») y
    colocaba en `LeadingFloats` los *floats* que hay dentro de un `<ruby>`;
  - `LineBreaker::HandleRuby` maqueta cada columna de *ruby* con un `LineBreaker` hijo con `LeadingFloats` vacío, así que
    esos *floats* se maquetaban otra vez sin avanzar `leading_floats_index_`;
  - los *floats* siguientes tomaban por índice entradas de `LeadingFloat` que ya no les correspondían.
- **El arreglo:**
  - `PositionLeadingFloats` se para en `kOpenRubyColumn` y no hace nada al reanudar un corte dentro de *ruby*
    (`RubyData()`);
  - cada `LeadingFloat` guarda el índice de su `InlineItem`. `LineBreaker::HandleFloat` lo comprueba con un `CHECK_EQ`, y
    `RewindFloats` empareja por ese índice;
  - todo va tras la función de Blink `RubySkipLeadingFloats`, `stable` (encendida), como interruptor de emergencia;
  - pruebas: `InlineLayoutAlgorithmTest.LeadingFloatWithRuby` y la WPT
    `css/css-ruby/crashtests/leading-float-in-ruby-crash.html`.
- **Sin adaptación:** es el propio merge M156. Brave no toca `layout/inline/`. Sus trozos en
  `runtime_enabled_features.json5` más cercanos a la entrada nueva (línea 5488) están en las 5193 y 6626: no chocan.
- **Aplica a Mac.** **Para LOCAL:** `blink_unittests --gtest_filter='InlineLayoutAlgorithmTest.*:LineBreakerTest.*'` y la
  WPT nueva.

## `chromium/0032`: [M156] Blink, el *layout* de un `fieldset` no entra en sus hijos si está bloqueado por *display lock* (crbug 589815787)

El merge **`c05f0c54bb`** de la **8078** (27-11 09:02 UTC; bug del merge 590348142; main `b9836c7432`, #1753359; gemelo
M159 8154 `1a3e847a61`), tal cual sobre `0031`. **Gravedad no publicada.**
- **El fallo:**
  - con *display lock* (por ejemplo, `content-visibility: hidden`), `BlockNode::FirstChild()` no devuelve hijos;
  - pero el `fieldset` es especial y llega a los suyos con `GetFieldsetContent()` y `GetRenderedLegend()`, que no
    miraban el bloqueo. El algoritmo de `fieldset` podía así maquetar hijos que no debía tocar.
- **El arreglo:** los dos devuelven nulo si `ChildLayoutBlockedByDisplayLock()`, y `FieldsetLayoutAlgorithm` solo maqueta el
  contenido si existe. Prueba nueva: la WPT `css/css-contain/content-visibility/crashtests/fieldset-with-shadowroot.html`.
- **Sin adaptación:** es el propio merge M156. Brave no toca estos ficheros.
- **Aplica a Mac.** **Para LOCAL:** la WPT nueva y `blink_unittests --gtest_filter='*Fieldset*'`.

## `chromium/0033`: [M156] Caché de disco, mover y borrar la caché no sigue enlaces simbólicos (crbug 578691708)

El merge **`6a41a1772a`** de la **8078** (27-11 10:40 UTC; bug del merge 590971315; main `fe710bd127`, #1755328, que es el
*reland* de `13b9f13fab`), tal cual sobre `0032`. **Gravedad no publicada.**
- **El fallo:**
  - en POSIX, `disk_cache::MoveCache` usaba `base::Move`, que, si falla el `rename`, copia y borra;
  - el borrado de la caché recorría directorios sin cuidarse de los enlaces simbólicos. El commit no explica el ataque,
    pero las comprobaciones que añade apuntan a eso: un enlace dentro del directorio de la caché, o en su lugar, podía
    hacer que Chromium moviera o borrara ficheros fuera de ella;
  - además, `BackendImpl::RestartCache` volvía a iniciar la caché aunque la limpieza hubiera fallado.
- **El arreglo:**
  - `MoveCache` valida el origen y el destino: ni vacíos, ni con `..`, ni enlaces; el origen tiene que ser un directorio y el
    destino no debe existir. Luego mueve con `base::ReplaceFile` (`rename`), sin copiar;
  - el borrado nuevo (`internal::DeleteCacheContents`) usa `openat`/`unlinkat` con `O_NOFOLLOW` y no sigue enlaces;
  - `DeleteCache` devuelve si ha salido bien, y `RestartCache` deja la caché desactivada si la limpieza falla;
  - pruebas nuevas en `cache_util_unittest.cc` y `backend_unittest.cc`. El *reland* ajusta una prueba que fallaba en
    macOS 13–15: allí `rename(2)` devuelve `EACCES` sobre un directorio con modo 0.
- **Sin adaptación:** es el propio merge M156 (la réplica de gitiles no lo tuvo hasta 1 h después). Brave no toca
  `net/disk_cache`.
- **Aplica a Mac** (`cache_util_posix.cc`). **Para LOCAL:** `net_unittests --gtest_filter='CacheUtilTest.*:*DiskCacheBackendTest*Restart*'`,
  en la 6,1 con Mojave (es la versión de macOS más antigua que tenemos, y la prueba toca un comportamiento de `rename` que
  cambia entre versiones).

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

## `brave-core/0005`: [M159] V8, `__lookupGetter__` no se salta la comprobación de acceso (crbug 586878505)

Puerto del merge **`78d94a8570`** de V8 15.9.128.38 (24-11 13:55 UTC; bugs 590052667 y 586878505; cherry-pick de main
`602aeed99c`). **Aún no está en la 15.6. Gravedad no publicada; es una fuga de datos entre orígenes.**
- **El fallo:** `ObjectLookupAccessor` (`__lookupGetter__` y `__lookupSetter__`) se saltaba un `AccessorInfo` y seguía
  subiendo por la cadena de prototipos, y `LookupIterator::Next()` arrastraba un `state_` viejo a
  `LookupInSpecialHolder()` del siguiente objeto. Juntos dejaban leer los accesores del global de otro reino (otra ventana
  de otro origen) sin comprobación de acceso.
- **El arreglo:** un `AccessorInfo` devuelve `undefined` (tapa a los accesores de más arriba, como dice la especificación);
  `Next()` pone `state_` a `NOT_FOUND` al dejar un objeto ordinario; `NextInternal()` lleva un `CHECK_EQ` en release.
  Trae la prueba `regress/regress-586878505.js`.
- **Aplica tal cual** sobre 15.6.75.66 (una línea de desfase en `lookup.cc`). `Start()`, `Next()` y `NextInternal()` son
  iguales en la 15.6.75.66 y en la 15.9.128.37, y `builtins-object.cc` es idéntico. Los únicos llamadores de
  `NextInternal()` son `Start()` y `Next()`, y los dos llegan con `NOT_FOUND`, así que el `CHECK` nuevo no salta por
  diferencias de la 15.6. Ningún otro `patches/v8` toca esos ficheros. Época de caché: la cubre `0001`.

## `brave-core/0006`: V8, la pieza que le faltaba a la serie del parser de la 3.0.1 (crbug 571126471)

Main **`2ea1b126e2`** de V8 (#110518, 09-10; Toon Verwaest), tal cual. No está en la 15.6; la 15.9 lo lleva desde su punto
de rama. **Gravedad no publicada.** Lo pidió COORDINACIÓN-62 (buzón `…1426-COORDINACION-62-es6-rojos`).
- **El problema:** desde la 3.0.2, D8-LINUX ve en rojo dos pruebas que trajo nuestra propia serie del parser
  (CVE-2026-121082, 21 commits de main portados en la 3.0.1): `es6/regress-arrow-cover-grammar-scope` y
  `es6/regress-strict-param-error-order`. Se lanza el `SyntaxError`, pero con el mensaje de un error posterior.
- **La causa:** a la serie le faltaba `2ea1b126e2`. En main entró siete minutos antes que `618b7515c6` (la de la primera
  prueba), y su guarda en `ArrowHeadParsingScope::RecordDeclarationError` (conservar el **primer** error) es la que dan
  por hecha `618b7515c6` y `7f9cb9e341` (la de la segunda). Sin ella, en `"use strict"; (1, ...eval) => {}` el error de
  `eval` pisa al de `1`, y en `([a.b], 1) => {}` el de `1` pisa al de `a.b`. Las dos pruebas son idénticas a las de main
  y a las de la 15.9: **no hay que tocarlas.**
- **Cómo se encontró:** comparando nuestro `src/parsing` (15.6.75.66 + `patches/v8`) con el de la 15.9; luego, aplicando a la
  inversa `618b7515c6`, `7f9cb9e341` y `87fabc80d7` (los tres están completos en nuestro árbol) y buscando por bisección en
  main el commit que trae la guarda.
- **Lo que trae, además de la guarda:** `CHECK_GT(end_position, start_position)` en
  `GetDataForSkippableFunction` y `CHECK_GE(pos, current_pos)` en `Scanner::SeekForward`, los dos de release. Una
  `PreparseData` corrupta dentro del sandbox ya no puede hacer retroceder el escáner: es un endurecimiento del sandbox.
  Trae la prueba `sandbox/regress-571126471.js` (con `--sandbox-testing`).
- **Aplica tal cual** sobre 15.6.75.66. `expression-scope.h` ya tenía parche: se rehízo acumulado (el hunk nuevo entra
  27 líneas antes que en main). `preparse-data.cc` y `scanner.cc` no los toca ningún otro `patches/v8`. Época de caché:
  la cubre `0001` (no cambia el bytecode).
- **Probado (D8-LINUX-6, 24-11, buzón `…1444-D8-LINUX-6-0011-y-0006`):** `es6/*` 483/483, con las dos rojas en verde
  (no falta otro commit de la serie); `sandbox/regress-571126471` 1/1; `regress/regress-567222737*` 6/6; `*parser*` 4/4;
  `message/*` 371/371; `v8_unittests` `*Pars*:*Scanner*:*Preparse*` 397/397.

## `brave-core/0007`: [M156] V8, `InvokeApiFunction` respeta los ámbitos sin JS (crbug 576333024)

**`474a6307ce`** de V8 **15.6** (15.6.75.84, 25-11 08:57 UTC; bugs 584997097 y 576333024): el *reland* de `af144bc8d4`,
que fue la 15.6.75.59. La .60 lo revirtió (`a62636bc52`) porque «depende» de crbug 566156384, por un fallo en el bot
`fuchsia-x64-cast-receiver-rel` (`3.1.2/CONTENIDO.md`). **El *reland* es idéntico byte a byte** (mismo `patch-id`
`2b46e1b065`). No da motivo, pero upstream lo lleva ya en Chrome 156, y en las ramas 8078 y 8154 no aparece ningún commit
con el 566156384. Entra tal cual sobre la 15.6.75.66. **Gravedad no publicada.**
- **El fallo:** `Builtins::InvokeApiFunction` llamaba a las *callbacks* C++ de `FunctionTemplate` sin las comprobaciones
  `DisallowJavascriptExecution`/`ThrowOnJavascriptExecution`/`DumpOnJavascriptExecution` que `Execution::Invoke` aplica
  al JS. Una *callback* podía ejecutarse dentro de un ámbito en el que el motor da por hecho que no corre código, y
  romper sus invariantes (el patrón típico de uso tras liberar).
- **El arreglo:** aplica las mismas comprobaciones, salvo en los constructores de API sin efectos secundarios
  (`kHasNoSideEffect`; en `include/v8-function.h` solo cambia un comentario). Además, `ValueDeserializer::ReadJSMap` y
  `ReadJSSet` llenan el `Map` y el `Set` en C++, sin llamar a `set`/`add`, y ya no necesitan permitir JS. Trae pruebas.
- **Riesgo:** cambia el comportamiento. Si algún código de Blink o de Brave llama a una función de API dentro de un ámbito
  sin JS, ahora lanza una excepción o, con `DumpOnJavascriptExecution`, tumba el proceso. Chrome 156 ya lo lleva, así que
  la parte de Chromium está cubierta; **la de Brave hay que mirarla navegando**.
- Ficheros: `src/api/api.cc` ya tenía parche de FlyWeb; los demás son nuevos en `patches/v8`.

## `brave-core/0008`: [M159] V8, debug-evaluate no iza `var`/`function` a módulos ni a enlaces léxicos (crbug 589433702)

**`d76136bcef`** de V8 **15.9** (15.9.128.39, 25-11 08:58 UTC; bug del merge 590348412; main `eb88dd314f`). **Aún no está
en la 15.6.** Entra tal cual sobre la 15.6.75.66; `runtime-scopes.cc` ya tenía parche de FlyWeb, sin conflicto, y todo lo
que usa existe en la 15.6. **Gravedad no publicada.**
- **Merge M156 (26-11 08:15 UTC):** V8 15.6 **`6d5d7dc23a`** (15.6.75.87; bug del merge 590347087). **El nuestro es más
  estricto, y se queda como está.** El M156 rechaza igual los `ModuleContext` y los *bindings* léxicos o de solo lectura,
  con los mismos `DCHECK`. No incluye el tercer caso del M159: el `arguments` implícito de una función con parámetros no
  simples (`index != kNotFound && IsFunctionContext() && !HasSimpleParameters()`), ni su prueba (`function arguments(){}`,
  `runNonSimpleParams: [null,0]`). Lo demás del `.patch` de `runtime-scopes.cc` (`MarkContextSlotNotAssignedIsUnreliable`)
  es de otro port que ya estaba en ese fichero, no de este.
  - La **8078** ya sube V8 a esta 15.6.75.87 (`3d68ce799d`, «Roll src/v8 in M156 from 8191c808fb9f to 3c7ca7fa2c4c»).
- **El fallo:** al evaluar en un marco del depurador (DevTools), un `var` o `function` del fragmento se izaba más allá del
  `DebugEvaluateContext` sin la comprobación de conflictos del parser. `DeclareEvalHelper` podía escribir un índice de
  celda de módulo en un `ModuleContext` (o tratar un `SourceTextModule` como `JSObject`), sobrescribir `const`/`let` o
  envolver ranuras en TDZ: corrupción de memoria.
- **El arreglo:** rechaza de entrada cualquier `ModuleContext` con `EvalError`, y los enlaces léxicos, de solo lectura o el
  `arguments` implícito con parámetros no simples dan un `SyntaxError` de redeclaración. Trae prueba de inspector.
- **Alcance:** solo con el depurador (DevTools abiertas o una extensión con permiso `debugger`). Aplica a Mac.

## `brave-core/0009`: [M156] V8, Maglev deja etiquetados los Phi de una sola entrada (crbug 587040688)

**`7ef85e6153`** de V8 **15.6** (15.6.75.85, 25-11 12:17 UTC; bug del merge 588740578; main `b9c28af54c`). Entra tal cual
sobre la 15.6.75.66. **Gravedad no publicada.**
- **El fallo:** si la arista de vuelta de un bucle moría a mitad de `PrePhiUntaggingPhase`, unos usos del Phi de una sola
  entrada ya apuntaban a su entrada y otros seguían en el Phi. `MaglevPhiRepresentationSelector` podía quitarle la
  etiqueta (truncarlo o desempaquetarlo) de forma distinta a la de esos usos. Es una mala compilación del JIT, el camino
  típico a la confusión de tipos. Maglev está activo por defecto en la 156: cualquier página llega.
- **El arreglo:** esos Phi se quedan etiquetados. Trae `turbolev/regress-587040688.js`.
- Ningún otro fichero de `patches/v8` toca `maglev-phi-representation-selector.cc`. El árbol de V8 queda en `822e10df96`.

## `brave-core/0010`: [M156] V8, el contexto *incumbent* se compara con `fp()` (crbug 587455884)

**`4faa529e55`** de V8 **15.6** (15.6.75.86, 25-11 18:28 UTC; bug del merge 590347928; main `83e9c391a7`; gemelo M159
`548f85215d`). Entra tal cual sobre la 15.6.75.66. `isolate.cc` ya tenía parche de FlyWeb, sin conflicto. **Gravedad no
publicada.**
- **El fallo:** las llamadas de la *Fast C API* saltan del JS optimizado a C++ sin `ExitFrame`, así que el marco JS que las
  llama se reconstruye con `sp()` nulo. Con un `BackupIncumbentScope` activo, `GetIncumbentContextSlow()` comparaba ese `sp()`
  con la dirección del ámbito. En release leía 0 y podía elegir mal el contexto *incumbent*, que es el que decide, por
  ejemplo, el origen de un `postMessage`: una confusión entre contextos.
- **El arreglo:** compara con `fp()`, que en esos marcos es válido. El árbol de V8 queda en `979f191d9f` (con `0011`, `92df3849a4`).

## `brave-core/0011`: [M156] V8, SimplifiedLowering respeta `kTaggedPointer` (crbug 585624825)

**`2a154b5db9`** de V8 **15.6** (15.6.75.88, 26-11 11:20 UTC; bug del merge 588740156; main `33cdb11f68`; gemelo M159
`51437718f5`, 15.9.128.41; la 8078 rueda V8 a 15.6.75.88 en `5310174b15`, 26-11 13:02 UTC). Entra tal cual sobre la 15.6.75.66. `representation-change.cc`,
`simplified-lowering-verifier.cc` y `turboshaft/operations.h` ya tenían parche de FlyWeb, sin conflicto. **Gravedad no
publicada.**
- **El fallo, una confusión de tipos en el código optimizado:**
  - `TruncatingUseInfoFromRepresentation` devolvía `UseInfo::AnyTagged()` para `MachineRepresentation::kTaggedPointer`;
  - cuando el análisis de escape sustituía por escalares un `PropertyArray` al crecer su almacén, un Phi sobre números
    comprobados como HeapObject podía desempaquetarse a Float64 y volver a etiquetarse como Smi. TurboFan guardaba así
    un Smi en una ranura que debe tener un HeapObject.
- **El arreglo:**
  - `kTaggedPointer` usa `UseInfo::TaggedPointer()`, y mantiene la barrera de escritura de puntero al empaquetar entradas
    `kTaggedSigned`;
  - la operación nueva `ChangeTaggedToTaggedPointer` empaqueta los Smi en HeapNumber sin desoptimizar, en el lowering de
    TurboFan y de Turboshaft, los verificadores y los reductores. Son 14 ficheros, sin prueba en upstream.
- **Montaje:** el merge aplicado en `v8t` sobre el árbol `979f191d9f` (todos nuestros parches de V8) da `92df3849a4`. Los 14
  `.patch` se regeneran con `git diff --full-index 917584bd HEAD -- <fichero>`, el mismo método que reproduce byte a byte
  los que ya había. 11 son nuevos y 3 se amplían. Sección arriba en `patches/v8/FLYWEB-SECURITY.md`; sin cambio de
  bytecode, así que sirve la subida de época 40 → 41 de `0001`.
- **Aplica a Mac.** **Para D8-LINUX y LOCAL:** mjsunit (`compiler/*`, `regress/*`) y `unittests` `*SimplifiedLowering*` y
  `*RepresentationChange*`.

## `brave-core/0012`: [M156] V8, el `sort` que TurboFan mete en línea hace *checkpoint* antes de llamar a `comparefn` (crbug 585624824)

**`1941d806d2`** de V8 **15.6** (27-11 08:01 UTC; bug del merge 586790592; main `686ea5103e`; gemelo M159 `4ac3021e1e`,
15.9.128.43). Entra tal cual sobre la 15.6.75.66. `js-call-reducer.cc` ya tenía parche de FlyWeb, lejos de este trozo, y
su blob de partida coincide con el del merge. **Gravedad no publicada.** La 8078 ya rueda V8 a 15.6.75.89, con este merge, en `473601d703` (27-11 09:01 UTC).
- **El fallo:**
  - el `Array.prototype.sort` que TurboFan mete en línea no tenía *checkpoint* entre las cabeceras del bucle y la
    llamada a `comparefn`;
  - las desoptimizaciones anticipadas que se añaden al bajar esa llamada (por ejemplo, la conversión de argumentos de un
    `comparefn` de Wasm metido en línea) usaban el estado de antes del `sort`. Al desoptimizar, el `sort` volvía a
    empezar cuando las llamadas anteriores a `comparefn` ya habían tenido efectos (por ejemplo, acortar el array).
- **El arreglo:** un `Checkpoint` con la continuación desde la instantánea del `sort`
  (`SortContinueFromSnapshotEagerFrameState`) justo antes de la llamada. Prueba nueva:
  `mjsunit/regress/wasm/regress-585624824.js`.
- **Montaje:** el merge aplicado en `v8t` sobre `92df3849a4` da el árbol `c2e26ed0aa`. Se regeneran con
  `git diff --full-index 917584bd HEAD -- <fichero>` el `.patch` de `js-call-reducer.cc` (se amplía) y el de la prueba
  (nuevo). Sección arriba en `patches/v8/FLYWEB-SECURITY.md`. No cambia el bytecode, así que vale la subida de época
  40 → 41 de `0001`.
- **Aplica a Mac.** **Para D8-LINUX:** mjsunit `regress/wasm/regress-585624824` (con `--turbofan`), `compiler/*`,
  `wasm/*` y `regress/*`.

## `brave-core/0013`: [M156] V8, Maglev y Turbolev mantienen vivo el mapa del enumerador al leer la caché de `for-in` (crbug 590253989)

**`a2c4c5c9dd`** de V8 **15.6** (15.6.75.90, 27-11 09:03 UTC; bug del merge 590971898; main `8a6bd48d91`; gemelo M159
`b10dd63a16`, 15.9.128.44). Entra tal cual sobre la 15.6.75.66. `maglev-graph-builder.cc` y `maglev-ir.h` ya tenían
parche de FlyWeb, sin conflicto; los blobs de partida de los siete ficheros coinciden con los del merge. **Gravedad no
publicada.** La 8078 rueda V8 a 15.6.75.90, con este merge, en `b35a60dbe0` (27-11 10:02 UTC).
- **El fallo, una lectura fuera de límites en el código optimizado:** en Maglev y Turbolev, la lectura de la caché de
  enumeración de `for-in` (`VisitForInNext`) no mantenía vivo el mapa del enumerador. Si ese mapa se recogía, el GC podía
  recortar la caché, y los accesos siguientes leían fuera de ella. TurboFan ya tenía el arreglo.
- **El arreglo:** un nodo nuevo de Maglev, `Retain`, mantiene vivo el mapa durante la lectura. Turbolev lo baja al `Retain`
  de Turboshaft, y un mapa constante se retiene en el objeto de código. Pruebas nuevas: `mjsunit/maglev/regress-590253989.js`
  y `mjsunit/turbolev/regress-590253989.js`.
- **Montaje:** en `v8t` sobre `c2e26ed0aa`, el árbol queda en `9531c8efc0`. Se regeneran 7 `.patch` (5 nuevos y 2 que se
  amplían). Sin cambio de bytecode.
- **Aplica a Mac.** **Para D8-LINUX:** las dos pruebas nuevas (con sus banderas), `maglev/*` y `turbolev/*`, con y sin
  `--maglev`.

## `brave-core/0014`: [M159] V8, comprobación TDZ de los *bindings* de módulo en las búsquedas dinámicas (crbug 587035145)

**`4f37951e9a`** de V8 **15.9** (15.9.128.45, 27-11 09:13 UTC; bug del merge 590972031; main `a5a56b7673`). **Aún sin
merge a la 15.6.** **Gravedad no publicada.**
- **El fallo:**
  - debug-evaluate (evaluar en un *frame* pausado desde DevTools) compila los identificadores libres como búsquedas
    dinámicas;
  - si una resolvía a un *import* o *export* de módulo, `LoadLookupSlot` devolvía el valor de la celda sin comprobar la
    TDZ: leer un *binding* sin inicializar daba el `TdzHole` como valor. `StoreLookupSlot` también escribía en *bindings*
    aún sin inicializar.
- **El arreglo:** las dos lanzan `ReferenceError` (`kNotDefined`), como ya hacía el camino de las ranuras de contexto. Prueba
  nueva del inspector: `debugger/evaluate-on-call-frame-module-tdz`.
- **Adaptación a la 15.6:** los trozos de la M159 no aplicaban porque el código de alrededor se ha movido, y la 15.6 pasa
  `name` a `kConstAssign`. Se han puesto a mano: las líneas añadidas y quitadas son las mismas que en upstream (comprobado
  con `diff`). En `v8t` el árbol queda en `06395c7d6d`. Se regeneran el `.patch` de `runtime-scopes.cc` (ya tenía parche de
  FlyWeb, de `0008`) y los dos de la prueba. Sin cambio de bytecode.
  - La salida esperada de la prueba viene de la 15.9 y puede necesitar retoque en la 15.6.
- **Aplica a Mac.** **Para D8-LINUX:** inspector `debugger/evaluate-on-call-frame-module-tdz` y `debugger/*`, y mjsunit
  `modules-*`.

## Pruebas para LOCAL y D8-LINUX

**D8-LINUX-6, `brave-core/0007`–`0009` en verde** (25-11, `buzon/COORDINACION/20261125-1530-D8-LINUX-6-d8-bc0007-0009.md`,
48235f2d). Árbol de V8 `822e10df96`; `out/x64icu` (Release + DCHECK, ICU). Comparado con la base `0001`–`0006`:

| Prueba | Resultado |
|---|---|
| mjsunit completo | 9224/9224 (+1, `turbolev`) |
| `value-serializer` y serialización | 16/16 |
| `cctest/test-api/*` | 661/661 |
| `unittests` `ValueSerializerTest.*` | 80/80 |
| inspector `debugger/*` | 257/257 (+1, de 0008) |
| `maglev/*` y `turbolev/*`, con y sin `--maglev` | 1322/1322 |
| `turbolev/regress-587040688`, con `--turbolev` | 1/1 |

Sin fallos nuevos. Falta lo de LOCAL: la sesión de navegación de `0007` (DevTools, extensiones y claude.ai).

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
- D8-LINUX: mjsunit `value-serializer`, `cctest` `test-api/*` (sobre todo `*InvokeApi*`, `*NoJS*`, `*DisallowJavascript*`),
  `unittests --gtest_filter='ValueSerializerTest.*'` y mjsunit completo sin fallos nuevos (brave-core/0007). En LOCAL,
  además, una sesión de navegación normal con DevTools, extensiones y claude.ai, por si algo de Brave llama a la API en un
  ámbito sin JS (brave-core/0007).
- D8-LINUX: inspector `debugger/evaluate-on-call-frame-redeclaration` y `debugger/*` (brave-core/0008).
- D8-LINUX: mjsunit `turbolev/regress-587040688` (`--turbolev`), `maglev/*` y `turbolev/*`, con y sin `--maglev`
  (brave-core/0009).
- D8-LINUX: mjsunit completo, `cctest/test-api/*` (incumbent, `BackupIncumbentScope`) y `unittests --gtest_filter='*FastApi*'`
  (brave-core/0010).
- D8-LINUX: mjsunit `regress/regress-586878505`, `es6/*`, `harmony/*` y `regress/*` (brave-core/0005; el `CHECK` nuevo
  de `NextInternal()` es de release).
- `blink_unittests --gtest_filter='*StyleTimeline*:*ScrollTimeline*:*ViewTimeline*'` y las WPT de
  `scroll-animations/` (chromium/0010).
- D8-LINUX: mjsunit `es6/regress-arrow-cover-grammar-scope` y `es6/regress-strict-param-error-order` (deben pasar a
  verde), `sandbox/regress-571126471` con las banderas del sandbox, `es6/*`, `regress/regress-567222737*` y `parser*`
  (brave-core/0006).
- `content_unittests --gtest_filter='BrowserAccessibilityManager*'` y `accessibility_unittests`, y en la 6,1 una pasada
  con VoiceOver por una página y la interfaz (chromium/0012).
- `gpu_unittests --gtest_filter='*RasterDecoder*:*WritePixels*:*CopySharedImage*'` y una pasada de WebGL y canvas
  (`webgl_conformance` si se puede) en la 6,1 (chromium/0013).
- `unit_tests --gtest_filter='LoginHandler*:LoginTabHelper*'` y `browser_tests --gtest_filter='*LoginPrompt*'`
  (chromium/0014).
- `media_unittests --gtest_filter='*Vpx*:*VP8*:*VP9*:*Vp8*:*Vp9*'` y, en la 6,1, una llamada WebRTC con VP9 SVC (L3T3,
  p. ej. la muestra «scalable video coding» de webrtc.github.io), cambiando la resolución y desactivando capas a mitad de
  llamada (chromium/0015; con la reserva, lo mismo).
- `content_unittests --gtest_filter='CacheStorageBlobToDiskCacheTest.*:*CacheStorageCacheTest.*'` (chromium/0017).
- `browser_tests --gtest_filter='PageInfoBubbleViewBrowserTest.*'` (sobre todo `OpenSiteSettingsWhenWebContentsDestroyed`) y
  `unit_tests --gtest_filter='PageInfoTest.*'`; a mano, en la 6,1: abrir la burbuja, pulsar «Configuración de sitios» y
  cerrar la pestaña con Cmd+W enseguida (chromium/0019).
- Skia: `dm --src tests --config gl --match SoftwarePathRenderer` (o `skia_unittests` con ese filtro), y a mano en la 6,1 y la
  5,1 una página con trazados grandes y transformados, comparada con la 3.2.2 (skia/0001).
- `blink_unittests --gtest_filter='SelectionModifierTest.*'` (chromium/0020).
- `media_unittests --gtest_filter='*DecoderSelectorTest.*:*DecoderStreamTest.*'` y vídeo cifrado con Clear Key, cerrando
  la pestaña mientras carga (chromium/0018).
- `content_unittests --gtest_filter='FileSystemAccess*HandleImplTest.*:FileSystemAccessHandleBaseTest.*'` y
  `browser_tests --gtest_filter='ChromeFileSystemAccessPermissionContext*'` (chromium/0016; con el *override* de Brave, las
  pruebas de mover y renombrar ficheros locales pueden fallar por `NotSupportedError`: es lo esperado).
- `blink_unittests` entero en una compilación con DCHECK (D8-LINUX: deben volver las 2765 que tumbaba el DCHECK), y
  las WPT `domparsing/tentative/stream-html-*` y `sanitizer-api/sanitizer-custom-elements-is.tentative.html`
  (chromium/0011).

## Solo Linux

Arreglos que no afectan a Mac pero sí al porte a Linux (aprobado, DIRECTIVAS 22-11). **No se portan todavía**: se hará
cuando haya una versión de Linux que publicar (orden de COORDINACIÓN-61). Para cada uno: commit, crbug y si nuestra
configuración de Linux compila el código.

| Commit | crbug | Qué | ¿Lo compila nuestra Linux? |
|---|---|---|---|
| 8078 `97c8484b2c` [M156] | 577371305 | `ExternalVkImageBacking`: `ProduceGL()` falla si el backing guarda un `NativePixmap`, y la conversión a `NativePixmap` pasa antes, de modo que la creación falla si no se puede | **Sí se compila:** `external_vk_image_backing.cc` está en `gpu/command_buffer/service/BUILD.gn` bajo `enable_vulkan` y `is_linux \|\| is_fuchsia`. `enable_vulkan` es `true` por defecto en Linux y FlyWeb no lo cambia. **En la práctica casi no se usa:** Vulkan va apagado por defecto en Linux (`features::kVulkan`, `FEATURE_DISABLED_BY_DEFAULT` fuera de Android). Además, según el propio commit, el backing con `NativePixmap` solo se da en Fuchsia. |
| 8154 `605bc384c4` [M159] (main #1755087) | 589323186 | `WaylandToplevelWindow` iteraba los *bubbles* hijos mientras los ocultaba, y el delegado podía modificar el vector durante la iteración. Ahora rechaza activar *bubbles* mientras oculta la ventana. Adaptado en la 159 (`Hide()`/`ActivateBubble()`) | **Sí se compila:** `build/config/ozone.gni` pone `ozone_platform_wayland = true` en Linux (con `ozone_auto_platforms`) y FlyWeb no lo cambia. Solo actúa en sesiones Wayland. |
| 8078 `8994ad8cd9` [M156] (main `34e6041497`, #1754219; gemelo M159 8154 `0305d454cf`) | 584204083 | `AXTree`: los dos nodos de anuncio extra (`extra_announcement_nodes_`) apuntan a la raíz del árbol. Al cambiar o quitar la raíz, esta se liberaba antes de borrarlos y quedaban punteros colgantes. Ahora se detecta el cambio de raíz en `ComputePendingChanges()` y se borran dentro de `Unserialize()` antes de liberar la raíz | **Sí se compila:** `ui/accessibility/ax_tree.cc` va en todas las plataformas. Todo lo que cambia está bajo `BUILDFLAG(IS_LINUX) \|\| BUILDFLAG(IS_WIN)`, igual que la creación de esos nodos (`AXTree::CreateExtraAnnouncementNodes`, y su llamada en `ax_node.cc`). En Mac no existen: no cambia nada. |

## Revisados y no aplicables

- **8154 `65f6c4cb6`**: roll de ANGLE en M159 con un solo commit, `2ec7b6db14` «[M159] GL: Read the last row separately when
  a pack fills its buffer» (588202947, 551017142). Es una solución de ANGLE GL para drivers **Mali** (GLES), que solo se
  activa con ellos. **No aplica:** en Mac no hay Mali y WebGL va por Metal.
- **8078 `107cb0a46c`**: roll de Dawn en M156, de `64d303d0bd` a `7b7e6ba308`. Trae un solo commit, `7b7e6ba308` «[M156] DEPS:
  Update DXC to patched branch» (588203839, 588203249, 588203897, 588203012, 589981981, 589982096, 589980992). Lo miró
  COORDINACIÓN-63 desde la 7,1; aquí dawn.googlesource.com sigue bloqueado. **No aplica:** DXC es el compilador de shaders
  HLSL de Direct3D 12, solo Windows; Mac usa Metal. `dawn/0001` sigue aparcado.
- **8154 `4ff7592ac0`**: roll de Dawn en M159, de `e6ee1e5319` a `9fe81c75fa`. Un solo commit, `9fe81c75fa` «[M159] DEPS:
  Update DXC to patched branch», sin `Bug:`. Solo toca `DEPS` y el gitlink `third_party/directx-shader-compiler/src`. Lo miró
  COORDINACIÓN-64 desde la 7,1 (buzón `…0323-COORDINACION-64-dawn-m159`). **No aplica:** es DXC, de D3D12, como el de la M156;
  ni Mac ni Linux.
- **8154 `245f6bc0c`** [Copy Trigger] (589785441, 587818005): con las políticas de auditoría de los conectores
  empresariales (`OnDataCopiedEnterpriseConnector`), copiar dejaba un marcador de «análisis en curso» y al pegar podía
  faltar el texto. Es un fallo funcional del análisis de contenido empresarial, no de seguridad, y FlyWeb no usa esos
  conectores.
- **8078 `2e6c9eed0`**: roll de V8 a 15.6.75.85, que trae `7ef85e6153` (`brave-core/0009`), ya en la tanda.
- **8154 `669a0a6b0d`** [M159] [net] (577402226; main `f6de74a6c2`): `QuicSessionPool` recorre las sesiones con `WeakPtr`
  y se salta las cerradas al avisarles de cambios de red. **Solo Android:** esos avisos (`OnNetworkConnected`/
  `Disconnected`/`MadeDefault`) solo llegan si `NetworkChangeNotifier::AreNetworkHandlesSupported()`, y en la 156 solo
  devuelve `true` `NetworkChangeNotifierAndroid`. En Mac y Linux el pool no se registra como observador
  (`quic_session_pool.cc`, `if (!AreNetworkHandlesSupported()) return;`).
- **8154 `9bce4066b1`** [M159] (586611778): `DesktopCaptureDevice` pide el `SharedImageInterface` en el hilo de la UI y no
  en el de captura. **Solo Windows:** en la 156, ese código solo corre con capturas de textura (`frame->texture()`, un
  `HANDLE` de D3D11 del capturador WGC). En Mac, la captura de pantalla entrega fotogramas en memoria y nunca llega ahí.
  Su gemelo M156, 8078 `5eaee3b93`, tampoco aplica.
- **8154 `30643ce52`** [M159] [webapps] (579501075, 579501200): si llega por sync una aplicación web sin nombre, ya no
  salta un `CHECK` (cierre controlado) en la instalación. Es estabilidad, no seguridad: los datos vienen de la propia
  cuenta de sync, no de una web. Toca siete ficheros, `web_app_specifics.proto` incluido. Fuera de la tanda; se recoge
  con el siguiente cambio de base.
- **8078 `50a21f264a`** y **8154 `1b29608a7`**: rolls de V8 a 15.6.75.84 y a 15.9.128.39. Traen `474a6307ce`
  (`brave-core/0007`) y `d76136bcef` (`brave-core/0008`), ya en la tanda.

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
- **8154 `a0ef70eb06`** (24-11): revert M159 de «[Extensions] Enforce screenshot restrictions in chrome.tabCapture API».
  El original no está en ninguna tanda nuestra (su motivo es la DLP de ChromeOS): nada que hacer.
- **8078 `0d1dc152be`** (24-11): roll de Dawn en M156, `c7cec856c9` → `64d303d0bd`. Un solo commit, `64d303d0bd`, el
  gemelo M156 de `extractBits` (`dawn/0001`, aparcado). Lo miró COORDINACIÓN-62 desde la 7,1 (aquí dawn.googlesource.com
  está bloqueado y el espejo de GitHub no tiene los commits de la rama). Sigue aparcado.
- **8154 `c0e8ff34d8`** (24-11): roll de ANGLE en M159 con dos arreglos de **D3D11** (`fcd0b72056`, b/578681060;
  `8165b581a6`, b/557480846). Solo Windows: no aplica a Mac ni a nuestro Linux.
- **8154 `a5358bd964`** (24-11): «Defer HWNDMessageHandler deletion in WindowEventTarget methods». Solo Windows.
