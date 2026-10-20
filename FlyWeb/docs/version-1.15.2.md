# FlyWeb 1.15.2 — anchor positioning del nivel 131 (FM.28, MOTOR-13, 20-10-2026)

**Estado:** en código, con visto bueno de seguridad (SEGURIDAD-PORTES-3, FS.21, regla 17). brave-core
`nube/motor-131-anchor` sobre la 1.15.1 (fa4fae392f). Compilaciones de prueba de LOCAL-5 (Static, `-k 0`): la primera
(F2, 38097e9ea2) dio 14 errores en 3 cabeceras; la segunda (porte entero, 5312cb22da), 40 en 17 ficheros. Están todos
arreglados en **767c49475b** (rama fija `nube/motor-131-anchor-f5`), que es la que falta compilar: navegador +
`blink_unittests`. Desde la tarde del 20-10 la nube no puede escribir a LOCAL, así que Titín le pasa el sha en
persona. El 21-10 la 7,1 compila Chromium 128 (FM.31), y la Release y la publicación esperan a que acabe. Falta: los
errores de esa Static, si hay; las pruebas a mano de LOCAL; las WPT, y la versión (`flyweb_version` 1.15.2). Detalle
técnico: fila FM.28 de `docs/TAREAS.md`; criba de la cadena en `FlyWeb/tools/port/anchor-clas.tsv`.

| Dato | Valor |
|---|---|
| Cabeza | brave-core `nube/motor-131-anchor`: F1 0f9820c4 (2023, sintaxis vieja), F2 4efeaf5685 + 38097e9ea2 (enero–abril de 2024, hasta «Ship the anchor positioning API»), F3+F4 848c954d (mayo–octubre de 2024, hasta la rama de la 131, con los arreglos de FS.21), arreglos de la primera Static 5312cb22da, pruebas unitarias de la 131 6266cb55, `StyleAnchorScope` con
`WeakPersistent` y `KeyboardFocusableScrollers` apagado a35b831b, FS.22 fundida 2fba9e43 y arreglos de la segunda Static
**767c49475b** (`nube/motor-131-anchor-f5`) |
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
CVE-2023-5218 |
| Fuera, con motivo | `anchor-size()` en insets y márgenes (experimental en la 131), el atributo `anchor` y la relación implícita con quien abre un popover (flags no activados en la 131), `<select>`/`selectlist` personalizables (fuera del alcance), la relación `aria-details` de accesibilidad entre el ancla y el elemento anclado (74a5382ac8b; necesita el mecanismo `TreeUpdateReason` de `AXObjectCacheImpl` que la 116 no tiene) y f8dd41bd01f (ancla dentro de una capa *sticky* fusionada; corrección, no seguridad, depende de refactors de composición de 2025–26) |
| Diferencias conocidas con Chrome 131 | el lector de pantalla no anuncia la relación ancla–elemento (sin el
`aria-details` automático de 74a5382ac8b); `KeyboardFocusableScrollers` apagado (regla 20: Brave 1.73 lo baja a
`experimental`; decisión de COORDINACIÓN-8, 20-10), así que un recuadro con desplazamiento sin nada enfocable dentro no
recibe el foco con el tabulador, como antes de la 1.14; las demás, cuando estén las WPT |
| WPT | `FlyWeb/tools/wpt-fm28-lista.txt`: `css/css-anchor-position/` (306 pruebas en la 131), `css/css-align/abspos/`, `html/semantics/popovers/` y 3 de `css/css-overflow/` (nodos de scroll para `overflow: hidden`). Pendiente (LOCAL) |
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

- **Más seguro.** Lleva cuatro arreglos de seguridad graves de versiones posteriores de Chrome: tres en el dibujo con
  la tarjeta gráfica (WebGL) y uno en el aislamiento entre webs.

Nada cambia en los ajustes ni en los datos del usuario, y el motor de JavaScript es el mismo que en la 1.15.
