# FlyWeb — Imágenes necesarias

Lista para el diseño definitivo. Todo lo que hay ahora sale del SVG provisional `icon_FlyWeb.svg`
(ver `scripts/`). Basta con entregar los **maestros** de la primera tabla; los tamaños concretos de la
segunda se generan desde ellos, salvo los marcados como "a mano".

## Maestros que hay que entregar

| # | Maestro | Formato | Notas |
|---|---|---|---|
| M1 | **Icono de la app** | SVG 1024×1024 (o PNG 1024 transparente) | Forma de icono de macOS: contenido dentro de ~824×824 centrado, sombra incluida si se quiere. Se ve en el Dock, Finder, Launchpad |
| M2 | **Símbolo** (la mosca sola, sin fondo) | SVG, cuadrado | Para pestañas y tamaños pequeños. Debe leerse a 16×16 |
| M3 | **Símbolo monocromo** | SVG, cuadrado, **un solo color**, solo trazados rellenos (sin trazos, degradados ni opacidades) | Barra de direcciones y notificaciones: Chromium lo pinta del color del tema (negro en claro, blanco en oscuro) |
| M4 | **Logotipo horizontal** (símbolo + "FlyWeb") | SVG, en dos versiones: para fondo claro y para fondo oscuro | `brave://version`, "Acerca de", bienvenida. Proporción aproximada 3,4:1 (164×48) |
| M5 | **Fondo del instalador DMG** | PNG 602×330 (y 1204×660 para Retina) | Ventana del `.dmg`: la app a la izquierda, Aplicaciones a la derecha, flecha en medio. La actual es de Brave (degradado morado) |

Opcional:

| # | Maestro | Notas |
|---|---|---|
| O1 | Variantes del icono por canal (beta, dev, nightly, development) | Hoy todos usan el mismo. Brave les pone otro color o una etiqueta. Útil para no confundir el build de pruebas con el estable |
| O2 | Icono de documento (`document.icns`) | Ficheros `.html` que abre FlyWeb. Si no, se usa el de la app |
| O3 | Versión 16×16 y 32×32 **dibujada a mano** del símbolo | A 16 px la mosca actual queda borrosa: el reescalado automático no basta |

## Limitaciones de cada maestro: color y fondo

Una sola mosca no sirve para todo. Cada sitio la pinta de una forma, y eso decide cómo hay que dibujarla.

| Tipo | Quién decide el color | Sobre qué fondo se ve | Maestros | Cómo dibujarlo |
|---|---|---|---|---|
| **A. Color fijo, fondo desconocido** | El dibujo. El sistema no lo cambia | Claro **y** oscuro, según el modo del usuario: Dock, Finder, Spotlight, avisos del escritorio, pestañas, barra de herramientas | M1, M2, O1, O2, O3, M6, M7 | Tiene que verse en los dos. O lleva su propia placa de fondo, o un contorno o relleno que contraste con ambos. Una mosca negra sin más desaparece en oscuro; una blanca, en claro |
| **B. Monocromo que pinta el sistema** | Chromium o macOS: negro en claro, blanco en oscuro (o el color del tema) | Cualquiera | M3 | Solo la silueta: un color, trazados rellenos, sin trazos, degradados ni transparencias. No hay que preocuparse del fondo. Debe leerse a 16×16 |
| **C. Pareja claro/oscuro** | El dibujo, pero hay **dos ficheros** y la página elige según el modo | Cada versión, solo en su fondo | M4 | Una versión oscura para fondo claro y otra clara para fondo oscuro. No hace falta que una sola valga para los dos |
| **D. Fondo fijo conocido** | El dibujo | Siempre el mismo fondo de la propia página | M8, M5 | Se dibuja para ese fondo. Hoy la bienvenida es un degradado morado: la mosca negra provisional queda apagada |

Comprobado el 30/09 en el código y en la compilación del paso 7:
- `brave://version` usa `product_logo.png` en claro y `product_logo_white.png` en oscuro (`prefers-color-scheme`): tipo C.
- Los tres `product.icon` son vectoriales de un color: tipo B.
- El botón de Shields son dos PNG de color fijo (activo y apagado): tipo A.
- En un sistema en modo oscuro, la mosca provisional del Dock y de los avisos se ve bien (HUMANO, 29/09).
- El canal de los builds `Static` es **`development`**: las pruebas en la 6,1 y la 5,1 enseñan esas variantes (O1).

## Imágenes que faltaban en la lista (30/09, LOCAL)

Siguen siendo de Brave en `flyweb` f274035d. Las de servicios desactivados no se cuentan.

