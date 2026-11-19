# 3.2.0: interfaz del diseño de Titín

MOTOR-46, desde el 19-11, por encargo de COORDINACIÓN-51. Diseño: `FlyWeb/branding/interfaz-3.2.0/` (#1107).
**Sin compilar** (la nube no tiene el checkout de Chromium). Destino: 3.2.0.

Base: brave-core `local/3.1.4` (`e660929ac9`); Chromium de referencia `local/314` (`e9b670773e`). Un parche por hito,
para que LOCAL pruebe cada uno en la 6,1. Se aplican en orden. Árbol tras el 0001: `0ab5d2c1f8`; tras el 0003: `4e7ece5536`; tras el 0004: `47543553c4`.

| Parche | Hito | Qué hace |
|---|---|---|
| `0001-FlyWeb-3.2.0-interface-frame-toolbar-active-tab-and-.patch` | H1 colores | `browser/ui/color/color_palette.h`, `brave_color_mixer.cc` y su test |
| `0002-FlyWeb-3.2.0-interface-tab-shape-with-smaller-top-ra.patch` | H2 pestañas | Dos ganchos en `patches/` y sus `chromium_src` (`tab_style.cc`, `horizontal_tab_style_views.cc`) |
| `0003-FlyWeb-3.2.0-interface-soft-inner-glow-instead-of-th.patch` | H3 foco de la URL | `browser/ui/views/location_bar/brave_location_bar_view.{h,cc}` y un test de navegador |
| `0004-FlyWeb-3.2.0-interface-Titin-s-answers-on-icon-text-an.patch` | H1, respuestas de Titín | Iconos, texto de las pestañas, ventana sin foco y carpetas (`brave_color_mixer.cc` y su test) |

Pendiente: H4 iconos.

## H1: colores

| Elemento | Claro | Oscuro | Id de color |
|---|---|---|---|
| Pestaña activa y barra de iconos y URL | `#F4F5F6` | `#656666` | `kColorToolbar`; `kColorTabBackgroundActiveFrameActive` = `kColorToolbar` |
| Barra de las pestañas inactivas (marco) | `#E3E3E2` | `#4D4D4C` | `ui::kColorFrameActive` y `ui::kColorFrameInactive` |
| Fondo de la URL | `#FFFFFF` | `#FFFFFF` | `kColorToolbarBackgroundSubtleEmphasis` → `kColorLocationBarBackground` |

Las constantes están en `color_palette.h`:
- `kLightFrame` y `kDarkFrame` (ya existían; ahora con los valores de Titín).
- `kFlyWebLightToolbar`, `kFlyWebDarkToolbar` y `kFlyWebLocationBarBackground`.
- `kFlyWebLightOmniboxInDarkMode` y `kFlyWebOmniboxSelectionOnLight`.

### URL blanca en modo oscuro

Chromium 156 pinta la URL con foco con el fondo del desplegable de sugerencias (`location_bar_view.cc`: si el cursor está
visible, `kColorOmniboxResultsBackground`). Además, el texto de la URL y el del desplegable usan los mismos ids. Por eso,
con la URL blanca, **el desplegable también es blanco con texto oscuro en modo oscuro**. Se elige con
`kFlyWebLightOmniboxInDarkMode`:
- `true` (por defecto): URL y desplegable blancos.
- `false`: la omnibox oscura de Brave.

COORDINACIÓN-51 le pasa la decisión a Titín.

En modo oscuro, los colores CR2023 de la omnibox salen de los tokens `ui::kColorSys*` del modo oscuro, pensados para un
campo oscuro. Aquí se sustituyen por las recetas de contraste del propio Chromium (las de `omnibox_color_mixer.cc` para
temas personalizados): texto atenuado, iconos, chips, selección y aviso de seguridad. Así siguen al fondo blanco.

### Respuestas de Titín (19-11), parche 0004

| Qué | Claro | Oscuro | Cómo |
|---|---|---|---|
| Iconos de la barra | `#656666` | `#EDEEF1` | `kColorToolbarButtonIcon` |
| Texto de la pestaña activa | `#000000` | `#FFFFFF` | `kColorTabForegroundActive*` |
| Texto de las pestañas inactivas | negro al 50 % | blanco al 50 % | Mezclado sobre el color de la barra de pestañas: da un color opaco, que es lo que espera el código de pestañas de Chromium. El resultado se ve igual. |
| Ventana sin foco | marco atenuado | marco atenuado | La receta de Chromium para la cabecera inactiva (`ui/color/sys_color_mixer.cc`), aplicada a los colores de Titín: `AlphaBlend(marco, kColorRefNeutral98, 0x48)` en claro y `AlphaBlend(marco, kColorRefNeutral25, 0x99)` en oscuro |
| Carpetas de marcadores | plano, color de los iconos | ídem | `kColorBookmarkFolderIcon` = `kColorToolbarButtonIcon` |

- **URL y desplegable en modo oscuro**: blancos con texto oscuro (confirmado).
- **Ventanas privadas y de Tor**: sin tocar. Titín las diseña aparte. El texto de las pestañas va en un mezclador que solo
  corre en las ventanas normales. Las privadas tienen su propio proveedor de tema, que sigue mandando.
- **Borde de la URL**: no lleva. **Línea bajo los marcadores**: se mantiene.
- **Texto de la barra de marcadores**: sigue al texto de la pestaña activa, como en Brave (negro en claro, blanco en
  oscuro).

### Lo que no cambia

- **Ventanas privadas y de Tor**: conservan los colores de Brave. Usan un proveedor de tema propio
  (`BravePrivateWindowThemeSupplier`, un tema personalizado), así que los mezcladores de FlyWeb, que salen antes con
  `key.custom_theme`, no les afectan. Se comprueba en el paso 5 de la prueba.

## Prueba de H1 (LOCAL, 6,1 en pantalla 1x y una Retina)

1. `brave_unit_tests --gtest_filter='BraveColorMixersTest.*'`: deben pasar los tres tests.
2. `brave_browser_tests --gtest_filter='BraveThemeServiceTest.*'`: deben pasar sin cambios.
3. A ojo, en claro y en oscuro:
   - La pestaña activa y la barra son del mismo color, sin línea entre ellas.
   - La barra de las pestañas inactivas lleva el color del marco.
   - La URL es blanca.
4. En modo oscuro:
   - Pulsar la URL: sigue blanca.
   - Escribir: el desplegable sale blanco y el texto, los iconos de las sugerencias, la sugerencia seleccionada y el
     texto seleccionado se leen bien.
   - Abrir `http://` y una página con certificado inválido: se ven el icono del candado y el aviso de seguridad.
5. Una ventana privada y una de Tor: el mismo aspecto que en la 3.1.4.
6. Con el 0004:
   - Iconos de la barra en `#656666` (claro) y `#EDEEF1` (oscuro).
   - Texto de la pestaña activa negro o blanco, y el de las inactivas al 50 %.
   - Carpetas de marcadores en color plano.
   - Pasar a otra app: el marco de la ventana sin foco se ve algo más apagado y el texto de las pestañas sigue
     legible.

## H2: forma de las pestañas

| Qué | Valor | Dónde se cambia |
|---|---|---|
| Radio superior | **3 dip** (Chromium: 10) | `BRAVE_TAB_STYLE_TOP_CORNER_RADIUS`, en `chromium_src/chrome/browser/ui/tabs/tab_style.cc` |
| Curvas de la base (unión con la barra) | **0 dip**: unión recta | `kFlyWebTabBottomCornerRadius`, en `chromium_src/chrome/browser/ui/views/tabs/common/horizontal_tab_style_views.cc` |

- **El radio superior** sale de la maqueta en proporción al alto. La pestaña mide unos 16 px en la maqueta y 34 dip en
  Chromium, y la esquina se resuelve en 1–1,5 px: unos 3 dip, entre 2 y 4. Se ajusta en las pruebas con Titín.
  `TabStyle::GetTopCornerRadius()` la usan la forma de la pestaña, el resaltado al pasar el ratón y el anillo de foco,
  así que todos siguen el mismo radio.
- **El tamaño no cambia.** En Chromium, `TabStyle::GetBottomCornerRadius()` (12) también fija el ancho de la pestaña y
  el solape entre pestañas. Por eso no se toca: solo se deja de dibujar la curva de la base (`GetPath()`), y se conservan
  el ancho y la posición.
- **Pestañas inactivas sin fondo y con separador**: ya es así en Chromium; no se toca.
- **Sin contorno**: en macOS, `BrowserView::ShouldDrawTabStrokes()` solo dibuja contorno con un tema del sistema distinto
  del de por defecto, que en Mac no existe. Además, el contraste pestaña/marco (1,18 en claro y 1,47 en oscuro) solo
  importaría con ese tema.
- **Pestañas fijadas con el estilo nuevo** (`IsNewHorizontalPinnedTabStylingEnabled`, `GetPinnedPath()`) y **pestañas
  verticales**: sin cambios.
- Los dos ganchos van en `patches/` con el formato de Brave: una línea por fichero de Chromium.

### Prueba de H2
- A ojo, en claro y en oscuro, a 1x y en Retina:
  - La pestaña activa tiene esquinas superiores poco redondeadas y baja recta hasta la barra, sin curvas hacia fuera.
  - Las inactivas mantienen el separador.
  - El ancho de las pestañas no cambia frente a la 3.1.4 (con el mismo número de pestañas).
- Pasar el ratón sobre una inactiva: el resaltado tiene el mismo radio pequeño.
- Arrastrar una pestaña y crear un grupo: sin huecos ni líneas raras en la unión con la barra.

## H3: URL con foco

- **Ventanas normales y de invitado**: se quita el anillo de foco de la URL (`views::FocusRing::Remove`). En su lugar,
  una vista transparente, la última hija de la barra para quedar por encima de la caja de texto (que tiene fondo opaco),
  pinta un brillo interior gris.
- **Cuándo se ve**: con la misma condición que el anillo de Chromium, cursor visible y desplegable cerrado. Con el
  desplegable abierto, campo y lista forman una pieza y no se pinta.
- **Ventanas privadas y de Tor**: conservan el anillo de Brave.
- **Cómo se dibuja**: con unos trazos concéntricos con suavizado que se desvanecen hacia dentro, sin filtro de
  difuminado. El coste es mínimo también en la GPU de la 5,1.

| Constante (`brave_location_bar_view.cc`) | Valor | Qué es |
|---|---|---|
| `kFlyWebOmniboxFocusGlowThickness` | 2 dip | Anchura del brillo desde el borde hacia dentro |
| `kFlyWebOmniboxFocusGlowColor` | `#808080` | Color en el borde |
| `kFlyWebOmniboxFocusGlowOpacity` | 0,30 | Opacidad en el borde (luego se desvanece) |
| `kFlyWebOmniboxFocusGlowSteps` | 4 | Número de trazos del degradado |

**Lo que dice la maqueta.** En `maqueta-claro-url-pulsada.png`, lo que más cambia al pulsar es que desaparece el borde
fino gris de la URL (≈`#ECEDEE`), y el borde queda casi blanco. A esa resolución no se distingue el degradado. Por eso
los valores de arriba son un punto de partida para afinar con Titín.

### Prueba de H3
1. `brave_browser_tests --gtest_filter='BraveLocationBarViewColorOverridesTest.*'`: debe pasar el test nuevo
   `FlyWebFocusGlowReplacesFocusRing` y los que ya había.
2. A ojo, en claro y en oscuro, a 1x y en Retina:
   - Pulsar la URL o ⌘L: aparece el brillo y no hay anillo de color.
   - Escribir, con el desplegable abierto: sin brillo.
   - Esc o clic en la página: desaparece.
3. Ventana privada y de Tor: el anillo de siempre.
4. Accesibilidad: con VoiceOver, la vista del brillo no aparece. El foco sigue anunciándose en la URL.
