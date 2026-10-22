# FlyWeb 2.0.0 — identidad sobre la base 128 (FM.38, IDENTIDAD)

Pasar a la base 128 (brave-core `nube/base-128-motor-p9` abb90752c3 = Brave 1.69.168 + motor) lo que la 1.15.2 (rama
`flyweb` 9401833a66) ya tenía respecto a Brave. Nada nuevo. Ramas de brave-core: trabajo en `nube/base-128-identidad`,
entregas fijas en `nube/base-128-identidad-iN`. Esta página es también la nota de relevo de IDENTIDAD.

## Método (reproducible)

- Ficheros propios = `git diff --name-status v1.57.64 flyweb` sin `patches/` ni `.xtb`: **422** (8 de Android fuera).
- Para cada uno, contra p9: `untouched` (Brave no lo tocó: se copia el de `flyweb`), `clean` (fusión de tres vías limpia),
  `conflict` (a mano), `gone` (Brave lo movió o borró: se reubica a mano). Recuento: 120 / 93 / ~130 / 33; 37 nuevos.
- Las cadenas no se fusionan: se ejecuta `script/flyweb-rebrand-strings.py` sobre la 1.69. **Comprobado:** ejecutado sobre
  `v1.57.64` reproduce las cadenas de `flyweb` salvo dos añadidos a mano (pestañas fijadas compartidas, i3, y los iconos de
  Shields, i1). Necesita `FP.py` de `tools/grit/grit/extern` en `PYTHONPATH` (se baja de Chromium 128).
- Los 121 `.patch` de `flyweb` que no están en p9 son de motor ya de serie en la 128, salvo tres de la versión declarada a
  las extensiones (`minimum_chrome_version_checker`, `chrome_extensions_browser_client`, `update_query_params`): **i3**.

## Bloques

| Bloque | Qué | Estado |
|---|---|---|
| **i1** | Cadenas (script), iconos y logotipos, D-DIN, identidad fija (BRANDING, perfil, llavero, carpeta de apps, versión 2.0.0, número de compilación y commit de origen), `flyweb://`, enlaces de ayuda, sin barra «macOS 11», sin `navigator.brave` | **entregado** `nube/base-128-identidad-i1` 0598ad79f8 |
| i2 | Servicios: Wallet/Rewards/Ads/News/Talk/VPN/Leo fuera o apagados (`enable_ai_chat:false`), `braveEthereum`/`solana`, proxies de Safe Browsing (`network_constants.h`), componentes propios (IDs de Shields, Local Data, clave de editor), stats, P3A, referidos, variations, crash, captive portal, traducción, DevTools remoto, DoH, CoreLocation, webcompat, protocolo del actualizador | pendiente |
| i3 | Funciones: NTP y bienvenida propias, pestañas fijadas compartidas (la 1.69 trae su servicio y su ajuste: comparar), ajustes (Web3, P3A, sync sin QR), buscador DuckDuckGo, versión declarada a las extensiones, fuentes CJK, `brave_license_helper.py` | pendiente |

## i1: adaptaciones a la 1.69 (no son cambios nuevos, son la misma regla donde Brave movió o añadió)

- **Constantes en cabeceras** (`inline constexpr`): `kBraveUIScheme`, `url_constants.h` (más `kFlyWeb*URL`),
  `webui_url_constants.h`, `chrome/common/url_constants.h`. Las ayudas nuevas de la 1.69 (`support.brave.com`) van a
  `flyweb.lamosquita.net/ayuda/` con el ancla más cercana.
- **`brave://` literal** en código que no es de prueba (25 sitios): con el esquema `flyweb` dejarían de abrir.
- **Logotipo nuevo** `product_logo_name_22_white` (1.69): generado del M4 oscuro pequeño con el Chromium del contenedor;
  `generar-marca.sh` lo genera en la Mac.
- **D-DIN también como `Inter Variable`**: la NTP y otras páginas de la 1.69 cargan `inter.css` en vez de Poppins.
- **Botón de Shields** a 18/36 px: la 1.69 usa `LOCATION_BAR_TRAILING_ICON_SIZE`, que Brave fija en 18: igual que la 1.15.
- **`obsolete_system_mac.cc`**: el mismo reemplazo de `IsObsoleteNowOrSoon()`; sin verificar contra el fuente de la 128
  (raw de GitHub limitado por el proxy): si no compila, mirar la firma allí.

## Qué comprobar en la compilación (LOCAL)

`flyweb://version` (logo, «FlyWeb 2.0.0 (motor 131) · Brave 1.69.168»), menús y ajustes en español sin «Brave» salvo
servicios y avisos legales, icono de la app y de las pestañas internas, `navigator.brave` indefinido, el llavero pide
«FlyWeb Safe Storage», perfil en `~/Library/Application Support/LaMosquita/FlyWeb-Development`, sin barra de macOS 11,
`flyweb://settings` y los enlaces «Más información» a `flyweb.lamosquita.net/ayuda`.