| # | Maestro nuevo | Tipo | Ficheros (brave-core) | Tamaños | Dónde se ve |
|---|---|---|---|---|---|
| M6 | **Botón de Shields**, en dos estados: activo y apagado | A | `components/brave_shields/resources/icon.png`, `icon-off.png` | 64×64 y 54×54 | El león a la derecha de la barra de direcciones, en todas las webs. Es el icono de marca que más se ve. Hay que decidir el símbolo: no puede ser el león |
| M7 | **Icono de la extensión interna** (Shields) | A | `components/brave_extension/extension/brave_extension/assets/img/icon-{16,32,48,64,128,256}.png` | 16–256 | `brave://extensions` y permisos. Puede salir de M2 |
| M8 | **Ilustración de bienvenida** | D | `components/brave_welcome_ui/assets/brave_logo_3d@2x.webp` (ya es la mosca provisional); fondos `background@2x.webp` 2992×1756, `sky.webp`, `hill.webp`, `pyramid.webp`; `components/images/lion_logo.svg`, `welcome_{shields,rewards,search,import,bg}.svg` | 200×239 el logo | `brave://welcome`. Los fondos morados son el estilo de Brave: decidir si se cambian |
| M9 | **Piezas de la nueva pestaña** | A | `components/img/newtab/defaultTopSitesIcon/brave.png` (256×300), `components/brave_new_tab_ui/components/default/braveNews/braveNewsLogo.svg`, `components/img/newtab/dummy-branded-wallpaper/logo.png` (512×512) | — | Icono por defecto de un sitio, logo de Noticias (la tarjeta se ocultará), logo del fondo de muestra |
| M10 | **Iconos del paquete de diseño de Brave** | B o A | `@brave/leo` (en `node_modules`, fuera del repo): `product-brave-color.svg`, `product-brave-monochrome.svg`, `product-brave-outline.svg`, `social-brave-favicon.svg`, `leo-color.svg` y los `product-brave-{news,talk,search,wallet,ai,premium}` | SVG | Ajustes y menús de las páginas internas. **NUBE: ver cuáles se usan con Wallet, Rewards y Leo quitados, y cómo sustituirlos** (no se pueden editar en `node_modules`) |
| M11 | Favicon de la bienvenida | A | `components/img/welcome/favicon.ico` | 16–32 | Pestaña de `brave://welcome` |

Con nombre "brave" pero sin marca (iconos genéricos; no hay que rediseñarlos): los `app/vector_icons/sidebar_*.icon`,
`brave_translate.icon`, `brave_sad.icon`, `vertical_tab_strip_toggle_button.icon`, `webstore_icon*.png`,
`brave_wayback_infobar*.png`, `brave_web_discovery_infobar_*.png`, las ilustraciones de `brave_sync_page/` y
`cookie_list_opt_in/`.

## Dónde acaba cada cosa (en brave-core)

| Fichero | Tamaños | Sale de |
|---|---|---|
| `app/theme/brave/mac/app.icns` (y `beta/`, `dev/`, `development/`, `nightly/`) | 16–1024, @1x y @2x | M1 (O1) |
| `app/theme/brave/mac/document.icns` | 16–1024 | O2 o M1 |
| `build/mac/dmg.icns` (y `dmg-<canal>.icns`) | 16–1024 | M1: icono del volumen `.dmg` |
| `build/mac/dmg-background.png` | 602×330 | M5 |
| `app/theme/brave/product_logo_{22,24,48,64,128,256}.png`, `product_logo_128_<canal>.png` | los del nombre | M1 |
| `app/theme/brave/product_logo_22_mono.png` | 22×22 | M3 (solo lo usa Linux) |
| `app/theme/default_{100,200}_percent/brave/product_logo_16*.png`, `product_logo_32*.png` | 16, 32 (y 32, 64 en @2x), por canal | M2 (O3): icono de las pestañas `brave://` |
| `app/theme/default_{100,200}_percent/brave/product_logo_name_22.png` | 77×22 / 154×44 | M4 claro |
| `app/theme/default_{100,200}_percent/brave/product_logo_name_48.png` | 164×48 / 328×96 | M4 claro |
| `app/theme/default_{100,200}_percent/brave/product_logo_white.png` | 214×64 / 428×128 | M4 oscuro |
| `components/resources/default_{100,200}_percent/brave/product_logo.png`, `product_logo_white.png` | 164×48 / 328×96 | M4 claro / oscuro: logo de `brave://version` |
| `vector_icons/components/omnibox/browser/vector_icons/product.icon` | lienzo 32 | M3 → `scripts/svg2icon.py` |
| `vector_icons/ui/message_center/vector_icons/product.icon` | lienzo 96 | M3 |
| `components/vector_icons/brave/product.icon` | lienzo 24 | M3 |
| `components/brave_welcome_ui/assets/brave_logo_3d@2x.webp` | 200×239 | M2 o M1: página de bienvenida |

## Qué no hace falta

- **Fondos de la nueva pestaña**: son fotografías que Brave sirve por su actualizador de componentes, con
  crédito del autor. No son marca de Brave. Las imágenes patrocinadas (publicidad) ya están quitadas
  en código (`nube/no-sponsored-images`).
- Iconos de Android, iOS, Windows y Linux (salvo lo anotado): FlyWeb solo se compila para macOS.
- Iconos de servicios de Brave (Rewards, Wallet, VPN, Leo, Talk): están desactivados.
