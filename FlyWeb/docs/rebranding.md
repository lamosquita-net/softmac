# Rebranding de Brave 1.57.64 → FlyWeb

Inventario de lo que hay que tocar para sacar **FlyWeb** (bundle id `net.lamosquita.flyweb`, macOS x86_64,
objetivo Mojave) a partir de `brave-core` **v1.57.64** (Chromium **116.0.5845.188**).

- Rutas sin prefijo = relativas a la raíz de `brave-core` (en el checkout de compilación: `src/brave/`).
- Rutas con prefijo `src/` = Chromium 116.0.5845.188.
- Todo lo citado se ha visto en el código de esas versiones. Lo que es deducción se marca **(sin verificar)**.

---

## 0. Cómo aplica Brave la marca (necesario para entender el resto)

| Pieza | Dónde | Qué hace |
|---|---|---|
| `branding_path_component: "brave"` y `branding_path_product` | `build/commands/lib/config.js` (`buildArgs()`, ~l. 303) | Args de gn. `getBrandingPathProduct()` devuelve `"brave"` en builds oficiales y `"brave-development"` si no. |
| `branding_file_path = "//chrome/app/theme/$branding_path_component/BRANDING"` | `src/build/config/chrome_build.gni` | Chromium lee de ahí el nombre y los ids. |
| `exec_script("version.py", … BRANDING)` → `chrome_product_full_name`, `chrome_product_short_name`, `chrome_mac_bundle_id`, `chrome_mac_creator_code`, `chrome_mac_team_id` | `src/build/util/branding.gni` | Variables gn que usa todo el árbol. |
| `updateBranding()` | `build/commands/lib/util.js` (~l. 209–320) | Se ejecuta en cada `npm run build`. Copia `app/theme/brave/` a `src/chrome/app/theme/brave/` **y** a `src/chrome/app/theme/chromium/`, más `app/theme/default_{100,200}_percent/{brave,common}`, `components/resources/default_*`, imágenes de settings/signin, etc. En macOS elige `BRANDING.<canal>` y `mac/<canal>/app.icns` según el canal. |
| `import("//brave/build/config/brave_build.gni")` | `patches/build-config-chrome_build.gni.patch` | Inyecta los `.gni` de Brave en `chrome_build.gni`. `build/config/brave_build.gni` **no** define marca: solo importa otros `.gni` (entitlements, `build/mac/config.gni`, sources…). |

**Consecuencia práctica:** lo más barato es **mantener el nombre de carpeta interno `brave`** (valor de
`branding_path_component`) y cambiar su *contenido*. Cambiar `branding_path_component` obliga a tocar
`config.js`, `util.js` y los `.grd` que referencian `brave/…`.

**Canales:** `config.js` pone `channel = 'development'` salvo en `Release` (→ `''`, estable). Una build
Component/Static usa `BRANDING.development`, `mac/development/app.icns` y el sufijo de perfil `-Development`.
Hay que rebrandear **como mínimo `BRANDING` y `BRANDING.development`** (y borrar o igualar `beta`, `dev`, `nightly`).

---

## 1. Nombre del producto e identificadores en macOS

