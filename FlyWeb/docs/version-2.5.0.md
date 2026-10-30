# FlyWeb 2.5.0 — nivel 136 del motor

MOTOR-35, 30-10-2026. Inventario y estado: `motor-niveles.md` § «Nivel 136»; cruce con wpt.fyi: `wpt-136-cruce.md`.
Declaración prevista: Chrome **136.0.7103.116** (la última Stable de Mac del 136). V8 **13.6.233.10** (5297e56d).

**Rama:** brave-core `nube/motor-136`: 778fd91ca9 (2.4.0) + 841029d2 (`fw1`, entregado a LOCAL) + d3951086, 365bbb4c,
670f8fa1, ada7223e, 6a78dd41 (MOTOR-35) + 8bc16792 … **1747f79f** (MOTOR-36: escapes, anchor, Blink del 136, regla 17,
HSTS/CT y declaración 136.0.7103.116 / 2.5.0). Sin compilar. Detalle por commit en `motor-niveles.md` § «Nivel 136».

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

- **Anchor** (dff03148, 33 commits): `PhysicalFragment::OofData` con la consulta como `Member` y `EnsureAnchorQuery()`,
  `LogicalFragmentLink` sigue siendo agregado, `AddOutOfFlowChildCandidate` con `align_self_direction` en medio
  (llamadores de flex, grid, math y custom: los de 2–4 argumentos no cambian), `LogicalStaticPosition` con campo nuevo,
  `FragmentBuilder::Finalize()`/`PropagateSizeDependentData()`.
- **Canvas `lang`** (6f8abd3c): `lang` puesto a mano en los dos IDL de la 128 (no hay `base_rendering_context_2d.idl`);
  `CanvasRenderingContextHost::GetLocale()` nuevo en `HTMLCanvasElement` y `OffscreenCanvas`.
- **OffscreenCanvas transferido** (8bc16792 + 6f8abd3c): el serializador escribe locale y dirección; el deserializador los
  lee en el mismo orden. `SerializedTextDirection*` vive en `serialized_color_params.{h,cc}` (sin el renombrado de upstream).
- **Fuentes** (e28633a3): `PrimarySimpleFontData` → `…WithSpace/WithDigitZero/WithCjkWater` en `font_fallback_list.h`.
- **CSS math** (28622769): `CSSMathOperator::kPow` y `CalculationOperator::kPow` (switch sin `default` en `ToString`).
- **CloseWatcher** (d84e5b8b): constructor `(LocalDOMWindow&, WatcherStack&)` y `CreateInternal`.
- `.mojom` de contadores: `kPrintColorAdjust = 848` y `kTextAutoSizingDisabledOnFlexbox = 5374` (fuera de orden).

## Caída al arrancar con `fw1` (LOCAL-14, 30-10)

La 2.5.0 se caía **siempre** al arrancar: `CHECK(password_sync_bridge_)` en
`LoginDatabaseAsyncHelper::GetSyncControllerDelegate()` (pila del minidump). Arreglo: brave-core `local/250-arreglos`
**8ef2fe9cd5** (LOCAL-14; revisado por MOTOR-40), fundido en `nube/motor-137` **aaaaef17**.

- **Causa.** `fw1` (FS.25) enciende `kUseAsyncOsCryptInLoginDatabase`, que la 128 trae **apagada**. Con ella,
  `Initialize()` de la base de contraseñas espera a que llegue la clave de `os_crypt_async`, y en la 128 el puente de sync
  de contraseñas se crea **dentro** de `Initialize()`. Sync pide el delegado del puente antes de que llegue la clave: no
  existe y el `CHECK` mata el navegador. Upstream lo arregló en la 136 separando la creación del puente (al arrancar) de su
  `Init()` (con la base abierta); el arreglo porta ese reparto. La migración `v10` → `fw1` no cambia: `Initialize()`
  sigue igual salvo la creación del puente, y el puente se crea siempre (tarea encolada en la secuencia de la base antes
  de `Initialize()`; si la base no abre, `Init()` sigue informando del error a sync como antes).
