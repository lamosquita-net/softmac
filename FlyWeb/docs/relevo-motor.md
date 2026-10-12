# Relevo de MOTOR: de MOTOR-4 a MOTOR-5 (12-10-2026, ~23:10)

MOTOR-4 (`session_01TF1UZA4dTDReaRJUfTC5fU`, Opus 5.5, esfuerzo extra) deja el trabajo al empezar RubyLB, con el
contexto al 46 %. MOTOR-5: Opus 5.5, esfuerzo extra. Leer esta sección, la fila FM.16 de `docs/TAREAS.md` y
`motor.md` «Nivel 128». En esta sesión no hay nada a medio escribir ni sin subir.

**Ramas de brave-core:**

| Rama | Cabeza | Qué |
|---|---|---|
| `nube/v8-12.8-api` | e9c4ad85 | FM.17, fases 0–3. LOCAL hace el Static/ASan |
| `nube/v8-12.8-fase4` | 493c8998 | FM.17 fase 4: V8 12.8 + flags caducados, con visto bueno de SEGURIDAD-PORTES |
| `seg/v8-12.8` | f8cbd8c9 | FS.10, de SEGURIDAD-PORTES sobre 493c8998, época 10. **La 1.11.2 sale de aquí** |
| `nube/motor-128` | 84735505 | Nivel 128 sin `ruby-align` = **1.12** (decisión del HUMANO): 7 portes + declara 128/1.12 |
| `nube/motor-128-ruby` | = 84735505 | Subida, sin commits propios: aquí va RubyLB, un commit y un push por paso |

**Lo que queda, en orden (órdenes de COORDINACIÓN-4, 12-10):**
1. **RubyLB por etapas** en `nube/motor-128-ruby`: R1 `display: ruby` → R2 inlinificación → R3 núcleo → R4
   `ruby-align` → R5 arreglos. LOCAL compila cada etapa aparte; saldrán en 1.12.1, 1.12.2… **El 129 no empieza hasta
   terminar RubyLB.** Plan y medición en `motor.md` «Nivel 128».
2. **R0, decidido: no se portan los renombres de LayoutNG.** Serían 369 ficheros nuevos, sin poder borrar los viejos,
   y 209 más parcheados por los nombres (70 con parche nuestro). Se usa el traductor de diffs
   (`FlyWeb/tools/port/ngmap.py`, `ngtraducir.py`, `portarng.sh`; README).
3. **R1, ya probado** con `portarng.sh r1 fff250bc61 8e6792e47d f47ea0a5a5 d1aceb95f2 e63c1d7cf2 bf262bd8d1 bdb9aad17f
   8b01cfed9a d4967df6da f551901fad 10fc889f33 37da5ae3a9 e60ed2dd1a` (163df85f89 y su revert, fuera: va el *reland*
   d4967df6da). Rechaza 25 *hunks*. Los de `json5`/`mojom`, a mano (`addflag.py`, contadores en orden). Con `patch
   -F3` entran 8 más. Quedan 5 a mano:
   - `layout_ruby.cc`: `RemoveChild` y `DidRemoveChildFromColumn`.
   - `layout_ng_ruby_as_block.cc`: lo mismo.
   - `layout_ng_ruby_base.h`: `IsPlaceholder`.
   - `ng_block_layout_algorithm.cc`: la limpieza f47ea0a5a5 de `HandleRubyText`; si nada posterior la pide, se puede
     quitar de la cadena.
   - `longhands_custom.cc`: `IsDisplayInside` con `kRuby`.

   Faltan después los arreglos de R1 (207a403ed2, 189fa20e6f, 259c7e28f1, 988652b535, 3748c5249f) y la retirada de
   flags (f7690c6fbc, 58b8c97874, 7d0a83fd26).
4. **1.11.2**: cuando LOCAL dé el Static de 493c8998, montar `local/huella-127` + `flyweb_version` 1.11.2 **sobre
   `seg/v8-12.8` f8cbd8c9** (no sobre 493c8998). `flyweb_engine_full_version` del 127.
5. **Al cerrar la 1.11.2**: rebasar `nube/motor-128` (y `-ruby`) sobre `seg/v8-12.8` (solo difieren en `patches/v8`);
   en la 1.12, `flyweb_engine_full_version` del 128. **No tocar `patches/v8/` sin avisar a SEGURIDAD-PORTES.**
