# B2, hito 1: poda de brave-core (FM.55)

MOTOR-31, 05-11-2026, encargo de COORDINACIÓN-27. Rama `lamosquita-net/brave-core` `nube/b2-poda`, sha **9b8eb665**, sobre
`flyweb` 5fdeb23d (2.7.0); PR borrador brave-core #8. **Sin compilar**: la compilación y el recuento de ficheros rotos
son de MOTOR-30 (Ubuntu). Plan de origen: `brave-propio.md` §11.6 (74 directorios).

## Resumen

- **123 commits**: 70 `[b2-poda] remove <dir>` (uno por directorio) + 53 `[b2-poda] seams for <dir>`; 6 755 ficheros, −742 854 líneas.
- **Borrados 70 de 74.** Se quedan, por dependencia viva (§2.3; acordado con COORDINACIÓN-27):
  `components/webcompat` (excepciones de Shields: `remote_list_provider`; la heurística lo cogió por el nombre),
  `components/p3a_utils` (Shields, sync, Playlist), `components/time_period_storage` (Speedreader, Brave Search, perf
  predictor) y `components/ntp_background_images` (NTP de Brave; se decide con la interfaz).
- **Tor, Speedreader, Playlist, Widevine:** ningún directorio de la lista era suyo. Costura mínima en commits aparte
  (`… (speedreader|tor|playlist|sidebar)`).
- **Costuras fuera de los 70:** 495 ficheros, 274 editados y 221 borrados (solo servían a lo borrado). Por tipo (M/D):
  gn/DEPS 68/6 · chromium_src 43/13 · parches 3/3 · grd/resource_ids 3/2 · prefs 7 · about_flags 1 · factorías 8 ·
  WebUI/ajustes/TS 71/85 · pruebas 33/29 · Rust 2/1 · resto (UI C++, process impl, tab helpers, comandos IDC, iconos).
- **Comprobación estática:** 0 marcadores; referencias a los 70 = 0 salvo Android/iOS, `chromium_presubmit_config.json5` y
  `visibility` de `third_party/argon2` y `bitcoin-core`; frente a la base, ningún `#include "brave/…"` ni etiqueta
  `//brave/…` nuevo inexistente fuera de bloques Android; ningún BUILDFLAG ni arg de gn de lo borrado fuera de Android.
- **Método:** 7 grupos en paralelo (worktrees), integrados por rebase en el orden IPFS/PSST → News → VPN → Leo → P3A →
  Rewards → Wallet. Lo más frágil sin compilar: resoluciones entre grupos en `brave_web_ui_controller_factory.cc`,
  `brave_content_browser_client.cc`, `brave_browser_process_impl.cc`, `brave_toolbar_view_browsertest.cc`.
- **Pendiente (con F1):** args de `FlyWeb/scripts/build.sh` que ya no se declaran (lista en cada grupo); políticas sin
  pref (`BraveWalletDisabled`, `BraveRewardsDisabled`, `BraveAIChatEnabled`, `BraveVPNDisabled`); crates y bibliotecas
  huérfanas; cadenas `.grd`/`.xtb` con `chromium-rebase-l10n.py`.
- **CI del PR #8:** `compare-chromium-versions` falla por la etiqueta `chromium-version-mismatch`, que no existe en el fork (no es de la poda).

Los informes de cada grupo siguen tal cual (los sha intermedios son anteriores a la integración; vale el final, 9b8eb665).

---

## Informe g1-psst (poda B2)

Rama `b2/g1-psst` en `/home/user/wt-g1-psst`, base 5fdeb23d. **sha final: 2768a36b20924515b7c62803a4a3dd23872ab877**. Sin push.

### Commits (`git log --oneline nube/b2-poda..`)
```
2768a36b [b2-poda] seams for components/script_injector
35a12d8e [b2-poda] seams for components/psst
9da4dc3c [b2-poda] seams for components/brave_player
95a5d4fb [b2-poda] seams for components/webcompat_reporter
c75a769a [b2-poda] seams for browser/ui/webui/webcompat_reporter   (cubre también components/webcompat_reporter)
75fa1121 [b2-poda] seams for browser/day_zero_browser_ui_expt
94c61718 [b2-poda] seams for components/ipfs
abbc7d59 [b2-poda] remove test/data/psst-component-data
e9b228a1 [b2-poda] remove components/script_injector
1af43699 [b2-poda] remove components/psst
219582e7 [b2-poda] remove components/brave_player
942a6dc3 [b2-poda] remove components/webcompat_reporter
8457f134 [b2-poda] remove browser/ui/webui/webcompat_reporter
23c5c69d [b2-poda] remove browser/day_zero_browser_ui_expt
30b2b53b [b2-poda] remove components/ipfs
```
test/data/psst-component-data no tenía referencias (sin commit de costuras).

### Directorios
- Borrados los 8 del grupo.
- Además, borrados como costura (código vivo que solo servía a lo borrado): `browser/script_injector` (browsertest),
  `browser/psst` (browsertest), `browser/ui/views/brave_player/`, `browser/ui/webui/brave_player_ui.{cc,h}`,
  `components/test/brave_player/playerEmbed_test.ts`, `app/theme/default_{100,200}_percent/brave/brave_player_action_icon.png`,
  `components/definitions/webcompatReporter.d.ts`.
- No borrado nada revertido. **Ojo, §2.3 (interfaz):** el «Informar de un sitio roto» de FlyWeb (menú de la app, menú Ayuda de
  Mac y botón del panel de Shields) vivía en `browser/ui/webui/webcompat_reporter` y abría la página propia
  `kFlyWebReportProblemURL`. Se conserva: nueva `brave::OpenFlyWebReportProblemPage(WebContents*)` en `browser/ui/brave_pages.{h,cc}`
  (mismo `OpenURL` NEW_FOREGROUND_TAB que antes), usada por `ShowWebcompatReporter` y `ShieldsPanelDataHandler::OpenWebCompatWindow`.
  `IDC_SHOW_BRAVE_WEBCOMPAT_REPORTER` sigue vivo. Lo que desaparece es el diálogo de Brave (ya no se usaba) y chrome://webcompat.

