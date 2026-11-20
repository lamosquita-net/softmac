# 3.2.0: V8 de brave-core (LIBC_MATH y época de la caché)

MOTOR-47, 20-11, por encargo de COORDINACIÓN-53. El orden lo ha confirmado SEGURIDAD-PORTES-33. **Sin compilar.**

| Parche | Qué hace |
|---|---|
| `0001` | Pasa `3.2-renderer-webgl/0003` (LIBC_MATH en `src/base/ieee754.cc`, de V8 upstream) a `patches/v8/src-base-ieee754.cc.patch` de brave-core. Base: V8 15.6.75.66 (blob `bedffe0147`); ningún otro `patches/v8` toca ese fichero |
| `0002` | `kFlyWebCacheEpoch` de 37 a **38** (`patches/v8/src-utils-version.cc.patch`), con su nota en `patches/v8/FLYWEB-SECURITY.md` |

**Por qué la época.** La 3.2.0 cambia V8 dos veces respecto a la 3.1.4: d68cecd900 (`seguridad/pendiente/brave-core/0001`)
y LIBC_MATH. Los dos cambian código generado. Se sube una sola vez para toda la versión, así la caché de código de la
3.1.4 no se reutiliza.

**Orden:** al final de la cadena de brave-core de la 3.2.0, después de `seguridad/pendiente/brave-core/0001`:

| Tras | Árbol |
|---|---|
| … + `pendiente/brave-core/0001` | `d2dc281eb0` |
| `0001` | `1e74f54a66` |
| `0002` | **`612c201d14`** (árbol final de brave-core de la 3.2.0) |

Para comprobar (D8-LINUX o LOCAL): que `gclient`/`apply_patches` aplica `src-base-ieee754.cc.patch` sobre V8; mjsunit
`math` y `es6/math-*`; y que una página con JS cacheado por la 3.1.4 se carga bien en la 3.2.0 (sin cierres).
