# FlyWeb 3.0.2: página de ajustes de sync (FS.43)

MOTOR-43, 09-11-2026, por encargo de COORDINACIÓN-36. Esta sesión no tiene push a brave-core, así que la entrega va como
`git format-patch`: la rama local `nube/b2-sync-ajustes` está sobre brave-core `nube/b2-porte-t11` **bf4262a094**
(el código de la 3.0.0; ls-remote del 09-11).

| Parche | Qué hace |
|---|---|
| `0001-settings-create-BraveSettingsUI-through-the-WebUICon.patch` | `BraveSettingsUIConfig`; quita `SettingsUIConfig` del `WebUIConfigMap` y pone la nuestra en su lugar |
| `0002-l10n-translate-the-sync-Passwords-data-type-label.patch` | traducción de «Passwords» en 53 idiomas (es: «Contraseñas») |
| `0003-settings-let-sync-type-toggles-follow-Sync-everythin.patch` | porte del arreglo de `disableTypeCheckBox_` de Brave 1.98 (parche de `sync_controls.ts` regenerado sobre 156.0.8078.90) |
| `0004-ntp-create-BravePrivateNewTabUI-through-the-WebUICon.patch` | `BravePrivateNewTabUIConfig`: la NTP privada y la de invitado vuelven a ser las de Brave |
| `0005-ntp-FlyWeb-private-new-tab-page-without-Brave-Search.patch` | NTP privada de FlyWeb: sin el logo de Brave Search, búsqueda con el buscador del usuario y sin la mención a Tor |

0001–0003 entran en la **3.0.1 unificada** (build 42); la carpeta conserva el nombre 3.0.2. **0004 y 0005 son de la 3.1 y
van juntos** (COORDINACIÓN-36, 09-11): con solo 0004, LOCAL-19 vio en la 6,1 el logo «brave» con el león y un texto
de Tor.

Comprobado con `git am` (ls-remote del 09-11): los 4 primeros entran limpios sobre bf4262a094 (árbol `a99b13aef`),
`seg/3.0.1` **6415661d24**, `seg/3.0.1-parser` **bee89ad8a6** y `seg/3.0.2` **0d6a771f23**. Los 5 juntos, sobre
bf4262a094 (árbol `b1dc13fdf`, igual que la rama local), `seg/3.0.1` y `seg/3.0.2`. El 0003 da avisos de
espacios en blanco: son líneas de contexto del `.patch` que lleva dentro; no fallan. Nada compilado (en la nube no se compila).

## Por qué falla

En Chromium 156, `chrome_web_ui_configs.cc:400` registra `settings::SettingsUIConfig` en el `WebUIConfigMap`. El mapa se
consulta antes que `BraveWebUIControllerFactory`. Así, `chrome://settings` se creaba como el `SettingsUI` de Chromium, no
como `BraveSettingsUI`, y no se añadía **ningún manejador propio de Brave**: `BraveSyncHandler`, `DefaultBraveShieldsHandler`,
`BraveAppearanceHandler`, `BravePrivacyHandler`, `BraveAdBlockHandler`, `BraveDefaultExtensionsHandler` ni
`MetricsReportingHandler`. La página sí se pinta, porque los recursos se añaden desde el proveedor de cadenas. Pero los
`sendWithPromise` de la página de sync (`SyncGetDeviceList`, `SyncSetupGetSyncCode`, `SyncSetupReset`,
`SyncPermanentlyDeleteAccount`…) no tenían a nadie que respondiera. Por eso:
- la lista de dispositivos sale vacía;
- los botones no hacen nada;
- «Eliminación de la cuenta en curso…» se queda para siempre, porque la promesa nunca se resuelve.

El motor de sync no depende de la WebUI; por eso seguía escribiendo en el servidor.

Brave 1.98.63, sobre la misma rama 156.0.8078, lo resuelve igual: `RemoveOverridenWebUIs()` quita `SettingsUIConfig` y
añade `BraveSettingsUIConfig`. El porte se quedó con el `chrome_web_ui_configs.cc` antiguo, que solo añadía `ShieldsPanelUIConfig`.
Los nombres de los mensajes JS ↔ C++ y el proxy JS son coherentes entre sí: no era eso. El manejador sí estaba registrado
en `BraveSettingsUI`, pero esa clase no llegaba a crearse.

«Passwords»: `IDS_SETTINGS_PASSWORDS_AND_PASSKEYS_CHECKBOX_LABEL` se redirige a `IDS_SETTINGS_BRAVE_PASSWORDS_CHECKBOX_LABEL`
(«Passwords», id 7029809446516969842). Nuestros `brave_generated_resources_*.xtb` no tenían esa traducción; los de Brave
1.98.63 sí. Las líneas se han copiado tal cual de Brave, no se han escrito a mano. El id se ha comprobado con la huella de
grit. En sr tampoco hay traducción en Brave. El resto de cadenas de `brave_settings_strings.grdp` relacionadas con sync sí
tienen traducción al español.

