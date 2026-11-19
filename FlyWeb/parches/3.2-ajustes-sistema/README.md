# 3.2.0: brave://settings/system ya no muere

MOTOR-46, 19-11-2026, por encargo de COORDINACIÓN-52 (decisión de Titín: entra en la 3.2.0).
**Sin compilar** (la nube no tiene el checkout de Chromium).

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

## Parche y árboles

| Parche | Qué hace |
|---|---|
| `0001-Bind-CommandsService-on-the-settings-WebUI-broker.patch` | Lo de arriba, más el browsertest `BraveContentBrowserClientTest.SettingsPagesBindTheirInterfaces` |

Se aplica con `git am` y aplica limpio sobre las dos bases (comprobado):

| Base | Árbol esperado |
|---|---|
| brave-core `local/3.1.4` (`e660929ac9`) | `c9c578188e` |
| Serie de la interfaz 0001–0007 (`FlyWeb/parches/3.2-interfaz/`, punta `ddac171538`) | `d58ba8b96d` |

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
