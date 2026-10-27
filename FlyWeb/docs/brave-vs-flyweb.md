# FlyWeb — Brave 1.57 → 1.69 frente a lo que arrastramos (INVESTIGACIÓN-MOTOR, 20-10-2026)

Estudio en papel (fila FM.34, caso 3). Sin código ni ramas. **Propone; decide Titín.** Responde a: *de nuestros cambios sobre
la 1.57, ¿cuáles cambió, absorbió o quitó Brave hasta la 1.69, para no rehacer lo que ya no hace falta?* Parte de las
medidas de `migracion-128.md` (FM.31/FM.32); aquí se miran **una a una las ediciones que Brave deja sin sitio**.

**Etiquetas:** **[V]** visto en el código (brave-core `v1.57.64`, `v1.69.168` y nuestra rama `flyweb`); **[I]** inferido;
**[H]** hipótesis. Las horas son **estimación mía** y entran en la clase C de FM.32 (no cambian el total).

## 1. Resumen

- **Qué hizo Brave con lo nuestro:** de los **257 ficheros de código** que tocamos (sin traducciones) [V]: **53** Brave no los
  toca, **71** se fusionan limpios, **16** son solo marca (se regeneran), **78** chocan poco (a mano), **5** chocan mucho y
  **34** los **movió o borró**. Chromium, no Brave, absorbió el grueso del motor (~1 040 de nuestros 1 372 parches de
  motor, FM.32).
- **Brave no absorbió nada nuestro** [V]: solo hay **4** parches con el mismo nombre (colisiones, §4; **corregido el 20-10: eran 3, falta `runtime_enabled_features.json5`**); no he visto ningún
  commit de Brave que haga lo que hace una edición nuestra.
- **Quitó** [V]: **IPFS de escritorio** (78 ficheros en `components/ipfs` → 10, y `ipfs_ui`, `browser/ipfs`), `adblock_rust_ffi` (movido a `brave_shields/adblock`) y
  `cdm` (sustituido por `widevine` [I]); `page_info` ya no existe como carpeta. **15 de nuestros 34 ficheros desaparecen con
  ello**: no hay que rehacerlos.
- **Lo peligroso son los que se mueven sin avisar** [V]: **cinco ficheros de constantes pasaron a cabeceras** (`inline
  constexpr`) y **tres ediciones funcionales** quedarían en el aire con una fusión por defecto: el esquema `flyweb://`, los
  *proxies* de Safe Browsing y el monedero siempre apagado. No fallaría nada al compilar. **Es la trampa principal** (§3).
- **Hay además una trampa ruidosa** (§5): tres argumentos de GN de `build.sh` dejan de existir en la 1.69 y `gn gen` falla.
- **Horas:** ≈ **8–15 h** para reubicar lo que Brave movió (dentro de la clase C de FM.32); se **ahorran ≈ 1–4 h** de
  lo que desaparece. **El total de FM.32 no cambia.**

## 2. Método y límites

- Clonados en lectura (parciales, sin binarios) `v1.57.64`, `v1.69.168` y nuestra `flyweb` (54b964da).
- **Ficheros nuestros** = diferencia entre `v1.57.64` y `flyweb`: 2 422 (1 050 modificados, 1 370 nuevos, 2 borrados) [V].
  De ellos, 733 son traducciones (se regeneran con `flyweb-rebrand-strings.py`) y 1 327 son parches de motor y seguridad.
- **Qué hizo Brave con cada fichero nuestro** = su estado entre `v1.57.64` y `v1.69.168` (modificado, borrado o movido), y
  para los modificados una fusión de tres vías (`git merge-file`), como en FM.32.
- **Límites.**
  - La detección de renombrados de `git diff` se saltó (30 740 ficheros): lo que sale «borrado» puede ser un movimiento.
    Los 34 se resolvieron **a mano** buscando el fichero en el árbol de la 1.69 (§3).
  - No he mirado los ficheros **nuevos** que Brave añadió en 1.58–1.69 con cadenas «Brave» o `brave://` (la lista se
    obtiene al correr el script de marca; `rebranding.md`).
  - No he compilado nada. El efecto de cada edición es el que dicen el código y su comentario.