## Qué cambia

- `browser/ui/webui/brave_settings_ui.{h,cc}`: `BraveSettingsUIConfig` (un `DefaultWebUIConfig` sobre
  `chrome://settings`); el constructor pasa a `BraveSettingsUI(WebUI*)`, que es lo que exige `DefaultWebUIConfig`.
- `chromium_src/chrome/browser/ui/webui/chrome_web_ui_configs.cc`: `RemoveConfig(chrome://settings)` y
  `AddWebUIConfig(BraveSettingsUIConfig)`.
- `browser/ui/webui/brave_web_ui_controller_factory.cc`: la rama de ajustes usa el constructor nuevo. Se deja por si acaso;
  las dos vías crean lo mismo.
- `app/resources/brave_generated_resources_*.xtb` (53): la traducción de «Passwords».

## Auditoría de WebUIConfig (0004)

Se han comparado las WebUIConfig que Brave 1.98.63 quita o sustituye con nuestro
`chromium_src/chrome/browser/ui/webui/chrome_web_ui_configs.cc` (que solo añadía `ShieldsPanelUIConfig`). Chromium 156
registra sus configs en `RegisterChromeWebUIConfigs`; el `WebUIConfigMap` se consulta antes que
`BraveWebUIControllerFactory`. Solo hay dos hosts en los que una config de Chromium choca con nuestra fábrica: `settings` y
`newtab`.

| Config | Qué hace Brave 1.98 | 3.0.0 | Qué se ve en la 3.0.0 | Ahora |
|---|---|---|---|---|
| `settings::SettingsUIConfig` | la quita y pone `BraveSettingsUIConfig` | nada | ajustes sin manejadores de Brave (sync, Shields, apariencia…) | 0001 |
| `NewTabUIConfig` (incógnito/invitado) | la quita y pone `BravePrivateNewTabUIConfig` | nada | NTP privada y de invitado de **Chromium** | 0004 (sin Tor: no está en FlyWeb) |
| `TabSearchUIConfig`, `BookmarksSidePanelUIConfig` | las sustituye por `#define` con versiones de Brave (recursos y opciones propias) | nada | las de Chromium, que funcionan | no se portan: no faltan funciones, solo personalización de Brave |
| `ShieldsPanelUIConfig` | la añade | la añade | panel de Shields de Brave | igual |
| `BraveAdblockUIConfig`, `BraveAdblockInternalsUIConfig` | las añade | por la fábrica (sin choque con Chromium) | las de Brave | igual |
| `BraveWelcomePageUIConfig` | la añade (bienvenida nueva) | `BraveWelcomeUI` por la fábrica; Chromium 156 no registra config para `welcome` | la bienvenida de Brave | igual |
| Wallet (página, panel y las no confiables: market, nft, line_chart, ledger, trezor, snap), Rewards, News (y su barra lateral), VPN, Playlist, AI Chat/Leo (y sus no confiables), IA local, Ads internals | las añade | no existen en nuestro árbol | — | funciones quitadas: siguen sin registrarse |
| Speedreader, Webcompat reporter, Brave Account, Brave Education, Brave Origin, Email Aliases, PSST | las añade | no existen en nuestro árbol (no hay `chrome_untrusted_web_ui_configs.cc` propio) | — | no se tocan |

Un perfil OTR que no es el principal (p. ej. el de DevTools) no entra en `BravePrivateNewTabUIConfig` y cae en la fábrica,
igual que en Brave 1.98.

## Para LOCAL

1. `git am` de los dos parches sobre la brave-core de la 3.0.2 (`seg/3.0.2`, o la rebasada sobre `seg/3.0.1-parser`).
2. En ejecución, en Sequoia y en Mojave, en `flyweb://settings/braveSync/setup`, con un perfil que ya esté en una cadena:
   - **Lista de dispositivos**: sale este Mac, marcado como el actual, y los demás de la cadena.
   - **Ver el código de sincronización**: salen las 25 palabras y el QR.
   - **Añadir un nuevo dispositivo**: se abre el diálogo de móvil/ordenador con el QR o el código.
   - **Abandonar la cadena de sincronización**: vuelve a la pantalla de inicio de sync. Al volver a unirse con el código, la lista vuelve.
   - **Eliminar cuenta de Sincronización**: hacerlo solo con una cadena de prueba, porque borra la cadena en el servidor.
     Debe terminar, sin quedarse en «en curso». Los otros Macs de esa cadena recibirán DISABLED_BY_ADMIN; ver la nota de abajo.
   - En español, la lista de tipos dice **«Contraseñas»**.
