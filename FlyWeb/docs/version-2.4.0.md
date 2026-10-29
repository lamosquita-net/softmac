# FlyWeb 2.4.0 — nivel 135 del motor

MOTOR-31, 29-10-2026. Inventario: `motor-niveles.md` § «Nivel 135». Declaración prevista: Chrome **135.0.7049.117** (la
última Stable de Mac del 135). V8 **13.5.212.10**.

**Rama:** brave-core `nube/motor-135`, sobre la 2.3.0 (`nube/motor-134` 479bcaf1e2). Sin compilar. Lo hecho y lo que
falta, en la tabla de `motor-niveles.md` § «Nivel 135».

## Cruce con wpt.fyi antes de compilar (prueba de método de Titín)

Encargo de Titín: cruzar el inventario con wpt.fyi para sacar las pruebas que Chrome 135 pasa y Chrome 134 no, y portar
las faltas antes de compilar. Tabla completa: [`wpt-135-cruce.md`](wpt-135-cruce.md).

**Coste medido (get_session de MOTOR-31 y uso del subagente):**
- Reloj: **11 min** (15:53:53–16:05 UTC). Un subagente Sonnet: 132 000 tokens, 22 herramientas y 5 consultas HTTP
  (wpt.fyi y los dos resúmenes de los runs).
- La sesión pasó de 14,35 $ a 24,32 $ en esa ventana. **Esa diferencia no es el coste del cruce:** incluye el trabajo de
  la sesión principal en paralelo (inventario en `motor-niveles.md`, este documento) y relecturas de un contexto del 27 al
  37 %.
- Coste propio del cruce, estimado con la tarifa de Sonnet: **~1–2 $**.
- Falta el coste de portar las faltas: lo mide MOTOR-32.

**Resultado (V los recuentos; S la asignación por directorio):**
- Runs de Linux 134.0.6998.165 y 135.0.7049.114. No son los builds de Mac y sus revisiones de WPT son distintas, así que
  hay falsos positivos.
- **458 pruebas mejoran** de 134 a 135: css 269, html 95, dom 52, navigation-api 38, editing 3 y wai-aria 1. Hay 40
  regresiones, sin analizar.
- **330 (a)** las cubre una fila del inventario que se porta: carousel ~100, select ~55, Observable 46,
  navigate-event 30, `command` ~25, `shape()` ~25, `interactivity` 12…
- **5 (b)** son de filas aplazadas o fuera: `corner-shape`, `animation-trigger`, margin boxes, `interesttarget`.
- **27 (d)** son pruebas cambiadas o de entorno.
- **68 (c), faltas que el inventario no veía**, en 8 causas con commit; ninguna lleva flag salvo la 7. Total
  estimado 8–10 h de papel, ~3–4 h reales:
  1. Gradientes con un solo stop y `hue longer` (de30a22358e, ae4b6e17166, c61a6575eb5, 7523f80eaa6): ~40 reftests;
     toca `cc/paint_shader.cc`, fuera de Blink.
  2. `:visited` hereda en todos los estilos (b39d6582c8e): 3 pruebas. **Es de privacidad: regla 17 y regla 20, que lo
     revise SEGURIDAD-PORTES.**
  3. `text-emphasis-position: auto` (f64b0a258a3): 12 pruebas.
  4. `text-shadow` en custom highlights (7dafeb6822f): ~7.
  5. `color-mix` con componentes que faltan (d3d0ae5bf4d).
  6. `text-box-trim` con hijos que abren BFC y spanners (6078e755853, 80505a9e751). Son escapes del 133 que ya estaban
     en la lista.
  7. `SetIntervalWithoutClamp` (0399f3f3d6f, base::Feature).
  8. `preserveAspectRatio` en `feImage` (8692b015aaf).

  Además, 88e081e06af (recalcular anchor al cambiar de fallback) va con `CSSAnchorRememberedScrollOffset`.
- **28 (c?)** sin causa localizada: view transitions 5, writing-modes `available-size-020/021`, ruby, quotes,
  `precommit-handler` 3, `location_hash_set_empty_string`, `random-invalid` y otras. Requieren mirar los `-expected.txt`
  commit a commit (~12 s cada uno).
- **Conclusión para Titín:** por ~1–2 $ y 11 min, el cruce encuentra **8 causas (68 pruebas) que el inventario por flags
  no veía**, porque son arreglos sin flag. La asignación es por nombre de directorio (S). Antes de portar hay que mirar en
  la 128 de FlyWeb si alguna ya está.

## Porte de las faltas del cruce (MOTOR-32, 29-10, ~16:13–16:26 UTC)

Antes, buscadas en la 128 + parches: ninguna estaba. Resultado por causa:

