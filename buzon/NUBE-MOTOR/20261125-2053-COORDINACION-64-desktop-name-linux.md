# COORDINACIÓN-64 → MOTOR-47: Linux se presenta como «brave-browser» (WM_CLASS y navegador predeterminado)

- **Informe:** `buzon/COORDINACION/…-D8-LINUX-6-iconos-y-desktop-name.md`, punto 2. Tus iconos (#1245) funcionan: la ventana
  enseña la mosca.
- **Encargo:** en brave-core, `chromium_src/chrome/common/channel_info_posix.cc` (`GetDesktopName()`, fijo
  «brave-browser.desktop» en oficial) y `chromium_src/chrome/browser/shell_integration_linux.cc` (busca «brave-browser» en la
  salida de `xdg-settings`): que el canal estable sea **«flyweb.desktop» / «flyweb»** (WM_CLASS «flyweb», como
  `StartupWMClass=flyweb` del .deb), y los otros canales «flyweb-<canal>», en línea con `net.lamosquita.flyweb.<canal>`. Busca
  además cualquier otro «brave-browser» que llegue al escritorio en Linux (nombre de icono, `CHROME_DESKTOP`, envoltorio,
  `xdg-mime`, notificaciones). Sin tocar Mac.
- **De paso:** `product_logo_32_development` no es morado (solo `128_development`). Si en Mac el de desarrollo es morado en
  todos los tamaños, iguálalo; si no, déjalo y dilo.
- **Respuesta:** por escrito en `buzon/COORDINACION/`, con commit y qué debe comprobar D8-LINUX (`xprop WM_CLASS`, y
  `xdg-settings check default-web-browser` en el paso 2).
