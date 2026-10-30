# FlyWeb 2.6.0 — nivel 137 del motor

MOTOR-37, 30-10-2026. Inventario y estado: `motor-niveles.md` § «Nivel 137»; cruce con wpt.fyi: `wpt-137-cruce.md`.
Declaración prevista: Chrome **137.0.7151.122** (la última Stable de Mac del 137). V8 **13.7.152.17** (075234cf3d).

**Rama:** brave-core `nube/motor-137` sobre `local/250-arreglos` 3e8c8e219a (2.5.0 + FS.37): b832524c … **dea5f3eb**
(MOTOR-37). **A medias y sin compilar**; falta lo de «Pendiente del 137» en `motor-niveles.md`. No es una entrega.

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
