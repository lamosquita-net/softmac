# FlyWeb 1.15.2 — anchor positioning del nivel 131 (FM.28, MOTOR-13, 20-10-2026)

**Estado:** **en código; candidato a la entrega `nube/motor-131-anchor-f13` 357d708c47** (= 9069fb3e1a, `nube/motor-131-anchor-1152`, con los arreglos de las WPT de la F11, 12bfef324f99 y el seguimiento de upstream 0e454ce616 que portó SEGURIDAD-PORTES-4; falta compilarlo y probarlo). 9069fb3e1a = el porte
(rama `nube/motor-131-anchor` sobre la 1.15.1, fa4fae392f) + FS.22 + `flyweb_version` 1.15.2. Visto bueno de seguridad de
SEGURIDAD-PORTES-3 al porte (FS.21) y a la F9 (21-10, #391). Compilaciones de prueba (Static, `-k 0`): F2 38097e9ea2,
14 errores en 3 cabeceras; F4 5312cb22da, 40 en 17 ficheros; F5 767c49475b, navegador sin errores de C++ pero sin enlazar
(`Position::ApplyInherit`) y 115 errores en `blink_unittests` (unos 88 de antes del porte, arreglados solo en tests); F7
7f864fb08c y F8 510aab322e, compilan y enlazan, pero **el renderer se caía en cualquier recálculo de estilo** (SEGV 0x38
en `Element::RecalcOwnStyle`: el código de upstream lee `new_style` después de `std::move(new_style)`, que no lo vacía en
upstream porque `ComputedStyle` es GC y en la 116, `scoped_refptr`, sí); F9 6fef4b8068 lo arregla (y guarda con referencia
el estilo candidato de `@position-try`); F10 ecb6ce11ed, `shadowrootmode` en un test. **Pruebas de LOCAL-6 (21-10)** con
la F9/F10: `blink_unittests` del anchor y `LayoutBoxTest.*` 476/477 (el que falla, `ElementFragmentAnchorTest`, es de los
fragmentos `#ancla`, no del porte); en la 6,1 sin caídas, motor-117…130 iguales que la 1.15.1, **motor-131 32/32**,
superficie +81 líneas (solo lo del anchor, nada quitado), shader WebGL2 `for(;;)` rechazado (FS.22; la 1.15.1 lo
aceptaba), ventanas nuevas bien, carrusel `overflow: hidden` y página larga a 60 fps como la 1.15.1. Sin automatizar:
`<webview>` de extensiones. **WPT frente a CfT 131 (LOCAL-6, 21-10, F9; 405 pruebas, 2 pasadas iguales):** CfT 332/73,
F9 328/76 y 1 colgada. Del anchor, 3 peores: `anchor-scroll-overflow-hidden` (fallo de traducción: los contenedores
`overflow: hidden` no contaban para el ajuste por scroll) y `anchor-position-top-layer-007` (faltaba upstream 1624b1441b9),
las dos arregladas en 9472de6fe0 junto con 14c9714ba83e (caída en cc con los nodos de scroll de `overflow: hidden`), y
`anchor-getComputedStyle-002`, que queda como diferencia conocida; 6 del anchor salen bien en FlyWeb y mal en CfT 131, y 8
fallan igual en la 1.15.1 (heredadas). **1624b1441b9 arregla además una caída del renderer que ya tenía la 1.15.1**: los
dos crashtests de container queries con la capa superior del 131 tumban el renderer en la 1.15.1 y en la F9 (SEGV) y
pasan en CfT 131. **Y la F12 (f2699e58e7) arregla otra caída que la 1.15 y la 1.15.1 tienen desde FM.22:** con
`GetComputedStyleOutOfFlowInsetsFix` (6c6fc68fc55) vino un CHECK que exige que el resultado de layout de un absoluto guarde
sus insets, pero no su complemento upstream 12bfef324f99 (crbug 1458561): tras un layout de subárbol de un absoluto que es
límite de relayout, `getComputedStyle()` de un inset no fijo tumba el renderer (p. ej. cambiar el texto de un tooltip
absoluto de tamaño fijo y leer su `top: 10%`). Prueba: `FlyWeb/tools/caidas-fm28.html` (**confirmado por LOCAL-6, 21-10:** la F9 se cae con «Check failed: bitfields_.has_oof_insets_for_get_computed_style» y la 1.15.1 publicada tampoco llega al final). **Falta:** compilar y probar la F13
(navegador, `blink_unittests`, WPT, los crashtests y `caidas-fm28.html`) y la Release (cuando lo diga Titín). Detalle técnico: fila FM.28 de `docs/TAREAS.md`; criba de la cadena en
`FlyWeb/tools/port/anchor-clas.tsv`.

| Dato | Valor |
|---|---|
| Cabeza | brave-core `nube/motor-131-anchor`: F1 0f9820c4 (2023, sintaxis vieja), F2 4efeaf5685 + 38097e9ea2 (enero–abril de 2024, hasta «Ship the anchor positioning API»), F3+F4 848c954d (mayo–octubre de 2024, hasta la rama de la 131, con los arreglos de FS.21), arreglos de la primera Static 5312cb22da, pruebas unitarias de la 131 6266cb55, `StyleAnchorScope` con
`WeakPersistent` y `KeyboardFocusableScrollers` apagado a35b831b, FS.22 fundida 2fba9e43, arreglos de la segunda Static
767c49475b, `Position::ApplyInherit` 1b3878c1, `blink_unittests` 4cd5d890 (del porte) y 7f864fb08c + 510aab322e (de antes
del porte), la caída de `RecalcOwnStyle` 6fef4b8068, `shadowrootmode` ecb6ce11ed, la versión 9069fb3e1a
(`nube/motor-131-anchor-1152`) y **los arreglos de las WPT 9472de6fe0** (`nube/motor-131-anchor-f11`: `overflow: hidden`,
1624b1441b9 y 14c9714ba83e) 12bfef324f99 f2699e58e7 (`-f12`) y **0e454ce616** de SEGURIDAD-PORTES-4 (`seg/top-layer-box` 1f7b9912), fundida en **357d708c47** (`nube/motor-131-anchor-f13`) |
| Versión visible / `CFBundleVersion` | 1.15.2 / 157.64.N (`FLYWEB_BUILD_NUMBER` lo pone LOCAL en la entrega) |
| Nivel declarado | Chrome 131, sin cambios (131.0.6778.265) |
| Motor JavaScript | el de la 1.15: V8 13.1.201.22 con los arreglos de FlyWeb (`patches/v8` igual) |
| Lo nuevo | **Anchor positioning de Chrome 131**, unos 230 commits de upstream: `anchor-name`, `position-anchor`, `anchor()` y `anchor-size()` (con el ancla y el lado en cualquier orden, `inside`/`outside` y `anchor-size()` sin argumento), `position-area`, `position-try-fallbacks`, `position-try-order` y `position-try`, la regla `@position-try` con `CSSPositionTryRule` y `CSSPositionTryDescriptors`, `position-visibility` (`anchors-visible`, `no-overflow`, anclas encadenadas), `anchor-scope` (con `all` por ámbito), `align-self`/`justify-self: anchor-center` con el comportamiento nuevo, la alineación segura por defecto de los elementos absolutos, el último *fallback* que funcionó, el ajuste al desplazar el ancla (también dentro de `overflow: hidden` desplazado) y la parte del inspector (ancla de un elemento, regla `@position-try` activa) |
| Adaptaciones a la 116 | analizadores con `CSSParserTokenRange`; `ComputedStyle` contado por referencias (`StyleAnchorScope` guarda el ámbito de `anchor-scope: all` con
`WeakPersistent`, como el `WeakMember` de `ScopedCSSName`, y los nombres con `Persistent`); `ConversionChecker` de las
animaciones no es GC (`std::make_unique`); sobrecargas de `ResolvedAlignSelf`/`ResolvedJustifySelf` con `ItemPosition` para el código de la 116; la ruta de la 116 de `IntersectionObserver` y de la unificación de scroll; el flag `CSSAnchorPositioning` se queda en `stable` (upstream lo quitó) para el código de la 116 que lo consulta; el atributo `anchor` solo con `HTMLAnchorAttribute` (experimental, como en la 131) |
| Seguridad (FS.21) | arreglos de upstream posteriores a la 131 incluidos: 07dfbede6f2 (caída con `@position-try` y `display: none`), 9d2cba3f6cf (estilo nulo en `IsScopedByElement`), 31adde08d12 y 05730fe4c1c (observador de visibilidad del ancla), d3bdf5fec59 (recursión en `AnchorPositionOffset` de cc). **Visto bueno de SEGURIDAD-PORTES-3** sobre 767c49475b; a
petición suya, `StyleAnchorScope` guarda el `TreeScope` con `WeakPersistent` (con `Persistent`, `anchor-scope: all`
cerraba un ciclo que no dejaba liberar el documento). Se conserva FS.12 e6273d015e (`layout_object.cc`,
`style_containment_scope*.cc`) |
| Seguridad (FS.22) | los 4 CVE críticos de 117–128 que faltaban en la 116, fundidos sin rebase (`seg/cve-criticos-128`
ad21546964): ANGLE CVE-2024-2883, CVE-2024-4058 y CVE-2024-7532 (parches del subrepositorio de ANGLE) y Site Isolation
CVE-2023-5218; y dos arreglos posteriores de upstream que tocan el código del porte (regla 17, SEGURIDAD-PORTES-4):
c215f8e6f0 (crbug 491994185, posible uso tras liberar en `LocalFrameView::PerformLayout` si un recálculo de estilo con
container queries destruye una raíz de maquetación de subárbol; `seg/subtree-roots-copy` 49964845, en la F14) y
0e454ce616 (crbug 543070692, la pertenencia a la capa superior se decide por el árbol de cajas; `seg/top-layer-box`
1f7b9912, en la F13) |
| Fuera, con motivo | `anchor-size()` en insets y márgenes (experimental en la 131), el atributo `anchor` y la relación implícita con quien abre un popover (flags no activados en la 131), `<select>`/`selectlist` personalizables (fuera del alcance), la relación `aria-details` de accesibilidad entre el ancla y el elemento anclado (74a5382ac8b; necesita el mecanismo `TreeUpdateReason` de `AXObjectCacheImpl` que la 116 no tiene) y f8dd41bd01f (ancla dentro de una capa *sticky* fusionada; corrección, no seguridad, depende de refactors de composición de 2025–26) |
| Diferencias conocidas con Chrome 131 | el lector de pantalla no anuncia la relación ancla–elemento (sin el
`aria-details` automático de 74a5382ac8b); `KeyboardFocusableScrollers` apagado (regla 20: Brave 1.73 lo baja a
`experimental`; decisión de COORDINACIÓN-8, 20-10), así que un recuadro con desplazamiento sin nada enfocable dentro no
recibe el foco con el tabulador, como antes de la 1.14; `getComputedStyle()` de un elemento anclado cuyo bloque
contenedor es un inline partido entre líneas da otros insets (WPT `anchor-getComputedStyle-002`; depende de refactors de
OOF que no se portaron) |
| WPT | `FlyWeb/tools/wpt-fm28-lista.txt` (405 sobre el árbol del 131: `css/css-anchor-position/`, `css/css-align/abspos/`, `html/semantics/popovers/` y 3 de `css/css-overflow/`). Con la F9: CfT 131 332 bien / 73 mal; FlyWeb 328 / 76 / 1 colgada (`popover-open-in-beforetoggle`, también en la 1.15.1). Del anchor: 3 peores (2 arregladas en la F11, 1 diferencia conocida) y 6 mejores; heredadas de la 1.15.1, 8 (`css-align/abspos/stretch-intrinsic-size-*` con `<canvas>` y 4 de popovers). Falta repetir con la F11 |
| Comprobación | `FlyWeb/tools/motor-131.html` con la sección «Anchor positioning (1.15.2)»: 13 comprobaciones automáticas (sintaxis que admite y rechaza la 131, CSSOM de `@position-try` y maquetación). En Chromium 141 salen bien todas menos la de lo no admitido: `anchor-size()` en márgenes e insets se publicó después de la 131. `motor-130.html` espera ahora `KeyboardFocusableScrollers` apagado |
| Pruebas a mano (LOCAL) | **FS.22:** un shader WebGL con `for(;;){}` sin `break` se rechaza al compilarlo; ventanas nuevas (`window.open`, `target=_blank`) y `<webview>` de extensiones. **`ScrollNodeForOverflowHidden`** (stable en la 131; da nodo de scroll a los `overflow: hidden` desplazados, ab59a973033): en páginas **sin** anchor, recuadros `overflow: hidden` desplazados por script (carruseles) y rendimiento al desplazar páginas largas, frente a la 1.15.1. Tanda de siempre (motor-117…131, claude.ai) |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12 del tablero.)*

