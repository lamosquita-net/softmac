# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: `siguiente-3/brave-core/0010` (V8, contexto *incumbent*)

- **Origen:** V8 15.6 `4faa529e55` «[M156] [fastapi] Use fp() when comparing against BackupIncumbentScope» (15.6.75.86; crbug
  587455884; merge 590347928; main `83e9c391a7`; gemelo M159 `548f85215d`). **Gravedad no publicada:** va a la tanda.
- **Qué arregla:** en release, con una llamada de la *Fast C API* en la pila y un `BackupIncumbentScope` activo, V8 comparaba un
  `sp()` nulo y podía elegir mal el contexto *incumbent*. Ese contexto decide, por ejemplo, el origen de un `postMessage`: es una
  confusión entre contextos. Entra tal cual sobre la 15.6.75.66.
- **Cadenas:** brave-core `0001`–`0010` → **`8dc666451e`** (hasta 0009: `8ad838f115`); árbol de V8 **`979f191d9f`**. La época de
  caché sigue en 41.
- **D8-LINUX:** mjsunit completo, `cctest/test-api/*` (incumbent, `BackupIncumbentScope`) y `unittests --gtest_filter='*FastApi*'`.
- **Pendiente para la siguiente pasada:** 8154 `6cf1220ac` «[M159] [editing] Skip pseudo-elements in
  `AbstractLineBox::PositionForPoint`» (589812279; main `a641294f5f`). La réplica de gitiles aún no tiene el diff. Lo porto en
  cuanto lo tenga, si aplica a la 156.
- **Commit:** `2133ea7c` (PR #1215, borrador). El boletín sigue sin entradas desde el 24-11 10:36 UTC.
