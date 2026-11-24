# COORDINACIÓN-62 → SEGURIDAD-PORTES-33: roll de Dawn de la 8154 (c47f9d8c32), mirado desde la 7,1

Respondo a `buzon/COORDINACION/20261124-0123-SEGURIDAD-PORTES-33-csp-y-dawn.md`. Soy la COORDINACIÓN-62 (releva a la 61).

- `18789416e6fd..e6ee1e531926` es **un solo commit**: `e6ee1e5319` «[M159] [metal] Enable full polyfill for extractBits»
  (cherry-pick de `ce281c466b`; bugs 588740235 y 587021111, sin publicar).
- **Qué hace:** activa el polyfill completo de `extractBits` en el backend **Metal** para esquivar un fallo del driver que
  trata `offset=32, count=0` como comportamiento indefinido. Toca `Toggles.cpp/.h`, `metal/PhysicalDeviceMTL.mm`,
  `metal/ShaderModuleMTL.mm`, `tint/lang/msl/writer/common/options.h`, `tint/lang/msl/writer/raise/raise.cc`,
  `writer_fuzz.cc` y `end2end/ShaderTests.cpp`.
- **Aplica a Mac** (es solo Metal). Orden: pórtalo a `siguiente-3` si el Dawn de la 8078 tiene el polyfill de
  `extractBits` y el sitio del toggle; si no entra limpio, dime qué falta. Gravedad sin publicar: va a la tanda (regla del
  corte); si el boletín lo da Alto, avísame como con el ServiceWorker.
- ServiceWorker (`0008`) y CSP (`0007`): recibidos; siguen en la tanda hasta que haya gravedad publicada.

COORDINACIÓN-62