- **Por qué nadie lo vio antes de compilar.** (1) Es un fallo de orden en tiempo de ejecución: solo sale al arrancar un
  navegador con perfil y sync inicializado; ni `git apply`, ni `fuera.py`, ni la revisión de cifrado de FS.25 (que miró
  claves, formato y migración, no el arranque de sync) lo podían ver. (2) Según LOCAL-14, la app con `fw1` no se había
  arrancado nunca hasta esta compilación. (3) Encendimos una función que upstream llevaba apagada en la base: la 128 no
  probaba ese camino, y el arreglo de upstream (136) es posterior a la base.
- **Lección (para MOTOR y SEGURIDAD-PORTES):** al encender una `base::Feature` que la base trae apagada, buscar en
  upstream, entre la base y el Chrome en que se encendió, los commits que toquen el código que esa función controla, y
  portarlos con ella.

## Lo que no entra en la 2.5.0 (y por qué)

- F12 `AudioContext` `interrupted`: en Chrome 136 solo lo dispara el camino de visibilidad del marco, tras una función
  apagada; nada observable.
- F15 (tamaños con % y elementos sustituidos) y parte de F16/F18/F20: exigen infraestructura del 13x que la 128 no tiene
  (`HTMLImageElementActualNaturalSize`, quirks de `-webkit-box`, refactor del foco delegado, `GetValueIfKnown`). Lista de
  saltados en cada mensaje de commit.
- F17 (redondeo de scroll y de paint offset): pide prueba visual; a una 2.5.x solo si una web lo pide.
- `SplitCacheByCrossSiteMainFrameNavigationBoolean`: la 128 no tiene ni la función ni el código de la clave de caché.
- `d63e50b22` (nodos de compositor de anchor): `StackScrollTranslationVector` distinto en la 128; caso raro.
- **Decisiones de Titín (30-10, vía COORDINACIÓN-21):** `::target-text`/Scroll-to-Text-Fragment, **apagado** como en
  Brave (regla 20): los 3 escapes de `wpt-240` quedan aceptados. HEVC en WebRTC/MediaRecorder, **no se expone** (huella;
  las Mac de Mojave no tienen HEVC por hardware). Gradientes en espacios amplios: **solo el cuelgue** (f5074d96d: aviso
  en consola y rechazo del degradado, como Chrome 136); el parche de Skia, cuando una web lo pida.
  `PartitionVisitedLinkDatabaseWithSelfLinks`: **sí** (privacidad), pendiente de portar (historial y `visitedlink` del
  navegador, 6–10 h de papel): MOTOR-37.

## Para la web

- `Node.moveBefore()`: mover elementos sin perder su estado (iframes, foco, animaciones).
- JavaScript: `Float16Array`, `using`/`DisposableStack` y `RegExp.escape`.
- Arreglada una caída al arrancar con contraseñas guardadas (cifrado propio `fw1`).
- Arreglada una caída de pestaña con `Float16Array` (al pasarlo a funciones de la página como `crypto.getRandomValues`; venía de la 2.4.0).
- Anchor positioning con desplazamiento: los elementos anclados recuerdan el desplazamiento al elegir posición
  (`CSSAnchorRememberedScrollOffset`), y `position-area` puede ampliar el bloque contenedor.
- CSS: `print-color-adjust` sin prefijo, `attr(… raw-string)`, `var()` con cualquier fallback en propiedades registradas,
  `dynamic-range-limit`, colores relativos resueltos tarde, `pow()` con unidades, `-webkit-box` con `line-clamp`.
- Canvas: `ctx.lang`. SVG: `<a rel>` y `relList`; `isPointInFill({x, y})`. `ProgressEvent` con decimales.
- Temporizadores anidados como dice la especificación (recorte desde el nivel 6).
- Las páginas con `Cache-Control: no-store` vuelven al instante con «Atrás» si no han cambiado las cookies.
- Arreglos de CSS: unidad `ch` en texto vertical, gradientes con componentes ausentes, `flex` con `calc()`, columnas en
  `fieldset`, imágenes rotas sin forzar 1:1.
