# FlyWeb en Linux: `flyweb.desktop` en vez de `brave-browser`

MOTOR-47, 25-11-2026, por encargo de COORDINACIÓN-64 (D8-LINUX-6, punto 2). **Sin compilar.** No toca Mac: todo está bajo
`IS_LINUX` o en ficheros que solo se compilan en Linux.

## Qué se presentaba como «brave-browser» y cómo queda

| Dónde (brave-core) | Efecto en el escritorio | Antes | Ahora |
|---|---|---|---|
| `chromium_src/chrome/common/channel_info_posix.cc`, `GetDesktopName()` | **WM_CLASS** (lo calcula `shell_integration_linux::GetProgramClass{Name,Class}()`), el nombre que se pasa a `xdg-settings` para «navegador predeterminado» y la pista `desktop-entry` de las notificaciones | `brave-browser[-canal].desktop` | `flyweb.desktop` (estable, y en compilación no oficial, donde `CHROME_DESKTOP` sigue mandando); `flyweb-{beta,dev,nightly}.desktop` |
| `chromium_src/chrome/browser/shell_integration_linux.cc` | «¿Es predeterminado otro canal?» (`xdg-settings get default-web-browser`) | busca `brave-browser` | busca `flyweb` |
| `patches/chrome-browser-shell_integration_linux.cc.patch`, `GetIconName()` | `Icon=` de los `.desktop` que genera el navegador (aplicaciones web sin icono propio) | `brave-browser` | `flyweb` (el paquete instala `hicolor/*/apps/flyweb.png`) |
| `chromium_src/media/audio/pulse/pulse_util.cc` | Nombre e icono en el mezclador de sonido (PulseAudio/PipeWire) | `brave-browser` / «Brave» | `flyweb` / «FlyWeb» |

Con eso la clase de ventana queda «flyweb» / «Flyweb», que casa con `StartupWMClass=flyweb` del `.deb` de
`empaquetar-deb.py`.

**Sin tocar, a propósito:**
- La rama `BRAVE_SNAP=1` (`brave.desktop`): FlyWeb no tiene snap, así que no se llega a ella.
- `chromium_src/chrome/installer/linux/common/brave-browser/*` (`PACKAGE="brave-browser"`, el `id` de `appdata.xml`): son el
  empaquetado de Brave. FlyWeb empaqueta con su propio `empaquetar-deb.py` (`PAQUETE = "flyweb"`), que no los usa.
- `kBrowserProcessExecutableName = "brave"` (nombre del binario): no llega al escritorio, porque el `.desktop` llama a
  `/usr/bin/flyweb`. Cambiarlo movería rutas del paquete.

**Cabecera de `patches/…shell_integration_linux.cc.patch`:** solo cambia la línea `+`. Las líneas `index` son las que traía
Brave y ya no corresponden a la 156 (en la 8078.110 el fichero es otro *blob*). Así venía; `git apply --check` entra
con desplazamiento (-11) sobre la 156.0.8078.110. `media-audio-pulse-pulse_util.cc.patch` no cambia.

## Base y árboles

brave-core `local/322-final` = **060015a802** (ls-remote del 25-11), árbol `fbdf05a0d3`. Con `git am`, árbol **`e2f5cbe6ee`**
(comprobado). No comparte ficheros con `3.2-iconos-linux` (#1245) ni con `3.2-sync-cuenta/0012` (#1242).

## Qué debe comprobar D8-LINUX

1. Con FlyWeb abierto: `xprop WM_CLASS`, y clic en la ventana → `WM_CLASS(STRING) = "flyweb", "Flyweb"`. Con
   `--user-data-dir=X` el primero es `"flyweb (X)"`, como en Chromium. En el dock, la ventana se agrupa con el lanzador de FlyWeb.
2. Paso 2, con el `.deb` instalado:
   - FlyWeb → Ajustes → «Hacer predeterminado»;
   - después, `xdg-settings get default-web-browser` debe dar `flyweb.desktop`, y `xdg-settings check default-web-browser flyweb.desktop`
     debe dar `yes`;
   - en Ajustes debe salir que FlyWeb ya es el predeterminado.
3. Opcional: el mezclador de sonido, con un vídeo sonando, muestra «FlyWeb».
4. `grep -a -c brave-browser` en el binario: lo que quede debe ser texto de Brave que no llega al escritorio (URLs de
   incidencias, nombres de prefs). Si aparece en algo visible, avisad.

## Ficheros

- `0001-linux-present-FlyWeb-as-flyweb.desktop-WM_CLASS-defa.patch` (`git format-patch --full-index`).
- `SHA256SUMS`.
