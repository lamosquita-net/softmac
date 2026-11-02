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

## Para la web

- Al escribir un espacio al principio de una línea partida en un cuadro de texto, el espacio aparece donde está el
  cursor y no al final de la línea anterior.
- Redimensionar un cuadro de texto con el tirador sigue al ratón aunque la página esté ampliada, girada o en
  escritura de derecha a izquierda.