### Costuras (ficheros / ediciones)
| tipo | ficheros | ediciones | detalle |
|---|---|---|---|
| gn | 11 | 22 | browser/sources.gni (ipfs, day_zero, psst ×3), renderer/sources.gni, browser/ui/BUILD.gn (webcompat ×3, player ×2), components/resources/BUILD.gn (webcompat ×2, player ×3), app/BUILD.gn, app/theme/BUILD.gn, chromium_src/chrome/browser/ui/BUILD.gn; DEPS: chromium_src/chrome/browser/DEPS (ipfs, player ×2, psst), chromium_src/chrome/common/DEPS, chromium_src/components/page_info/DEPS |
| buildflag | 1 | 3 | brave_page_action_icon_container_view.cc (bloque ENABLE_BRAVE_PLAYER) |
| include | 4 | 7 | brave_pages.cc/.h, shields_panel_data_handler.cc (webcompat → página propia), brave_content_renderer_client.cc (script_injector) |
| prefs | 3 | 6 | brave_profile_prefs.cc y chromium_src/.../browser_prefs.cc (prefs obsoletas de IPFS), brave_local_state_prefs.cc (day_zero) |
| features | 1 | 5 | about_flags.cc: brave-player (include, include buildflag, macro, uso) y brave-psst |
| keyed | 3 | 6 | brave_browser_process_impl.{h,cc} (DayZeroBrowserUIExptManager, solo Win/Android), brave_tab_helpers.cc (PsstTabHelper) |
| grd | 4 | 6 | brave_components_resources.grd (include webcompat, part brave_player), brave_theme_resources.grd (icono player), resources/resource_ids.spec (webcompat_reporter, brave_player) |
| webui | 4 | 9 | brave_web_ui_controller_factory.cc (webcompat ×3, player ×4), common/extensions/api/_api_features.json (chrome://webcompat), components/common/typescript.gni (+ d.ts borrado) |
| chromium_src | 3 | 6 + 1 borrado | ver abajo |
| test | 1 | 7 | test/BUILD.gn: ipfs unit, day_zero unit+browser, psst browser, script_injector unit+browser (+ dirs de test borrados) |
| otros | 2 | 4 | chromium_presubmit_config.json5 (uploader webcompat); build/commands/lib/config.js (arg gn `webcompat_report_api_endpoint`, ×3) |

### chromium_src y parches
- **Borrado** `chromium_src/chrome/browser/component_updater/registration.cc`: solo registraba el componente PSST (feature
  `BravePsst` desactivada por defecto). Ahora corre `RegisterComponentsForUpdate` de Chromium sin envoltorio (mismo efecto).
- Editado (parte muerta): `chromium_src/chrome/browser/ui/views/page_action/page_action_icon_controller.cc` (case del icono Player),
  `chromium_src/chrome/browser/ui/webui/chrome_untrusted_web_ui_configs.cc` (config untrusted del Player),
  `chromium_src/chrome/browser/prefs/browser_prefs.cc` (ClearDeprecatedIpfsPrefs).
- Parches: ninguno tocado (`kIPFSCache` del parche de browsing_data no depende de components/ipfs).

### Residuales (`resid.sh`)
- components/ipfs: **9** = 7 dentro de `components/brave_wallet` (lista de 70) + `chromium_src/ios/.../prefs/DEPS` (iOS) +
  `browser/net/decentralized_dns_network_delegate_helper.cc` (fuera de la lista, pero depende entero de brave_wallet y
  decentralized_dns: lo debe quitar el grupo de decentralized_dns/wallet junto con su entrada en browser/net/sources.gni;
  no lo toqué para no chocar con ese borrado).
- Resto de dirs del grupo (y browser/script_injector, browser/psst, browser/ui/views/brave_player): **0**. android/ios informativos: ipfs 2, webcompat_reporter 3, browser/psst 1.

### Args de gn que pasa softmac `FlyWeb/scripts/build.sh`
- `--gn "webcompat_report_api_endpoint:$INERT"` (línea 253): su `declare_args` estaba en components/webcompat_reporter/buildflags; quitarlo de build.sh (si no, gn avisa «has no effect»).
- `enable_brave_player` no lo pasa build.sh (valía true por defecto, feature apagada). Ya no está declarado; app/BUILD.gn lo pasa como define de grit fijo `enable_brave_player=false` porque el `<if>` de su cadena sigue en brave_generated_resources.grd (cadenas no se tocan).

### Dudas / restos
- `brave_pages.cc`: `OpenURL(params, /*navigation_handle_callback=*/{})` copiado del código borrado (compilaba en 128); includes añadidos a mano (page_navigator, web_contents, page_transition_types, window_open_disposition, url_constants).
- `components/webui/webui_resources.cc` conserva la tabla de cadenas "webcompat" (IDS siguen existiendo; muerta pero compila). Dejada por la regla de cadenas.
- Restos inofensivos sin tocar: `kBravePlayerPageActionIconType` (brave_page_action_icon_type.h), `kColorBravePlayerActionViewBorder` (color id/mixer), `kWebcompatReporterHost`/`kBraveUIWebcompatReporterURL` (webui_url_constants.h), `components/definitions/ipfs.d.ts` (huérfano antiguo), include `chrome_isolated_world_ids.h` ahora sin uso en brave_tab_helpers.cc, feature `kBraveDayZeroExperiment` (la usa brave_stats, de otro grupo).
- Patrones de jest/storybook que buscasen `components/test/brave_player` o los stories de webcompat_reporter: no encontré referencias explícitas.

---

## Poda B2, grupo g2-news: informe

Worktree `/home/user/wt-g2-news`, rama `b2/g2-news`, desde flyweb `5fdeb23d`. Sin push.
**sha final: `2314014e32069f3747ddfedfa5592a88c69a1252`**

Nota: `nube/b2-poda` ya no está en 5fdeb23d (ahora en 2768a36b, con commits de otros grupos), así que
`git log nube/b2-poda..` da los mismos 6 commits; la base real de la rama es 5fdeb23d.

```
2314014e [b2-poda] seams for components/brave_news
cf6f0ef9 [b2-poda] seams for browser/ui/views/brave_news
c4c37a3e [b2-poda] seams for browser/brave_news
6df257b7 [b2-poda] remove components/brave_news
bd7c1915 [b2-poda] remove browser/ui/views/brave_news
6cc4e0df [b2-poda] remove browser/brave_news
```

### Directorios
- Borrados: `browser/brave_news`, `browser/ui/views/brave_news`, `components/brave_news`.
- No borrados: ninguno. Nada vivo usaba News de verdad: en FlyWeb `BraveNewsControllerFactory` ya devolvía nullptr.
- Borrado además como costura (solo servían a News): `browser/ui/webui/brave_news_internals/` (WebUI news-internals),
  `fuzzers/brave_news/`, `third_party/rust/brave_news_cxx/` (solo README.chromium) y en el NTP
  `components/brave_new_tab_ui/components/default/braveNews/` (40 ficheros), `actions/today_actions.ts`, `async/today.ts`,
  `reducers/today/` y las historias de News (`stories/today.tsx`, `todayStrings.ts`, `mockBraveNewsController.ts`,
  `getBraveNewsDisplayAd.ts`, `todayStorybookState.ts`).

### Costuras arregladas (ficheros / ediciones aprox.)
| tipo | ficheros | ediciones | detalle |
|---|---|---|---|
| gn | 9 | 22 | browser/sources.gni (import, mojom, sources/deps), browser/ui/BUILD.gn (fuentes de views, internals y 4 deps), test/BUILD.gn (4), fuzzers/BUILD.gn (target + grupo), components/resources/BUILD.gn (3), components/brave_new_tab_ui/BUILD.gn, .storybook/BUILD.gn, chromium_src/chrome/browser/DEPS, Cargo.toml/Cargo.lock (crate brave-news-cxx) |
| buildflag | 0 | 0 | News no tenía buildflag |
| include | 14 | ~30 | browsing_data_remover (ClearHistory), brave_tab_helpers, brave_profile_manager, location bar .h/.cc (botón siempre null), perf processor y su browsertest, brave_rewards_page_ui (`newsAdsEnabled` fijo a false), brave_pages (ShowBraveNewsConfigure), brave_browser_command_controller y `IDC_CONFIGURE_BRAVE_NEWS` en app/brave_command_ids.h |
| prefs | 5 | 9 | brave_profile_prefs.cc (RegisterProfilePrefs, prefs de migración P3A, kBraveNewsIntroDismissed), chromium_src/.../browser_prefs.cc (2 migraciones), components/constants/pref_names.h (kBraveNewsIntroDismissed), brave_prefs_util.cc (allowlist), settings_localized_strings_provider (etiqueta del botón) |
| features | 1 | 3 | about_flags.cc: brave-news-peek y brave-news-feed-update |
| keyed | 1 | 2 | browser_context_keyed_service_factories.cc |
| grd | 3 | 3 | `<part news_resources.grdp>` en brave_components_resources.grd, entrada brave_news_internals de resources/resource_ids.spec, mapeo de cadenas de News en components/webui/webui_resources.cc (las cadenas .grd/.grdp y .xtb **no** se tocan) |
| webui | ~20 | ~60 | registro de news-internals (content browser client, controller factory ×2, kBraveNewsInternalsHost); NTP en C++: binder del mojo de News, flags `featureFlagBraveNews*`, `showToday`/`isBraveNewsOptedIn`, observadores de prefs, cadena plural; NTP en TS: store, reducers, getActions, new_tab_types, app.tsx, newTab/index.tsx, settings.tsx (pestaña News), page/index.tsx, new_tab_storage, definitions newTab.d.ts y chromel.d.ts (chrome.braveNews), stories/regular.tsx, storybookState, test data_test.ts |
| chromium_src | 0 | 0 | no hay envoltorio solo de News (browser_prefs.cc mezcla: solo se quitó la parte muerta) |
| patches | 0 | 0 | ningún parche apunta a News |
| test | 3 | 4 | test/BUILD.gn, perf browsertest (EXPECT de News), data_test.ts |
| otros | 3 | 3 | script/brave_license_helper.py, chromium_presubmit_config.json5 (entrada direct_feed_controller.cc), SearchEngineIcon/SearchResult del NTP (ver dudas) |

### Envoltorios chromium_src y parches
- Tocado (parte muerta): `chromium_src/chrome/browser/prefs/browser_prefs.cc`, `chromium_src/chrome/browser/DEPS`.
- Ninguno borrado. Ningún parche tocado.

### Residuales (`resid.sh`)
- `browser/brave_news`: 0 (+1 en android, informativo).
- `browser/ui/views/brave_news`: 0.
- `components/brave_news`: 25 líneas, todas justificadas:
  - 5 en `browser/day_zero_browser_ui_expt/` y 15 en `components/brave_ads/`: directorios de la lista de 70 (los borra otro agente).
  - 5 solo de Android/iOS, sin tocar: `browser/android/preferences/brave_pref_service_bridge.cc`,
    `chromium_src/chrome/browser/flags/android/chrome_feature_list.cc`, `build/android/config.gni`,
    `chromium_src/ios/.../prefs/{BUILD.gn,browser_prefs.mm,DEPS}`. Más ~40 ficheros en `android/` e `ios/`.

### Args de gn / buildflags en `FlyWeb/scripts/build.sh`
- Ninguno: News no tenía buildflag y build.sh no menciona News.

### Dudas (sin compilar)
- **Buscador del NTP** (`components/search/SearchEngineIcon.tsx`, `SearchResult.tsx`): usaban `useUnpaddedImageUrl` de
  News, que pedía la imagen al BraveNewsController. En FlyWeb ese controlador era null, así que las imágenes nunca
  cargaban y quedaban ocultas (opacidad 0). Ahora se pintan ocultas directamente: se ve igual que hoy. Si se quiere que
  carguen, habría que pedirlas por otro camino (no lo he hecho: sería un cambio de comportamiento). En
  `MaybeImage`, `const { src, ...rest }` deja `src` sin usar; TS no lo marca con `noUnusedLocals` porque va junto a un
  rest. Si el compilador protesta, se cambia por `const rest = { ...props }; delete rest.src`.
- **Overlay del NTP** (`page/index.tsx`): el bloque `&::before` dependía de `featureFlagBraveNewsFeedV2Enabled`, que
  estaba **activado** por defecto. Lo dejo sin condición para que la página se vea igual.
- La clave `newsAdsEnabled` del rewards page sigue existiendo, fija a `false`. Rewards se poda en otro grupo.
- Crates de Rust: quitado `brave-news-cxx` de Cargo.toml y Cargo.lock a mano. `feed-rs` (vendor `feed-rs-1.3.0`,
  `third_party/rust/feed_rs`) y quizá otros quedan huérfanos: no los borro (gnrt los poda si se regenera; los BUILD.gn
  de third_party/rust no los referencia nadie vivo).
- Quedan sin usar: cadenas `IDS_BRAVE_NEWS_*`, `IDS_IDC_CONFIGURE_BRAVE_NEWS` y `IDS_SETTINGS_SHOW_BRAVE_NEWS_BUTTON_LABEL`
  (las poda `chromium-rebase-l10n.py`); `brave_news_strings.grdp` sigue incluido (está en components/resources, que no se
  borra); iconos Leo `news-*`/`product-brave-news` en ui/webui/resources/BUILD.gn; el enum `MessageTypes.Today` en
  components/common/Background.ts. Nada de esto rompe la compilación.
- `app/generate_command_metadata.py` genera los metadatos a partir de los IDC; al quitar `IDC_CONFIGURE_BRAVE_NEWS`
  debería dejar de generarlo. No he visto ninguna lista fija con ese comando, pero no lo he podido ejecutar.
- Si `nube/b2-poda` se rebasa con los otros grupos, habrá conflictos previsibles en Cargo.toml/Cargo.lock,
  browser/sources.gni, test/BUILD.gn, about_flags.cc, brave_profile_prefs.cc y browser_prefs.cc (otros grupos
  tocan los mismos ficheros).

---

## Poda B2 — grupo g3-vpn

Worktree `/home/user/wt-g3-vpn`, rama `b2/g3-vpn`, base **5fdeb23d** (ojo: la ref local `nube/b2-poda` ya apunta a
2768a36b porque alguien la movió; mis commits van sobre 5fdeb23d). Sin push.

### sha final y commits (`git log --oneline 5fdeb23d..`)
sha final: **154102be**
```
154102be [b2-poda] seams for components/brave_vpn
75725356 [b2-poda] seams for browser/ui/webui/brave_vpn
57843401 [b2-poda] seams for browser/brave_vpn
2dac06e2 [b2-poda] remove components/brave_vpn
831191d7 [b2-poda] remove browser/ui/webui/brave_vpn
faa096c9 [b2-poda] remove browser/ui/views/brave_vpn
b8f609ff [b2-poda] remove browser/brave_vpn
```
Casi todas las costuras tocan los cuatro directorios a la vez (buildflag y args de gn definidos en components/brave_vpn,
servicios en browser/brave_vpn, UI en views/webui), así que van en `seams for browser/brave_vpn` (dicho en el cuerpo).
`browser/ui/views/brave_vpn` no tiene costuras exclusivas, así que no tiene commit de costuras.

### Directorios
- Borrados: los 4 (browser/brave_vpn, browser/ui/views/brave_vpn, browser/ui/webui/brave_vpn, components/brave_vpn).
- No borrados: ninguno. Nada vivo de §2.3 usaba la VPN de verdad; solo menús, botones, prefs, métricas y el DoH de
  VPN en Windows.
- También se borraron ficheros solo de VPN que estaban fuera del grupo: `browser/ui/toolbar/brave_vpn_menu_model*`,
  `browser/ui/views/toolbar/brave_vpn_{button,panel_controller,status_label,toggle_button}*` (con sus pruebas),
  `browser/ui/webui/settings/brave_vpn/`, `browser/ui/webui/settings/brave_settings_secure_dns_handler.*` (solo para el DoH
  de VPN en Windows), `browser/resources/settings/brave_system_page/brave_vpn_{page.ts,page.html,browser_proxy.ts}`,
  `win_build_output/midl/brave/components/brave_vpn/` (15 ficheros MIDL generados).

### Costuras (tipo × ficheros)
| tipo | ficheros | qué |
|---|---|---|
| gn | 25 | `if (enable_brave_vpn*)` quitados (rama false), deps `//brave/components/brave_vpn/common/{buildflags,mojom}`, `import(buildflags.gni)`, `browser/brave_vpn/sources.gni` y sus variables en browser/sources.gni, BUILD.gn raíz (import de allowlist.gni), test/BUILD.gn, 3 DEPS de chromium_src, elevation_service/sources.gni (lista vacía), .storybook |
| buildflag | 41 | bloques `#if BUILDFLAG(ENABLE_BRAVE_VPN[_WIREGUARD])` quitados (se deja `#else`) y su `#include buildflags.h`; los compuestos se simplifican (`VPN \|\| AI_CHAT` → `AI_CHAT`, `VPN \|\| SPEEDREADER` → `SPEEDREADER`) |
| include | 4 | brave_web_ui_controller_factory.cc (vpn_utils.h sin `#if`), brave_settings_ui.cc (features.h), declaración adelantada en testing_brave_browser_process.h, brave_app_menu_model.h |
| prefs | 4 | brave_local_state_prefs.cc (`brave_vpn::RegisterLocalStatePrefs`, `kBraveVpnDnsConfig`), brave_prefs_util.cc (lista permitida), brave_simple_policy_map.h (política→pref), chromium_src/chrome/common/pref_names.h (borrado) |
| features | 2 | about_flags.cc (entradas VPN/DNS/WireGuard y sus macros, salto condicional), brave_features_internal_names.h |
| keyed | 5 | browser_context_keyed_service_factories.cc, brave_browser_process(.h/_impl), testing_brave_browser_process, binders mojo de brave_content_browser_client.cc |
| grd | 4 | `<include IDR_VPN_PANEL_HTML>` en brave_components_resources.grd, entrada de resource_ids.spec, define de grit quitado (resources) y fijado a `false` en 2 (ver dudas) |
| webui | 12 | chrome_untrusted_web_ui_configs.cc, brave_settings_ui.cc, cadenas de ajustes (proveedor), settings TS/HTML (toolbar.html/ts, system_page.ts, settings.gni, sources.gni, defines de preprocess en BUILD.gn), constantes de URL del panel, iconos (vpn_indicator_*, banderas de país de leo) |
| chromium_src | 11 | ver lista abajo |
| patches | 2 | ver lista abajo |
| test | 8 | test/BUILD.gn, browsertests (prefs, command controller, app menu model, app menu, toolbar view), pruebas unitarias borradas |
| otros | 14 | comandos IDC_*VPN* (brave_command_ids.h, generate_command_metadata.py, controller, browser_commands, app_menu_icons, brave_app_menu_model, BraveBrowserWindow/BraveBrowserView), colores (brave_color_id.h, mixer), brave_toolbar_view, brave_app_menu, skus_internals_ui.cc (bloques VPN), script/brave_license_helper.py, chromium_presubmit_config.json5, check_chromium_src_config.json5 |

Total: 86 ficheros modificados y 41 borrados (además de los 4 directorios), con 6208 líneas quitadas.

### chromium_src y parches
- **Envoltorios borrados** (cambian el comportamiento de Chromium solo en lo de la VPN):
  - `chromium_src/components/crash/core/app/crashpad.cc`: aceptaba los procesos `brave-vpn-helper` y `brave-vpn-wireguard-service`; solo Windows.
  - `chromium_src/chrome/common/pref_names.h`: solo definía `kBraveVpnDnsConfig`.
  - `chromium_src/chrome/installer/setup/install_worker.h`: solo declaraba `OneTimeVpnServiceCleanup`, cuya definición también se ha quitado.
  - `chromium_src/chrome/installer/setup/test/{BUILD.gn,install_worker_vpn_unittest.cc}`.
- **Envoltorios con la parte de VPN quitada:**
  - `stub_resolver_config_reader.cc`: el DoH forzado por VPN en Windows; se queda lo de FlyWeb.
  - `settings/settings_ui.cc`: deja de redefinir `SecureDnsHandler` en Windows.
  - `shared_settings_localized_strings_provider.cc`, `chrome_untrusted_web_ui_configs.cc`.
  - `elevation_service/elevator.cc`: `InstallVPNServices` solo valida y devuelve S_OK.
  - `installer/setup/install_worker.cc` y `uninstall.cc`: solo Windows.
- **Parches:**
  - Borrado `patches/components-crash-core-app-crashpad.cc.patch`: solo metía la macro del envoltorio borrado.
  - Editado `patches/chrome-installer-mini_installer-chrome.release.patch`: se quitan las 4 líneas `+` de los binarios de
    VPN/WireGuard. La cabecera pasa de `@@ -18,9 +18,19` a `+18,15` y el hunk siguiente de `+76` a `+72`. La línea `index` queda con el hash antiguo.

### Residuales (`resid.sh`)
- browser/brave_vpn: 1, en `browser/ui/webui/webcompat_reporter/webcompat_reporter_ui.cc`, que está en la lista de los 70 (lo poda otro grupo).
- browser/ui/views/brave_vpn: 0.
- browser/ui/webui/brave_vpn: 0.
- components/brave_vpn: 23, todos justificados:
  - webcompat_reporter_ui.cc (2) y components/skus/renderer (7): están en la lista de los 70.
  - Solo Android, sin tocar (11 en `components/brave_mobile_subscription/renderer/android/`, que solo se carga dentro de
    `is_android`; 1 en `chromium_src/chrome/browser/flags/android/chrome_feature_list.cc`; 1 en
    `browser/android/preferences/BUILD.gn`). Ojo: el cálculo cuenta `android/` en cualquier nivel.
- android/ e ios/ (informativo): 0 rutas `brave/...brave_vpn`; 170 ficheros y 1288 líneas mencionan VPN (Java y recursos), sin tocar.
- Toqué dos condiciones Android de nivel superior para que GN no lea un arg que ya no existe:
  `renderer/BUILD.gn`, `renderer/sources.gni` y `test/BUILD.gn` pasan de `is_android && (enable_brave_vpn || enable_ai_chat)`
  a `is_android && enable_ai_chat` (y lo mismo dentro de `if (is_android)` en brave_unit_tests).

### Args de gn que pasa `FlyWeb/scripts/build.sh` (softmac)
Los args se declaraban en `components/brave_vpn/common/buildflags/buildflags.gni`, que ya no existe. Hay que quitar de
build.sh las líneas 270–271: `--gn enable_brave_vpn:false` y `--gn enable_brave_vpn_panel:false`. Si no, gn avisará de que el
arg no tiene efecto. `enable_brave_vpn_wireguard` también desaparece; build.sh no lo pasa.

### Dudas / lo que queda a propósito
1. **Cadenas:** los `<if expr="enable_brave_vpn">` de `app/brave_generated_resources.grd` y
   `components/resources/brave_components_strings.grd` (`<part brave_vpn_strings.grdp>`, que no está en lo borrado) se dejan,
   como manda la regla de las cadenas. Para que grit no falle, el define queda fijado a `"enable_brave_vpn=false"` en
   `app/BUILD.gn` y en el grit `strings` de `components/resources/BUILD.gn`. Quitarlos cuando se poden las cadenas con
   `chromium-rebase-l10n.py`. También quedan los `IDS_IDC_*VPN*` de commands.grdp (cadenas que ya no se usan).
2. **BUILD.gn raíz:** `merge_allowlists` (solo Win + allowlist) dependía de la allowlist de WireGuard. Lo cambié por un
   `copy` de la allowlist de chrome con el mismo nombre, porque `patches/chrome-BUILD.gn.patch` lo usa. Solo Windows; sin probar.
3. **Política `BraveVPNDisabled`** en `chromium_src/components/policy/tools/generate_policy_source.py`: se deja, porque quitar una
   política con id fijo puede afectar a las tablas de ids. La constante `key::kBraveVPNDisabled` queda sin usar, lo que es inofensivo.
4. **No tocado, aunque es de VPN:** hooks `wireguard_nt` y `wireguard_tunnel` del `DEPS` raíz (solo `checkout_win`; el script
   `build/win/download_brave_vpn_wireguard_binaries.py` sigue existiendo); el método IDL `InstallVPNServices` de
   elevation_service (Windows); la variante `.VPNPanel` en el parche de histogramas; `skus_internals_ui` (GetVpnState, que
   devuelve vacío; skus es de otro grupo); `README.md` de elevation_service.
5. **macOS:** `app/app-entitlements-brave.plist` todavía declara `com.apple.developer.networking.vpn.api`. No lo toqué (es de
   firma, de PUBLICACIÓN), pero sobra sin VPN y puede exigir perfil de aprovisionamiento.
6. `kBraveVpnDnsConfig` deja de registrarse en local state, sin migración `ClearPref`: el valor viejo, si existe, se queda huérfano.
7. Quité por completo los comandos IDC de VPN (ids 56028–56034 y 56050). Si alguien guardó atajos con esos ids, se ignoran.
8. Sin compilar: los `#if` quedan equilibrados (comprobado por script en todos los .cc/.h modificados) y la rama false es la
   de siempre en FlyWeb. Lo más arriesgado es lo que he quitado fuera de `#if`: comandos, `UpdateCommandForBraveVPN`,
   `ShowBraveVPNBubble`/`GetAnchorViewForBraveVPNPanel` y el handler de DNS seguro en Windows.

---

## Informe g4-leo (poda B2)

Worktree `/home/user/wt-g4-leo`, rama `b2/g4-leo`, **rebasada sobre `nube/b2-poda` 1d8a13ee** (podas de
PSST/Player/IPFS, News y VPN). Sin push.
**SHA final: 09482b94c5f560e83d118cb294dc058796b9ac64** (antes del rebase: a0c920a9 sobre 5fdeb23d).

```
09482b94 [b2-poda] seams for browser/ui/ai_rewriter
22a5203f [b2-poda] seams for browser/resources/settings/brave_leo_assistant_page
02897dfc [b2-poda] seams for browser/ai_chat (speedreader)
f9b9e093 [b2-poda] seams for browser/ai_chat (sidebar)
c258a48e [b2-poda] seams for browser/ai_chat
8bc2e293 [b2-poda] remove test/data/leo
38a4c3a7 [b2-poda] remove test/data/ai_chat
912fd5a9 [b2-poda] remove components/ai_rewriter
34734b12 [b2-poda] remove components/ai_chat
6d8b8cdf [b2-poda] remove browser/ui/webui/ai_chat
d6e61006 [b2-poda] remove browser/ui/ai_rewriter
40df78d9 [b2-poda] remove browser/resources/settings/brave_leo_assistant_page
35ad4b46 [b2-poda] remove browser/ai_chat
```

#### Rebase (1d8a13ee)
- Conflictos: 28 ficheros en `seams for browser/ai_chat`, 1 en la página de Leo (toolbar.ts) y 1 en ai_rewriter
  (brave_web_ui_controller_factory.cc). Resueltos quitando ambos lados; comprobado que lo quitado respecto a
  nube/b2-poda es solo lo que mi commit original quitaba, salvo los casos de abajo.
- Donde VPN había dejado `#if BUILDFLAG(ENABLE_AI_CHAT)` (antes `VPN || AI_CHAT`) y yo `ENABLE_BRAVE_VPN`, ahora los dos
  flags están quitados → el bloque entero sale: `skus::SkusServiceFactory` + su include (keyed factories),
  `skus::RegisterLocalStatePrefs` (local state; skus está en la lista de 70), `pref_change_registrar_` del command
  controller (.cc Init y miembro .h; sin más usos), bloques `brave_mobile_subscription` de renderer/{BUILD.gn,sources.gni}
  y test/BUILD.gn (fuera de `if (is_android)`).
- brave_toolbar_view_browsertest.cc: rehecho desde nube/b2-poda + quitar bloques ENABLE_AI_CHAT; además quito
  `SetUpInProcessBrowserTestFixture()` porque usaba `provider_`, cuyo miembro solo existía con VPN/AI chat (ya no
  compilaba con ambos a false).
- Corregidos de paso: 4 líneas en blanco al final de fichero y una línea en blanco doble que metía mi primer commit
  (`git diff --check` limpio en todos los commits). Sin marcadores de conflicto.

### Directorios
- **Borrados (8/8):** browser/ai_chat, browser/resources/settings/brave_leo_assistant_page, browser/ui/ai_rewriter,
  browser/ui/webui/ai_chat, components/ai_chat, components/ai_rewriter, test/data/ai_chat, test/data/leo.
- **No borrados:** ninguno. Nada vivo de §2.3 (Shields, sync, políticas, updater, NTP, flyweb*) usaba de verdad AI chat:
  en políticas solo había un mapeo de pref (`kBraveAIChatEnabled` → `ai_chat::prefs::kEnabledByPolicy`), quitado.
- Sin tocar: el sistema de diseño `@brave/leo` (iconos `leo_*`, `kLeo*Icon`, `leo.bundle.js`, `brave_leo` iconset de
  settings, `leo_colors`) y `components/brave_service_keys` (la clave de servicios sigue igual).

#### Reparto de commits de costuras
Las costuras de ai_chat están muy mezcladas (browser/ai_chat, browser/ui/webui/ai_chat y components/ai_chat aparecen
en los mismos ficheros, y muchos ficheros también tocan ai_rewriter), así que:
- `seams for browser/ai_chat`: todo lo de ai_chat (cubre también browser/ui/webui/ai_chat y components/ai_chat) y la
  parte ai_rewriter de los ficheros compartidos (dicho en el cuerpo).
- `seams for browser/ai_chat (sidebar)` y `(speedreader)`: costuras mínimas aparte (punto 7). Sidebar incluye también
  `browser/ui/views/side_panel/brave_side_panel_utils.cc` y `browser/ui/brave_browser_actions.cc` (registro de panel
  lateral de Leo).
- `seams for browser/resources/settings/brave_leo_assistant_page`: TS/gni de ajustes + el parche de settings.
- `seams for browser/ui/ai_rewriter`: lo que solo tocaba al reescritor (cubre components/ai_rewriter).
- browser/ui/webui/ai_chat, components/ai_chat, components/ai_rewriter, test/data/*: sin commit propio (cubiertos
  arriba o sin referencias).

### Costuras arregladas (ficheros vivos editados o borrados)
| Tipo | Ficheros | Detalle |
|---|---|---|
| gn | 20 | browser/sources.gni, browser/ui/BUILD.gn, renderer/{BUILD.gn,sources.gni}, test/BUILD.gn, components/{resources,webui,sidebar/browser}/BUILD.gn, components/{omnibox/browser,browsing_data/core}/sources.gni, chromium_src/chrome/browser/ui/BUILD.gn, browser/{browsing_data,renderer_context_menu/test,ui/sidebar}/BUILD.gn, common/extensions/api/BUILD.gn, .storybook/BUILD.gn; DEPS: chromium_src/chrome/{browser,renderer}, chromium_src/components/omnibox/browser, components/omnibox/browser (+ borrado chromium_src/components/browsing_data/core/DEPS). `brave_components_browsing_data_core_deps` queda `[]` (lo usa un parche). |
| buildflag | ~62 C++ | Bloques `#if BUILDFLAG(ENABLE_AI_CHAT)` / `ENABLE_AI_REWRITER` quitados dejando el `#else` (script que imita el preprocesador con el flag a false; #if/#endif comprobados balanceados). `ENABLE_BRAVE_VPN \|\| ENABLE_AI_CHAT` → `ENABLE_BRAVE_VPN` (5 sitios); `is_android && (enable_brave_vpn \|\| enable_ai_chat)` → `is_android && enable_brave_vpn` (renderer x2, test x1). |
| include | 3 | `brave_browser_window.h` (buildflags.h de ai_chat), `brave_settings_ui.h/.cc` (settings_helper.mojom.h y el `BindInterface(AIChatSettingsHelper)` que quedaba vacío). |
| prefs | 6 | brave_profile_prefs.cc, brave_local_state_prefs.cc, chromium_src/.../prefs/browser_prefs.cc (migración `ModelService::MigrateProfilePrefs`), brave_prefs_util.cc, brave_pref_service_incognito_allowlist.cc, browser/policy/brave_simple_policy_map.h. |
| features | 2 | about_flags.cc: 4 entradas (brave-ai-chat, -history, -context-menu-rewrite-in-place, brave-ai-rewriter) y sus macros; brave_perf_features_processor.cc. |
| keyed | 2 | browser_context_keyed_service_factories.cc (`ModelServiceFactory`), brave_tab_helpers.cc (`AIChatTabHelper`). |
| grd | 4 | app/theme/brave_theme_resources.grd (`<if enable_ai_chat>` IDR_LEO_FAVICON) + define en app/theme/BUILD.gn; brave_components_resources.grd (2 `<part>` a grdp borrados); resources/resource_ids.spec (ai_chat_ui.grd, ai_rewriter_ui.grd). Cadenas sin tocar. |
| webui | 15 | brave_content_browser_client.cc (binders/throttle/IAP), chrome_untrusted_web_ui_configs.cc, brave_web_ui_controller_factory.cc, skus_internals_ui.cc, brave_settings_ui; ajustes TS: basic_page.ts, settings_menu.ts, brave_routes.ts, page_visibility.ts, toolbar.html/.ts, settings.gni, sources.gni. |
| chromium_src | 13 editados + 3 borrados | ver lista abajo. |
| patches | 1 | chrome-browser-resources-settings-BUILD.gn.patch. |
| test | 11 | test/BUILD.gn y pruebas vivas: render_view_context_menu_unittest, brave_clear_browsing_data_browsertest, brave_perf_features_processor_browsertest, brave_browser_command_controller_browsertest, brave_app_menu_model_browsertest, brave_toolbar_view_browsertest, sidebar_{browsertest,unittest}, sidebar_service_unittest, speedreader_browsertest (solo se quitaron bloques ENABLE_AI_CHAT). |
| otros | 14 | Ficheros vivos que solo se compilaban con enable_ai_chat/enable_ai_rewriter, borrados: browser/ui/views/toolbar/ai_chat_button.{cc,h}, browser/ui/side_panel/ai_chat/*, browser/ui/views/side_panel/ai_chat/*, browser/ui/webui/settings/brave_settings_leo_assistant_handler.{cc,h}, browser/ui/webui/ai_rewriter/*, components/omnibox/browser/leo_{action,provider}.{cc,h}. Y build/commands/lib/config.js: deja de pasar el arg `service_key_aichat` (declarado solo en components/ai_chat). |

### chromium_src y parches
- **Borrados** (envoltorios que solo existían para Leo; con el flag a false ya eran pass-through, así que no cambia el
  comportamiento de Chromium): `chromium_src/components/browsing_data/core/browsing_data_utils.{cc,h}`,
  `chromium_src/chrome/browser/browsing_data/chrome_browsing_data_remover_constants.h`, y `chromium_src/components/browsing_data/core/DEPS`.
- **Editados (parte muerta quitada):** renderer_context_menu/render_view_context_menu.{cc,h} (menú Leo/reescritor),
  autocomplete/chrome_autocomplete_provider_client.{cc,h}, components/omnibox/browser/{autocomplete_controller.cc,
  actions/omnibox_action.h, mock_autocomplete_provider_client.h}, chrome/renderer/{chrome_content_renderer_client.cc,
  url_loader_throttle_provider_impl.cc}, ui/webui/settings/settings_clear_browsing_data_handler.cc,
  ui/webui/chrome_untrusted_web_ui_configs.cc, prefs/browser_prefs.cc, chrome/browser/ui/BUILD.gn, DEPS (3).
  `MaybeAddLeoProvider`/`MaybeShowLeoMatch` y `MaybeCreateAIChatResourceSnifferThrottle` quedan como funciones vacías /
  `return nullptr` (sus macros siguen llamándolas; mínimo cambio).
- **Parche:** `patches/chrome-browser-resources-settings-BUILD.gn.patch`: de la línea `+` se quita
  `mojo_files = brave_settings_mojo_files mojo_files_deps = brave_settings_mojo_files_deps` (eran solo los mojom TS de
  ai_chat). Es la misma línea `+` editada, la cabecera del hunk no cambia (+1 línea sigue siendo +1).

### Residuales (`resid.sh`)
| Dir | Cifra | Justificación |
|---|---|---|
| browser/ai_chat | 0 | — |
| browser/resources/settings/brave_leo_assistant_page | 0 | — |
| browser/ui/ai_rewriter | 0 | — |
| browser/ui/webui/ai_chat | 0 | — |
| components/ai_chat | 28 | 5 en browser/misc_metrics (está en la lista de 70); 6 iOS (chromium_src/ios/...); 17 Android (build/android/config.gni, chromium_src/.../flags/android, chromium_src/.../android/browsing_data, browser/android/preferences/BUILD.gn, components/brave_mobile_subscription/renderer/android/*). Todo ignorado por el punto 5. |
| components/ai_rewriter | 0 | — |
| test/data/ai_chat | 0 | — |
| test/data/leo | 0 | — |

Informativo, no tocado: android/ios (contador de resid: 12 ficheros en ai_chat), `test/BUILD.gn:506` (`enable_ai_chat`
dentro de `if (is_android)`), `android/BUILD.gn`, `browser/ui/android/ai_chat/*`, `browser/ui/android/omnibox/*Leo*`,
`components/p3a/metric_names.h` (en la lista de 70).

### Args de gn que pasa softmac `FlyWeb/scripts/build.sh` (para quitarlos allí)
- `enable_ai_chat:false` (línea 269): su `declare_args` estaba en components/ai_chat (borrado) → gn avisará de arg sin efecto.
- `brave_ai_chat_endpoint:flyweb.invalid` (línea 194): ya no estaba declarado en ningún sitio ni antes de la poda.
- `enable_ai_rewriter` y `service_key_aichat` no los pasa build.sh (este último lo pasaba config.js; quitado).
- El comentario de la línea 167 («Leo: desactivado») y 191 pueden actualizarse.

### Dudas (lo que puede no compilar o merece revisión)
1. `brave_settings_ui.cc` sigue añadiendo `isLeoAssistantAllowed`/`isLeoAssistantHistoryAllowed` = false: los leen aún
   clear_browsing_data_dialog.ts y brave_clear_browsing_data_on_exit_page.ts (casillas ocultas de borrar historial de
   Leo). Se dejaron, junto con las prefs `browser.clear_data.brave_leo[_on_exit]` (chromium_src/.../pref_names) y su
   entrada en brave_prefs_util, porque siguen registradas y no apuntan a lo borrado.
2. La política `BraveAIChatEnabled` sigue definida en `chromium_src/components/policy/tools/generate_policy_source.py`
   pero ya no tiene mapeo en `brave_simple_policy_map.h`. Si hay una prueba que exija que toda política Brave esté
   mapeada, fallará; quitarla de la definición sería cambiar políticas (§2.3), no lo hice.
3. Comando/cadenas que quedan vivos e inertes: `IDC_TOGGLE_AI_CHAT` y `IDC_AI_CHAT_CONTEXT_*` (app/brave_command_ids.h),
   su `case` vacío en brave_browser_command_controller.cc, la entrada condicionada en brave_app_menu_model.cc (nunca se
   activa), y los grdp de cadenas `components/resources/ai_chat_*.grdp` / IDS_SETTINGS_LEO_* (cadenas: para
   chromium-rebase-l10n.py). Speedreader conserva su botón «AI» (mojom `AiChat()` y TSX) oculto por
   `aiChatFeatureEnabled=false`.
4. Edición de un `+` dentro de un parche: el `index` del parche (hash post-imagen) ya no coincide; `git apply` no lo
   comprueba, pero conviene ver que `npm run apply_patches` lo aplica.
5. `mojo_files` del settings: asumo que el BUILD.gn de Chromium 128 no los define (si los definiera, el parche
   original habría dado «Replacing nonempty list»); al no pasarlos, build_webui no copia mojom.
6. Ficheros que quedaron con funciones vacías por la poda (cosmético): `MaybeAddLeoProvider`,
   `MaybeShowLeoMatch`, `SpeedreaderToolbarDataHandlerImpl::AiChat()`, `SkusInternalsUI::GetLeoState()` (dict vacío).

---

## Informe g5-p3a (poda B2)

Worktree `/home/user/wt-g5-p3a`, rama `b2/g5-p3a`, base 5fdeb23d. **sha final: 6b61f3dc0d333de33054af6ff9feb9ee911a2934**. Sin push.

Ojo: `nube/b2-poda` apunta ahora a 1d8a13ee, no a 5fdeb23d (ha avanzado desde que se creó la rama). Por eso la lista sale con
`git log --oneline 5fdeb23d..`; con `nube/b2-poda..` aparecerían diferencias que no son de este grupo.

### Commits (`git log --oneline 5fdeb23d..`, el más antiguo primero)
```
5f29657c [b2-poda] remove browser/brave_federated
b4188138 [b2-poda] remove browser/brave_stats
c458a5a8 [b2-poda] remove browser/misc_metrics
e54d1b38 [b2-poda] remove browser/web_discovery
ffacdcbb [b2-poda] remove components/brave_federated
5858e2e4 [b2-poda] remove components/brave_stats
3deea282 [b2-poda] remove components/misc_metrics
c2c6e910 [b2-poda] remove components/p3a
c1cc64c2 [b2-poda] seams for browser/brave_federated
960a461b [b2-poda] seams for components/brave_federated
572b90ed [b2-poda] seams for browser/brave_stats
f258c1f2 [b2-poda] seams for browser/brave_stats (playlist)
a0cf0ca4 [b2-poda] seams for browser/misc_metrics
582be334 [b2-poda] seams for browser/misc_metrics (sidebar)
42fa7fdc [b2-poda] seams for browser/web_discovery
cc6d9891 [b2-poda] seams for components/brave_stats
a6a7fa20 [b2-poda] seams for components/misc_metrics
6b61f3dc [b2-poda] seams for components/p3a
```
(El commit de costuras de components/brave_federated va antes que el de browser/brave_stats; no afecta al contenido.)

### Directorios
Se borraron los 8: browser/brave_federated, browser/brave_stats, browser/misc_metrics, browser/web_discovery,
components/brave_federated, components/brave_stats, components/misc_metrics, components/p3a. No se quedó ninguno.
- **brave_stats y el updater**: nada de Sparkle/Keystone/updater ni del component updater usaba browser/brave_stats ni
  components/brave_stats. Solo lo usaban Playlist (`GetFirstRunTime`), los ajustes (interruptor del ping de uso), los
  prefs y el proceso del navegador.
- **p3a**: en FlyWeb `p3a_service()` ya devolvía null (brave_p3a_enabled=false). Ninguna parte viva usaba P3A más allá de
  métricas o interruptores. Se quedan p3a_utils y time_period_storage. `browser/p3a/p3a_core_metrics` (UMA, no está en la
  lista) también se queda: no usa components/p3a.

### Costuras (ficheros/ediciones aprox.)
| tipo | nº | detalle |
|---|---|---|
| gn | 14 ficheros / ~35 líneas | browser/sources.gni (imports y `+=` de brave_stats, misc_metrics, web_discovery; deps federated/p3a), browser/ui/BUILD.gn (federated, misc_metrics ×2, p3a, fuentes de las vistas de infobar de WDP), browser/infobars/sources.gni, browser/ntp_background/sources.gni, browser/ntp_background_images/sources.gni (fichero obsoleto que nadie importa), components/brave_shields/content/browser/BUILD.gn, test/BUILD.gn (unidad y browser tests de los 8), chromium_src/chrome/browser/DEPS, third_party/rust/chromium_crates_io/Cargo.toml (constellation-cxx: dependencia y `[patch]`) |
| buildflag | 3 bloques | `BRAVE_P3A_ENABLED` en brave_browser_process_impl.cc (braveizer y p3a_service): se dejó la rama false (nada) |
| include | ~25 | los includes de cabeceras borradas, en todos los ficheros tocados |
| prefs | 4 ficheros | brave_local_state_prefs.cc (brave_stats ×2, UptimeMonitor, StarRandomness, P3AService::RegisterPrefs, NTPP3AHelperImpl, ProcessMiscMetrics, PageMetrics, GeneralBrowserUsage); chromium_src/chrome/browser/prefs/browser_prefs.cc (3 migraciones); prefs de ajustes: el ping de uso (kStatsReportingEnabled) y P3A (kP3AEnabled) ya no se registran, así que se quitaron sus lectores |
| keyed | 6 | BraveFederatedServiceFactory y ProfileMiscMetricsServiceFactory (factorías y profile manager), PageMetricsTabHelper, include de WebDiscoveryTabHelper (brave_tab_helpers), y en BraveBrowserProcess(+Impl, +Testing): `brave_stats_updater()`, `process_misc_metrics()`, `p3a_service()` |
| webui | 6 ficheros | ajustes de recogida de datos (HTML/TS/proxy): se quitan el interruptor del ping de uso y el código de P3A; brave_privacy_handler (handlers de ping y P3A); welcome_dom_handler y welcome_browser_proxy.ts (`setP3AEnabled`); brave_new_tab_ui.cc (el receptor de NewTabMetrics se descarta) |
| otros | 6 | app menu: se quitan las métricas de menú (`RecordMenuUsage` entero); main_extra_parts (uptime monitor, `p3a Init`); main_parts y borrado de BraveConfirmP3AInfoBarDelegate; borrado de ntp_p3a_helper_impl.{cc,h,unittest} (ViewCounterService recibe `nullptr`, igual que hoy); borrado de las vistas de infobar de Web Discovery; build/commands/lib/config.js (deja de emitir los args brave_stats_*) |
| métricas convertidas en no-op | 2 | Shields `MaybeRecordShieldsUsageP3A` (cuerpo vacío; no se tocó nada más de Shields), NTP `RecordInitialP3AValues`/customize (se quitan las llamadas, el enum y la constante del histograma) |
| speedreader/tor/playlist/sidebar | 2 commits | playlist: `brave_stats::GetFirstRunTime` → helper local con el mismo cuerpo de escritorio (`first_run::GetFirstRunSentinelCreationTime()`); sidebar: se quita el include de process_misc_metrics.h (su único uso está en un bloque de AI chat) |
| chromium_src | 0 envoltorios borrados | solo se quitaron líneas en browser_prefs.cc, chrome_autocomplete_provider_client.cc (include) y DEPS |
| patches | 0 | ningún parche toca lo borrado |
| grd | 0 | no se tocaron .grd/.grdp ni cadenas (IDS de ping/P3A/WDP sin usar, quedan para `chromium-rebase-l10n.py`) |

### Envoltorios chromium_src y parches
- Ningún envoltorio borrado. Editados: `chromium_src/chrome/browser/prefs/browser_prefs.cc`,
  `chromium_src/chrome/browser/autocomplete/chrome_autocomplete_provider_client.cc` (solo un include) y
  `chromium_src/chrome/browser/DEPS`.
- Parches: ninguno.

### Residuales (resid.sh)
- browser/brave_federated, browser/web_discovery, components/brave_federated: **0**.
- browser/brave_stats: 1 → `browser/android/brave_init_android.cc` (Android).
- components/brave_stats: 1 → `browser/ntp_background/android/ntp_background_images_bridge.cc` (Android).
- components/misc_metrics: 1 → `build/android/config.gni` (Android).
- browser/misc_metrics: 5, todos dentro de `#if BUILDFLAG(ENABLE_AI_CHAT)` o en ficheros que solo se compilan con
  `enable_ai_chat`; se dejan al grupo de ai_chat (que quita esos bloques) para no chocar al fusionar:
  render_view_context_menu.cc:48, brave_omnibox_client_impl.cc:29, ai_chat_button.cc:12,
  brave_settings_leo_assistant_handler.cc:14, simple_command_source.cc:27. Igual con las llamadas a
  `process_misc_metrics()->ai_chat_metrics()` en brave_tab_helpers.cc, sidebar_items_contents_view.cc,
  chrome_autocomplete_provider_client.cc y brave_app_menu.cc (include de ai_chat_metrics.h).
- components/p3a: 8 → `chromium_src/ios/...` (6, iOS) y `browser/android/preferences/BUILD.gn` (2, Android).
  También `android/BUILD.gn`, que importa `components/p3a/buildflags.gni` (Android).
- Fuera de la búsqueda: `browser/sources.gni:352` (`brave_browser_misc_metrics_android_sources`, dentro de
  `if (is_android)`, no se toca).

### Args de gn que pasa `FlyWeb/scripts/build.sh` de softmac (hay que quitarlos allí)
- `brave_stats_updater_url` (línea 262): lo declaraba browser/brave_stats/BUILD.gn, borrado.
- `brave_p3a_enabled:false` (línea 268): lo declaraba components/p3a/buildflags.gni, borrado.
- (`brave_stats_api_key` lo declaraba components/brave_stats/browser; build.sh no lo pasa. Ya lo quité de lo que emite
  config.js.)
Si siguen ahí, gn dará el aviso «build argument has no effect».

### Dudas
1. **Fusión con el grupo ai_chat**: brave_app_menu.cc. Quité `RecordMenuUsage` entero, que contiene un bloque
   `ENABLE_AI_CHAT`. Si ai_chat quita ese bloque por su cuenta, habrá conflicto (se resuelve quedándose con mi versión).
   En brave_browser_process(_impl).h/.cc y brave_local_state_prefs.cc, ai_chat, brave_ads y referrals tocan líneas
   vecinas: probables conflictos triviales.
2. Las llamadas a `process_misc_metrics()` dentro de bloques ENABLE_AI_CHAT no compilan si ese bloque sobrevive. Con el
   flag a false no se compilan.
3. Playlist: `ScopedAllowBlockingForTesting` y `chrome/browser/first_run/first_run.h` copian lo que hacía
   first_run_util.cc. En Android cambia el comportamiento (no se compila).
4. Ajustes de recogida de datos: solo queda «metricsReportingControl», con `class="hr"` (una raya encima del primer
   elemento). Solo es estético.
5. Rust: quedan `Cargo.lock`, `gnrt_config.toml`, `vendor/star-constellation-*`, `third_party/rust/star_constellation`
   y `third_party/rust/constellation_cxx` (huérfanos; GN no los carga si nadie depende de ellos). Si alguien ejecuta
   gnrt, regenerará el lock.
6. Pruebas que siguen compilando pero ya no tiene sentido ejecutar: no encontré pruebas vivas de los histogramas
   Shields.UsageStatus ni NTP.CustomizeUsageStatus.
7. Quedan sin uso y sin dar error: `kFederatedInternals*` en webui_url_constants.h, `kP3ALearnMoreURL`, los colores e
   icono de la infobar de WDP, el identificador de infobar en chromium_src y los métodos privados
   `SetLocalStateBooleanEnabled`/`GetLocalStateBooleanEnabled` de los handlers.

### Rebase sobre nube/b2-poda (09482b94)
- **sha final tras el rebase: f080796c04c9049b77682c93b444a2bc812d7620**. Se conservan los 18 commits (`git log --oneline 09482b94..`), del 87d01068 (remove browser/brave_federated) al f080796c (seams for components/p3a).
- Commits con conflictos y ficheros:
  - browser/brave_federated: browser_context_keyed_service_factories.cc y brave_profile_manager.cc.
  - components/brave_federated, browser/brave_stats, browser/misc_metrics: prefs, factorías, proceso del navegador,
    tab helpers, BUILD.gn y otros por el estilo.
  - components/p3a: brave_local_state_prefs.cc y brave_new_tab_message_handler.cc.
- Cómo se resolvieron:
  - Casi todos los conflictos eran de dos borrados distintos sobre las mismas líneas. Los resolvió un script con estilo
    diff3: se queda el texto base menos lo que quita cada lado, y solo actúa cuando ninguno de los dos añade nada.
  - Uno se hizo a mano, en brave_new_tab_message_handler.cc. News había reescrito el `if` de la métrica de
    personalización del NTP y yo lo quitaba entero; queda quitado.
- Comprobaciones, todas limpias:
  - `git diff --check` en cada commit.
  - Sin marcadores de conflicto.
  - #if/#endif cuadran en todos los ficheros tocados.
  - Ningún `#if` vacío, ninguna lista gn huérfana ni líneas en blanco dobles nuevas.
  - Las ediciones de app menu, prefs, proceso, tab helpers y main_extra_parts, revisadas a ojo.
- resid.sh tras el rebase:
  - browser/brave_federated, browser/misc_metrics, browser/web_discovery, components/brave_federated: 0. Los 5 de
    misc_metrics en bloques de AI chat ya los quitó Leo.
  - browser/brave_stats: Android (1) y browser/brave_ads/analytics/p3a (está en la lista de 70, lo borra otro grupo).
  - components/brave_stats: Android (1), components/brave_wallet/browser/BUILD.gn y components/brave_referrals/browser/BUILD.gn
    (los dos en la lista de 70).
  - components/misc_metrics: build/android (1).
  - components/p3a: iOS (6) y Android (2).
  - Fuera de la búsqueda: `brave_stats::GetAPIKey/GetPlatformIdentifier` en `brave_browser_process_impl.cc`, dentro de
    `brave_referrals_service()`. Es del grupo de referrals (components/brave_referrals está en la lista); si ese grupo no
    lo quita, no compila.

---

## Informe g6-wallet (poda B2)

Worktree `/home/user/wt-g6-wallet`, rama `b2/g6-wallet`, base `nube/b2-poda` (= flyweb 5fdeb23d). Sin push.

### sha final y commits

sha final: **41427715**

```
41427715 [b2-poda] seams for components/brave_wallet (speedreader)
15de5828 [b2-poda] seams for components/brave_wallet (sidebar)
b3f4db9d [b2-poda] seams for components/filecoin
1f82e332 [b2-poda] seams for components/decentralized_dns
52b0d202 [b2-poda] seams for components/brave_wallet_ui
34a5dd36 [b2-poda] seams for components/brave_wallet
60105e78 [b2-poda] seams for browser/ui/webui/brave_wallet
d1b0323e [b2-poda] seams for browser/resources/settings/brave_wallet_page
137286da [b2-poda] seams for browser/ethereum_remote_client
a7e4cf39 [b2-poda] seams for browser/decentralized_dns
208d86e5 [b2-poda] seams for browser/brave_wallet
2a9190ff [b2-poda] remove test/data/brave-wallet
78b4608b [b2-poda] remove renderer/brave_wallet
6cc34c50 [b2-poda] remove components/services/brave_wallet
684a1ed2 [b2-poda] remove components/filecoin
bae73650 [b2-poda] remove components/decentralized_dns
c0f8ab6a [b2-poda] remove components/brave_wallet_ui
d4eb31f2 [b2-poda] remove components/brave_wallet
57852591 [b2-poda] remove browser/ui/webui/ethereum_remote_client
e8789ed6 [b2-poda] remove browser/ui/webui/brave_wallet
2d9c25a8 [b2-poda] remove browser/resources/settings/brave_web3_domains_page
4684861c [b2-poda] remove browser/resources/settings/brave_wallet_page
18bc81dd [b2-poda] remove browser/ethereum_remote_client
cb43a455 [b2-poda] remove browser/decentralized_dns
f05b1a0f [b2-poda] remove browser/brave_wallet
```

Las costuras de un fichero que tocaba varios directorios van en el commit del primero de la lista del grupo
(casi todo cae en `browser/brave_wallet`, `browser/ethereum_remote_client` o `components/brave_wallet`); el cuerpo de cada
commit lo dice. No hay commit de costuras propio para `brave_web3_domains_page`, `browser/ui/webui/ethereum_remote_client`,
`components/services/brave_wallet`, `renderer/brave_wallet` ni `test/data/brave-wallet`: sus costuras estaban en ficheros
que ya iban en el commit de un directorio anterior.

### Directorios

Borrados los 14: browser/brave_wallet, browser/decentralized_dns, browser/ethereum_remote_client,
browser/resources/settings/brave_wallet_page, browser/resources/settings/brave_web3_domains_page,
browser/ui/webui/brave_wallet, browser/ui/webui/ethereum_remote_client, components/brave_wallet, components/brave_wallet_ui,
components/decentralized_dns, components/filecoin, components/services/brave_wallet, renderer/brave_wallet,
test/data/brave-wallet.

No se ha revertido nada (§2.3): Shields, sync, políticas, rebranding, updater, flyweb_ntp y component updater no usaban nada
del grupo (rg en components/brave_sync, browser/sync, brave_shields, browser/policy, flyweb*, component_updater: 0).

Ficheros vivos que solo servían a Wallet/ERC/DNS descentralizado y se han borrado como costura (48):
- Extensión Crypto Wallets (ERC): browser/extensions/api/brave_wallet_api.{cc,h}, brave_wallet_apitest.cc,
  ethereum_remote_client_unittest.cc, ethereum_remote_client_util.{cc,h}, common/extensions/api/brave_wallet.json,
  _brave_wallet_api_features.json, components/definitions/chrome_brave_wallet.d.ts,
  test/data/extensions/api_test/{braveWallet,notBraveWallet,braveShieldsWithWallet}/.
- DNS descentralizado: browser/net/decentralized_dns_network_delegate_helper{.cc,.h,_unittest.cc}.
- Interfaz: browser/ui/brave_wallet/ (BUILD.gn, wallet_bubble_manager_delegate.h), browser/ui/wallet_bubble_manager_delegate_impl.*,
  browser/ui/views/wallet_bubble_focus_observer*, browser/ui/views/toolbar/wallet_button*
  (+ notification source y sus browsertests), browser/ui/views/permission_bubble/brave_wallet_permission_prompt_impl.*,
  browser/ui/webui/settings/brave_wallet_handler{.cc,.h,_unittest.cc}.
- Permisos: components/permissions/contexts/brave_wallet_permission_context.*,
  browser/permissions/brave_wallet_permission_context_{browsertest,unittest}.cc, browser/permissions/permission_manager_browsertest.cc
  (todas sus pruebas eran de permisos Ethereum/Solana con subpeticiones).
- Otros: fuzzers/brave_wallet/, renderer/test/js_ethereum_provider_browsertest.cc,
  components/resources/brave_wallet_resources.grdp y decentralized_dns_resources.grdp (todos sus `<include>` apuntaban a lo borrado
  o a node_modules solo de la cartera).

### Costuras arregladas (tipo × número)

| Tipo | Ficheros | Ediciones (aprox.) |
|---|---|---|
| gn (BUILD.gn, .gni, DEPS) | 26 | ~150 líneas: deps, sources, imports de buildflags ERC, bloques `if (ethereum_remote_client_enabled)`, entrada DEPS de librustzcash, include_rules |
| buildflag (ETHEREUM_REMOTE_CLIENT_ENABLED) | 17 | ~30 bloques `#if` quitados (ver dudas: el flag estaba en **true**) |
| include (+ uso) | ~45 C++ | includes de cabeceras borradas y el código que las usaba |
| prefs | 6 | registro local/perfil y migraciones de wallet y decentralized_dns, allowlist de settingsPrivate (13 prefs), allowlist incógnito, entrada de política BraveWalletDisabled |
| features | 1 (about_flags.cc) | 6 entradas (native-brave-wallet, zcash, bitcoin, ankr, simulaciones, Crypto Wallets) |
| keyed | 5 | 8 factorías en EnsureBrowserContextKeyedServiceFactoriesBuilt, tab helper, GetServiceForContext en profile manager, DependsOn en BraveRendererUpdaterFactory, delegado WalletDataFilesInstaller en BraveBrowserProcessImpl |
| grd | 4 + 2 grdp borrados | 13 `<include>` y 2 `<part>` en brave_components_resources.grd; 13 entradas de resources/resource_ids.spec; paks en components/resources/BUILD.gn; html ERC en ui/webui/resources/BUILD.gn. Cadenas (.grdp de strings, .xtb) sin tocar |
| webui | ~20 | controller factory, configs trusted/untrusted (6), binders mojo (5), handler y flags de ajustes, 5 mensajes de BraveDefaultExtensionsHandler, TS/HTML de ajustes (basic_page, page_visibility, privacy_page, site_details, site_settings_page, brave_routes, toolbar), br_toolbar, settings.gni/sources.gni |
| chromium_src | 13 | ver lista abajo |
| patches | 2 | ver lista abajo |
| test | 10 vivos recortados + 11 borrados | test/BUILD.gn, browser/permissions/BUILD.gn, renderer/test/BUILD.gn, browsertests de prefs, scheme load, toolbar, lifetime manager, location bar, content client |
| otros | ~12 | mojom DynamicParams (5 campos de proveedores fuera), BraveRendererUpdater, observer del renderer, servicio de utilidad BraveWalletUtilsService, botón y burbuja en toolbar/BraveBrowserView/browser_commands/command controller, brave_pages, PermissionOriginLifetimeMonitorImpl, presubmit/eslint/jest, brave_license_helper.py |

Costuras mínimas en commit aparte (punto 7): sidebar (`SidebarService::GetBuiltInItemForType(kWallet)` devuelve
`SidebarItem()` como antes, ya que IsAllowed era false; fuera dep brave_wallet/common) y speedreader (browsertest: quitada la
llamada a SetDefaultSolanaWallet).

### chromium_src y parches

Envoltorios **borrados** (cambian comportamiento de Chromium frente a hoy, aunque en la práctica no, porque la extensión ERC
nunca se cargaba y la cartera estaba apagada):
- `chromium_src/chrome/browser/sessions/session_common_utils.cc` (solo excluía URLs de la extensión ERC de la restauración).
- `chromium_src/chrome/browser/ui/hid/hid_chooser_controller.cc` (solo cambiaba el título del selector HID para el origen de la cartera).

Envoltorios **recortados** (parte muerta fuera):
- component_extensions_allowlist/allowlist.cc (id ERC), history/history_utils.cc (queda la rama `#else`),
  ui/browser_navigator.cc (chrome://wallet en incógnito devuelve `false` fijo, que era el valor por defecto de la pref borrada),
  ui/views/permissions/chooser_bubble_ui.cc (fuera todo lo del panel de la cartera; queda la macro SetExtraView/footnote),
  permissions/permission_manager_factory.{cc,h} (fuera los contextos BRAVE_ETHEREUM/SOLANA y los `friend` de pruebas de wallet),
  ui/views/permissions/permission_prompt_factory.cc (fuera el prompt de wallet), components/permissions/permission_request_manager.cc
  (ShouldGroupRequests ya no agrupa subpeticiones de wallet), prefs/browser_prefs.cc (migraciones), ui/webui/chrome_untrusted_web_ui_configs.cc,
  ui/webui/chrome_web_ui_configs.cc, chromium_src/chrome/browser/DEPS, chromium_src/components/permissions/DEPS.

Parches:
- **Borrado** `patches/extensions-browser-user_script_manager.h.patch` (solo añadía `friend class ::EthereumRemoteClientService`).
- Recortado `patches/tools-metrics-histograms-metadata-page-histograms.xml.patch`: quitada la línea `+<variant name=".WalletPanel"/>`,
  cabecera `@@ -183,6 +183,17 @@` → `@@ -183,6 +183,16 @@`.
- No tocados (enums/tipos de Chromium, por la regla de no quitar valores): router.ts.patch (BRAVE_WALLET/BRAVE_WEB3 en el tipo de rutas),
  site_settings-constants.ts.patch y settings_category_default_radio_group.ts.patch (ETHEREUM/SOLANA),
  permissions_policy_features.json5.patch (Ethereum/Solana), y los enums ContentSettingsType/RequestType/PermissionType
  BRAVE_ETHEREUM/BRAVE_SOLANA en chromium_src (content_settings_types.mojom, request_type.*, permission_utils.*, registro,
  uma, etc.). Siguen registrados; solo se han quitado sus usos con código borrado.

### Residuales (resid.sh, fuera de los 70)

- browser/brave_wallet: 2 → browser/ui/BUILD.gn:1202 (dentro de `if (is_android)`, no se toca) y third_party/argon2/BUILD.gn:21
  (lista `visibility`, gn no resuelve etiquetas de visibility; argon2 queda sin usuarios). android/ios: 1.
- browser/decentralized_dns: 0 (android/ios: 1).
- browser/ethereum_remote_client: 0.
- browser/resources/settings/brave_wallet_page: 0. brave_web3_domains_page: 0.
- browser/ui/webui/brave_wallet: 1 → browser/ui/BUILD.gn:1203 (bloque `if (is_android)`). android/ios: 1.
- browser/ui/webui/ethereum_remote_client: 0.
- components/brave_wallet: 20, todos justificados: android (build/android/config.gni, test/BUILD.gn:1205 en el apk de
  pruebas Android, browser/permissions/*_android.*, connect_account_android.cc, browser/ui/BUILD.gn:1204-1206 en `if (is_android)`,
  chromium_src/chrome/browser/flags/android/chrome_feature_list.cc), iOS (chromium_src/ios/... prefs: BUILD.gn, browser_prefs.mm, DEPS)
  y `visibility` de third_party/bitcoin-core (3) y third_party/argon2 (2). android/ios informativo: 32.
- components/brave_wallet_ui: 5 → browser/ui/BUILD.gn:1207-1211 (`if (is_android)`).
- components/decentralized_dns: 5 → browser/android/preferences (2, Android) y chromium_src/ios/.../prefs (3, iOS). android/ios: 1.
- components/filecoin, components/services/brave_wallet, renderer/brave_wallet, test/data/brave-wallet: 0.
  (components/ipfs/BUILD.gn apunta a components/filecoin/rs, pero ipfs está en la lista de 70.)

Sin tocar a propósito (no rompen la compilación): `net/decentralized_dns/constants.h` y su uso en
`chromium_src/net/base/lookup_string_in_fixed_set.cc` (TLD .eth/.crypto/.sol en la omnibox, autónomo); constantes de URL
`kWalletPageHost`… en components/constants; comandos IDC_SHOW_BRAVE_WALLET* y entrada de menú (nunca habilitados);
cadenas (.grdp de strings, wallet_strings.grdp, decentralized_dns_strings.grdp, .xtb) y el registro de cadenas en
brave_settings_localized_strings_provider.cc; definición de la política BraveWalletDisabled en
chromium_src/components/policy/tools/generate_policy_source.py; package.json/package-lock.json (dependencias npm de la
cartera); .gitignore, .github/labeler.yml, codeql, .sonarcloud, .prettierignore; slug `ethereum_remote_client_extension` en
script/lib/l10n/transifex/common.py; ids de la extensión en common/extensions/api/_api_features.json; test/filters/*.filter;
test/data/dapp.html y test/data/wallet/ (sin usuarios).

#### Terceros que quedan sin usuarios (no tocados en este paso)
- C/C++: third_party/argon2, third_party/bitcoin-core, third_party/ethash (third_party/bip39wally-core-native sigue en uso por brave_sync).
- Rust usados directamente solo por lo borrado: bech32/v0_9, bls_signatures/v0_12, ed25519_dalek_bip32/v0_2, forest_bigint/v0_1,
  fvm_shared/v3, libsecp256k1/v0_7, orchard/v0_8; y, salvo dependencias entre crates, blake2b_simd/v1, byteorder/v1, cid/v0_8,
  curve25519_dalek/v3, fvm_ipld_encoding/v0_3, incrementalmerkletree/v0_5, memuse/v0_2, multihash/v0_16, nonempty/v0_7, rand/v0_8
  (thiserror/v1 sigue en uso por adblock y speedreader). Además third_party/rust/brave_wallet/v1 y filecoin_cxx/v1 (README),
  y los vendor de zcash/orchard/fvm/bls en third_party/rust/chromium_crates_io (Cargo.toml/Cargo.lock).
- npm: third_party/npm_@glif_filecoin-wallet-provider, npm_@solana_web3.js, npm_@ledgerhq_hw-app-solana, npm_@brave_wallet-standard-brave,
  components/third_party/crypto_wallets.
- La dependencia gclient de librustzcash se ha quitado de DEPS (apuntaba dentro de components/brave_wallet).

### Args de gn / buildflags para softmac

- `ethereum_remote_client_enabled` (definido en browser/ethereum_remote_client/buildflags/buildflags.gni, borrado):
  `FlyWeb/scripts/build.sh` **no** lo pasa (comentario en la línea 170 de build.sh sobre «Wallets y Rewards… sin argumentos aquí»;
  conviene actualizar ese comentario). Ya no hay ningún `import()` de ese .gni en lo vivo.
- `enable_gemini_wallet:false` (línea 272 de build.sh) es de Rewards (components/brave_rewards), no de este grupo.
- `brave_infura_project_id` / `BRAVE_INFURA_PROJECT_ID` (buildflag de components/brave_wallet/common) desaparece con el directorio; build.sh no lo pasa.

### Dudas (lo que puede no compilar o cambia algo)

1. **ETHEREUM_REMOTE_CLIENT_ENABLED estaba en true** en FlyWeb (buildflags.gni: «kept at Brave's default»), no en false.
   He quitado las ramas `#if` enteras igualmente (el código está borrado); el efecto visible es nulo porque la extensión nunca se cargaba
   (AddEthereumRemoteClientExtension estaba vacío), pero ya no se recomienda su instalación, ni se oculta su URL en historial/sesiones.
2. Ajustes: desaparecen las entradas Ethereum/Solana de «Configuración de sitios» y de los detalles de sitio (antes visibles porque
   kNativeBraveWalletFeature estaba activo por defecto) y el interruptor del icono de la cartera. Los tipos de contenido
   BRAVE_ETHEREUM/SOLANA siguen registrados (enums), así que los valores guardados no se tocan.
3. `common/brave_renderer_configuration.mojom`: he quitado los 5 campos de proveedores de DynamicParams y adaptado la única
   llamada (`DynamicParams::New(de_amp, onion, widevine, playlist)`); comprobar que no haya otro constructor posicional fuera (rg: no).
4. chooser_bubble_ui.cc: sin el panel de la cartera quedan los includes y la macro SetExtraView/SetFootnoteView, que usa la variable
   `browser` del original de Chromium 128; si el original no la define con ese nombre, fallará (antes la definía igual el mismo código).
5. Prefs: ya no se registran las prefs de wallet ni de decentralized_dns ni se migran/limpian; los valores antiguos se quedan sin registrar
   en los perfiles existentes (Chromium los conserva sin error). He quitado todas las lecturas vivas que conocía
   (autoLockMinutesValue en ajustes, toolbar, navigator, renderer updater); si queda alguna lectura de una pref sin registrar, CHECK en ejecución.
6. La política BraveWalletDisabled sigue definida en generate_policy_source.py pero ya no mapea a ninguna pref; algún test de
   políticas (policy_test_cases) podría quejarse.
7. ReinstallAsNonComponent (BraveComponentLoader) y `pref_change_registrar_` de BraveDefaultExtensionsHandler quedan sin uso; no
   debería dar error (no son campos triviales).
8. android: además de no tocar android/ y los `if (is_android)` de BUILD.gn, en ficheros C++ compartidos he quitado también los bloques
   `#if BUILDFLAG(IS_ANDROID)` que usaban la WebUI Android de la cartera (brave_content_browser_client.cc, brave_web_ui_controller_factory.cc),
   para no dejar includes rotos; quedan rotos browser/permissions/*_android.*, browser/android/preferences y browser/ui/BUILD.gn (android).
9. Fusión con otros grupos: browser/sources.gni, browser/ui/BUILD.gn, test/BUILD.gn, about_flags.cc, brave_content_browser_client.cc,
   resource_ids.spec, el parche de histogramas y components/resources/BUILD.gn los tocan también otros grupos; pueden dar conflictos de texto.

### Rebase sobre nube/b2-poda (218876fc)

- `b2/g6-wallet` está rebasada sobre la rama local `nube/b2-poda` (218876fc, que ya trae PSST/IPFS, News, VPN, Leo, P3A/stats,
  Rewards/Ads/SKUs). **sha final: 9b8eb665** (25 commits: 14 `remove` + 11 `seams`, mismo orden y asuntos de antes).
  `nube/b2-poda` sin tocar; sin push.
- 45 conflictos de fichero en 8 de los 11 commits de costuras (browser/brave_wallet: 20; browser/ethereum_remote_client: 7;
  brave_wallet_page: 2; browser/ui/webui/brave_wallet: 1; components/brave_wallet: 11; filecoin: 1; sidebar: 2; speedreader: 1).
  Los resolví con diff3: cuando los dos lados solo borraban líneas de la base, me quedé con la intersección (se quita lo que
  quitaba cada lado). Hubo 4 trozos que había que mirar a mano: brave_web_ui_controller_factory.cc (2), navigation_bar_data_provider.cc
  y brave_pages.cc. Ninguno era «modificado aquí / borrado allí».
- Arreglos tras resolver: `#if !BUILDFLAG(IS_ANDROID)` duplicado en NewWebUI (factory), `}` pegado al final de
  StartBraveServices (process impl), bloque `#if IS_WIN||IS_MAC||IS_LINUX` vacío en brave_simple_policy_map.h (sin el include de
  Rewards ni el de Wallet), dobles líneas en blanco (grd de componentes, factory, content client, factorías con clave) y dos
  líneas en blanco al final de fichero que ya traía mi rama (toolbar browsertest, default extensions handler), metidas con
  fixup en su commit.
- Comprobaciones: `git show --check` limpio en los 25 commits; sin marcadores de conflicto; los `#if/#endif` y las llaves,
  corchetes y paréntesis cuadran igual que en 218876fc en todos los ficheros modificados; resources/resource_ids.spec se puede
  leer como literal de Python (25 entradas, sin `},` duplicados).
- browser/net/decentralized_dns_network_delegate_helper.{cc,h,_unittest.cc}: los borra mi commit de browser/brave_wallet. Ya no queda
  ninguna referencia (brave_request_handler.cc y browser/net/sources.gni limpios).

#### resid.sh sobre los 70 directorios (último grupo)
Los 70 están borrados. Los 4 que se quedan (components/ntp_background_images, p3a_utils, time_period_storage, webcompat)
salen en resid porque existen y se usan, como estaba previsto.
Si quito android/ios/presubmit/.github, solo queda esto, y todo es de este grupo y está justificado:
- browser/ui/BUILD.gn:955-964 (brave_wallet, webui/brave_wallet, components/brave_wallet, brave_wallet_ui): dentro de `if (is_android)`.
- test/BUILD.gn:1041 (`brave_wallet/common:mojom_java`): dentro del `if (is_android)` del apk de pruebas.
- third_party/argon2/BUILD.gn:21-23 y third_party/bitcoin-core/BUILD.gn:31-32,81: listas `visibility` (gn no resuelve esas
  etiquetas; las dos bibliotecas se quedan sin usuarios).
Con referencias relativas entre comillas (`"<dir>/` o `'<dir>/`) a cualquiera de los 70 fuera de android/ios/presubmit/.github: 0.

#### Cosas que me preocupan
- components/resources/BUILD.gn importa dos veces `//brave/components/playlist/common/buildflags/buildflags.gni` (líneas 6-7).
  Ya estaba así en 218876fc (viene de otro grupo). Habría que confirmar si gn lo acepta; por si acaso, mejor dejar una sola línea.
- Los 4 trozos resueltos a mano y la intersección automática son edición sin compilar. Los más delicados son
  brave_web_ui_controller_factory.cc (los `#if` de Android en NewWebUI y GetWebUIFactoryFunction) y brave_content_browser_client.cc.
- navigation_bar_data_provider.cc: el parámetro `profile` se queda sin uso (no da error).

---

## Informe g7-rewards (poda B2)

Rama `b2/g7-rewards` (worktree /home/user/wt-g7-rewards), base `nube/b2-poda` = flyweb 5fdeb23d.
**sha final: 3cacac55179cb3a001952d0f67eda8b46850132f** (sin push). 39 commits:

```
da7e1e8d [b2-poda] remove browser/brave_adaptive_captcha
d02d1698 [b2-poda] remove browser/brave_ads
5cf08f28 [b2-poda] remove browser/brave_referrals
a5676d2a [b2-poda] remove browser/brave_rewards
17daa245 [b2-poda] remove browser/greaselion
bef34c40 [b2-poda] remove browser/skus
c26ac5e7 [b2-poda] remove browser/ui/brave_ads
6f558a81 [b2-poda] remove browser/ui/brave_rewards
8c2489d9 [b2-poda] remove browser/ui/views/brave_ads
2cf2891a [b2-poda] remove browser/ui/webui/brave_rewards
27d6a11f [b2-poda] remove components/brave_adaptive_captcha
c6747579 [b2-poda] remove components/brave_ads
0ee89ad5 [b2-poda] remove components/brave_referrals
1c2366f7 [b2-poda] remove components/brave_rewards
8fa6b9a0 [b2-poda] remove components/challenge_bypass_ristretto
1209984e [b2-poda] remove components/greaselion
a41ded99 [b2-poda] remove components/services/bat_ads
529ada45 [b2-poda] remove components/services/bat_rewards
b65e497a [b2-poda] remove components/skus
7ef92d86 [b2-poda] remove components/test/brave_rewards
876f7675 [b2-poda] remove test/data/brave_ads
0b8f6fbc [b2-poda] remove test/data/brave_rewards
92b1d2d3 [b2-poda] remove test/data/greaselion
c89051b4 [b2-poda] remove test/data/greaselion-data
78ef473e [b2-poda] remove test/data/rewards-data
400cb7bd [b2-poda] seams for browser/brave_adaptive_captcha
c0b7bc94 [b2-poda] seams for browser/brave_ads
12337ea8 [b2-poda] seams for browser/brave_referrals
dea22015 [b2-poda] seams for browser/brave_rewards
6ea3dd62 [b2-poda] seams for browser/greaselion
ae5c7171 [b2-poda] seams for browser/skus
ac37e5d9 [b2-poda] seams for browser/ui/brave_rewards
b6345d10 [b2-poda] seams for components/brave_adaptive_captcha
7381ef90 [b2-poda] seams for components/brave_ads
547584c0 [b2-poda] seams for components/brave_rewards
bb275ff4 [b2-poda] seams for components/greaselion
1e8df49a [b2-poda] seams for components/services/bat_ads
061363ea [b2-poda] seams for components/skus
3cacac55 [b2-poda] seams for browser/brave_ads (tor)
```

### Directorios
Los 25 del grupo están borrados (un commit cada uno). **No se ha dejado ninguno.** Comprobado (§6): ni Shields ni sync ni el
updater/Sparkle ni flyweb_ntp, components/flyweb* o browser/flyweb usan nada de verdad. brave_referrals solo
lo usaba brave_stats (que es de otro grupo) y la parte de super-referral del NTP. El updater no lo usa.

Ficheros vivos muertos que se han borrado en las costuras (fuera de la lista de 70; solo servían a Rewards/Ads/Skus/Greaselion):
browser/extensions/api/{brave_rewards_api,greaselion_api,rewards_notifications_api}.{cc,h};
common/extensions/api/{brave_rewards,greaselion,rewards_notifications}.json;
browser/ui/webui/{brave_rewards_page_ui,brave_rewards_internals_ui,brave_rewards_source,skus_internals_ui}.{cc,h};
browser/ui/views/brave_actions/brave_rewards_action_view.{cc,h} (el botón de Rewards de la barra de direcciones) y
brave_actions_container_browsertest.cc (solo probaba ese botón); browser/ui/views/brave_rewards/ (tip_panel_bubble_host);
browser/net/search_ads_header_network_delegate_helper{.cc,.h,_unittest.cc}; browser/notifications/ads_notification_handler.{cc,h};
renderer/skus/; components/brave_extension/.../background/greaselion.ts;
components/brave_new_tab_ui/components/default/rewards/ (widget de Rewards del NTP); components/definitions/rewardsInternals.d.ts.
Quedan huérfanos, pero sin romper nada (nadie los compila): ui/brave_ads/ (biblioteca de notificaciones de anuncios) y
third_party/rust/{skus,skus_cxx,challenge_bypass_ristretto,challenge_bypass_ristretto_cxx}. Habría que borrarlos aparte.

### Costuras (tipo × ficheros / ediciones aprox.)
| tipo | ficheros | ediciones |
|---|---|---|
| gn (BUILD.gn/.gni/DEPS; sources de los ficheros borrados) | 24 | ~150 líneas |
| buildflag (ENABLE_GREASELION, ENABLE_GEMINI_WALLET, bloques skus con VPN/AI_CHAT) | 7 | 12 |
| include + uso (C++) | 38 | ~120 |
| prefs (profile/local_state/migraciones/settings allowlist) | 4 | 14 |
| features (about_flags: skus-sdk, rewards-gemini, 5 de rewards y 7 de ads) | 1 | 14 entradas |
| keyed (factorías, tab helpers, process impl, DependsOn) | 7 | 20 |
| grd (part de skus en brave_components_resources.grd; 9 entradas de resource_ids.spec; paks) | 3 | 13 |
| webui (controller factory, chrome_web_ui_configs, chrome-urls, data sources, TS del NTP, d.ts, extensión) | 14 | ~30 |
| chromium_src | 3 | ver abajo |
| patches | 1 | borrado |
| test (test/BUILD.gn, pruebas vivas) | 14 | ~70 |
| política (brave_simple_policy_map.h) | 1 | 1 entrada |
| otros (TS del NTP y brave_extension, _api_features.json) | 8 | — |

Detalles relevantes:
- **Política**: quitada la entrada `kBraveRewardsDisabled → brave_rewards::prefs::kDisabledByPolicy` de
  browser/policy/brave_simple_policy_map.h. La política BraveRewardsDisabled sigue definida (chromium_src/components/policy/
  tools/generate_policy_source.py) y el mobileconfig de softmac la sigue poniendo: ahora no apunta a ninguna pref (inocuo).
- **NTP (ntp_background_images, que se queda)**: ViewCounterService ya no recibe AdsService (se cambió la firma; solo la
  llaman la factoría y el unittest). La imagen patrocinada sale siempre del modelo, sin frequency capping de anuncios, y no se
  envían eventos de anuncios. Se borraron GetBackgroundFromAdInfo/AdInfoMatchesSponsoredImage. En
  NTPBackgroundImagesService, super-referral sin código de referido: CheckSuperReferralComponent marca la instalación como
  no-SR, GetReferralPromoCode devuelve "" y el monitor de la pref no hace nada. En FlyWeb Init() ya no registraba nada.
  La factoría y BraveNewTabMessageHandler fijan `is_supported_locale`/`featureFlagBraveNTPSponsoredImagesWallpaper` = false.
  NTPP3AHelperImpl: IsRewardsDisabled() devuelve true y kPageLandAfter es una constante local de 5 s (el valor por defecto de antes).
- **NTP TS (brave_new_tab_ui, vivo)**: el JS llamaba a chrome.braveRewards al cargar el módulo (apiEventsToStore.ts), y con la
  API borrada **habría roto el NTP**. Quitados esos listeners y rewardsInitData. braveRewardsSupported = false.
  Widget de Rewards borrado; renderRewardsWidget devuelve null. Configure.tsx importa formatMessage de $web-common.
  rewardsExtensions.d.ts: los tipos que importaba de brave_rewards se sustituyen por tipos estructurales (number/Optional).
- **Settings**: isBraveRewardsSupported y brToolbarShowRewardsButton quedan en false (las claves siguen, para no romper loadTimeData).
- Pruebas borradas porque solo probaban lo borrado: ExcludeServicesInOTRAndGuestProfiles, las 8 SearchAds* de
  brave_search_browsertest, las 3 de anuncios de view_counter_service_unittest, StopSendingAfterEnablingRewards y los tests de
  código de referido de ntp_background_images_service_unittest.
- **Tor** (commit aparte `seams for browser/brave_ads (tor)`): solo tor_profile_manager_browsertest (quitadas 2 aserciones y
  2 includes) y la dep brave_ads de browser/tor/test/BUILD.gn. El comportamiento de Tor no cambia.

### chromium_src y parches
- **Borrado** chromium_src/chrome/browser/notifications/notification_display_service_impl.cc. Solo existía para registrar
  AdsNotificationHandler. Ahora se compila el fichero de Chromium sin envoltorio.
- **Borrado** patches/chrome-browser-notifications-notification_display_service_impl.cc.patch. Su única línea + era la macro
  BRAVE_ADD_BRAVE_ADS_NOTIFICATION_HANDLER, así que el parche se queda vacío. Se mantiene el enum BRAVE_ADS = 9 de
  notification_handler_impl.h, por la numeración.
- Editados: chromium_src/chrome/browser/prefs/browser_prefs.cc (migraciones de rewards/ads),
  chromium_src/chrome/browser/ui/webui/chrome_web_ui_configs.cc (3 configs de Rewards),
  chromium_src/chrome/common/webui_url_constants.cc (quitados de chrome://chrome-urls los hosts de rewards, rewards-internals y
  skus-internals), chromium_src/chrome/browser/DEPS.
- No se ha tocado: patches/tools-metrics-histograms-metadata-page-histograms.xml.patch (variantes .RewardsPanel/.TipPanel; es
  solo XML de métricas y no afecta a la compilación).

### Residuales (resid.sh)
Están a 0: browser/brave_adaptive_captcha, brave_referrals, brave_rewards, greaselion, ui/brave_ads, ui/brave_rewards,
ui/views/brave_ads, ui/webui/brave_rewards, components/challenge_bypass_ristretto, services/bat_rewards,
test/brave_rewards y los 5 de test/data.
Con cifra (todo justificado):
- browser/brave_ads 5, browser/skus 2, components/brave_adaptive_captcha 2, components/brave_ads 11, components/brave_referrals 14,
  components/brave_rewards 19, components/greaselion 1, services/bat_ads 2, components/skus 49. Las líneas caen en estos grupos:
  * **Dentro de los 70** (de otros agentes): browser/brave_stats, browser/day_zero_browser_ui_expt, browser/brave_vpn,
    browser/ai_chat, browser/brave_news, components/{brave_vpn,ai_chat,brave_news,brave_federated,p3a,webcompat_reporter}.
  * **Solo Android/iOS** (se cuentan, no se tocan): browser/android/**, build/android/config.gni,
    browser/ntp_background/android/ntp_background_images_bridge.cc, components/brave_mobile_subscription/renderer/android/**,
    chromium_src/chrome/browser/flags/android/chrome_feature_list.cc y chromium_src/ios/**.
    Además, android/ e ios/ (cifras de resid: 2, 1, 11, 13, 12).
  * **Solo con enable_brave_vpn** (flag a false): browser/ui/views/toolbar/brave_vpn_button_unittest.cc y
    brave_vpn_panel_controller_browsertest.cc. Los usos de skus:: en bloques `#if BUILDFLAG(ENABLE_BRAVE_VPN)` o
    `ENABLE_AI_CHAT` (brave_tab_helpers.cc y 4 browsertests de toolbar/menú) se quedan para los agentes de VPN y Leo.
    Ya está quitado el include incondicional de skus en esos ficheros.
  * **Configuración de presubmit**: chromium_presubmit_config.json5 (4 rutas en listas de exclusión, inocuo).
    No hay ningún residual sin justificar.

### Args de gn que pasa FlyWeb/scripts/build.sh (declarados en components/brave_rewards/core/config.gni, ya borrado)
Hay que quitarlos de build.sh. Ahora gn avisará de "has no effect":
rewards_grant_{dev,staging,prod}_endpoint, bitflyer_production_{client_id,client_secret,fee_address,url},
gemini_production_{api_url,client_id,client_secret,fee_address,oauth_url}, uphold_production_{api_url,client_id,client_secret,
fee_address,oauth_url}, zebpay_production_{api_url,client_id,client_secret,oauth_url}.
También desaparecen `enable_greaselion` y `enable_gemini_wallet` (build.sh no los pasa).
build/commands/lib/config.js (tooling npm de Brave) sigue pasando rewards_grant_* si se usa `npm run build`. No lo he tocado.

### Dudas (lo que puede no compilar o cambia comportamiento)
1. **enable_greaselion era true** (= enable_extensions), no false. Sus bloques `#if BUILDFLAG(ENABLE_GREASELION)` se
   quitaron enteros, porque solo usaban greaselion. Es un cambio de comportamiento: Greaselion (scripts de creadores de
   Rewards) deja de existir.
2. brave_new_tab_message_handler.h ahora incluye base/values.h (antes le llegaba de ads_service.h). Puede faltar algún include
   transitivo más en otros ficheros que lo recibían de cabeceras de brave_ads/brave_rewards: es lo primero que conviene mirar si
   falla la compilación.
3. view_counter_service.cc: BrandedWallpaperLogoClicked deja `creative_instance_id`, `destination_url` y `wallpaper_id` sin
   usar. NTPP3AHelperImpl::IsRewardsDisabled(prefs) deja `prefs` sin usar. Chromium no activa -Wunused-parameter, así que no
   debería fallar.
4. brave_web_ui_controller_factory.cc: la cadena de `||` ahora termina en `false)`. Es correcto, pero quizá no le guste a
   clang-format o al presubmit.
5. Pruebas que ya fallaban en FlyWeb antes de la poda (Init() de NTPBackgroundImagesService no registra componentes):
   ntp_background_images_service_unittest sigue igual de roto, solo se ha arreglado para que compile.
   LandCountReported ahora usa 5 s en lugar del parámetro de 10 s; los tiempos de la prueba deberían seguir valiendo.
6. Third_party Rust: chromium_crates_io/Cargo.toml y Cargo.lock siguen apuntando a components/skus/browser/rs/* y
   components/challenge_bypass_ristretto/rust/cxx. No afecta a gn (los BUILD.gn de third_party/rust ya están generados y nadie
   los depende), pero romperá `gnrt` si alguien regenera los crates. Hay que quitarlos de Cargo.toml y regenerar.
7. La política BraveRewardsDisabled queda definida pero sin mapear: la prueba de Chromium policy_test_cases puede quejarse.
8. Interfaz que sigue apuntando a chrome://rewards (no se puede pulsar o está oculta, pero no se ha borrado): el enlace "reset
   rewards data" en clear_browsing_data_dialog.ts (settings), los callbacks de chrome.braveRewards.* en newTab/index.tsx
   (inalcanzables con braveRewardsSupported=false), BatAdLabel en braveNews/displayAd, IDC_SHOW_BRAVE_REWARDS/ShowBraveRewards
   (el comando ya no se activa), y las constantes kRewardsPageHost/kSkusInternalsHost en components/constants. Además,
   chromium_src favicon_utils, browser_navigator y tab_renderer_data comparan con kRewardsPageHost (inocuo).
9. Posibles conflictos al integrar: brave_new_tab_message_handler.cc, newTab/index.tsx, Configure.tsx y
   chrome/common/webui_url_constants.cc los tocarán también otros grupos (News, Wallet).
10. Las cadenas IDS_* de Rewards/Ads (brave_components_strings, generated_resources, .xtb) no se han tocado. Se quitarán con
    chromium-rebase-l10n.py.

### Rebase sobre nube/b2-poda (f080796c: PSST/IPFS, News, VPN, Leo y P3A/stats)
**sha final tras el rebase: 218876fce6ea323c2aaad098891c3fa22216c756** (sin push; nube/b2-poda no se ha tocado). Son 39 commits
en el mismo orden; el sha anterior al rebase era 3cacac55. Commits:
```
16bc4a90 [b2-poda] remove browser/brave_adaptive_captcha
c22fd43d [b2-poda] remove browser/brave_ads
b4620157 [b2-poda] remove browser/brave_referrals
3d3be1b6 [b2-poda] remove browser/brave_rewards
208dbcfe [b2-poda] remove browser/greaselion
9b649c25 [b2-poda] remove browser/skus
60f21231 [b2-poda] remove browser/ui/brave_ads
906c525a [b2-poda] remove browser/ui/brave_rewards
9526e288 [b2-poda] remove browser/ui/views/brave_ads
cbaf4e07 [b2-poda] remove browser/ui/webui/brave_rewards
db5b3fee [b2-poda] remove components/brave_adaptive_captcha
d3705e28 [b2-poda] remove components/brave_ads
d2a1a4c1 [b2-poda] remove components/brave_referrals
3da36e1e [b2-poda] remove components/brave_rewards
b7df9917 [b2-poda] remove components/challenge_bypass_ristretto
e0bd2e23 [b2-poda] remove components/greaselion
d3328e3e [b2-poda] remove components/services/bat_ads
1ae32b82 [b2-poda] remove components/services/bat_rewards
f8cf6ded [b2-poda] remove components/skus
a535cfd4 [b2-poda] remove components/test/brave_rewards
33502d67 [b2-poda] remove test/data/brave_ads
467e0a65 [b2-poda] remove test/data/brave_rewards
133b3a6f [b2-poda] remove test/data/greaselion
da435898 [b2-poda] remove test/data/greaselion-data
c642bd62 [b2-poda] remove test/data/rewards-data
ae35ec30 [b2-poda] seams for browser/brave_adaptive_captcha
69609677 [b2-poda] seams for browser/brave_ads
485eccf7 [b2-poda] seams for browser/brave_referrals
2606b06a [b2-poda] seams for browser/brave_rewards
e8713262 [b2-poda] seams for browser/greaselion
ed792aaf [b2-poda] seams for browser/skus
9188ffda [b2-poda] seams for browser/ui/brave_rewards
32c81cb0 [b2-poda] seams for components/brave_adaptive_captcha
3673bc66 [b2-poda] seams for components/brave_ads
53c1d0dc [b2-poda] seams for components/brave_rewards
f2ae9eff [b2-poda] seams for components/greaselion
a994e283 [b2-poda] seams for components/services/bat_ads
243a23c5 [b2-poda] seams for components/skus
218876fc [b2-poda] seams for browser/brave_ads (tor)
```
- **Conflictos**: casi todos con borrados de los dos lados. Se resolvieron con una fusión de 3 vías por líneas y, en cada
  fichero, se comprobaron las cuentas por línea (base/ours/theirs/resultado). Ficheros:
  browser_context_keyed_service_factories.cc, browser/sources.gni, brave_browser_process{,_impl}.{h,cc},
  brave_content_browser_client.cc, brave_local_state_prefs.cc, brave_profile_prefs.cc, brave_tab_helpers.cc,
  view_counter_service_factory.cc, brave_profile_manager.cc, brave_new_tab_message_handler.cc, test/BUILD.gn, perf/*,
  browser/ui/BUILD.gn, brave_web_ui_controller_factory.cc, chromium_src/.../browser_prefs.cc, about_flags.cc,
  brave_prefs_util.cc, ntp_background(_images)/sources.gni, chromium_src/chrome/browser/DEPS, resources/resource_ids.spec,
  test/base/testing_brave_browser_process.{h,cc}, browser/BUILD.gn, .storybook/BUILD.gn, components/resources/*, components/webui/BUILD.gn,
  brave_browser_command_controller.cc, renderer/*, y los browsertests de toolbar y menú.
- Conflictos de modificado/borrado, resueltos borrando: browser/ui/webui/brave_rewards_page_ui.cc (nuestro) y skus_internals_ui.cc
  (nuestro); browser/ntp_background/ntp_p3a_helper_impl{,_unittest}.cc (los borró P3A, que se lleva también mi cambio de
  kPageLandAfter/IsRewardsDisabled); braveNews/customize/Configure.tsx (lo borró News).
- Errores de la fusión automática ya corregidos, cada uno metido en su commit con fixup y autosquash:
  - una llave `}` suelta en brave_browser_process_impl.cc;
  - un `return nullptr; }` suelto en testing_brave_browser_process.cc;
  - un `},` duplicado en resource_ids.spec;
  - líneas en blanco dobles en content_browser_client, local_state_prefs, new_tab_message_handler y
    ntp_background_images_service_unittest (esta última ya venía de mi primera pasada).
  Limpiado además un comentario huérfano (`# these are layering violation…`) en browser/BUILD.gn.
- Comprobaciones: `git diff --check` está limpio en los 39 commits y no queda ningún marcador de conflicto. El balance de
  llaves, corchetes, paréntesis y #if/#endif de todos los ficheros modificados coincide con el de nube/b2-poda.
  Ningún fichero vivo sigue usando skus::, brave_ads::, brave_rewards::, greaselion::, bat_ads::, BraveReferralsService ni
  las factorías de esos servicios. Las únicas excepciones son de Android (chrome_feature_list.cc de Android y
  ntp_background_images_bridge.cc). VPN y Leo ya habían quitado sus bloques con skus.
- **third_party/rust**: skus/v1, skus_cxx/v0_1 y challenge_bypass_ristretto_cxx/v1 solo tienen README.chromium, sin BUILD.gn.
  challenge_bypass_ristretto/v1/BUILD.gn solo apunta al crate de vendor/, que sigue existiendo, y ningún BUILD.gn ni .gni lo
  usa. Como GN no carga ninguno de ellos, no he cambiado nada. Lo que sigue pendiente es Cargo.toml y Cargo.lock de
  chromium_crates_io (rutas a components/skus y challenge_bypass_ristretto): solo rompe `gnrt`.
- **resid.sh tras el rebase**: en 0 para 16 de los 25 directorios. El resto suma 3+2+5+3+9+1+1+7 líneas, todas de Android
  (browser/android/**, build/android/config.gni, ntp_background_images_bridge.cc, brave_mobile_subscription/renderer/android/**,
  chromium_src/.../flags/android), de chromium_src/ios/** o de chromium_presubmit_config.json5. Las cifras de android/ e ios/
  no cambian. Ya no queda ninguna referencia dentro de los 70.
- Pendiente al integrar: components/brave_wallet_ui todavía importa ../brave_rewards/resources/shared/lib/external_wallet
  (5 ficheros). En nube/b2-poda brave_wallet_ui aún no se ha borrado; si no se borrara, el TS de wallet no compilaría.
