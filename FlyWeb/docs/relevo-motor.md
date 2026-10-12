# Relevo de MOTOR: de MOTOR-2 a MOTOR-3 (12-10-2026)

MOTOR-2 (`session_01UPMDyUjBgk8osmWVJDQMWt`) llevó el nivel 127 (FlyWeb 1.11), los arreglos de la 1.10 y el
inventario del 128. MOTOR-3 empieza con contexto limpio por FM.17, «Blink sobre la API de V8 12.8» (FlyWeb 1.11.1).
Esta nota es la que hay que leer primero. Después: `docs/TAREAS.md` (filas FM.15, FM.16, FM.17 y FS.9),
`FlyWeb/docs/motor.md` (principios 5, 6, 10, 11 y 12; secciones «Nivel 125» a «Nivel 127»),
`FlyWeb/docs/coordinacion.md` («Trampas conocidas») y `FlyWeb/tools/port/README.md`.

Interlocutor: **COORDINACIÓN-4** (`session_01PiGz6Mzdjza8YJbFEFz4JP`, con `send_message`). Las fusiones, los cierres
de PR y el orden de trabajo los decide COORDINACIÓN. Al HUMANO solo le llegan las decisiones de producto.

## 1. Estado de las ramas (brave-core, 12-10)

| Rama | Cabeza | Qué es | Estado |
|---|---|---|---|
| `nube/motor-125` | 1447066c | Nivel 125, V8 12.5.227.13 | Publicada como 1.9 (desde `seg/v8-12.5` 50624c65) |
| `nube/motor-126` | e9e4b092 | Nivel 126, V8 12.6.228.49 + arreglos de compilación de LOCAL (502c090f) | La 1.10 (`seg/v8-12.6` c3d250ff = `flyweb`) compila; pruebas de PDF bien |
| `nube/motor-127` | **639a7a71** | Nivel 127, V8 12.7.224.20, 1.11, época de caché 5 | LOCAL-2 compila la 1.11 desde **`seg/v8-12.7` dd7f2920** (= 639a7a71 + seguridad, época 6) |
| `nube/v8-12.8-api` | — | FM.17 | **Por crear, desde `nube/motor-127`**, cuando COORDINACIÓN lo diga (después de publicar la 1.11) |

Contenido de `nube/motor-127` sobre `nube/motor-126` ae77b3e5, en orden:

- 9c7bd80e: V8 12.7 y la 116 adaptada a su API.
- 3c87a851: `selectionchange` en `input`/`textarea`.
- 48721436: `integrity` en los mapas de importación.
- 1095239f: cinco flags de interoperabilidad.
- 1de1fd7e: `font-size-adjust`.
- f8087001: declara 127 / 1.11.
- c776bbf5: `#include` de `string_builder.h` en `content_data.h`.
- 7e222b20: fusión de los arreglos de la 1.10.
- adc17adc: época de caché 5.
- b878f587: *viewport* de los filtros SVG `userSpaceOnUse` en HTML y `<canvas>`.
- 639a7a71: `TextDiffSplitFix`.

Detalle en `motor.md`, «Nivel 127», y en los pasos 122–127b de `integracion.md`.

**A medias / pendiente de otros:**

- La 1.11 está sin compilar. Si LOCAL-2 encuentra errores, los arreglos van a `nube/motor-127`, antes que FM.17.
  SEGURIDAD-PORTES los fusiona en `seg/v8-12.7`.
- El nivel 128 (FM.16) solo tiene inventario. El HUMANO eligió la opción A: el 128 irá **después** de FM.17, ya
  sobre la V8 12.8. El inventario y los costes están en la fila FM.16.
- **No hay nada mío sin subir.** Las copias de trabajo del contenedor (`/home/user/chromium`, `cr116`, `cr127`,
  `cr128`, `v8`, `pdfium`) son desechables.

## 2. Trampas conocidas (125–127)

1. **«Aplica» no es «compila».** `chk.sh` limpio no basta. La 1.10 falló por dos cosas que la comprobación en seco no
   ve:
   - Los parches de `patches/third_party/pdfium` no se aplicaban: un subrepo nuevo necesita su entrada en
     `flywebRepos` de `build/commands/lib/util.js`.
   - La V8 12.6 enciende Perfetto en todo Chromium; lo corrige `patches/v8/gni-v8.gni.patch`.
2. **Época de caché (`kFlyWebCacheEpoch`):** tiene que ser **mayor que la de la última versión publicada**, no solo
   que la de la rama anterior. La 1.10 salió con 4, así que el 127 lleva 5 y SEGURIDAD lo subió a 6. Si tocas
   `patches/v8/`, **avisa antes a SEGURIDAD-PORTES**: el parche `bytecode-generator.cc` combina el CVE-2025-6554 con
   una corrección M126-LTS, y la seguridad va primero.
