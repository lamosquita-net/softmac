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
| **i2** | Servicios: Wallet (sin `ethereum`/`solana`), Rewards, News, Talk, referidos fuera; Leo y VPN por argumentos (`enable_ai_chat:false`, `enable_brave_vpn:false`); proxies de Safe Browsing, componentes propios (Shields, Local Data, clave de editor), petición del actualizador recortada y sin pings, stats, P3A, variations, crash, captive portal, traducción, DevTools remoto, DoH apagado, WebGPU apagado, JIT permitido, webcompat | **entregado** `nube/base-128-identidad-i2` 2fbba345c9 |
| **i5** | Componente de recursos de Shields propio de la 2.0: ID `nilendadbigifkognoeoodppkjkgmppg`, clave `recursos-20` | **entregado** `nube/base-128-identidad-i5` dff94888fe (**la que hay que compilar**) |
| **i4** | Dominios de servicios de Brave inertes por defecto (`config.js`: `flyweb.invalid`) | **entregado** `nube/base-128-identidad-i4` 95b490bd34 |
| **i3** | Funciones: NTP y bienvenida propias, pestañas fijadas compartidas encendidas, DuckDuckGo por defecto (también en privada), versión declarada a las extensiones (3 parches re-cortados sobre 128), créditos de D-DIN | **entregado** `nube/base-128-identidad-i3` 6cee51d215 |

## i1: adaptaciones a la 1.69 (no son cambios nuevos, son la misma regla donde Brave movió o añadió)

- **Constantes en cabeceras** (`inline constexpr`): `kBraveUIScheme`, `url_constants.h` (más `kFlyWeb*URL`),
  `webui_url_constants.h`, `chrome/common/url_constants.h`. Las ayudas nuevas de la 1.69 (`support.brave.com`) van a
  `flyweb.lamosquita.net/ayuda/` con el ancla más cercana.
- **`brave://` literal** en código que no es de prueba (25 sitios): con el esquema `flyweb` dejarían de abrir.
- **Logotipo nuevo** `product_logo_name_22_white` (1.69): generado del M4 oscuro pequeño con el Chromium del contenedor;
  `generar-marca.sh` lo genera en la Mac.
- **D-DIN también como `Inter Variable`**: la NTP y otras páginas de la 1.69 cargan `inter.css` en vez de Poppins.
- **Botón de Shields** a 18/36 px: la 1.69 usa `LOCATION_BAR_TRAILING_ICON_SIZE`, que Brave fija en 18: igual que la 1.15.
- **`obsolete_system_mac.cc`**: el mismo reemplazo de `IsObsoleteNowOrSoon()`; comprobado en Chromium 128.0.6613.138
  (`namespace ObsoleteSystem`, `MacOSMajorVersion() < 11`). Fuente de Chromium sin descargarlo entero:
  `git fetch --depth 1 --filter=tree:0 https://github.com/chromium/chromium refs/tags/128.0.6613.138` y `git show` por fichero.

## i2: adaptaciones y pendientes

- **Ya de serie en la 1.69, no se llevan:** ECH y clave poscuántica (Chromium 128 los trae encendidos; ML-KEM va por parche
  de SEGURIDAD), CoreLocation (Brave usa `PlatformOnly`), Sync encendido. Las *client hints* son trabajo de MOTOR (p9).
- **DoH:** Chromium 128 ya no lee la *feature* `DnsOverHttps`; se cambia el valor por defecto de la preferencia
  (`chromium_src/chrome/browser/net/stub_resolver_config_reader.cc`).
- **Leo:** `test/BUILD.gn` dependía de `ai_chat/core/browser` fuera de `enable_ai_chat` (el `assert` que vio LOCAL-7).
  VPN: no he encontrado dependencias sin guarda, pero sin `gn` no está probado.
- **Pendiente de servidor (clase H, fuera de este encargo):** el componente de recursos de Shields sigue con el ID de la 1.x;
  `brave-sync-shields.md` §3.4 pide **ID y clave nuevos para la 2.0** (firma en bak) y el catálogo nuevo (`list_catalog.json`,
  con las listas por defecto y de primera parte como entradas `hidden`). Hasta entonces, Shields en la 2.0 puede quedarse sin
  listas por defecto.