6. Si el Static de LOCAL de e9c4ad85 o de 493c8998 da fallos: los arreglos van primero en esas ramas y todo lo de
   encima se rebasa.

**Trampas nuevas:**
- `brave-core` en el contenedor es un clon `--depth 60`; para ramas viejas, `git fetch --depth`.
- `git show` en el clon `tree:0` de Chromium es lento con commits grandes, porque baja árbol a árbol: 198 commits
  tardaron unos 40 minutos. Lánzalo en segundo plano.
- `cr128` (copia parcial de la 128.0.6613.194: `third_party/blink`) sirve para ver el código final de upstream que
  protege una flag.
- La lista de commits de ruby está en `/tmp/claude-0/ruby-128.txt` de esta sesión. No se conserva: se rehace con
  `git log --grep=ruby -i` entre el 26-06-2023 y el 23-07-2024.

**Mediciones de MOTOR-4** (Opus 5.5, extra; `get_session`): 12-10, 18:36–23:05 UTC, unos 230 turnos, salida 143 k,
caché leída 54,9 M, escrita 413 k, entrada sin caché 412. Fase 4 de FM.17 (18:36–18:50): 90 turnos, salida 52 k, caché
16,3 M; retrabajo tras la revisión: 0. Nivel 128 (sin RubyLB) y medición de RubyLB: el resto.

---

# Relevo de MOTOR: de MOTOR-3 a MOTOR-4 (12-10-2026)

MOTOR-3 (`session_01UiNp8ASzm2Sn5mbDycomnk`, Opus 5.5, esfuerzo extra) deja FM.17 al cerrar la fase 3, con el contexto
cerca del 50 % (regla de ARQUITECTURA). MOTOR-4: Opus 5.5, esfuerzo extra (`xhigh`). Leer en este orden: esta sección,
`FlyWeb/docs/v8-12.8-blink.md` (§2, el plan y lo que se hizo, y §3, una fila por adaptación), la fila FM.17 de
`docs/TAREAS.md` y `FlyWeb/tools/port/README.md` y `FlyWeb/tools/bindings/README.md`. La nota de MOTOR-2, más
abajo, sigue valiendo para las trampas de los niveles 125–127.

**Hecho** (brave-core `nube/v8-12.8-api`, todo sobre la V8 12.7.224.20 y sin compilar):

| Fase | Qué | Commits |
|---|---|---|
| 0 | `nube/motor-127` = 639a7a71 + 94914682 de LOCAL-2 | 0d6136c7 |
| 1 | (c) `SetAccessor` | fa528ab2 |
| 2 | (a) interceptores `v8::Intercepted`: 2a generador, 2b gin, 2c Blink (con 565f8ac357bf y la retirada de los `[Custom]`), 2d PDFium | 4df5719a, 03868d17, 7cbca6f2, 40b012f8, ab71e0a3, ade843c5 |
| 3 | (b) `Object::Wrap`: 3a-1…12, 3d (V8 aaa23fc87, época 7), 3b-1…3, 3c | a115c0d6 … **e9c4ad85** (cabeza) |
| (e) | `consoleTime*`, para el cambio de V8 | rama `nube/v8-12.8-paso-v8` 326f17ce |

**En curso:** nada a medio escribir; no hay ningún fichero abierto. La fase 3 espera la revisión de SEGURIDAD-PORTES,
y la fase 4 espera al Static de LOCAL de e9c4ad85 (decisión de COORDINACIÓN-4, para no mezclar fallos).

**Lo que queda, en orden:**
1. **Revisión de SEGURIDAD-PORTES de la fase 3: hecha, con visto bueno (12-10, sin cambios; 9401594f42b8 se
   queda).** Lo que miró, por si vuelve a salir: el almacenamiento en línea solo en el mundo por
   defecto de cada *isolate* (3a-4/3a-5), `ClearIfEqualTo` en los caminos de liberación del contexto (3a-2) y los
   `DOMWrapperWorld` guardados en código de después de 2137f1da3a53 (ninguno). Sus pruebas con ASan para LOCAL están
   en el §2. Si algún día hay que quitar 9401594f42b8, es un `git revert` de 85aa26ed, que no tiene dependientes.
