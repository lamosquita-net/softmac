# FlyWeb 1.15 — nivel de motor 131 (MOTOR-11, 15-10-2026)

**Cabeza final:** brave-core `nube/motor-131` **057630a8c8** (`git ls-remote`), sobre la 1.14 (303e498fb5) +
`seg/ml-kem` fc0f45c433 (FS.17) + `seg/v8-13.1` 634cedc130 (FS.18, cerrada) + los arreglos de la 1.14
(`nube/arreglos-1.14` d12847a77f, fusión 391db5f63d) + el modo de petición de los recursos SVG externos (FS.19,
1419974606) + OOPSIF (`seg/oopsif` 57c1b3fa2a, FS.15: lo que lleva la 1.14.1 va en la 1.15) + P3A apagado de serie
(1cc62618e) + casilla de informes de diagnóstico desmarcada (bcc6c90f3) + `minimum_chrome_version` y las peticiones de extensiones a la Web Store con la versión declarada (3af48da54 y c1b778809, FM.24, opción A). Un solo nivel en una sola
versión, con la V8 de Chrome 131 (regla 18).

**Estado:** entregada a PUBLICACIÓN (LOCAL-5, 16-10, ~22:00): `nube/motor-131` 057630a8c8, build 25 (157.64.25), Release compilada desde cero. Revisión de la regla 17 (FS.19): colores relativos y cascada, bien; `SvgExternalResources` arreglado con el modo de petición de la 131 (1419974606, visto bueno de SEGURIDAD-PORTES-3, 15-10, ~20:44). Pruebas en FM.21 (Static y ASan en la 6,1, JA4 de ML-KEM como CfT 131, WPT de color completas). Detalle técnico:
`motor.md`, «Nivel 131», §11; commits: `FlyWeb/tools/port/nivel131-commits.tsv`.

| Dato | Valor |
|---|---|
| Cabeza final | brave-core `nube/motor-131` **057630a8c8** (arreglos de las WPT del 131 en 7da4ea17f, aff0f1574, 96346db73, f98054586 y 0fbbf9e77; fijadas compartidas en 6a3ea2695 y, al restaurar la sesión, en 057630a8c; `GPUAdapter.info` en e51076b41; P3A en 1cc62618e; casilla de diagnóstico en bcc6c90f3; extensiones en 3af48da54 y c1b778809; OOPSIF fundido en 55b9b4d9d2; FS.19 en 1419974606; declaración en 2f04e8614a; paso de V8 en `nube/motor-131-v8` 9b19e7dafc) |
| Versión visible | 1.15 (`CFBundleVersion` la pone LOCAL en la entrega) |
| Nivel declarado | Chrome 131 (`flyweb_engine_full_version` 131.0.6778.265; `platformVersion` mínimo **11.7.10**) |
| Motor JavaScript | V8 13.1.201.22 (cabeza de la rama 13.1, la de la 131.0.6778.265) con los arreglos de seguridad de FlyWeb (FS.18; época de caché **16**; 62 parches; d8: pruebas de FlyWeb 8/8, mjsunit 7279/7280, Wasm con `--stress-wasm-code-gc` 394/394). gin sin cambios |
| TLS y QUIC | intercambio poscuántico **X25519MLKEM768** en lugar de Kyber, como Chrome 131 (FS.17; interruptor `--disable-features=UseMLKEM`) |
| Portes del 131 | `::details-content` y `<details>` con cualquier `display`, con la cascada de ámbitos de sombra de la 131; colores relativos sobre `currentcolor` (y sobre colores de sistema, `light-dark()` y `color-mix()`); `@property` con `<string>`; recursos SVG de otro documento (`fill: url(otro.svg#id)`); 8 flags de interoperabilidad (búsqueda en la página, edición, `<embed>`/`<object>`, `initial-letter`, flotantes) |
| Aplazados del 130 | `getComputedStyle()` con `::placeholder`, `::file-selector-button` y `::details-content`; estilos de reserva de `<meter>`; `scrollIntoView()` suave en paralelo |
| Escapes de niveles anteriores | `customElements.getName()`, `preventDefault()` en `beforeunload`, `content-visibility: auto` con `contain-intrinsic-size: auto`, error con atributos de importación desconocidos, `SVGClipPathElement.transform`, selección con `mousemove` cancelado, `<input type=date>` *inline-block*, `lostpointercapture` al quitar el nodo, `inputType` `insertLink` y copiar sin `text-transform` |
| Fuera, con motivo | `PaintHighlightsForFirstLetter` (decisión de COORDINACIÓN-7: 25 *hunks* a mano en el pintado de selección; pasa a FM.22). Ninguna WPT depende de ello. `BreakIteratorHyphenMinus` y `TextTransformAndSecurityFix` no aplican a la 116 (confirmado por SEGURIDAD-PORTES-3, FS.18) |
| Diferencias conocidas con Chrome 131 | las de la 1.14 (sin Web Share; Brave quita `navigator.connection`, File System Access y Web Serial), las marcas de buscar/ortografía en la letra de `::first-letter` y, en las WPT, `css-color/lab-004` y `lch-004` (1/255 al pintar) y `oklab-005` (pasa aquí y falla en CfT 131). `scrollIntoView-smooth` la falla CfT |
| Fuera del motor | **P3A:** no enviaba nada (sin servicio con `brave_p3a_enabled=false`), pero la preferencia seguía encendida y salía su barra en un perfil nuevo; ahora va apagada de serie, sin interruptor en Ajustes ni casilla en la bienvenida. **Informes de diagnóstico:** tampoco enviaban nada (UMA bloqueado por Brave; informes de fallos sin URL de subida); la casilla de la bienvenida sale ahora desmarcada. **Extensiones:** `minimum_chrome_version` y el `prodversionmin` de la Web Store se comparan con la versión declarada (131.0.6778.265), no con la 116 (`FlyWeb/docs/extensiones.md`, opción A), y las peticiones de extensiones a la Web Store envían esa versión: con `prodversion` 116 la tienda no servía el CRX y la instalación acababa en «Se canceló la descarga». Los componentes siguen enviando 116.0.5845.188 |
| Escapes que destaparon las WPT del 131 | `GPUAdapter.info` (127); `@property` (120): reglas incompletas descartadas, `<image>`/transformaciones en `syntax`, listas y `<resolution>`; LinkText, VisitedText y Highlight según `color-scheme` (125–131); especificidad de etiqueta para los pseudoelementos (128); `currentColor` en `light-dark()`; tono «none» en colores sin croma (121/125); `rgb()` sin redondear a enteros (120) |
| Comprobación | `FlyWeb/tools/motor-131.html` (en un origen http(s); comprobada en Chromium 141: solo fallan la versión y lo que sale después del 131), `wpt-131-lista.txt` (43 entradas, con `css/css-color/` entero, `html/rendering/the-details-element/` y `the-meter-element/`) |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12 del tablero.)*

