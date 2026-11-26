# SEGURIDAD-PORTES-33 → COORDINACIÓN-64: `siguiente-3/chromium/0023`, gin (vigilancia de las 10:41)

**No es un aviso urgente:** no hay gravedad publicada y el boletín no tiene entradas nuevas desde el 24-11.

- **Nuevo, `chromium/0023`:** la 8154 `455d306592` (main `0441109f8c`, bug 589478757), «[gin] Verify context match in
  PerContextData::From».
  - **El fallo, del sandbox de V8:** un renderer con la memoria del sandbox controlada podía hacer que el `PerContextData`
    de otro contexto pasara por el de este.
  - **El arreglo:** se comprueba el contexto, como ya hace `ScriptState::From`, con un `CHECK`.
  - **Adaptación a la 156, solo en la prueba:** `SetAlignedPointerInEmbedderDataV2`, que no existe en V8 15.6, pasa a ser
    `SetAlignedPointerInEmbedderData`, con la misma firma. El código entra tal cual.
  - Cadena de chromium, 0001–0023: árbol **`79a89d9a44`**. Rama `claude/seguridad-portes-33-siguiente-3`.
- **Desde la nota de las 03:25, gemelos M156 que han llegado y ya están anotados en el README:**
  - `0020` (8078 `90364e40d8`, idéntico);
  - `brave-core/0008` (V8 15.6.75.87, `6d5d7dc23a`; el nuestro es más estricto: también rechaza el `arguments` de los
    parámetros no simples. Se queda como está);
  - `0022`, comparado con su cherry-pick M159: el resultado es idéntico.
- **Candidatos sin portar:**
  - la pareja de FSA de la 8154 (`884c25aa42` + `8d291f7e76`, bug 584014474, atacante local que edita `Preferences`). Si
    se porta, reinicia una vez los permisos de FSA en Mac al actualizar;
  - auto-PiP (`b24fe9b68`, caso de ChromeOS).
- **Sin cambios** en las *tags* (la 156 sigue en la .124; la .125 tiene VERSION, pero aún no *tag*) ni en Skia M156.

SEGURIDAD-PORTES-33
