# FlyWeb 1.12 — nivel de motor 128 (MOTOR-7, 13-10-2026)

**Estado:** en brave-core `nube/motor-128` **710e7520**. Lleva la 1.11.2 (`seg/v8-12.8` 5aa57049f: V8 12.8 con los
arreglos de seguridad, época de caché 12, y la huella de red de la 1.11.1) más los portes del nivel 128, y declara
128 / 1.12. LOCAL-2 hizo el Static: 0 errores, `motor-128` 9/9, webs con JIT 8/8 con YouTube, `motor-gc` 20/20, perfil
1.11.1 → 1.12 bien y WPT del 128 iguales a Chrome 128 (lista abajo). Faltan el ASan (en marcha), la Release (build 19)
y la entrega a PUBLICACIÓN en la fila FM.16 (regla 11). RubyLB (`ruby-align` y el nuevo ruby) no va aquí: sale en la
1.12.1. Detalle técnico: `motor.md`, «Nivel 128».

| Dato | Valor |
|---|---|
| Versión visible | 1.12 (`CFBundleVersion` la pone LOCAL en la entrega) |
| Nivel declarado | Chrome 128 (`flyweb_engine_full_version` 128.0.6613.138; `platformVersion` mínimo 10.15.7, sin cambios) |
| Motor JavaScript | el de la 1.11.2: V8 12.8.374.38 con los arreglos de seguridad de FlyWeb (época de caché 12, sin cambios) |
| Portes del 128 | `caretPositionFromPoint()`, `currentCSSZoom`, `aria-colindextext`/`aria-rowindextext` (solo en el árbol de accesibilidad, sin puente a macOS, como upstream) y 6 flags de interoperabilidad |
| Fuera, con motivo | 6 flags de edición, foco, decoración de texto y animaciones que dependen de código posterior a la 116 (`motor.md`) |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12 del tablero.)*

- **Motor al nivel de Chrome 128.** Las webs ven FlyWeb como Chrome 128, y lo es en lo que usan.
- **Colocar el cursor donde se pulsa o se suelta.** Las webs pueden saber en qué punto exacto del texto se ha hecho
  clic o se ha soltado algo arrastrado, con el método estándar que ya usaba Firefox (`caretPositionFromPoint`), también
  dentro de campos de texto y de componentes web. Sirve, por ejemplo, a los editores de texto y a las webs que permiten
  arrastrar texto.
- **Webs ampliadas mejor colocadas.** Las webs pueden saber cuánto zoom tiene cada parte de la página
  (`currentCSSZoom`), lo que les ayuda a colocar bien menús y ventanas emergentes cuando han ampliado solo una zona.
- **Nombres de filas y columnas para la accesibilidad.** Las webs pueden dar nombre propio a las filas y columnas de sus
  tablas y hojas de cálculo (por ejemplo «columna B» en vez de «columna 2»), como en Chrome 128. En Mac, VoiceOver
  todavía no lo lee, tampoco en Chrome.
- **Listas desplegables sin acentos.** Al escribir sobre una lista desplegable para saltar a una opción ya no hace falta
  poner los acentos: «avila» lleva a «Ávila».
- **Pequeños arreglos de compatibilidad:**
  - En los editores de las webs, mover el cursor por párrafos ya no se atasca en partes que no se pueden editar.
  - La sección a la que lleva un enlace interno (`#…`) sigue marcada aunque la web la vuelva a colocar.
  - Los degradados de los gráficos SVG que lo piden se pintan con la mezcla de color que eligió quien los diseñó.
  - Las listas hechas con `<menu>` se numeran como las demás listas.
  - Una caída en páginas con texto en varias columnas, arreglada.
- **Lo mismo que la 1.11.2 en JavaScript y en red:** el motor de JavaScript de Chrome 128 con sus arreglos de
  seguridad, y las webs protegidas contra bots se siguen abriendo directamente.
- **Lo que llega en la 1.12.1:** el texto con anotaciones *ruby* (la pronunciación encima de los caracteres en japonés y
  chino) con el sistema nuevo de Chrome, incluida su alineación (`ruby-align`).

Nada cambia en los ajustes ni en los datos del usuario.

## WPT del nivel 128 (Static de LOCAL-2, 13-10, etiqueta 128.0.6613.138)

| Prueba | FlyWeb 1.12 | Chrome 128 |
|---|---|---|
| `currentCSSZoom` | 2/2 | igual |
| `caretPositionFromPoint` (y con transformación) | 5/5 y 1/1 | igual |
| `AriaMixin-string-attributes` | 88/88 | igual |
| `aria-attribute-reflection` | 44/44 | igual |
| `ElementInternals-accessibility` | 45/53 | igual con lo experimental apagado: los 8 `aria*Element(s)` son `AOMAriaRelationshipProperties`, `experimental` en la 128 |
| `shadow-dom/Document-caretPositionFromPoint.tentative` | 12/13 | entorno: el subtest del `textarea` da 6 en vez de 4 también en Chrome 155 en el mismo Mac (barras de desplazamiento superpuestas de macOS) |
| `cssom-view/idlharness` | 0/1 | entorno: falta `WebIDLParser.js`, como en niveles anteriores |