2. **Arreglos del Static/ASan de LOCAL**, en commits aparte, con una fila cada uno en el §3.
3. **Fase 4**, con el plan del §2 («Fase 4: plan de `patches/v8`»): `FlyWeb/v8-revision` de brave-core a d213b3bb,
   `v8re.sh`, quitar la 3d (aaa23fc87 ya está en la 12.8), época 9 y *cherry-pick* de (e). **Avisar a
   SEGURIDAD-PORTES antes de tocar `patches/v8`.** El plan ya tiene su visto bueno (12-10). Al terminar, avisarle
   para FS.10 (`seg/v8-12.8`, época ≥ 10).
4. Al terminar FM.17: nota final con las mediciones de todas las fases (decide el modelo del motor desde el 129).

**Trampas de las fases 1–3:**
- **El plan de MOTOR-2 se quedaba corto.** Los commits de upstream se apoyan en refactors que la 116 no tiene. Antes de
  dar por buena una cadena, hay que aplicarla paso a paso (`portar.sh` con `STEP=1` y luego `addfiles.sh`) y buscar
  en **toda** la 116 los llamadores de cada API que cambia (`args1.py`, `grep` en `/home/user/cr116`, en brave-core
  y en los parches). Lo más grave que apareció así: f092aac67790. Sin él, quitar los campos internos dejaba
  `ToExecutionContext()` siempre en `nullptr`.
- **`generar.sh` diferencia contra el último commit del área de trabajo.** Lo arreglado a mano tiene que tener
  commit, y después se comprueba que cada parche aplicado sobre la 116 da el fichero del área byte a byte (en el
  registro hay un bucle hecho).
- **brave-core no borra ficheros:** se quitan del `BUILD.gn`/`.gni` y se quedan en disco (`custom_wrappable.*`,
  `v8_html_plugin_element_custom.cc`).
- **El generador de la 116 es propio en partes** (`make_named_props_obj_*`, el objeto de propiedades con nombre de
  `Window`): upstream lo convirtió en la interfaz `WindowProperties`. Cada cambio de upstream ahí se traduce a mano.
- **Los `git log` por ruta en el clon sin árboles tardan muchísimo.** Mejor `git log --grep` o `--author` en un rango,
  y `git show <tag>:<fichero> | grep -c` para fechar un cambio.
- **No hacer `pkill -f` con un patrón que esté en el propio comando**: mata el comando.
- La época de caché 6 es de `seg/v8-12.7`. No reutilizar números de época entre ramas con parches de V8 distintos.

**Mediciones** (de la transcripción de la sesión; Opus 5.5, esfuerzo extra; tokens de entrada sin caché / salida /
caché leída / caché escrita):

| Fase | Tiempo (UTC) | Turnos | Entrada | Salida | Caché leída | Caché escrita | Retrabajo tras revisión |
|---|---|---|---|---|---|---|---|
| Arranque + plan + 0 + 1 | 14:42–15:26 | 177 | 362 | 150 239 | 53,1 M | 434 k | 0 |
| 2 | 15:26–16:12 | 159 | 318 | 138 032 | 99,9 M | 318 k | 0 |
| 3 (incluye una compactación) | 16:12–16:56 | 232 | 464 | 166 780 | 65,2 M | 397 k | pendiente de la revisión |
| 4 (MOTOR-4, `session_01TF1UZA4dTDReaRJUfTC5fU`; incluye arranque y relevo) | 18:36–18:50 | 90 | 180 | 51 540 | 16,3 M | 203 k | pendiente de la revisión |

El `usage` de `get_session` no se actualizó desde las 15:25 (16,86 USD en ese momento). `rate_limit_info`:
`seven_day`, `allowed_warning`, sin porcentaje; se restablece el martes 13 a las 09:00 de Madrid.

**Qué se espera de los demás:**
- **SEGURIDAD-PORTES:** revisión de los 17 commits de la fase 3 (el mensaje con los puntos delicados está en su
  sesión); después, `seg/v8-12.8`.
- **LOCAL:** tras publicar la 1.11, un Static y un ASan de e9c4ad85, con las pruebas del §3 (las de 3b-1 y 3a-11 son
  las importantes) y la de SEGURIDAD-PORTES con mundos aislados.

**Entorno:** las herramientas están en `FlyWeb/tools/port/` y `FlyWeb/tools/bindings/`; se copian a
`/tmp/claude-0/port/` (README). Clones, como en la nota de MOTOR-2: `/home/user/chromium/chromium` (sin árboles,
con los tags 116–149 ya traídos), `/home/user/cr116` (copia parcial de la 116 para `grep`) y `/home/user/v8`.

---

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