| Causa | Estado | Commit de brave-core |
|---|---|---|
| 1. Gradientes de un solo stop y `hue longer` | **portada** (4 commits, limpios) | f9680180 |
| 2. `:visited` hereda en todos los estilos | **portada en commit aparte** (revertible): solo llena los campos internos de «visited» con los heredados; `getComputedStyle` no cambia. **Pendiente de la revisión de SEGURIDAD-PORTES (regla 17)** | 6eaf6c4d |
| 3. `text-emphasis-position: auto` | **no se porta**: en el 135 sigue `experimental`; Chrome 135 Stable no lo da | — |
| 4. `text-shadow` en custom highlights | portada | 0bba4d30 |
| 5. `color-mix` con componentes que faltan | portada | 0bba4d30 |
| 6. `text-box-trim` con hijos BFC (6078e755853) | portada, adaptada (FlyWeb no tiene la pasada de `line-clamp: auto`) | 0bba4d30 |
| 6. `text-box-trim` con spanners (80505a9e751) | **aplazada**: exige el refactor del 134 que lleva el estado a `BoxFragmentBuilder` | — |
| 7. `SetIntervalWithoutClamp` | portada a mano (la 128 no tiene el flag; encendido como en el 135) | 0bba4d30 |
| 8. `preserveAspectRatio` en `feImage` | **aplazada**: depende de un `FEImage::GetImage()` del 129–134 | — |

**Coste:** ~13 min de reloj en la sesión principal (más ~10 min de montar el entorno sin la historia completa de
Chromium). `get_session` no da `cost_usd` en esta sesión: la cifra en dólares la saca COORDINACIÓN. Cubre ~55 de las 68
pruebas (todas menos `text-emphasis` 12, spanners y `feImage`).

**Lección para el método:** el run de wpt.fyi de Chrome 135 cuenta como mejora lo que va detrás de un flag
`experimental` (causa 3). El cruce debe comprobar el `status` del flag en el json5 del 135 antes de dar una falta por
buena.

## Dónde puede fallar la compilación

- V8 13.5: `turboshaft/pipelines.{h,cc}` y `compiler/pipeline.cc` (stack clash rehecho: `AllocateRegisters` devuelve
  `bool`), `maglev-graph-builder.cc` (constness de `DefineNamedOwnProperty` con el visitante auxiliar, guarda de
  `MaxInliningId` en `CanInlineCall`), `js-native-context-specialization.cc` (d73530cfd9 con `length_string()`),
  `base::Mutex` sobre `absl::Mutex` (abseil de la 128).
- Emoji: `font_fallback_priority.h` (enum con 2 valores nuevos y 3 bits en `InlineItemSegment`), `font_cache_mac.mm`
  (cascada a Apple Symbols), `symbols_iterator.cc` contra el `emoji_presentation_scanner.c` nuevo (parche de
  `third_party/emoji-segmenter/src`, que `util.js` aplica ahora).
- `font_face.cc` (`MediaValuesDynamic`, `ComputeValueInCanonicalUnit`), `style_builder_converter.{h,cc}` y llamantes de
  `ConvertFontWeight` (firma con `CSSLengthResolver`).
- **Arreglado por LOCAL-14 (7df1ac0a94):** `perfetto::NamedTrack` de V8 13.5 (cppgc `process-heap.h`) no existe en el
  Perfetto de la 128 (parche con `perfetto::Track::Global` e id fijo); `licenses.py` y `brave/patches/net/third_party`.
  Para los niveles siguientes: cada V8 nueva puede traer más usos de `NamedTrack`; buscarlos al rebasar `patches/v8`.
- MOTOR-32 (sin compilar): `platform/timer.{h,cc}` (`RepeatInterval()` pasa a `std::optional`; llamantes de la 128:
  `frame_caret.cc` compara con `==`), `html_button_element.cc` (trasplante del 135 de `command()`/`GetCommandEventType`
  y del bloque `DOMActivate`), `html_dialog_element.cc` (`request-close`), `keywords.json5` (`request-close`),
  `invoker_element.idl` (fuera de `idl_in_core.gni`, sin borrar), `style_environment_variables.{h,cc}`,
  `block_layout_algorithm.cc` (`UpdateTextBoxTrim`), `color.{h,cc}`, `navigate_event.cc` (`IsBackForwardOrRestore` de
  `frame_loader.h`).
- Parches de repos nuevos en `util.js`: `third_party/emoji-segmenter/src` y `net/third_party/quiche/src`.

## Pruebas

- Humo: `getContext('webgl')` y `getContext('webgl2')` (con `ANGLE_multi_draw`), claude.ai, GitHub, YouTube, Wikipedia.
- WPT de los 16 escapes del 134 (`wpt-230.md`) y `highlight-paired-cascade-004` con la receta de
  `wpt-230-investigacion.md`.
- `d8` 13.5 con `FlyWeb/scripts/v8-d8.sh` (mjsunit y `--maglev`), en la 7,1 y la 6,1.
- Huella: JA4 (ALPS 17613) y el Initial de QUIC (`version_information` 0x11) frente a Chrome 135.
- Fijadas: 8 fijadas compartidas en 2 ventanas en la 7,1 (Sequoia), actualizar de la 2.3.0 a la 2.4.0 y comprobar que
  siguen (Titín perdió 6 de 8 al pasar de la 2.1.1 a la 2.3.0 solo en la 7,1).
- Emoji: `font-variant-emoji: text` y VS15 (U+FE0E) se ven en blanco y negro (Apple Symbols); cambio visible pequeño,
  igual que Chrome 131+.

## Para la web

FlyWeb 2.4.0 pone el motor al nivel de Chrome 135. (Se completa al cerrar el nivel.) Por ahora: los emoji respetan
`font-variant-emoji` y los selectores de variación (texto o color), `font-weight` admite `calc()`, pegar texto en una
lista crea elementos nuevos, y el motor JavaScript pasa a V8 13.5. Para la red, FlyWeb se presenta igual que Chrome 135
(ALPS y QUIC).
