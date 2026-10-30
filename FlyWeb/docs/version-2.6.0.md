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
- **`DocumentIsolationPolicy`: sí**, en la 2.6.0 si cabe sin riesgo o en la misma 2.6.x que Blob URL; **antes comprobar
  que Brave 1.79 no la apaga** (si la apaga, no se porta: regla 20).
- **CSS `if()` y `reading-flow`:** a MOTOR-38 con el plan y la estimación de «Pendiente del 137».
- **FS del 137:** COORDINACIÓN la abre a SEGURIDAD-PORTES cuando MOTOR dé el inventario por cerrado.

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

## Para la web

(Se escribe al cerrar el nivel.)