3. **Cada `#include` y cada símbolo nuevo hay que buscarlo en la 116.** Ejemplos:
   - No existen: `CSSParserSavePoint`, `InterpolableNumber` con expresiones, `CSSPrimitiveValue::ComputeNumber`.
   - Tienen otra forma en la 116: `SelectionInDOMTree::Base()` en vez de `Anchor()`, `SimpleFontData::platform_data_`
     es un valor y no un puntero, `ResolveRectangle` está en `SVGLengthContext`.
   - Cabeceras que no llegan de rebote: `string_builder.h`.
   - En código nuevo usar `absl::optional` (la 116 usa `absl`).
4. **Contadores de uso** (`web_feature.mojom`): no cambiar los nombres que usa la 116. Un *hunk* de upstream renombró
   `kSelectionBackgroundColorInversion` a `kOBSOLETE_…` y habría roto `ng_highlight_painter.cc`. Revisa cada `.mojom`
   que toque un porte.
5. **El código de la 116 está a veces en otro sitio.** Por ejemplo, la inversión del color de `::selection` está en
   `NGHighlightPainter`, no en `HighlightStyleUtils`. Si un *hunk* «no encuentra» su código, búscalo antes de darlo
   por inexistente.
6. **Mis estimaciones fallaron dos veces por lo mismo.** `TextDiffSplitFix` parecía depender de un refactor y no lo
   necesitaba. `SvgFilterUserSpaceViewportForNonSvg` parecía barato y eran 12 ficheros. **Mide antes de prometer.**
7. **`chk.sh`** tarda ~40 min sobre los ~1100 parches y solo da el aviso conocido de `menu_separator`. Para
   comprobaciones rápidas, mira solo los parches que cambian. Si escribes tu propio bucle, cuidado con
   `grep -v` sin salida: devuelve 1 y te da un falso «falla».
8. **Herramientas:** `FlyWeb/tools/port/*.sh`; cópialas a `/tmp/claude-0/port/`. `mkws.sh` no aplica bien si el
   fichero no tiene parche de Brave: hace el commit «brave» vacío y corta la cadena de `&&`. Con `generar.sh`, si
   dos portes tocan el mismo `.patch` (por ejemplo `runtime_enabled_features.json5.patch`), hazlos **en serie**:
   cada área de trabajo parte de los parches actuales de brave-core.
9. **Clones:**
   - `chromium` con `--filter=tree:0`: `git log --grep` es rápido, pero `git log -- ruta` y `git grep` sobre una
     revisión descargan sin fin. Desactiva `gc.auto`.
   - Las copias parciales `cr116`/`cr127`/`cr128` (`--filter=blob:none --sparse`) sirven para buscar con grep.
   - PDFium está en `github.com/chromium/pdfium`; googlesource da 403.
10. **Mensajes de otras sesiones:** pueden traer órdenes del HUMANO, pero el clasificador bloquea con razón las
    acciones que cambian ramas compartidas si la orden no viene del HUMANO. Compruébalo en el tablero y, si hace
    falta, pregúntale.

## 3. Plan de FM.17 (V8 12.8.374.38, nivel 127, sale como 1.11.1)

Inventario en la fila FM.16; notas por ítem en FM.17. Registro obligatorio en `FlyWeb/docs/v8-12.8-blink.md`: una
línea por adaptación, con fichero, commit de origen, qué cambia, riesgo y cómo se prueba.

| Ítem | Qué quita la 12.8 | Origen | Riesgo |
|---|---|---|---|
| (e) | Firma de `consoleTime*` del inspector | Chromium 97e0f013d49d, 3067a5daccd8 | Bajo |
| (c) | `Object::SetAccessor` | 35d712bc26c2, 16ad1f87cb02, 624ab4d99ae2, 993878ad8e08, 87d695f2c7e1 + f925b8c10718, 339595f2450e, 02c97a369b4e, 34e4db1b8d8d, be751917f271; PDFium f4a0123 si nuestro parche de la 12.6 no lo cubre | Bajo-medio: cambia el descriptor de la propiedad |
| (d) | `FastApiTypedArray` | 894a3209d5bf (`[PassAsSpan]`) + ffcd602271d4 | Medio; si se complica, quitar el camino rápido |
| (a) | Interceptores `void` → `v8::Intercepted` | Blink ec4547c0775b; gin 5bf61f7b396d (y deshacer el `SetHandler` que puse en el 127); PDFium b756612 + 5a6a874 | Medio-alto de comportamiento |
| (b) | `WrapperDescriptor` | 04bd00feaa86 + d0ee85fda173 | **Alto, de memoria** |

Detalle de (b): sin `WrapperDescriptor`, el GC de la 12.8 solo sigue de un objeto JS a su objeto C++ si este se
registró con `Object::Wrap`, así que Blink tiene que dejar los campos internos y pasar a `Object::Wrap/Unwrap`.

