# FlyWeb 2.7.0 — nivel 138 del motor

Fila FM.53. Base: brave-core `local/261-arreglos` 480f73623798 (2.6.1 publicada), rama `nube/motor-138` (MOTOR-42).
Inventario del 138: `motor-niveles.md` § «Nivel 138» (pendiente).

## Decisiones

### Aplazado del 137

- **`CSSSampleId::kReadingOrder` en su sitio numérico** (839 antes de `kPrintColorAdjust` 848): hecho en 84bff67d. Detrás
  no hay contador implícito (`enumorden.py` sin avisos), así que es orden, no una caída evitada.
- **Particionado de Blob URL: propuesta de no portar los ~27 commits de `content/` del 137** (decide COORDINACIÓN).
  Motivo (V, lectura de código): FlyWeb ya lo tiene. La 128 guarda cada Blob URL con su `StorageKey`
  (`BlobUrlRegistry::IsUrlMapped`/`RemoveUrlMapping` comparan la clave) y la anulación de Brave
  `chromium_src/storage/browser/blob/blob_url_store_impl.cc` (2022) solo resuelve un Blob URL, para `fetch` y para
  navegación, desde la misma partición (o desde una extensión). **Brave 1.79 (Chrome 137) mantiene esa anulación** sobre
  el código de Chrome ya particionado, e ignora `is_top_level_navigation`: es más estricto que Chrome, que deja abrir en
  una pestaña nueva, con `noopener`, un Blob URL de otra partición del mismo origen. Regla 20: la referencia es Brave, y en
  esto ya estamos igual. Lo que trae el porte de Chrome es fontanería (estados `kNotMappedCrossPartition…`, avisos de
  DevTools, la política `PartitionedBlobUrlUsage`, claves de workers) sin cambio de privacidad para quien navega. S: no
  he comprobado línea a línea los workers dedicados y compartidos creados desde un Blob URL de otra partición; lo cubre
  la prueba de Brave `blob_url_browsertest.cc` solo para marcos.

- **`CaretWithTextAffinityUpstream`** (2a137720e54, crbug 40677155): c7fbf1e6. Bandera `stable` como en Chrome 137;
  include de `runtime_enabled_features.h` explícito en `insert_text_command.cc`. Sin arreglos posteriores en upstream.
- **`TextareaStableResizing`** (a687e1c3da8): 8a7edf40. Un hunk de `PointerEventManager::Clear()` a mano (contexto
  distinto en la 128). `PaintLayerScrollableArea::Resize` cambia de firma: los únicos llamadores en la 128 son
  `scroll_manager.cc` y `pointer_event_manager.cc` (S: no he barrido el árbol entero; si LOCAL ve otro, ese llamador
  tiene que guardar `InitializeResizeTransform()` al empezar el arrastre, como hacen los dos; un `{}` daría tamaños
  erróneos). Sin arreglos posteriores salvo quitar la bandera (026c1ff36ec).
- `fuera.py --ref 137.0.7151.122` sobre los 8 parches tocados: 0 avisos. `enumorden.py`: sin avisos.
- **Bit 0 de canvas-float16 (2.6.0: 1 canal de ~250 en un origen): sin causa encontrada, sin cambio de código.** Hipótesis
  descartada con simulación del algoritmo de `PerturbPixelsInternal` (200 claves, 64×64, float16 y float32): un canal
  elegido dos veces vuelve exacto a su valor, como el XOR de 8 bits; ninguna ejecución da un cambio fuera del bit 0.
  Queda como sospecha (S) un píxel que la GPU no rellena idéntico (1 ULP de diferencia en un relleno liso), que la página
  cuenta como «cambiado» sin serlo. `canvas-float16.html` ahora informa del píxel, canal, bits y valores de cada caso
  (hasta 4): LOCAL lo pasa con la 2.7.0 y, con ese dato, se decide. No bloquea (COORDINACIÓN-23, 31-10).

### Nivel 138, tanda del 02-11 (MOTOR-42; `nube/motor-138` 5a86f3aa, sin compilar)

- **`MediaSourceNewAbortAndDuration`** (0cc875d9): encendido sin más; el código que gobierna es idéntico en la 128 y la 138.
- **Contenido mixto** (993b32bd; 3e980163 + aa485810): `ShouldAutoupgrade` decide con `IsMixedContentRestrictedInFrameContext`
  (esquema del marco superior y del actual) en vez del `HttpsState`. Afecta a la anulación de Brave
  `chromium_src/.../mixed_content_checker.{cc,h}` (firma nueva con `LocalFrame*`) y a `.onion`: el camino viejo dependía de
  que `https_state.cc` devolviera `kModern` para `.onion`; se añade el gancho
  `BRAVE_MIXED_CONTENT_CHECKER_IS_MIXED_CONTENT_RESTRICTED_IN_FRAME_CONTEXT` tal como lo tiene Brave 1.80. Sin portar
  `mixed_content_checker_test.cc` (si LOCAL compila `blink_unittests`, ese test no compilará con la firma vieja: pasarle
  `nullptr` como último argumento).
- **`QuotaExceededError`** (5a86f3aa; 3009dd8e, 1b6ec5ba, a7bea0c1, a162e5a3, 400a4608): interfaz nueva derivada de
  `DOMException` con `quota`/`requested`. Adaptado a la 128: `ExceptionState` guarda la excepción construida con
  `SetException` (la 128 la propaga después); sin isolate se lanza un `QuotaExceededError` normal en vez de no lanzar nada
  (upstream volvía sin excepción); fuera los trozos de `modules/ai`. `DOMExceptionCode::kQuotaExceededError` pasa a
  implícito = 37, igual que en la 138 (mismo orden), y `IDBException::kQuotaError` = 37 a juego (`idb_request.cc` hace un
  `static_cast` entre los dos). S: no he barrido la 128 entera buscando otros sitios que supongan el 22.
- **Aplazados a la tanda de mañana** (no son encendidos: piden código posterior a la 128):
  - `progress()`, `abs()`/`sign()`: sintaxis nueva de `progress()` (b9417dbcfe2), recorte del resultado (0f954c71f10) y la
    infraestructura de cálculo sin resolver que comparten con `sibling-index()` (se retiraron en marzo por caídas en flex).
    Van con `sibling-index()`.
  - `ViewportSegments`: `window.viewport` no existe en la 128 (ae78afaca30, ago. 2024). En Mac siempre es un segmento:
    solo aporta coherencia con el Chrome declarado. Coste ~1 h.
  - **Integrity-Policy**: función entera ausente en la 128 (~10 commits: análisis en `services/network`, mojom,
    `navigation_request.cc`, informes, Blink). Más que una tanda corta.
- `fuera.py --ref 138.0.7204.185`: 0 avisos en los 30 parches tocados; `enumorden.py`: sin avisos.

## Para la web

- Al escribir un espacio al principio de una línea partida en un cuadro de texto, el espacio aparece donde está el
  cursor y no al final de la línea anterior.
- Redimensionar un cuadro de texto con el tirador sigue al ratón aunque la página esté ampliada, girada o en
  escritura de derecha a izquierda.
- `QuotaExceededError` es ahora un tipo de error propio, que indica cuánto espacio había y cuánto se pidió.
- La subida automática a HTTPS del contenido mixto (imágenes, audio y vídeo) usa el mismo criterio que el bloqueo.
