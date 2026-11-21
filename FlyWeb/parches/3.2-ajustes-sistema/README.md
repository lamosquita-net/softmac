# 3.2.0: ajustes de la 156 (Sistema y Apariencia)

MOTOR-46, 19-11-2026, por encargo de COORDINACIÓN-52 y 53 (decisión de Titín: todo entra en la 3.2.0).
**Sin compilar** (la nube no tiene el checkout de Chromium). Tres parches, en orden:
- 0001: brave://settings/system ya no muere (#1122, fusionado);
- 0002: vuelve el selector de tema en Apariencia;
- 0003: los seis desplegables de Brave vuelven a guardar;
- 0004: la tarjeta «Aspecto» deja de quedar tapada, y la fila de tema pasa a ser su primera fila.

Los tres son fallos del porte de los ajustes a la 156 (T11), no de la serie de la interfaz.

## El fallo

`flyweb://settings/system` mostraba «¡Vaya!» con `RESULT_CODE_KILLED_BAD_MESSAGE`. Pasa en la 3.1.3, en la 3.1.4 y en la
build de la interfaz. LOCAL-19 lo confirmó con un perfil limpio:
`[ERROR:content/browser/per_web_ui_browser_interface_broker.cc:40] Per WebUI interface binder missing for:
commands.mojom.CommandsService`, y después `Tab Killed: chrome://settings/`.

Desde Chromium 156, chrome://settings pide sus interfaces Mojo al intermediario propio de `settings::SettingsUI`
(`chrome_browser_interface_binders_webui_parts_desktop.cc:625-633`). Ya no consulta el mapa antiguo por frame. La página
Sistema de Brave tiene la subpágina de atajos, que carga `commands.bundle.js` y pide `CommandsService`. Brave solo la
registraba en el mapa antiguo (`brave_content_browser_client.cc:439`), así que el intermediario no la tenía y el navegador
cerraba el renderer.

## El arreglo

Es el mismo que hace Brave (master, 2025):
- `browser/brave_content_browser_client.cc`, en `RegisterTrustedWebUIInterfaceBrokers()`:
  `registry.ForWebUI<BraveSettingsUI>().Add<commands::mojom::CommandsService>()`, con `kBraveCommands` encendida (lo está
  por defecto).
- `chromium_src/content/public/browser/web_ui_browser_interface_broker_registry.h` y su parche
  `patches/content-public-browser-web_ui_browser_interface_broker_registry.h.patch`: un gancho que deja pasar un segundo
  `ForWebUI()` para el mismo tipo de controlador. Copiados de Brave. Sin él, en una build con DCHECK salta
  «Interfaces for a WebUI should be registered together». En la Release no hay DCHECK, pero los tests sí los tienen.

**Cambio respecto a la propuesta aprobada (opción b).** No se le puede dar a `BraveSettingsUI` un tipo de controlador
propio: en 156, `WEB_UI_CONTROLLER_TYPE_DECL()` declara `GetType() final`, y `SettingsUI` ya lo usa. `BraveSettingsUI`
comparte, por tanto, el tipo y el intermediario de `SettingsUI`, y se le añade `CommandsService`. El binder llama a
`GetAs<BraveSettingsUI>()`, que acepta cualquier controlador de ese tipo. En FlyWeb todo chrome://settings es
`BraveSettingsUI`, porque `chrome_web_ui_configs.cc` cambia `SettingsUIConfig` por `BraveSettingsUIConfig`. Las cinco
interfaces de upstream no se tocan y siguen enlazándose con `GetAs<settings::SettingsUI>()`.

