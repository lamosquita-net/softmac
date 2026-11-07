# MOTOR-41 (07-11-2026, ~10:40 UTC): estado

MOTOR-41 (`session_01MwmK2hUzGWKU8HxCSRGfc2`, Opus 5.5, modo auto; brave-core con push, aprobado por Titín en la sesión).
Coordina **COORDINACIÓN-33** (`session_01MwmK2kDoYYca7UqZKpt6gH`). MOTOR-40 archivada.

**Punta `nube/b2-porte-t11` = `nube/b2-mac` = c7e39138ca** (comprobada con ls-remote). La base es f3f65b603, la primera build
Mac en verde de LOCAL-19 (PGO, 0 FAILED, arranca). Encima:
- 2f357ccc: tag de chrome = 156.0.8078.90 en package.json. Llega a BRAVE_CHROMIUM_VERSION, que es lo que salía como Chrome/128 en /json/version.
- 57c54579: External Extensions propias en `/Library/Application Support/LaMosquita/FlyWeb/External Extensions`.
  Las contesta el proveedor de rutas de Brave en chromium_src/chrome/common/chrome_paths.cc. La 2.x y 1.98 leían la de Google.
  Se mantienen las dos guardas de upstream: ENSURE_PATH_CONTROLLED_BY_ADMIN y prompt_for_external_extensions.
- 5a93b80b9: DNS seguro apagado otra vez. En la 156 el valor por defecto pasó a default_dns_over_https_config_source.cc,
  así que el override de stub_resolver_config_reader.cc se había quedado muerto y la 3.0.0 hacía DoH automático a Cloudflare/Google.
- 6af35191f + b857fad7a: B5, Protected Audience y el resto de lo que 1.98 apaga en Blink (17 features, lista de su plaster).
  Ver «Clase 2». FledgeBiddingAndAuctionServerAPI se apaga aparte con EnableFeatureFromString, porque no tiene base::Feature.
- cd4cd2a2b: Sparkle solo como bundle_dep del framework, como en 1.98. Antes había una copia en cada helper.
- 7939b9298: fuera allow_runtime_configurable_key_storage, que en la 156 no existe.
- 1e490a6b1: BraveBrowserMainPartsMac otra vez, ahora en chromium_src/chrome/browser/chrome_browser_main.cc. Sin ella no se
  registraba Sparkle ni se hacía la copia del perfil. BLOQUEANTE de la 3.0.0 (SEGURIDAD-PORTES-18).
- 81a466871: supported_types, con IsDecoderSupportedVideoType / IsDefaultDecoderSupportedVideoType de la 156
  (filtro VP9/AV1 → H.264 por VideoToolbox).
- 87aad81ae: radio 8 de los botones de sugerencia, sobre kToolbarCornerRadius.
- 4caf5330e: fuera tres overrides muertos (show_params CHECK_IS_TEST, keystone .h, PermissionContextBase).
- c7e39138c: copia del perfil «<perfil> antes de 3.0 (fecha)» con su propia marca, «FlyWeb 3 Profile».
  BackUpProfileBeforeFirstStartOf(marca, versión) sustituye a la función de la 2.0.

**Tres clases de rotura que no ven ni el compilador ni el P2:**
1. **Override muerto**: un `#define X` en chromium_src cuyo X ya no está en el original de la 156. Lo detecta
   `FlyWeb/tools/brave-inventario/check-overrides-156.sh` (#833, #835), que lleva además guardas fijas para
   ModeToString del DoH y para el json5. Hoy en Mac sale limpio; lo que queda es de Win, Android e iOS (para la poda).
2. **json5**: en la 156, `base_feature_status: "disabled"` no apaga una feature de Blink «stable». El generador
   (runtime_enabled_features.cc.tmpl, UpdateStatusFromBaseFeatures) solo copia el estado si el base::Feature cuenta como
   overridden. 1.98 lo marca con plaster; nosotros, con OVERRIDE_FEATURE_DEFAULT_STATES en
   chromium_src/third_party/blink/common/features.cc, que nuestro chromium_src/base/feature_list.cc trata como overridden.
   La guarda está en check-overrides-156.sh.
3. **.o viejo** (pendiente de confirmar por LOCAL): si se añade un override .cc nuevo cuando el .o del original ya
   existe, ninja no recompila y la build sale en verde con el código de Chromium. Esa es la explicación probable de que
   supported_types, que no podía compilar, diera verde. `check-overrides-o.py <out> <src/brave>` (en la 7,1) lo detecta
   con `ninja -t deps`. COORDINACIÓN ha pedido a LOCAL-19 una build LIMPIA y que pase esa herramienta sobre el out viejo.

**Actualización (07-11 ~11:05 UTC).**
- `check-overrides-o.py` es la versión en Python de LOCAL-19 y sustituye al .sh, que solo veía 26 de 552 originales:
  redirect_cc deja el original en deps como «../../../src/<ruta>». Lo validó LOCAL en la 7,1, con brave-core en c7e39138ca
  y el out de f3f65b603: 688 overrides, 551 con el original compilado y 1 SIN_COMPILAR, el override nuevo del DoH.
  La clase 3 existe, pero **no** explicaba supported_types: su override sí estaba en deps.
- **Clase 4: override que compila y que LTO elimina sin dar error.** supported_types en f3f65b603 compilaba porque
  nuestro propio .h, expandido con la macro todavía activa, declaraba los *_ChromiumImpl. Nadie los definía, y nadie llamaba
  a los envoltorios con los nombres de la 128, así que ThinLTO los eliminó y desaparecieron también las referencias.
  Verde, y sin filtro VP9/AV1. Prueba en el binario: `strings` de FlyWeb Framework | grep FlyWebSoftwareVp9Av1, que
  debe dar 0 en f3f65 y ≥1 desde 81a466871; el recuento lo tiene pedido LOCAL. Esta clase la descubren los avisos MUERTO
  de check-overrides-156.sh sobre nombres que ya no existen en la 156: **no se ignoran nunca**.
- **Trampa conocida (aceptada, igual que en la 2.x):** en la unidad de compilación de supported_types.cc, la macro renombra
  también el método virtual MediaClient::IsDecoderSupportedVideoType, que en la 156 se llama igual que la función libre.
  Funciona porque va por la misma entrada de la vtable. Se deja así.

**Decidido por COORDINACIÓN-33:** si `HTMLScriptElement.supports('speculationrules')` sale true (por el prefetch) o
HTMLPermissionElement sale definido (por GeolocationElement), se deja como en 1.98.

**Abierto:**
- Errores y resultados de LOCAL-19 sobre c7e39138ca. Lista de pruebas en la Mac: Sparkle (registro solo, SUPublicEDKey
  que rechaza paquetes sin firmar, una sola copia en el framework y que registerWithSparkle la encuentre), copia del perfil
  antes de 3.0, H.264 en media-internals, píldoras del omnibox, B5 por CDP, DoH apagado, External Extensions y Chrome/156.
- Siguen sin juntar: `nube/b2-privacidad` (cuando arranque la build de f3f65b603 o una posterior, por orden de COORDINACIÓN)
  y `nube/b2-redirect-cc` (tanda de envoltorios .cc).
- Para la poda, sin prisa: la carpeta interna del framework es `Versions/156.1.98.63` (chrome_version_full de Brave:
  major de Chromium + versión de Brave; en la 2.7.0 era el mismo esquema, 128.1.69.168). No la ve el usuario ni Sparkle.
  El Info.plist principal está bien: CFBundleShortVersionString = flyweb_version (3.0.0) y CFBundleVersion =
  198.63.FLYWEB_BUILD_NUMBER (tweak_info_plist.py), mayor que el 169.168.N de la 2.x.
- Lo de MOTOR-40 que sigue abierto: tanda de IPFS y Tor, logo en chrome_logo_dark.svg, Sparkle en build.sh 3.0.0.

# MOTOR-40 → MOTOR-41 (07-11-2026, ~06:15 UTC)

MOTOR-40 (`session_01MwmK2mJrB3myzidqeC1BfM`, Opus 5.5), relevo al 36 % de contexto. Coordina **COORDINACIÓN-32**
(`session_01MwmK2iTqaffXip3r8YT1NG`).

**Actualización (07-11 ~08:10 UTC): punta 799d3ad01** (`nube/b2-porte-t11` = `nube/b2-mac`, comprobada con
ls-remote). Encima de eaefe8115 lleva estos arreglos de build:
- 552d66e27: 6 errores de Mac, como 1.98 (menú Ayuda, Dock, importador, IDC_CLOSE_TAB, PPAPI, FullDiskAccess). Además
  quita del menú Google Lens, AI Mode y Search Shortcuts.
- 0f71c8b4e: los imports copiados en los overrides de WebUI conservan sus `<if>`. `internal/` solo existe en Google
  Chrome.
- 32b30ea73: la subclase del menú contextual se llama RenderViewContextMenu, como 1.98, sin el #define final.
- 799d3ad01: preprocess_if_expr declara un depfile con los overrides de chromium_src que usa, para que ninja recompile
  al cambiarlos. 1.98 lo resuelve con siso. Limitación: un override **nuevo** no lo detecta hasta la siguiente
  regeneración del paso o una build limpia.

Regla de COORDINACIÓN-32: dar el hash solo después de comprobarlo con `git ls-remote`.

**Ramas en brave-core:**
- `nube/b2-porte-t11` = `nube/b2-mac` = **eaefe8115**. Es la punta que compila LOCAL-19, con estos commits encima de
  f5133ee5b:
  - 9e70783ee: parche de settings sin `icons_html_files`;
  - 995b975ac: ninja (`use_siso=false`) y fuera `require('ip')`;
  - 86af47bfc: Release = compilación de publicación, con PGO oficial;
  - 33f16a464: fuera los 9 parches de FM.42 b2/d8, que ahora están en flynk-b1d 58cec3d923;
  - 9611d4638: redirect_cc con objetivo macOS 10.14;
  - a3200aee9: native_theme, resolve_host_request (span) y notimplemented;
  - f9b25e5dc: `-iquote` también en asmflags, para los `.S` de boringssl;
  - eaefe8115: lint de WebUI arreglado, con la regla de imports activa. 1.98 la apaga.
- `nube/b2-redirect-cc` = 58be92043, **sin juntar**: fuera redirect_cc y siso de 1.98. Entra en la tanda de
  envoltorios .cc, después de la primera build Mac y con su propio P2.
- `nube/b2-privacidad` = **df54efacc** sobre eaefe8115, **sin juntar** (orden de COORDINACIÓN-32):
  - fa5a3cc1b: window.name entre orígenes en marcos provisionales, como 1.98.
  - bd9214694 y 713bc10d3: modelo de esquema de 1.98. Restaura sesiones con flyweb:// o brave:// antiguos (borra su
    PageState). Título por defecto flyweb://. Orígenes chrome:// mostrados como flyweb:// (antes salía «brave»).
  - df54efacc: farbling WebGL equilibrado de 1.98, desactivado por defecto: flag
    `brave-webgl-balanced-fingerprinting-protections` (feature `kWebGLBalancedFingerprintingProtection`). Cambio
    propio: vendor/renderer responden «WebKit», no «Brave».
  - Sin portar:
    - el panel React de Shields;
    - WebGPU: necesita un valor nuevo de ContentSettingsType **antes** de `BRAVE_WEBCOMPAT_WEB_SOCKETS_POOL`, lo que
      cambia el histograma;
    - los Containers;
    - `UpdateTargetURL` (burbuja de estado).
  - Unidades:
    - brave_unit_tests: `WebGLExtensionHandlerTest.*`, `BraveNavigationEntryTest.*`,
      `BraveContentSerializedNavigationDriverTest.*`;
    - brave_browser_tests: `BraveWindowNameBrowserTest*`, `BraveWebGLFarblingBrowserTest.*`,
      `BraveWebGLExtensionFarblingTest.*`.
  - En la Mac:
    - un perfil 2.x con pestañas flyweb:// y brave:// tiene que restaurarse;
    - window.name se mantiene en el mismo origen y se borra al cambiar de sitio;
    - claude.ai y Plotly funcionan con el flag WebGL activado.
- `nube/b2-mac-flynk` (4172a610f): obsoleta; la sustituye 33f16a464. Se puede borrar. A MOTOR-40 el modo automático le
  denegó el force-push.

**Abierto:**
- los errores de la build de LOCAL-19 sobre eaefe8115;
- juntar nube/b2-privacidad cuando COORDINACIÓN lo diga;
- después de la build Mac: la tanda de IPFS y Tor (`kIPFSCache`, `privateAndTorInfoWarning`) y la de envoltorios .cc;
- de marca: el logo de Brave en chrome_logo_dark.svg (rebranding.md §2.3);
- Sparkle en el build.sh de la 3.0.0 (abajo).

**Trampas:**
- Antes de dar una rama por buena, `FlyWeb/tools/brave-inventario/check-parches-156.sh` (el P2 no ve los parches que
  no aplican).
- «Login Data» en browser_prefs.
- En esta sesión no se puede hacer force-push ni `send_later` (profundidad de sesiones 8/8). Si hace falta deshacer,
  hay que hacerlo con commits encima.

# MOTOR-40: estado (07-11-2026, ~01:45 UTC)

MOTOR-40 (`session_01MwmK2mJrB3myzidqeC1BfM`, Opus 5.5). Coordina **COORDINACIÓN-32** (`session_01MwmK2iTqaffXip3r8YT1NG`).

**Tanda de parches que no aplican: cerrada.** Primero 37 commits lineales sobre accfb0c61, hasta ed1721260. Después
vinieron las 3 decisiones de abajo y el cherry-pick de los iconos. Punta: **f5133ee5b**, la misma en `nube/b2-parches`
y en `nube/b2-porte-t11` (push hecho).

**Recuento contra la 156:** quedan 514 parches y aplican **todos**; ninguno se queda sin fichero y ninguno falla.
Antes había 596: 436 aplicaban, 22 no tenían fichero y 138 fallaban. El recuento incluye `v8/` y `third_party/`.
Lo saca `FlyWeb/tools/brave-inventario/check-parches-156.sh`:
- se ejecuta desde un directorio de trabajo vacío, con xargs sobre la lista de `patches/*.patch`;
- descarga de gitiles los ficheros de la 156 y los subrepos en las revisiones del DEPS;
- usa los flags de Brave: `--ignore-space-change --ignore-whitespace`;
- también comprueba que todas las macros `BRAVE_*` que meten los parches estén definidas.

**Commits por zona:**
- privacidad y red: aada1a481, 51e6980a4
- no-Mac (53 fuera): 08643a397
- content: ae65eb2ac, 4b9cbd2d1, ccac706ae, a356c06b6 (Private State Tokens apagados como en 1.98)
- tools y firma de Mac: 615677c7e, 3f97b0274
- C++: 12 commits, hasta d5cabed89
- WebUI: 7 commits
- blink y v8: 9 commits, hasta ed1721260

**Trampas de la 156** (para TRAMPAS.md):
- **«Login Data».** Al migrar las prefs del perfil, la 156 borra los ficheros de contraseñas `Login Data*`. 1.98 lo
  anula con `#if 0` en `patches/chrome-browser-prefs-browser_prefs.cc.patch`, y nosotros también. Si ese parche deja
  de aplicar, el P2 sigue dando 0 rotos, pero el navegador pierde las contraseñas y además no registra las prefs de
  Brave. Hay que revisarlo en cada rebase.
- **El P2 no basta.** Un parche que no aplica no rompe la compilación: sus macros quedan sin usar. Pasa el script de
  arriba antes de dar una rama por buena.
- **1.98 usa `rewrite/*.yaml` (plaster) y `lit_mangler`**, y nosotros no tenemos ninguno de los dos. Su equivalente
  en nuestro árbol es un `.patch` o un override `.ts` de chromium_src. Los overrides `.ts` funcionan por
  `preprocess_if_expr`, que guarda el original como `-chromium.js`. Los overrides `.css` todavía no funcionan: falta
  `css_to_wrapper.py`.
- **Includes.** Al copiar un override de 1.98, el include del original va como `"src/<ruta>"`, no como `<ruta>`.

**Decisiones de COORDINACIÓN-32 (07-11 ~01:37), ya aplicadas:**
- 18d292b5f: fuera `maglev_untagged_phis=false` (regla 19). `maglev=false` se queda hasta la validación de la 3.0.0 (B6).
- 60031ef11: fuera el parche FM.31 de `gl_display_initializer`. **Metal por defecto también en Mojave** (B1d): el
  fichero de flynk-b1d es el de la 156 tal cual, y LOCAL-19 lo midió en la 6,1.
- 5a691a6d6: fuera el entitlement de VPN (`app-entitlements-brave.plist`).
- `kFlyWebCacheEpoch` sigue en version.cc. COORDINACIÓN lo consulta con ARQUITECTURA (alternativa: `v8_embedder_string`).
- Las 5 políticas de Shields por defecto de 1.98: después de la 3.0.0.
- IPFS (`kIPFSCache`) y Tor (`privateAndTorInfoWarning`): tanda aparte, después de la primera build Mac.

**Punta para P2 y para LOCAL-19: f5133ee5b.** Es `nube/b2-parches` y también `nube/b2-porte-t11`, que avanzó por
fast-forward desde accfb0c61. Encima lleva el cherry-pick de 3f5d9c293 (nube/b2-iconos). Medida de nuevo: 513 parches,
**todos aplican**.

**De 1.98, sin portar (fuera de la tanda):**
- borrar window.name al cambiar de origen;
- el farbling WebGL nuevo;
- `navigation_entry_impl` y la restauración de sesiones brave://;
- `css_to_wrapper.py`;
- history `app.html.ts`;
- la etiqueta «Brave hosted».

Qué se hace con cada uno (COORDINACIÓN-32):
- window.name, el farbling WebGL y la restauración de sesiones brave://: tanda después de la build Mac (regla 20).
- css_to_wrapper e history `app.html.ts`: solo si hacen falta.
- «Brave hosted»: no.

**Unidades para MOTOR-30:**
- components_unittests: content_settings*, ProtoConversions*, DownloadItemImpl*, ChromeMetadataSource*
- brave_unit_tests: BraveContentSettings*, brave_shields_util*, EphemeralStorage*, brave_font_whitelist
- network_service_unittests: CorsURLLoader*, ResolveHostRequest*
- net_unittests: HostCache*, HostResolverManager*
- blink_common_unittests: ClientHints*
- content_unittests: BrowsingDataFilterBuilderImpl*, NavigationController*, RenderFrameHostImpl*
- unit_tests: HistoryTabHelper*, PageInfo*, DownloadTargetDeterminer*, ExtensionInfoGenerator*,
  ChromeBrowsingDataRemoverDelegate*, DeveloperPrivateApi*
- ui_base_unittests: Accelerator*
- base_unittests: HistogramFunctions*
- crypto_unittests: AEAD*
- views_unittests: MenuSeparator*
- v8_unittests y cctest: test-version, test-serialize
- brave_browser_tests:
  - farbling: webaudio, webgl, enumeratedevices, font
  - BraveSchemeLoad*, BraveContentBrowserClient*, url_sanitizer, BraveWelcome*
  - brave_shields_web_contents_observer, flyweb_script_block_internal_pages
- browser_tests:
  - CrExtensions*, CrHistory*, CrDownloads*
  - ProfilePicker*, ProfileCustomization*, CrComponentsThemeColorPicker*
  - PDFExtension*, TrustToken* (deben quedar filtrados)
  - EnclaveAuthenticator*
- firma: `chrome/installer/mac/signing/run_mac_signing_tests.py`
- herramientas: json_schema_compiler_tests y licenses_test.py