- **Motor al nivel de Chrome 131**, con el motor de JavaScript de Chrome 131. Las webs ven FlyWeb como Chrome 131, y lo
  es en lo que usan.
- **Conexiones seguras preparadas para el futuro.** FlyWeb cifra las conexiones con el método poscuántico estándar
  (ML-KEM), el mismo que Chrome 131, pensado para que lo que se envía hoy no se pueda descifrar mañana con ordenadores
  cuánticos.
- **Secciones desplegables con más estilo.** Las secciones que se abren y cierran (`<details>`) se pueden diseñar como
  cualquier otro bloque, como en Chrome, Safari y Firefox.
- **Colores que siguen al texto.** Las webs pueden calcular un color a partir del color del texto (por ejemplo, una
  versión más clara para el fondo), también con modo oscuro, como en Chrome, Safari y Firefox.
- **Medidores visibles.** Las barras de nivel (`<meter>`) con estilo propio de la web ya no desaparecen.
- **Desplazamientos suaves más rápidos.** Cuando una web lleva la vista hasta un elemento dentro de varias zonas con
  desplazamiento, se mueven todas a la vez y no una detrás de otra.
- **Pequeños arreglos de compatibilidad:**
  - Al copiar texto que la web muestra en mayúsculas, se pega como está escrito de verdad.
  - Seleccionar texto con el ratón funciona también en webs que interceptan el movimiento del ratón.
  - Los campos de fecha ocupan su sitio en la línea como en los demás navegadores.
  - Las webs que piden confirmar antes de salir lo hacen igual que en Chrome.
  - Las imágenes SVG pueden usar degradados y recortes de otro archivo, como en Firefox y Safari.
- **Más extensiones de la Chrome Web Store.** Las extensiones que piden una versión de Chrome reciente (hasta la 131) ya
  se instalan, por ejemplo Ghostery o KeePassXC-Browser. Algunas todavía no, como uBlock Origin Lite (necesita más
  reglas de bloqueo de las que admite FlyWeb) o Bitwarden (pide Chrome 134).
- **Pestañas fijadas más fiables.** Las pestañas fijadas, que se comparten entre todas las ventanas, ya no cierran el
  navegador al cambiar de ventana ni salen repetidas al volver a abrir FlyWeb con varias ventanas.
- **Sin la pregunta de las estadísticas de uso.** FlyWeb no envía estadísticas de uso; en un perfil nuevo ya no aparece
  la barra que preguntaba por ellas.
- **Nada cambia** en los ajustes ni en los datos del usuario. La primera vez que se abra una web pesada puede tardar un
  poco más (el motor de JavaScript nuevo vuelve a preparar su caché).

## WPT del nivel 131

Hechas por LOCAL-4 (16-10) con el Static de c1b778809c en la 6,1: lista `FlyWeb/tools/wpt-131-lista.txt` (294 pruebas, con `css/css-color/` entero) frente a Chrome for Testing 131 en el mismo Mac. **De 28 diferencias a 4** tras los pasos A (aff0f15742) y B (0fbbf9e775). Las 4 que quedan, aceptadas por COORDINACIÓN-7: `css-color/lab-004` y `lch-004` (1/255 en un canal, en el pintado), `oklab-005` (pasa aquí y falla en CfT 131) y `scrollIntoView-smooth` (la falla CfT). Excepciones escritas: ninguna por `PaintHighlightsForFirstLetter`; su única prueba es la interna de Blink `paint/markers/first-letter.html`, que no es WPT. Resultados en la rama de softmac `local/wpt-131`.
