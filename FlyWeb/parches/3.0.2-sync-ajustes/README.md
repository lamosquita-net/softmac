# FlyWeb 3.0.2: página de ajustes de sync (FS.43)

MOTOR-43, 09-11-2026, por encargo de COORDINACIÓN-36. Esta sesión no tiene push a brave-core, así que la entrega va como
`git format-patch`: la rama local `nube/b2-sync-ajustes` está sobre brave-core `nube/b2-porte-t11` **bf4262a094**
(el código de la 3.0.0; ls-remote del 09-11).

| Parche | Qué hace |
|---|---|
| `0001-settings-create-BraveSettingsUI-through-the-WebUICon.patch` | `BraveSettingsUIConfig`; quita `SettingsUIConfig` del `WebUIConfigMap` y pone la nuestra en su lugar |
| `0002-l10n-translate-the-sync-Passwords-data-type-label.patch` | traducción de «Passwords» en 53 idiomas (es: «Contraseñas») |

Comprobado con `git am`: entran limpios sobre bf4262a094 (árbol `b1fa1a5b0`, igual que la rama local) y sobre `seg/3.0.2`
**0d6a771f23**. Nada compilado (en la nube no se compila).

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
4. Los interruptores de tipos de datos tienen que poder cambiarse cuando «Sincronizar todo» está apagado. Brave 1.98 trae un
   arreglo (`disableTypeCheckBox_` sin `syncStatus`) que nuestro parche de `sync_controls.ts` no tiene. Si salen grises,
   avisar a MOTOR: no se ha tocado porque nuestra página sí pasa `syncStatus`.

## Notas (no arregladas)

- **DISABLED_BY_ADMIN** (cadena borrada desde otro Mac): queda para la 3.2. El servicio lo trata como Brave 1.98
  (`BraveSyncServiceImpl::ResetEngine`: abandona la cadena y deja pendiente el aviso de cuenta borrada). La página solo
  enseña «inhabilitado por el administrador» con `syncStatus.managed`. No se ha cambiado nada.
- Chromium 156 también registra `NewTabUIConfig`. Brave 1.98 lo quita para las ventanas privadas y la de invitado y pone
  `BravePrivateNewTabUIConfig`; nuestro porte no lo hace. Es probable que la nueva pestaña privada sea la de Chromium.
  No se ha tocado (no es de este encargo).
- Intocables respetados: ni el permiso «Inicio de sesión con Google» ni las llaves de acceso con el móvil.
