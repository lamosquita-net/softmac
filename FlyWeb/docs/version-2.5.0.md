# FlyWeb 2.5.0 — nivel 136 del motor

MOTOR-35, 30-10-2026. Inventario y estado: `motor-niveles.md` § «Nivel 136»; cruce con wpt.fyi: `wpt-136-cruce.md`.
Declaración prevista: Chrome **136.0.7103.116** (la última Stable de Mac del 136). V8 **13.6.233.10** (5297e56d).

**Rama:** brave-core `nube/motor-136`: 778fd91ca9 (2.4.0) + 841029d2 (`fw1`, entregado a LOCAL) + d3951086, 365bbb4c,
670f8fa1, ada7223e, 6a78dd41 (MOTOR-35, sin compilar). Falta el resto del Blink del 136, anchor y la declaración.

## Dónde puede fallar al compilar

- **CppHeap** (670f8fa1, e0ae83721): `thread_state.{h,cc}`, `v8_per_isolate_data.{h,cc}`, `v8_initializer.cc`,
  `worker_backing_thread.cc`, `gin/isolate_holder.{h,cc}` (estos dos ya llevaban parche de FlyWeb). Riesgo en ejecución:
  cierre de workers y snapshot con el heap en manos del isolate.
- **V8 13.6:** `shared-function-info` (bits `live_edited` + `class_initializer_allows_await`, 32 justos), `rewriter.cc`
  (el desbordamiento de pila por `out_has_stack_overflow`), `cppgc/visitor.h` (`ClearKeyAndValueIfKeyIsDead`).
- **moveBefore** (d3951086): `node.idl` → `parent_node.idl`, reacciones de custom elements (`connectedMoveCallback`),
  `webdx_feature.mojom` con `kMoveBeforeAPI = 229` fuera de orden.
- **Faltas del cruce:** `element.cc` (`TrustedTypesCheckFor` de 4 argumentos), `color.cc`/`gradient.cc`
  (`ConvertToColorSpaceForInterpolation`), `cc/paint/paint_shader.cc` (`gfx::ClampFloatGeometry`).

## Para la web

- `Node.moveBefore()`: mover elementos sin perder su estado (iframes, foco, animaciones).
- JavaScript: `Float16Array`, `using`/`DisposableStack` y `RegExp.escape`.
- Arreglos de CSS: unidad `ch` en texto vertical, gradientes con componentes ausentes, `flex` con `calc()`, columnas en
  `fieldset`, imágenes rotas sin forzar 1:1.
