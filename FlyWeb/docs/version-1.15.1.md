# FlyWeb 1.15.1 — nivel 131 con los escapes de los niveles 117–131 (FM.22, MOTOR-11 y MOTOR-12, 20-10-2026)

**Estado:** en brave-core `nube/motor-131-escapes` **fa4fae392f** = FM.22 entero (**9b35099024**, compilado y probado por
LOCAL-5: Static, ASan, tanda, superficie, WPT de A+B y de la D, pruebas a mano y ASan corto con Titín, todo limpio) +
`flyweb_version` 1.15.1. Sobre la 1.15 (057630a8c8). LOCAL la compila con el siguiente `FLYWEB_BUILD_NUMBER` (la 1.15 fue
la 25) y la entrega a PUBLICACIÓN (regla 11). Detalle técnico: fila FM.22 de `docs/TAREAS.md`; decisión y commit por flag
en `FlyWeb/tools/port/fm22-escapes.tsv`.

| Dato | Valor |
|---|---|
| Cabeza final | brave-core `nube/motor-131-escapes` **fa4fae392f** (versión); FM.22 en 9b35099024. Tanda A en 7ae04c9456, B en c30a6a9c2d, C en 4ea0170cd0 (con `PaintHighlightsForFirstLetter`), D de 0cb2fbdd1f a b18a2fbe0e; arreglos de compilación 546e638220/bf66b41dcb (include de `TextControlElement`), 1b90404f88 (`absl::optional` en `FilterOperation`) y 9b35099024 (`gfx::RectF` en `VideoFrame`) |
| Versión visible / `CFBundleVersion` | 1.15.1 / 157.64.N (`FLYWEB_BUILD_NUMBER` lo pone LOCAL en la entrega) |
| Nivel declarado | Chrome 131, sin cambios (131.0.6778.265; `platformVersion` mínimo 11.7.10) |
| Motor JavaScript | el de la 1.15: V8 13.1.201.22 con los arreglos de seguridad de FlyWeb (época de caché 16, sin cambios; `patches/v8` igual) |
| Lo nuevo | **101 escapes**: funciones que Chrome tuvo de serie en algún nivel 117–131 y que no habían llegado a FlyWeb. **A** (7): seguridad y lo que tienen los tres motores (`<a>.href` con URL inválida, escritura de HTML bien formado y SVG sin referencias externas al pegar, sin color de acento del sistema, `background-clip` sin prefijo, `dirname`, `<hr>` en `<select>`). **B** (46): DOM y HTML, eventos, portapapeles, XML, URL, WebIDL y edición (listas, citas, saltos de línea, borrado, `inert`, `dir`/`lang` heredados, foco). **C** (27): layout, pintado y CSS (`resize: auto`, primera letra, `text-align-last`, `backface-visibility`, filtros, paletas de fuentes animadas, `context-paint` en SVG, marcas de buscar/ortografía en `::first-letter`). **D** (21): lo que solo tiene Chrome (`sizes=auto`, `showPicker()` en `<select>`, `scrollend` en `visualViewport`, `persistentDeviceId`, `prefers-reduced-transparency` con el ajuste de macOS, Media Session con capítulos, `skipad` y `enterpictureinpicture`, `monitorTypeSurfaces`, WebCodecs con `contentHint`, copia a RGB y formatos de 10/12 bits, `drawingBufferStorage` de WebGL, `writingsuggestions`, informes de Permissions Policy, `unload` en Permissions Policy, `deliveryType`, control de extensiones de cabecera RTP, HDR en `mediaCapabilities`, alias `window-placement`, SVG en el portapapeles) |
| Seguridad y privacidad | revisadas por SEGURIDAD-PORTES-3 (regla 17): A y B enteras (incluidas WebAuthn en iframes de otro origen y el permiso implícito del portapapeles); de la D le pasó COORDINACIÓN-7 ClipboardSvg, MonitorTypeSurfaces (ruta de permisos de captura), MediaSessionChapterInformation (datos del renderer al navegador, saneados) y WebCodecsHBDFormats. **`:visited` con `context-paint`:** el alfa se fuerza como en upstream bb0351bff33 (233ad89d5e / 7fde3677af); LOCAL-5 comprobó que no hay fuga del historial (CfT 131 sí la tiene). **JS Self-Profiling apagado** (a9733521ba, decisión de Titín, regla 20): sin la interfaz `Profiler`, como el Brave actual |
| Fuera, con motivo (TSV) | **por privacidad** (11, confirmadas por SEGURIDAD-PORTES-3): Compute Pressure (canal encubierto y huella), Storage Access (2; Brave bloquea las cookies de terceros), leer HTML sin sanear del portapapeles y 7 de reglas de especulación (Brave apaga Prerender2); **lo que Brave apaga** (27: Privacy Sandbox, FedCM, File System Access, Web Serial); **no aplica** (63: internas, de rendimiento o que Chrome volvió a apagar); **aplazadas** (26), entre ellas 13 que se proponen como porte propio: StorageBuckets, BackForwardCacheNotRestoredReasons, los 3 eventos de *scroll snap*, DocumentPictureInPictureUserActivation, LongAnimationFrameTiming, SecurePaymentConfirmationExtensions, CSSTextSpacingTrim, CSSPhraseLineBreak, RTCRtpEncodingParametersCodec, LayoutBlockButton y LayoutBaselineFix. Anchor positioning y view transitions entre documentos van en la 1.15.2 y la 1.15.3 |
| Diferencias conocidas con Chrome 131 | las de la 1.15; **`Profiler` no existe** (JS Self-Profiling apagado: 3 pruebas de `js-self-profiling/` que pasaban en la 1.15 fallan); 3 subpruebas de `url/a-element-origin` («`<x>`/`<#x>`/`<?x>` against `<sc://ñ>`») dan `""` en vez de `"null"`, como Chrome 117–129, hasta FM.23 (analizador de esquemas no especiales completo; el arreglo parcial 9c335e9c44 se revirtió por decisión de COORDINACIÓN-7 con SEGURIDAD-PORTES-3); el «I444AP10» de WebCodecs se convierte como 4:4:4 (la 131 lo trata como 4:2:2, un error de upstream) |
| WPT (LOCAL-5, frente a CfT 131 en la 6,1 y con la 1.15 en la 7,1) | `wpt-fm22-ab-lista.txt` (903): 25 peor que CfT, de ellas 15 del entorno de la 6,1, 7 heredadas, 2 que mejoran (`dir-assorted` 38→40, `url/a-element` 461→597) y la de `url/a-element-origin`. `wpt-fm22-d-lista.txt` (108): 9 peor que CfT, de ellas 5 heredadas, 1 que mejora (`videoFrame-construction` 35→46) y las 3 de `js-self-profiling`. A mano: `drawingBufferStorage` bien y `getDisplayMedia` con `monitorTypeSurfaces: "exclude"` sin pantallas enteras (Titín) |
| Comprobación | motor-117…131, fastapi-129, seg-1.14.1, js-seg, claude.ai y YouTube idénticos a la 1.15; superficie = 1.15 + lo esperado de FM.22 − `Profiler` |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12 del tablero.)*

