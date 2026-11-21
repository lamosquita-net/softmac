# 3.2.0: V8 de brave-core (LIBC_MATH y época de la caché)

MOTOR-47, 20-11, por encargo de COORDINACIÓN-53. El orden lo ha confirmado SEGURIDAD-PORTES-33. **Sin compilar.**

| Parche | Qué hace |
|---|---|
| `0001` | Pasa `3.2-renderer-webgl/0003` (LIBC_MATH en `src/base/ieee754.cc`, de V8 upstream) a `patches/v8/src-base-ieee754.cc.patch` de brave-core. Base: V8 15.6.75.66 (blob `bedffe0147`); ningún otro `patches/v8` toca ese fichero |
| `0002` | `kFlyWebCacheEpoch` de 37 a **38** (`patches/v8/src-utils-version.cc.patch`), con su nota en `patches/v8/FLYWEB-SECURITY.md` |

**Por qué la época.** La 3.2.0 cambia V8 respecto a la 3.1.4 con `seguridad/pendiente/brave-core/0001`–`0004`
(d68cecd900; los merges M159 a0f2c9f8c3 y 51512210b3, que cambian el *bytecode* y el código optimizado; y ceb90d38eb, que
cambia el formato de la caché con el hash SHA-256) y con LIBC_MATH. Se sube **una sola vez**, de 37 a 38, para toda la
versión. La 37 es la de la 3.1.4 publicada, y la 38 no se ha usado en ninguna versión ni rama: con una subida basta,
porque cualquier caché de la 3.1.4 se rechaza por la época y, además, 0003 cambia el formato.

**Orden** (20-11, con `pendiente/brave-core/0002`–`0004` de #1147): al final de la cadena de brave-core de la 3.2.0,
**después** de `pendiente/brave-core/0001`–`0004` y **antes** de `3.2-ajustes-sistema/0005` (#1150). El 0002 se ha
regenerado sobre `0004`, porque los dos añaden una sección al principio de `FLYWEB-SECURITY.md`. Los parches por
fichero no chocan: 0002–0004 de seguridad no tocan ni `ieee754.cc` ni `version.cc`.

| Tras | Árbol |
|---|---|
| … + `pendiente/brave-core/0001` | `d2dc281eb0` |
| `pendiente/brave-core/0002`–`0004` | `d0fa19b902`, `1de4ed581a`, `7c7234a67b` |
| `3.2-v8/0001` | `1a33e5f32e` |
| `3.2-v8/0002` | `3ca3f393a8` |
| `3.2-ajustes-sistema/0005` | **`d1fe696d26`** (árbol final de brave-core de la 3.2.0) |

Si Titín deja fuera `pendiente/brave-core/0002`–`0004`, sirve el 0002 anterior de esta carpeta (commit `b76f3410d9` de
la rama): `612c201d14` y, con el 0005 de ajustes-sistema, `e09a2118a4`.

Para comprobar (D8-LINUX o LOCAL): que `gclient`/`apply_patches` aplica `src-base-ieee754.cc.patch` sobre V8; mjsunit
`math` y `es6/math-*`; y que una página con JS cacheado por la 3.1.4 se carga bien en la 3.2.0 (sin cierres).
