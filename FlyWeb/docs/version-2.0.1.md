# FlyWeb 2.0.1 — arreglos sobre la 2.0.0 (FM.40)

**Estado (26-10-2026, MOTOR-19):** código en brave-core `nube/base-128-motor-p19` **4b4bb3cc68** (sobre `-p18` 16b6e01b57),
entregado como bundle (rama de softmac `nube/motor19-p19`; la nube no tiene escritura en brave-core). Sin compilar.
`flyweb_version` 2.0.1; LOCAL compila con `FLYWEB_BUILD_NUMBER=29` (169.168.29).

| Commit | Qué |
|---|---|
| 16b6e01b57 (`-p18`, MOTOR-18) | Estadísticas de la NTP como en la 1.15 en los fondos FlyWeb, sin halo |
| 6b10100f | Sin aviso falso «No se puede actualizar FlyWeb» (punto 1) |
| 1f77e29f | `apply_patches` con parches que crean ficheros nuevos (punto 4) |
| 86c74248 | «FlyWeb Sync» en `flyweb://sync-internals` (punto 2b) |
| 4b4bb3cc | `flyweb_version` 2.0.1 |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12.)*

- **Fuera el aviso falso de actualización.** Horas después de abrir FlyWeb 2.0.0, el botón de actualizar se ponía en rojo y
  decía «No se puede actualizar FlyWeb». Era falso: FlyWeb se actualiza solo, con nuestro sistema. Ya no sale.
- **Nueva pestaña:** las cifras de bloqueos vuelven a verse como en la 1.15 sobre los fondos de FlyWeb.

## 1. Aviso falso de versión desactualizada (hecho)

- **Causa** [comprobado en el código de 116.0.5845.188 y 128.0.6613.138, `chrome/browser/upgrade_detector/upgrade_detector_impl.cc`]:
  la 116 salía de `UpgradeDetectorImpl::Init()` en macOS si no había Keystone (`!keystone_glue::KeystoneEnabled()`, dentro de
  `#if ENABLE_UPDATE_NOTIFICATIONS`): ni detector de instalación desactualizada ni sondeo de la versión instalada. **La 128 quitó
  esa guarda.** Brave pone `enable_update_notifications = isOfficialBuild()`, así que en la Release el detector arranca, compara
  la fecha de compilación (`base::GetBuildTime()` = fecha del commit de Chromium 128, agosto de 2024) con el reloj, ve más de
  8 semanas y marca `UPGRADE_NEEDED_OUTDATED_INSTALL`: botón rojo y burbuja. En Static el flag es `false`: por eso no se vio antes.
- **Arreglo de raíz:** `enable_update_notifications: false` en `build/commands/lib/config.js`. Es lo que hacía la 116 en ejecución
  y lo que ya compila cada Static de Mac; no se crea el detector ni el sondeo (sin estado que afecte a otras cosas).
  Las actualizaciones siguen siendo de Sparkle (`enable_sparkle`), que no depende de esto.
- **«Reinstalar»** llevaba a `https://flyweb.lamosquita.net/descargas/` (el `chromium_src` de Brave cambia la URL de Google por
  `kDownloadBraveUrl`, que IDENTIDAD ya apuntó a nuestra web). Sin problema de privacidad.
- **Prueba (LOCAL, 6,1, perfil temporal, sin `--disable-background-networking`):**
  `--simulate-outdated="2024-08-01 00:00:00"`: con la 2.0.0 sale la burbuja al poco de arrancar; con la 2.0.1, no. Sin fecha el
  interruptor fuerza la burbuja aunque el detector esté apagado: así no sirve.

## 2. Marca Brave visible

- **(a) Passkey por el teléfono:** ni las cadenas `IDS_WEBAUTHN_*` ni `IDS_PRODUCT_NAME` dicen Brave (FlyWeb), y brave-core no
  toca `device/fido/cable`. [inferencia] El «Brave» lo pinta el teléfono (Google Play Services) o la página de Google. **Falta
  una captura de Titín** (qué pantalla, ordenador o teléfono, qué texto exacto) antes de tocar nada.
- **(b) «Brave Sync» en `sync-internals`:** etiqueta escrita a mano en `chromium_src/components/sync/service/sync_internals_util.cc`;
  ahora «FlyWeb Sync» (86c74248). No es cadena traducible.
- **(c) Usuario de sync `… @brave.com`** (`components/sync/service/brave_sync_auth_manager.cc`): nuestro servidor no lo usa
  (go-sync identifica por la clave pública; sus pruebas mandan `share` vacío), pero el cliente guarda el correo de la cuenta en
  las preferencias y Chromium puede tomarlo como **otra cuenta** y reiniciar los datos de sync. Riesgo sin probar → **no se toca**
  (nadie lo ve fuera de `sync-internals`).
- **(d) `settings/braveSync`:** identificador interno (`browser/resources/settings/brave_routes.ts`); `rebranding.md` desaconseja
  tocarlos. **No se toca.**
