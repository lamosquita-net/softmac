# FlySync: `flyweb://settings/flysync`, sin restos de «Sync» de Brave, y avisos en pastilla naranja

MOTOR-47, 27-11-2026, por encargo de COORDINACIÓN-66/67 (Titín: «es un sistema diferente que hemos desarrollado nosotros,
FlySync»; y la pastilla naranja para los mensajes). **Sin compilar.** Para la próxima versión de Mac y Linux. El punto 2
del encargo (modelo de los equipos ya registrados) lo prepara D8-LINUX con SERVIDOR-LOCAL.

## 1. Ruta

- `flyweb://settings/braveSync[/setup]` pasa a **`flyweb://settings/flysync[/setup]`**. Cambian:
  - `kBraveSyncPath` y `kBraveSyncSetupPath` (`components/constants/webui_url_constants.h`), que usan los avisos y
    `chrome::ShowSettingsSubPage`;
  - las rutas de `brave_routes.ts`;
  - el enlace del menú (`settings_menu.ts`);
  - el `route-path` de la subpágina;
  - y las dos pruebas que comprueban la URL.
- **Redirección:** si la página se abre con `/braveSync` o `/braveSync/setup`, desde marcadores, el historial o enlaces
  viejos, `addBraveRoutes()` la reescribe a `/flysync…` con `history.replaceState`, conservando la consulta y el ancla. Esto
  pasa antes de que el *router* lea la URL: `createRoutes()` se evalúa antes de `new Router()` en `route.ts` de la 156.
  `flyweb://sync` sigue llevando a la página.
- Los nombres internos (`BRAVE_SYNC`, la sección `braveSync`, los `id` de la vista) no se ven y se quedan como están.

## 2. Textos (27 mensajes de `app/brave_settings_strings.grdp`)

Fuera «Sync», «FlyWeb Sync» y «device/dispositivo». Quedan **FlySync** y **equipo**, como en las cadenas de la cuenta de D8.
Lo más visible:

| Antes (es) | Ahora |
|---|---|
| Gestiona tus dispositivos sincronizados | Gestiona tus equipos sincronizados |
| Configuración de FlyWeb Sync (configuración inicial) | Configurar FlySync |
| Configuración de FlyWeb Sync (ajustes) | Configuración de FlySync |
| Administrador de FlyWeb Sync | Gestor de FlySync |
| Iniciar una nueva cadena FlyWeb Sync | Iniciar una cadena de FlySync nueva |
| Lista de dispositivos / Nombre del dispositivo / (este dispositivo) | Equipos / Nombre del equipo / (este equipo) |
| Añadir un nuevo dispositivo | Añadir un equipo |
| Abandonar la cadena de sincronización | Salir de la cadena de FlySync |

y los textos largos de esa página: borrar la cuenta, restablecer, el aviso de seguridad y la clave distinta.

- **Sin tocar:**
  - el título de la sección, «Cuenta y sincronización». Es nuestro, y las cadenas de la cuenta lo citan («Cuenta y
    sincronización → He olvidado la contraseña»);
  - «Ordenador / Teléfono» del selector de tipo de aparato;
  - «código de sincronización», que es genérico.
- **Ids de grit:** cada mensaje cambiado tiene id nuevo (md5 del texto inglés). `es` y `es-419` llevan la traducción nueva.
  **Los otros idiomas conservan su traducción de antes, movida al id nuevo**, así que ninguno cae al inglés, aunque en
  ellos siga diciendo «Sync» o lo que dijeran. `gu`, `ml`, `mr` y `te` no tenían traducción y `ta` tenía 12: siguen igual.
  Algún idioma, como `am`, ya decía «Brave» en su traducción; eso viene de antes y no se toca aquí.

## 3. Mensajes en pastilla naranja (`flyweb_sync_account.html`)

- Todos los mensajes de la página de la cuenta son una pastilla **naranja `#FF9900` con texto negro**, en claro y en oscuro:
  - los avisos (`.fw-banner`: «¿Has sido tú?», «Sin red», «después de No he sido yo», borrado programado);
  - los errores (`.fw-error`);
  - los estados («Comprobando…», `.fw-info`);
  - la contraseña débil.
- Fuera el borde y el texto rojos.
- Es el naranja de los avisos de FlyWeb (`kColorToastBackgroundProminent`, #1250) y de los botones de la bienvenida.
- **Contraste del negro sobre #FF9900: 9,8:1** (≥ 4,5).
- **Botones dentro de la pastilla:** el principal («No he sido yo») negro con texto blanco; los demás («He sido yo»,
  «Reintentar»…) blancos con texto y borde negros. Los dos con 21:1.
- **Capturas** (`capturas/claro.png`, `capturas/oscuro.png`): son una **maqueta** con el mismo CSS del parche, pintada con
  Chromium en el contenedor de la nube, no la página compilada. Los botones de verdad son `cr-button`, con la forma de
  Chromium.

## Base y árboles

brave-core `local/322-final` = **060015a802** (ls-remote del 27-11), árbol `fbdf05a0d3`. Con `git am`, árbol **`87464a7e3f`**
(comprobado; avisa de espacios al final en tres traducciones que ya los traían). No comparte ficheros con
`3.2-version-producto` (#1284). Sí toca `brave_settings_strings.grdp` y `brave_generated_resources_es*.xtb`, igual que el
parche «equipo» de D8: **orden: primero el de D8 y luego este**. Si al montarlo choca en esos `.xtb`, avisad y lo rehago
sobre su base.

## Qué deben comprobar LOCAL (Mac) y D8 (Linux)

1. `flyweb://settings/flysync` abre la página. `flyweb://settings/braveSync` y `…/braveSync/setup` acaban en `/flysync` y
   `/flysync/setup` (mirar la barra de direcciones). Los avisos «la clave ha cambiado» y «cuenta borrada» llevan a `/flysync/setup`.
2. En castellano no queda ningún «Sync», «FlyWeb Sync» ni «dispositivo» en esa página (salvo «Teléfono/Tablet» del selector).
3. Forzar un aviso («¿Has sido tú?», por ejemplo dando de alta otro equipo) y un error (sin red): pastilla naranja y texto
   negro, en claro y en oscuro; botones legibles.
4. Otro idioma, por ejemplo `de`: los textos siguen traducidos, no en inglés.
5. `brave_unit_tests`/`browser_tests` de `BraveContentBrowserClient` (URL `flysync`).

## Ficheros

- `0001-FlySync-settings-at-flyweb-settings-flysync-no-Brave.patch` (`git format-patch --full-index`).
- `capturas/claro.png`, `capturas/oscuro.png` (maqueta).
- `SHA256SUMS`.
