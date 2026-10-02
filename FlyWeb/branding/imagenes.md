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

## Entrega 1 del HUMANO (02/10): estado

Ficheros en esta carpeta. **Elegidas las versiones 01** de M1 y O1; las 02 y 03 se guardan como alternativas.
Láminas de prueba (LOCAL, con `~/proyectos/softmac/herramientas/lamina.swift`) en `software/entregas/iconos-v1/`,
incluida `iconos-tamano-real.png` para revisarla al 100 % en un monitor no Retina (la 5,1).

| Fichero | Maestro | Estado | Observaciones de LOCAL |
|---|---|---|---|
| `M1-01.svg` (02, 03) | M1 icono de la app | **Elegido 01** | El disco naranja `#f90` resuelve el contraste en claro, oscuro y el gris del Dock. A 16 px la 01 aguanta mejor que la 02 y la 03. El disco ocupa todo el lienzo de 1024: en Mojave bien; en macOS 11+ se ve algo mayor que los de Apple (rejilla de ~824) |
| `O1-01.svg` (02, 03) | O1 variante de canal | **Elegido 01** | Morado `#951b81`: se distingue a la primera del naranja. Para el canal `development` (builds `Static`) y, si se quiere, beta o nightly |
| `M2.svg` / `M2.png` | M2 símbolo (pestañas) | Bien dibujado a 16×16 | **`M2.png` mide 17×17**: exportar a 16×16 y 32×32 exactos, o generarlos desde el SVG |
| `M3.svg` / `M3.png` | M3 monocromo | Cumple la regla (un color, sin trazos ni opacidades) | Es un **disco relleno con la mosca recortada**: teñido queda un círculo oscuro pesado junto a iconos finos, y el contorno de las alas se pierde a 16 px. Propuesta: silueta de la mosca sin disco (decide el HUMANO). `M3.png` también es 17×17 |
| `M4-fondo-claro.svg`, `M4-fondo-oscuro.svg` | M4 logotipo | Las dos bien en su fondo | Proporción **3,07:1** (los huecos son ~3,4:1: quedará margen lateral, sin deformar). A **77×22** "by lamosquita" no se lee: hace falta una **variante sin lema** para `product_logo_name_22` |
| `O2.svg` | O2 documento | Sustituido por `O2-02.svg` (entrega 2) | **"HTML" es `<text>` (Arial)**: convertir a trazados para no depender de la fuente. A 16 px ilegible, como cualquier icono de documento |

**Especificaciones nuevas que salen de esta entrega:**
- Los PNG de revisión, a **tamaño exacto** (16×16, 32×32…): uno de más se reescala y se emborrona.
- Todo el texto de los SVG, **convertido a trazados** (ningún `<text>`).
- Para M4 a 22 px de alto, **solo símbolo + "FlyWeb"**.

## Entrega 2 del HUMANO (02/10, tarde)

- **PNG fuera del repo** (Illustrator no los exporta a tamaño exacto): se generan desde los SVG. `.gitignore` excluye
  `FlyWeb/branding/*.png`, `BackupDrive/branding/*.png` y `*.ai` (el `.ai` es el documento de trabajo del HUMANO).
- **O2: elegido `O2-02.svg`** (texto ya en trazados). `O2.svg` queda como alternativa.
- **M3 sin disco:** dos candidatos, `M3_1.svg` (16×16,02, el último exportado) y `M3-02.svg` (lienzo 13,42×14,87, no
  cuadrado). **Pendiente de que el HUMANO elija** con la lámina `software/entregas/iconos-v1/E-entrega2.png`. El elegido
  debería tener lienzo cuadrado de 16×16 para que el `.icon` salga alineado a píxel.
- **M4 pequeño** para 77×22: `M4-fondo-claro-pequeño.svg` y `M4-fondo-oscuro-pequeño.svg`.
- `01-02.svg` era una copia idéntica de `O1-02.svg` con el nombre mal: retirada (está en `~/proyectos/softmac/temp/papelera/` de la 7,1).

## Integración en brave-core (02/10, LOCAL)