3. Lo que este arreglo debería devolver de paso, porque usa los mismos manejadores (comprobar que funciona):
   - Shields por defecto (`flyweb://settings/shields`);
   - listas de filtros (`flyweb://settings/shields/filters`);
   - Apariencia;
   - y, si `kBraveCommands` está encendida, Atajos de teclado (enlazada por mojo a `BraveSettingsUI`).
4. Tipos de datos (0003): con «Sincronizar todo» encendido, los interruptores están grises y marcados; al apagarlo se
   pueden cambiar uno a uno, y el cambio se mantiene al recargar la página.
5. NTP privada (0004): una ventana privada (⇧⌘N) y una de invitado muestran la nueva pestaña privada de **Brave/FlyWeb**,
   no la de incógnito de Chromium. Una pestaña nueva normal sigue siendo la NTP de FlyWeb, con sus fondos.

## 0005: NTP privada y de invitado sin marca de Brave ni Tor (3.1)

**Qué se veía con 0004** (componente React de `components/brave_private_new_tab_ui/resources/page`):
- **El león y «brave search»:** el SVG `BraveSearchLogo` de `components/search-box`. Además, la caja buscaba **siempre en
  Brave Search** (`GoToBraveSearch` → `TemplateURLPrepopulateData::brave_search`), aunque el usuario tuviera otro buscador.
- **Tor:** el diálogo une `headerText1` y `headerText2`. `headerText2` (`IDS_BRAVE_PRIVATE_NEW_TAB_PRIVATE_WINDOW_DESC2`)
  acaba con «…open a private window with Tor.», y la frase está en sus 49 traducciones. Las cadenas `…_TOR` de la grd
  no se usan en esta página.
- El resto no lleva marca: fondo de ondas, la insignia «Ventana privada» con su icono de gafas y el placeholder
  «Buscar en la web de forma privada».

**Por qué esta y no la de Chromium:** la página de incógnito de Chromium (la de la 3.0.0), con las cadenas que Brave
rebasa, dice «You've gone Private». Además trae un «including FlyWeb» que es una sustitución errónea de «including
Google», y su enlace «Más información» va a la ayuda de Google. Arreglar eso pide cambiar cadenas (y perder sus
traducciones) y una URL de Chromium. La de Brave se arregla sin tocar ninguna cadena ni ningún `.xtb`.

**Qué cambia:**
- **Logo:** la mosca de FlyWeb (el dibujo de la NTP, `mosca-newtab.svg`) en lugar del logo de Brave Search. Copio
  `moscaSvg.ts` y `svgEnReact.tsx` en `components/flyweb/` de este paquete, igual que hace `brave_welcome_ui`: cada WebUI
  lleva su copia, y el conversor evita `innerHTML` por Trusted Types. El nombre accesible del formulario deja de ser
  «Brave» y pasa a ser el placeholder traducido.
- **Búsqueda:** `GoToBraveSearch` → `GoToSearch` (mojom, TS y C++), con el **buscador predeterminado** del perfil.
  `TemplateURLServiceFactory` redirige el perfil privado y el de invitado al original. Si no hay buscador o su URL no
  admite términos, no hace nada.
- **Texto:** el diálogo solo enseña `headerText1` (`…_DESC1`), sin Tor en ningún idioma. `headerText2` sigue en la lista
  de cadenas, pero sin usarse.

**Queda pendiente (no es de este parche):**
- La traducción **coreana** de `…_DESC1` dice «Brave». Es el mismo problema que el resto de los `.xtb`: lo arregla el flujo
  de `chromium-rebase-l10n.py` (`FlyWeb/docs/rebranding.md`), no a mano.
- Si Titín prefiere otro dibujo, o la mosca con otro tamaño, se cambia en `search-box`.

**LOCAL comprueba (3.1), en una ventana privada (⇧⌘N) y en una de invitado:**
- arriba, la mosca blanca de FlyWeb; nada de león, de «brave» ni de «search»;
- buscar algo va al buscador predeterminado (el de `flyweb://settings/search`), y ⌘↩ lo abre en otra pestaña;
- el diálogo de la esquina (y el botón ⓘ) dice solo «FlyWeb nunca guarda lo que haces…», sin Tor;
- en la consola de DevTools de la página, ningún error de Trusted Types;
- una pestaña nueva normal sigue igual.

## Notas (no arregladas)

- **DISABLED_BY_ADMIN** (cadena borrada desde otro Mac): queda para la 3.2. El servicio lo trata como Brave 1.98
  (`BraveSyncServiceImpl::ResetEngine`: abandona la cadena y deja pendiente el aviso de cuenta borrada). La página solo
  enseña «inhabilitado por el administrador» con `syncStatus.managed`. No se ha cambiado nada.
- Intocables respetados: ni el permiso «Inicio de sesión con Google» ni las llaves de acceso con el móvil.