## i3: qué no se lleva y por qué

- **Pestañas fijadas compartidas:** Brave 1.69 trae su propia versión de lo que la 1.15 había portado de Brave posterior
  (la misma preferencia `brave.tabs.shared_pinned_tab`, su interruptor en Ajustes, cambio en caliente). Solo se llevan los
  valores por defecto de FlyWeb (encendido). **No** se lleva el arreglo propio de la 1.15 para ventanas restauradas
  (`restored_browsers_`): la 1.69 resuelve la restauración de otra forma; **probar** restaurar sesión y ventana cerrada con
  pestañas fijadas. Si falla, se porta.
- **Fuentes CJK** (`PrefsFontList`, Menlo, `,Osaka,BIZ UDGothic,Menlo`): ya en Chromium 128.
- **«Formularios verticales»** (`writing-mode` en controles): es motor (nivel), no identidad; ya en la base de MOTOR.
- **NTP de la 1.69:** sin los iconos de Ajustes, Marcadores e Historial abajo a la izquierda (los quitó Brave); el
  widget de búsqueda nuevo de la 1.69 (clase E) queda como venga.

## Dominios para `network-audit.py` (COORDINACIÓN-12: cualquier URL de Brave viva es un fallo)

**Regla:** en un arranque limpio y en una navegación normal (nueva pestaña, una web, Ajustes, instalar una extensión),
**ninguna** petición a `*.brave.com`, `*.bravesoftware.com`, `*.brave.software`, `*.brave.io` ni
`*.brave-http-only.com`. Las que sí deben aparecer: `components.flyweb.lamosquita.net`, `sync.flyweb.lamosquita.net`
(si se activa sync), `proxy.flyweb.lamosquita.net`, `updates.flyweb.lamosquita.net` y Google directo (Web Store,
traducción si se activa, Safe Browsing por el proxy).

Las que hay que mirar una a una, porque la 2.0 las tiene en el código (`git grep` en i3, sin pruebas, iOS ni Android):

| Dominio | De qué es | Estado en la 2.0 |
|---|---|---|
| `safebrowsing.brave.com`, `sb-ssl.brave.com`, `safebrowsing2.brave.com`, `redirector.brave.com` | Safe Browsing, CRLSet, Chromecast | Van al proxy propio (`network_constants.h`); aparecer = fallo |
| `clients4.brave.com`, `static1.brave.com` | Sync de Google, autorrelleno | Bloqueados (`blocked.flyweb.invalid`) |
| `crxdownload.brave.com`, `extensionupdater.brave.com`, `go-updater.brave.com`, `componentupdater.brave.com` | Extensiones y componentes | Extensiones directas a Google; componentes, a ns2 por argumento |
| `variations.brave.com`, `laptop-updates.brave.com`, `p3a*.brave.com`, `star.wdp.brave.com` | Variations, stats/referidos, P3A, Web Discovery | No se piden (sin cambio de URL: el código no llega) |
| `translate.brave.com`, `translate-static.brave.com` | Traducción | Directa a Google |
| `devtools.brave.com`, `detectportal.brave-http-only.com`, `cr.brave.com` | DevTools remoto, portal cautivo, informes de fallo | `flyweb.invalid` / apagados |
| `dict.brave.com` | Diccionarios del corrector | **Mirar**: en la 1.15 pasaban por el proxy (`redirector`); confirmar que la 1.69 no los pide aquí |
| `pcdn.brave.com`, `brave-today-cdn.brave.com` | Imágenes de la NTP y News | Componentes de NTP sin registrar y News sin controlador |
| `account.brave.com`, `leo.bravesoftware.com`, `*.rewards.*`, `*.ads.*`, `*.wallet.brave.com`, `talk.brave.com` | Leo, Rewards, anuncios, monedero, Talk | Apagados; aparecer = fallo |
| `search.brave.com` (y `imgs.`, `tiles.`, `cdn.`) | Brave Search | Solo si el usuario lo elige; el widget de búsqueda de la NTP de la 1.69 (clase E) puede pedir sugerencias: **mirar** |

