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

## Respaldo GL de ANGLE en los Mac de 2012–2015: revisión de la regla 17 (candidato)

Parches de ARQUITECTURA: `FlyWeb/parches/3.1.2-gl-reserva/` 0001–0005 (#982, fusionado). `SHA256SUMS` cuadra. Estudio en
`FlyWeb/docs/gpu-mac-antiguos.md`. Revisado por SEGURIDAD-PORTES-23 el 14-11 sobre el código de `seg/3.1.1` (9e0d83137f) y
el ANGLE de su `DEPS` (`f10470c77e`, rama `chromium/8078`). **Veredicto: APTO con condiciones (G-C1 a G-C3).** Solo
entra si la preliminar de LOCAL sale bien; lo decide Titín.

### Selección: ¿se puede forzar GL donde Metal funciona?
- **Por defecto, no.** Con el 0001, `GetEGLInitDisplays` prueba METAL primero, y OPENGL y OPENGLES solo si la pantalla de
  Metal no se inicia. En la 6,1 y la 5,1 nada cambia (la prueba A de LOCAL lo confirma).
- **Una web, no:**
  - en la 156, `chrome://flags#use-angle` solo existe en Windows y Android, y brave-core no lo añade;
  - cuando el proceso de GPU se cae y retrocede de modo (`HARDWARE_GL`, SwiftShader…), no cambia el backend de ANGLE;
  - la lista de fallos de controladores no tiene ninguna entrada con `disable_metal`.
- **macOS 11 o posterior: nada cambia** (`MacOSVersion() < 11`).
- **A mano, sí:** con `--use-angle=gl` en la línea de órdenes, en cualquier Mac con 10.14 o 10.15, Mac Pro incluidos.
  Lo acepto: es del usuario local, como `--no-sandbox`, y hace falta para la prueba B. Si se quisiera cerrar, se haría
  en una versión posterior.

### Ficheros nuestros (0002–0005)
- **Devuelven código que upstream tuvo hasta la 156**: `GetTextureTargetForIOSurfaces`, el campo del mojom, el destino
  de textura en `ClientSharedImage` y el formato de viz. Solo añaden; no deshacen ningún arreglo de la 156 en esos
  ficheros.
- **Con Metal o SwiftShader, `GetTextureTargetForIOSurfaces()` devuelve `GL_TEXTURE_2D`**, el mismo destino que hoy:
  en los Mac con Metal, el 0005 da el mismo formato que antes.
- **Mojom (0003):** el campo va del proceso de GPU al cliente. No abre ninguna frontera nueva: un renderer ya puede usar
  cualquier destino en sus órdenes, y quien valida es el frontal de ANGLE.

### Recuento real de CVE del OpenGL de ANGLE
- **Los 34 de la 151–156 (`gl-150-156-seg.md`): ya están.** 37 de los 39 commits de ANGLE de esa lista son ancestros
  de `f10470c77e`. Los otros dos son `8f1c9f81de`, la revert de `ed78400986` (que sí está), y `0855dd00f9`, de abajo.
  La parte de Chromium que tocaban (decodificador *validating*) B1c no la devuelve. La deuda de esa lista es **cero**.
- **Desde la 156 hasta la base de la 158**, nuestro ANGLE no tiene estos commits de `src/libANGLE/renderer/gl/`, que se
  vuelven **aplicables** si GL entra (`git log chromium/8078..chromium/8127 -- src/libANGLE/renderer/gl`):

  | Commit | Qué | Bug |
  |---|---|---|
  | `a965a227` | [M158] GL: Recreate 3D texture on depth increase from zero-extent level | 584998888, 577140687 |
  | `0855dd00` | GL: forcefullyFlush in useTempForNonZeroBaseLevelGenmipmap (la otra mitad de CVE-2026-103628) | 566683383 |
  | `b40b5946` | GL: Avoid FBO driver hash collisions | 551065275 |
  | `fb01175` (+ `66b09c8`) | Avoid user memory when querying sync status in the backends | 573982271 |

  Además, tres `[M158] GL` que se revirtieron en la rama el 13-11 (`69b419c`, `7a33c47`, `1f25c8e`): hay que vigilar
  si vuelven, como la V8 .59.
- **Capa CGL** (`renderer/gl/cgl/`): desde la 156 solo hay refactorizaciones del cerrojo de pantalla (`deeaa4b`,
  `e5913a5`, `77be48b`), ninguna de seguridad. Que esté a medio desmontar (sin `prepareForCall`, `testDeviceLost` ni
  aviso de cambio de GPU) es un riesgo de **estabilidad** (pérdida de contexto, cambio de GPU). No he encontrado
  ningún fallo de memoria conocido. Se mide en la preliminar.

### Condiciones
- **G-C1.** Si GL entra en la 3.1.2, entran también los arreglos de la tabla de arriba, como parches a ANGLE, y lo que
  diga la nota de la 158 del 17-11 sobre ANGLE GL. Falta decidir **por dónde** se parchea ANGLE: hoy `DEPS` apunta al
  ANGLE de upstream y la serie de seguridad no lleva ningún parche de ANGLE. COORDINACIÓN decide con LOCAL.
- **G-C2.** Pruebas antes de cerrar el contenido:
  - la A de LOCAL (Mac Pro con `angle=metal`, sin cambios);
  - en el MacBookPro9,1, el **cambio automático de GPU** (HD 4000 ↔ GT 650M), dormir y conectar un monitor, sin caídas
    ni pantalla negra. Si falla, ARQUITECTURA decide entre fijar la GPU dedicada en GL o devolver `prepareForCall`.
- **G-C3.** Desde la 3.1.2, las tandas de seguridad (y SEGURIDAD-VIGÍA) tratan como **aplicables en Mac**
  `renderer/gl/` y `renderer/gl/cgl/` de ANGLE. Hasta ahora se descartaban: eran código muerto.
- **Opcional:** que los *traits* del 0003 acepten solo `0`, `GL_TEXTURE_2D` y `GL_TEXTURE_RECTANGLE_ARB`.

## Orden de aplicación (provisional)

| Paso | Qué | Árbol tras el paso |
|---|---|---|
| chromium 1 | `chromium/` 0001–00NN: delta de la 158, y lo nuevo de la 8078 y la 15.6 si lo hay | (17-11) |
| chromium 2 | Candidato: respaldo GL de ANGLE (ARQUITECTURA), si el informe sale bien y pasa la revisión | (pendiente) |
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