## 3. Los 34 ficheros que Brave movió o borró

Cada uno con su destino, su efecto y el trabajo que queda [V, salvo lo marcado]:

### 3.1 Constantes que pasan a cabeceras (5): **funcional y silencioso**

En la 1.57, `components/constants/*.cc` y dos de `chromium_src` definían las constantes. **En la 1.69 son `inline constexpr`
en la cabecera `.h`** y el `.cc` ya no existe. Nuestra edición está en el `.cc`:

| Fichero (1.57) | Lo que cambiamos | Nuevo sitio (1.69) |
|---|---|---|
| `components/constants/url_constants.cc` | `kBraveUIScheme = "flyweb"`, URL de ayuda de P3A y de importación | `components/constants/url_constants.h` |
| `chromium_src/content/public/common/url_constants.cc` | `kBraveUIScheme = "flyweb"` | `chromium_src/content/public/common/url_constants.h` |
| `components/constants/webui_url_constants.cc` | `flyweb://wallet/...`, `flyweb://settings/...` | `components/constants/webui_url_constants.h` |
| `chromium_src/chrome/common/url_constants.cc` | Todas las ayudas de `support.brave.com` → `flyweb.lamosquita.net/ayuda/` | `chromium_src/chrome/common/url_constants.h` |
| **`components/constants/network_constants.cc`** | **`kBraveSafeBrowsing2Proxy`, `kBraveSafeBrowsingSslProxy`, … → `proxy.flyweb.lamosquita.net`** (nada pasa por Brave) | `components/constants/network_constants.h` (siguen en `*.brave.com`) |

**Riesgo:** si una fusión por defecto da por borrado el `.cc`, la 1.69 sale **con `brave://` y con Safe Browsing por los
*proxies* de Brave**. Lo segundo es una **regresión de privacidad (regla 20) que no se nota al compilar.** Trabajo: reaplicar
las cinco ediciones en las cabeceras, **1,5–3 h**, y comprobar con `scripts/network-audit.py` (el método de FM.31).

### 3.2 Movidos, con la misma edición en el sitio nuevo (10): hay que reubicar

| Fichero (1.57) | Nuevo sitio (1.69) | Edición nuestra |
|---|---|---|
| `components/brave_wallet/common/common_util.cc` | `common_utils.cc` (renombrado) | **`IsAllowed()` devuelve `false`**: monedero siempre apagado, sin `window.ethereum`/`window.solana` |
| `components/sidebar/sidebar_service.cc` | `components/sidebar/browser/` | Quita Brave Talk de la barra lateral (Brave Talk sigue en la 1.69) |
| `chromium_src/chrome/browser/ui/toolbar/recent_tabs_sub_menu_model.cc` | `chromium_src/chrome/browser/ui/tabs/` | `kBraveSyncedTabsUrl = "flyweb://history/syncedTabs"` |
| `chromium_src/chrome/browser/ui/webui/about_ui.cc` | `.../ui/webui/about/about_ui.cc` | Lista de páginas internas `flyweb://` |
| `chromium_src/.../web_app_shortcut_mac.mm` | `.../os_integration/mac/apps_folder_support.mm` | Carpetas «FlyWeb Apps.localized» |
| `browser/ui/tabs/BUILD.gn` | **Desaparece**: las dependencias van a `browser/ui/BUILD.gn` | `buildflags` de Playlist y Speedreader |
| `components/brave_shields/browser/ad_block_*` (4 ficheros) | `core/browser/` y `content/browser/` | ID y claves de componentes (caso 1: `brave-sync-shields.md`) |

**Riesgo del monedero:** un fallo aquí **activaría el monedero** (superficie de ataque y cadenas «Brave Wallet»). Prueba
mínima: `window.ethereum` y `window.solana` indefinidos en una página cualquiera. Además, la 1.69 añade Bitcoin y Zcash
(`IsBitcoinEnabled`, `IsZCashEnabled`) [V]: comprobar que se apagan con `IsAllowed`. **Trabajo:** 2–5 h (más el caso 1).