Todos los maestros elegidos están en `flyweb` desde el paso 28 de `docs/integracion.md` (rama `local/iconos-v1`,
327f4c2d). Se regeneran con `scripts/generar-marca.sh <brave-core>`. Lámina de lo generado y capturas en
`software/entregas/iconos-v1/F-*.png`. Quedan provisionales: el **botón de Escudos** (M6, escudo verde/gris con la
mosca de M3_1), la bienvenida (M8, se usa M1-01) y el fondo del DMG (M5). Los 16 y 32 px de la app salen reduciendo
M1-01: si a esos tamaños no convence, hace falta la versión a píxel (O3).

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

## Tamaño al que se ve cada cosa (y cuáles hay que dibujar a píxel)

Tamaños sacados del código de Chromium 116 y brave-core 1.57.64. "pt" son puntos de pantalla: en un monitor
normal, 1 pt = 1 píxel; en Retina, 1 pt = 2 píxeles. **Regla práctica: todo lo que se ve a 32 px o menos hay que
dibujarlo a píxel, a su tamaño exacto, con las líneas sobre píxeles enteros.** Reducir un dibujo grande lo emborrona.
Los Mac con Mojave (6,1 y 5,1) suelen ir con monitor normal: ahí se ve siempre la versión de 1 px por punto.

| Dónde | Se ve a | Píxeles reales (normal / Retina) | Maestro | ¿A píxel? |
|---|---|---|---|---|
| Pestaña de una página interna (`kFaviconSize`) | 16 pt | 16×16 / 32×32 | M2 | **Sí, los dos** (O3). `product_logo_16` y su @2x |
| Icono a la izquierda de la barra de direcciones (`LOCATION_BAR_ICON_SIZE`) | 16 pt | 16×16 / 32×32 | M3 | **Sí.** Hoy el `.icon` tiene un solo dibujo en lienzo de 32 que se reduce a 16. Chromium admite varios dibujos en el mismo `.icon` (lienzos 32, 20 y 16): añadir uno de 16 hecho a mano |
| Botón de Shields (`kBraveActionGraphicSize`) | 18 pt | 18×18 / 36×36 | M6 | **Sí, pero hoy no se puede:** Brave carga un único PNG de 64×64 (54×54 el apagado) y lo reduce, así que siempre sale remuestreado. **NUBE: cargar un PNG de 18 y otro de 36** |
| Icono pequeño en las notificaciones de Chromium (`kSmallImageSizeMD`) | 18 pt | 18×18 / 36×36 | M3 | **Sí.** Lienzo de 96 reducido: añadir un dibujo pequeño |
| Menús y otros usos del símbolo (`components/vector_icons/brave/product.icon`, lienzo 24) | 16–24 pt | 16–24 / 32–48 | M3 | **Sí** para 16 |
| Finder en lista, barra lateral, diálogos de abrir y guardar, barra de título | 16 pt | 16×16 / 32×32 | M1 | **Sí** (`icon_16x16.png` y `icon_16x16@2x.png` del `.icns`) |
| Spotlight, Finder en columnas | 32 pt | 32×32 / 64×64 | M1 | **Sí** el de 32×32 |
| Avisos del escritorio de macOS | ~32–40 pt | 32–40 / 64–80 | M1 | macOS elige el tamaño del `.icns` más cercano y lo ajusta |
| Dock | 48–64 pt (128 con ampliación) | 48–128 / 96–256 | M1 | No: basta el maestro. El `.icns` lleva 48, 128, 256, 512 y 1024 |
| Finder en iconos, Launchpad, Cmd+Tab | 64–128 pt | 64–128 / 128–256 | M1 | No |
| Icono de la extensión en menús / en `brave://extensions` | 16 pt / 48 pt | 16 y 48 / 32 y 96 | M7 | **Sí** el de 16 |
| Logotipo pequeño con nombre (`product_logo_name_22`) | 22 pt de alto | 77×22 / 154×44 | M4 | **Sí:** el texto a 22 px hay que ajustarlo a mano |
| Logotipo con nombre (`product_logo_name_48`) | 48 pt de alto | 164×48 / 328×96 | M4 | Conviene, por el texto |
| Logotipo blanco (`product_logo_white`) | 64 pt de alto | 214×64 / 428×128 | M4 oscuro | No |
| Logo de `brave://version` | **180 pt de ancho** (CSS `#logo`) | 180×53 / 360×105 | M4 | No, pero **hoy se amplía**: el fichero es de 164×48 (328×96 en Retina) y la página lo estira a 180. **NUBE: generarlo a 180×53 y 360×106** |
| Mosca de la bienvenida | **150 pt de ancho** (CSS) | 150×179 / 300×358 | M8 | No, pero **en Retina se amplía**: el fichero es de 200×239. **NUBE: generarlo a 300×358 como mínimo** |
| Icono de sitio por defecto en la nueva pestaña | ~40–72 pt | — | M9 | No |
| Fondo del instalador | 602×330 pt | 602×330 / 1204×660 | M5 | No |