**Dominios de servicios (i4, aprobado por COORDINACIÓN-12):** `brave_services_{production,staging,dev}_domain` valen
`flyweb.invalid` por defecto (`build/commands/lib/config.js`). En la 1.69 solo Leo, News y P3A construyen sus hosts con
`brave_domains::GetServicesDomain()`; ningún servicio propio (componentes, sync, proxy, actualizaciones) los usa.

**Cerrados tras i3:** `dict.brave.com` solo está en la lista de permitidos de la auditoría de Brave (igual en la 1.57/1.15);
ningún código lo pide. El widget de búsqueda de la NTP (`kBraveNtpSearchWidget`, encendido) es **nuevo de la 1.69**: va a
la clase E.

## Shields: lo que falta para la 2.0 (clase H; lo lleva COORDINACIÓN con Titín y SERVIDOR-LOCAL)

- **Hace falta:** un par de claves nuevo para el componente **de recursos** de Shields de la 2.0 (firmado en bak), con su
  ID (los 32 caracteres `a`–`p` del hash de la clave pública), porque `resources.json` de adblock 0.8 no vale para la
  0.7.9 de la 1.x (`brave-sync-shields.md` §3.4). El catálogo sigue con su ID y clave de la 1.x, pero el CRX tiene que
  llevar además `list_catalog.json`.