| Identificador | Valor actual | Dónde se define | Cambio |
|---|---|---|---|
| Nombre completo (`.app`, menús del sistema, `CFBundleName`) | `Brave Browser` | `app/theme/brave/BRANDING` → `PRODUCT_FULLNAME` | `FlyWeb` |
| Nombre corto | `Brave` | `BRANDING` → `PRODUCT_SHORTNAME` | `FlyWeb` |
| Empresa | `Brave Software, Inc.` / `Brave Software` | `BRANDING` → `COMPANY_FULLNAME`, `COMPANY_SHORTNAME` | `lamosquita.net` |
| Copyright | `Copyright 2016 The Brave Authors…` | `BRANDING` → `COPYRIGHT` | Mantener el de Brave (MPL) y añadir el propio |
| Bundle id | `com.brave.Browser` (`.beta`, `.dev`, `.nightly`, `.development`) | `BRANDING*` → `MAC_BUNDLE_ID` | `net.lamosquita.flyweb` (y p. ej. `net.lamosquita.flyweb.development`) |
| Team ID | `KL8N8XSYF4` (Brave) | `BRANDING*` → `MAC_TEAM_ID` → `chrome_mac_team_id` | Team ID propio (se usa en entitlements y notarización, ver §5) |
| Creator code | `Cr24` | `BRANDING*` → `MAC_CREATOR_CODE` | Puede quedarse |
| Instalador | `Brave Installer` | `BRANDING*` → `PRODUCT_INSTALLER_*` | `FlyWeb Installer` (solo Windows en la práctica) |
| Nombre de `.app` / `.dmg` / `.pkg` | `$chrome_product_full_name.app/.dmg/.pkg` | `build/config.gni` (l. ~120) | Automático desde `BRANDING` |
| Framework | `Brave Browser Framework` | `src/chrome/BUILD.gn`: `chrome_framework_name = chrome_product_full_name + " Framework"` | Automático |
| Helpers (procesos) | `Brave Browser Helper`, `… (Renderer)`, `… (GPU)`, `… (Plugin)`, `… (Alerts)` | `src/chrome/BUILD.gn`: `chrome_helper_name = chrome_product_full_name + " Helper"`; sufijos en `src/content/public/app/mac_helpers.gni` | Automático → `FlyWeb Helper (Renderer)`, etc. |
| Bundle id de helpers | `com.brave.Browser.helper[.renderer/.plugin/.alerts]` | `src/chrome/app/helper-Info.plist`: `${CHROMIUM_BUNDLE_ID}.helper${CHROMIUM_HELPER_BUNDLE_ID_SUFFIX}` | Automático → `net.lamosquita.flyweb.helper…` |
| `IDS_HELPER_NAME` / `IDS_APP_MENU_PRODUCT_NAME` | `Brave Helper` / `Brave` | `app/brave_strings.grd` (l. ~853–860) | Cambiar texto (ver §3) |
| Carpeta de perfil | `~/Library/Application Support/BraveSoftware/Brave-Browser[-Development/-Beta/-Dev/-Nightly]` | `build/config.gni`: `brave_product_dir_name = "BraveSoftware/Brave-Browser$brave_product_dir_name_suffix"` → `build/mac/tweak_info_plist.py` lo escribe como `CrProductDirName` en el `Info.plist` (targets `brave_app_plist` / `brave_helper_plist` en `BUILD.gn`, l. ~578–610) → lo lee `src/chrome/common/chrome_paths_mac.mm` (`ProductDirNameForBundle`) | Cambiar a p. ej. `LaMosquita/FlyWeb` (+ sufijo `-Development` en no oficiales) |
| Carpeta de accesos de web apps | `Brave Browser Apps.localized` (y variantes por canal) | `chromium_src/chrome/browser/web_applications/os_integration/web_app_shortcut_mac.mm` (l. 20–28) | `FlyWeb Apps.localized` |
| Keychain (Safe Storage) | servicio `Brave Safe Storage`, cuenta `Brave` | `chromium_src/components/os_crypt/sync/keychain_password_mac.mm` (`kBraveDefaultServiceName`, `kBraveDefaultAccountName`) | `FlyWeb Safe Storage` / `FlyWeb` |
| `BRAVE_PRODUCT_STRING` (`PRODUCT_STRING` en macOS) | `$chrome_product_full_name` | `common/BUILD.gn` (l. 122) → `chromium_src/chrome/common/chrome_constants.cc` | Automático |
| Nombre de artefactos de `create_dist` | `brave-v…-darwin-x64.zip` | `build/config.gni`: `brave_product_name = "brave"`; también `script/lib/config.py` (`npm_config_brave_product_name`) | Opcional: `--gn=brave_product_name:"flyweb"` o `npm config brave_product_name` |
| Canal en tiempo de ejecución | `KSChannelID` del Info.plist | `build/mac/tweak_info_plist.py` y `chromium_src/chrome/common/channel_info_mac.mm` | Sin cambio (estable = sin `KSChannelID`) |
| URL de Sparkle en config.gni | `https://updates.bravesoftware.com/sparkle/Brave-Browser` | `build/config.gni` (`base_sparkle_update_url`) | Irrelevante si se desactiva Sparkle (§4) |

---

## 2. Iconos y recursos gráficos

### 2.1 Iconos de la app (macOS)

| Fichero | Uso | Contenido actual (tipos `.icns`) |
|---|---|---|
| `app/theme/brave/mac/app.icns` | Icono de la app, canal estable. `util.js` lo copia a `src/chrome/app/theme/brave/mac/app.icns`; `src/chrome/BUILD.gn` (l. ~662) lo mete en el bundle | `ic04` 16, `ic05` 32, `ic11` 16@2x, `ic12` 32@2x, `ic07` 128, `ic13` 128@2x, `ic08` 256, `ic14` 256@2x, `ic09` 512, `ic10` 512@2x (1024) |
| `app/theme/brave/mac/{beta,dev,development,nightly}/app.icns` | Icono por canal (`development` es el de las builds no Release) | Igual |
| `app/theme/brave/mac/document.icns` | Icono de documentos (`src/chrome/BUILD.gn`, l. ~669) | Igual |
| `build/mac/dmg.icns`, `dmg-{beta,dev,development,nightly}.icns` | Icono del volumen `.dmg` | (sin verificar tamaños; generar el mismo juego) |
| `build/mac/dmg-background.png`, `build/mac/DS_Store*` | Fondo y disposición del `.dmg` | `DS_Store` guarda posiciones con el nombre `Brave Browser.app` → regenerar **(sin verificar)** |

