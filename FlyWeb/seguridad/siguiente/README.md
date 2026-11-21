# Seguridad: tanda siguiente (después de la 3.2.0)

Desde el 20-11 a las 20:01 UTC (COORDINACIÓN-57, confirmado por Titín en `docs/DIRECTIVAS.md`, #1160), la tanda de la
3.2.0 está cerrada: `seguridad/pendiente/` (#1147) y `seguridad/portes-159/` (#1159). Lo que llegue después y **no**
sea Alto, Crítico o KEV se prepara aquí, para la versión que venga detrás de la 3.2.0, salvo que Titín diga otra cosa.
Lo que sí lo sea se avisa enseguida a COORDINACIÓN. Lo prepara SEGURIDAD-PORTES (desde la -33, 21-11-2026).

## Base

| Repo | Base | Parches de aquí | Árbol resultante |
|---|---|---|---|
| chromium | árbol **`2bb85047ec`** (`pendiente/chromium/0001`–`0008` + `portes-159/chromium/0001`–`0002`) | `chromium/0001`–`0007` | **`3564a4b08e`** (tras `0006`: `c9905873db`; tras `0001`: `faec7dc5b9`; `0002`: `ee335593f3`; `0003`: `6d4ab28029`; `0004`: `1ec5df9eea`; `0005`: `f4eb399ad1`) |
| brave-core | árbol **`78df46b5d6`** (`pendiente/brave-core/0001`–`0004`, `3.2-v8/0001`–`0002` y `pendiente/brave-core/0005`; `patches/v8` = `6f8c5d4c51`, V8 = `9914512d91`) | `brave-core/0001` | **`1b0908a323`** (`patches/v8` = **`bc401fbf50`**; con todos los `patches/v8` sobre la V8 15.6.75.66, árbol de V8 **`41e5bb46c4`**) |

## Rama 8078 después del cierre de la tanda

| Commit de la 8078 | Qué | ¿Mac? | Parche |
|---|---|---|---|
| `af12c47ccb` (20-11 23:10 UTC) | [M156] «[HLS] Intercept data: URLs in HlsDataSourceProviderImpl» (580846503, merge 586790744) | Sí (abajo) | `chromium/0002` |
| `1a63009b31` (23:19 UTC) | Prueba desactivada en Mac | — | — |
| `2762e65042` (23:56 UTC) | [M156] «Disable VariationsService HTTP fallback by default» (588460249, merge 588518337) | Sí, pero en FlyWeb Variations apunta a una URL inerte (abajo) | `chromium/0003` |
| `f95dd51f6f` (21-11 00:09 UTC) | [M156] «Never expose pseudo-elements via Event.target; fix ::column disposal» (583179913, 584370079; merge 588203329) | Sí (abajo) | `chromium/0001` |
| `d1b613c0d8` (00:20 UTC) | [M156] «Retarget NavigateEvent.sourceElement» (584367025, merge 585802046) | Sí (abajo) | `chromium/0004` |
| `40bf5125f6` (00:21 UTC) | [M156] «Recheck cross-document new children in ReplaceChild(VectorOf<Node>)» (583907042, merge 587226434) | Sí (abajo) | `chromium/0005` |
| `dabab2fd13` (00:23 UTC) | [M156] «Don't pause on DOM breakpoints during document lifecycle updates» (584330765, merge 587226163) | Sí, con DevTools abierto (abajo) | `chromium/0006` |
| `1f56333f76` (00:57 UTC) | Pruebas WPT marcadas como inestables en Mac | — | — |
| `b83b7983ff` (02:12 UTC) | VERSION a 156.0.8078.120 | — | — |
| `28fb53154e` (02:35 UTC) | [M156] «Don't scroll when a focused input's list target changes» (583179912, merge 588196773) | Sí (abajo) | `chromium/0007` |
| `3df8aa144a` (03:32 UTC) | *Roll* de pruebas internas de Glic (`chrome/browser/glic/e2e_test/internal`) | — | — |
| `04db7fff13` (00:10 UTC) | [M156] «SchemeHostPort: Reject empty host for non-file SCHEME_WITH_HOST schemes» (586171393, merge 588196153) | Sí | Ya está: es **idéntico** (`patch-id` igual) a `portes-159/chromium/0002` (#1159) |

El tag **156.0.8078.113** (`970863f8c7`, 20-11) **no sirve de referencia**. Es un *hotfix* en la sub-rama
`branch-heads/8078_108`, hecha desde 8078@#2244 (16-11, anterior a la .111), que solo añade el cambio de Variations.
Tiene menos arreglos que la .112.

## Tag 156.0.8078.119 (`1f56333f76`, rama principal 8078; visto el 21-11 a las 02:30 UTC)

Su DEPS tiene V8 `f08ef923d3` (15.6.75.76) y **las mismas** Skia (`9d96dfeb45`), ANGLE (`0b547a1161`), PDFium y Dawn que
la .112. Todo lo que hay entre `.112` y `.119` en la rama está ya preparado:

- `pendiente/chromium/0003`–`0008` y `brave-core/0002`, `0003` y `0005` (V8 .75, .74 y .76), en #1147;
- `portes-159/chromium/0002` (SchemeHostPort), en #1159;
- `siguiente/chromium/0001`–`0006`, aquí.

El resto son cambios de VERSION y de pruebas. Así que **con este PR dentro, la versión cubre la .119 entera**. Sin él,
se queda en la .112 más lo de #1147 y #1159. Lo que se declare lo decide Titín. Además, FlyWeb lleva arreglos que la
.119 no tiene: `brave-core/0004` (585614984, aún sin merge en la 15.6) y `portes-159/chromium/0001` (menús FOR_DROP).
La rama 8078 sigue en la .120.

## `chromium/0001`: f95dd51f6f (bugs 583179913 y 584370079)

Mientras se ejecutan los manejadores por defecto de un evento, su `target` vuelve a ser el pseudo-elemento en bruto si
este tiene comportamiento de activación (p. ej. `::scroll-marker`). Un *script* que se ejecutara entonces (p. ej. un
`DOMActivate`) podía leer `event.target` y obtener un `PseudoElement` vivo, y con él moverlo y **corromper el árbol de
pseudo-elementos** en el *renderer*. `Event::target()` solo tenía un `DCHECK`. Ahora devuelve el elemento de origen, o
`null`. Además, desechar un `::column` no desechaba su `::scroll-marker`, y eso también se corrige. Se alcanza desde
cualquier web con *scroll markers* de CSS. Aplica a Mac.

- Mismo cambio que upstream. Los seis ficheros que no son `element.cc` quedan idénticos byte a byte a los de upstream.
  En `element.cc` el *hunk* entra con un desplazamiento de 9 líneas y con las mismas líneas añadidas y quitadas
  (`git diff` las alinea de otra forma, por eso el `patch-id` sale distinto). El resto de diferencias de ese fichero con
  upstream son portes anteriores de FlyWeb, en otras funciones.
- brave-core no toca estos ficheros.

### Veredicto (regla 17): **APTO**, `chromium/0001`

Pruebas para LOCAL: las dos WPT nuevas de `css/css-overflow/scroll-markers/` (`*-crash.html`), con `run_web_tests`, y
`blink_unittests --gtest_filter='*Event*Target*:*PseudoElement*'`.

## `chromium/0002`: af12c47ccb (bug 580846503)

El reproductor HLS integrado (`HlsDataSourceProviderImpl`) pasaba las URL `data:` por la pila de red, y así quedaban al
alcance de los *service workers*, que podían interceptarlas. Ahora se cargan directamente (`net/base/data_url`). En
FlyWeb el *demuxer* HLS se compila (`enable_hls_demuxer = proprietary_codecs`, y Brave compila con códecs
propietarios), así que aplica a Mac.

- Mismo diff que upstream (`patch-id` igual). Añade `+net/base/data_url.h` a `media/DEPS`. brave-core no toca estos
  ficheros.

### Veredicto (regla 17): **APTO**, `chromium/0002`

Pruebas para LOCAL: `media_unittests --gtest_filter='HlsDataSourceProvider*'` y, en la build, un vídeo HLS (`.m3u8`)
cualquiera.

## `chromium/0003`: 2762e65042 (bug 588460249, b/554051967)

`VariationsService` reintentaba por **HTTP plano** cuando fallaba la descarga de la semilla por HTTPS. Ahora ese
reintento viene apagado por defecto. En FlyWeb, Variations apunta a una URL inerte, así que en principio no hay
petición que reintentar. Va como endurecimiento, por si un día la URL deja de ser inerte.

- Mismo diff que upstream (`patch-id` igual). brave-core no toca `variations_service.{h,cc}`.

### Veredicto (regla 17): **APTO**, `chromium/0003`

Prueba para LOCAL: `components_unittests --gtest_filter='VariationsServiceTest.*'`.

## `chromium/0004`: d1b613c0d8 (bug 584367025)

`NavigateEvent.sourceElement` devolvía el elemento de origen en bruto, que puede estar dentro de un *shadow tree*. Al
pulsar un `<a>` de SVG clonado dentro del *shadow tree* de agente de usuario de un `<use>`, el *script* recibía la copia
interna y podía **modificar el *shadow tree* de agente de usuario** en el *renderer*. Ahora `sourceElement` se
reorienta igual que `ToggleEvent.source`, `CommandEvent.source` e `InterestEvent.source`, y nunca expone nodos internos
del *shadow*. Se alcanza desde cualquier web que use la Navigation API. Aplica a Mac.

- Mismo diff que upstream (`patch-id` igual). brave-core no toca estos ficheros.

### Veredicto (regla 17): **APTO**, `chromium/0004`

Prueba para LOCAL: la WPT nueva `navigation-api/navigate-event/sourceElement-shadow-tree.html`.

## `chromium/0005`: 40bf5125f6 (bug 583907042)

En `ContainerNode::ReplaceChild(const VectorOf<Node>&, ...)`, quitar el hijo viejo puede ejecutar manejadores de
eventos síncronos (p. ej. el `blur` de un control deshabilitado dentro de un `<fieldset>`). Si un manejador metía uno
de los hijos nuevos en **otro documento**, el detector de mutaciones no lo veía, se saltaba la comprobación y el nodo
acababa enlazado en dos listas de hijos: **corrupción del árbol DOM** en el *renderer*. Ahora la comprobación se fuerza
cuando algún hijo nuevo no está en el documento del nodo. Se alcanza desde cualquier web (`replaceWith`,
`replaceChildren` con varios nodos). Aplica a Mac.

- Mismo diff que upstream (`patch-id` igual). brave-core no toca `container_node.cc`.

### Veredicto (regla 17): **APTO**, `chromium/0005`

Prueba para LOCAL: la WPT nueva `dom/nodes/crashtests/replaceWith-blur-cross-document-crash.html`.

## `chromium/0006`: dabab2fd13 (bug 584330765)

Los puntos de interrupción de DOM de DevTools podían detenerse en mutaciones hechas **durante una actualización del
ciclo de vida** (p. ej. al desechar pseudo-elementos en el *recalc* de estilo). Al pausar, el depurador puede ejecutar
*script*: por ejemplo, `ViewTransition.skipTransition()` liberaba la lista que se estaba recorriendo y había un **UAF**
al reanudar. Ahora no se pausa en mutaciones que no causa el *script*. Solo se alcanza con DevTools, o una extensión con
`chrome.debugger`, y puntos de interrupción de DOM. Aplica a Mac.

- Mismo diff que upstream (`patch-id` igual). `VirtualTestSuites` entra con desplazamiento de 1–2 líneas. brave-core
  no toca `inspector_dom_debugger_agent.cc`.

### Veredicto (regla 17): **APTO**, `chromium/0006`

Prueba para LOCAL: `inspector-protocol/dom/dom-breakpoint-skip-view-transition-during-recalc.js` (y su variante
`virtual/threaded`).

## `chromium/0007`: 28fb53154e (bug 583179912)

`TextFieldInputType::ListAttributeTargetChanged()` puede ejecutarse de forma síncrona desde notificaciones de mutación
del DOM. Si el `<input>` tenía el foco, llamaba a `UpdateSelectionOnFocus(kRestore)`, que hace *scroll* y fuerza un
*layout* síncrono a mitad de la mutación. Durante `moveBefore()`, ese *layout* anidado podía recalcular asignaciones de
*slots* mientras `LocalFrameView` recorría `scroll_anchoring_scrollable_areas_`: **corrupción o UAF en el
*renderer***. Ahora no se hace *scroll* en ese caso. Se alcanza desde cualquier web (`<input list>`, `<datalist>`,
`moveBefore`). Aplica a Mac.

- Mismo diff que upstream (`patch-id` igual). brave-core no toca `text_field_input_type.cc`.

### Veredicto (regla 17): **APTO**, `chromium/0007`

Pruebas para LOCAL: las dos WPT nuevas `dom/nodes/moveBefore/moveBefore-input-list-target-{inserted,removed}-crash.html`.


## V8 después del cierre de la tanda

| Commit | Qué | ¿Mac? | Parche |
|---|---|---|---|
| `5b7c1a1f0f` (merge en la 15.9, M159; de `352e9c46c2` en *main*) | «[compiler] Use TruncateFloat64ToInt64 when input may be minus zero» (585624828, 588203225) | Sí (abajo). **Sin merge en la 15.6** | `brave-core/0001` |

## `brave-core/0001`: 352e9c46c2 (bug 585624828)

En `RepresentationChanger::GetWord64RepresentationFor`, un número (float o *tagged*) de tipo
`kDoubleRepresentableInt64OrMinusZero`, con un uso que identifica +0 y −0, se convertía a Int64 con
`ChangeFloat64ToInt64`/`ChangeTaggedToInt64`. Los dos bajan a `ReversibleFloat64ToInt64`, que da por hecho que el Int64
vuelve al mismo Float64, y con −0.0 no es así: **TurboFan genera código con una suposición falsa** (la clase de fallo
que acaba en confusión de tipos). Ahora se usa `TruncateFloat64ToInt64` (desempaquetando antes con
`ChangeTaggedToFloat64` si la entrada es *tagged*), y `SimplifiedLoweringVerifier` propaga las truncaciones a través
de él. Se alcanza desde cualquier web con JavaScript optimizado. Aplica a Mac. COORDINACIÓN-57 pidió portarlo ya,
sin esperar al merge de la 15.6, por el precedente de `pendiente/brave-core/0002` y `0004`.

- `representation-change.cc` y `simplified-lowering-verifier.cc` son idénticos byte a byte en la 15.6.75.66 y con
  todos los `patches/v8` aplicados: ningún parche de FlyWeb ni de Brave los toca. El diff es el de upstream
  (`patch-id` igual), más la prueba `test/mjsunit/compiler/regress-585624828.js`.
- **No se llevan** los cambios de *unittests* de upstream: `representation-change-unittest.cc` en la 15.6 es el
  cctest `test-representation-change.cc`, con otras utilidades, y el caso nuevo de
  `turboshaft/machine-optimization-reducer-unittest.cc` comprueba comportamiento ya existente del reductor, no el
  arreglo.
- Cambia código optimizado. Si entra en la 3.2.0, le vale la subida de época a 38; si sale después, esa versión
  tiene que volver a subir `kFlyWebCacheEpoch`. Nota en inglés al principio de `patches/v8/FLYWEB-SECURITY.md`.

### Veredicto (regla 17): **APTO**, `brave-core/0001`, si D8-LINUX lo da en verde

Pruebas (en el mismo encargo de D8-LINUX que la tanda de la 3.2.0, paso nuevo al final): mjsunit con y sin Maglev,
en especial `compiler/regress-585624828`, y `cctest/test-representation-change/*`, en *release* y en *debug*.