Riesgos:
- Si algún día se crea un `settings::SettingsUI` que no sea de Brave, un `CommandsService` pedido desde él haría un
  `static_cast` a `BraveSettingsUI`. Hoy no puede pasar (ver arriba), y el primer paso de abajo lo comprueba. Aunque
  pasara, `BraveSettingsUI` no tiene miembros propios (su binder solo usa `web_ui()`), así que no se leería ni escribiría
  fuera del objeto. Lo fija un `static_assert(sizeof(BraveSettingsUI) == sizeof(settings::SettingsUI))` en
  `brave_settings_ui.cc`, la condición de SEGURIDAD-PORTES-32 (APTO, #1122). Si algún día hacen falta miembros, el
  assert fallará y habrá que poner una comprobación de verdad.
- El gancho quita el DCHECK para **todos** los `ForWebUI()`, no solo para el de ajustes. Un registro duplicado por error
  ya no avisa en debug. El `CHECK(!binder_map->Contains<Interface>())` de cada interfaz sigue activo, así que registrar
  dos veces la misma interfaz sigue rompiendo.

## 0002: selector de tema (claro / oscuro / igual que macOS)

**Fallo** (Titín, LOCAL-19, en la build de prueba y en la 3.1.4 con perfil limpio): en Ajustes › Apariencia no hay
selector de tema; solo se puede cambiar con el modo del sistema.
- `brave_overrides/appearance_page.ts` oculta con CSS la fila de Chromium (`#colorSchemeModeRow`).
- La de Brave (`<settings-brave-appearance-theme>`) no se inserta nunca: Brave 1.98 la mete con lit_mangler, que FlyWeb
  no tiene.
- `setBraveThemeType` funcionaba (LOCAL lo cambió por CDP); faltaba el control.

**Arreglo:** el mismo fichero engancha `firstUpdated` del elemento Lit (el patrón de `about_page.ts`) e inserta la fila de
Brave justo detrás de `#colorSchemeModeRow`.
- Es un nodo estático de la plantilla de 156 (`appearance_page.html.ts:66`), fuera de cualquier condicional, así que Lit
  no lo vuelve a crear y el hermano insertado se queda.
- La fila es un elemento Polymer con sus propios datos: la lista sale de `chrome.braveTheme.getBraveThemeList`, permitida
  en `chrome://settings/*` (`_api_features.json`), y el valor se escribe con `setBraveThemeType`.
- No se usa el selector de Chromium porque escribe la preferencia de color de Chromium (`ThemeService`), no la de Brave.

## 0003: los desplegables de Brave no guardaban

**Fallo:** en 156, `settings-dropdown-menu` es Lit y solo escribe la preferencia si tiene `pref-key`
(`controls/settings_dropdown_menu.ts:145` y `:125`); ya no la saca de un `pref="{{…}}"` enlazado con Polymer. Los seis
desplegables de Brave solo pasaban `pref`: enseñaban el valor, pero cada cambio se perdía. Ninguno tiene manejador propio.

| Desplegable | Página | Preferencia |
|---|---|---|
| Modo de pasar por encima de las pestañas | Apariencia › Pestañas | `brave.tabs.hover_mode` |
| Tamaño de letra | Apariencia › Contenido | `webkit.webprefs.default_font_size` |
| Qué muestra la nueva pestaña | Página de nueva pestaña | `brave.new_tab_page.shows_options` |
| **Política de IP de WebRTC** | Privacidad | `webrtc.ip_handling_policy` |
| Request OTR | Privacidad | `brave.request_otr.request_otr_action_option` |
| **Buscador de las ventanas privadas** | Buscador | `brave.default_private_search_provider_guid` |

**Arreglo:** `pref-key` con la misma preferencia en cada uno. Las seis están en la lista permitida de `settingsPrivate`
(`brave_prefs_util.cc`). El de pestañas además salía **vacío**: `tabTooltipModes_` era un campo de clase. Con el target
ESNext de 156 (`tools/typescript/tsconfig_base.json`), ese campo tapa el accesor que Polymer crea para el enlace. Ahora es
una propiedad Polymer con `value()`.

«Tarjeta con vista previa» funciona en Mac aunque `kTabHoverCardImages` venga apagada:
`brave_tab_hover_card_controller.cc:23-26` y el browsertest `brave_tab_hover_browsertest.cc:163-170`. La tarjeta en sí
no se toca: la diseña Titín.

**Revisión:** SEGURIDAD-PORTES-32 revisa el 0003 antes de fusionar (WebRTC y el buscador de privadas son de privacidad).

## 0004: la fila de tema no se veía

**Fallo:** Titín no veía el selector en la build de prueba (bt-320a). LOCAL-21 lo midió por CDP a 1400×897:
- `settings-appearance-page-index` medía 0×0 en y=56, y `settings-appearance-page` iba en `position: absolute` con h=0;
- `settings-brave-appearance-extras` empezaba también en y=56;
- encima del `#braveThemeType` estaba `settings-brave-appearance-toolbar`.

En 156, la tarjeta «Aspecto» es una vista del `cr-view-manager` del index, que coloca las vistas con posición absoluta. El
index no ocupa alto, y las tarjetas «Barra de herramientas» y «Pestañas» de Brave (que `settings_main.ts` pone justo
después, en la misma vista) se pintaban encima de la parte de arriba de «Aspecto». Quedaban tapados la fila del 0002,
«Temas» y «Personalizar barra de herramientas», y los títulos salían montados. Venía del porte (T11); el 0002 solo lo hizo
evidente.

**Arreglo**, solo en `brave_overrides/appearance_page.ts`:
- `injectStyle(SettingsAppearancePageIndexElement, …)` con `cr-view-manager [slot=view]:not(.closing) { position:
  initial; }`, la misma regla que ya usan las tarjetas de Brave (`brave_appearance_extras.html`). Así «Aspecto» ocupa su
  alto y las de Brave van debajo.
- La fila de tema pasa a insertarse delante de `#themeRow`, como primera fila de «Aspecto», que es donde la quiere Titín.
  `#themeRow` es el primer nodo estático de `div[route-path="default"]`. Se le devuelve el separador superior y el
  elemento insertado va con `display: block`.

## Parches y árboles

| Parche | Qué hace |
|---|---|
| `0001-Bind-CommandsService-on-the-settings-WebUI-broker.patch` | Sistema, más el browsertest `BraveContentBrowserClientTest.SettingsPagesBindTheirInterfaces` |
| `0002-Settings-show-Brave-s-theme-row-on-the-appearance-pa.patch` | Fila de tema (`brave_overrides/appearance_page.ts`) |
| `0003-Settings-make-Brave-s-dropdowns-save-their-prefs-aga.patch` | `pref-key` en 6 desplegables y `tabTooltipModes_` como propiedad |
| `0004-Settings-un-hide-the-top-of-the-Appearance-card-them.patch` | «Aspecto» ocupa su alto; la fila de tema, la primera de la tarjeta |

Se aplican en orden con `git am`, limpios sobre las dos bases (comprobado):

| Base | Tras 0001 | Tras 0002 | Tras 0003 | Tras 0004 |
|---|---|---|---|---|
| brave-core `local/3.1.4` (`e660929ac9`) | `c9c578188e` | `1720966e37` | `b82f38e3cd` | `f0530f3177` |
| Serie de la interfaz 0001–0007 (`FlyWeb/parches/3.2-interfaz/`, punta `ddac171538`) | `d58ba8b96d` | `d3cded8ef3` | `7a24c45189` | `a0c808d485` |

La serie de la interfaz no toca ninguno de estos ficheros.

## Pasos para LOCAL

1. En el checkout entero de Chromium (`src/`):
   `git grep -n "GetAs<.*SettingsUI>"` y `git grep -n "SettingsUIConfig\|new settings::SettingsUI\|<settings::SettingsUI>("`.
   Lo esperado: ningún `GetAs<BraveSettingsUI>` fuera de este parche, y que el único sitio donde se crea un
   `settings::SettingsUI` sea el `SettingsUIConfig` que sustituye `chrome_web_ui_configs.cc`. Si aparece otro, avisad
   antes de seguir.
2. Compilar y pasar el test nuevo:
   `browser_tests --gtest_filter=BraveContentBrowserClientTest.SettingsPagesBindTheirInterfaces` (también en una build
   con DCHECK, donde actuaría el DCHECK que se quita).
3. A mano, con un perfil limpio, abrir y comprobar que no sale «¡Vaya!» y que en el log no hay «Per WebUI interface
   binder missing»:
   - `flyweb://settings/system`;
   - la subpágina de atajos (Sistema → Atajos de teclado): la lista de atajos se carga y se puede cambiar uno;
   - `flyweb://settings/appearance`: el selector de color y el de modo claro/oscuro funcionan (son interfaces de
     upstream en el mismo intermediario);
   - `flyweb://settings/braveSync`.
4. Apariencia (0002), con perfil limpio: en `flyweb://settings/appearance` aparece la fila de colores de FlyWeb
   (`IDS_SETTINGS_APPEARANCE_SETTINGS_BRAVE_THEMES`, «FlyWeb colors») con tres opciones. Elegir claro, oscuro e «igual
   que macOS» (cambiando el modo de macOS) y comprobar que la ventana
   cambia al momento y que, al recargar la página, la opción elegida sigue marcada. El selector de Chromium no debe verse.
   En la consola de la página no debe salir `[FlyWeb] appearance page: #colorSchemeModeRow not found`.
5. Desplegables (0003): en cada uno de los seis de la tabla, elegir otro valor, **recargar la página** y comprobar que se
   conserva (y en `flyweb://prefs-internals`, si hace falta, el valor de la preferencia). En especial:
   - **Política de IP de WebRTC:** elegir «Disable non-proxied UDP», recargar; y comprobar en https://browserleaks.com/webrtc
     (o equivalente) que deja de salir la IP local.
   - **Buscador de las ventanas privadas:** elegir otro, recargar, abrir una ventana privada y buscar desde la barra.
   - **Modo de pasar por encima de las pestañas:** ahora salen las tres opciones (tarjeta, tarjeta con vista previa y
     tooltip). Con «Tarjeta con vista previa», la tarjeta lleva miniatura; con el tooltip, solo el título.
6. «Aspecto» (0004), en `flyweb://settings/appearance`:
   - la fila de colores de FlyWeb es la **primera** de la tarjeta «Aspecto», arriba del todo, y se ve;
   - los títulos «Aspecto», «Barra de herramientas» y «Pestañas» no salen montados: cada tarjeta, debajo de la anterior;
   - se ven «Temas» y «Personalizar barra de herramientas»;
   - entrar en «Personalizar fuentes» y volver: sin saltos ni tarjetas encima de otras;
   - claro, oscuro e «igual que macOS» se conservan al recargar.
   Por CDP, `settings-appearance-page-index` ya no debe medir 0 de alto.

## 0005: «Accesos directos» tapado por las tarjetas de Sistema (MOTOR-47, 20-11)

LOCAL-21 lo vio en bt-320e: en `flyweb://settings/system/shortcuts`, la subpágina de atajos se pintaba **debajo** de las
tarjetas de Sistema de Brave y de Memoria, en vez de sustituirlas.

- **Causa:** no viene de 0001–0004. Está en `brave_system_page_index.html` de nuestro porte de la 156, que ya estaba en
  la 3.1.4 y no tocan ni esta serie ni la interfaz. Hasta 0001 la página de sistema daba «¡Vaya!», así que no se veía.
  En nuestro porte, las vistas llevan la clase `.cr-centered-card-container`. Su `display: block` viene del árbol del
  propio elemento (`cr-shared-style`) y gana a la regla `::slotted([slot=view]) { display: none }` de `cr-view-manager`,
  así que esas vistas no se ocultaban nunca. Brave 1.98 pone la clase en el `cr-view-manager`.
- **Arreglo:** una regla en el mismo árbol oculta una vista con esa clase si no está activa ni cerrándose, salvo que se
  esté en modo búsqueda (`show-all`). No cambia el aspecto de las vistas que se ven.
- **Orden:** al final de la cadena de la 3.2.0, tras `3.2-v8` 0002 (árbol `612c201d14`) → **`e09a2118a4`**. Toca un
  fichero que nada más modifica, así que también entra limpio sobre e660929 o sobre a0c808d485.

**Prueba (LOCAL):**
1. `flyweb://settings/system`: se ven las tarjetas de siempre (Sistema, Sistema de Brave, Memoria).
2. «Accesos directos»: solo la subpágina, con su flecha atrás. Volver: las tarjetas de antes.
3. Buscar «memoria» en ajustes: se ven las tarjetas que coinciden y no aparece la subpágina de atajos.