Generación con `iconutil`: un `FlyWeb.iconset` con `icon_16x16.png`, `icon_16x16@2x.png` (32),
`icon_32x32.png`, `icon_32x32@2x.png` (64), `icon_128x128.png`, `icon_128x128@2x.png` (256),
`icon_256x256.png`, `icon_256x256@2x.png` (512), `icon_512x512.png`, `icon_512x512@2x.png` (1024),
todo a partir de `FlyWeb/branding/` (SVG maestro de 1024×1024).

### 2.2 PNG de producto (resource packs)

| Ruta | Tamaño(s) | Notas |
|---|---|---|
| `app/theme/brave/product_logo_{22,24,48,64,128,256}.png` | 22, 24, 48, 64, 128, 256 px | También `product_logo_22_mono.png` (22) y `product_logo_128_{beta,dev,development,nightly}.png` |
| `app/theme/default_100_percent/brave/product_logo_{16,32}.png` | 16, 32 | + `product_logo_32_{beta,dev,development,nightly}.png` (referenciados como `IDR_PRODUCT_LOGO_32_*` en `app/theme/brave_theme_resources.grd`) |
| `app/theme/default_200_percent/brave/product_logo_{16,32}.png` | 32, 64 | @2x de lo anterior |
| `app/theme/default_100_percent/brave/product_logo_name_22.png` / `_48.png` | 77×22 / 164×48 | Logotipo con nombre |
| `app/theme/default_200_percent/brave/product_logo_name_22.png` / `_48.png` | 154×44 / 328×96 | @2x |
| `app/theme/default_{100,200}_percent/brave/product_logo_white.png` | 214×64 / 428×128 | |
| `components/resources/default_100_percent/brave/product_logo.png`, `product_logo_white.png` | 164×48 | `util.js` los copia también sobre `src/components/resources/default_*/chromium/` |
| `components/resources/default_200_percent/brave/product_logo.png`, `product_logo_white.png` | 328×96 | |
| `app/theme/default_{100,200}_percent/brave/linux/…` y `app/theme/brave/{linux,win,android}/` | — | No afectan a macOS; se pueden dejar |

La página "Acerca de" de ajustes usa los `IDR_PRODUCT_LOGO_*` de Chromium, que salen de estos PNG
**(sin verificar el recurso exacto en 116)**.

### 2.3 Logotipos en páginas internas (WebUI)

| Página | Ficheros |
|---|---|
| Bienvenida (`brave://welcome`) | `components/brave_welcome_ui/components/images/lion_logo.svg` (importado en `components/images/index.ts`), `components/brave_welcome_ui/assets/brave_logo_3d@2x.webp` (importado en `components/welcome/index.tsx`) |
| Nueva pestaña | Fondo por defecto en `components/brave_new_tab_ui/data/backgrounds.ts` (`dylan-malval_sea-min.webp`, el resto llega por el componente de NTP); sitios por defecto con enlaces a Brave (App Store de Brave, `brave.com`, Facebook de BraveSoftware) en `components/brave_new_tab_ui/data/defaultTopSites.ts`; logotipo de Brave News en `components/brave_new_tab_ui/components/default/braveNews/braveNewsLogo.svg` |
| Wallet | `components/brave_wallet_ui/page/screens/send/assets/brave-logo-{dark,light}.svg` (solo si se deja Wallet) |
| Ajustes / signin / perfiles | Directorios que `util.js` copia sobre Chromium: `browser/resources/settings/images/`, `browser/resources/signin/images/`, `browser/resources/signin/profile_picker/images/`, `browser/resources/signin/profile_customization/images/` (revisar si llevan marca, **sin verificar**) |
| Otros | `browser/resources/chrome-logo-faded.png`; iconos vectoriales en `components/vector_icons/brave/` (copiados a `src/components/vector_icons/brave/`) |

---

## 3. Cadenas visibles con "Brave"

**No hay un mecanismo central de sustitución.** Existen `IDS_PRODUCT_NAME` / `IDS_SHORT_PRODUCT_NAME`
(`app/brave_strings.grd`, l. ~287–300, valor `Brave`), pero la inmensa mayoría de mensajes llevan "Brave"
escrito literalmente (en `brave_strings.grd` hay 510 apariciones; solo ~74 líneas con `PRODUCT_NAME`/`ph name`).

### 3.1 Cómo se generan