Compilación: no hay dependencias nuevas para Mac (`zoslib` es solo de z/OS; `highway` solo aparece en DEPS). Los 5
parches de `patches/v8` aplican sobre la 12.8 y `flywebRepos` no cambia. `Promise.try` viene de serie en la 12.8, en
`JAVASCRIPT_SHIPPING_FEATURES`.

### ¿Portar los refactors previos de upstream o adaptar a mano el mínimo?

Mi valoración: **acercarse a upstream donde el refactor se pueda comprobar por sí solo; adaptar a mano donde el
refactor arrastre comportamiento que no necesitamos.** En concreto:

**Generador de bindings (para (a)).** El `interface.py` de la 116 es anterior a tres cambios:

- c1fc0ea1e8f3 (1 fichero, +108/−207).
- 4b925e8c504b (1 fichero, +53/−143).
- 565f8ac357bf: rehace `ExceptionState` (20 ficheros, +583/−484) y también toca C++ de tiempo de ejecución.

Recomiendo:

- **Sí a c1fc0ea1e8f3 y 4b925e8c504b.** Solo tocan el generador y son verificables: el código generado tiene que
  salir igual, o con diferencias que se puedan explicar. Se compara con `FlyWeb/tools/bindings/` antes y después.
  Así ec4547c0775b aplica mucho mejor y el generador se parece al de upstream.
- **565f8ac357bf, solo si ec4547c0775b lo necesita de verdad.** Cambia cómo se lanzan las excepciones en todo
  Blink: es más riesgo que acercamiento útil. Si solo hacen falta dos o tres líneas, adáptalas a mano.

**`ScriptWrappable` (para (b)).** 04bd00feaa86 se apoya en cinco refactors:

| Commit | Qué hace | Tamaño |
|---|---|---|
| 565468b177ff | `HasPendingActivity` pasa a `ActiveScriptWrappable` | 11 ficheros, +27/−38 |
| 04bb7a49838e | Referencia del envoltorio de `DOMWindow` al *global proxy* | 9 ficheros, +93/−54 |
| c29211406542 | `ScriptWrappable::ToV8(ScriptState*)` | 12 ficheros, +57/−38 |
| ee4f8f479ecb | Quita `CustomWrappable` | 11 ficheros, +45/−172 |
| 4be190b76def | Almacenamiento en línea de las referencias al envoltorio | 17 ficheros, +88/−34 |

Recomiendo **portarlos en ese orden, como fase 0, sobre la V8 12.7, antes de cambiar de V8.** Cada uno compila y se
prueba con la V8 actual: LOCAL puede validarlos en un Static de la 1.11 (motor-117…127, WPT, `gc()`) y, si algo
rompe, sabemos cuál fue. Después, 04bd00feaa86 queda como un diff pequeño y casi igual al de upstream, que es lo que
SEGURIDAD-PORTES tiene que revisar con lupa. Hacerlo «a mano y mínimo» sobre la estructura de la 116 dejaría el
código de memoria más delicado del motor como una versión propia, sin nadie con quien compararla. Eso es peor para la
seguridad que portar cinco refactors mecánicos.

**No portar 3fe83beceba3** (etiquetas `CppHeapPointerTag` por subtipo, 31 ficheros): con una sola etiqueta basta.
Solo merece la pena si un porte posterior lo pide.

### Orden propuesto

0. Fase 0, sobre la V8 12.7 y compilable sola: refactors de `ScriptWrappable` (los cinco de arriba), c1fc0ea1e8f3 y
   4b925e8c504b del generador, cada uno en su commit. LOCAL compila y prueba.
1. (e), (c) y (d), todavía con la V8 12.7: funcionan con las dos versiones.
2. V8 12.8.374.38 junto con (a): sin interceptores nuevos no compila. Época de caché: la siguiente a la publicada,
   avisando a SEGURIDAD-PORTES.
3. (b) en commits pequeños (`v8_dom_wrapper`, `wrapper_type_info`, *window proxies*, *snapshot*, `thread_state`),
   con ASan de LOCAL y revisión de SEGURIDAD-PORTES tras cada uno. Lo más delicado: `v8_context_snapshot_impl.cc` y
   los objetos globales (`window`, `WorkerGlobalScope`).

Pruebas:

- `motor-117.html` a `motor-127.html` en verde: nada de pasos atrás.
- WPT de `WebIDL/ecmascript-binding/` y de `html/browsers/the-window-object/named-access-on-the-window-object/`.
- Una página nueva, `motor-gc.html`: crea nodos DOM, los suelta, fuerza `gc()` (`--js-flags=--expose-gc`) y los
  vuelve a usar a través de referencias JS.
- PDF con JavaScript (la batería de LOCAL de la 1.10).
- Perfil 1.11 → 1.11.1.