- **Más compatible con las webs de hoy.** FlyWeb incorpora un centenar de funciones y arreglos que Chrome fue añadiendo
  entre sus versiones 117 y 131, para que las webs funcionen como en Chrome 131.
- **Escribir y editar texto, mejor.** Las listas, las citas, los saltos de línea, borrar y pegar en editores de texto
  web (correo, documentos, foros) se comportan como en Chrome.
- **Imágenes más ligeras.** Las webs que cargan sus imágenes a medida que se desplaza la página pueden pedir solo el
  tamaño que de verdad se ve, y la página gasta menos datos.
- **Compartir solo lo que quieres.** Una web de videollamadas puede pedir que solo se ofrezca compartir una pestaña o una
  ventana, nunca la pantalla entera.
- **Vídeo en el navegador.** Los editores de vídeo y las videollamadas en la web admiten más formatos (vídeo de 10 y 12
  bits) y pueden codificar mejor el contenido de una pantalla (texto y detalles finos).
- **Respeta «Reducir transparencia».** Si está activada en las preferencias de accesibilidad del Mac, las webs que lo
  tienen en cuenta también la reducen.
- **Más privacidad:**
  - Las webs ya no pueden medir con detalle cómo se ejecuta su JavaScript en el ordenador (lo mismo hace Brave).
  - Un truco con iconos SVG que en Chrome 131 deja a una web saber si has visitado otra no funciona en FlyWeb.
  - Copiar y pegar HTML y SVG entre webs es más seguro.

Nada cambia en los ajustes ni en los datos del usuario, y el motor de JavaScript es el mismo que en la 1.15.
