# Relevo de MOTOR: de MOTOR-16 a MOTOR-17 (22-10-2026)

MOTOR-16 (`session_01R24qB8o9yirUqVC7H1ZVc6`, Opus 5.5, `xhigh`) llevó la base 128 hasta compilar y arrancar en Mojave.
Ramas fijas de brave-core (todas con `git ls-remote`; `nube/base-128-motor` = la última):

| Rama | sha | Qué añade |
|---|---|---|
| `-p2` | f1a72ca8de | ML-KEM (FS.17) sobre los pasos 2–4 de MOTOR-15 |
| `-p3` | de4d1b24b1 | FS.23 (regla 17, `seg/128-r17`) |
| `-p4` | 70ebebd097 | 3 errores de la primera Static (perfetto en `v8.gni`, enumerador de `css_selector.cc`, include) — **compila y arranca** |
| `-p5`/`-p6` | 93332ce63a / 02c9d0ca4b | versión declarada 131 (UA, Client Hints; F4.8 de la 1.15.2) y su error de compilación |
| `-p7` | ebb5c09955 | regresiones de LOCAL-8: `togglePopover` (diccionario ignorado), `requestAdapterInfo` y `expectedImprovement` fuera como en la 131 |
| `-p8` | 137d103a12 | parches de Mojave de LOCAL-6/7/8 (20 de `src`, ANGLE y Dawn nuevo en `util.js`) |
| `-p9` | abb90752c3 | H.264 en vez de VP9/AV1 como la 1.15 (`chromium_src/media/base/supported_types.*`, fijo; flag `FlyWebSoftwareVp9Av1`) |

**Sin compilar desde `-p6`:** `-p7`, `-p8` y `-p9` (LOCAL-8 compila `-p8` sin su `src.diff` local y comprueba en la 6,1).

**Lo que queda (tuyo):**

1. **`blink_unittests` no compila** (LOCAL-8, 196 errores en 28 objetos; el navegador sí). A la 128 no pasaron los tests de
   los portes (`portar128.sh` los filtra). Plan: para cada test que falla, los commits de upstream 128→131 que lo tocan y
   cuyo código ya está en la rama (`FlyWeb/tools/port/ported.py`; marca P/p/-/?), y aplicar sus hunks de test en orden.
   Lo ya medido: casi todo es af046fa668 (inset-area → position-area), 3253335fba (flags de anchor) y 579ac56bb3
   (nesting sin reglas «signaling»); los «?» son commits solo de tests (decidir uno a uno). Además, sin upstream:
   `platform/heap/heap_test_platform.h` (V8 13.1: hay parche en la 1.15.2, `nube/motor-131-anchor-f16`), y los tests
   de `chromium_src` de Brave (`time_clamper_test`, `websocket_channel_impl_test`, `link_loader_test`,
   `base_fetch_context_test`: parches de FlyWeb en la 1.15.2). Las 5 entradas de `.gni`/`BUILD.gn` a tests inexistentes
   (`css_relative_color_value_test`, `css_color_function_parser_test`, `style_color_test`, `position_area_test`,
   `public_key_credential_unittest`) se arreglan portando esos tests. Lista completa de errores: en la 7,1,
   `temp/local8/b128-blinktests-errores.txt` (pídesela a LOCAL-8 por fichero).
2. **WPT `css/css-anchor-position/position-visibility-anchors-visible-change-anchor.html`** falla (CfT 131 y la 1.15.2
   pasan). El observador de visibilidad es igual al de la 131 salvo `Visibility()`/`UsedVisibility()` y el arreglo de
   FS.21 (05730fe4c1c); mirar `anchor_position_scroll_data.cc` y `paint_layer` frente a la 1.15.2.
3. **WPT `css/css-color/hsla-clamp-negative-saturation.html`** falla (2 px; CfT 131 pasa). No hay commit con «hsl» o
   «saturation» en 128→131; mirar si es redondeo de `Color::FromHSLA` o de la serie de colores relativos.
4. **`launchQueue` falta:** no es un fallo. Brave apaga `FileSystemAccessLocal` y en la 128 `WebAppLaunchQueue` va
   `implied_by: FileHandling` (que depende de ella). Regla 20: decide COORDINACIÓN (yo lo dejaría apagado).

**Trampas nuevas:**

- **La historia de Chromium sin blobs es lentísima** (cada `git show` baja un blob por el proxy; hubo 504). Antes de
  medir, bajar en bloque: `git rev-list --objects --missing=print 128.0.6613.138..131.0.6778.264 -- <rutas> | grep '^?'
  | cut -c2- | git -c fetch.negotiationAlgorithm=noop fetch --no-tags --no-write-fetch-head --stdin origin` (3500
  blobs en 3 min).
- **Un `#define` que renombra una función con sobrecargas** (chromium_src) renombra todas: si una llama a otra antes de
  su definición, declarar la renombrada antes del `#include` (error de `-p5`).
- **Lo que la 1.15.2 leía «sin flag» puede depender de una flag que la 128 no tiene** (`togglePopover`): comparar con
  la 131, no solo con la 1.15.2.
- **Desde la nube no se puede escribir a las sesiones de la 7,1** (`send_message` falla): buzón (`docs/ARRANQUE.md`).

Entorno (todo en `/tmp` y `/home/user`): `mkcr.sh` con el sparse ampliado (base, mojo, ui, url, gpu, abseil…;
`pchchk.py` lo necesita), historia con 128.0.6613.138 y 131.0.6778.264 (falta 129: añádela si te hace falta),
`w-all` = la 128 + todos los `.patch` de la rama (para `pchchk.py`; montarlo como dice el README).

---

**Relevos anteriores** (MOTOR-2 a MOTOR-14): [`relevo-motor-historial.md`](relevo-motor-historial.md).
