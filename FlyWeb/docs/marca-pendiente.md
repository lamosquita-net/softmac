# FlyWeb — Marca Brave visible en la interfaz (F1.8)

Inventario de lo que todavía dice o muestra "Brave". Parte de las capturas del paso 0 (29/09, LOCAL y HUMANO)
y de la lectura del código de brave-core 1.57.64 y Chromium 116. Complementa a [`rebranding.md`](rebranding.md),
que trata la identidad (bundle id, perfil, llavero) y los servicios.

Estados: **rama** = arreglado en una rama `nube/*` aún sin integrar; **hecho** = ya en `flyweb`;
**pendiente**; **se queda** = decisión de no cambiarlo.

## `brave://version`

| Qué se ve | De dónde sale | Estado |
|---|---|---|
| Etiqueta "Brave:" | `IDS_PRODUCT_NAME` (`app/brave_strings.grd`) | **rama** `nube/l10n` (paso 5) → "FlyWeb" |
| Logo (león + "brave") | `IDR_PRODUCT_LOGO`/`_WHITE` = `components/resources/default_{100,200}_percent/brave/product_logo{,_white}.png` | **rama** `nube/branding-ui` (paso 7) |
| Empresa ("Brave Software Inc"; en español "Los creadores de Brave") | `IDS_ABOUT_VERSION_COMPANY_NAME` | **rama** `nube/l10n` b91686cc → "lamosquita" en todos los idiomas |
| Copyright | `IDS_ABOUT_VERSION_COPYRIGHT` | **rama** `nube/l10n` 8db1ad26 (paso 5b): "lamosquita and The Brave Authors"; en español "lamosquita y los creadores de Brave"; resto de idiomas en inglés (decisión HUMANO). El paso 5 lo había dejado en "Los creadores de FlyWeb", atribución falsa |
| "Revisión" 25c5f015 (el tag 1.57.64) | `build/util/LASTCHANGE`, que escribe el hook `brave_lastchange` de brave-core `DEPS`: último commit cuyo mensaje es una versión (`^1.57.64$`), y solo en `gclient sync` | **hecho** en `build.sh`: ejecuta `lastchange.py` sin filtro → commit de `flyweb` que se compila |
| Versión "1.57.64 Chromium: 116…" | `kBraveVersionNumberForDisplay` | **se queda** por ahora: es la versión real de la base. Cambiarla afecta a la cadena de user agent y a los componentes de Brave (piden por versión) |

## Iconos y logotipos

| Qué se ve | De dónde sale | Estado |
|---|---|---|
| Icono de la app, Dock, notificaciones | `app/theme/brave/mac/*.icns`, `product_logo_{22..256}.png` | **hecho** (77b25c6b) |
| Icono de las pestañas de páginas internas (`brave://…`) | `chrome://theme/current-channel-logo` → `product_logo_32*` de `app/theme/default_{100,200}_percent/brave/` (en `Static` es `_development`) | **rama** `nube/branding-ui` |
| León de la barra de direcciones (páginas internas) | `vector_icons/components/omnibox/browser/vector_icons/product.icon` | **rama** `nube/branding-ui` (silueta de la mosca, color según el tema) |
| León de notificaciones / otros sitios | `vector_icons/ui/message_center/…/product.icon`, `components/vector_icons/brave/product.icon` | **rama** `nube/branding-ui` |
| Logotipos con nombre (`product_logo_name_22/48`, `product_logo_white`) | `app/theme/default_{100,200}_percent/brave/` | **rama** `nube/branding-ui` |
| Triángulo de Rewards (BAT) en la barra | Brave Rewards | **rama** `nube/no-wallet` (paso 6): Rewards desactivado en código |
| León 3D de la página de bienvenida | `components/brave_welcome_ui/assets/brave_logo_3d@2x.webp` | **rama** `nube/branding-ui` |

Todo lo de `nube/branding-ui` sale del SVG provisional (`FlyWeb/branding/icon_FlyWeb.svg`). El texto
"FlyWeb" de los logotipos usa DejaVu Sans Bold, también provisional. Cuando haya icono definitivo, se
regeneran con el mismo procedimiento (`FlyWeb/branding/scripts/`).

## Textos

| Qué se ve | Estado |
|---|---|
| Menús y ajustes ("Salir de Brave", "Acerca de Brave"…) | **rama** `nube/l10n` (paso 5) |
| Etiqueta "Brave" de la barra de direcciones en páginas internas | `IDS_SHORT_PRODUCT_NAME` → **rama** `nube/l10n` |
| "Brave Rewards", "Brave Wallet", "Brave News", "Brave Search"… | **se queda**: son servicios de Brave con su nombre (y Wallet/Rewards desaparecen con el paso 6) |
| Avisos legales que nombran a Brave Software (marca registrada, descargos) | **se queda**. `nube/l10n` los estropeaba ("FlyWeb is a registered trademark of Brave Software", falso): corregido en b91686cc |

## Página de nueva pestaña (NTP)

| Qué se ve | Estado |
|---|---|
| Fondos de imagen (fotografías con crédito del autor) | **se queda**: no son marca de Brave |
| **Imágenes patrocinadas** (Sponsored Images) y fondos de "super referral" | **rama** `nube/no-sponsored-images` 8c984d70 (paso 8): sus componentes no se registran ni se descargan; solo quedan las fotografías |
| Estadísticas de Brave (anuncios y rastreadores bloqueados, tiempo ahorrado) | **se queda**: son de Shields y útiles |
| Tarjetas de Brave News, Brave Talk | pendiente: ocultarlas por defecto (preferencias), Brave News hace peticiones a Brave |

## Después (F7.1, sin fecha)

- Esquema `flyweb://` en lugar de `brave://`.
- Página de inicio propia.

Imágenes que hay que diseñar para sustituir las provisionales: [`../branding/imagenes.md`](../branding/imagenes.md).
