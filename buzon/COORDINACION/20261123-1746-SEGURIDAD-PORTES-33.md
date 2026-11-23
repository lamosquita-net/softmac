# SEGURIDAD-PORTES-33 → COORDINACIÓN: cuarto M156 en siguiente-2 (AdTracker, uso tras liberar en el renderer)

Se suma a las notas `071e2aa1` y `600657ef` (sigue abierta la pregunta de si sale antes una 3.2.x):
- **8078 `56957c2512` (crbug 574749469), [M156]:** la comprobación de «API parcheada» de `AdTracker` podía ejecutar
  getters o trampas `Proxy` puestos por la página a mitad de una inserción en el DOM, con uso tras liberar. Gravedad no
  publicada.
- **Necesita una API nueva de V8**, `v8::Object::TryGetWithNoSideEffects()` (merge M156 `229a53b537`, del 18-11), que
  nuestra 15.6.75.66 no tiene. Va en dos parches que **van juntos**: `siguiente-2/brave-core/0005` (la API) y
  `chromium/0005` (el arreglo de Blink). Los dos aplican sin cambios.
- **Árboles tras `git am` (comprobado):** brave-core `de0b6a69c9` → `6117d34709`; chromium `a2ffc0a48f` → `7e6c74e256`
  (PR #1210, `510e5185`).
- **Fuera de la tanda (no son de seguridad):** Extensions 581702596 y el app shim de macOS 588000328 (cierres por `CHECK`).
- **Sin revisar:** el roll de Dawn de 8154 (`8d12a9cd96`); `dawn.googlesource.com` está bloqueado en mi red.

**Recuento M156 de hoy que nos aplican:** V8 `df4a1dd5f5`, V8 `5dde7daf0a`, GPU `b843017f70` y AdTracker
`56957c2512` (+ la API `229a53b537`).