- **Hecho en -i5** (clave `recursos-20`, #479): `kAdBlockResourceComponentId` = `nilendadbigifkognoeoodppkjkgmppg`
  (comprobado con el SHA-256 de la clave) y su clave pública en `brave_shield_constants.h`. Falta la parte de servidor:
  empaquetar los recursos con el formato 0.8 bajo ese ID y `list_catalog.json` en el catálogo.

## Pestañas fijadas compartidas: por qué el servicio de la 1.69 (decisión de COORDINACIÓN)

COORDINACIÓN-12 pide conservar el comportamiento de la 1.15 y usar el de la 1.69 solo si es equivalente y más barato.

- **Más barato:** sí. El de la 1.15 era el de la 1.57 más arreglos de Brave posterior (b0541dd7aba, 9b010f57069,
  e0f8a1e720f, a172cff31b1) **que la 1.69 ya trae**; llevar el nuestro son 19 conflictos en un fichero que Brave sigue
  cambiando.
- **Equivalente:** igual o mejor en lo visto (misma preferencia `brave.tabs.shared_pinned_tab`, interruptor en Ajustes,
  encendido por defecto con i3, y cambio en caliente en vez de al reiniciar). **Sin comprobar:** la restauración de
  sesión y de ventanas cerradas, que en la 1.15 arregló un fallo visto con ASan (FM.25, 057630a8c). La 1.69 lo trata a su
  manera en `SynchronizeNewBrowser()`. **Prueba para LOCAL:** con dos ventanas y pestañas fijadas, salir y volver a abrir
  (restaurar sesión) y reabrir una ventana cerrada; sin duplicados ni caídas (ASan si se puede). Si falla, porto el
  arreglo de la 1.15 (`restored_browsers_`), que es pequeño.

## Qué comprobar en la compilación (LOCAL)

`flyweb://version` (logo, «FlyWeb 2.0.0 (motor 131) · Brave 1.69.168»), menús y ajustes en español sin «Brave» salvo
servicios y avisos legales, icono de la app y de las pestañas internas, `navigator.brave` indefinido, el llavero pide
«FlyWeb Safe Storage», perfil en `~/Library/Application Support/LaMosquita/FlyWeb-Development`, sin barra de macOS 11,
`flyweb://settings` y los enlaces «Más información» a `flyweb.lamosquita.net/ayuda`.

i2: argumentos `enable_ai_chat:false`, `enable_brave_vpn:false`, `brave_p3a_enabled:false` (primero `gn gen`, barato);
sin `brave_ai_chat_endpoint`, `brave_zero_ex_api_key` ni `enable_updater` (ya no existen en la 1.69, `brave-vs-flyweb.md` §5).
`typeof window.ethereum` y `window.solana` = `undefined`; sin Rewards, News, Talk ni Leo en barra, NTP y barra lateral;
`flyweb://settings/privacy`: DNS seguro apagado; `network-audit.py` en un arranque limpio: nada a `*.brave.com` salvo lo de
componentes que aún no sirva ns2.

i3: NTP con fondos y mosca de FlyWeb y crédito propio, sin velo oscuro; bienvenida con estilo FlyWeb y sin el paso «Ayuda a
mejorar»; pestaña fijada en una ventana aparece en las demás (y restaurar sesión no la duplica); buscador por defecto
DuckDuckGo en normal y privada; instalar una extensión de la Chrome Web Store que pida `minimum_chrome_version` 129–131.

## Trampas (para el relevo)

- **Un PR por entrega, rama nueva desde `main`:** COORDINACIÓN fusiona enseguida. Tres veces se empujó a
  `claude/base-128-identidad` con su PR (#472) ya cerrado y hubo que reaplicarlo a mano (#473, #475). Antes de empujar,
  mirar si el PR de la rama sigue abierto; si no, rama nueva desde `main` y PR nuevo.
- **Fuente de Chromium 128 sin descargarlo:** `raw.githubusercontent.com` da 429 y `googlesource` 403 desde la nube;
  `git fetch --filter=tree:0` del tag y `git show` por fichero funciona (no usar `git grep`: baja medio árbol).
- **`m3.sh` sobre un fichero que Brave borró o movió lo copia entero de la 1.15:** comprobar el destino antes.

## Estado y relevo (IDENTIDAD-1, 22-10 ~15:25)

- **Hecho:** i1–i5 en brave-core; la que se compila es `nube/base-128-identidad-i5` dff94888fe (sobre p9). PR de softmac
  fusionados: #472, #473, #475, #476, #478, #480.
- **Esperando:** errores de compilación de LOCAL (en su fila o por COORDINACIÓN). Arreglos en `nube/base-128-identidad`
  y punto fijo `-i5b`, `-i5c`…; si MOTOR mueve la base (p10…), fusionar la base nueva en `nube/base-128-identidad`
  (sin reescribir) y dar un `-iN` nuevo.
- **Prueba abierta de LOCAL/Titín:** restaurar sesión y reabrir ventana cerrada con pestañas fijadas compartidas; si
  falla, portar el arreglo de FM.25 (`restored_browsers_` en `shared_pinned_tab_service.cc` de `flyweb`).
- **No es de IDENTIDAD:** servidor de Shields (clase H: recursos 0.8 bajo `nilendadbigifkognoeoodppkjkgmppg`,
  `list_catalog.json`, firma en bak), widget de búsqueda de la NTP (clase E), Sparkle y perfil (F).
- **Herramientas que usé** (en el *scratchpad*, no en el repo; se rehacen en minutos): fusión de tres vías por fichero
  (`git merge-file` con base `v1.57.64`, «nuestro» `flyweb` 9401833a, «suyo» la base de la 128), elegir bloques de
  conflicto por lado, y llevar valores de constantes de un `.cc` de la 1.57 a la cabecera `inline constexpr` de la 1.69
  (por nombre de constante, también `char16_t`). Clonado: `git init` + `git fetch --depth 1` de los sha concretos.

## Estado y relevo (IDENTIDAD-2, 22-10 ~17:45)

- **Hecho:** `nube/base-128-motor-p13` 8f3bcc24aa sobre `-p12` ae5626ab1a: los 9 arreglos de LOCAL-9 (fila FM.38).
  Los fijos de MOTOR e IDENTIDAD ya van en la misma serie `-pN` (encargo de COORDINACIÓN-12), no en `-iN`.
- **Decisiones que tomé (revisables):** (d) sin widget de búsqueda en la NTP, como la 1.15, en vez de cambiar el icono:
  el de la 1.69 busca con Brave Search por defecto (`components/brave_new_tab_ui/components/search/config.ts`), así que
  cambiar solo el icono habría escondido una fuga; si se quiere el widget, es clase E (buscador por defecto del navegador
  y sin Brave Search). (f) apagar `ignore_patch_version_number` hace que cada subida de versión recompile ~2300
  objetivos (lo dice Brave): asumible, las versiones cambian poco.
- **Esperando:** compilación y pruebas de LOCAL (identidad y `network-audit.py --mode reposo` en la 6,1). En reposo ya
  no debería salir DIAL (`:8008`) y el cliente de Safe Browsing debe declarar 131.0.6778.265.
