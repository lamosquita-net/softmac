# FlyWeb 2.6.0 — nivel 137 del motor

MOTOR-37, 30-10-2026. Inventario y estado: `motor-niveles.md` § «Nivel 137»; cruce con wpt.fyi: `wpt-137-cruce.md`.
Declaración prevista: Chrome **137.0.7151.122** (la última Stable de Mac del 137). V8 **13.7.152.17** (075234cf3d).

**Rama:** brave-core `nube/motor-137` sobre `local/250-arreglos` 3e8c8e219a (2.5.0 + FS.37): b832524c … **dea5f3eb**
(MOTOR-37). **A medias y sin compilar**; falta lo de «Pendiente del 137» en `motor-niveles.md`. No es una entrega.

**Decisiones del 30-10 (COORDINACIÓN-22, 16:37 y 16:49 UTC; Titín da por buenas JSPI y Maglev):**
- **JSPI y las banderas de Wasm que pasan a true en 13.7** (`wasm_deopt`, `wasm_inlining_call_indirect`, `branch_hinting`,
  `exnref`): **sí, como Chrome 137** (regla 19 y huella). Ya están así en V8 13.7 sin tocar nada. Condición: la FS del 137
  (regla 17) revisa expresamente JSPI y `wasm_deopt` con los merges posteriores hasta la LTS; si aparece algo explotado
  sin portar, se apaga desde gin (`--no-experimental-wasm-jspi`, etc.) hasta portarlo.
- **Maglev: sigue apagado en el 137** (falta la medición de JetStream de LOCAL en la 6,1 y la 5,1 y el umbral de Titín).
  Seguir portando su deuda de seguridad (`patches/v8/FLYWEB-SECURITY.md`) para que encenderlo sea solo la bandera.
- **V8 13.7.152.18/.19:** como arreglos del 137 (484172fda y 4278d6d37 ya estaban en `patches/v8`, comprobado con `apply -R`).
- **`ReduceScreenSize`: no** (Chrome 137 no la lleva); se reabre cuando Chrome la envíe.
- **Canvas float16 + `ImageData.pixelFormat`: sí, solo si `getImageData` en float pasa por el mismo farbling**, con una
  prueba que lo demuestre (dos lecturas en orígenes distintos, valores distintos); si no se puede garantizar, fuera y
  anotado. SEGURIDAD-PORTES lo revisa en la FS del 137.
- **Particionado de Blob URL: sí, en una 2.6.x propia** después de publicar la 2.6.0.
- ~~**`DocumentIsolationPolicy`: sí**, en la 2.6.0 o en la 2.6.x de Blob URL~~ → **no se porta** (COORDINACIÓN-22, 30-10,
  tras MOTOR-39): Brave 1.79 no la apaga, pero en Chrome 137 la de Blink es `experimental` + origin trial y ninguna web la
  ve. Se reabre cuando Chrome la saque en stable. La 2.6.x lleva solo el Blob URL.
- **CSS `if()` y `reading-flow`:** a MOTOR-38 con el plan y la estimación de «Pendiente del 137».
- **FS del 137:** COORDINACIÓN la abre a SEGURIDAD-PORTES cuando MOTOR dé el inventario por cerrado.

**Fallo esperado de la d8 13.7: `mjsunit/maglev/extras-cped`** (MOTOR-39, 30-10). La prueba no pasa `--maglev` y
termina con `assertTrue(isMaglevved(testOpt))` (39:1); `patches/v8/src-flags-flag-definitions.h.patch` pone
`DEFINE_BOOL(maglev, false, …)`, así que `%OptimizeMaglevOnNextCall` no compila con Maglev y el assert falla. Por eso pasa
en la base y falla con los parches (igual que en la 13.4–13.6), y pasa en la tanda `--maglev --stress-maglev` (1319/1319).
No es un error: desaparece el día que se encienda Maglev. Cifra buena de la d8 parcheada: 7799/7800 con ese único fallo.

**2.5.0 (LOCAL-14):** los arreglos de compilación de la 1.ª pasada (`local/250-arreglos` 44d92a8611, 13 sitios) están
fundidos en `nube/motor-137` 331b25b6 (tres parches resueltos en fuente: `style_builder_converter.cc`, `element.h`,
`out_of_flow_layout_part.cc`).

## Dónde puede fallar al compilar

- **V8 13.7 + simdutf 6.4.0** (cc6ec885): los `third_party-simdutf-*.patch` son ficheros nuevos de la 137 (la 128 no
  tiene simdutf). A mano: `builtins/wasm.tq`, `codegen/compiler.cc` (`SetScopeInfo` + `TryGetOuterScopeInfo`),
  `turboshaft/pipelines.cc` (guarda de 4 KB entre `AssignSpillSlotsPhase` y `CommitAssignmentPhase`).
- **`:visited` particionado** (b832524c): `HistoryAddPageArgs` con `frame_url` como último argumento (orden de la 128);
  `history_tab_helper.cc` (opener y cadena de openers vivos para `target=_blank`); `Document::GetCachedTopFrameSite`
  con `VisitedLinkPassKey` amiga de `HTMLAnchorElement`; `PartitionVisitedLinkDatabaseWithSelfLinks` generada por el json5
  (quitada de `features.cc/.h`): si algo fuera de Blink la declara aparte, choque de símbolos.
- **`offset-path: shape()`** (d20bb0ed): `ShapeOffsetPathOperation` con `scoped_refptr` (`std::move(shape)`);
  `NOTREACHED_NORETURN()` de la 128.
