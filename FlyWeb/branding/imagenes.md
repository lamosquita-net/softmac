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