- `app/brave_strings.grd`, `app/settings_brave_strings.grdp`, `components/components_brave_strings.grd` y los
  `*_override.grd(p)` se **generan desde las cadenas de Chromium** con `script/chromium-rebase-l10n.py`,
  que aplica las sustituciones de `script/lib/l10n/grd_string_replacements.py`
  (`branding_replacements`: `Chromium`→`Brave`, `Google Chrome`→`Brave`, `Chrome`→`Brave`, …; `fixup_replacements`
  para deshacer casos como `Brave Drive`→`Google Drive`).
- `util.js` (`updateBranding`) copia esos `.grd` sobre `src/chrome/app/`, `src/components/` y copia las
  traducciones `.xtb` de `app/resources/` y `components/strings/`.
- Cadenas propias de Brave (no generadas): `app/brave_generated_resources.grd` (75 apariciones),
  `components/resources/brave_components_strings.grd` (112) y sus `.grdp` (`rewards_strings`, `wallet_strings`,
  `brave_vpn_strings`, `brave_news_strings`, `brave_welcome_strings`, `tor_strings`, …).
- Traducciones: 648 ficheros `.xtb` contienen "Brave".
- Extensión integrada: `components/brave_extension/extension/brave_extension/_locales/*/messages.json`.

### 3.2 Propuesta

1. Añadir `('Brave', 'FlyWeb')` al final de las sustituciones (o cambiar los destinos `r'Brave'` por `r'FlyWeb'`
   en `script/lib/l10n/grd_string_replacements.py`) y regenerar con `script/chromium-rebase-l10n.py`.
2. En `brave_generated_resources.grd`, `brave_components_strings.grd`, sus `.grdp` y los `.xtb`: sustitución
   con script **solo de "Brave" como marca del navegador**, respetando nombres de servicios que se quitan
   (Brave Rewards/Wallet/VPN/News/Talk/Search: si el servicio se deshabilita, no merece la pena traducirlo).
3. Revisar a mano lo que se ve en macOS: menú de la app ("Acerca de / Ocultar / Salir de FlyWeb"),
   `IDS_HELPER_NAME`, diálogo de primer arranque, "Acerca de", `brave://settings`.
4. Literales en C++ (no en `.grd`): `chromium_src/components/embedder_support/user_agent_utils.cc`
   (`kBraveBrandNameForCHUA = "Brave"`, marca del client hint `Sec-CH-UA`), `browser/about_flags.cc` (l. ~172),
   `components/search_engines/brave_prepopulated_engines.cc` (Brave Search, l. ~187) — ver §6.

---

## 4. Servicios de Brave que llaman a casa

Los args se pasan en `brave-browser` con `npm run build -- Release --gn=<clave>:<valor>` (opción `--gn`,
declarada en `build/commands/scripts/commands.js` l. 145, procesada en `config.js` l. ~1023 y mezclada al final de
`buildArgs()` con `...this.extraGnArgs`), o como claves de `npm config` / `.npmrc` / `.env` que lee `getNPMConfig()`.

**Ojo:** en builds oficiales (`Release`), varios `BUILD.gn` hacen `assert(… != "")`. Si no se dan valores,
**la configuración de gn falla**. Hay que darles una URL inerte (p. ej. `https://no-thanks.invalid`, que Brave
ya usa como `kDummyUrl` en `app/brave_main_delegate.cc`):

| Arg gn (clave npm) | Assert en |
|---|---|
| `updater_prod_endpoint`, `updater_dev_endpoint` | `components/update_client/BUILD.gn` |
| `brave_stats_updater_url` | `browser/brave_stats/BUILD.gn` |
| `brave_sync_endpoint` | `components/brave_sync/BUILD.gn` |
| `brave_variations_server_url` | `components/variations/BUILD.gn` |
| `brave_services_key` | `components/constants/BUILD.gn` |

### 4.1 Tabla de servicios

