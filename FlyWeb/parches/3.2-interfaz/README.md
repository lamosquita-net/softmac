# 3.2.0: interfaz del diseño de Titín

MOTOR-46, desde el 19-11, por encargo de COORDINACIÓN-51. Diseño: `FlyWeb/branding/interfaz-3.2.0/` (#1107).
**Sin compilar** (la nube no tiene el checkout de Chromium). Destino: 3.2.0.

Base: brave-core `local/3.1.4` (`e660929ac9`); Chromium de referencia `local/314` (`e9b670773e`). Un parche por hito,
para que LOCAL pruebe cada uno en la 6,1. Árbol tras el 0001: `0ab5d2c1f8`.

| Parche | Hito | Qué hace |
|---|---|---|
| `0001-FlyWeb-3.2.0-interface-frame-toolbar-active-tab-and-.patch` | H1 colores | `browser/ui/color/color_palette.h`, `brave_color_mixer.cc` y su test |

Pendientes: H2 forma de las pestañas, H3 foco de la URL (brillo interior) y H4 iconos.

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

### Lo que no cambia

- **Ventanas privadas y de Tor**: conservan los colores de Brave, porque su proveedor de tema se aplica después. Las recetas
  de contraste también corren ahí, pero se calculan sobre el fondo de la ventana privada. Se comprueba en el paso 5 de
  la prueba.
- **Ventana sin foco**: los mismos colores. Es la propuesta pendiente de Titín; está en una línea.
- **Colores de texto e iconos de la barra**: los de Brave. En la maqueta oscura los iconos son casi blancos (≈`#EDEEF1`) y
  el texto de la pestaña activa ≈`#ECECEC`. En la clara, los iconos ≈`#656666` y el texto de la pestaña activa
  ≈`#4C4D4D`. Ni el README del diseño ni el encargo los nombran, así que van como pregunta a Titín. En modo oscuro, el
  gris de los iconos de Brave sobre `#656666` puede quedar con poco contraste: conviene mirarlo en la prueba.
- **Otras cosas de la maqueta que no están en el encargo**:
  - No hay línea entre la barra de marcadores y la página. En FlyWeb sigue la de Brave (`kColorToolbarContentAreaSeparator`).
  - La URL tiene un borde fino: ≈`#ECEDEE` en claro y ≈`#8C8C8C` en oscuro.

  También son preguntas para Titín.

## Prueba (LOCAL, 6,1 en pantalla 1x y una Retina)

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