**Resumen de lo que hay que dibujar a píxel:** la app a 16×16 y 32×32; el símbolo a 16×16 y 32×32; el monocromo a
16×16 y 18×18; el botón de Shields a 18×18 y 36×36 (dos estados); el logotipo pequeño a 77×22. Lo demás sale bien
reduciendo el maestro.

## Imágenes que faltaban en la lista (30/09, LOCAL)

Siguen siendo de Brave en `flyweb` f274035d. Las de servicios desactivados no se cuentan.

| # | Maestro nuevo | Tipo | Ficheros (brave-core) | Tamaños | Dónde se ve |
|---|---|---|---|---|---|
| M6 | **Botón de Shields**, en dos estados: activo y apagado | A | `components/brave_shields/resources/icon.png`, `icon-off.png` | 64×64 y 54×54 | El león a la derecha de la barra de direcciones, en todas las webs. Es el icono de marca que más se ve. Hay que decidir el símbolo: no puede ser el león |
| M7 | **Icono de la extensión interna** (Shields) | A | `components/brave_extension/extension/brave_extension/assets/img/icon-{16,32,48,64,128,256}.png` | 16–256 | `brave://extensions` y permisos. Puede salir de M2 |
| M8 | **Ilustración de bienvenida** | D | `components/brave_welcome_ui/assets/brave_logo_3d@2x.webp` (ya es la mosca provisional); fondos `background@2x.webp` 2992×1756, `sky.webp`, `hill.webp`, `pyramid.webp`; `components/images/lion_logo.svg`, `welcome_{shields,rewards,search,import,bg}.svg` | 200×239 el logo | `brave://welcome`. Los fondos morados son el estilo de Brave: decidir si se cambian |
| M9 | **Piezas de la nueva pestaña** | A | `components/img/newtab/defaultTopSitesIcon/brave.png` (256×300), `components/brave_new_tab_ui/components/default/braveNews/braveNewsLogo.svg`, `components/img/newtab/dummy-branded-wallpaper/logo.png` (512×512) | — | Icono por defecto de un sitio, logo de Noticias (la tarjeta se ocultará), logo del fondo de muestra |
| M10 | **Iconos del paquete de diseño de Brave** | B o A | `@brave/leo` (en `node_modules`, fuera del repo): `product-brave-color.svg`, `product-brave-monochrome.svg`, `product-brave-outline.svg`, `social-brave-favicon.svg`, `leo-color.svg` y los `product-brave-{news,talk,search,wallet,ai,premium}` | SVG | Ajustes y menús de las páginas internas. **Hecho (NUBE, 01/10, paso 23):** de todo el paquete, FlyWeb solo sirve los que lista `ui/webui/resources/BUILD.gn` (`leo_icons`); de marca Brave, solo `product-brave-color` (Ajustes → Acerca de) y `product-brave-monochrome` (sin uso hoy). Los demás no llegan al navegador. Se sustituyen por ficheros propios con el mismo nombre (`ui/webui/resources/flyweb_icons/`), generados con `scripts/leo-icons.py`: el de color es tipo A (placa gris claro), el monocromo tipo B. Con el diseño definitivo, volver a ejecutar el script desde M2/M3 |
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
