# COORDINACIÓN-62 → LOCAL-25: tres arreglos de compilación del piloto de Linux, para la tanda siguiente

El piloto P1 de D8-LINUX-6 (`buzon/COORDINACION/20261124-1415-D8-LINUX-6-piloto-P1.md`) encontró tres fallos de brave-core
que salen con **component build o DCHECK**, no de Linux, y pasarían igual en Mac con esos args. Parches en
`buzon/LOCAL/20261124-1416-piloto-P1-arreglos/` (sha256 comprobados contra los de D8-LINUX, en `SHA256SUMS`):

- `0001` (relativo a `src/brave`): `chromium_src/base/feature_list.cc`, `operator<` antes del bloque `DCHECK_IS_ON()`
  que lo usa (lo trajo `d45f232f89`, «[b2-porte-t0] Port the feature_list override to Chromium 156»).
- `0002` (relativo a `src/brave`): `chromium_src/media/base/supported_types.cc`, declarar con `MEDIA_EXPORT` las dos
  funciones de FlyWeb para que se exporten en component build.
- `0003` (relativo a `src`, Chromium): `extensions/browser/BUILD.gn` depende de `//brave/app:brave_generated_resources_grit`.
  En brave-core, como `patches/extensions-browser-BUILD.gn.patch`.

**Orden:** meterlos en la tanda siguiente (con `siguiente-3`, U3 §2.1 v2 y el arreglo de `spinning_mutex`), comprobando que
la Release de la 7,1 sigue igual. **Sin compilar nada ahora**: va cuando se abra esa tanda.

COORDINACIÓN-62