| Servicio | Mecanismo en 1.57.64 | Flag / arg exacto | Acción para FlyWeb |
|---|---|---|---|
| **Actualizaciones (Sparkle)** | `enable_sparkle = !is_component_build && is_mac` (`build/config.gni`) → `ENABLE_SPARKLE` (`browser/BUILD.gn`); feed **fijo** `https://updates.bravesoftware.com/sparkle/Brave-Browser/<canal>/appcast.xml` en `browser/mac/sparkle_glue.mm` (l. ~450) | `enable_sparkle`, `build_sparkle`, `sparkle_eddsa_public_key` | `--gn=enable_sparkle:false`. Si algún día se quiere Sparkle propio, cambiar el feed en `sparkle_glue.mm` |
| Updater de Chromium | `enable_updater`, `enable_update_notifications` (declarados en `src/chrome/browser/buildflags.gni`); `config.js` los fuerza a `isOfficialBuild()` | `enable_updater`, `enable_update_notifications` | `--gn=enable_updater:false --gn=enable_update_notifications:false` (efecto exacto en macOS **sin verificar**) |
| **Componentes (go-updater)** | `GetUpdateURLHost()` en `app/brave_main_delegate.cc` pasa `UPDATER_PROD_ENDPOINT`/`_DEV_` como `--component-updater`; también lo usan Greaselion y la cabecera de clave de servicio | `updater_prod_endpoint`, `updater_dev_endpoint` | Decisión: URL inerte = sin listas de Shields/adblock actualizadas, sin Widevine, sin fondos de NTP, sin Greaselion. Alternativa: apuntar al go-updater de Brave (llama a casa, pero es lo que hace funcionar Shields). Ver §6 |
| **Rewards / Ads** | Sin flag de gn para desactivarlo entero. Solo `enable_gemini_wallet` y los args de Uphold/bitFlyer/Gemini (`components/brave_rewards/core/config.gni`). Política `BraveRewardsDisabled` (`browser/policy/brave_simple_policy_map.h`) | `enable_gemini_wallet`, `enable_greaselion` (usado por Rewards) | `--gn=enable_gemini_wallet:false --gn=enable_greaselion:false`; dejar vacíos los args de proveedores; forzar `brave_rewards::prefs::kDisabledByPolicy` o parchear la UI (**sin verificar** qué basta) |
| **Wallet** | Sin flag de gn. Feature `kNativeBraveWalletFeature` activada por defecto (`components/brave_wallet/common/features.cc`); política `BraveWalletDisabled` | `ethereum_remote_client_enabled` (extensión antigua de wallet); `brave_infura_project_id`, `brave_zero_ex_api_key`, `sardine_client_id/secret` vacíos | `--gn=ethereum_remote_client_enabled:false`; parche para poner `kNativeBraveWalletFeature` a `FEATURE_DISABLED_BY_DEFAULT` o `kDisabledByPolicy` por defecto |
| **VPN** | `components/brave_vpn/common/buildflags/buildflags.gni` | `enable_brave_vpn`, `enable_brave_vpn_panel` | `--gn=enable_brave_vpn:false --gn=enable_brave_vpn_panel:false` (además evita el entitlement de VPN, §5) |
| **News** | Sin flag de gn. Opt-in: `kBraveNewsOptedIn` = `false`; `kNewTabPageShowToday` depende del idioma (`components/brave_news/browser/brave_news_controller.cc` l. 71–73) | — | Parche: `kNewTabPageShowToday` = `false` y ocultar tarjeta |
| **Talk** | Sin flag. Sidebar `kBraveTalkURL = "https://talk.brave.com/widget"` (`components/sidebar/constants.h`); tarjeta de NTP `kNewTabPageShowBraveTalk = true` (`browser/brave_profile_prefs.cc` l. ~355) | — | Parche: pref a `false` y quitar el item `kBraveTalk` de la sidebar |
| **Sync** | Opt-in; endpoint en `chromium_src/chrome/app/chrome_main_delegate.cc` (`--sync-url`) | `brave_sync_endpoint` | URL inerte (obligatoria en oficial) y ocultar `brave://settings/braveSync` (**sin verificar** cómo) |
| **P3A / P2A / estadísticas anónimas** | `components/p3a/buildflags.gni` → `BRAVE_P3A_ENABLED` (usado en `browser/brave_browser_process_impl.cc`) | `brave_p3a_enabled`, `p3a_json_upload_url`, `p3a_creative_upload_url`, `p2a_json_upload_url`, `p3a_constellation_upload_url`, `star_randomness_host` | `--gn=brave_p3a_enabled:false` y URLs vacías |
| **Stats ping (usage)** | `BraveStatsUpdater` se crea siempre (`brave_browser_process_impl.cc` l. 141); pref `kStatsReportingEnabled` por defecto `true` (`browser/brave_stats/brave_stats_updater.cc` l. 464); servidor `BRAVE_USAGE_SERVER` | `brave_stats_updater_url`, `brave_stats_api_key` | URL inerte + parche: `kStatsReportingEnabled` a `false` o no crear el updater |
| **Referrals** | `brave_referrals_service()` se llama siempre en `brave_browser_process_impl.cc` l. 127; host `kBraveReferralsServer = "laptop-updates.brave.com"` (`components/constants/network_constants.cc`) | — (sin flag) | Parche: no instanciar el servicio |
| **Leo / AI Chat** | `enable_ai_chat` por defecto **solo** en canal `nightly`/`development` (`components/ai_chat/common/buildflags/buildflags.gni`) → activado en builds Component/Static | `enable_ai_chat`, `brave_ai_chat_endpoint` | `--gn=enable_ai_chat:false` siempre |
| **Variations (field trials)** | `--variations-server-url` en `chromium_src/chrome/app/chrome_main_delegate.cc` | `brave_variations_server_url` | URL inerte (obligatoria en oficial) |
| **Safe Browsing** | `safe_browsing_mode: 1` en `config.js`; si `safebrowsing_api_endpoint` no está vacío, redirige `safebrowsing.googleapis.com` a ese host (`browser/net/brave_static_redirect_network_delegate_helper.cc`); si está vacío va directo a Google, que exige `google_api_key` (`src/google_apis/BUILD.gn`) | `safe_browsing_mode` (Chromium, `src/components/safe_browsing/buildflags.gni`), `safebrowsing_api_endpoint` | Opción A: `--gn=safe_browsing_mode:0` (sin Safe Browsing). Opción B: clave de Google propia (`google_api_key`) y endpoint vacío. Qué pasa con modo 1 sin clave: **sin verificar** |
| Geolocalización | `GOOGLEAPIS_URL = brave_google_api_endpoint + brave_google_api_key` (`browser/net/BUILD.gn`); por defecto clave `AIzaSyAREPLACEWITHYOUROWNGOOGLEAPIKEY2Q` en `config.js` | `brave_google_api_key`, `brave_google_api_endpoint` | Dejar sin clave válida (sin geolocalización) o clave propia |
| Clave de servicios Brave | Cabecera añadida a `*.brave.com`/`*.bravesoftware.com` | `brave_services_key` | Valor ficticio (obligatorio en oficial) |
| Informes de compatibilidad | `webcompat_report_api_endpoint = "https://webcompat.brave.com/1/webcompat"` | `webcompat_report_api_endpoint` | URL inerte |
| Informes de fallos | `chromium_src/components/crash/core/app/crash_reporter_client.cc` devuelve `https://cr.brave.com` | — | Parche: URL vacía/propia (solo sube con consentimiento, **sin verificar**) |
| Otros opcionales | IPFS, Tor, Wayback Machine, WebTorrent, Speedreader, Playlist | `enable_ipfs`, `enable_tor`, `enable_brave_wayback_machine`, `enable_brave_webtorrent`, `enable_speedreader`, `enable_playlist` | Desactivar lo que no se quiera mantener (menos superficie, menos cadenas "Brave") |