- **Menús, avisos y tooltips en su sitio.** Las webs pueden pegar un menú desplegable, un aviso o una etiqueta al botón
  o al texto que lo abre. FlyWeb los coloca como Chrome 131, sin depender de bibliotecas de JavaScript.
- **Se recolocan solos.** Si un menú no cabe debajo de su botón, por ejemplo al final de la pantalla, la web puede
  pedir que se abra arriba o al lado, y FlyWeb elige el sitio donde cabe.
- **Siguen al desplazar.** Al desplazar la página o un recuadro, lo que va pegado a un elemento se mueve con él, y se
  puede ocultar cuando ese elemento deja de verse.
- **También en carruseles.** Lo que va pegado a un elemento sigue en su sitio aunque esté dentro de un carrusel o un
  panel que la web desplaza por su cuenta, sin barra de desplazamiento.
- **El tabulador, como en Brave.** Al recorrer una página con el tabulador, FlyWeb vuelve a saltarse los recuadros con
  desplazamiento que no tienen nada que pulsar dentro, como Brave (en la 1.14 y la 1.15 se paraba en ellos, como
  Chrome). Para desplazarlos con las flechas, basta hacer clic dentro.
- **Más compatible con las webs de hoy.** Muchas webs modernas, entre ellas editores, paneles de control y tiendas, ya
  usan esta función de CSS. Ahora se ven como en Chrome.

- **Más estable.** Arregla dos cierres de la pestaña que ya tenía la 1.15.1: en páginas que combinan ventanas de diálogo
  o menús emergentes con diseños que se adaptan al tamaño de su recuadro, y en páginas que cambian el texto de un aviso o
  una etiqueta flotante y consultan luego su posición.
- **Más seguro.** Lleva cuatro arreglos de seguridad graves de versiones posteriores de Chrome: tres en el dibujo con
  la tarjeta gráfica (WebGL) y uno en el aislamiento entre webs. Además, arregla un posible fallo de memoria en la
  maquetación con container queries.

Nada cambia en los ajustes ni en los datos del usuario, y el motor de JavaScript es el mismo que en la 1.15.
