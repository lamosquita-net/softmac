# 3.2.0: interfaz del diseño de Titín

MOTOR-46, desde el 19-11, por encargo de COORDINACIÓN-51. Diseño: `FlyWeb/branding/interfaz-3.2.0/` (#1107).
**Sin compilar** (la nube no tiene el checkout de Chromium). Destino: 3.2.0.

Base: brave-core `local/3.1.4` (`e660929ac9`); Chromium de referencia `local/314` (`e9b670773e`). Un parche por hito,
para que LOCAL pruebe cada uno en la 6,1. Se aplican en orden. Árbol tras el 0001: `0ab5d2c1f8`; tras el 0003: `6ebef09e6d`; tras el 0004: `a345fdd36e`; tras el 0006: `78b591fe4e`; tras el 0007: `6653db38fb`. (El 0003 se corrigió el 19-11 tras la compilación de LOCAL-19: a la vista del brillo le faltaba `METADATA_HEADER`/`BEGIN_METADATA`, obligatorio en la 156. Los árboles posteriores cambian por eso. El 0004 se corrigió después, por los tests de LOCAL-19: el texto de las pestañas se aplicaba antes que el mezclador de pestañas de Chromium, que lo pisaba. Ahora va al final de `AddBravifiedTabStripColorMixer()`.)

| Parche | Hito | Qué hace |
|---|---|---|
| `0001-FlyWeb-3.2.0-interface-frame-toolbar-active-tab-and-.patch` | H1 colores | `browser/ui/color/color_palette.h`, `brave_color_mixer.cc` y su test |
| `0002-FlyWeb-3.2.0-interface-tab-shape-with-smaller-top-ra.patch` | H2 pestañas | Dos ganchos en `patches/` y sus `chromium_src` (`tab_style.cc`, `horizontal_tab_style_views.cc`) |
| `0003-FlyWeb-3.2.0-interface-soft-inner-glow-instead-of-th.patch` | H3 foco de la URL | `browser/ui/views/location_bar/brave_location_bar_view.{h,cc}` y un test de navegador |
| `0004-FlyWeb-3.2.0-interface-Titin-s-answers-on-icon-text-.patch` | H1, respuestas de Titín | Iconos, texto de las pestañas, ventana sin foco y carpetas (`brave_color_mixer.cc` y su test) |
| `0005-FlyWeb-3.2.0-interface-Titin-s-toolbar-tab-and-bookm.patch` | H4 iconos | 11 `.icon` en `vector_icons/`, 4 propios en `app/vector_icons/`, ganchos del «+» y del «⌄», carpeta vectorial |
| `0006-FlyWeb-3.2.0-interface-Shields-as-a-colored-shield-o.patch` | H4 escudo de Shields | `browser/ui/views/brave_actions/brave_shields_action_view.{h,cc}` |
| `0007-FlyWeb-3.2.0-interface-private-window-toolbar-active.patch` | Ventana privada | Barra, pestaña activa y marco de la privada (`brave_color_mixer.cc`, `color_palette.h` y test de navegador). **Aparte**: LOCAL-19 compila 0001–0006 sin él |
| `0008-FlyWeb-3.2.0-interface-URL-focus-glow-as-a-soft-inne.patch` | Ajuste 20-11 (1) | Brillo de la URL como sombra interior difuminada de 4 dip, igual en claro y oscuro (`brave_location_bar_view.cc`) |
| `0009-FlyWeb-3.2.0-interface-URL-field-a-little-shorter-fr.patch` | Ajuste 20-11 (2) | URL 3 dip más baja por arriba (`brave_toolbar_view.cc`, `brave_layout_constants.h`, `brave_actions_container.cc`) |
| `0010-FlyWeb-3.2.0-interface-inactive-tab-hover-colors.patch` | Ajuste 20-11 (3) | Hover de la pestaña inactiva (`brave_color_mixer.cc`, `color_palette.h` y su test) |
| `0011-FlyWeb-3.2.0-interface-lower-favicon-and-title-on-in.patch` | Ajuste 20-11 (4) | Título y favicon de las inactivas 4 dip más bajos (chromium_src `tab.cc` y el parche de `tab.cc`) |
| `0012-FlyWeb-3.2.0-interface-inactive-tab-hover-as-a-tab-s.patch` | Ajuste 20-11 (5) | Hover de la inactiva con silueta de pestaña hasta la base (chromium_src y parche de `horizontal_tab_style_views.cc`) |
| `0013-FlyWeb-3.2.0-interface-URL-shadow-always-inside-soft.patch` | Ajuste 20-11 (6) | Sombra de la URL siempre por dentro: más suave en hover y más marcada con el cursor (`brave_location_bar_view.cc`) |

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
2. `brave_browser_tests --gtest_filter='BraveThemeServiceTest.*'`: deben pasar `ColorProviderTest` y
   `OmniboxColorTest`. `SystemThemeChangeTest` y `ThemeObserverTest` fallaron en la 6,1 (19-11) por algo ajeno a la
   serie. En Mac, `SetSystemDarkMode()` (`brave_dark_mode_utils_mac.mm`) solo cambia la apariencia de `NSApp`, y el
   tema nativo se entera después; los tests lo comprueban en el acto. Ningún parche de la serie toca ese código ni esos
   tests. Ver el aviso a COORDINACIÓN.
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

## H4: iconos

Se generan con `FlyWeb/tools/iconos-3.2.0.sh <brave-core> [escala]`, que llama a `FlyWeb/tools/svg2icon.py` (solo la
biblioteca estándar, con vista previa en PNG). La escala es común a todos, para conservar las proporciones del Illustrator
de Titín: **2,2642 dip por unidad del SVG**, calibrada para que la flecha de atrás mida lo que mide hoy (12 dip en la
rejilla de 20). Para cambiarla basta con volver a ejecutar el script con otra escala.

**Qué se ve hoy en FlyWeb 156**: los iconos «old» de Chromium. Los redondeados (`features::IsRoundedIconsEnabled()`)
están apagados. Las sustituciones Leo de Brave (`vector_icons/leo_overrides.json`) apuntan a nombres de la 1.57 y en la
156 casi ninguna tiene efecto. No se tocan aquí.

| Icono de Titín | Rejilla | Sustituye a | Cómo |
|---|---|---|---|
| `ico-atras` / `ico-adelante` | 20 | `components/vector_icons/{back,forward}_arrow_chrome_refresh_old.icon` | `vector_icons/<misma ruta>` |
| `ico-recargar` / `ico-detener` | 20 | `components/vector_icons/reload_chrome_refresh_old.icon`, `chrome/app/vector_icons/navigate_stop_chrome_refresh_old.icon` | ídem |
| `ico-estrella-vacia` / `-llena` | 20 | `components/omnibox/browser/vector_icons/star{,_active}_chrome_refresh_old.icon` (el botón de marcadores de Brave, a la izquierda de la URL) | ídem |
| `ico-extensiones` | 20 | `components/vector_icons/extension_chrome_refresh_old.icon` | ídem |
| `ico-descargas` | 20 | `chrome/app/vector_icons/download_toolbar_button_chrome_refresh_old.icon` | ídem |
| `ico-menu-tres-puntos` | 20 | `chrome/app/vector_icons/browser_tools_chrome_refresh_old.icon` | ídem. También cambia el ⋮ de la cabecera de grupos de pestañas y del menú de extensiones; tiene sentido que sean iguales |
| `ico-cerrar-pestana` | 16 | `chrome/app/vector_icons/close_tab_chrome_refresh_old.icon` | ídem |
| `ico-mas-adelante` («»») | 16 | `chrome/app/vector_icons/bookmarkbar_overflow_refresh_old.icon` | ídem |
| `ico-pestana-nueva` («+») | 16 | `kAddOldIcon` del botón de nueva pestaña | Icono propio `kFlywebNewTabIcon` y gancho en `horizontal_tab_strip_region_view.cc`. `add_old.icon` es un «+» genérico de Chromium |
| `ico-buscar-pestanas` («⌄») | 16 | `kExpandMoreOldIcon` del botón de buscar pestañas | Icono propio `kFlywebTabSearchIcon` y gancho en `tab_strip_combo_button.cc`. El chevrón de Chromium es genérico |
| `ico-carpeta-marcadores` | 16 | Las PNG con degradado de Brave (`IDR_BRAVE_BOOKMARK_FOLDER_CLOSED_*`) | `GetBookmarkFolderIcon()` en el `chromium_src` de Brave devuelve el vector `kFlywebBookmarkFolderIcon` en `kColorBookmarkFolderIcon` (color plano). Las carpetas gestionadas siguen con el icono de Chromium |
| `ico-escudo` | 20 | Las PNG de Shields | Ver H4 escudo |

**Sin uso**:
- `ico-apps`: el atajo «Aplicaciones» está oculto en FlyWeb. El `chromium_src` de Brave hace que
  `IsAppsShortcutEnabled()` y `ShouldShowAppsShortcutInBookmarkBar()` devuelvan `false`. Si Titín lo quiere visible, es
  otro cambio.
- `ico-mas-atras` («««»): Chromium no tiene «« en la barra de marcadores. En escritura de derecha a izquierda, el «»»
  se refleja solo.
- «Personalizar» de la nueva pestaña: sigue el actual.

**Tamaño**: con la escala común, extensiones (~17 dip), descargas (~15) y escudo (~15 de alto) quedan algo más grandes
que los de Chromium (~16 en la rejilla de 20). Es el resultado de conservar las proporciones; se decide con las capturas.

### Prueba de H4
- A ojo, en claro y en oscuro, a 1x y en Retina:
  - Barra: atrás, adelante, recargar, detener (mientras carga), estrella (sin guardar y guardada), extensiones,
    descargas y ⋮.
  - Pestañas: «×», «+» y «⌄».
  - Barra de marcadores: carpetas (planas, sin degradado) y «»» con muchos marcadores.
- El resto de la interfaz no cambia: los «+» de otros diálogos y los chevrones de menús y desplegables siguen con el
  icono de Chromium.
- Con la interfaz en árabe o hebreo (de derecha a izquierda): la carpeta y el «»» se reflejan.

## H4: escudo de Shields

`brave_shields_action_view.cc` dibuja el contorno de `ico-escudo.svg` (`kFlywebShieldsIcon`), sin mosca, en lugar de
las PNG `IDR_FLYWEB_SHIELDS_ICON_*`. **Valores provisionales**, en constantes `kFlyWebShields*`, hasta que Titín los vea:

| Estado | Color del contorno |
|---|---|
| Shields activo en el sitio | verde `#1E7B34` |
| Shields bajado en el sitio | rojo `#C62828` |
| Páginas donde Shields no actúa (internas y locales: nueva pestaña, ajustes, `file:`, `data:`…) | el color neutro de los iconos de la URL (`kColorOmniboxSecurityChipSecure`, como el candado). Antes usaban la misma imagen que «bajado» |

- **Contraste**: el botón está **dentro de la URL**, que es blanca también en modo oscuro. Por eso el contraste se mide
  contra el blanco: verde 5,3:1 y rojo 5,7:1, un mismo par en los dos modos. Si la URL fuera oscura (con
  `kFlyWebLightOmniboxInDarkMode` = false), se usa otro par: verde `#86EFAC` y rojo `#FFB3B3`. Lo que dije antes sobre
  `#F4F5F6`/`#656666` no aplica: el escudo no está sobre la barra.
- **Contador**: de 1 a 99, dentro del escudo, en negrita (altura máxima de la letra de 9 dip) y en el color del texto de
  la URL. A partir de 100, «99+» en la burbuja de fuera, como antes. Solo con Shields activo y con la preferencia de
  mostrar el contador activada, como en Brave.
- Se repinta al cambiar el tema, porque los colores salen del proveedor de colores.

### Prueba del escudo
- Una página con rastreadores: escudo verde con el número dentro, hasta 99. Una página muy cargada: «99+» fuera.
- Bajar Shields en el sitio: escudo rojo, sin número.
- Nueva pestaña y ajustes: escudo gris neutro.
- Cambiar entre claro y oscuro con la ventana abierta: el escudo cambia sin recargar.
- Comprobar a 1x que dos cifras se leen dentro del escudo y sacar captura para Titín, también de la alternativa
  «99» dentro (`kFlyWebShieldsMaxCountInside`).

## Ventana privada (0007, aparte)

Decisiones de Titín (19-11):
- Pestaña activa y barra de la ventana privada en una sola pieza: **`#571E73`**.
- **La privada va siempre en oscuro.** `#AFA6D2` (claro) queda para más adelante. Ver «Trabajo futuro».
- **Marco `#272726`** en lugar de `#13052A`, para que la privada no se confunda con una ventana normal en oscuro. Va en una
  constante propia, `kFlyWebPrivateFrame`. La URL y el fondo de la página nueva siguen con `kPrivateFrame`.
- **Invitado**: igual que la privada. Comparten tema y no se separan.

- **Siempre en oscuro**: en Chromium 156, `ThemeService::GetColorProviderKey()` fuerza el modo oscuro para los perfiles
  de incógnito, y Titín ha decidido dejarlo así por ahora.
- **Sin cambios**: los iconos (pendientes de Titín), la URL y la página de la ventana privada nueva. Tor no existe en
  FlyWeb.
- **Contraste** (medido por COORDINACIÓN): blanco sobre `#571E73`, 11,4:1; `#EDEEF1` sobre `#571E73`, 9,8:1.

### Prueba
- `brave_browser_tests --gtest_filter='BraveThemeServiceTest.ColorProviderTest'`: comprueba el marco (`#272726`), la
  barra y la pestaña activa de la privada.
- A ojo: ventana privada nueva, con la barra y la pestaña activa en `#571E73`, el marco en `#272726` y el resto como
  antes. La ventana de invitado, igual.

### Trabajo futuro: privada clara (decisión de Titín, 19-11: más adelante)

Para que la ventana privada (y la de invitado, que comparte su tema) siga el modo claro u oscuro del sistema:

1. **Modo**: en `browser/ui/views/frame/brave_browser_widget.cc` (`BraveBrowserWidget::GetColorProviderKey()`), dejar de
   forzar el oscuro. Lo fuerza `ThemeService::GetColorProviderKey()` de Chromium para incógnito, y el propio widget de
   Brave para el invitado.
2. **Paleta clara de la privada**, en `browser/ui/color/brave_color_mixer.cc` (`AddPrivateThemeColorMixer()`). Hoy llama
   siempre a las mezclas oscuras de Brave y de Chrome. Haría falta una rama clara:
   - barra y pestaña activa `#AFA6D2`;
   - marco claro (por definir);
   - texto de pestañas negro, con las inactivas al 50 %;
   - iconos (por definir; `#656666` sobre `#AFA6D2` da 2,5:1, por debajo de 3:1);
   - separadores, línea bajo la barra y anillo de foco.
3. **URL y desplegable de la privada**: `AddBraveOmniboxPrivateThemeColorMixer()`, `GetLocationBarBackground()` y
   `GetOmniboxResultBackground()` con privada. Hay que decidir el color de la URL en claro y aplicar las recetas de
   contraste del desplegable, como en H1.
4. **Página de la ventana privada nueva**: `components/brave_private_new_tab_ui` (React), con un diseño oscuro fijo que
   Titín está rediseñando.
5. **Revisión a ojo** de lo que toma colores de la clave: menús, burbujas, panel de Shields y perfil.

**Riesgos**:
- Hay que rehacer las expectativas de `BraveThemeServiceTest.ColorProviderTest` y `.OmniboxColorTest`, y buscar otros
  tests que miren colores de ventanas privadas.
- El invitado deja de ser siempre oscuro.
- Mientras no exista la página privada clara, saldría una página oscura dentro de una ventana clara.

**Parches**: dos o tres.
1. Modo, paleta clara, URL y desplegable, y tests.
2. La página privada nueva.
3. Los iconos, si no entran en el primero.

Depende de que Titín decida el marco claro, la URL clara y los iconos.

## Ajustes de Titín del 20-11 (0008–0011)

MOTOR-46, por encargo de COORDINACIÓN-53; 0008 y 0009 rehechos por MOTOR-47 el 20-11 con la maqueta del foco (#1140). Diseño: `FlyWeb/branding/interfaz-3.2.0/ajustes-20-11/`. **Sin compilar.** Ninguno
toca la ventana privada ni la de Tor.

**Orden:** van **después** de 0001–0007 de esta carpeta **y** de 0001–0004 de `FlyWeb/parches/3.2-ajustes-sistema/` (ya en
main), es decir, sobre el árbol `a0c808d485`. Con `git am`, en ese orden, aplican limpio (comprobado):

| Tras | Árbol |
|---|---|
| interfaz 0001–0007 + ajustes-sistema 0001–0004 | `a0c808d485` |
| 0008 | `140d67f20f` |
| 0009 | `45dd7aebd3` |
| 0010 | `14f9b42b27` |
| 0011 | `f6222babef` |

| Ajuste | Qué se hizo | Constante (provisional) |
|---|---|---|
| 1. Brillo de la URL (los dos modos) | Sombra interior gris difuminada en los cuatro lados, como en `maqueta-claro-foco-hd.webp`: opacidad 0,37 junto al borde que se reduce a la mitad cada dip, 8 trazos de 0,5 dip, sin filtro de difuminado. A 1x, sobre blanco: ≈#DD, #EE, #F6, #FB (maqueta: DD, EE, F7, FD). El mismo dibujo en claro y en oscuro: la caja es blanca en los dos. Sustituye al 0008 de MOTOR-46 (3 dip y 0,55 solo en oscuro), que daba un borde más fuerte | `kFlyWebOmniboxFocusGlowThickness` = 4 dip, `kFlyWebOmniboxFocusGlowOpacity` = 0,37, `kFlyWebOmniboxFocusGlowHalvingDistance` = 1 dip, `kFlyWebOmniboxFocusGlowSteps` = 8 (`brave_location_bar_view.cc`) |
| 2. URL más baja por arriba | `BraveToolbarView::Layout` quita esos dip del borde superior de la URL al final de cada pasada. La barra conserva su alto y la URL, su borde inferior. Los botones de Brave de la URL (Shields) se acortan lo mismo, para conservar su margen | `kFlyWebLocationBarTopTrim` = 3 dip (maqueta en alta del foco: la caja pasa de y=87 a y=90, abajo igual) (`brave_layout_constants.h`) |
| 3. Hover de la pestaña inactiva | `kColorTabBackgroundInactiveHoverFrameActive/FrameInactive` en el mezclador de texto de pestañas de FlyWeb, que no se aplica a privada ni a Tor | `kFlyWebLightInactiveTabHover` #EBEBEB, `kFlyWebDarkInactiveTabHover` #585959 (`color_palette.h`) |
| 4. Título y favicon de las inactivas más bajos | Favicon: el gancho de diseño que ya había en chromium_src `tab.cc`. Título: un gancho nuevo en `title_bounds` (`Tab::Layout`), una línea más en `patches/chrome-browser-ui-views-tabs-tab.cc.patch`. Al activarse, `Tab::ActiveStateChanged()` maqueta la pestaña al momento: suben sin animación. Solo la tira horizontal (las verticales de la 156 usan otras vistas) | `kFlyWebInactiveTabContentOffset` = 4 dip (chromium_src `tab.cc`; de la maqueta en alta de Titín, #1137: ~5–6 px de imagen con la URL a ~33) |

### Pasos para LOCAL

Compilar sobre `a0c808d485` + 0008–0011 (árbol `f6222babef`). Pasar `BraveColorMixersTest.*` (0010 añade el hover en claro y
en oscuro) y `LocationBarViewBrowserTest.FlyWebFocusGlowReplacesFocusRing`. Capturas a Titín, en claro y en oscuro, en la
6,1 a 1x y en una Retina:
1. **URL con foco, en claro y en oscuro:** se ve la misma sombra interior difuminada en los cuatro lados (no un borde). LOCAL no puede dar el foco por SSH: lo comprueba Titín en la build. Si en oscuro no se ve nada (caja blanca pura junto al borde), avisar a MOTOR: entonces no se pinta y hay otra causa.
2. **URL:** la caja empieza 3 dip más abajo; el borde inferior y la altura de la barra no cambian; el desplegable de
   sugerencias sigue pegado a la URL; el escudo de Shields y la estrella, centrados en la caja. Con y sin «barra de
   direcciones ancha».
3. **Hover:** pasar el ratón por una pestaña inactiva da #EBEBEB (claro) y #585959 (oscuro), con la ventana con foco y sin
   él. Privada y Tor no cambian.
4. **Pestañas inactivas:** título y favicon 4 dip más bajos que en la activa, también en las fijadas. Al hacer clic, suben de
   golpe. Comprobar que no hay salto raro al abrir una pestaña nueva (aparece el favicon) ni con el indicador de audio.

Las constantes se ajustan con Titín viendo las capturas, como el radio.

## Ajustes de Titín tras bt-320c (0012–0013)

MOTOR-47, 20-11, por encargo de COORDINACIÓN-53. **Sin compilar.** Van detrás de 0011 (árbol `f6222babef`). No tocan la
ventana privada.

| Tras | Árbol |
|---|---|
| 0012 | `553734129c` |
| 0013 | `78658d3433` |
| 0013 + `3.2-fijadas` 0001 (#1142) | `5f100e4476` |

| Ajuste | Qué se hizo | Constante (provisional) |
|---|---|---|
| 5. Hover de la inactiva | Titín: el fondo «se queda unos píxeles por arriba, como un botón». Causa: en Chromium, el camino `kHighlight` (hover y pestañas seleccionadas) es una píldora de `kTabHeight` menos el relleno y el solape, dentro de una vista de `kTabStripHeight`. Acaba 6 dip por encima de la base y redondea las esquinas de abajo. Un gancho nuevo en `GetPath()` lo baja hasta la misma base que la activa, con las esquinas de abajo rectas: la misma silueta que la activa, detrás de ella. No cambian el área de clic ni las fijadas con el estilo nuevo de Chromium | `kFlyWebHighlightBottomCornerRadius` = 0 (chromium_src `horizontal_tab_style_views.cc`) |
| 6. Sombra de la URL | Titín: en hover salía por fuera (la `ViewShadow` de Brave) y, al pulsar, por dentro. Ahora las ventanas normales y de invitado no crean la sombra exterior, y la sombra interior del 0008 sale también con el ratón encima sin cursor, más suave. Elección de MOTOR, con la que coincide COORDINACIÓN: más marcada con el cursor (escribiendo) y más suave en hover. Si Titín la quiere al revés, basta con cambiar las dos constantes | `kFlyWebOmniboxFocusGlowOpacity` = 0,37 (≈#DD en el borde a 1x), `kFlyWebOmniboxHoverGlowOpacity` = 0,20 (≈#ED) |

### Pasos para LOCAL

Compilar sobre `f6222babef` + 0012–0013 (árbol `78658d3433`; con las fijadas, `5f100e4476`). Pasar
`LocationBarViewBrowserTest.FlyWebFocusGlowReplacesFocusRing` y `BraveColorMixersTest.*`. Capturas para Titín, en claro
y en oscuro:
1. **Hover de una inactiva:** el fondo #EBEBEB o #585959 baja hasta la base, con las esquinas de arriba como la activa y
   las de abajo rectas. Igual con varias pestañas seleccionadas (Mayúsculas + clic). Al arrastrar o cerrar pestañas, no
   aparecen restos.
2. **URL:** ratón encima sin pulsar: sombra suave por dentro, nada por fuera. Al pulsar: más marcada. Con el desplegable
   abierto: ninguna. Ventana privada: como antes, con el anillo y la sombra de Brave.

## Ajustes de Titín tras bt-320e (0014–0015)

MOTOR-47, 20-11, por encargo de COORDINACIÓN-55. **Sin compilar.** No tocan la ventana privada.

**Orden:** al final de la cadena completa de la 3.2.0, tras `3.2-ajustes-sistema/0005` (árbol `d1fe696d26`). Tocan
ficheros que ya tocan 0012 y 0013, así que tienen que ir detrás de ellos.

| Tras | Árbol |
|---|---|
| … + `3.2-ajustes-sistema/0005` | `d1fe696d26` |
| 0014 | `b80ddd1f86` |
| 0015 | **`68da2bca21`** |

| Ajuste | Qué se hizo | Constante |
|---|---|---|
| 7. Hover más bajo | Titín: «la pestaña en roll over debía ser más baja, como en mi maqueta». En `maqueta-claro-hd.webp`, el hover de la primera inactiva empieza ≈5 px por debajo de la parte de arriba de la activa (y 50,5 frente a 45,5) y llega a la misma base. La activa mide allí 38,5 px y 34 dip en el navegador: ≈4,4 dip. Un segundo gancho en `GetPath()` baja la parte de arriba del camino `kHighlight` de las inactivas y deja la base donde estaba. La activa conserva toda su altura | `kFlyWebHoverTabTopInset` = 4 dip (chromium_src `horizontal_tab_style_views.cc`) |
| 8. Flou con el desplegable | Titín: al pulsar en la URL «el flou no se ve». El 0003 ocultaba la sombra interior con el desplegable abierto, como el anillo de Chromium. Ahora la caja la conserva mientras se escribe: el desplegable deja ver la URL por su hueco | — |

### Pasos para LOCAL

Compilar `68da2bca21` y pasar `LocationBarViewBrowserTest.FlyWebFocusGlowReplacesFocusRing` (sigue valiendo: sin cursor ni
ratón encima, la sombra está oculta). Capturas para Titín, en claro y en oscuro:
1. **Hover de una inactiva:** el fondo empieza ≈4 dip por debajo de la parte de arriba de la activa y llega a la base.
2. **URL con foco, con el desplegable abierto (escribiendo) y cerrado:** la sombra interior se ve en los dos casos.

**Pendiente, a la espera de respuestas de Titín:** el ancho del desplegable, su sombra exterior y «la línea bajo el
campo».

## 0016: URL y desplegable en una sola pieza

MOTOR-47, 20-11. Respuestas de Titín a P1–P4 y `maqueta-oscuro-desplegable-hd.webp` / `maqueta-claro-url-sutil.png`
(#1153). **Sin compilar.** En todas las ventanas, también la privada (P1).

**Medidas en la maqueta oscura** (1 px ≈ 1 dip; la caja de la URL mide 29 px, como en el navegador desde el 0009):
- La URL va de x=434 a x=1567, y el desplegable igual: **el mismo ancho**.
- El desplegable empieza en y=120, justo debajo de la última fila de la URL (y=119): **hueco 0**.
- **Sin sombra** alrededor.
- Esquinas de la URL y del desplegable: **≈1–2 px** (en `maqueta-claro-url-sutil.png`, «muy sutil»).

**Qué hace:**
- `RoundedOmniboxResultsFrame` (parche nuevo con 2 ganchos y chromium_src):
  - sin márgenes de alineación (Chromium: 6 dip por lado, 5 arriba y abajo);
  - el hueco de la URL, tan alto como la caja (`kLocationBarHeight − kFlyWebLocationBarTopTrim`);
  - elevación 0;
  - el radio de la caja.
- `LocationBarView::ComputeBorderRadius()` (un gancho más) devuelve `kFlyWebLocationBarCornerRadius` = **2 dip**: el
  fondo de la caja, el hueco del desplegable, la sombra interior y el anillo de foco de la privada.

**Árbol:** sobre `68da2bca21` → **`49012e5a50`**.

**Para LOCAL:** compilar `49012e5a50`. Capturas en claro y en oscuro, normal y privada:
1. URL sin foco: esquinas casi rectas (2 dip).
2. URL escribiendo, con el desplegable: el mismo ancho que la caja, pegado debajo, sin sombra, con la sombra interior en la
   caja.
3. Ampliada, la unión entre la caja y la primera sugerencia, para la P2 de Titín.
Si en Mac `BubbleBorder` sin sombra pinta algún borde de 1 px, avisar a MOTOR.

## 0017: URL y desplegable oscuros en modo oscuro

MOTOR-47, 20-11. Decisión de Titín: «para que el desplegable esté en la gama del entorno». Sustituye lo del 19-11
(URL blanca en oscuro). Solo en la ventana normal y en modo oscuro; en claro y en la privada no cambia nada. **Sin
compilar.** Árbol: sobre `49012e5a50` → **`b9f628b8a6`**.

| Elemento | Valor | Origen |
|---|---|---|
| Caja de la URL | `#4D4D4D`, texto blanco (8,5:1) | maqueta |
| Desplegable | `#909294`, texto blanco | maqueta |
| Fila seleccionada | `#542671`, texto blanco (11:1), marca a la izquierda `#AFA6D2` (en la maqueta ≈`#AFA8D3`) | maqueta |
| Flou interior | negro, opacidad 0,22 en el borde con el cursor (≈`#41` junto al borde, como en la maqueta) y 0,12 en hover | maqueta |
| Texto secundario, URL de las sugerencias, respuestas, iconos | blanco | **propuesta** (abajo) |
| Hover de fila | `#909294` un 10 % hacia el negro (≈`#828486`) | **propuesta**: la receta de Brave |
| Selección de texto en la caja, iconos y chips de la caja | recetas de contraste de Chromium sobre `#4D4D4D` | **propuesta** |

**Contraste (para Titín):** el blanco sobre `#909294` da **3,1:1**. No llega a AA para texto normal (4,5:1); sí para
texto grande y para iconos (3:1). Las recetas de Chromium, que buscan 4,5:1, habrían puesto oscuros el texto secundario y
las URL. Por eso se quedan blancos, como en la maqueta. Si se quiere AA con texto blanco, el fondo tendría que ser
`#767676` o más oscuro. Si se quiere mantener `#909294`, el texto tendría que ser oscuro (negro: 6,7:1).

Chromium pinta la caja con foco del color del desplegable. Aquí la caja conserva su `#4D4D4D` mientras tiene el cursor.

**Ojo, línea (P2):** con colores distintos, el trazo de 1 px que Chromium pinta alrededor del hueco de la URL
(`TopBackgroundView`, del color del desplegable) se verá como un **borde gris claro alrededor de la caja oscura** con el
desplegable abierto. En la maqueta no está. Propuesta: quitarlo si Titín lo confirma en la captura.

### Pasos para LOCAL

`BraveColorMixersTest.*` (comprueba los colores oscuros) y `BraveThemeServiceTest.OmniboxColorTest`. Capturas en claro y en
oscuro, ventana normal y privada:
1. URL sin foco.
2. URL con foco, sin desplegable.
3. URL con el desplegable abierto y una fila seleccionada con las flechas.
4. Ampliada, el borde de la caja con el desplegable abierto (para la línea de 1 px).

## 0018: `OmniboxColorTest` en oscuro (bt-320f)

MOTOR-47, 20-11. Solo la prueba; el navegador no cambia.

- **Fallo:** en bt-320f, `BraveThemeServiceTest.OmniboxColorTest` falla en oscuro. Espera `#4D4D4D` y `#909294` y lee
  `#FFFFFF`. En pantalla el oscuro está bien (LOCAL-21: caja `#4D4D4D`).
- **Causa:** en Mac, `SetBraveDarkModeType()` solo cambia la apariencia de `NSApp`, y el tema nativo la sigue más tarde.
  El proveedor de la ventana seguía siendo el claro: es la misma causa que en `ThemeObserverTest` y
  `SystemThemeChangeTest`. Hasta la 3.2.0 la caja oscura era blanca como la clara, así que la prueba pasaba por casualidad.
- **Arreglo:** los colores oscuros se leen del proveedor de la clave de la propia ventana con el modo oscuro
  (`ColorProviderManager::GetColorProviderFor`).
- **Árbol:** sobre `b9f628b8a6` → **`db8f0061e3`**.
- **Para LOCAL:** `brave_browser_tests --gtest_filter='BraveThemeServiceTest.OmniboxColorTest'`.