Políticas de Brave disponibles como alternativa en tiempo de ejecución (útiles para las Mac del estudio
sin tocar código): `BraveRewardsDisabled`, `BraveWalletDisabled`, `BraveVPNDisabled`, `TorDisabled`,
`IPFSEnabled`, `BraveShieldsDisabledForUrls`, `BraveShieldsEnabledForUrls` (`browser/policy/brave_simple_policy_map.h`,
definiciones en `script/policy_source_helper.py`).

---

## 5. Firma y notarización

### 5.1 Qué pasa `config.js` en macOS

`shouldSign()` es cierto si no es build de componente, no hay `--skip_signing` y `mac_signing_identifier` está
definido. Entonces `buildArgs()` añade:

| Arg gn | Origen (npm config / opción CLI) | Declarado en |
|---|---|---|
| `mac_signing_identifier` | `mac_signing_identifier` / `--mac_signing_identifier` | `build/mac/config.gni` ("find with `security find-identity -v -p codesigning`") |
| `mac_installer_signing_identifier` | `mac_installer_signing_identifier` | `build/mac/config.gni` |
| `mac_signing_keychain` (def. `login`) | `mac_signing_keychain` / `--mac_signing_keychain` | `build/mac/config.gni` |
| `notarize`, `notary_user`, `notary_password` | `--notarize`, `notary_user`, `notary_password` | `build/mac/config.gni` |
| `skip_signing` | `--skip_signing` | `build/config.gni` |
| `allow_runtime_configurable_key_storage: true` | siempre en darwin | Chromium |

`sign_dmg` usa `certificate leaf = H"$mac_signing_identifier"` (`build/mac/BUILD.gn` l. ~427): el identificador
debe ser el **hash SHA-1 de 40 caracteres** del certificado, no el nombre.

### 5.2 Flujo

`build/mac/BUILD.gn` → acción `sign_app` → `build/mac/sign_app.sh` → `sign_chrome.py` de Chromium
(parcheado: `patches/chrome-installer-mac-signing-*.patch`) → `script/signing_helper.py`
(`BraveModifyPartsForSigning`, `GetBraveSigningConfig`).

### 5.3 Qué hace falta para firmar con un Developer ID propio

1. **Certificado** "Developer ID Application" (y "Developer ID Installer" para el `.pkg`) en el llavero;
   pasar su SHA-1 como `mac_signing_identifier`.
