# FlyWeb 2.1.0 — motor 132 (FM.45)

**Estado (27-10-2026, MOTOR-25):** brave-core `nube/motor-132` **50f5d099** (13 commits sobre `nube/motor25-p25` fbe2394fed =
2.0.3 compilada por LOCAL-12 + b2 + arreglo de las fijadas). **Sin compilar.** Falta, antes de dársela a LOCAL: **FS.28**
(rebase de `patches/v8` a la 13.2.152.56 y Maglev, SEGURIDAD-PORTES-9; sin él no aplican los parches de V8) y **FS.27**
(regla 17 de `sideways` y `shape-outside`). Inventario y decisiones: [`motor-niveles.md`](motor-niveles.md), «Nivel 132».
`flyweb_version` 2.1.0 (el menor sigue al nivel sobre la base 128, como sobre la 116: **lo confirma COORDINACIÓN**).
Prueba: `FlyWeb/tools/motor-132.html`; WPT: `FlyWeb/tools/wpt-132-lista.txt`. **Cambios visibles en la interfaz:** ninguno
(todo es de lo que dibujan las webs).

Un commit por punto, para revertir uno solo:

| Commit | Qué |
|---|---|
| 7e78e663 | Escape: serie de `shape-outside` del 129 (`ShapeOutsideWritingModeFix`, `ShapeOutsideClippedImageFix`; la necesita `sideways`) |
| 33b2a351 | Escapes: `DirAutoFixSlotExclusions`, `TextInputNotAlwaysDirAuto` |
| 780af58e | Escape: `ScrollIntoViewRootFrameViewportBugFix` (con 291f585e77 y sus pruebas) |
| d10597e6 | V8 13.2.152.56 en `FlyWeb/v8-revision` y la parte de Blink de su API (`IsRoot`, `SetIsLoading`) |
| 89245751 | `toggle`/`beforetoggle` en `<dialog>` |
| 95eb20ed | `Request.bytes()`, `Response.bytes()`, `PushMessageData.bytes()` |
| 3dcda630 | `anchor-size()` en *insets* y márgenes (el código vino con el 131; solo se enciende) |
| 1ed75fc7 | IndexedDB: `NotReadableError` (adaptado a la 128) |
| b041904e | Flags del 132 sin Baseline (selección en Shadow DOM, *top layer* en documentos inactivos, `<li>` con `counter-set`, doble clic con `float`, `selectionchange` al borrar, selector de fecha) |
| 541200a5 | `KeyboardFocusableScrollers` a `stable` (como Chrome for Testing 132 y Brave 1.74) |
| 250c23a8 | Nivel 132 declarado: `132.0.6834.160`, `flyweb_version` 2.1.0 |
| 915097fd | Merge de FS.27 (`seg/fs27-blink132` 54b1ae68, SEGURIDAD-PORTES-9: arreglos de caídas de upstream en el código que toca `sideways`) |
| **50f5d099** | **`writing-mode: sideways-rl` y `sideways-lr`**, el último (35 commits + encendido; si LOCAL o FS.27 lo tumban, se revierte solo) |

**Fuera del nivel, con motivo:** `SkipTemporaryDocumentFragment` (398837e6773: necesita los refactors de
`Node::ConvertNodeUnionsIntoNode` de 129–131; núcleo del DOM y sin Baseline), `ViewTransitionOverflowRectFromSurface` (su
flag no está en la 2.0), `FindRubyInPage` (solo Cmd-F, aplazado), el refactor 199d1a77501 de `KeyboardFocusableScrollers`
(~60 ficheros: los recuadros con desplazamiento también se enfocan con el ratón, como en la 1.14). `NoReferrerForPreloadFromSubresource`
ya estaba: es CVE-2025-4664, portado en la 2.0.0.

**Riesgos para LOCAL:** `sideways` (35 commits sobre la 128 sin compilar; tres adaptados a mano: sentido de los
deslizadores, caret de bloque vacío y ancla de desplazamiento); la serie de `shape-outside`; V8 13.2 (que `patches/v8`
compile tras FS.28). **Maglev, pendiente de COORDINACIÓN** (SEGURIDAD-PORTES-9 recomienda no encenderlo en el 132: ~15 arreglos posteriores a la LTS); si se enciende: Speedometer 3 y JetStream con y sin él en la 5,1 y la 6,1; si la 5,1 empeora, se
apaga con el dato (COORDINACIÓN-16).

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12.)*

- **Motor al nivel de Chrome 132.** Las webs ven FlyWeb como Chrome 132.
- **Texto girado de lado** (`writing-mode: sideways-rl` y `sideways-lr`): las webs pueden poner texto en vertical girado
  hacia un lado u otro, como en Firefox y Safari (títulos en lomos de libros, tablas con cabeceras verticales).
- **Diálogos que avisan al abrirse y cerrarse** (eventos `toggle` en `<dialog>`), como en Firefox y Safari.
- **`bytes()` en las respuestas de red**, para que las webs lean datos binarios con menos código.
- **Elementos anclados más flexibles**: `anchor-size()` también en posiciones y márgenes.
- **Formas de texto alrededor de imágenes** (`shape-outside`) correctas también en texto vertical.
- **Teclado**: los recuadros con barra de desplazamiento se pueden enfocar con Tab y mover con las flechas.