- **AudioWorklet** (2afdbe36): `ToV8Traits<AudioWorkletProcessor>` y `V8AtomicString` en `audio_worklet_processor.cc`.
- **CSS `if()`** (ce442bec, MOTOR-38, a mano): `CSSIfParser` sobre stream pero con los parsers de media/container **por
  rango** de la 128 (`ConsumeBlockContentsAsRange` re-tokeniza el bloque, como `@media`); `MediaQueryParser` hace
  `friend class CSSIfParser` (constructor privado en la 128); `KleeneValue` pasa a `kleene_value.h`;
  `css_variable_parser.cc` construye un `CSSParserContext` desde el `ExecutionContext`; `StyleCascade` con
  `CSSTokenizer` + `CSSParserTokenStream(tokenizer)` (no hay `CSSParserTokenStream(String)` en la 128) y
  `ResolveTokensInto` sobrecargado con `stop_type`; `SetAffectedByFunctionalMedia` sale del json5 de campos extra.
  Prueba: `if(media(width > 0px): green; else: red)`, `if(style(--x: 1): …)`, `if(supports(display: grid): …)`.
- **`reading-flow`/`reading-order`** (f4b4d1ec): `Element::ReadingFlowChildren` (foco y AX); `ReadingFlowNodes` en lugar
  de `ReadingFlowElements` en layout; `CSSSampleId::kReadingOrder = 839`; `AXNodeObject::AddNodeChildren` sin
  `IsAddedOnlyViaSpecialTraversal` (13x). Toca el foco con Tab: probar Tab en un flex con `reading-flow: flex-visual`.
- **Selección en Shadow DOM** (5abcd0cc): `getComposedRanges` (IDL nuevo `get_composed_ranges_options.idl`, en
  `idl_in_core.gni`/`generated_in_core.gni`), `UpdateSelectionBehavior` en `Range`; `HandleMouseFocus` y
  `SelectionHasFocus` suben por el árbol plano (forma final de la 137, sin las flags que upstream quitó);
  `WebFeature` 5040/5041.
- **Canvas float16** (f52504fe, 94a1c75d, MOTOR-40): el generador de bindings conoce `Float16Array` (`idl_type.py`,
  `ir_builder.py`, `interface.py`, `union.py`, `blink_v8_bridge.py`); la unión pasa a
  `v8_union_float16array_float32array_uint8clampedarray` y los enums a `v8_image_data_pixel_format` y
  `v8_canvas_color_type` (`generated_in_{core,modules}.gni`). `setColorType`/`setPixelFormat` reciben `String` como en
  la 128. Farbling: `BraveSessionCache::PerturbPixels` con un tercer argumento (bytes por canal); `html_canvas_element.cc`
  de `chromium_src` lo deduce del tamaño del búfer (`ImageDataBuffer` no da el tipo de color). Tests: `blink_unittests`
  de canvas y de serialización actualizados (`setPixelFormat`, `DOMFloat16Array`).

- **Anchor en inline/multicol** (8044f254, MOTOR-41): una línea en `box_fragment_builder.cc` (`Finalize()` fuera del bucle
  de DCHECK). Pruebas: las 9 WPT de LOCAL-14 de `css/css-anchor-position` (anchor-getComputedStyle-002,
  anchor-name-inline-001, anchor-name-multicol-002/-003, anchor-position-inline-004, anchor-position-multicol-003/-005/
  -fixed-001, anchor-scroll-004), que deben pasar como en la 2.4.0 y CfT 136.
- **Cookies `fw1`** (1644d954, MOTOR-41): `net/extras/sqlite/sqlite_persistent_cookie_store.cc` (sin parche antes) con
  designadores (`UndecryptableFw1Row{.host_key = …}`), `BindBool`, `base::StartsWith`. Test nuevo
  `SQLitePersistentCookieStoreTest.UndecryptableFw1DropsOnlyItsRow` en `net_unittests`. Prueba en la Mac: ítem `fw1`
  corrupto, un dominio con una cookie `fw1` y otra `v10` → la `v10` sigue.

## Para la web

Declara Chrome **137** (137.0.7151.122). Prueba del nivel: `FlyWeb/tools/motor-137.html`.

- CSS `if()`: valores condicionales con `media()`, `style()` y `supports()`.
- `reading-flow` y `reading-order`: el tabulador sigue el orden en que se ven los elementos de un flex o una rejilla.
- Selección de texto a través de Shadow DOM (`getComposedRanges`).
- View Transitions con `view-transition-name: match-element`.
- `offset-path: shape()`.
- WebCrypto con Ed25519 (firmas modernas sin bibliotecas).
- Canvas de alta precisión (`colorType: "float16"`) e `ImageData` con `Float16Array` y `pixelFormat`, con la misma
  protección frente a la huella digital que el canvas normal.
- Privacidad: los enlaces visitados ya no se ven entre sitios distintos (`:visited` particionado), y las pestañas que
  abre un `blob:` de otro sitio no pueden acceder a la que las abrió.
- Certificados raíz al día (Root Store v19).
- JavaScript: V8 13.7 (WebAssembly con JSPI, como Chrome 137).
- Arreglado: los elementos colocados con `anchor()` y `anchor-size()` vuelven a encontrar su ancla cuando está dentro de un
  texto (un `<span>`) o de un diseño en columnas (fallaba desde la 2.5.0).
- Cookies: si una cookie cifrada con la clave de FlyWeb no se puede leer, se pierde solo esa, no todas las del mismo sitio.