2. **`MAC_TEAM_ID`** propio en `app/theme/brave/BRANDING*`: se usa en `CHROMIUM_TEAM_ID` de los entitlements
   (`src/chrome/BUILD.gn` l. ~754) y como `--notary-asc-provider`.
3. **Perfil de aprovisionamiento.** En builds oficiales `sign_app` exige
   `build/mac/release.provisionprofile` (o `${brave_channel}.provisionprofile`); los que trae el repo son de Brave
   (contienen `com.brave.Browser`). Para builds no oficiales usa `dummy.provisionprofile` y `--development`.
4. **Entitlements restringidos.** `app/entitlements.gni` añade en builds oficiales
   `//brave/app/app-entitlements-brave.plist` (VPN: `com.apple.developer.networking.vpn.api`) y
   `//chrome/app/app-entitlements-chrome.plist` (`com.apple.application-identifier`, `keychain-access-groups`
   `…devicetrust`/`…webauthn`, `associated-domains.applinks.read-write`, `web-browser.public-key-credential`).
   Estos entitlements exigen un perfil que los cubra; sin él macOS mata la app al arrancar **(sin verificar en
   Mojave)**. Dos opciones:
   - a) Crear en Apple Developer un perfil Developer ID para `net.lamosquita.flyweb` con esas capacidades y
     ponerlo como `build/mac/release.provisionprofile`.
   - b) **Recomendado**: vaciar `brave_entitlements_templates` en `app/entitlements.gni` (sin VPN, y la
     `public-key-credential` es de macOS 13.3+ de todos modos) y firmar sin perfil.
5. **`script/signing_helper.py`**: la regex `com.brave.Browser(.*).UpdaterPrivilegedHelper` (l. ~100–105) hay que
   adaptarla a `net.lamosquita.flyweb`; las piezas de Sparkle solo se firman si hay perfil (desaparecen con
   `enable_sparkle=false`, **sin verificar** que no falle la búsqueda de ficheros).
6. **Widevine**: la firma VMP necesita `SIGN_WIDEVINE_CERT/KEY/PASSPHRASE` (`enableCDMHostVerification()` en
   `config.js`). Sin ellos queda desactivada; no afecta a claude.ai.
7. **Notarización**: `build/mac/notarize_dmg_pkg.py` usa `xcrun altool --notarize-app`, y el `notarize.py` de
   Chromium 116 tiene `--notarization-tool` con **`altool` por defecto** (admite `notarytool` y `--notary-team-id`).
   Apple dejó de aceptar `altool` para notarizar en noviembre de 2023, así que el flujo de Brave **ya no sirve
   tal cual**. Opciones: parchear `sign_app.sh` para pasar `--notarization-tool notarytool --notary-team-id <TEAM>`,
   o firmar con gn y notarizar a mano en la MacPro7,1: `xcrun notarytool submit FlyWeb.dmg --keychain-profile … --wait`
   + `xcrun stapler staple`. `notarytool` no existe en Xcode 11.3.1 (MacPro6,1) **(sin verificar la versión mínima;
   creemos que es Xcode 13)**.

---

## 6. Riesgos: "Brave" en rutas e identificadores internos

