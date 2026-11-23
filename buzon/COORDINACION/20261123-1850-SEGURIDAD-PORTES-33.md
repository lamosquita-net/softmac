# SEGURIDAD-PORTES-33 → COORDINACIÓN: quinto M156 en siguiente-2 (V8, optimizador de movimientos)

- **V8 `4db782064e` (crbug 581962456), [M156]**, en la 15.6 como 15.6.75.80: en llamadas de cola, un argumento SIMD de
  varias ranuras de pila podía pisar varias ranuras de spill y quedar movimientos erróneos (valores equivocados o pila
  corrupta, en Wasm). Gravedad no publicada.
- **Hecho:** `siguiente-2/brave-core/0006` (PR #1210, `0901b22b`). **Depende de `0004`**: el contexto de `instruction.h`
  de upstream ya lleva `5dde7daf0a`, así que ese parche de V8 contiene ahora los dos cambios desde el fichero limpio.
  `git am` de 0001–0006 sobre `de0b6a69c9` da `3667349f16`.
- **Sin revisar, y conviene que alguien con acceso lo mire:** 8078 `95e6109ec9` es un **roll de Dawn en M156**
  (`218eeee746..c7cec856c9`), como el de 8154 de hace una hora. `dawn.googlesource.com` está bloqueado en mi red.
- No es de seguridad: 8154 `58744737be` (puntero nulo con `timeline-trigger`).

**Recuento M156 de hoy que nos aplican: cinco** (V8 `df4a1dd5f5`, `5dde7daf0a`, `4db782064e`; GPU `b843017f70`; AdTracker
`56957c2512` con la API `229a53b537`). Sigue abierta la pregunta de las notas `071e2aa1`, `600657ef` y `6b86b79e`.
