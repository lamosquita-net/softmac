# FlyWeb 3.1.2: contenido (borrador, falta la 158)

SEGURIDAD-PORTES-23, 13-11-2026. Es la directiva «3.1.2 antes de la 3.2.0» (Titín, 13-11 noche; COORDINACIÓN-41): una
versión **solo de seguridad** con la V8 de la rama, el delta de la 158 (estable el 17-11) y el KEV. Fuera queda todo lo
que no sea seguridad, salvo un arreglo pequeño y ya diagnosticado que decida COORDINACIÓN. **Contenido abierto**: se
cierra el 17-11 con la nota de la 158. **Nada compilado.**

## Base (comprobada con `ls-remote` el 13-11)

Es la 3.1.1 publicada (198.63.44).

| Repositorio | Rama | Commit | Árbol |
|---|---|---|---|
| chromium (fork `lamosquita-net/chromium`) | `seg/3.1.1` | `9e0d83137fde575222a8ad3c41fe55468bd8d9f1` | `38c6e1d3e3` |
| brave-core | `local/3.1.1` | `3e2c12fad571ebc9341994792fa20e91c3fe1e2f` | — |

## Lo que ya está

| Qué | Estado | Dónde |
|---|---|---|
| **KEV** | `cve-watch.py --desde 2026-10-15`, catálogo **2026.11.13**: 2 de Chromium, los 2 ya triados, **0 nuevos**. Se repite el 17-11 | — |
| **brave-core 0001** | `flyweb_version` 3.1.1 → **3.1.2**, en un commit aparte (`docs/SEGURIDAD.md`). `git apply --check` limpio sobre 3e2c12fad57; árbol tras el commit: `78684355db` | [`brave-core/`](brave-core/) (sumas dentro) |
| **V8** | **se queda en 15.6.75.58**, la de la 3.1.1, ya probada (`3.1.1/mjsunit.md`). La .59 se retira: ver abajo | — |
| **Rama 8078** | sin tags nuevos: la última sigue siendo 156.0.8078.104, que ya está en la 3.1.1 (0035–0043). Tampoco hay ninguno nuevo en la 8103 (157.0.8103.81) | — |
| **Chrome Releases** | feed leído el 13-11 a las 21:50 UTC: nada nuevo desde la nota del 11-11; de la 158 solo el Early Stable 158.0.8127.36/.37, **sin CVE** | — |

### V8 15.6.75.59: retirada (no entra en la 3.1.2)

La 15.6.75.60 (13-11) **revierte** el único cambio de la .59: af144bc, «[M156] Enforce no-JS execution scopes in
InvokeApiFunction», con los bugs 584997097 y 576333024. Esto dice el revert a62636b:

> Reason for revert: depends on https://issues.chromium.org/issues/566156384

El fallo salió en el bot `fuchsia-x64-cast-receiver-rel` de la m156.

Así quedan las versiones:
- **.60 = .58 + número de versión**: `git diff 15.6.75.58 15.6.75.60` solo toca `include/v8-version.h`.
- **No subimos a la .60.** Solo cambiaría `V8_PATCH_LEVEL`, y con él el hash de la caché de código, sin arreglar nada.
- **El parche `3.1.1/v8-15.6.75.59/0001` no se usa.** Su d8 en verde no basta: upstream lo retiró porque le falta un
  cambio previo.
- **D8-LINUX:** como la V8 no cambia, no hay encargo de d8 para la 3.1.2. Si se cambia de V8 el 17-11, el encargo va a
  `buzon/D8-LINUX`.
- **El 17-11:** mirar si el arreglo de 576333024 vuelve a la rama 15.6 junto con 566156384 (una .61 o posterior), o
  si viene en la V8 de la 158. Si vuelve a la 15.6, se porta con su dependencia, se vuelve a pasar el d8 y se sube
  la V8.

## Pendiente para el 17-11 (cuando salga la nota de Chrome 158 estable)

1. **Nota de la 158.** Feed Atom: `https://chromereleases.googleblog.com/feeds/posts/default?redirect=false&max-results=40`.
   Sin `redirect=false` redirige a feedburner, que no resuelve.
   - Cruzar cada CVE con `FlyWeb/docs/seguridad-3.1.1.md` §1–§3 y con `3.1.1/CONTENIDO.md`.
   - Por cada CVE que afecte a la 156, buscar el `[M158]` en la rama 8127 y el commit original en `main`.
2. **Rama 8078 y V8 15.6.** `ls-remote` de los tags `156.0.8078.*` (¿hay .105 o más?) y `15.6.75.*` (¿vuelve
   576333024?). Lo nuevo entra con `cherry-pick -x` y el mismo `patch-id`, como 0035–0043.
3. **KEV** del día: `cve-watch.py --desde 2026-10-15`.
4. **Serie chromium.** Va en `chromium/`, numerada desde **0001** sobre `seg/3.1.1`, con el árbol tras cada paso.
   - El último parche es `chrome/VERSION`, si hay una .105 o más.
   - Sumas en `SHA256SUMS`.
5. **Cruce con `patches/` de brave-core** antes de cerrar: por cada `src/a/b.cc` de la serie, mirar si hay
   `patches/a-b.cc.patch` en `local/3.1.1` y hacer `git apply --check` sobre el árbol final. Es la trampa de
   `navigation_request.cc` de la 3.1.1.
6. **Huella:** si algún parche toca red (TLS, HTTP/2, cabeceras, Client Hints), la prueba de huella de la 3.1.1 se
   repite. Si no, basta la de la 3.1.1.
7. **Cerrar** este fichero: tabla «Orden de aplicación» y tabla «Versión y build». Después, aviso a COORDINACIÓN-41
   para la orden a LOCAL.

## Orden de aplicación (provisional)

| Paso | Qué | Árbol tras el paso |
|---|---|---|
| chromium 1 | `chromium/` 0001–00NN: delta de la 158, y lo nuevo de la 8078 y la 15.6 si lo hay | (17-11) |
| brave-core 1 | `brave-core/` 0001: `flyweb_version` 3.1.2 | `78684355db` |
| brave-core 2 | `package.json` con la etiqueta de `chrome/VERSION`, si cambia (como 59680cc en la 3.1.1) | (LOCAL) |

## Versión y build (provisional)

| Qué | Valor | Quién y cómo |
|---|---|---|
| `flyweb_version` | **3.1.2** | brave-core 0001, aplicado por LOCAL |
| `FLYWEB_BUILD_NUMBER` | **45** (la 3.1.1 fue la 44, publicada como 198.63.44) | LOCAL, en `build.sh` |
| CFBundleVersion | **198.63.45** | sale solo: `<flyweb_bundle_version_base>.<build>` |
| `chrome/VERSION` | 156.0.8078.104, salvo que haya una .105 o más (17-11) | — |
| V8 | 15.6.75.58, sin cambios | — |
| `flyweb_engine_full_version` (Client Hints) | 156.0.8078.82, sin cambios (se sigue declarando 156) | — |
| `kFlyWebCacheEpoch` | 31, sin cambios (sin parches de V8) | — |