| Qué | Dónde | Riesgo si se cambia | Recomendación |
|---|---|---|---|
| Carpeta interna `brave` (`branding_path_component`) | `config.js`, `util.js`, `.grd` | Rompe copias de recursos y referencias `brave/…` | **No cambiar**; solo contenido |
| `branding_path_product` = `brave` / `brave-development` | `config.js`; `util.js` copia `chromium_src/chrome/installer/setup/brave_behaviors.cc` con ese nombre | Rompe includes de `${branding_path_product}_strings` / behaviours | No cambiar |
| Esquema `brave://` y URLs internas | Constantes WebUI (`components/constants/webui_url_constants.cc`) | Enlaces internos, tests, permisos de WebUI | No cambiar en la 1ª versión |
| Nombres de preferencias `brave.*` y migraciones | `browser/brave_profile_prefs.cc`, `browser/brave_local_state_prefs.cc`, `*_migration*.cc` | Migraciones y lectura de prefs; romperían perfiles | No cambiar (el usuario no los ve) |
| Políticas administradas en macOS | Chromium lee el dominio `base::mac::BaseBundleID()` (`src/chrome/browser/policy/chrome_browser_policy_connector.cc` l. ~281) | Con el bundle id nuevo, `/Library/Managed Preferences/com.brave.Browser.plist` deja de aplicarse; pasa a `net.lamosquita.flyweb.plist`. Los nombres de política (`BraveRewardsDisabled`…) se mantienen | Documentar el dominio nuevo para el despliegue |
| Plantillas de políticas | `chromium_src/components/policy/tools/template_writers/writer_configuration.py` (`BraveSoftware.Policies.Brave`, claves de registro), `script/policy_source_helper.py` | Solo plantillas de admin/Windows | Dejar o cambiar al final |
| Keychain `Brave Safe Storage` | `keychain_password_mac.mm` | Si se cambia a mitad de vida, se pierden contraseñas/cookies cifradas de perfiles existentes | Cambiar **antes** de la primera versión pública, no después |
| `CrProductDirName` | `build/config.gni` | Igual: cambiarlo después obliga a migrar el perfil | Fijarlo desde el principio |
| Brand del client hint `Sec-CH-UA` = "Brave" y la API `navigator.brave` | `chromium_src/components/embedder_support/user_agent_utils.cc`; renderer | Webs que detectan Brave cambiarían de comportamiento; un brand desconocido puede alterar la detección en claude.ai (**sin verificar**) | Primera versión: dejar el UA de Chromium y valorar cambiar solo el brand |
| Importadores (`--import-brave`, etc.) | `keychain_password_mac.mm` | Funcionalidad de importación | Sin cambio |
| Host de referrals, `*.brave.com`, `*.bravesoftware.com` | `components/constants/network_constants.cc` | Son destinos de servicios; cambiarlos sin quitar el servicio solo genera errores | Quitar servicios (§4) en vez de cambiar hosts |
| Componentes (go-updater) desactivados | §4 | Shields sin listas (`components/brave_shields/browser/ad_block_*`), sin Widevine, sin CRLSet (Brave redirige CRLSet/CRX a sus proxys, **sin verificar**) | Decidir explícitamente; para claude.ai no es necesario |
| Provisioning profiles de Brave | `build/mac/*.provisionprofile` | Firmar con ellos con otro Team ID falla | Sustituir o no usar (§5) |
| Tests (`common/brave_channel_info_unittest.cc` espera `BraveSoftware`, etc.) | varios `*_unittest.cc` / `*_browsertest.cc` | Fallarán tests | No compilar tests en la 1ª fase |

---

## 7. Mínimo imprescindible para la primera compilación con marca FlyWeb

1. **`app/theme/brave/BRANDING` y `BRANDING.development`** (borrar o igualar `beta`/`dev`/`nightly`):
   `PRODUCT_FULLNAME=FlyWeb`, `PRODUCT_SHORTNAME=FlyWeb`, `COMPANY_*`, `MAC_BUNDLE_ID=net.lamosquita.flyweb`
   (`.development` en el otro), `MAC_TEAM_ID=<propio>`.
2. **`build/config.gni`**: `brave_product_dir_name` → `LaMosquita/FlyWeb` (+ sufijos) para no compartir perfil con Brave.
3. **`chromium_src/components/os_crypt/sync/keychain_password_mac.mm`**: `FlyWeb Safe Storage` / `FlyWeb`.
4. **Iconos**: `app/theme/brave/mac/app.icns`, `mac/development/app.icns`, `mac/document.icns` y los
   `product_logo_*` de §2.2 (16–256 px + @2x).
5. **Args de gn** (Release):
   `--gn=enable_sparkle:false --gn=enable_updater:false --gn=enable_update_notifications:false`
   `--gn=brave_p3a_enabled:false --gn=enable_ai_chat:false --gn=enable_brave_vpn:false --gn=enable_brave_vpn_panel:false`
   `--gn=enable_gemini_wallet:false --gn=ethereum_remote_client_enabled:false --gn=safe_browsing_mode:0`,
   y valores inertes para los args con `assert` (`updater_prod_endpoint`, `updater_dev_endpoint`,
   `brave_stats_updater_url`, `brave_sync_endpoint`, `brave_variations_server_url`, `brave_services_key`).
6. **Cadenas**: sustitución `Brave`→`FlyWeb` vía `script/lib/l10n/grd_string_replacements.py` +
   `script/chromium-rebase-l10n.py`, y a mano `IDS_PRODUCT_NAME`, `IDS_SHORT_PRODUCT_NAME`,
   `IDS_APP_MENU_PRODUCT_NAME`, `IDS_HELPER_NAME` en `app/brave_strings.grd`.
7. **Firma**: primera compilación con `--skip_signing` (o build no oficial); para distribuir, vaciar
   `brave_entitlements_templates` en `app/entitlements.gni`, adaptar la regex de `script/signing_helper.py`
   y notarizar con `notarytool`.
8. **Parches pequeños de privacidad** (pueden ir en la segunda iteración): no instanciar `BraveReferralsService`,
   `kStatsReportingEnabled=false`, `kNewTabPageShowBraveTalk=false`, `kNewTabPageShowToday=false`,
   URL de `crash_reporter_client.cc`.