### 3.3 Movidos, solo marca (4): se regeneran

`brave_ads/.../reminder_util.cc` (una URL de ayuda), `notification_ad_constants.h`, `ads_client.h` y
`debounce_navigation_throttle.cc` (comentarios con `brave://`). **El script de marca los rehace**; ≤ 1 h con su `--check`.

### 3.4 Desaparecen (15): **no hay que rehacerlos**

- **IPFS (4):** `ipfs_ui.h`, `ipfs_constants.cc`, `ipfs_network_utils.cc`, `ipfs_ui/.../app.tsx`. Brave quitó IPFS de
  escritorio: de 78 ficheros en `components/ipfs` quedan 10 (limpiador de componentes y preferencias). **Ganamos menos
  superficie y menos cadenas.**
- **Monedero (5):** cuatro paneles de la interfaz (`wallet-settings-menu`, `panel-bottom-nav`, `assets-panel`,
  `connected-panel`) y `brave_wallet_pin_service.cc`. Solo cambiábamos texto; el monedero va apagado.
- **Speedreader (2)** (enlaces a `brave://settings`), **Recompensas móvil (1)** y **estadísticas (1)**
  (`brave_stats_tab_helper.cc`: comprobación del esquema; las estadísticas ya van con URL inerte).
- **Dos parches de Brave que habíamos tocado** (`canvas_rendering_context_2d`, `scheduled_action`): Brave los borró;
  nuestros cambios eran adaptaciones a los niveles de motor, que **la 128 ya trae**.

## 4. Parches propios

[V] Colisiones: **cuatro** Chromium-ficheros que **Brave y nosotros parcheamos** con el mismo nombre en `patches/` (Brave los añadió
en 1.58–1.69): `content-app_shim_remote_cocoa-render_widget_host_view_cocoa.mm`,
`...blink-renderer-core-editing-commands-clipboard_commands.cc`, `...blink-renderer-core-frame-local_dom_window.cc` y
**`...blink-renderer-platform-runtime_enabled_features.json5`**. **Corrección del 20-10 (FM.35, parte 3):** en la primera versión
de este documento la cuarta se me escapó, y es **la más importante**: es el fichero donde se encienden las *flags* de todos los
niveles (nuestro parche lleva 107 *hunks*, ≈ 1 745 líneas; el de Brave, 4 hunks en la 1.69 y 5 en la 1.73). Hay que **fundirlos en
uno** (2–4 h en total; la cuarta, 1–2 h por sí sola); `git` los da como «añadido en ambos». Detalle en `brave-vs-parches-motor.md`.

- **Parches de motor y seguridad (1 327)**, ya medidos en FM.32: ~1 040 vienen de serie en la 128, ~320 se vuelven a cortar,
  14 de V8 siguen (el `v8-revision` independiente).
- **Los 25 parches de Brave que editamos nosotros** [V]: 2 desaparecen, 17 chocan poco, 4 chocan moderadamente y 2 mucho.
  **La mayoría de esas ediciones eran adaptaciones al motor** y se pierden con la base nueva [I].

## 5. Tres argumentos de `build.sh` que dejan de existir (ruidoso)

[V] `gn gen` rechaza un argumento pasado que ninguna `declare_args` declara (lo vimos con el de Safe Browsing en la 1.57):

| Argumento de `build.sh` | En la 1.69 | Qué hacer |
|---|---|---|
| `brave_ai_chat_endpoint` | **Ya no existe** (solo `enable_ai_chat`) | Quitarlo; seguir con `enable_ai_chat:false` |
| `brave_zero_ex_api_key` | **Ya no existe** en la configuración del monedero | Quitarlo |
| `enable_updater` | Es un argumento de Chromium; Brave añade **`brave_enable_updater`** (por defecto `false`) en `updater/config.gni` y lo pone él a `true` solo si se activa | Usar `brave_enable_updater` (`false`) y **no** pasar `enable_updater` |

