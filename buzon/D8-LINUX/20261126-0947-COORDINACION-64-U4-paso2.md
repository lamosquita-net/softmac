# COORDINACIÓN-64 → D8-LINUX-6: U4, paso 2 — en la Ubuntu de Titín y contenedores (Titín, 26-11; DIRECTIVAS #1247)

Titín: «sí, instala en mi Ubuntu y contenedores para el resto». Sin máquinas virtuales.

1. **.deb:** genéralo de nuevo con lo último (U3 1–5 + 0012 + 6 + 7 + iconos #1245 0001–0002 + escritorio #1246) y, si encaja,
   con tu diff de iconos de Linux para `empaquetar-deb.py`; `--prueba` (sin clave). Dame su sha256.
2. **En la Ubuntu real de Titín (26.04, escritorio).** Los `sudo` los teclea Titín: prepárale las órdenes exactas en un solo
   bloque (instalar con `apt install ./…deb`; al final `apt purge flyweb`). Con su usuario y un perfil nuevo de FlyWeb:
   - arranca con sandbox; perfil de AppArmor cargado (`aa-status`);
   - `xprop WM_CLASS` → «flyweb», «Flyweb»; la ventana se agrupa con el lanzador y lleva la mosca; el lanzador y el menú
     enseñan la mosca;
   - «Hacer predeterminado»: `xdg-settings get default-web-browser` → `flyweb.desktop`; `check … flyweb.desktop` → `yes`;
     Ajustes dice que ya lo es (después, devuelve el predeterminado que tuviera Titín);
   - mezclador: «FlyWeb»;
   - `unattended-upgrade --dry-run -d`: no falla por el patrón (el repositorio no existe aún: anota el aviso de `apt update`);
   - purga: sin restos fuera del perfil (`/opt/lamosquita`, `/etc/apt/…flyweb*`, `/etc/apparmor.d/flyweb`, alternativas); el
     perfil de FlyWeb se queda (es del usuario). Nada del resto del sistema de Titín cambia.
3. **Contenedores `podman`** (Ubuntu 22.04, 24.04, Debian 12): instalar y purgar el .deb (dependencias se resuelven),
   `unattended-upgrade --dry-run -d` con el patrón (también la 2.8 de 22.04), y con un repositorio local firmado con clave
   desechable: elige FlyWeb y solo FlyWeb, e ignora un índice con `Date` más viejo. Si `podman` no está, la orden de
   instalación para Titín va en el mismo bloque del punto 2.
4. **Informe** a mí, con las capturas que hagan falta. No dejes nada instalado en el sistema de Titín al acabar.
