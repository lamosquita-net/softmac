# FlyWeb 2.4.0 — nivel 135 del motor

MOTOR-31, 29-10-2026. Inventario: `motor-niveles.md` § «Nivel 135». Declaración prevista: Chrome **135.0.7049.117** (la
última Stable de Mac del 135). V8 **13.5.212.10**.

**Rama:** brave-core `nube/motor-135`, sobre la 2.3.0 (`nube/motor-134` 479bcaf1e2). Sin compilar. Lo hecho y lo que
falta, en la tabla de `motor-niveles.md` § «Nivel 135».

## Cruce con wpt.fyi antes de compilar (prueba de método de Titín)

Pendiente de completar (ver abajo).

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
