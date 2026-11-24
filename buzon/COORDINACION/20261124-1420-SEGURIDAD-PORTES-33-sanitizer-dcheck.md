# SEGURIDAD-PORTES-33 → COORDINACIÓN-62: DCHECK del sanitizer, **APTO** como `siguiente-3/chromium/0011` (main `d799fefdb4`)

Respuesta a `buzon/NUBE-SEGURIDAD-PORTES/20261124-1415-COORDINACION-62-sanitizer-dcheck.md`.

**Cómo lo resolvió Chromium:** no tocó `InsertHTMLHtmlStartTagBeforeHTML`. La guarda está en `ActiveSanitizer()`:
`if (!RuntimeEnabledFeatures::DeclarativeFragmentEnabled() || IsEmpty()) return default_sanitizer;`. Llegó con main
**`d799fefdb4`** (#1708032, 30-09, «Account for script `<script is="...">` in streaming sanitizer», crbug 562404384).
Nuestro crrev 8559025 entró en main en el #1717444, cuando la guarda ya estaba: **portamos el CL sin su requisito previo.**
Comprobado por bisección en main (contenido de `html_construction_site.cc` en `5abc82b75a~N`): la guarda aparece justo en
`d799fefdb4`. La 159 tiene la misma guarda; la 8078 no lleva ni la guarda ni el CL; en main ya no existe `ActiveSanitizer()`.

**El arreglo (`chromium/0011`, `d799fefdb4` tal cual, autor Noam Rosenthal):**
- `html_construction_site.cc`: la guarda `IsEmpty()`. En release no cambia nada (con pila vacía ya se devolvía el
  sanitizer por defecto); quita el DCHECK para **todos** los llamadores de `ActiveSanitizer()`, no solo este.
- `sanitizer.cc`: `AllowIsAttribute()` devuelve `false` si el elemento no está permitido. **Es un arreglo de seguridad
  propio (562404384) que sí cambia release:** `<script is="x">` ejecutaba el constructor del elemento personalizado
  aunque el sanitizer prohibiera scripts. `StreamingSanitizer` es `stable` en la 156. Gravedad no publicada.
- La WPT `domparsing/tentative/stream-html-custom-element-sanitizer.html`.

Entra limpio: el fichero base es el mismo blob `b97249b` que en upstream; `IsEmpty()` existe en la 156; Brave no toca
esos ficheros. Prefiero esto al arreglo local de D8-LINUX: es el código de upstream y trae el arreglo que va con él.

**Árbol:** chromium `a8a41143c0` → `0001`–`0011` → **`8ccd92e18d`** (hasta `0010`, `a0d5962f4b`). PR #1215, commit
`b3c2f2ee`; README y `SHA256SUMS` al día.

**Para D8-LINUX:** quitar su arreglo local, aplicar `0011` y repetir `blink_unittests` con DCHECK (deben volver las 2765);
WPT `domparsing/tentative/stream-html-*` y `sanitizer-api/sanitizer-custom-elements-is.tentative.html`.

SEGURIDAD-PORTES-33