- **(e) Barrido (159 líneas con «Brave» en .grd/.grdp, casi todas de servicios apagados):** propuesta para Titín, sin cambiar nada:
  - Promos de **Brave Search** (no lo ofrecemos; DuckDuckGo por defecto): `generated_resources.grd` 6060 y 8628–8646,
    `settings_strings.grdp` 98, 143, 4084, `brave_components_strings.grd` 262/265/489, `brave_generated_resources.grd` 531–567.
    Comprobar si alguna se ve con un perfil nuevo; si se ve, apagar la promo (código), no reescribir la cadena.
  - `welcome_strings.grdp` 92 y `profiles_strings.grdp` 883 «Get Brave Search and FlyWeb smarts»; `nux_strings.grdp` 12 y 29
    («Make Brave your own», «Brave Apps»): restos de la sustitución Google → Brave. Ver si salen en la bienvenida.
  - `<title>` de páginas de Playlist, Rewards, Wallet, Brave Player y News: servicios apagados.
  - **Riesgo latente:** `script/lib/l10n/grd_string_replacements.py` sigue cambiando Google/Chrome/Chromium por **Brave**. Antes
    de pasar `chromium-rebase-l10n.py`, cambiarlo a FlyWeb (si no, vuelve «Brave» a todas las cadenas). Anotado en TRAMPAS.

## 3. Pestañas fijadas perdidas (1.15.2 → 2.0, estudio en papel)

[comprobado] La sesión y la lista de fijadas no cambian de formato de la 116 a la 128: las dos leen `Sessions/` y la
preferencia `pinned_tabs` (`PinnedTabCodec`, lista de `{url}`), que solo se usa **si «Al iniciar» no es «Continuar donde lo
dejaste»** y no hay otra ventana (`StartupTabProviderImpl::GetPinnedTabsForState`). Las hipótesis, de más a menos probable:

1. **Pestañas fijadas compartidas** (encendidas en las dos). La 1.15 llevaba un arreglo propio para ventanas restauradas
   (`restored_browsers_` + `SynchronizeRestoredBrowser`, MOTOR-11/FM.25) que **no se llevó a la 2.0** (`identidad-128.md`, i3:
   «la 1.69 lo resuelve de otra forma; probar»). Con dos o más ventanas, la 1.69 sincroniza cada ventana restaurada al
   activarla comparando URL; si no cuadran, las fijadas de una ventana pueden quedar como relleno de otra o perderse.
2. **Cierre sucio por Sparkle:** si la 1.15.2 no cerró limpia al instalar, la 2.0 arranca como «tras un fallo» y no añade las
   fijadas de `pinned_tabs` (solo ofrece restaurar).
3. **La 1.15.2 guardó mal `pinned_tabs`** (los rellenos de las fijadas compartidas sin URL) y la 2.0 lo lee bien, pero vacío.

**Prueba para LOCAL en la 6,1** (perfil temporal, copia de uno de la 1.15.2; nunca el de Titín):
1. Con la 1.15.2: 2 ventanas, 3 fijadas + 2 normales. Dos variantes de «Al iniciar»: (A) «Página Nueva pestaña», (B) «Continuar
   donde lo dejaste». Cmd+Q. Guardar copia del perfil y anotar de `Preferences`: `pinned_tabs`, `session.restore_on_startup`,
   `brave.tabs.shared_pinned_tab`, `profile.exit_type`; y la lista de `Sessions/`.
2. Abrir esa copia con la 2.0.0 (`-p17`): ¿cuántas fijadas y normales, en qué ventanas? Cmd+Q y volver a abrir con la 2.0.0.
3. Repetir 1–2 con `brave.tabs.shared_pinned_tab` = false en la 1.15.2 (aisla la hipótesis 1).
4. Repetir el paso 2 con `exit_type` = `Crashed` a mano (hipótesis 2).
5. Control 2.0 → 2.0 (sin cambiar de versión): si también se pierden, el fallo es de la 2.0, no de la migración.
Con eso se decide si se porta el arreglo de la 1.15 (`restored_browsers_`) a la 2.0.x.

## 4. `build.sh` para la 2.x y `apply_patches` (hecho)

- `FlyWeb/scripts/build.sh`: `FLYWEB_BASE=128` (por defecto) o `116`. En 128: checkout `~/proyectos/brave-128`, SDK 14.5,
  depot_tools `31e21628`, **`FLYWEB_BRANCH` obligatoria** (rama o sha de brave-core), brave-browser no se toca,
  `mac_deployment_target`/`mac_min_system_version` 10.14 y `flyweb_metal_bin_path` (por defecto el toolchain de
  `~/proyectos/sdk/Xcode-15.4.app`; `FLYWEB_METAL_BIN` para otra ruta). Las 6 claves inertes ya estaban (#505). **Sin probar en
  la 7,1:** LOCAL compara su guion con `build.sh` y avisa de lo que falte (p. ej. `treat_warnings_as_errors`, los diff de Mojave
  de `temp/local7/parches-128` si no están ya en brave-core).
- `build/commands/lib/gitPatcher.js` (1f77e29f): el reset hacía un solo `git checkout <rutas>`; con un fichero que crea un parche
  (no está en Chromium) fallaba entero y no restauraba nada. Ahora restaura los seguidos y borra los creados por parches, que el
  parche vuelve a crear. Probado en un repo de juguete: con el código viejo, cambiar un parche que crea un fichero y otro que
  modifica uno hace fallar los dos; con el nuevo aplican; quitar el parche borra su fichero.
