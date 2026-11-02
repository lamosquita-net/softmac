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

## Para la web

- (pendiente)