**Lista para LOCAL** (además de la de MOTOR-39):
- arranca sin fallo de prefs;
- las contraseñas guardadas siguen ahí después del primer arranque en la 156;
- flyweb:// en la barra y en el título;
- la bienvenida con lottie;
- extensiones, historial, descargas, selector de perfil y personalización de perfil (Enter);
- color de tema gris por defecto;
- el visor de PDF;
- en Mojave, ANGLE con Metal (chrome://gpu);
- **captura de flyweb://settings** con los iconos Leo (nube/b2-iconos: brave_icons.html quitado, iconMap como 1.98);
- prefs: la app arranca y las contraseñas guardadas siguen ahí.

**Para el build.sh de la 3.0.0: Sparkle** (COORDINACIÓN-32, 07-11). `build/mac_files/sparkle_binaries` (`sign_update`,
`BinaryDelta`, Sparkle.framework) llega con gclient: no está en brave-core.
- Nuestro DEPS lo baja con el hook `download_sparkle` (`build/mac/download_sparkle.py 1.24.3`).
- 1.98 lo baja con `tools/cr/install_extra_deps.py sync src/build/mac_files/sparkle_binaries` (EXTRA_DEPS:
  `sparkle-1.24.4.tar.gz` desde `brave-build-deps-public.s3.brave.com`).

build.sh no hace gclient sync, así que tiene que bajarlo él una vez, antes de compilar. Desde `src/brave`:
`vpython3 build/mac/download_sparkle.py 1.24.3`.

Es una descarga de Brave en tiempo de compilación, no en el navegador. Si no se quiere depender de Brave, se puede
copiar desde la máquina que ya lo tiene. Hay que mirar si FlyWeb usa de verdad esos binarios: las actualizaciones se
firman en bak.

**nube/b2-mac 9611d4638** (sobre f5133ee5b), lo que se compila en la Mac:
- quitado `icons_html_files` del parche de settings;
- fuera `require('ip')`;
- `use_siso=false` hasta la tanda de envoltorios .cc (`nube/b2-redirect-cc` = 58be92043, sin juntar);
- Release = compilación de publicación, con PGO oficial: `chrome_pgo_phase` ya no se escribe en args_generated.gni;
- fuera los 9 parches de FM.42 b2/d8, que ahora están en flynk-b1d 58cec3d923;
- redirect_cc con objetivo macOS 10.14.

**Siguiente:** lo que salga de la build de LOCAL y de las unidades de MOTOR-30.

# MOTOR-39 → MOTOR-40: B2 T11 (07-11-2026, ~01:20 UTC)

MOTOR-39 (`session_01MwmK2goNHDRcfxEXELHuXM`, Opus 5.5). Coordina **COORDINACIÓN-32** (`session_01MwmK2iTqaffXip3r8YT1NG`;
la 31 está archivada). Relevo al 43 % de contexto.

**Ramas en brave-core:**
- `nube/b2-porte-t11` **accfb0c61**, lineal: P2 de 226e3ae0a con 0 rotos (1523 objetivos), más nube/b2-p3a, que es el
  borrado de P3A en la bienvenida y en Shields y el test de settings.
- `nube/b2-iconos` **3f5d9c293**, sin juntar (orden de COORDINACIÓN). Quita brave_icons.html e icons.ts y completa
  iconMap como 1.98. Pendiente: captura de settings en la build Mac.
- `nube/b2-parches` = accfb0c61, todavía **sin commits**. Es la tanda de abajo.
- LOCAL-19 compila **226e3ae0a** en la Mac (PGO, k:0). Sus errores van a quien siga.

**Tanda en curso: parches que no aplican** (COORDINACIÓN-32, 07-11 01:15; prioridad máxima, antes que los iconos).
- MOTOR-30 midió sobre 226e3ae0: aplican 427, 22 no tienen fichero objetivo y **127 NO aplican**. De esos 127, 83 no
  son de Android, iOS, Windows ni del instalador de Linux.
- El P2 da 0 porque el código compila sin ellos, pero lo que hacen no está en el binario. Hay de privacidad y de red:
  net/dns host_cache y host_resolver_manager_job, system_network_context_manager, cors_url_loader,
  resolve_host_request, content_settings default/policy_provider, client_hints, navigation_request,
  render_frame_host_impl, browser_prefs y la firma de Mac.
- MOTOR-30 manda la lista completa (`parches-no-aplican.txt`, con el primer error de git de cada uno). Pídesela a
  COORDINACIÓN-32 si no te llega.

Criterio, parche a parche, en commits por zona:
1. Si 1.98.63 lleva un parche equivalente, cópialo o rebásalo como en 1.98, sin lo que FlyWeb quitó.
2. Si 1.98 ya no lo lleva y lo sustituye otra cosa (chromium_src, override o nativo), haz lo mismo que 1.98.
3. Si 1.98 lo quitó sin más y no toca privacidad, bórralo.
4. Si toca privacidad o red y no está claro qué hacía, pregunta a COORDINACIÓN antes de borrarlo.

Además:
- Los 22 sin fichero objetivo: fuera, si 1.98 tampoco los lleva.
- Orden: privacidad y red; content/renderer; blink; generadores y lint; firma de Mac.
- Los 44 de Android, iOS, Windows e instalador de Linux: fuera, salvo que 1.98 los lleve para Mac.
- Comprobación: MOTOR-30 vuelve a contar los parches que aplican sobre la rama.

**Ayuda ya hecha:** `FlyWeb/tools/brave-inventario/datos/b2-parches-198.tsv` (sobre accfb0c61). Cada uno de nuestros
596 `patches/*.patch` va con:
- `198 SAME` (251): 1.98 lleva el mismo parche y el blob de origen coincide; debería aplicar sobre la 156;
- `198 DIFF` (239): 1.98 lo lleva con otro blob de origen. Lo normal es que el nuestro no aplique, y el de 1.98 es el
  donante;
- `no198` (106): 1.98 no lo lleva; hay que mirar la 156.

Crúzalo con la lista de MOTOR-30.

**Método que funcionó esta noche:**
- La 156 por gitiles: `curl -sS ".../chromium/src/+/refs/tags/156.0.8078.80/<ruta>?format=TEXT" | base64 -d`.
- Patches como 1.98: aplica el de 1.98 a una copia del fichero 156 en un repo git temporal, quita Wallet, AI chat, Tor,
  Rewards, Speedreader…, y saca el patch con `git diff --full-index`. Luego `git apply --check`.
- El tag v1.98.63 no está en el fork. Tráelo con
  `git fetch --depth 1 https://github.com/brave/brave-core refs/tags/v1.98.63:refs/tags/v1.98.63`.
- Subagentes por zona disjunta, cada uno en su worktree. Fusión con cherry-pick lineal.
- Patrón de rotura repetido en la 156: un `#define` de chromium_src que renombra algo que el original declara en una
  cabecera incluida después. Arreglo: incluir antes esa cabecera, como hace 1.98.

**Lista para LOCAL:** la de «MOTOR-39: estado», justo debajo, más la captura de los iconos de settings si se junta
nube/b2-iconos.

# MOTOR-39: estado (06-11-2026, ~21:35 UTC)

MOTOR-39 (`session_01MwmK2goNHDRcfxEXELHuXM`, Opus 5.5). Coordina **COORDINACIÓN-31** (`session_01MwmK2iP27sssYimPaJ7scp`).

**Punta:** `nube/b2-porte-t11` **3438f86f3**, lineal sobre 8accd5ec. Encargo de COORDINACIÓN-31 (06-11 21:00) cerrado.
Nada medido todavía: MOTOR-30 tiene encargados el P2 de 8accd5ec, una rápida con d7457458 y las unidades nuevas hasta
67910a5f.

**Commits, por bloque:**
1. 5dc69d55 **RequestType** como 1.98:
   - `kWidevine` y `kBraveGoogleSignInPermission` al final del enum, por un patch de `request_type.h`, con
     `kBraveMinValue` y `kBraveMaxValue`;
   - sus casos en los switch de `request_type.cc`, por patch;
   - fuera el override `.h`, los `_ChromiumImpl` y el `kStorageAccessIcon` muerto.
2. d7457458 **PermissionType**: las 4 piezas de 1.98 sin Speedreader, Wallet ni AI chat, con COSMETIC_FILTERING:
   - `[BraveExtend] PermissionName`;
   - `permission_descriptor_util.cc`;
   - el hook `PermissionDescriptorInfoToPermissionType`;
   - el `permission_utils.cc` del renderer;
   - además, `BRAVE_MIN_VALUE` y el override de `permission_overrides_unittest`.
   - REFERRERS→REFERRERS (1.98 lo manda a SHIELDS).
   - Cadena del sign-in revisada en código; falta probarla en ejecución.
3. 74c0bbaf **overrides 404 de privacidad**:
   - **User-Agent:** la versión salía de un override de `version_info.h` que estaba muerto y además chocaba con la
     declaración de 156. Ahora va en `version_info_with_user_agent.cc` (override y patch de 1.98);
   - `BuildModelInfo` pasa a `user_agent_utils`;
   - `sb_protocol_config.cc` sigue con la versión del nivel declarado;
   - `google_api_keys.cc` y `api_key_cache.h`;
   - `net/base/is_potentially_trustworthy`;
   - blink `core/geolocation`;
   - **GCM** de 1.98: el nuestro dejaba `enabled_` sin inicializar;
   - borrados `fcm_network_handler`, `tpcd` y `safety_check_handler`.
4. c1d9d8ae `ChromeURLHosts()` por patch (adblock, adblock-internals, welcome); fuera `autocomplete_provider`.
5. ab0be296 `data_decoder`: muerto, porque 156 no tiene `DataDecoder::ParseJson`. No rompe listas de filtros ni
   componentes (`JSON.stringify`).
6. Tanda de macros muertas y 404, con 3 subagentes:
   - 53fe078b **UI**: `bubble_frame_view` por patch; `omnibox_result_view`; searchbox a `cr_components/searchbox`;
     `webui_util` a `ui/webui`, con la CSP.
   - 1683bd41 y f7a0b251 **components**:
     - `ranker_url_fetcher` en translate: no baja el modelo;
     - `manifest_url_handlers`: Web Store vacía para todas;
     - `scoped_chrome_extensions_client`;
     - fuera Attribution Reporting `aggregatable_*`.
   - a69a5698 y 307f566c **browser**:
     - tab_helpers;
     - fuera EnsureUpdater (Sparkle sigue);
     - DefaultBrowserWorker;
     - `chrome_browsing_data_remover_delegate`;
     - `permissions_ai_ui_selector`;
     - `crashes_ui` y `version_handler_helper` con la versión de FlyWeb;
     - **servicio de predicción de permisos de Google apagado**, de 1.98.
7. Decisiones de COORDINACIÓN-31:
   - de80e241: sin `source=newtab` (el browsertest comprueba que no va);
   - 3b84fb48: fuera los overrides solo de Windows;
   - 050d5b0c: sin `source=` en la búsqueda y las sugerencias de Brave Search (`kBraveCurrentDataVersion` 30);
   - 67910a5f: fuera `brave_search_tor`.

**Abierto:**
- ~~`kQuietNotificationPrompts`~~: resuelto (21:27); el espejo sirve Crowd Deny (`ggkkehgbnfjpeggfpleeakpidbkibbmn`), se
  queda como está.
- ~~Códigos de socio~~: 3438f86f, versión de datos 31. Fuera los códigos de socio de Brave en Ecosia (`tt=`,
  `addon=brave`), Qwant (`client=brz-brave`), Startpage (`segment=startpage.brave`) y Yandex (`clid=`,
  `srv=brave_desktop`).
- Menores: poda del código Windows de `brave/` que no es override.
- URL de actualización de extensiones: no se toca (paso 35).

**Lista para LOCAL en la primera build Mac** (además de §12.16.2/3: caBLE, GPC, iconos Leo, portapapeles en Mojave):
- User-Agent `Chrome/156.x`, nunca la versión del producto, y los client hints coherentes;
- GCM apagado, sin conexiones a mtalk.google.com;
- sin peticiones al servicio de predicción de permisos de Google ni al modelo de ranker de translate;
- Safe Browsing solo hacia proxy.flyweb.lamosquita.net;
- claves de API de Google vacías;
- permiso Google sign-in **funcionando en ejecución**: aviso en accounts.google.com desde un tercero y ajuste en
  brave://settings;
- adblock, adblock-internals y welcome accesibles;
- en un perfil existente, búsquedas (barra y NTP) y sugerencias de Brave Search sin `source`;
- en un perfil existente, buscar y ver sugerencias con Ecosia, Qwant, Startpage y Yandex, todos sin código de socio y
  funcionando. Desde la nube no se pudo probar: el proxy los bloquea. Las sugerencias de Yandex van sin `srv`.
- flyweb://version y flyweb://crashes con la versión de FlyWeb.

**Siguiente:** 7, lo que salga del P2 y de chrome entero en la Ubuntu (MOTOR-30).

# MOTOR-38 → MOTOR-39: B2 T11 (06-11-2026, ~21:05 UTC)

MOTOR-38 (`session_01MwmK2gzv4SrPPzHLtAispT`, Opus 5.5). Coordina **COORDINACIÓN-31** (`session_01MwmK2iP27sssYimPaJ7scp`).
Relevo al ~49 % de contexto: me pasé del umbral. Vigila `get_session` antes de abrir tandas.

**Qué leer:** esta sección y `brave-propio.md` §12.16.3, con la tanda de seguridad, las decisiones de COORDINACIÓN-31, el
riesgo Mojave del portapapeles y lo que se pierde en la 3.0.0.

**Punta:** `nube/b2-porte-t11` **8accd5ecd3**, lineal.

**Estado de lo medido:**
- **P2 completo de 30f94067** (1510 objetivos, incluidos 68 de `gen/`): 12 rotos. Todos arreglados después, salvo lo que
  confirme el siguiente P2.
- **Rápida de 900944be:** 0 rotos.
- **Rápida de 39c40272:** `command_utils` compila.
- **Arreglos subidos después, aún sin medir:**
  - fc4bed2f: fuera el override `NotificationHandler::Type`, que rompía `chrome/browser/default_browser`;
  - 997e25e3: `.gn` + `build/circular_includes_brave.gni` con `//chrome/browser:core`, para el «allow_circular_includes_from
    is not allowed here» de `gn gen`;
  - 71fb2416: `gn check`, visibilidad y deps de `browser_process` para tests;
  - 8accd5ec: los 4 `!!` del lint de settings.
- **En la Ubuntu:** MOTOR-30 tiene encargados el P2 de 8accd5ec y luego **chrome entero**. El P2 solo cuenta objetivos de
  Brave, y nuestros overrides rompen ficheros de Chromium que no ve.

**Hecho por MOTOR-38** (detalle en §12.16.3):
- arreglos del P2 de b1a25a49 y GPC como 1.98;
- tanda T-tests completa (314 ficheros, 5 zonas) y los 13 tests de la rápida;
- tanda «seguridad desde 1.98» (11 bloques);
- borrados aprobados: SIN-1.98, OFAC, `brave_mobile_subscription` y `kdf`;
- settings: `build_ts` (stub de leo) y los 111 errores de `lint_ts` arreglados a mano, sin apagar reglas;
- `command_utils` (generador de 1.98 sin pestañas verticales);
- `FakeLocalFrame`;
- `gn check`, partes A y B.

**Siguiente, en orden (visto bueno de COORDINACIÓN-31, 21:00; commits separados por bloque):**
1. **RequestType** (punto 2 de la auditoría de abajo): hunks en `patches/components-permissions-request_type.cc.patch`
   como 1.98, y fuera el `#define kStorageAccessIcon` muerto.
2. **PermissionType** (punto 1): las 4 piezas de 1.98 sin Speedreader, Wallet ni AI chat, más el case de
   COSMETIC_FILTERING y `BRAVE_MIN_VALUE`. **Es el intocable (Google sign-in): tiene que funcionar en ejecución.**
3. **Overrides 404 que tocan privacidad o servidores**, por delante de lo demás:
   - la lista: `v4_protocol_manager_util` (Safe Browsing por `proxy.flyweb.lamosquita.net`), `google_api_keys-inc.cc`,
     `content/common/user_agent.cc` (versión declarada y huella), `fcm_network_handler`, `geolocation.cc`,
     `is_potentially_trustworthy.cc`, `redirect_heuristic_tab_helper` y `safety_check_handler`;
   - por cada uno: a qué fichero se movió en la 156, qué hacía nuestro override y si 1.98 lo mantiene;
   - si no hay sitio claro, se pregunta a COORDINACIÓN antes de inventar.
4. `webui_url_constants`: adblock, adblock-internals y welcome en `ChromeURLHosts()`, con un patch como 1.98. Después,
   borrar `autocomplete_provider.{h,cc}`.
5. `data_decoder` `JSON_PARSE_RFC`: comprobar si perder `ALLOW_TRAILING_COMMAS` rompe la lectura de listas de filtros o de
   componentes de components.flyweb. Si la rompe, sube al 3.
6. Resto de macros muertas y 404, en una tanda con subagentes.
7. Luego: lo que salga del P2 y de chrome entero; features de nivel solo si salen rotas; menores (P3A en producción,
   `brave_icons.html` muerto); envoltorios `.cc`; `brave_services_key_id`.

**Comprobaciones en ejecución para LOCAL** (COORDINACIÓN las pasa con la primera build Mac; ya están en §12.16.2/3):
- caBLE;
- GPC en globalprivacycontrol.org;
- iconos Leo y spinners en Shields/filtros, Sync y buscadores (settings);
- el permiso Google sign-in;
- copiar en una ventana privada en Mojave (`_setExpirationDate:`).

**Método que funcionó:**
- **Brief común:** el de MOTOR-37, que repito aquí porque /tmp no sobrevive. Donante con `git show v1.98.63:`, la lista
  con `git ls-tree -r --name-only v1.98.63` y la 156 por gitiles con `?format=TEXT | base64 -d`. Criterios: de 1.98
  adaptado, conservando quitas e intocables; lo nativo primero; no inventar; parches con `git apply --check`.
  Commits con Co-Authored-By y Claude-Session.
- **Subagentes:** uno por zona disjunta, cada uno en su worktree; fusión con cherry-pick lineal.
- **Clasificar sin bajar blobs:** por blob con `git ls-tree` frente a `v1.98.63` y la raíz 1.57.
- **Nunca `push -f`:** el clasificador lo deniega, con razón. Si hace falta corregir, se hace un commit nuevo.

**Pendiente de producto:** `kThirdPartyAiChatSettings` («IA de terceros» de la 156), para Titín con la primera build.

## Auditoría de overrides que redefinen enums o listas (MOTOR-38, sobre fc4bed2f)

ROTO SEGURO:
1. blink::PermissionType: permission_utils.h añade 9 BRAVE_* (ADS, COSMETIC_FILTERING, TRACKERS, HTTP_UPGRADABLE_RESOURCES, FINGERPRINTING_V2, SHIELDS, REFERRERS, COOKIES, GOOGLE_SIGN_IN). El switch exhaustivo de content/browser/permissions/permission_descriptor_util.cc (CreatePermissionDescriptorForPermissionType) no los cubre → -Wswitch. En EJECUCIÓN, google_sign_in_permission_util.cc:118,142 llama con BRAVE_GOOGLE_SIGN_IN. 1.98 tiene cuatro piezas: chromium_src/content/browser/permissions/permission_descriptor_util.cc, chromium_src/third_party/blink/public/mojom/permissions/permission.mojom ([BraveExtend] PermissionName), el hook BRAVE_PERMISSION_UTIL_PERMISSION_DESCRIPTOR_INFO_TO_PERMISSION_TYPE en blink/common/permissions/permission_utils.cc (override y patch) y chromium_src/third_party/blink/renderer/modules/permissions/permission_utils.cc. Arreglo: portarlas sin Speedreader/Wallet/AI chat; COSMETIC_FILTERING necesita su case.
2. permissions::RequestType: request_type.h mete kWidevine y kBraveGoogleSignInPermission tras kStorageAccess. En la 156, request_type.cc tiene dos switch exhaustivos (GetIconIdDesktop: nuestro #define kStorageAccessIcon está muerto; RequestTypeToContentSettingsType). 1.98 los cubre con hunks en patches/components-permissions-request_type.cc.patch (kExtensionOldIcon / std::nullopt). Arreglo: esos hunks y fuera el #define muerto.
RIESGO:
- webui_url_constants.cc: #define kChromeUIAttributionInternalsHost muerto, así que adblock, adblock-internals y welcome faltan en ChromeURLHosts(). 1.98 lo hace con un patch.
- autocomplete_provider.{h,cc}: #define TYPE_BOOKMARK muerto (la 156 usa kBookmark); TYPE_BRAVE_LEO sin uso. Borrar.
- PermissionType: falta BRAVE_MIN_VALUE para el permission_overrides_unittest de content.
- request_type.h: los valores van en medio del enum (1.98 los pone al final). No urge.
- Macros muertas: data_decoder JSON_PARSE_RFC (se pierde ALLOW_TRAILING_COMMAS), bubble_frame_view DIALOG_BUTTON_NONE, tab_helpers kWebUITabStrip, realbox_handler, omnibox_pedal kShare*ChromeRefreshIcon, chrome_browser_main_mac EnsureUpdater, profile.cc WipeSearchEngineChoicePrefs, DefaultBrowserWorker, opaque_browser_frame_view_layout.h, omnibox_result_view, ranker_url_fetcher.h, aggregatable_trigger_config.h, chrome_browsing_data_remover_delegate.h.
- Overrides de ficheros que la 156 ya no tiene (404): prediction_based_permission_ui_selector, redirect_heuristic_tab_helper, click_to_call_utils, crashes_ui, webui_util, safety_check_handler, searchbox_handler, initialize_extensions_client, fcm_network_handler, v4_protocol_manager_util, version_handler_helper, content/common/user_agent.cc, manifest_url_handlers, google_api_keys-inc.cc, is_potentially_trustworthy.cc, geolocation.cc.
- Solo Windows: chromium_install_modes, idl, elevator, sandbox interceptors.
BIEN: ContentSettingsType, SiteSettingSource, ProviderType/SettingSource, ChromeIsolatedWorldIDs, DownloadClient, InfoBarIdentifier, ImporterType, HistogramValue, omnibox_action_concepts, api_permission_id, ChooserControllerType, SelfDeleteSupport, DataTypeForHistograms, url_constants, las 54 listas de features y origin_trials.

# MOTOR-38: estado (06-11-2026, ~16:05 UTC)

MOTOR-38 (`session_01MwmK2gzv4SrPPzHLtAispT`, Opus 5.5). Coordina **COORDINACIÓN-31** (`session_01MwmK2iP27sssYimPaJ7scp`).

**Punta:** `nube/b2-porte-t11` en **f81e6b8949** (T-tests, limpieza y tanda de seguridad desde 1.98), sin medir:
el P2 de MOTOR-30 está pendiente. Detalle en
`brave-propio.md` §12.16.3.

**Hecho:**
- arreglos del P2 y de la rápida de b1a25a49;
- GPC como 1.98;
- tanda T-tests completa (5 subagentes por zonas, con el brief de MOTOR-37 adaptado y lista de zona por fichero);
- caBLE revisado: ningún parche ni flag lo apaga (§12.16.2).

**Siguiente:**
1. P2 o rápida de 074ad618: arreglar lo que salga.
2. Features de nivel, solo si salen rotas.
3. Decisiones de COORDINACIÓN sobre los SIN-1.98 y OFAC.
4. Tanda «seguridad desde 1.98» (lista en §12.16.3), si COORDINACIÓN la aprueba.
5. Envoltorios `.cc`.
6. `brave_services_key_id`.

**Método T-tests que funcionó:**
- clasificar por blob con `git ls-tree` frente a `v1.98.63` y la raíz 1.57 (no baja blobs);
- una zona por subagente, con su lista etiquetada TOMAR-1.98/PORTAR/SIN-1.98;
- cherry-pick lineal de las cinco ramas: no hubo conflictos.

# MOTOR-37 → MOTOR-38: B2 T11 (06-11-2026, ~14:35 UTC)

MOTOR-37 (`session_01MwmK2mQraxPiisCp7W6WP8`, Opus 5.5). Coordina **COORDINACIÓN-30** (`session_01MwmK2mDgcmCYXZUo9KnJZU`).
Relevo al ~37 % de contexto.

**Qué leer:** esta sección y `brave-propio.md` §12.16.1–§12.16.2 (pérdidas, tabla de shas, decisiones, comprobaciones
para LOCAL).

**Punta:** `nube/b2-porte-t11` **b1a25a49**, lineal sobre 2eb3838b5. Último P2 de MOTOR-30, sobre 64c5c0f2: rotos 106 =
producción 11 (8 reales) + tests 95, ningún símbolo sin definir. Todo lo de esos 11 ya tiene arreglo subido (0fe3c858,
fc2e9ca1); lo posterior a 64c5c0f2 (settings 156, settings2, limpieza, localhost) **no está medido**. Pide el P2 de
b1a25a49 primero.

**Hecho en T11 por MOTOR-37** (detalle en §12.16.2):
- crx_verifier (revisado por SEGURIDAD-PORTES-18);
- build_ts (stub de leo y `ts_definitions`);
- las 68 filas de producción, en 4 zonas;
- `not_needed(is_ash_webui)`;
- tanda «settings 156»: plugins `*_page_index` + mecanismo «-chromium.ts» de 1.98, sin lit_mangler;
- Checkup oculto;
- subpáginas de autoplay, estado de Shields y Google sign-in;
- Storage Access visible;
- auto-verify fuera;
- webpack de la NTP con `//resources`;
- origin_trials de 1.98;
- cadena muerta de PiP fuera;
- permiso localhost → LNA nativo.

**Decisiones vigentes (COORDINACIÓN-30 / Titín):**
- **Google sign-in se queda entero** (Titín). No lo quites.
- La lista de lectura de Chromium se queda.
- (B) history, extensions y downloads compilan: no se quitan.
- AUTO_VERIFY y ANTI_ABUSE quedan como en 1.98: fuera de settings; el enum y el C++ se quedan.

**Siguiente, en orden:**
1. P2 de b1a25a49 y sus rotos de producción. Hay riesgo en:
   - settings:build_ts, por los ~20 TS nuevos con mixins de la 156;
   - el override global de `tools/grit/preprocess_if_expr.py`, que toca todo preprocess de WebUI;
   - gn check de `ad_block_service.cc`: si falla, añade la dep `//services/network/public/cpp`;
   - la regeneración del mojom `content_settings_types`.
2. Parches de motor que nombran features de nivel borradas (punto 3 de la nota de MOTOR-36): navigation_request,
   cors_url_loader, local_dom_window, navigation_url_loader_impl, render_frame_host_impl, enclave_authenticator_browsertest.
   Solo si la Ubuntu los da rotos.
3. Pendientes menores de MOTOR-36 que siguen abiertos:
   - `ShouldUseDarkColors()` en `favicon_source.cc`;
   - `bookmark_utils.cc` (iconos `ui::ColorVariant`);
   - la bienvenida con `help-wdp`/`recordP3A`;
   - `brave_shields_p3a`;
   - el wrapper Android de `chrome_feature_list.cc`;
   - `ModuleFileNamePatch` de Windows;
   - el menú contextual (esquema 128).
   Repásalos con `git grep` antes de nada: algunos los pueden haber tocado las zonas.
4. Tanda T-tests: 95 rotos de tests y la lista base de MOTOR-36 (152 idénticos a 1.98, 140 tocados, 39 sin equivalente con
   propuesta).
5. Envoltorios `.cc` al esquema de 1.98 (`#include <...>`) sin `redirect_cc`.
6. softmac: `brave_services_key_id` sale de `FlyWeb/scripts/build.sh` cuando build.sh pase a la 3.0.0.

**Método que funcionó:**
- Subagentes por zonas disjuntas, cada uno en su worktree (`git worktree add -b t11-<zona> /home/user/wt/<zona> <punta>`),
  con un brief común en un fichero. El mío era `/tmp/claude-0/brief.md`, que no sobrevive: reescríbelo. Contenido:
  - el donante 1.98 con `git show v1.98.63:` y `ls198.txt`;
  - la 156 por gitiles con `?format=TEXT | base64 -d`;
  - los criterios del porte;
  - el formato de commit y del informe.
- Cuatro subagentes a la vez fueron bien (150–450 k tokens cada uno).
- Fusiona con `--ff-only`. Si la rama local de la punta va atrasada respecto a la remota (empujé desde un worktree),
  `git fetch origin nube/b2-porte-t11` y rebasa sobre `origin/`.
- Los diffs mecánicos de la Ubuntu llegan por COORDINACIÓN: aplícalos tal cual (ya vienen probados) y comprueba los
  parches con `git apply --check` contra el fichero de la 156 descargado (`git hash-object` da el blob de la línea `index`).

**Trampas:**
- `add_repo` de brave-core lo deniega el clasificador la primera vez; Titín lo autoriza en tu sesión y entra al
  reintentar. Mientras tanto, el clon de solo lectura (repositorio público) sirve para trabajar en local.
- `IDC_*`/`IDS_*` de funciones quitadas: se quedan el id y las cadenas, porque alimentan tablas generadas; quita solo los usos.
- Los overrides «../gen/…» de chromium_src son el patrón bueno para cabeceras grit; si salen «no encontrado», el problema
  suele ser que el grit no ha llegado a correr (dependencia bloqueada), no la ruta.

# MOTOR-36 → MOTOR-37: B2 T11 (06-11-2026, ~12:50 UTC)

MOTOR-36 (`session_01MwmK2kkeRetx2LSfb5hfkz`, Opus 5.5). Coordina **COORDINACIÓN-29** (`session_01MwmK2iQtUzz1YsyLeXQbNV`).
Relevo al ~40 % de contexto.

**Qué leer:** esta sección y `brave-propio.md` §12.16 (decisiones y pérdidas de T11).

**Punta:** `nube/b2-porte-t11` **2eb3838b5** (encima de t10 4445df1fd; cadena lineal salvo un merge de t11-ext). Trabaja
encima. Medida: P2 de T11 en d28ecad6 (MOTOR-30, sin arreglos locales): rotos **177** (T10: 280) = **producción 98**
(chromium_src 49, brave 39, chromium_via_brave 7, generado_falta 2, otro 1) + tests 79; 0 regresiones, 84 unidades
arregladas. Lo subido después de d28ecad6 (marcadores, componentes, content/blink, omnibox, features, limpieza) aún no
está medido: pide la compilación rápida de las unidades o el P2 de la punta.

**Alcance (COORDINACIÓN-29):** T11 = solo producción; el hito siguiente es que LOCAL compile y arranque en Mac. Los tests
van en una tanda **T-tests** aparte: de 335 ficheros de test, 152 son idénticos a 1.98 y FlyWeb no los tocó (se toman
enteros de 1.98), 140 están tocados (se portan) y 39 no tienen equivalente en 1.98 (lista con propuesta portar/borrar a
COORDINACIÓN). Lista base: `git ls-files | grep -E "(browsertest|_test|unittest)s?\.(cc|mm|h)$"` sin android/ios.

**Siguiente (en orden):**
1. **crx_verifier** (confirmado por COORDINACIÓN y ARQUITECTURA, comentario en softmac #790): ninguna clave de editor de
   Brave; solo `kFlyWebPublisherKeyHash` (= `publicador_sha256` de `claves-publicas.json`) además de la de Google de
   Chromium; `IsBravePublisher` → `IsFlyWebPublisher` (parche de `crx_verifier.cc` en consonancia; conservar o renombrar
   `SetBravePublisherKeyHashForTesting`); quitar el comentario «Accepted in addition to Brave's…»; comparar
   `kPublisherKeyHash` de la 156 con la de la 128. Lo revisa SEGURIDAD-PORTES-18 (lo abre COORDINACIÓN con el commit).
2. Las **98 filas de producción** y el fallo de `//brave/ui/webui/resources:build_ts` (tsc) que te pasa COORDINACIÓN.
   build_ts seguramente bloquea los 2 generado_falta (`brave_new_tab_generated_map.h`, `ui/webui/resources/grit/webui_resources.h`).
   Pista del agente de extensiones: las sustituciones Polymer de `cr_toggle`, `cr_button` y `cr-toolbar` (`br_toolbar`) son
   Lit en la 156; 1.98 quitó `br_shared_style`/`vars` y esos `#import`. `lint_css`: ya se puso un selector por línea en
   `br_shared_style.css`. Nuevos ya conocidos: `post_task_and_reply_with_result_internal.h:47` (algún PostTaskAndReplyWithResult
   con tipos que no casan), `brave_browser_main_extra_parts.cc:59` (`set_silence_deprecated_manifest_version_warnings_for_testing`),
   `brave_new_tab_page_handler.cc:34` (`chrome_select_file_policy.h`), `top_sites_message_handler.cc:21` (`ntp_pref_names.h`
   → `chrome/browser/new_tab_page/prefs`).
3. **Riesgo:** el agente de features borró 6 parches de nivel (content/net/network/blink/fido features: la 156 los trae
   de serie), pero algunos parches de motor aún nombran esas features: `navigation_request`, `cors_url_loader`,
   `local_dom_window`, `navigation_url_loader_impl`, `render_frame_host_impl` (y `enclave_authenticator_browsertest`).
   Si la Ubuntu los da rotos, quita esas condiciones.
4. **Tanda propia aprobada:** fuera el permiso «localhost» de Brave en favor del Local Network Access nativo (~50 ficheros:
   `components/localhost_permission`, permission contexts, content settings, about_flags, ajustes); no se trasladan los
   permisos concedidos. Ahora solo compila (`brave_localhost_permission_network_delegate_helper.cc`).
5. Pendientes menores: `ShouldUseDarkColors()` en `chromium_src/ui/native_theme/native_theme_android.cc` y
   `chromium_src/chrome/browser/ui/webui/favicon_source.cc`; seeker propio de `brave_video_overlay_window_views` +
   `chromium_src/content/public/browser/overlay_window.h` → barra de progreso nativa de la 156 (como 1.98);
   `chromium_src/chrome/browser/ui/bookmarks/bookmark_utils.cc` (iconos con `absl::variant` → `ui::ColorVariant`, IDR) y
   `chromium_src/.../views/bookmarks/*`; `appearance_page.ts` (Polymer → Lit); frontend de bienvenida con `help-wdp` y
   `recordP3A` (manejadores vacíos); `brave_shields_p3a` sigue; wrapper Android `chrome_feature_list.cc` nombra lo quitado;
   cadena de Windows `ModuleFileNamePatch` (muerta en Mac); menú contextual sigue con el esquema 128
   (`BraveRenderViewContextMenu` + `#define`); 1.98 pasó a clase propia: adóptalo si al compilar hay choques.
6. Después (ya encargado): envoltorios `.cc` al esquema de 1.98 (`#include <...>` en vez de `"src/..."`), sin `redirect_cc`.
7. softmac: `brave_services_key_id` sigue en `FlyWeb/scripts/build.sh` mientras viva la 2.x (Brave 1.69 la exige en
   oficial); quitarla cuando build.sh pase a la 3.0.0.

**Método:** igual que MOTOR-35: cada sha que subas lo compila la Ubuntu en las unidades tocadas (dale a COORDINACIÓN la
lista de `.cc`); P2 completo al cerrar tanda. Sube a menudo.

**Herramientas y trucos:**
- Clon: `git clone --depth 1 -b nube/b2-porte-t11 https://github.com/lamosquita-net/brave-core /home/user/brave-core`;
  luego `git remote add up https://github.com/brave/brave-core` y `git fetch --depth 1 --filter=blob:none up tag v1.98.63`
  (y `tag v1.69.168`). Nunca `git grep` sobre las etiquetas; `git ls-tree -r --name-only v1.98.63 > ls198.txt` y `git show`.
- `b2-chk` sobre la punta antes de tocar nada (chk-base); ~33 falsos positivos de generados (`app/`, `vector_icons.h`).
  `b2-cr156` cachea en `/tmp/claude-0/cr156`; exporta `FlyWeb/tools/brave-inventario` al PATH.
- **Subagentes por zonas disjuntas** con worktrees (`git worktree add -b t11-<zona> /home/user/wt/<zona> nube/b2-porte-t11`)
  y el brief `b2-brief-t5bis.md` adaptado (sed de la sesión, asunto `[b2-porte-t11]`, rebase sobre la punta); fusionar con
  `--ff-only` (rebasan ellos). Seis a la vez fueron bien; cada uno ~230–400 k tokens.
- Script para features: comparar cada `{kX,` de `OVERRIDE_FEATURE_DEFAULT_STATES` con el `.cc`/`.h` de la 156 y con el
  wrapper de 1.98; ojo, `grep -q` con lista de ficheros vacía lee stdin y se cuelga (usa `</dev/null`). Las features que la
  156 cambió de fichero salen en `v1.98.63:app/feature_defaults_unittest.cc`.
- La medida de contexto de `get_session` (`context_usage.used_tokens`) es la fiable; al principio puede marcar 0.
- `push --delete` lo deniega el clasificador; `nube/m34-probe` lo borra Titín desde la web.

# MOTOR-35 → MOTOR-36: B2 T9-fix, T5-bis y T10 subidas (06-11-2026, ~11:10 UTC)

MOTOR-35 (`session_01MwmK2jBqgc4rNEXcQwzpbr`, Opus 5.5). Coordina **COORDINACIÓN-29** (`session_01MwmK2iQtUzz1YsyLeXQbNV`).
Relevo al 39 % de contexto.

**Qué leer:** esta sección y `brave-propio.md` §12.15 (y §12.13 si vas a tocar `patches/`).

**Puntas (brave-core, cadena lineal con merges):** T9-fix `nube/b2-porte-t9-fix` 29e723561 (PR #20, medida: 335 rotos) →
T5-bis `nube/b2-porte-t5-bis` 84335a1a0 → T10 `nube/b2-porte-t10` 4445df1fd (= T5-bis + T10, por merge). Trabaja encima
de la punta más alta (t10). `nube/m34-probe` sigue sin borrar (el clasificador deniega `push --delete`; Titín desde la web).

**Método nuevo (COORDINACIÓN-29, 06-11):** cada sha que subas lo compila la Ubuntu (MOTOR-30/31) solo en las unidades
tocadas; COORDINACIÓN te pasa los errores; los arreglos mecánicos los hace ella en `nube/b2-ubuntu-fix` encima de tu punta
y tú los fusionas (merge). P2 completo solo al cerrar tanda. Sube a menudo.

**Siguiente:**
1. Errores de la compilación de T5-bis/T10 que pase COORDINACIÓN. Previsibles: `BraveTabStrip` (`UpdateHoverCard(Tab*)`,
   `GetBrowser()`), `BraveTabHoverCardController` y partes de `BraveBrowserView` con API de 128;
   `brave_sharing_hub_browsertest.cc` incluye `page_action_icon_view.h` (ya no existe); 16 sitios en 10 tests con
   `Browser* x = CreateIncognitoBrowser()/CreateBrowser()` (en 156 devuelven `BrowserWindowInterface*`).
2. Tarea posterior ordenada por COORDINACIÓN-29: pasar los envoltorios `.cc` al esquema de 1.98, sin `redirect_cc`.
3. Pendientes de otros: LOCAL confirma si ANGLE Metal necesita `flyweb_metal_bin_path` en `flynk-b1d` y mete los 9
   parches de `FlyWeb/docs/b2/t10-para-b1d/`; LOCAL-19 comprueba que con WebGPU apagado nada llame a Dawn en 10.14;
   la puerta del llavero debe probarse con T10 (los 4 parches de sync de contraseñas se quitaron por ser nativos en 156).

**Herramientas:** clon `--depth 1 -b nube/b2-porte-t9-ver` + `git fetch --depth 1 --filter=blob:none up tag v1.98.63 tag
v1.69.168` (remote `up` = brave/brave-core); nunca `git grep` sobre las etiquetas. `lamosquita-net/chromium` es público:
`flynk-b1d` se lee por `raw.githubusercontent.com`. Briefs para subagentes: `FlyWeb/tools/brave-inventario/b2-brief-t5bis.md`
(común) y `b2-brief-t10.md` (cruce con flynk-b1d); cópialos a tu scratchpad y cambia la línea `Claude-Session` por la tuya. Cinco subagentes en
paralelo funcionaron bien con zonas disjuntas; fusionar con `--ff-only` y rebasar el resto.

# MOTOR-34 → MOTOR-35: B2 T7-ter, T5, T8, T9 y T9-ver subidas (05-11-2026, ~00:00 UTC)

MOTOR-34 (`session_01MwmK2k5p4qtinBTbRDd26B`, Opus 5.5, alto). Coordina **COORDINACIÓN-29** (`session_01MwmK2iQtUzz1YsyLeXQbNV`).
MOTOR-30 pasó el relevo a MOTOR-31 (Ubuntu, misma máquina, puente); los sha se mandan a COORDINACIÓN-29.

**Qué leer:** esta sección; `brave-propio.md` §12.12 (llavero), §12.13 (capa de nivel y versión) y §12.14 (T5, T8, T9).

## Estado (brave-core, todas en borrador)
| Tanda | Rama | sha | PR |
|---|---|---|---|
| T7 + T7-bis + T7-ter | `nube/b2-porte-t7` | acc9b19eb | #15 |
| T5 (poda + interfaz mínima) | `nube/b2-porte-t5` | ab239aabb | #16 |
| T8 (Privacy Sandbox, JS bloqueado) | `nube/b2-porte-t8` | 4f182ca33 | #17 |
| T9 (pins, capa de nivel, Wallet) | `nube/b2-porte-t9` | 93660fbb6 | #18 |
| T9-ver (3.0.0, nivel 156, Client Hints) | `nube/b2-porte-t9-ver` | 4b74fc021 | #19 |

- **Siguiente:** recuento de MOTOR-31 sobre 4b74fc021 y arreglar encima de la punta más alta; **T5-bis** (lo que la 156
  reestructuró: vistas de pestañas, pestañas verticales, menú de perfil, maquetación del panel lateral, infobars; parches
  `profile_menu_view_base.cc` y `tab_style_views.cc`); **T10** (los ~55 «reportar» de §12.13, primero `audio_param_handler.h`,
  `trust_store_chrome.cc`, `pki_metadata_component_installer.cc`; cada parche Mojave se cruza antes con `lamosquita-net/chromium`
  `flynk-b1d`: lo que ya esté allí no se reporta; los 3 parches de extensiones de UA/versión sobran).
- **Decisiones de COORDINACIÓN-29 (05-11, 23:58), para T5-bis:** (1) fuera la vista dividida de Brave y el aviso de la lista de
  cookies, **antes** comprobar si la 156 trae la vista dividida nativa de Chromium (si la trae, se queda la de Chromium sin tocar);
  (2) conforme con la poda de los paneles de lectura y marcadores de Brave; (3) fuera `brave_tooltips` y `BraveDownloadItemModel`;
  (4) `BraveWalletDisabled` se queda; `safe_builtins` y `third_party/rapidjson` fuera si `b2-chk` confirma que no tienen usuarios.
  Pestañas verticales: mirar primero si la 156 tiene las nativas de Chromium; si las tiene, se quedan las de Chromium y no se portan
  las de Brave; **avisar a COORDINACIÓN de lo encontrado antes de portar nada**. Las funciones perdidas por ganchos quitados en la
  156 se aceptan (§12.14, «para las notas de la 3.0.0»).
- Rama de prueba `nube/m34-probe` (= b02508af) sin borrar: el proxy corta el push de borrado; borrarla desde la web.

## Cómo se hizo
- Entorno: clon `--depth 1` de la rama; `git remote add up https://github.com/brave/brave-core`; etiquetas `v1.98.63` y `v1.69.168`
  con `--filter=blob:none`; blobs por lotes de 4 000 (`git ls-tree -r` → `git fetch up <oids>`), **sin** `ios/ android/
  third_party/ vendor/` ni imágenes (~50 000, unos minutos). `git grep` sobre la etiqueta trae blobs de uno en uno: evitarlo.
- Brief de subagentes en `/tmp/claude-0/t5-brief.md` (se pierde: rehacerlo desde `b2-brief-subagentes.md`, con la base de
  `b2-chk` en `/tmp/claude-0/chk-base.txt`). Dos subagentes a la vez, cada uno en su worktree; al final rebasan ellos.
- Cadena: `git rebase --onto <nueva base> <base vieja> <rama>`; los conflictos salen donde una tanda poda y otra porta la misma
  línea (Wallet frente a `BrowserWindowInterface`): quedarse con la firma nueva y quitar lo podado.

## Trampas nuevas
- **`-iquote`, no `-I`, para `chromium_src`** (como 1.98): con `-I` un envoltorio con `#include <x/y.h>` se incluye a sí mismo. Se
  conserva además `-I//..` porque ~1 200 envoltorios usan `"src/…"`.
- La capa de nivel de la 2.x (1319 parches) y los 70 backports de seguridad ya no están; si un parche nuevo de Blink usa un flag
  de `runtime_enabled_features.json5`, comprobar que existe en 156.
- `FlyWeb/v8-revision` (y dragonbox/fast_float) ya no existe: `build.sh` toma la V8 de la DEPS de la 156.
- El push a GitHub falló 20 min (23:20–23:39 UTC, «fatal error in commit_refs», también sin objetos nuevos): es de GitHub; no
  subir por la API (COORDINACIÓN-29), reintentar.

## Lo que dudo
- T5-interfaz: `gn check` de `browser_window/internal` (1.98 añade `//brave/browser/ui/browser_window/internal`).
- Buscadores: `brave_template_url_service_util_unittest` (`@gemini` al final); las pruebas de navegador de buscadores y
  `search_engine_provider_util.h` (`Profile*` → `Profile&`) siguen con la API vieja.
- Client Hints: `GetUserAgentFromCommandLine()` del original se usa desde el envoltorio (mismo TU); sin compilar.

# MOTOR-33 → MOTOR-34: porte B2 a Chromium 156, hechas T3, T6 y T7 (05-11-2026, ~22:25 UTC)

MOTOR-33 (`session_01MwmK2k3tUrKX1yNFM5soGn`, Opus 5.5, alto). Coordina **COORDINACIÓN-28** (`session_01MwmK2kJamvybegV8BvFxJf`).
Plan «ultra»: cada tanda se sube y se pasa sin esperar el recuento de MOTOR-30; lo que salga se arregla encima.

**Qué leer:** esta sección; `brave-propio.md` §12.6 (plan), §12.8–§12.11 (T3, T6, T7 y la medida del NTP); «Cómo se hizo» y
«Trampas» de la sección MOTOR-32 de abajo (siguen valiendo).

## Estado
| Tanda | Rama brave-core | sha | PR | Estado |
|---|---|---|---|---|
| T3 (Blink/V8, Page Graph podado) + T3-bis/ter | `nube/b2-porte-t3` | 8b2de20e | #13 | entregada; MOTOR-30 midió 078fe70b: 644 rotos (743 en T4), 0 regresiones |
| T6 (Shields: adblock 0.13.3, C++) + T6-bis (Wallet fuera) | `nube/b2-porte-t6` | a28f8adf | #14 | entregada; MOTOR-30 mide 820772ce |
| T7 (sync, `os_crypt_async`, importer, buscadores) | `nube/b2-porte-t7` | ff2fa26e | #15 | entregada; aviso en `buzon/MOTOR/20261105-2217-MOTOR-33.md` |
| PR de documentación | softmac `claude/motor33-b2` | 19ec1c3 | #769 | §12.8–§12.11 |

- **Siguiente: T5** (interfaz mínima, `Browser` → `BrowserWindowInterface`…) sobre `nube/b2-porte-t7`, con la **poda previa**
  de Playlist, Speedreader, WebTorrent, Wayback, Commander y la Sidebar, y la del NTP según §12.11 (aprobada: (B) fuera en commits
  revertibles, (A) mínima; criterio de Titín: la nueva pestaña de la 3.0.0 igual que la de la 2.7.0). Recoge también: los ~42
  `override` no factoría de T4, `RegisterTrustedWebUIInterfaceBrokers`, `HandleURLOverrideRewrite` (sin `kChromeUISyncHost`/
  `kChromeUIWelcomeHost`), `NewTabShowsNavigationThrottle`, el throttle de WebTorrent, `brave_adblock_handler` (browser_finder.h),
  `brave_welcome_ui` (webpack; `kHasSeenWelcomePage` → `brave_welcome_page::prefs`), `identity_apitest`,
  `brave_sync_account_deleted_infobar`, `brave::ShowSync(BrowserWindowInterface*)`, `ephemeral_storage_blink_memory_cache_browsertest`.
- **Después: T8** (`chromium_src` restante). **Bloqueantes de T8** (COORDINACIÓN-28): el parche de `runtime_enabled_features.json5`
  que apaga Privacy Sandbox (SharedStorage, PrivateAggregation, Fledge/InterestGroup, Topics, Attribution…) con prueba JS de que no
  existen; comprobación de que con JS bloqueado en Shields siguen `chrome://settings`, la nueva pestaña y las extensiones;
  `password_status_check_service.h`. **T9**: ausentes de 1.98, pins estáticos de Brave fuera, restos de Wallet (Android,
  `wallet_strings.grdp`, allowlist `braveWallet`), Speedreader (con él caen `ahash 0.7` y lol_html).
- Pendientes de decisión enviados a COORDINACIÓN-28: excluir `AUTOFILL_VALUABLE` del sync (como 1.98), según go-sync.
- Para LOCAL (Mac): `Fw1KeyProvider` para `os_crypt_async` y la puerta M1–M5 del llavero con perfil real de la 2.x (§12.10).

## Cómo se hizo (además de lo de MOTOR-32)
- Blobs del donante: los de `chromium_src third_party patches components browser net build script common utility renderer v8`
  de las dos etiquetas, por lotes de 4 000 (`git ls-tree -r <tag> -- <dirs>` → `git fetch up <oids>`); ~46 000 en total.
- Dos subagentes a la vez, cada uno en su worktree sobre la punta, con un brief por tanda (copia del de T3 en
  `/tmp/claude-0/t3-brief.md`, se pierde con el contenedor: rehacerlo desde `b2-brief-subagentes.md`). Las tandas grandes se parten
  por zona (T3: Page Graph / envoltorios; T6: Rust / C++) y luego un «-bis» para los llamadores comunes
  (`brave_content_browser_client`). Encadenar con `git branch -f` y `rebase`; `b2-chk.py` idéntico en cada paso.
- Lo que aflora en cada medida de MOTOR-30 se arregla encima de la punta más alta, no en la rama vieja (evita reescribir las de
  encima).

## Trampas nuevas
- **La «nueva pestaña de FlyWeb» no es `flyweb_ntp`**: es `brave_new_tab_ui` modificado; `flyweb_ntp` solo son recursos.
- Un `#define` de ancla sobre un método cuyo tipo de retorno cambió en 156 rompe a todos los que incluyen la cabecera, en sitios
  sin relación (`update_client.h` → `action_runner.cc`).
- Macros de pruebas de `chromium_src` con nombres genéricos (`MIDI`) pisan enumeradores de mojom generados.
- Los parches de Blink de FlyWeb mezclan ganchos de Brave con backports del motor: al regenerar, fuera lo que la 156 ya trae.

## Lo que dudo
- Valores esperados del browsertest de device memory (copiados de 1.98; mismo PRNG, sin ejecutar).
- `temporal_capi` (Rust): causa sin aclarar; `stable_deref_trait` sin `std`; `raw_gn` de adblock de 1.98.
- La causa de `permission.mojom-data-view.h:161` (atribuida a la macro de `safety_hub_handler_unittest`).

# MOTOR-32 → MOTOR-33: porte B2 a Chromium 156, tandas T0–T4 (sin T3) (05-11-2026, ~20:30 UTC)

MOTOR-32 (`session_01MwmK2gqciFCPCBxxQQaRW8`, Opus 5.5, alto). Lo abrió COORDINACIÓN-27; lo coordina
**COORDINACIÓN-28** (`session_01MwmK2kJamvybegV8BvFxJf`). Plan «ultra» de COORDINACIÓN-28: cada tanda se sube y se
pasa sin esperar el recuento de MOTOR-30; lo que salga del recuento se arregla encima.

**Qué leer:** esta sección; `brave-propio.md` §12.6 (plan) y §12.7 (T0); la sección de MOTOR-31 de abajo («Cómo se
trabaja una tanda», trampas).

## Estado
| Tanda | Rama brave-core | sha | PR | Estado |
|---|---|---|---|---|
| T0 (lista 3) | `nube/b2-porte-t0` | 146eeddc | #9 (borrador, CI verde) | entregada; medida de MOTOR-30 pendiente (`buzon/MOTOR`) |
| T1 (renombres de `base`/URL) | `nube/b2-porte-t1` | 5d7b856a | #10 (borrador) | entregada (con T1-bis: `GURL::Get*()`), CI verde; dicho a MOTOR-30 que mida T1 si no empezó T0 |
| T2 (`base::Value::Dict`/`List`) | `nube/b2-porte-t2` | 7a6e1577 | #11 (borrador) | entregada: renombre a `base::DictValue`/`ListValue` (145 ficheros) y `JSONReader` con opciones explícitas (20) |
| T4 (factorías de servicios) | `nube/b2-porte-t4` | dbc5fbd5 | #12 (borrador) | entregada: `BuildServiceInstanceForBrowserContext` (15 factorías), ayudas de incógnito globales, `ProfileSelections` en TemplateURL/SearchEngineChoice |

- Cifra esperada: T0, unos 41 crates de Rust, 5 de omnibox y `json_reader.cc`; T1, unos 100 de 114; T2, unos 69 de 82 más
  6 por el `JSONReader` de un argumento.
- Restos de T2: `password_status_check_service.h` (la macro choca con una sobrecarga nueva de 156; 1.98 la resuelve con
  un parche: T8) y `content/public/test/browser_test_utils.h:756` (conversión ambigua de `nullptr` a `base::Value`;
  sin localizar quién la provoca).
- **Siguiente: T3 (Blink: `WTF::String`/`AtomicString`, `v8::Context::GetIsolate`; toca farbling y la capa del motor)
  → T6 → T7 → T5 → T8 → T9** (orden de §12.6), cada una sobre la anterior (T3 sobre `nube/b2-porte-t4`).
- Restos de T4: las factorías de lo que se poda en T5/T9 (Playlist, Speedreader, Commander, Sidebar, NTP de Brave)
  siguen con la API vieja; `patches/chrome-browser-themes-theme_service_factory.cc.patch` sigue anclado en
  `BuildServiceInstanceFor` (de los ~330 parches que no aplican); el constructor de `privacy_sandbox_settings_factory.cc`.
  T4 debería tumbar unos 15 de sus 64 más unos 15 `.cc` de otras causas; los otros ~42 de esas 64 líneas no eran
  factorías (otros `override`: `ContentBrowserClient`, vistas, url_loader…) y quedan para T5/T8.
- Decisión de Titín para T5 y T9 (05-11, en `DIRECTIVAS`): Playlist, Speedreader, WebTorrent, Wayback, Commander y la
  Sidebar de Brave quedan **fuera** y se podan como en B2.
- La nueva pestaña es `components/flyweb_ntp` tal cual. El NTP de Brave (`ntp_background_images`,
  `brave_new_tab_ui`, widgets) se borra salvo lo que `flyweb_ntp` use: **antes de borrar, medir sus dependencias y
  decírselas a COORDINACIÓN**.
- No se portan los parches GN propios de FlyWeb del motor (Blink, dragonbox, fast_float, simdutf, boringssl, CT…):
  se deciden en B3 con LOCAL (COORDINACIÓN-28).
- Para T7/T8 quedan anotados:
  - el parche `prepopulated_engines.json`, que en la 156 vive en el repo aparte `external/search_engines_data`;
  - `components-os_crypt-sync-BUILD.gn` y el C++ de `os_crypt` → `os_crypt_async` (`brave_sync_prefs`,
    `chrome_importer`), con §11.8;
  - `components/flyweb_os_crypt` y `browser/test`, que siguen con `os_crypt/sync` (solo Mac: LOCAL).

## Cómo se hizo (y conviene repetir)
- **Entorno** (se pierde con el contenedor):
  - `git clone --depth 1 -b nube/b2-porte-tN …/brave-core`;
  - `git remote add up https://github.com/brave/brave-core`;
  - `git fetch --depth=1 --filter=blob:none up refs/tags/v1.98.63:refs/tags/v1.98.63 refs/tags/v1.69.168:refs/tags/v1.69.168`;
  - después, **los blobs por lotes**: `git fetch up <oid…>` de a 4 000, con la lista sacada de `git ls-tree -r`.
    Unos 2 min para 30 000. `git cat-file --batch-check` los baja de uno en uno y no termina.
- **Herramientas** (`FlyWeb/tools/brave-inventario/`, en el PATH):
  - `b2-cr156 <ruta>` baja el fichero de Chromium 156.0.8078.90, o de v8 en su revisión de DEPS, con caché;
  - `b2-mkpatch <ruta> <modificado>` hace un parche al estilo de Brave (`--full-index`);
  - `b2-chkpatch <.patch>` hace `git apply --check` contra 156.
  - Comprobación estática: `b2-chk.py <checkout>`; su salida tiene que ser **idéntica** a la de la tanda anterior.
- **Subagentes:** uno por grupo, en worktrees, con el brief común
  `FlyWeb/tools/brave-inventario/b2-brief-subagentes.md` (método, herramientas, commits, informe). Cada uno rebasa él mismo al final.
- **Límite de 5 h de la cuenta:** seis subagentes a la vez lo agotaron a mitad de T0 y se paró todo unas 2 h. Con dos
  a la vez no pasó. Norma de COORDINACIÓN-28: si salta, `send_later` a la hora de `resetsAt` y seguir solo.

## Trampas de esta línea
- **El donante cambia el esquema de Brave.** Copiar un parche GN de 1.98 trae objetivos que aquí no existen
  (`//brave/browser:core`, `brave_origin`, omaha4…). Se toma solo **dónde anclar** en 156, con nuestro contenido de
  1.69 más FlyWeb.
- **En 156, `source_set("browser")` de `chrome/browser` ya no compila código propio**: las fuentes de Brave van en
  `core`. El arreglo de medida las ponía en `browser`, donde se perdían sin dar error.
- Algunas páginas WebUI de 156 son Lit: los `brave_overrides` de Polymer ya no valen (1.98 los quitó). Los parches TS
  que los importan siguen en el árbol y romperán tsc.
- **`GURL::host()`/`path()` devuelven `string_view` en 156**: quien necesite un `std::string`, `GetHost()`/`GetPath()`
  (T1-bis).
- Los `.grd`/`.grdp` de Chromium que Brave copia **no se editan a mano**: se regeneran con `chromium-rebase-l10n`,
  que ya va dentro de `updateBranding` y comprueba `app/CHROMIUM_L10N_VERSION`.
  `script/flyweb-rebrand-strings.py --check` tiene que salir 0.
- **Rust:** los reenvíos nuevos están solo en GN. Un `gnrt gen` los pisaría hasta que se pongan los `[patch]` en
  `Cargo.toml`, que es trabajo de T6.

## Lo que dudo
- La macro `default_state` de `chromium_src/base/feature_list.cc` solo está probada en una maqueta.
- Los tamaños de `resource_ids.spec` son estimados.
- El reparto por causa sale del **primer** error: las tandas pueden bajar menos de lo esperado.

# MOTOR-31 → MOTOR-32: porte de brave-core a Chromium 156, tandas T0–T9 (05-11-2026, ~15:20 UTC)

MOTOR-31 (`session_01MwmK2m9AmTH8abi3xrc5gB`, Opus 5.5, alto; línea B2, distinta de la de niveles MOTOR-4x). Lo
abrió y lo coordina COORDINACIÓN-27 (`session_01MwmK2j9aGRTHMvVrCfE8vE`). Hizo la **poda B2** (FM.55, hito 1) y
escribió §12 de `brave-propio.md` con la medida P2 de MOTOR-30. **El plan T0–T9 de §12.6 está aprobado**
(COORDINACIÓN-27, 05-11): en ese orden, una rama por tanda, y la lista 2 a 0 en cada medida.

**Qué leer:** `brave-propio.md` §12 entero (sobre todo §12.3 listas, §12.4 Rust, §12.6 plan) y §11.7 (receta);
`b2-poda.md` (resumen arriba; los informes por grupo, solo si una costura falla); datos en
`FlyWeb/tools/brave-inventario/datos/p2/` (`B2-entrega.txt` es el informe original de MOTOR-30).

## Estado
- **brave-core `nube/b2-poda` = 4127545c** (comprobado con `git ls-remote`), sobre `flyweb` 5fdeb23d (2.7.0).
  Contiene: los 70 directorios de §11.6, Tor entero (7 directorios, decisión de Titín del 05-11), el corte de `.onion`
  en `chromium_src/net/dns/host_resolver_manager.cc` (DNS y mDNS) y los dos arreglos de la lista 2 de MOTOR-30.
  PR #8 de brave-core en **borrador**, CI en verde; **no se fusiona** hasta que lo diga COORDINACIÓN.
- Se quedan sin borrar a propósito: `components/webcompat`, `p3a_utils`, `time_period_storage`, `ntp_background_images`.
  **Widevine se queda** (desactivado por defecto; no tocar).
- Medida P2 (Linux, 156.0.8078.90): base 1 682 → poda **936** ficheros rotos; lista 1 = 928 (por la 156), lista 2 = 2
  (arreglados), lista 3 = 255 (arreglos de medida, a rehacer en T0).

## Cómo se trabaja una tanda
1. Rama `nube/b2-porte-tN` **encima de la anterior** (T0 sobre `nube/b2-poda`). Commits por causa, en inglés, asunto
   `[b2-porte-tN] …`. Sin compilar aquí (no hay Chromium): editar con el error de la lista 1 delante.
2. **Donante = etiqueta `v1.98.63` de `brave/brave-core` upstream** (pública; fetch anónimo, p. ej.
   `git fetch --depth=1 --filter=blob:none https://github.com/brave/brave-core refs/tags/v1.98.63` y los blobs que hagan
   falta). **No** el `master` del fork, que es 1.98.37: MOTOR-31 comparó contra 1.98.37 en §12.3 (633 distintos / 188
   ausentes / 4 iguales); **en T0 repite la comparación con .63 y anota en §12 si cambia**. Del donante se toma el
   cambio de la causa de la tanda, no el fichero entero, y se reaplican las ediciones de FlyWeb (marca, `flyweb://`,
   constantes de §2.3).
3. **Entrega:** push de la rama, comprobar el sha con `git ls-remote`, y `send_message` a COORDINACIÓN con sha, causa,
   ficheros tocados y la cifra esperada (cuántos de la lista 1 deberían caer). COORDINACIÓN lo pasa a MOTOR-30 por
   `buzon/MOTOR` (Ubuntu); MOTOR-30 compila con la receta de §12.1 y devuelve lista 1 nueva y lista 2 (debe ser 0).
   Si la lista 2 no es 0, se arregla en la misma rama antes de la tanda siguiente.
4. Documentar cada tanda en `brave-propio.md` §12 (subsección nueva) por PR `claude/motor32-…` de softmac.

## Qué depende de quién
- **T0–T4 y T6–T7** no dependen de decisiones: empezar por **T0** (lista 3 bien hecha: `redirect_cc`, `mojom_parser.py`
  y atributos `[BraveAdd]`/`[BraveExtend]`/`[Native]`, grit de la 156, `chromium-rebase-l10n` en `updateBranding`,
  cabeceras `_api.h`, envoltorios de `base`, los 70 parches GN como commits, Rust en GN, ciclo `brave_sync`).
- **T5 (interfaz) y T9 (ausentes en 1.98)** esperan a que Titín decida Playlist, Speedreader, Sidebar, WebTorrent,
  Wayback, Commander y el NTP de Brave (lo pide COORDINACIÓN). Cada «fuera» se poda como en B2 antes de portar.
- `FlyWeb/scripts/build.sh` **no se toca** hasta F1 (args que ya no se declaran: lista en `b2-poda.md`).

## Trampas (de esta línea)
- **Paralelizar con worktrees y rebasar después cuesta**: en B2 los 7 grupos chocaron en los mismos ficheros (prefs,
  factorías, `about_flags`, `BUILD.gn`, `resource_ids.spec`). Funcionó pidiendo a **cada subagente que rebasara él
  mismo** sobre la rama integrada (conoce sus cambios). Vigilar `}`/`#endif` sueltos, `},` duplicados en
  `resource_ids.spec` y líneas en blanco dobles: salieron en todas las integraciones.
- **Un envoltorio `chromium_src` borrado o recortado cambia Chromium sin error.** Antes de borrar uno, leerlo entero:
  `profile.h` parecía solo de Tor y también renombraba `IsIncognitoProfile`/`IsPrimaryOTRProfile` (estaba bien porque
  el `.cc` quitaba las dos cosas a la vez). Comprobar que ninguna macro `BRAVE_*` que se deja de definir siga en
  `patches/` o `chromium_src/` (orden en `b2-poda.md`, sección Tor).
- **Comprobación estática sin compilar** que sirvió: `#include "brave/…"` y etiquetas `//brave/…` inexistentes
  comparadas con la base (`FlyWeb/tools/brave-inventario/b2-chk.py`; residuales de un directorio:
  `b2-resid.sh`); buildflags y args de gn de lo borrado; marcadores
  de conflicto. Con eso la poda dio solo 2 rotos reales.
- **Ocultos por el primer error:** la clase de un fichero sale del primer error; al arreglarlo puede aflorar otro.
  Contar con que la lista 1 no baje lo que suma la tanda.
- La CI del fork (`compare-chromium-versions`) fallaba por una etiqueta inexistente: ya está creada
  (`chromium-version-mismatch`). Un rojo nuevo ahí no es del porte si las versiones coinciden.
- `raw.githubusercontent.com/chromium/chromium/<etiqueta>/<ruta>` para leer Chromium 128/156 (0,4 s por fichero).
- **El nombre «Leo»** es también el sistema de diseño `@brave/leo` (MIT), del que dependen los WebUI: no tocarlo.

## Lo que dudo
- El corte de `.onion` por **mDNS** (4127545c) no se ha compilado ni probado; el de DNS sí (MOTOR-30, con control negativo).
- La causa de cada fichero de la lista 1 es una regex sobre el primer error (aprox.): T1/T2 pueden salir algo más
  pequeñas o mayores.
- T6 (adblock 0.8 → 0.13.3) cambia la API que usa `brave_shields/adblock/rs`: es la tanda de más valor y más riesgo;
  después hace falta una prueba funcional de Shields con las listas propias (`components.flyweb.lamosquita.net`).
- Los ~330 parches de Brave que no aplican no están en T0–T9 (solo los 70 de GN en T0); Mac (50 `.mm`) lo mide LOCAL.

# MOTOR-44: cierre del nivel 138 (02-11-2026, ~14:45 UTC)

MOTOR-44 (`session_01MwmK2khgL2FTt7HVSDDaTs`, Opus 5.5, medio). COORDINACIÓN-24 no abrió MOTOR-45: MOTOR-44 cerró el
nivel. **brave-core `nube/motor-138` = 06d351d3**, sin compilar, entregada a COORDINACIÓN-24 para LOCAL. Detalle en
`version-2.7.0.md`. softmac PR #695 (notas y `motor-138.html`).

**Para la MOTOR siguiente** (errores de LOCAL de la 2.7.0 o el nivel 139):
1. Al principio del 139, «Aplazado del 138» (`version-2.7.0.md`): `sibling-index()`/`sibling-count()`, `stretch`,
   alineación OOF, la reescritura del textarea y el escape del 136 de `scheduler.yield` (1988acd89 + 1f5acb16).
2. Fuera de esta tanda y sin decidir: 0bc24ff1 (`LayoutIsAnonymousBlockFix`, 9 rechazos), 1c066c83 y 3a7a9069
   (rendimiento), B4 `FlowThreadLess`, A11 `RenderSurfaceFor2DScaleTransform`.
3. **Entorno** (se pierde con el contenedor): brave-core `git clone --filter=blob:none -b nube/motor-138`; herramientas
   `cp FlyWeb/tools/port/* /tmp/claude-0/port/` y `mkdir gd gf` dentro (sin ellas `gdiff.sh` falla en silencio);
   `cr128` parcial por `+archive` (Blink core/platform/modules/public, content/{browser,renderer,common,public},
   services/network/public; ~260 MB, 10 min). Si falta un fichero en `cr128`, `generar128.sh` lo pide a gitiles: **si
   gitiles da 503, el parche sale como «fichero nuevo»** (pasó con `core/dom/build.gni` en 5a86f3aa): `chk128.sh` lo
   detecta («NO APLICA»), pasarlo siempre. Metadatos de Chromium desde 2025-01-15 con `git fetch --filter=tree:0
   --shallow-since=2025-01-15 origin tag 138.0.7204.185` (menos de 10 min) para `git log --grep`. Un `python3 -` con
   `assert` que falla a mitad deja el fichero sin escribir: mirar el diff del área antes de generar.

---

# Relevo de MOTOR: de MOTOR-43 a MOTOR-44 (02-11-2026, ~13:00 UTC)

MOTOR-43 (`session_01MwmK2iCg1a5MkUFrLe5FvS`, Opus 5.5, medio). FM.53, nivel 138 = 2.7.0. **brave-core `nube/motor-138` =
17a21921**, sin compilar. COORDINACIÓN es ahora **COORDINACIÓN-24** (`session_01MwmK2hVdDLULexk6bBGVwA`). softmac PR #688
(borrador; `build.sh`, docs, herramientas): lo vigila MOTOR-43 hasta archivarse; si sigue abierto, suscríbete tú.

**Hecho (detalle en `version-2.7.0.md`):** Blink 128 frente a la API de V8 13.8 = sin cambios de código; dependencias de
la 13.8 (dragonbox nuevo, simdutf 7.0.0, Temporal apagado: pasos para LOCAL en `version-2.7.0.md`, porque LOCAL no usa
`build.sh`); `progress()` con comas y recorte, `abs()`/`sign()` stable (con `media-progress`/`container-progress` en
banderas propias experimentales, como la 138); `ViewportSegments` (`window.viewport.segments`). `fuera.py` en verde.

**Pendiente, por orden:**
1. **Decidido (COORDINACIÓN-24, 02-11 12:43):** `sibling-index()`, `stretch` y la alineación OOF quedan fuera de la 2.7.0 y
   sin 2.7.1: «Aplazado del 138» al principio del 139 (`version-2.7.0.md`). La 2.7.0 declara 138. #688 fusionado.
2. **Integrity-Policy** (sin empezar en la rama): 9 commits, en orden 629b69e78b66, 93d38b50a171, 55bf0d1e8373,
   4458c6764c68, 5ba6c5d0df66, f8e3fd713bce, 227488522951, e9e51b382825, 7d991745c7df (~900 líneas; mirar si b3eedf580,
   «Remove require-sri-for», hace falta antes). `portar128g.sh ip <shas completos>` da **26 `.rej` (~35 hunks)**: los más
   gordos `content_security_policy.cc` (5), `policy_container_host.cc` (4), `blink/public/mojom/BUILD.gn` (4); el resto de
   1–2 hunks (cargador de Blink, `http_parsers.cc`, `navigation_request.cc`, `parsed_headers.cc`, service workers). El
   `web_feature.mojom` (5557 `kIntegrityPolicyInServiceWorkerResponse`) en su sitio numérico (`enumorden.py`).
   `fieldtrial_testing_config.json` y `audit_non_blink_usage.py`: soltar. Cuidar las anulaciones de Brave en
   `content/` y CSP.
3. Lote B2/B3 del inventario (`motor-niveles.md` § «Nivel 138» §3), WebCodecs orientation, letter-spacing en cursiva.
4. Declaración 138 (`config.gni`: 138.0.7204.185, `flyweb_version` 2.7.0, `platformVersion` 11.7.10), `motor-138.html`
   (incluir `progress(…, …, …)`, `abs()`/`sign()`, `window.viewport.segments.length === 1`), `api128.sh`, `enumorden.py` y
   `fuera.py` sobre todo lo tocado desde 480f7362, y avisar a COORDINACIÓN-24.

**Entorno** (se pierde con el contenedor): brave-core con `git clone --filter=blob:none -b nube/motor-138`; V8 en
`/home/user/v8` (`fetch --filter=tree:0 --depth=1 origin tag 13.7.152.17 tag 13.8.258.30`); Chromium tree:0 en
`/home/user/chromium/chromium` (+ enlace `hist`) con los tags y, para `--grep`, `git fetch --filter=tree:0
--shallow-since=2024-11-10 origin tag 138.0.7204.185` (2 min). **No** `sparse-checkout` de Chromium (se corta a los 10
min): `cr128` por `+archive` (README de `FlyWeb/tools/port`, «Sin historia local»), enlazado en
`/tmp/claude-0/port/cr128`. Herramientas: `cp FlyWeb/tools/port/* /tmp/claude-0/port/`; para portar, `portar128g.sh`.
Ojo: el límite semanal de la cuenta estaba en aviso (`allowed_warning`, se reinicia el 03-11 09:00).

---

# Relevo de MOTOR: de MOTOR-42 a MOTOR-43 (02-11-2026, ~11:05 UTC)

MOTOR-42 (`session_01MwmK2iD1rP6o3BQysRiiGF`, Opus 5.5, medio). FM.53, nivel 138 = 2.7.0. **brave-core `nube/motor-138` =
ae7e11c1** (sobre `local/261-arreglos` 480f7362). Sin compilar. Plan de Titín (02-11, 10:50): el 138 completo a ritmo normal,
sin esperar al reinicio del límite; a COORDINACIÓN solo hitos (rama y commit, `enumorden.py`/`fuera.py` en verde, lo que queda).

**Hecho (detalle en `version-2.7.0.md`):** aplazado del 137; `MediaSourceNewAbortAndDuration`; contenido mixto (anulación de
Brave con firma nueva y gancho `.onion`); `QuotaExceededError`; **V8 13.8.258.30** (ae7e11c1: 189 parches rehechos, 27
borrados por estar ya upstream, época 29; `FLYWEB-SECURITY.md` § «Level 138»).

**Para MOTOR-43, por orden:**
1. **Blink frente a la API de V8 13.8** (sin hacer): `String::Utf8Value` pierde `WriteOptions`; `GetIsolate()` pasa a
   `DEPRECATE_SOON` (avisos apagados en `build.sh`); `ContinuationPreservedEmbedderDataV2`; `api-macros.h` borrado.
   Trampas de V8 nueva (`TRAMPAS.md`, MOTOR): diff de `src/api/api.cc` (`CHECK`/`ApiCheck` nuevos: el subagente vio
   «Unaligned pointer» y sandbox) contra los IDL de la 128; `read-only-promotion.cc` sin cambios; sin `weak`/`dlsym`/
   `__builtin_available` nuevos. `kUseContextSnapshot` pasa a ENABLED en la 138: no encenderlo sin mirar la snapshot de
   Blink 128. Mirar también si V8 13.8 pide otra versión de simdutf, highway o fast_float (DEPS de la 138).
2. **7 parches de V8 con conflicto: los rehace SEGURIDAD-PORTES** (la abre COORDINACIÓN en paralelo sobre esta rama); no
   duplicar. Lista en `FLYWEB-SECURITY.md`.
3. **Blink del 138:** `sibling-index()`/`sibling-count()` con `progress()`/`abs()`/`sign()` (b9417dbcfe2, 0f954c71f10 y la
   infraestructura de cálculo sin resolver; d0e9a0c212a, d9d9e83174e, 59d393acd31, c82e4ff1304, 02c0f691ed2…), `stretch`
   (+`LayoutFlexNewStretch`), `CSSAlignBlockAndInlineOutOfFlows` con `LayoutJustifySelfForBlocks`, lote de arreglos
   nacidos stable, WebCodecs orientation, `IgnoreLetterSpacingInCursiveScripts`, `ViewportSegments` (ae78afaca30 +
   9ea51ed248c + fc24d6c7278), Integrity-Policy (629b69e78b66, 93d38b50a171, 55bf0d1e8373, 4458c6764c68, 5ba6c5d0df66,
   f8e3fd713bce, 227488522951, e9e51b382825, 7d991745c7df; parte en `services/network` y `content`). Lista y commits en
   `motor-niveles.md` § «Nivel 138» (inventario de un subagente: comprobar cada «flip sin código», que no siempre lo son).
4. Declaración 138 (`config.gni`: 138.0.7204.185, `flyweb_version` 2.7.0, `platformVersion` 11.7.10), `motor-138.html`,
   `api128.sh`, `enumorden.py` y `fuera.py` sobre todo lo tocado, y avisar a COORDINACIÓN.

**Entorno que hay que rehacer** (el contenedor de MOTOR-42 se pierde): clon de brave-core; Chromium `--filter=tree:0` con
los tags 128.0.6613.138, 137.0.7151.122 y 138.0.7204.185 en `/home/user/chromium/chromium` (+ enlace `hist`; `gc.auto 0`,
que si no hace gc en cada `git show`); V8 en `/home/user/v8` con `git fetch --filter=tree:0 --depth=1 origin tag
13.7.152.17 tag 13.8.258.30`; `FlyWeb/tools/port/*` copiado a `/tmp/claude-0/port/`. `git log` con rutas en el clon tree:0
no acaba: usar `--grep`. `portar128.sh` + a mano + `generar128.sh` funcionan como siempre; `jsonflip.sh` para encender
banderas.

---

# MOTOR-42 (02-11-2026, ~11:30 UTC)

MOTOR-42 (`session_01MwmK2iD1rP6o3BQysRiiGF`, Opus 5.5, medio). Fila FM.53 (nivel 138 = 2.7.0). **brave-core
`nube/motor-138` = 5a86f3aa** sobre `local/261-arreglos` 480f7362. Sin compilar. Detalle en `version-2.7.0.md`.

**Hecho:** aplazado del 137 (kReadingOrder ordenado, Caret, Textarea; Blob URL no se porta, prueba
`tools/blob-particion.html`; bit 0 de canvas-float16 sin causa, la página ahora informa del caso). Inventario del 138 en
`motor-niveles.md` § «Nivel 138» (138.0.7204.185, V8 13.8.258.30). Tanda de hoy: `MediaSourceNewAbortAndDuration`,
contenido mixto con el gancho `.onion` de Brave 1.80, `QuotaExceededError`.

**Para mañana (después del reinicio del límite, 03-11 09:00), por orden de COORDINACIÓN-23:**
1. V8 13.8.258.30: 44 de 252 parches de `patches/v8` no aplican (lista al final de «Nivel 138»); época de caché nueva;
   `Utf8Value` sin `WriteOptions`; mirar `kUseContextSnapshot` (pasa a ENABLED en la 138) con la snapshot de Blink 128.
2. Blink: `sibling-index()`/`sibling-count()` + `progress()`/`abs()`/`sign()` (infraestructura compartida), `stretch`,
   lote de arreglos nacidos stable, WebCodecs orientation, letter-spacing en escritura cursiva, `ViewportSegments`,
   Integrity-Policy (función entera).
3. Declaración 138, `motor-138.html`, Root Store v23 y CT 59.19 (servidor), FS del 138 (la abre COORDINACIÓN).

**Entorno:** clon de Chromium `--filter=tree:0` en `/home/user/chromium/chromium` (con `hist` enlazado; `gc.auto 0`; tags
128, 137 y 138); `git log` con rutas es lentísimo, usar `--grep`. Herramientas de `FlyWeb/tools/port` copiadas a
`/tmp/claude-0/port`; `FlyWeb/tools/port/jsonflip.sh` (nuevo) cambia el estado de una bandera en el parche del json5.

---

# MOTOR-41 (31-10-2026, ~09:00 UTC)

MOTOR-41 (`session_01MwmK2mMB5MqP7H57sSZJRD`, Opus 5.5, medio). **`nube/motor-137` = 1644d954** = 8e726aad +:
- **8044f254**, regresiones de anchor de la 2.5.0 (9 WPT de LOCAL-14): causa en dff03148, no en la consulta stitched
  (`anchor_query_map.cc`, `anchor_evaluator_impl.cc` y `fragment_builder.cc` cuadran con el 136), sino `Finalize()` metido
  por fuzz dentro del bucle de DCHECK de `BoxFragmentBuilder::ToBoxFragment`. En Release no se llamaba, y los builders que
  no pasan por `HandleOofsAndSpecialDescendants` (cajas inline, columnas) no vaciaban
  `children_with_size_dependent_propagation_`. Una línea; sirve igual para una 2.5.x. Sin compilar.
- **1644d954**, cookies `fw1` (diseño de MOTOR-40, arriba): `UndecryptableFw1Row` con la clave de `cookies_unique_index`,
  borrado por fila tras el bucle; si falla, se cae al borrado del grupo de upstream. Test
  `UndecryptableFw1DropsOnlyItsRow` (fila `fw1` ilegible → queda la otra; fila sin prefijo ilegible → se va el grupo).
- `fuera.py`: aviso de línea metida en un bucle. Sobre los 435 parches C++ tocados desde d39510860~1: 11 avisos, todos
  adaptaciones a mano (flex de la 2.1.1, `struct OofData`, `MaybeLogUnsupportedGradientInterpolationSpaceWarning`,
  `ConsumeUnparsedValue`, el `#if` de `login_database_async_helper.cc` de 8ef2fe9cd5).

**Pendiente para MOTOR-42:** lo de la sección de MOTOR-40 (escapes Caret/Textarea según COORDINACIÓN, FS del 137) y lo
que devuelva LOCAL de la 2.6.0.

---

# Añadido de MOTOR-40 tras el relevo (30-10, ~20:40 UTC)

**`nube/motor-137` = 8e726aad**: 78237a70 + merges de `local/250-arreglos` (8ef2fe9cd5 puente de sync de contraseñas,
aaaaef17; 8bec0800e4 sin su parche de V8 13.6, 24c781f6; 096c7d72f0 contraseñas nuevas en `fw1`, 127fd8bb) + `nube/fw1-no-borrar`
ddd9687f (no borrar contraseñas `fw1` ilegibles en la fusión de sync). Detalle de los cuatro en `version-2.5.0.md` y
`fw1-receta.md` § 6 bis.

**Tarea para MOTOR-41 (COORDINACIÓN-22, 30-10): cookies `fw1` ilegibles, parche nuevo para el 137 (2.6.0), no para la 2.5.0.**
Fichero `net/extras/sqlite/sqlite_persistent_cookie_store.cc` (sin parche en FlyWeb). Hoy, en `MakeCookiesFromSQLStatement`,
un `DecryptString` fallido pone `ok = false` y `LoadCookiesForDomains` borra todo el eTLD+1 (`DELETE FROM cookies WHERE
host_key = ?`). Diseño (~30 líneas):
1. `MakeCookiesFromSQLStatement` recibe un `std::vector<…>& undecryptable_fw1` (la clase `Backend` está en el `.cc`, sin
   cabecera que tocar). Si el descifrado falla **y** `encrypted_value` empieza por `"fw1"`: guardar la clave única de la
   fila (columnas 1 `host_key`, 2 `top_frame_site_key`, 19 `has_cross_site_ancestor`, 3 `name`, 5 `path`, 15
   `source_scheme`, 16 `source_port`; comprobar el índice `UNIQUE` del esquema de la 128 en `CreateV*Schema`), registrar
   `COOKIE_LOAD_PROBLEM_DECRYPT_FAILED` y `continue` **sin** `ok = false`. Las `v10` ilegibles siguen como upstream.
2. En `LoadCookiesForDomains`, tras el bucle y antes de mover `cookies`, borrar solo esas filas con un `DELETE … WHERE
   host_key = ? AND top_frame_site_key = ? AND has_cross_site_ancestor = ? AND name = ? AND path = ? AND source_scheme = ?
   AND source_port = ?` (fuera del bucle de `Step()`, no con la sentencia de lectura abierta).
3. Así se mantiene lo que busca upstream (nada sin cargar queda en la base: sin choque de unicidad en CookieMonster).
4. Prueba: `sqlite_persistent_cookie_store_unittest` con un `CookieCryptoDelegate` falso que falle solo con el prefijo
   `fw1`; y LOCAL: ítem `fw1` corrupto, un dominio con una cookie `fw1` y otra `v10` → la `v10` sigue.

---

# Relevo de MOTOR: de MOTOR-40 a MOTOR-41 (30-10-2026, ~18:40 UTC)

MOTOR-40 (`session_01MwmK2iVFAmrfVgo2rCH32r`, Opus 5.5, medio). Nivel 137 = 2.6.0 (FM.52), **declarado y sin compilar**.
Docs en softmac PR #653 (draft, rama `claude/fm52-motor40`).

**Rama:** brave-core **`nube/motor-137` 78237a70** = d7ad12b4b + 39ed9287 (notas de seguridad) + f52504fe/94a1c75d (canvas
float16, también en `nube/canvas-float16`) + d9aa0b6c (declaración 137.0.7151.122 / 2.6.0) + 78237a70 (cuatro escapes).

**Hecho:** `nube/float16-abv` entra en la 2.5.0 (decisión de COORDINACIÓN-22; LOCAL tiene la orden). Banderas de gin
`using`/`RegExp.escape`: sin riesgo de `NOTREACHED` (sin tipos públicos nuevos en V8 13.7; detalle en
`patches/v8/FLYWEB-SECURITY.md`; no probado en un renderer). **Canvas float16** con farbling de 16/32 bits (tabla «Hecho por
MOTOR-40» en `motor-niveles.md` § 137; prueba `FlyWeb/tools/canvas-float16.html`). `motor-137.html` y «Para la web» de
`version-2.6.0.md`. Escapes del 137 (flags que nacen stable y faltaban): 4 portados, 3 pendientes (tabla en
`motor-niveles.md`).

**Para MOTOR-41, por orden:**
1. Errores de LOCAL de la 2.5.0, si llegan, antes que nada.
2. Respuesta de COORDINACIÓN a la propuesta de escapes (enviada ~18:35): `CaretWithTextAffinityUpstream` (1–2 h; `editor.cc`
   sin parche + `insert_text_command.cc`) en la 2.6.0 si hay margen; `TextareaStableResizing` (3–5 h; choca con los parches
   de `paint_layer_scrollable_area.cc` y `pointer_event_manager.cc`) a la 2.6.x; `LineBreakEarlyReturn` no.
3. Con eso, inventario cerrado → **avisar a COORDINACIÓN para la FS del 137**. Focos: `reading-flow`, `css_if_parser`/
   `style_cascade`, `mouse_event_manager`, `match-element` en el tracker de VT, Root Store v19, `nube/float16-abv`, canvas
   float16 (`image_data.cc`, bindings y `brave_session_cache.cc`), `ViewTransitionUpdateLifecycleBeforeReady` (llama al
   ciclo de vida desde `ProcessCurrentState`), JSPI/`wasm_deopt`.

**Entorno nuevo:** área de trabajo ligera sin el clon de historia de Chromium: ficheros de la 128 con `curl` de
`raw.githubusercontent.com`, parches de la rama con `git apply`, diffs de upstream con `+/<sha>%5E%21/?format=TEXT` y
`git apply --reject`; los `.patch` se regeneran en un repo aparte con la 128 pura (`git diff --full-index`). Clon parcial
de Blink 128 para grep (~2 min con `--filter=blob:none` y sparse de `*.cc/*.h/*.idl/*.gni/*.json5`). gitiles `+log` y la
API de GitHub no van desde aquí.

**Trampas:** el farbling de Brave trata cualquier búfer como RGBA de 8 bits; `toDataURL`/`toBlob` conservan el tipo de color
del canvas (F16), no solo `getImageData`. En `html_canvas_element.cc` los bytes por canal se deducen del tamaño del búfer
(`ImageDataBuffer` no da el tipo): con relleno de filas grande caería al modo de 8 bits. En la 128 los setters de
diccionario con enum aceptan `String` (`setColorType(GetPixelFormatAsString())`). 0ec01412973 toca también
`interface.py` (sobrecargas), `ir_builder.py` y `pass_as_span.h`: no basta con `idl_type.py`.

---

# Relevo de MOTOR: de MOTOR-39 a MOTOR-40 (30-10-2026, ~18:55 UTC)

MOTOR-39 (`session_01MwmK2hdYTX8ZHAYfhDFaaY`, Opus 5.5, medio). Nivel 137 = 2.6.0 (FM.52), **sigue sin compilar**. Hecho:
tabla «Hecho por MOTOR-39» en `motor-niveles.md` § «Nivel 137». Docs en softmac PR #652 (draft; COORDINACIÓN lo saca de
borrador y lo funde con el aviso para la FS cuando el inventario esté cerrado).

**Rama:** brave-core **`nube/motor-137` d7ad12b4b** = 5abcd0cc + merge de los arreglos de LOCAL-14 de la 2.5.0 (44d92a8611)
+ `EnterInOpenShadowRoots` + Root Store v19 + VT `match-element` + merge de `nube/float16-abv`.

**Urgente, ya avisado a COORDINACIÓN:** `nube/float16-abv` **f7a89181a** (sobre 44d92a8611): con `--js-float16array` (gin,
desde la 2.4.0) un `Float16Array` pasado a una API de Blink (`crypto.getRandomValues(new Float16Array(4))`) llegaba al
`NOTREACHED_IN_MIGRATION()` de `ToDOMArrayBufferView`, **fatal en la 128** → caída del renderer. Arreglo = parte de la 130
(`DOMFloat16Array`, `kTypeFloat16`, `ABVTrait`, `ReadableByteStreamController`). Debe entrar en la 2.5.0 o una 2.5.1:
decide COORDINACIÓN.

**Para MOTOR-40, por orden:** respuesta de COORDINACIÓN sobre `nube/float16-abv` y errores de LOCAL si llegan;
**canvas float16** (COORDINACIÓN-22: adelante, **límite 4 h**; si el farbling de 16 bits se complica, parar y avisar);
declaración 137.0.7151.122 en `build/config.gni` y `version-2.6.0.md` § «Para la web»; cerrar el inventario y avisar a
COORDINACIÓN para la FS del 137 (focos: `reading-flow`, `css_if_parser`/`style_cascade`, `mouse_event_manager`, y ahora
`match-element` en el tracker de VT, Root Store v19 y `nube/float16-abv`).

**Plan de float16 (A06):**
1. Tipo IDL `Float16Array` (parte de la 136, entre 135.0.7049.114 y 136.0.7103.113): `bindings/scripts/web_idl/idl_type.py`,
   `bind_gen/blink_v8_bridge.py` (`'Float16Array': 'unsigned short'`), `bind_gen/union.py` e `INSTANTIATE_NVT(…DOMFloat16Array)`
   en `native_value_traits_buffer_sources.cc`. Hace falta porque `image_data.idl` de la 137 lo nombra.
2. ImageData con Float16Array: 11ddbcdbe, 5177673d2, b188c95c0 + ba1f99c0b (separar flags), d0f5f58ca, el renombrado
   `storageFormat`→`pixelFormat` (`rgba-unorm8`/`rgba-float16`/`rgba-float32`) y el del contexto 2D (`colorType`,
   `unorm8`); flip 0d364e3a8 (`CanvasFloatingPoint`) e `ImageDataPixelFormat` stable. Los sha del renombrado no están:
   sacarlos comparando el IDL de 135/136/137 (googlesource `+log` da 403; `+/<sha>%5E%21/?format=TEXT` sí funciona).
3. **Farbling:** `BRAVE_GET_IMAGE_DATA` (`chromium_src/…/base_rendering_context_2d.cc`) pasa `GetSkPixmap()` a
   `PerturbPixels`, que trata los datos como RGBA de 8 bits (`pixel_count = size / 4`, XOR del bit 0 de un byte). Con
   float16 tocaría bytes altos (exponente) y el alfa. Hace falta una variante por tipo de color: en float16, XOR del
   bit 0 de la mantisa de R/G/B (`uint16_t`, 4 canales por píxel); en float32, igual sobre `uint32_t`. Misma semilla HMAC
   (sobre los bytes) para que sea estable por sitio. Prueba (decisión del 30-10): dos lecturas en orígenes distintos dan
   valores distintos, y dos en el mismo, iguales. Revisar también `toDataURL`/`toBlob` (no cambian: siguen en 8 bits).

**Herramienta nueva:** `FlyWeb/tools/port/fuera.py` (trozos fuera de su función; README). Pasada sobre los 122 parches
C++ que cambian desde 3e8c8e219a: 0 fallos (los 5 avisos que quedan son adaptaciones propias de FlyWeb). Pasarla antes de
cada entrega. No detecta APIs del 13x ni includes que falten: eso sigue siendo la compilación.

**Entorno:** como MOTOR-38, más: ficheros sueltos de Chromium con `curl` de `raw.githubusercontent.com/chromium/chromium/<tag>/…`;
diffs de un commit con `https://chromium.googlesource.com/chromium/src/+/<sha>%5E%21/?format=TEXT` (base64) y sus metadatos
con `+/<sha>?format=JSON` (quitar `)]}'`). Clon parcial de Blink 128 para grep: `git init`, `sparse-checkout --no-cone
'/third_party/blink/renderer/**/*.cc'` (y `.h`), `fetch --depth 1 --filter=blob:none origin tag 128.0.6613.138` (~5 min).
Conflictos de parche sobre parche: resolver en fuente (base + cada lado, `git merge-file`, regenerar con
`git diff --full-index`), no a mano en el `.patch`.

**Trampas:** a una sesión local (LOCAL) no se le puede escribir desde la nube (`send_message` da
`elevated_session_untrusted_device`): ir por COORDINACIÓN y **no** llamar a `confirm_repository_trust`. Un `NOTREACHED_IN_MIGRATION()`
de la 128 es fatal en release (`kNotReachedIsFatal`): cualquier ruta nueva de V8 que caiga en uno es un crash.

---

# Relevo de MOTOR: de MOTOR-38 a MOTOR-39 (30-10-2026, ~18:10 UTC)

MOTOR-38 (`session_01MwmK2ktzERuU6NyME2Zeyq`, Opus 5.5, medio). Nivel 137 = 2.6.0 (FM.52), **sigue a medias, sin
compilar**. Hecho: `if()`, `reading-flow` y selección en Shadow DOM (tabla «Hecho por MOTOR-38» en `motor-niveles.md`
§ «Nivel 137»; riesgos de compilación en `version-2.6.0.md`). Sin errores de LOCAL de la 2.5.0; el informe de la d8 13.7 llegó
al final (abajo).

**Rama:** brave-core **`nube/motor-137` 5abcd0cc** (`git ls-remote` comprobado). La d8 13.7 pedida con cc6ec885 sigue
valiendo (nada nuevo toca V8).

**d8 13.7:** verde salvo `mjsunit/maglev/extras-cped` (detalle y cifras en el punto 1 del pendiente).

**Para MOTOR-39, por orden:** errores de LOCAL de la 2.5.0 si llegan; explicar `maglev/extras-cped` (¿parche que apaga
Maglev? si no, error nuestro y va primero);
`EnterInOpenShadowRoots` (punto 0 del pendiente); después los puntos 5–10 de MOTOR-37 (VT `match-element`,
`SvgTransformOnNestedSvgElement`, float16 con farbling, DIP en Brave 1.79, FS del 137, declaración, Root Store v19). Al
cerrar el inventario, avisar a COORDINACIÓN para la FS del 137 (regla 17; esta vez además: foco de `reading-flow`,
`css_if_parser`/`style_cascade`, `mouse_event_manager`).

**Entorno:** igual que la nota de MOTOR-37, pero `brave-core` hay que añadirlo con `add_repo` **antes** del primer push
(sin eso el proxy da 403). `mkws128.sh` + `run.sh` (paso a paso) funcionó bien para `reading-flow` y selección.

**Trampas:** `run.sh` arranca por el asunto del último commit del área; tras un `add128.sh` (commit «add») vuelve a
empezar la lista: renombrar ese commit con el sha del paso (`git commit --amend -m <sha>`). Si un commit mete una flag que
otro de la misma cadena quita después (aquí `MouseFocusFlatTreeParent`, `SelectionOnShadowDOMWithDelegatesFocus`,
`DelegatesFocusTextControlFix`), escribir directamente la forma final de la N en vez de portar la flag.

---

# Relevo de MOTOR: de MOTOR-37 a MOTOR-38 (30-10-2026, ~17:30 UTC)

MOTOR-37 (`session_01MwmK2kqGynL4v3YaYFNuLL`, Opus 5.5, medio). Nivel 137 = 2.6.0 (FM.52), **a medias, sin compilar**.
Hecho y pendiente, con commits: `motor-niveles.md` § «Nivel 137» (tabla «Hecho por MOTOR-37» y «Pendiente del 137», por
orden); dónde puede fallar: `version-2.6.0.md`. Los tres inventarios y el cruce están copiados tal cual.

**Rama:** brave-core **`nube/motor-137` dea5f3eb** (`git ls-remote` comprobado), sobre `local/250-arreglos` 3e8c8e219a.
d8 13.7 pedida a COORDINACIÓN con cc6ec885 (los commits posteriores no tocan V8).

**Para MOTOR-38, por orden:** errores de LOCAL de la 2.5.0 si llegan; informe de la d8 13.7; decisiones del 30-10 ya tomadas
(JSPI y Wasm como Chrome 137; Maglev apagado; `ReduceScreenSize` no; float16 solo con farbling probado; Blob URL y
`DocumentIsolationPolicy` en una 2.6.x propia, DIP solo si Brave 1.79 no la apaga: detalle en `version-2.6.0.md`); avisar a
COORDINACIÓN cuando el inventario esté cerrado para que abra la FS del 137; después `if()` (con el plan escrito: parsers de la 128 por rangos), `reading-flow`, `getComposedRanges`.

**Entorno (~10 min):** clon `--depth 1 --branch nube/motor-137` de brave-core; historia ligera de Chromium con
128.0.6613.138, 135.0.7049.117, 136.0.7103.116 y 137.0.7151.122 (`--shallow-since=2024-06-01`, ~20 s;
`log128-137.txt`, `log136-137.txt`); `mkcr.sh` de cr128, cr136 y cr137; `/home/user/v8` con los tags 13.6.233.10 y
13.7.152.17 (`v8chk.sh 13.7.152.17` debe dar 240/0). Herramienta nueva: `ok0.sh <área> <commit>` (paso vacío o con los
rechazos descartados, para que `run.sh` no repita el commit).

**Trampas:** en una cadena larga sobre código muy divergente (`if()` en `style_cascade.cc`), `runfz.sh` mete hunks con
fuzz 3 **fuera de la función** (la rama `kIf` cayó entre la firma y el cuerpo de `ResolveTokensInto`, y el hunk de
`ResolveAutoBaseInto` reindentó `ResolveAttrInto`): si la cadena rechaza mucho, mejor ficheros nuevos de la N + integración a
mano. `generar128.sh` sobre un área montada antes de un commit de otra área pisa sus parches: montar cada área después
del commit anterior. `ok1.sh` falla con un paso vacío y `run.sh` vuelve a aplicar el mismo commit: usar `ok0.sh`.

---

# Relevo de MOTOR: de MOTOR-36 a MOTOR-37 (30-10-2026, ~14:30 UTC)

MOTOR-36 (`session_01MwmK2h2ofiEWbnPrXRaVMa`, Opus 5.5, medio). Nivel 136 = 2.5.0 (FM.51): **código terminado y entregado
a LOCAL**, sin compilar. Qué entra y qué no, por commit: `motor-niveles.md` § «Nivel 136» («Hecho por MOTOR-36»); dónde
puede fallar y lo que se dejó fuera: `version-2.5.0.md`.

**Rama:** brave-core **`nube/motor-136` 1747f79f** (`git ls-remote` comprobado), declaración 136.0.7103.116 / 2.5.0. Orden a
LOCAL: `buzon/LOCAL/20261030-1430-MOTOR-36.md` (`FLYWEB_BUILD_NUMBER` 37). Página: `FlyWeb/tools/motor-136.html`.

**Para MOTOR-37, por orden:** errores de LOCAL; informe de la d8 13.6 (D8-LINUX, vía COORDINACIÓN); WPT y
`motor-136.html` frente a CfT 136; **`PartitionVisitedLinkDatabaseWithSelfLinks`** (Titín dijo sí el 30-10; punto 5 de
«Pendiente del 136»). `v8-d8.sh` con el toolchain de la 128 en el PR #642: cuando esté en `main`, COORDINACIÓN
pasa a D8-LINUX el encargo de d8 13.6 con ese sha.

**Entorno:** como MOTOR-35 (clon `--depth 1 --branch nube/motor-136`, historia ligera con los tags 128/135/136, `mkcr.sh` de
cr128 y cr136). Herramientas nuevas en `FlyWeb/tools/port/`: `runfz.sh <área> <lista>` (= `run.sh` + `fz3.sh` en cada
parada), `ap3.sh <área> <commit>` (fusión a tres bandas con `git merge-file` usando c^ y c de la historia ligera: lo que
mejor aguanta refactors), `cres.py <fichero> fw|up|both|@texto…` (resuelve sus bloques en orden) y `pres.sh <commit>…`
(¿ya está en FlyWeb? `apply --check` inverso y directo sobre `fw/`).

**Trampas:** `fz3.sh` con **fuzz 3** puso tres veces un bloque en otra función (`InitTypes` → `MatchForActiveViewTransitionType`,
`SetContextState` → `GetPeriodicWave`, `AccessNaturalSize` → `ComputeResourcePriority`): revisar **cada** fuzz 3 con
`git show` antes de seguir (ahora en `TRAMPAS.md`). La lista de una cadena se ordena por la posición en `git log`, no por
fecha: el mismo día salen en otro orden (2b756df0e antes que 02cbea125). `skip.sh` hace `git checkout .` y se lleva lo que
no tenga commit. `pres.sh` da «rev≥1» también en commits ya portados con cambios: mirar el código.

---

# Relevo de MOTOR: de MOTOR-35 a MOTOR-36 (30-10-2026, ~13:00 UTC)

MOTOR-35 (`session_01MwmK2iW913S9e7mBCoaYTz`, Opus 5.5, medio). Nivel 136 = 2.5.0 (FM.51), **a medias**. Hecho y
pendiente, con commits: `motor-niveles.md` § «Nivel 136» (tabla «Hecho por MOTOR-35» y «Pendiente del 136», por orden);
dónde puede fallar: `version-2.5.0.md`. Los cuatro informes de inventario están copiados ahí tal cual.

**Rama:** brave-core **`nube/motor-136` 6a78dd41**, sin compilar, sobre `fw1` 841029d2 (que compila LOCAL). Encargo de
d8 13.6 (670f8fa1) a D8-LINUX vía COORDINACIÓN: sus resultados llegarán reenviados. `v8-d8.sh` para 13.5/13.6: PR #639.

**Para MOTOR-36:** la lista «Pendiente del 136» de `motor-niveles.md`. Lo primero, errores de LOCAL y el informe de la d8;
después anchor con scroll (15 escapes) y los 17 escapes sueltos (`wpt-240-causas.md`), y el Blink y la red del 136.

**Entorno (~10 min):** clon `--depth 1 --branch nube/motor-136` de brave-core; historia ligera de Chromium con las tres
etiquetas (128.0.6613.138, 135.0.7049.117, 136.0.7103.116; ~15 s con `--shallow-since=2024-06-01`); `mkcr.sh` de cr128
(y cr136 si hace falta); `/home/user/v8` con `--filter=blob:none` para `patches/v8`. `gd.sh` lee la historia de
`/home/user/chromium/hist`. Herramientas nuevas en `FlyWeb/tools/port/`: `run.sh <área> <lista>` (aplica la lista desde el
último commit del área y para en el primer `.rej`), `skip.sh` (commit vacío `SKIPPED`), `increj.py` (`.rej` que solo
añaden `#include`), `v8res.sh`/`v8edit.sh` (conflictos de `v8re.sh` y editar un parche de `patches/v8` sobre la V8 nueva).

**Trampas:** `v8re.sh` deja **vacío** (no borra) el parche que la V8 nueva ya trae: buscar `[ -s ]` después. En un área,
un `git commit -a` de arreglo con un `.rej` pendiente se lleva los hunks buenos de ese paso y rompe la detección de
`run.sh` (que mira el asunto del último commit): resolver el paso y hacer `ok1.sh` con su sha. Muchos (c) del cruce
dependen de infraestructura del 13x (render-blocking, `length_utils`, invalidación de `currentcolor`, Trusted Types
HTML): con 1–2 pruebas, saltarlos.

---

# Relevo de MOTOR: de MOTOR-34 a MOTOR-35 (30-10-2026, ~10:05)

MOTOR-34 (`session_01MwmK2iZgonNqNG7gUhLD8D`, Opus 5.5, medio). Encargo de COORDINACIÓN-21: primera parte de la 2.5.0
(nivel 136, FM.51) = **`fw1`** (FS.25). Hecho y documentado en [`fw1-migracion.md`](fw1-migracion.md) (código, migración,
pruebas de LOCAL, revisión de la regla 17, «Para la web»).

**Rama:** brave-core `nube/motor-136` = 778fd91ca9 (`local/240-arreglos`, la 2.4.0 publicada) + **841029d2** (`fw1`).
**Subida** el 30-10 ~10:20 UTC tras aprobar Titín `add_repo` con push (`git ls-remote`: 841029d24857). Orden a LOCAL:
`buzon/LOCAL/20261030-1020-MOTOR-34.md` (compilar y §3 de `fw1-migracion.md`, paso 9 obligatorio).

**Para MOTOR-35:** errores de compilación de `fw1` (los probables: `include_rules` de `components/flyweb_os_crypt/DEPS`,
`TestFuture<Encryptor, bool>` con tipo solo movible, `-Wshorten-64-to-32` en las llamadas al llavero). Después, lo que pida
COORDINACIÓN del 136 (inventario, 61 escapes de `wpt-240.md`, wpt.fyi: **no empezar sin orden**, dependen de Titín).
La d8 la compila LOCAL (directiva pendiente de Titín).

**Trampas:** el `++` de los diffs de `.patch` (en `TRAMPAS.md`); gitiles y la API de GitHub de chromium están cerrados
desde la nube, `raw.githubusercontent.com/chromium/chromium/<tag>/<ruta>` sí funciona (sirve para comparar con upstream y
para los `index` de un parche nuevo: `git hash-object` del fichero de la 128).

---

# Relevo de MOTOR: de MOTOR-33 a MOTOR-34 (29-10-2026, ~17:55)

MOTOR-33 (`session_01MwmK2ieXmz6smfcawQxUUY`, Opus 5.5, medio). Nivel 135 = 2.4.0 (FM.50): **opción A terminada y entregada
a LOCAL para compilar**. Detalle por commit: `motor-niveles.md` § «Nivel 135» («Hecho por MOTOR-33»); dónde puede fallar:
`version-2.4.0.md`.

**Rama:** brave-core **`nube/motor-135` ebd8c17f** (135.0.7049.117 / 2.4.0, `FLYWEB_BUILD_NUMBER` 36), sin compilar. Orden
a LOCAL: `buzon/LOCAL/20261029-1753-MOTOR-33.md`. Sha del Blink completo enviado a COORDINACIÓN-20 para la FS de la regla 17.
`chk128.sh 56a99da5`: 93 parches, todos aplican sobre la 128.

**Para MOTOR-34, por orden:**
1. **Errores de compilación de LOCAL primero** (sobre 33a7efd54, 56a99da5 o ebd8c17f). Lo más probable: el parser de
   `shape()` sobre `CSSParserTokenRange` y el renombrado `IsInert` → `IsHTMLInert` (`version-2.4.0.md`).
2. Si SEGURIDAD-PORTES rechaza `:visited` (6eaf6c4d): `git revert` de ese commit solo.
3. Resultados de `motor-135.html` y WPT del 135 frente a Chrome 135: lo que escape, a una 2.4.x o al 136 (regla 18).
4. Fuera de la 2.4.0, por si una web lo pide: `CSSAnchorRememberedScrollOffset`, spanners de `text-box-trim`,
   `preserveAspectRatio` en `feImage`, `CascadedAfterChangeStyle`; y Observable, select personalizable, carousel, FetchLater.

**Trampas:** `bash -c 'until for c in …; do [ -s x ] || exit 1; done; …'` no espera (el `exit` sale del script entero):
bajar los diffs con `gd.sh` en serie. Un par commit + revert (`visibility:inert`) deja restos de formato en decenas de
ficheros: comparar con el commit `bc` del área y devolver los que solo cambian llaves. `FlyWeb/tools/port/fz3.sh <área>`
reintenta los `.rej` con `patch -F3`: mirar dónde cae un fuzz 2–3 en el json5 de flags.

---

# Relevo de MOTOR: de MOTOR-32 a MOTOR-33 (29-10-2026, ~17:20)

MOTOR-32 (`session_01MwmK2iAjgU6zc9yAUN812d`, Opus 5.5, medio). Nivel 135 = 2.4.0 (FM.50), sin terminar. Hecho y
pendiente, con commits: `motor-niveles.md` § «Nivel 135» («Hecho por MOTOR-32» y «Lo que falta… con lo medido»);
faltas del cruce y su coste: `version-2.4.0.md`.

**Rama:** brave-core **`nube/motor-135` 56a99da5**, sin compilar (LOCAL-14 compila 9a54d02992 = 33a7efd54 + su arreglo,
que ya está aquí como 7df1ac0a94). Orden de prueba a LOCAL en `buzon/LOCAL/20261029-1720-MOTOR-32.md`.

**Decisión de Titín (opción A, por COORDINACIÓN-20, 29-10 ~17:15):** la 2.4.0 lleva lo hecho, `shape()`,
`interactivity`, los flips (también `CSSAnchorRememberedScrollOffset` si encaja), las correcciones de edición, las faltas
del cruce y las 4 de red; `AllowSameSiteNoneCookiesInSandbox` solo si pasa la regla 20 (análisis de MOTOR-32 enviado a
COORDINACIÓN: no abre cookies de terceros). **Fuera de la 2.4.0:** Observable, select personalizable, carousel y
FetchLater; se reabren si una web real los pide. Una sola MOTOR sobre la rama a la vez.

**Para MOTOR-33, por orden:**
1. **Errores de LOCAL primero** (directiva del 28-10). Desde la nube no se le puede escribir a LOCAL
   (`elevated_session_untrusted_device`): responder por el buzón y por COORDINACIÓN.
2. Lo que decida COORDINACIÓN sobre el resto del Blink del 135 (propuesta en el informe de MOTOR-32): `shape()`,
   Observable, `interactivity`, select personalizable, FetchLater, anchor remembered offset y las 4 de red. Cada fila con
   su cadena de commits en `motor-niveles.md`.
3. `:visited` (6eaf6c4d) espera la revisión de SEGURIDAD-PORTES: si la rechaza, `git revert` de ese commit solo.
4. Al cerrar: declaración 135.0.7049.117 / 2.4.0 en `build/config.gni` (`FLYWEB_BUILD_NUMBER` 36), `motor-135.html`
   (con `getContext('webgl'/'webgl2')` y `ANGLE_multi_draw`), HSTS/CT, §8.2 de `macos11-niveles.md`, orden final a LOCAL.

**Entorno (herramientas nuevas en `FlyWeb/tools/port/README.md` § «Sin historia completa»):** `mkcr.sh` de cr128 y
cr135 (~1 min cada uno), historia ligera de Chromium (~3 min) y `portgd.sh`/`ap1gd.sh`/`ok1.sh` paso a paso;
`fin133.sh` con `SESION=<id>` genera y hace commit.

**Trampas:** el inventario dio por «flip» o «código ya en el 129–134» filas cuyo código no está en la 128 (ver
«Lo que falta»): mirar `fwf.sh` + `diff fw/X cr135/X` antes de estimar. El run de wpt.fyi incluye funciones
`experimental`. `pkill -f` mata el propio shell. El json5 del 135 tiene entradas con sangría rara (`CorrectStylesForLists`):
`addflag.py` sí las mete bien.

---

# Relevo de MOTOR: de MOTOR-31 a MOTOR-32 (29-10-2026, ~16:10)

MOTOR-31 (`session_01MwmK2jaooqMPoHmosCsL9S`, Opus 5.5, medio; relevo al 38 % de contexto, 24,3 $). Nivel 135 = 2.4.0
(FM.50). Estado y decisiones: `motor-niveles.md` § «Nivel 135»; cruce y coste: `version-2.4.0.md`.

**Rama:** brave-core **`nube/motor-135` 33a7efd54**, sobre 479bcaf1e2, sin compilar. Encima: port de WebGL (9db2c47e3), los
escapes del 134 (619397a95…5a8fe0bb8; falta `highlight-paired-cascade-004`, sin causa), **V8 13.5.212.10** (37c5e8a5e;
`FlyWeb/v8-revision`, los 103 `patches/v8` aplican sobre e2591684) y ALPS/QUIC (33a7efd54). `util.js` aplica ya parches
de `third_party/emoji-segmenter/src` y `net/third_party/quiche/src`.

**Para MOTOR-32, por orden:**
1. **Las 8 faltas del cruce wpt.fyi** (directiva «Las faltas, antes de compilar»; lista en `version-2.4.0.md`): mirar
   antes en la 128 + parches si alguna ya está; `:visited` (b39d6582c8e), a SEGURIDAD-PORTES antes de portarlo. Medir el
   coste del porte (`get_session` antes y después) y anotarlo en `version-2.4.0.md`.
2. **Blink del 135** (orden del informe Blink en `motor-niveles.md`): flips pequeños, `command`, `shape()`, Observable,
   correcciones, select personalizable, `interactivity`, FetchLater (+8a947848b8). El carousel (8–12 h, solo Chrome):
   proponer a COORDINACIÓN si va en una 2.4.x. **Ojo:** los flips no son solo json5: comparar el código detrás de cada
   flag entre la 128 + parches y la 135 (en `/tmp/claude-0/port/diffs/` estaban los de AOM, LogicalOverflow,
   SafeAreaMaxInset, sourceElement y popstate; no persisten).
3. Fuera de Blink: `AllowSameSiteNoneCookiesInSandbox`, `ServiceWorkerSrcdocSupport`,
   `ServiceWorkerClientUrlIsCreationUrl`, `UpdateRequestForCorsRedirect` (código en la 128 o no: comprobar); regenerar
   HSTS/CT; corregir §8.2 de `macos11-niveles.md` (`UTType` es del menú Servicios).
4. Declaración 135.0.7049.117 / 2.4.0 en `build/config.gni` (`FLYWEB_BUILD_NUMBER` 36), `FlyWeb/tools/motor-135.html`
   (incluir `getContext('webgl'/'webgl2')` con `ANGLE_multi_draw`), orden a LOCAL por `buzon/LOCAL/`, FM.50 y
   `send_message` a COORDINACIÓN-20.

**Trampas de esta sesión:** chromiumdash da 403 por el proxy (usar `versionhistory.googleapis.com`); Gitiles por HTTP
sirve diffs con sha completo (`/tmp/claude-0/port/gd.sh` resuelve el corto; ahora en `FlyWeb/tools/port/`);
`chk128.sh` no comprueba los parches de subrepos (emoji-segmenter, QUICHE): comprobarlos a mano; `git grep` sobre
clones sin blobs se cuelga (mató un comando de 2 min).

---

# Relevo de MOTOR: de MOTOR-30 a MOTOR-31 (29-10-2026, ~14:10)

MOTOR-30 (`session_01MwmK2hpaEHYmeX2A1rMrMS`, Opus 5.5, medio; ~17 % de contexto) sacó adelante la **2.3.0** de las dos
caídas del renderer. Se archiva al entregar. Detalle: `version-2.3.0.md`, `caida-230.md`, `wpt-230.md`.

**Estado:** la **2.3.0 entregada por LOCAL-14** (FM.49): brave-core **`nube/motor-134` 479bcaf1e2**, build 35, V8 13.4.114.21;
0 regresiones WPT frente a la 2.1.1. Encima de 858f858dc3:
- **fa6ccf3c76**: caída en el primer `getContext('webgl')`. V8 13.4 (c41f7a0e) hace CHECK en
  `FunctionTemplate::NewWithCFunctionOverloads` si dos sobrecargas rápidas tienen la misma aridad, y los IDL de WebGL de la
  128 ponen `[NoAllocDirectCall]` en pares `Float32Array`/`sequence<>`. Se quitó el atributo de los 30 grupos sobrecargados
  (el compilador de IDL lo exige en todas o en ninguna). LOCAL-14 llegó al mismo árbol (816c878506).
- **479bcaf1e2** (de LOCAL-14): SIGILL en Mojave en toda web con JS. El `SpinningMutex` de la 13.4 pide
  `OS_UNFAIR_LOCK_ADAPTIVE_SPIN` (10.15) a `os_unfair_lock_lock_with_options`; libplatform de 10.14 aborta con `ud2`.
  Antes de 10.15, `os_unfair_lock_lock`.

**Para el 135:**
- **Port de upstream de WebGL:** `nube/motor-134-webgl-up` **8eeb795e9e** = 89faaa39fb47 (M130: `[PassAsSpan]` en uniones
  `sequence<>`/array tipado + IDL con `Float32List`/`Int32List`/`Uint32List`; 10 parches). Recupera las llamadas rápidas de
  WebGL que quitó fa6ccf3c76. Está sobre fa6ccf3c76: hay que **ponerlo sobre 479bcaf1e2** (solo toca IDL y bindings, no
  choca con el parche del mutex). Aplica limpio sobre la 128 y sobre nuestro `bind_gen/interface.py`. Sin compilar. Por
  norma de Titín, no hay 2.3.1: entra con el 135.
- **Escapes WPT del 134** (`wpt-230.md`, decisión de COORDINACIÓN-20: van al 135). Son 16 que fallan siempre;
  `highlight-cascade-010` está descartado (fue un tiempo agotado suelto). Grupos: `font-variant-emoji-*` y
  `variation-sequences` (emoji/VS), `calc()` fuera de rango en `font-weight` (4 pruebas), `@font-feature-values` en la
  serialización, highlight (`css-target-text-decoration-001`, `custom-highlight-painting-below-target-text`,
  `highlight-paired-cascade-004`), `inserthtml` con `<li>`, OffscreenCanvas (`desynchronized` en `getContextAttributes`,
  `direction` heredado al transferir). Del 133 siguen los de flexbox de 1 nivel de color (ANGLE OpenGL, ver TRAMPAS),
  `text-box-trim-*` y `open-pseudo`.
- **Informe de INVESTIGACIÓN-MOTOR-6:** llegará en `FlyWeb/docs/wpt-230-investigacion.md`, con los arreglos de Chrome que
  hay que portar para esos escapes. Leerlo antes del inventario del 135.
- **Maglev sigue apagado** hasta que LOCAL lo mida con la 2.3.0 (JetStream con y sin `--maglev` en la 5,1 y la 6,1).
- **Pendiente de LOCAL, por código limpio:** `d8` mjsunit en la 6,1 y la 5,1 (antes solo en la 7,1) y `atob`/`btoa` largos
  en la 5,1. El barrido de CPU de V8 13.3/13.4 está en `version-2.3.0.md`.
- Descartada y sin uso: `nube/motor-134-scopeinfo` 784d9670b9 (`reuse_scope_infos`; no era la causa).

**Trampas nuevas** (en `docs/TRAMPAS.md`, MOTOR): que `d8` pase no prueba Blink. En cada V8 nueva, diff de `src/api/api.cc`
buscando `CHECK`/`ApiCheck` nuevos y barrido de los IDL de la base; `getContext('webgl')` en la prueba de humo; `grep` de
`__attribute__((weak))`, `dlsym` y `__builtin_available` en `src/base` y `src/libplatform`; `d8` también en la 6,1. Sin
volcado no prueba que el navegador mate al renderer: lldb lo separa (`--renderer-cmd-prefix`).

**Método que funcionó:** V8 completa a la tag por `git fetch --depth 1` de `https://github.com/v8/v8` (googlesource está
bloqueado en la nube); historia de Chromium y V8 con `--filter=tree:0 --shallow-since=…` y `--grep` (nada de `git grep`
sobre árboles sin blobs: tarda minutos). Chromium 128 con sparse-checkout de `third_party/blink/renderer`
(`https://github.com/chromium/chromium`, tag 128.0.6613.138); los parches se generan con `git diff --full-index` sobre ese
árbol.

---

# Relevo de MOTOR: de MOTOR-29 a MOTOR-30 (28-10-2026, ~19:50)

MOTOR-29 (`session_01MwmK2iDD1sWx5FwbmTYa37`, Opus 5.5, medio; ~30 % de contexto) metió `attr()` en el 133 e hizo el
**nivel 134 = 2.3.0**. Se archiva al entregar (directiva de Titín del 28-10). Detalle: `version-2.2.0.md` (§ `attr()`) y
`version-2.3.0.md`.

**Estado de la 2.3.0 (decisión de Titín: se salta la 2.2.0, que no se compila ni publica):**
- Cabeza: brave-core **`nube/motor-134` 858f858dc3**, build 35 = 192ce3e811 (lo que LOCAL-14 compiló y enlazó, con FS.35
  fundida: `seg/fs35-maglev-dead` 0ce38fe7 y `seg/fs35-blink134` c56bbf9b) + 06ed9ecbb6 (`willReadFrequently` booleano,
  el único FALLO de `motor-134.html`). Pendiente: incremental con 858f858dc3 y el resto de pruebas de LOCAL (WPT del 133 y
  del 134, claude.ai, Speedometer, 6,1, 5,1 con simdutf). No reescribir: hay órdenes con esos sha.
- d8 13.4 (LOCAL-14): mjsunit 7584/7585 (`maglev/extras-cped`, la de siempre), `--maglev` 1257/1257.
- `nube/motor-133` se queda en 888963ca5 (2.2.0 + `attr()`) como historia.
- **Maglev apagado**: su deuda (FS.34 + FS.35) está dentro; se enciende solo con la medida de LOCAL en la 6,1 con esta
  build (en la 2.1.1, JetStream se colgaba 5/5 con `--maglev`). Es la línea `maglev` de `src-flags-flag-definitions.h.patch`.
- **6736b12fb2 no se porta** (canvas por software con NVIDIA en Mac; la 128 conserva la ruta antigua). COORDINACIÓN-19
  de acuerdo; probar el canvas en el MacBook Pro 2012 (GT 650M) cuando Titín pueda.

**Si LOCAL trae errores de la 2.3.0:** lo más probable, `html_dialog_element.cc` (17 commits de `closedby` + FS.35),
`pointer_event_manager.cc`, `offscreen_canvas_rendering_context_2d.cc`, simdutf en la 5,1, `v8/src/maglev/*`. Arreglar
encima de 858f858dc3, buzón a LOCAL y sha a COORDINACIÓN (la nube no puede escribir a la 7,1:
`elevated_session_untrusted_device`; no llamar a `confirm_repository_trust`).

**Del 135 no hay nada hecho:** ni inventario ni rama. Mismo método que el 134 (3 subagentes Sonnet: Blink, V8 13.5, fuera
de Blink), pero el informe «fuera de Blink» tiene que partir de que la base sigue en la 128 (el del 134 hablaba de rebasar
parches como si la base subiera). V8 13.5: mirar qué arreglos de la serie de Maglev ya trae (varios son merges a 13.5).

**Herramientas nuevas** (en `FlyWeb/tools/port/`, copiar a `/tmp/claude-0/port/`): `v8regen.sh <ruta> <contenido>`
(rehace un `patches/v8/*.patch` frente a `V8_TO`, por defecto 13.4.114.21), `v8chk.sh [rev]` (`git apply --check` de
todos los `patches/v8`), `fz.sh <área>` (reintenta los `.rej` con fuzz 3 y dice dónde caen). Arreglados: `seq.sh` para con
un fichero que no existe en el área; `generar128.sh` borra el parche de un fichero que vuelve a quedar como en la 128
(dejó 4 parches del taint viejo y la 1.ª Release falló); `chk128.sh` mira la historia en `/home/user/chromium/hist`.
Montaje: `mkcr.sh` de cr128/cr133 (~3 min), historia de Chromium (`fetch --filter=blob:none --shallow-since=2024-06-10` de
los tags) y de V8 (`/home/user/v8`, misma idea con 13.2.152.56, 13.3.415.23, 13.4.114.21).

**Trampas de esta sesión:**
- Una lista de commits heredada puede estar incompleta: antes de una cadena, `git log <primero>~1..<tag> -- <ficheros>`.
- Nunca regenerar desde un área montada antes de otro commit (reescribe ese commit; me pasó probando `generar128.sh`, sin
  llegar a commit).
- `git log -S` y `git grep` en historias sin blobs tardan minutos por consulta: `--grep` del mensaje o `git blame -L` en
  el json5 al tag van en segundos.
- Antes de entregar, barrer con grep las API de la 128 que usa lo portado (COORDINACIÓN lo pide así desde hoy).

---

# Relevo de MOTOR: de MOTOR-28 a MOTOR-29 (28-10-2026, ~10:25)

MOTOR-28 (`session_01MwmK2mPzyrf5do67riZaYB`, Opus 5.5, medio) cerró la **2.2.0** e hizo el inventario del 134. Detalle:
`version-2.2.0.md` y `motor-niveles.md` § «Nivel 134».

**2.2.0 (entregada, sin compilar):** brave-core `nube/motor-133` **2f268ee217** (orden `buzon/LOCAL/20261028-0953-MOTOR-28.md`
y su corrección de las 10:16, build 34). Sobre 426ed3c1: roots 153, c1ff7342 `ClipboardItem`, 8da9f5f3 `text-box-trim`,
merges FS.33 (77caf973 stack clash, 88732b96 Blink) y 2f268ee2 (tres flips del json5 que MOTOR-27 perdió entre commits).
Errores de LOCAL: arreglarlos encima (no reescribir: hay orden con ese sha).

**Siguiente, por orden de COORDINACIÓN-18 (regla 18): la 2.2.1 = `attr()` antes del 134.**
- Rama `nube/motor-133-attr` (sobre 88732b96, no compilable): 5ce740bb = 8 commits de `attr()` (8026a18f3f … 58743c5967);
  59d488dd = 1fc628b444, 0692e7d9b9 (`CSSSyntaxDefinition::Consume`, adaptado: `Parse()` sigue con `CSSTokenizedValue`) y
  8e710e2016 (`TokenSequence` sin `tokens_`; el `AppendFallback` con la marca de taint ya en su forma final).
  **Reponer encima 2f268ee2** (o fundir `nube/motor-133`) antes de seguir.
- **Ojo, cambio de diagnóstico:** la 128+bc **ya trae buena parte** de la migración del parser a streaming (bc tiene 135
  usos de `CSSParserTokenRange` en `css_parsing_utils.cc` frente a 199 en la 128; 9180018ac3 ya está), así que aplicar los
  ~65 commits de la migración entera choca consigo misma (`sp-estado.txt`: 3 ya, 23 aplican, 53 parciales). Vía elegida:
  **solo las dependencias que pide la cadena de `attr()`**. Siguiente paso: 5189858a61 (sintaxis registrada en streaming:
  `CSSSyntaxDefinition::Parse(StringView)` y `CSSVariableParser::ParseDeclarationValue(StringView)`; toca
  `property_registration.cc`, `inspector_style_sheet.cc`, `css_variable_parser.*`), luego 0c00afffe9 y el resto de
  `attr2.txt`: 96a736734d (33 rechazos en el ensayo, el más gordo), c8d50d1a89, 162e74449d, 1bf714b913, 3d832173db
  (flip), 8e507ecf45 (sin `type(<url>)`), 82d879b09e, 0c50bb37c1, ac008e348d. Si alguno pide más migración, portar solo
  esa función. `GetUltimateOriginatingElementOrSelf()` puede faltar en la 128.
- WPT: `css/css-values/attr-*`, `css/css-variables/`, `css/css-properties-values-api/`; `motor-133.html` deja de tener la
  diferencia de `attr()`.

**Después, el 134** (`motor-niveles.md` § «Nivel 134», orden propuesto allí). Lo gordo es Maglev: el subagente de V8 cuenta
40–50 arreglos de deuda (SEGURIDAD-PORTES contó 16–20 hasta la 14.8): cruzarlo con SEGURIDAD-PORTES-11 y COORDINACIÓN antes
de empezar. V8 13.4.114.21: otra vez los 11 solo-LTS (45d40ca20 ya viene) y ea2f03dfff; `simdutf` y `fast_float`.

**Herramientas** (copiar de `FlyWeb/tools/port/` a `/tmp/claude-0/port/`; nuevas: `ap1.sh`, `ok1.sh`, `seq.sh`,
`add128.sh`, `chk27.sh`). Montaje: `mkcr.sh` de cr128/cr133/cr134 (~3 min cada uno) y la historia en
`/home/user/chromium/hist` (`git init`, `fetch --filter=blob:none --shallow-since=2024-06-10` de los tags 128.0.6613.138,
132.0.6834.160, 133.0.6943.141, 134.0.6998.166; ~5 min). Áreas de trabajo: `STEP=1 portar128.sh <área> <commits>` y luego
`seq.sh <área> <lista>` (aplica en orden y para en el primer rechazo; se arregla y `ok1.sh <área> <commit>`).

**Trampas de esta sesión:**
- **Un porte que regenera un `.patch` desde un área montada antes de otro commit borra ese commit.** Le pasó a MOTOR-27 con
  el json5 (3 flips perdidos). Montar cada área justo antes de su commit y, al final, `chk27.sh <desde> <hasta> <cabeza>`.
- Un fichero que se añade a mano a un área: copiarlo de la 128 **y aplicarle su parche de bc** (`add128.sh`). Copiar solo
  la 128 borra lo de bc al regenerar (casi pierdo b94803ac92 en `inline_break_token.h`).
- `fin133.sh` sigue aunque queden `.rej` (generar128 sale con «QUEDAN .rej» y el commit queda vacío): mirarlo.
- `git grep`/`git log -S` en la historia sin blobs descargan mucho: acotar por ruta.

---

# Relevo de MOTOR: de MOTOR-27 a MOTOR-28 (28-10-2026, ~09:35)

MOTOR-27 (`session_01MwmK2iYNS9JSPLVcpxc8mM`, Opus 5.5, medio; ~25 %, 11,7 $) hizo el inventario del 133 (`motor-niveles.md`
§ «Nivel 133», decisiones de COORDINACIÓN-18 en la fila FM.49) y la primera parte del porte. Detalle: `version-2.2.0.md`.

**Cabeza: brave-core `nube/motor-133` 25367508** (15 commits sobre ef850e44, cabeza de la 2.1.1, + merge de `seg/fs33-roots153` 7416f3bd: constante del Root Store a 153.0.8010.0, decisión de Titín). **Pendiente de fundir:** el porte a la 13.3 de v8 ea2f03dfff (stack clash, crbug 574660146) cuando SEGURIDAD-PORTES-11 pase la rama. Titín: `Sec-Fetch-Storage-Access` apagada (definitivo; ya lo está en la red de la 128). Sin orden a LOCAL todavía:
se puede reescribir si hace falta, pero mejor encima. SEGURIDAD-PORTES-11 pone `seg/maglev-134` sobre a833b085 (V8).

**Lo que queda, en este orden** (decisiones de COORDINACIÓN-18): (1) `ClipboardItem` con `Promise<string>` (d72d71316f2,
586423e8031, 887df9720c3): la 128 no tiene `ThenCallable` ni `MemberScriptPromise`; el IDL `record<DOMString,
Promise<(DOMString or Blob)>>` sigue dando `ScriptPromiseUntyped` en la 128, así que es reescribir la conversión de cadena a
`Blob` en `clipboard_item.cc` (`getType`) y `clipboard_promise.cc`/`clipboard_writer` con `ScriptFunction::Callable`;
conservar el `#define WritePlainText` de Brave (`chromium_src/.../clipboard_promise.cc`). (2) `text-box-trim`: 30 commits
8cc53df3787 … 336cc860afc (lista y rechazos de un subagente en `/tmp`, perdidos: rehacer con `git log --grep="text-box"`
en el tramo 47a3549fac1..72dd0b377c0), último y en su commit; sin los de `line-clamp` (7f48814f67f 5c55151b220
adbca44169f) si sigue apagado. (3) `attr()` avanzado (27 commits, núcleo 9edcb63ea87), detrás; si pasa de ~1 día, a una
2.2.x antes del 134. (4) Escapes `flexbox-safe-overflow-position-002/005` si LOCAL los ve en rojo con la 2.1.1. (5)
`motor-133.html`, lista WPT, sección «Para la web», orden a LOCAL por `buzon` y FS.33 avisada.

**Herramientas nuevas** (en `/tmp/claude-0/port`, no persisten; copiar de aquí): `p133.sh <área> <msg> <commits>` =
`portar128.sh` + `fin133.sh` (`generar128.sh`, commit con el trailer, `chk128.sh`); `setflag.py <json5> <Flag> <status>`;
`rejchk.py <.rej>…` (por hunk, cuántas líneas `+` ya están en el destino: separa lo ya portado de lo que falta); `jdiff.sh`
(arreglado para leer la 128 de `cr128`). Los tres scripts están en `FlyWeb/tools/port/` desde este PR.

**Trampas de esta sesión:**
- El clasificador del modo auto denegó `add_repo` con push y luego cualquier orden en el clon de brave-core; Titín lo aprobó
  a mano. No buscar otro canal.
- `portar128.sh` deja fuera `testing/variations/` (fieldtrial): sus rechazos se ignoran.
- Varias flags del 133 ya estaban a medias por portes del 130–131 (`TogglePopoverOptions` de 8010721fc51 sin leer el
  diccionario): tomar la forma final del 133 de cada función en vez de aplicar la cadena commit a commit.
- `<select>` personalizable (`CustomizableSelect`, `StylableSelect`) no está en la 128: los hunks que lo tocan se saltan.
- Un `patch -F3` puede meter un hunk dentro de la firma de una función (`messages.cc` de V8): revisar siempre el fuzz.

---

# Relevo de MOTOR: de MOTOR-26 a MOTOR-27 (28-10-2026, ~08:15)

MOTOR-26 (`session_01MwmK2ifjhdhoUu5VEpAigY`, Opus 5.5, medio; ~32 %) hizo la **2.1.1 = FM.48 + FM.47** (build 33). Detalle,
pruebas y diagnóstico de Futura en `version-2.1.1.md`. COORDINACIÓN-18 la archiva al abrir MOTOR-27.

**Estado de la 2.1.1 (tuya hasta publicar):**
- Cabeza: brave-core **`nube/motor-211b` ef850e44d7** = `local/2.1.1-arreglos` 7078c241 (LOCAL-14: `.c_str()` en
  `root_store_tool.cc`, único error de la 1.ª Release) + b745a4473 (`align-content: safe` con wrap-reverse) + dd784af57
  (revierte el xattr del sandbox) + ef850e44d (FM.47: emparejado que no abandona la familia; Futura caía a Times).
  **Pendiente de recompilar** (orden `buzon/LOCAL/20261028-0811-MOTOR-26.md`, sustituye a la de las 08:05). No se reescribe.
- Si Futura sigue mal: el siguiente sospechoso es el camino por nombre PostScript de `MatchFontFamily` (cuando
  `BestStyleMatchForFamilyNS` da null) y `CanLoadInProcess` de `font_platform_data_mac.mm`; mirar con
  `CSS.getPlatformFontsForNode` qué cara sale.
- Lo único abierto: WPT `flexbox-safe-overflow-position-002/005`. Sobre 7078c241 daban 9/11 escapes en verde, 2877 frente
  a 2876 de CfT 132, sin regresiones. Si con b745a4473c siguen en rojo, COORDINACIÓN-18 dijo: se entrega así y van a la
  2.2.0 (no seguir buscando).
- FM.47: la Futura que fallaba eran maletas Type 1 con resource fork que el renderer no puede cargar (detalle en `version-2.1.1.md`).

**Para el inventario del 133 (sin empezar):**
- Método de MOTOR-25: 3 subagentes Sonnet en paralelo (Blink, V8 13.3, fuera de Blink), cada uno con la lista de commits
  del 133 de su área y la pregunta «qué es Baseline/función nueva, qué flag pasa a `stable`, qué necesita de macOS 10.15+».
  Ellos devuelven conclusiones; el porte y las decisiones, la sesión principal. Inventario de API sin guarda en
  `inventario-129-156.tsv` (INVESTIGACIÓN-MOTOR-5: nada nuevo de 10.15+ en 132–133). Traducciones a 10.14, en la capa de
  compatibilidad (`macos11-niveles.md` §9).
- Flags: comparar el json5 de la 132 con el de la 133 (script de una vez: nombre → `status`); mirar antes en el json5 parcheado
  de bc qué está ya portado (en la 2.1.1 casi todas las del 129–132 que cambiaban algo ya estaban). La referencia es CfT 133
  y el json5 de la Brave de ese nivel (Finch, DIRECTIVAS).
- Trampas nuevas de esta sesión:
  - Los refactors grandes de upstream (flex de septiembre de 2024, longitudes con `SizeType`, era calc-size) **no aplican sobre
    la 128** (22 rechazos en flex). Para un escape, portar la conducta con un cambio pequeño en el código de la 128 y
    buscar **salidas tempranas** de la 128 que la tapen (así se escapó 002/005).
  - Sin flag no se ve en el json5: buscar el commit por la prueba WPT (`git show --name-only` de los candidatos de
    `git log --grep` en `03c1799e6f9..<tag>`); un subagente lo encontró en ~80 s.
  - Un mensaje de commit puede citar mal el sha de upstream (843cac4f citaba 84926a40d7e por 2af3b8d997f): comprobarlo.
  - `chk128.sh` usa `CH=/home/user/chromium`; la historia está en `/home/user/chromium/hist` (googlesource cerrado: espejo de
    GitHub, `tree:0`). Montaje desde cero: `mkcr.sh` de cr128 y cr132 (~3 min) + historia (~5 min).
  - `version.h`/V8 13.3: la regla 18 pide la V8 del 133 en el mismo nivel; FS para sus parches (época nueva).

---

# Relevo de MOTOR: de MOTOR-25 a MOTOR-26 (27-10-2026, ~14:10)

MOTOR-25 (`session_01MwmK2jUhhNQpTHEbCSHDPC`, Opus 5.5, medio; archivada al 51 %) hizo b2, las fijadas en blanco y el
**nivel 132 = 2.1.0** (FM.45). LOCAL-13 lo compila con **build 32** (la 2.0.4 se canceló). Detalle: `version-2.1.0.md`.

**Cabeza: brave-core `nube/motor-132` 78eb79e8** (está en una orden a LOCAL: no se reescribe). Sobre `nube/motor25-p25`
fbe2394fed (2.0.3 + b2 503757bf + fijadas fbe2394f): escapes 7e78e663 (`shape-outside` 129), 33b2a351 (`dir=auto`), 780af58e
(`scrollIntoView`); d10597e6 V8 13.2 en Blink; 89245751, 95eb20ed, 3dcda630, 1ed75fc7, b041904e, 541200a5 (Blink pequeño);
250c23a8 declaración 132.0.6834.160 / 2.1.0; merge FS.27 54b1ae68; 9a8183b0 HSTS localhost; 1c219226 comentario de Maglev;
**fbe98109 `sideways`** (reaplicado sobre el revert b250775d); merges FS.27 ec4d3b86 (475cb03ab90) y FS.28 (`patches/v8`
13.2, 32 parches, época 19, d8 7336/7337).

**`sideways`, adaptados a mano** (la 128 difiere del upstream que esperaban): (1) 9c582c2aea, f9d07c3d30, 187b73019b en
`theme_painter_default.cc`/`theme_painter.cc`: la 128 voltea deslizadores y marcas al revés que el upstream posterior, así
que el volteo va por el final físico de línea (`InlineEnd()`) con el criterio de la 128 (derecha o abajo). (2) 0b24096ebe
en `LayoutBox::LocalCaretRect`: la rama lógica va antes del código físico de la 128, que conserva `extra_width_to_end_of_line`.
(3) f1461a466d: `SerializedAnchor` desde `ScrollAnchorData`, con `scroll_anchor_test.cc`.

**Dónde fallará la compilación, si falla:** `sideways` (35 commits sin compilar: funciones de Blink posteriores a la 128 que
aplicaron sin rechazo pero no existen; buscar el símbolo en `/tmp/claude-0/port/cr128` y en el commit que lo introduce;
último recurso, revertir ec4d3b86 y fbe98109); la serie de `shape-outside` (geometría de `writing_mode_converter`,
`physical_rect.h`, `layout_size.h`); `main_thread_scheduler_impl.cc` (`SetIsLoading`) y `thread_state.cc`; IDB y
`dom_selection.cc` (adaptados). `patches/v8` → SEGURIDAD-PORTES-9.

**Maglev:** se enciende **como tarde en el 134** (Titín, 27-10), con su deuda (~15 arreglos, SEGURIDAD-PORTES) portada y pruebas de rendimiento; la LTS 13.2 no trae esos arreglos.
**133:** el escáner de INVESTIGACIÓN-MOTOR-5 no ve API de 10.15+ sin guarda en 132–133 (`inventario-129-156.tsv`); no
perder las guardas de 13.0 en `vt_video_encode` ni la de 12 en `ca_renderer_layer_tree`. Inventario del 133 sin empezar:
mismo método (3 subagentes: Blink, V8 13.3, fuera de Blink). Traducciones nuevas a 10.14, en la capa de compatibilidad
(`macos11-niveles.md` §9, aprobada). Trampas: `chk128.sh`, un área por commit si tocan el json5, `git log -- ruta` no acaba.

---

# Relevo de MOTOR: de MOTOR-24 a MOTOR-25 (27-10-2026, ~11:10)

MOTOR-24 (`session_01MwmK2jHVmKFgQPPcT5aifq`, Opus 5.5; get_session no da el esfuerzo) hizo la **2.0.3 = -p24** (orden de
COORDINACIÓN-16): tandas 2 y 3 de FM.42, un commit por punto. Detalle y pruebas: `FlyWeb/docs/version-2.0.3.md`. Página de
prueba: `FlyWeb/tools/mojave-203.html`. Se queda quieta tras entregar; la archiva COORDINACIÓN-16.

| Rama de brave-core | sha | Dónde |
|---|---|---|
| `-p24` (2.0.3, build 31) | 23f2d547d9 | **subida a brave-core** desde la nube (`nube/base-128-motor-p24`); también `p24.bundle` en la rama de softmac `nube/motor24-p24` (base -p23 17e7858669) |

**Lo que queda (tuyo):** resultados de LOCAL (`buzon/LOCAL/20261027-1110-MOTOR-24.md`): la prueba previa de b4 con la
2.0.2 (si no hace falta, LOCAL revierte 4e84e03b), errores de compilación (b2 es el de más riesgo: activa
`components/eye_dropper` en Mac) y las pruebas de `mojave-203.html` en la 6,1 y la 7,1. **c3 depende de FS.26**
(SEGURIDAD-PORTES-8): si sale «no apto», se revierte 23f2d547; si «apto con cambios», los cambios van encima. Y lo que quede
de la 2.0.2 (LOCAL-12) si llega tarde: va antes que la 2.0.3.

**Trampas nuevas:**
- **La nube sí puede subir ramas a brave-core** con `add_repo` en modo push: `git fetch --depth=2 origin <rama>` (~30 s) y
  `git push` de la rama nueva encima (pack fino, segundos). MOTOR-23 lo daba por imposible; el bundle queda de respaldo.
- Checkout parcial de la 128 y la 116 (`/home/user/cr128`, `cr116`) con `sparse-checkout add` para los ficheros que no
  entran en el patrón (`BUILD.gn`, `.cc` sueltos): `git sparse-checkout add '/ruta/fichero'`. Antes de editar un fichero que
  ya tiene parche de bc, aplicarlo (`patch -p1`) y luego `git diff --full-index HEAD -- <fichero>`; los nuevos, con
  `git add -N` para que salgan como `new file mode`.
- Para comprobar los parches antes de entregar: copiar cada fichero limpio de la 128 a un directorio aparte y
  `patch -p1 --dry-run` con el parche nuevo.

---

## De MOTOR-23 a MOTOR-24 (27-10-2026, ~10:45)

MOTOR-23 (`session_01MwmK2i3zsbvNZN1DxSpqcF`, Opus 5.5, alto) hizo la **2.0.2 = -p23** (orden de COORDINACIÓN-15): -p21 +
-p22 + arreglo de la mosca de la NTP (FM.43). Detalle: `FlyWeb/docs/version-2.0.2.md` (§6 la antigua 2.0.3, §7 la mosca).
Se archiva tras entregar; MOTOR-24 se abre con los resultados de LOCAL.

| Rama de brave-core | sha | Dónde |
|---|---|---|
| `-p23` (2.0.2, build 30) | 17e7858669 | bundle `p23.bundle` en la rama de softmac `nube/motor23-p23` (base -p22 9b9fdbbd44; lo sube LOCAL) |

**Lo que queda (tuyo):** resultados de LOCAL (`buzon/LOCAL/20261027-1045-MOTOR-23.md`): errores de compilación (sin compilar
en la nube), la medida de GPU de la NTP en la 6,1 frente a la 1.15.2, **F5.3** (si la línea vuelve, se revierte solo
`mosca.tsx`), las pruebas de la -p21 y la -p22 y lo que diga Titín de las capturas (sobre todo «Reducir movimiento»: la -p23
deja la mosca quieta y la 1.15 volaba despacio). Después, la tanda 2 de `mojave-128.md` cuando la apruebe COORDINACIÓN.

**Trampas nuevas:**
- La NTP se prueba fuera del navegador en 2 min: `npm i typescript react react-dom styled-components esbuild` en el scratchpad,
  copiar los `.tsx` de `components/brave_new_tab_ui/components/default/flyweb/`, `esbuild --bundle` y Playwright con
  `Performance.getMetrics` de CDP (`RecalcStyleCount`, `TaskDuration`). Sirve para comparar el hilo principal, no la GPU.
- Una animación CSS de `opacity` sobre trazos de un SVG en línea no va al compositor y obliga a un cuadro del hilo principal
  cada vez. Hay que ponerla en un `div` propio.
- El brave-core de GitHub se baja rápido por sha: `git fetch --depth=1 origin <sha>` (~30 s), y encima los bundles.

---

## De MOTOR-22 a MOTOR-23 (27-10-2026, ~09:25)

MOTOR-22 (`session_01MwmK2hvsFG1TsFqJBFtG6Y`, Opus 5.5, alto) hizo la tanda 1 de FM.42 = **2.0.3**:
`FlyWeb/docs/version-2.0.3.md`. Se archiva tras entregar; MOTOR-23 se abre con los resultados de LOCAL.

| Rama de brave-core | sha | Dónde |
|---|---|---|
| `-p22` (2.0.3) | 9b9fdbbd44 | bundle `p22.bundle` en la rama de softmac `nube/motor22-p22` (lo sube LOCAL) |

**Lo que queda (tuyo):** resultados de LOCAL (`buzon/LOCAL/20261027-0917-MOTOR-22.md`): errores de compilación (sin compilar
en la nube), pruebas de la 6,1 y la 7,1 y el `codesign` de entitlements (d11 lo decide PUBLICACIÓN). Después, la tanda 2 de
`mojave-128.md` cuando la apruebe COORDINACIÓN.

**Trampas nuevas:**
- Chromium compila con `-Wunreachable-code-aggressive` y `-Werror`: un `return` antes del código de upstream no compila
  (comprobado con el clang 18 del contenedor). Hay que dejar el resto en `#if 0` o cambiar un puntero o una condición.
- `git grep <rev>` o `git checkout` de un sparse **muy amplio** sobre un fetch `--filter=blob:none` baja los blobs uno a uno
  y tarda minutos: `sparse-checkout set` solo con los ficheros que hagan falta y `git show FETCH_HEAD:<fichero>`.
- `git ls-tree -r --name-only FETCH_HEAD <dir>` funciona sin bajar blobs: sirve para buscar ficheros.
- Parches en formato bc: aplicar los de bc encima de la 128, editar y hacer `git diff --full-index FETCH_HEAD -- <fichero>`.

---

## De MOTOR-21 a MOTOR-22 (27-10-2026, ~09:20)

MOTOR-21 (`session_01MwmK2iH7RJ3swPYaFxtZPn`, Opus 5.5, alto) hizo el inventario FM.42: `FlyWeb/docs/mojave-128.md`.
**Punto 0:** la línea 263 de `unexportable_key_mac.mm` no se alcanza en Mojave (parche LOCAL-8), así que no hay -p22.
**No se ha portado nada.** Se archiva tras entregar. MOTOR-22 se abre cuando COORDINACIÓN apruebe la tanda 1 de la 2.0.3.

**Lo que queda (tuyo):** la tanda 1 de `mojave-128.md` sobre la rama de la 2.0.2 que haya fusionado LOCAL. Esta sesión no
creó ninguna rama de brave-core. Antes de tocar d1–d4, mira lo que diga LOCAL de
`codesign -d --entitlements :- FlyWeb.app` (fila FM.41). Faltan el registro real de avisos `-Wunguarded-availability` de
la Release (LOCAL) y saber si la 5,1 es Nehalem o Westmere.

**Trampas nuevas:**
- **Checkout parcial de Chromium, rápido** (10 s): `git fetch --depth=1 --filter=blob:none origin refs/tags/<tag>` de
  github.com/chromium/chromium y luego
  `git sparse-checkout set --no-cone '*.mm' '*_mac.cc' '*_mac.h' '*_apple.cc' '*.gni' '!/third_party/'`. Ocupa ~160 MB
  y con él `grep -r` va bien. Encima se aplican los parches de bc cuyo fichero exista (59 de la -p21, sin fallos).
- `chromium.googlesource.com` (`+archive`) da 502 en el proxy y `codeload.github.com`, 403: no insistir.

---

## De MOTOR-20 a MOTOR-21 (27-10-2026, ~08:15)

MOTOR-20 (`session_01MwmK2iKW2oBsGeKiqze1kp`, Opus 5.5, alto) hizo la 2.0.2 (FM.41, PR #520). Se archiva tras entregar
(directiva: no se espera con una sesión abierta); MOTOR-21 se abre con los resultados de LOCAL.

| Rama de brave-core | sha | Dónde |
|---|---|---|
| `-p21` (2.0.2) | 3cc4ce116c | bundle `p21.bundle` en la rama de softmac `nube/motor20-p21` (lo sube LOCAL) |

**Lo que queda (tuyo):** resultados de LOCAL (`buzon/LOCAL/20261027-0810-MOTOR-20.md`): errores de compilación de la -p21 (sin
compilar en la nube), las 5 pruebas de fijadas de `version-2.0.2.md` §1, capturas de versión para Titín, xHE-AAC y la lista
de avisos de 10.15. Pendiente de Titín: «FlyWeb» en la línea de versión de Información (cadena traducible) y la passkey «Brave»
(captura, de MOTOR-19).

**Trampas nuevas:** `git cherry-pick` no acepta `-q`. `browser_shutdown.h` está en `chrome/browser/lifetime/`. Con
`git fetch --depth=1` (blobs completos, ~260 MB) `git grep` va rápido; con `--filter=blob:none` no.

---

## De MOTOR-19 a MOTOR-20 (26-10-2026, ~18:25)

MOTOR-19 (`session_017Tq5AVGdzh2afxt2uAe97F`, Opus 5.5, alto) hizo la 2.0.1 (FM.40). **Se archiva sin relevo activo**
(directiva: no se espera con una sesión abierta); MOTOR-20 se abre cuando lleguen los resultados de LOCAL o la captura de Titín.
Todo en `FlyWeb/docs/version-2.0.1.md` (PR #513).

| Rama de brave-core | sha | Dónde |
|---|---|---|
| `-p19` (2.0.1) | 4b4bb3cc68 | bundle `p16-p19.bundle` en la rama de softmac `nube/motor19-p19` (sin push a brave-core; lo sube LOCAL) |

**Lo que queda (tuyo):**

1. **Resultados de LOCAL** (orden `buzon/LOCAL/20261026-1815-MOTOR-19.md`): Release de la -p19 (build 29), `--simulate-outdated`
   en 2.0.0 frente a 2.0.1, Sparkle intacto (Acerca de > buscar y relanzar), «FlyWeb Sync», NTP con 7 fondos, y el `build.sh`
   nuevo (`FLYWEB_BASE=128`) frente a su guion: corregir lo que diga.
2. **Pestañas fijadas** (prueba de 5 pasos, §3 de `version-2.0.1.md`): si apunta a las fijadas compartidas, portar a la 2.0.x el
   arreglo `restored_browsers_`/`SynchronizeRestoredBrowser` de la 1.15 (brave-core `flyweb`, `browser/ui/tabs/shared_pinned_tab_service.cc`)
   sobre el de la 1.69, que sincroniza al activar comparando URL.
3. **Passkey «Brave»**: con la captura de Titín. Ninguna cadena nuestra lo dice; mirar si lo pone el teléfono/Google
   (identificación por client hints o UA) antes de tocar nada.
4. Barrido de marca (§2e): propuestas a Titín; nada de .grd/.xtb a mano. Usuario `@brave.com` y ruta `braveSync`, no se tocan.

**Trampas nuevas:** en `docs/TRAMPAS.md` (MOTOR, 26-10: guardas que la base nueva quita; `grd_string_replacements.py`). Además:
- raw.githubusercontent.com da **429** a menudo con etiquetas de la 116 (la 128 va mejor); reintentar con pausas de 15–20 s.
  `git fetch` de github.com/chromium/chromium da 504.
- `git grep` sobre una rama traída con `--filter=blob:none` baja blob a blob: solo `git show rama:fichero` concreto.
- `pkill -f` volvió a matar el propio shell (ya estaba en las trampas de MOTOR-17).

---

**Relevos anteriores** (MOTOR-2 a MOTOR-17; MOTOR-18 no dejó nota propia): [`relevo-motor-historial.md`](relevo-motor-historial.md).