[I] Los otros 34 argumentos aparecen en la 1.69 (la comprobación completa de los `.gn` se cortó por tiempo; lo de arriba
sí está leído en `config.gni`). **0,5 h.**

## 6. Qué cambió Brave que **no** tocamos y hay que decidir

[V, de los directorios] Brave 1.58–1.69 **añade** `ai_rewriter`, `brave_player`, `psst`, `script_injector`,
`brave_service_keys`, `brave_mobile_subscription`, `brave_geolocation_permission`, `challenge_bypass_ristretto`, `webcompat`,
`widevine`, y en `browser/`: `ai_chat`, `hub`, `onboarding`, `day_zero_browser_ui_expt`, `tab_group`, `tab_ui`,
`storage_access_api`. La lista de servicios de FM.31 sigue en pie; aquí solo se añade que **`widevine` sustituye a `cdm`**
y que `network_constants.h` trae constantes nuevas de Widevine (`kWidevineGvt1Prefix`, `kWidevineGoogleDlPrefix`) que
conviene mirar junto a la decisión sobre los componentes de Google.

## 7. Qué ganamos y qué hay que vigilar

| | Cuánto | Dónde |
|---|---|---|
| **Se ahorra** | ≈ 1–4 h: 15 ficheros que desaparecen y 2 parches obsoletos | §3.4, §4 |
| **Hay que reubicar** | ≈ 8–15 h: 5 constantes (1,5–3 h), ≈ 10 ediciones movidas (2–5 h), 4 colisiones de parches (2–4 h), 3 argumentos (0,5 h), marca (≤ 1 h) y la comprobación de §7 (1 h) | §3.1–§3.3, §4, §5 |
| **Vigilar, silenciosos** | 6 (las 5 constantes, que incluyen `flyweb://` y los *proxies*, y el monedero) | §3.1, §3.2 |

### Comprobación propuesta (para LOCAL, tras fusionar)

Una pequeña lista de aserciones que **falle en voz alta** si una edición funcional ha vuelto al valor de Brave. Mínimo:

1. `kBraveUIScheme` vale `"flyweb"` en las dos cabeceras.
2. Los *proxies* de Safe Browsing de `network_constants.h` no apuntan a `*.brave.com`.
3. `IsAllowed()` devuelve `false`; `window.ethereum` y `window.solana` no existen.
4. Los ID de componentes de Shields son los nuestros (caso 1).
5. Las ayudas no llevan `support.brave.com` (`url_constants.h`).
6. `gn gen` pasa sin los tres argumentos retirados.

[H] Es una hora de trabajo si se hace como script de `scripts/` (código: lo hace otro agente; yo solo lo propongo).

## 8. Qué no pude comprobar

- **Los ficheros nuevos de Brave con «Brave» o `brave://`** (el script de marca los encuentra, no yo).
- **Si Brave 1.69 mantiene otros puntos de Safe Browsing o de red que ya no pasen por `network_constants.h`.** Conviene correr
  `network-audit.py` sobre la primera compilación (ya previsto en FM.31).
- **Los 34 argumentos de GN restantes** (lectura completa de los `.gn`; se cortó por tiempo).
- **Que las ediciones de motor «se pierden con la base nueva»** [I]: no he leído una a una las nueve (`chromium_src/v8`,
  Blink); FM.32 midió los parches, no estas.
- **Horas = estimación mía.**

## 9. Fuentes

- brave-core `v1.57.64`, `v1.69.168`, `flyweb` (54b964da): `components/constants/*`, `chromium_src/{content/public/common,
  chrome/common}/url_constants.*`, `components/brave_wallet/common/common_util*.cc`, `components/sidebar/`, `updater/config.gni`,
  `components/ai_chat/core/common/buildflags/buildflags.gni`, `components/brave_wallet/common/config.gni`,
  listados de `components/` y `browser/` de las dos versiones.
- Proyecto: `migracion-128.md` (FM.31/FM.32), `brave-sync-shields.md` (caso 1), `legacy-evolucion.md` (caso 2),
  `rebranding.md`, `scripts/build.sh`, `scripts/network-audit.py`.
