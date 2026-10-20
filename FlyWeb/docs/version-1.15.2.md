# FlyWeb 1.15.2 — anchor positioning del nivel 131 (FM.28, MOTOR-13, 20-10-2026)

**Estado:** en código. brave-core `nube/motor-131-anchor` sobre la 1.15.1 (fa4fae392f). Compilaciones de prueba de
LOCAL-5: la primera Static (F2, 38097e9ea2) dio 14 errores en 3 cabeceras, ya arreglados. Ahora compila la segunda, con
el porte entero (5312cb22da, rama fija `nube/motor-131-anchor-f4`). Falta: los errores que salgan de ella, la revisión
de SEGURIDAD-PORTES-3 (FS.21, regla 17), las WPT y la versión (`flyweb_version` 1.15.2). Detalle técnico: fila FM.28 de
`docs/TAREAS.md`; criba de la cadena en `FlyWeb/tools/port/anchor-clas.tsv`.

| Dato | Valor |
|---|---|
| Cabeza | brave-core `nube/motor-131-anchor`: F1 0f9820c4 (2023, sintaxis vieja), F2 4efeaf5685 + 38097e9ea2 (enero–abril de 2024, hasta «Ship the anchor positioning API»), F3+F4 848c954d (mayo–octubre de 2024, hasta la rama de la 131, con los arreglos de FS.21), arreglos de la primera Static 5312cb22da y pruebas unitarias de la 131 6266cb55 |
| Versión visible / `CFBundleVersion` | 1.15.2 / 157.64.N (`FLYWEB_BUILD_NUMBER` lo pone LOCAL en la entrega) |
| Nivel declarado | Chrome 131, sin cambios (131.0.6778.265) |
| Motor JavaScript | el de la 1.15: V8 13.1.201.22 con los arreglos de FlyWeb (`patches/v8` igual) |
| Lo nuevo | **Anchor positioning de Chrome 131**, unos 230 commits de upstream: `anchor-name`, `position-anchor`, `anchor()` y `anchor-size()` (con el ancla y el lado en cualquier orden, `inside`/`outside` y `anchor-size()` sin argumento), `position-area`, `position-try-fallbacks`, `position-try-order` y `position-try`, la regla `@position-try` con `CSSPositionTryRule` y `CSSPositionTryDescriptors`, `position-visibility` (`anchors-visible`, `no-overflow`, anclas encadenadas), `anchor-scope` (con `all` por ámbito), `align-self`/`justify-self: anchor-center` con el comportamiento nuevo, la alineación segura por defecto de los elementos absolutos, el último *fallback* que funcionó, el ajuste al desplazar el ancla (también dentro de `overflow: hidden` desplazado) y la parte del inspector (ancla de un elemento, regla `@position-try` activa) |
| Adaptaciones a la 116 | analizadores con `CSSParserTokenRange`; `ComputedStyle` contado por referencias (`StyleAnchorScope` con miembros `Persistent`); sobrecargas de `ResolvedAlignSelf`/`ResolvedJustifySelf` con `ItemPosition` para el código de la 116; la ruta de la 116 de `IntersectionObserver` y de la unificación de scroll; el flag `CSSAnchorPositioning` se queda en `stable` (upstream lo quitó) para el código de la 116 que lo consulta; el atributo `anchor` solo con `HTMLAnchorAttribute` (experimental, como en la 131) |
| Seguridad (FS.21) | arreglos de upstream posteriores a la 131 incluidos: 07dfbede6f2 (caída con `@position-try` y `display: none`), 9d2cba3f6cf (estilo nulo en `IsScopedByElement`), 31adde08d12 y 05730fe4c1c (observador de visibilidad del ancla), d3bdf5fec59 (recursión en `AnchorPositionOffset` de cc). Revisión de SEGURIDAD-PORTES-3 pendiente |
| Fuera, con motivo | `anchor-size()` en insets y márgenes (experimental en la 131), el atributo `anchor` y la relación implícita con quien abre un popover (flags no activados en la 131), `<select>`/`selectlist` personalizables (fuera del alcance), la relación `aria-details` de accesibilidad entre el ancla y el elemento anclado (74a5382ac8b; necesita el mecanismo `TreeUpdateReason` de `AXObjectCacheImpl` que la 116 no tiene) y f8dd41bd01f (ancla dentro de una capa *sticky* fusionada; corrección, no seguridad, depende de refactors de composición de 2025–26) |
| Diferencias conocidas con Chrome 131 | sin `aria-details` automático entre el ancla y el elemento anclado (los lectores de pantalla no anuncian esa relación); las demás, cuando estén las WPT |
| WPT | `FlyWeb/tools/wpt-fm28-lista.txt`: `css/css-anchor-position/` (306 pruebas en la 131), `css/css-align/abspos/`, `html/semantics/popovers/` y 3 de `css/css-overflow/` (nodos de scroll para `overflow: hidden`). Pendiente (LOCAL) |
| Comprobación | `FlyWeb/tools/motor-131.html` con la sección «Anchor positioning (1.15.2)»: 13 comprobaciones automáticas (sintaxis que admite y rechaza la 131, CSSOM de `@position-try` y maquetación). En Chromium 141 salen bien todas menos la de lo no admitido: `anchor-size()` en márgenes e insets se publicó después de la 131 |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12 del tablero.)*

- **Menús, avisos y tooltips en su sitio.** Las webs pueden pegar un menú desplegable, un aviso o una etiqueta al botón
  o al texto que lo abre. FlyWeb los coloca como Chrome 131, sin depender de bibliotecas de JavaScript.
- **Se recolocan solos.** Si un menú no cabe debajo de su botón, por ejemplo al final de la pantalla, la web puede
  pedir que se abra arriba o al lado, y FlyWeb elige el sitio donde cabe.
- **Siguen al desplazar.** Al desplazar la página o un recuadro, lo que va pegado a un elemento se mueve con él, y se
  puede ocultar cuando ese elemento deja de verse.
- **Más compatible con las webs de hoy.** Muchas webs modernas, entre ellas editores, paneles de control y tiendas, ya
  usan esta función de CSS. Ahora se ven como en Chrome.

Nada cambia en los ajustes ni en los datos del usuario, y el motor de JavaScript es el mismo que en la 1.15.
