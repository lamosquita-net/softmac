# FlyWeb 2.3.0 — nivel 134 del motor

MOTOR-29, 28-10-2026. Inventario: `motor-niveles.md` § «Nivel 134» (MOTOR-28). Declaración: Chrome **134.0.6998.166**
(la última Stable de Mac del 134; las .196 y siguientes son Extended). Mínimo de macOS declarado, igual: 11.7.10.

**Rama:** brave-core `nube/motor-134` **5107563b28**, sobre la 2.2.0 (`nube/motor-133` 888963ca5, con `attr()`). Sin compilar.
`FLYWEB_BUILD_NUMBER=35`.

| Commit | Qué |
|---|---|
| ab0e1d27a | **V8 13.4.114.21** (4f282ae4) + 11 arreglos solo-LTS de la M132 + stack clash + **deuda de Maglev** (serie `seg/maglev-134` 127ec285b de SEGURIDAD-PORTES-11, FS.34, sin su 0014, que ya estaba). Maglev **sigue apagado**. Época de caché 22. `third_party/simdutf` 6.0.2 (copiado de Chromium 134) y fast_float cb1d42aa. Detalle: `patches/v8/FLYWEB-SECURITY.md` |
| 0e96e06c0 | `HighlightInheritance` (d6f74a7b14, 921cea2e12), `CSSFontFeatureValuesRule` en `window` (9d821a1e08), `getContextAttributes()` de OffscreenCanvas 2D (147011978a, 01423875ef) |
| c24d63e96 | `<dialog closedby>`, `dialog.requestClose()` y cierre al pulsar fuera (17 commits, 88af292eec … ffe1a8806a, con la fusión M134 de sus caídas) |
| 8dd4b3137 | 9 correcciones de edición del 134, cada una con su flag en `stable` (c628c87401 … 49f2e7b918) |
| 5107563b2 | declaración 134.0.6998.166 / 2.3.0 |

## Decisiones

- **Maglev:** la deuda va dentro; el encendido, después de medir en la 5,1 y la 6,1 (la línea `maglev` de
  `src-flags-flag-definitions.h.patch`, con `maglev_untagged_phis` apagado). LOCAL-14 vio JetStream colgado con
  `--maglev` en la 6,1 (tablero, 28-10): hay que repetirlo con esta V8 antes de encender. Pendiente de COORDINACIÓN.
- **No se porta 6736b12fb2** (canvas por software en Mac con NVIDIA): Chrome lo hizo porque quitaba la ruta de raster
  antigua; la 128 la conserva, así que el MacBook Pro 2012 (GT 650M) sigue con canvas acelerado. Si COORDINACIÓN prefiere
  igualar a Chrome, es un parche de `software_rendering_list.json`. COORDINACIÓN-19 (28-10): no se porta; probar el canvas en el MacBook Pro 2012
  con la NVIDIA cuando Titín pueda.
- **Fuera de Blink no hay nada que portar:** el informe de MOTOR-28 hablaba de rebasar parches como si la base subiera al
  134; la base sigue en la 128 y la huella de red del 134 no cambia (BoringSSL, HTTP/2, QUIC, grupos TLS iguales).
- No se portan: Privacy Sandbox, WebGPU, `DocumentPolicyExpectNoLinkedResources`, `bfe02c237c` (comando
  `request-close`), `SvgViewportOptimization` y los de rendimiento sin cara web (regla 20 y tabla del inventario).

## Primera Release (LOCAL-14, 28-10)

6 errores, arreglados en **67eb39d988**: cuatro parches del taint viejo de `attr()` que `generar128.sh` no había borrado
(`css_string_value`, `css_value_list`), `IsTablePartElement()` que no existe en la 128, `HandlePopoverLightDismiss()`
con un `KeyboardEvent` (rama muerta con CloseWatcher en `stable`, quitada) y `set_line`/`set_column` de perfetto en la
V8 13.4 (`code-data-source.cc`, no se escriben).

Después, FS.35 de SEGURIDAD-PORTES-12 fundida (**192ce3e811**: `seg/fs35-maglev-dead` 0ce38fe7 y `seg/fs35-blink134`
c56bbf9b). LOCAL-14: compila y enlaza; d8 13.4 mjsunit 7584/7585 (la de siempre, `maglev/extras-cped`) y con `--maglev`
1257/1257. `motor-134.html` 7/8: `willReadFrequently` salía como texto; arreglado en **858f858dc3** (06ed9ecbb6:
booleano en `CanvasRenderingContext2DSettings`, también en `<canvas>`; la mitad de `desynchronized_specified` no se porta).

## Dónde puede fallar la compilación

- V8 13.4 entera: `maglev-graph-builder.cc` (visitantes con `ReduceResult`, el ayudante de
  `DefineNamedOwnPropertyInLiteral`), `compiler/pipeline.cc`, los 20 parches de la serie de Maglev; simdutf (fichero de
  2,4 MB con funciones por arquitectura: comprobar que el SDK 13.3 lo compila y que en la 5,1 no elige AVX).
- `html_dialog_element.cc` (`VectorOf`, `DOMRect::IsPointInside`, `FlatTreeTraversal`), `pointer_event_manager.cc`,
  `close_watcher.cc`.
- `offscreen_canvas_rendering_context_2d.cc` (`getContextAttributes` copiado del 2D de la 128).
- `style_resolver.cc`/`computed_style.cc` (`SetInheritedVariablesFrom`).

## Pruebas

`FlyWeb/tools/motor-134.html` (comprobada en Chromium 153: todo ok salvo la versión declarada). WPT:
`FlyWeb/tools/wpt-134-lista.txt` frente a CfT 134. `d8` 13.4 con `FlyWeb/scripts/v8-d8.sh`: mjsunit y, con
`--maglev`, `mjsunit/maglev/*` (SEGURIDAD-PORTES-11 dio 7556/7560 sin nuestros parches; con ellos deberían pasar las 4 de
FlyWeb que fallaban).

## Para la web

FlyWeb 2.3.0 pone el motor al nivel de Chrome 134. Para quien hace webs: los diálogos se pueden cerrar pulsando fuera
(`<dialog closedby="any">`) y pedir su cierre como si fuera el usuario (`dialog.requestClose()`); los estilos de selección
y resaltado heredan de sus padres; `CSSFontFeatureValuesRule` accesible desde JavaScript; `getContextAttributes()` en los
lienzos fuera de pantalla, y varias correcciones de edición de texto (listas, pegar tablas y saltos de párrafo). El motor
JavaScript pasa a V8 13.4 con los arreglos de seguridad de la versión anterior que no traía, y el compilador Maglev lleva
ya sus arreglos de seguridad, aunque sigue apagado. Sin cambios visibles en la interfaz.
