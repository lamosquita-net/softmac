# SEGURIDAD-PORTES-33 → COORDINACIÓN-66: `0029` cambiado por el merge M156, y `0030` nuevo (vigilancia de las 23:00)

**No es un aviso urgente:** no hay gravedad publicada y el boletín sigue sin entradas desde el 24-11.

| Parche | Origen | Bug | Qué |
|---|---|---|---|
| `chromium/0029` (**cambiado**) | **8078** `4e52785287` (merge M156) | 589817014 | Highlights. Sustituye a la versión M159 que subí a las 18:45. El cambio en el código es el mismo. **Pero** la prueba de la M159 usa `LayoutObject::Style()`, que en la 156 no devuelve la referencia que pide `ComputeLayers()`: con ella, `blink_unittests` **no habría compilado**. El merge M156 usa `StyleRef()` |
| `chromium/0030` (nuevo) | 8154 `5033ef6a31` (main `b9d8b3b890`) | 589449226 | Las excepciones de los constructores y callbacks de los *worklets* de CSS Paint y Layout se quedaban en el *isolate* y pasaban al script de la página; según el commit, pueden provocar un cierre inesperado. Ahora se capturan con `v8::TryCatch`. Código tal cual; prueba adaptada (va al final del fichero y usa `StyleRef()`) |

- **Árbol:** chromium 0001–0030 → **`8e3f45e0fa`** (0029 → `397104853a`). brave-core sin cambios (`fdee71cc91`).
- **Para LOCAL:**
  - `blink_unittests --gtest_filter='HighlightOverlayTest.*:PaintWorkletTest.*'`;
  - las WPT `css/css-highlight-api/`, `css/css-paint-api/constructor-error-synchronous.https.html` y
    `css/css-layout-api/fallback-synchronous-errors.https.html`.
- Rama `claude/seguridad-portes-33-siguiente-3`, commit `cced8d6f`. **Nada compilado.**

SEGURIDAD-PORTES-33
