# D8-LINUX-6 → COORDINACIÓN-64: iconos de Linux (PR #1245) bien; el binario se presenta como «brave-browser»

(Pegado por D8-LINUX-6 en el chat; lo sube COORDINACIÓN-64.)

**Base:** `0001-branding-FlyWeb-icons-for-Linux-window-launcher-inst.patch`, sha256 `e3881603…c30b356` (coincide). `git am` →
`6e148a4d09`; árbol con U3 1–5 + 0012 + 6 + 7 + iconos: `3ff7299294`. `Release-322-linux` recompilada: cambian solo los
`.pak`.

1. **Icono de ventana** (`_NET_WM_ICON` con xprop, Xvfb, perfil nuevo): 128×128, **la mosca naranja**. La primera vez salió
   el león porque `chrome/app/theme/brave/linux` es una copia que hace `updateBranding` en `npm run build`, y D8 compiló con
   ninja directo; con `updateBranding` sale la mosca. La Release de verdad usa `npm run build`: no pasa. Ningún león en lo
   que instala el .deb ni en la ventana (16, 48, 128, 256). `product_logo_32_development` **no es morado** (igual que el
   normal); el morado solo está en `128_development`. Los `app_list_*` siguen (cuadrícula de Chromium). El lanzador se ve en
   el paso 2.
2. **Problema nuevo:** `WM_CLASS` = «brave-browser», «Brave-browser». `brave/chromium_src/chrome/common/channel_info_posix.cc`,
   `GetDesktopName()`, devuelve fijo «brave-browser.desktop» en compilación oficial e ignora `CHROME_DESKTOP`; de ahí salen la
   clase de ventana y el nombre del icono. GNOME/KDE no casan la ventana con `flyweb.desktop` (`StartupWMClass=flyweb`).
   Además «navegador predeterminado» llamaría a `xdg-settings` con `brave-browser.desktop` (no existe en el paquete) y
   `brave/chromium_src/chrome/browser/shell_integration_linux.cc` busca «brave-browser» en su salida. Propuesta: «flyweb.desktop»
   y «flyweb» en esos dos ficheros. El .deb no se cambia para esconderlo.
3. **empaquetar-deb.py con los iconos de Linux:** diff en la Ubuntu `~/d8-trabajo/entrega-linux/u4/paso1/empaquetar-deb-iconos-linux.diff`
   (contra `e96e3c16`): los 7 tamaños de upstream (16, 24, 32, 48, 64, 128, 256) desde `app/theme/brave/linux` y
   `default_100_percent/brave/linux`; `--iconos` pasa a ser la carpeta `app/theme`. .deb de prueba 2 sha256
   `a95eeb05e05357604c409ade5314a0888deb4bc283e5e3065bf310eb4a33b0d0`. Solo vale con #1245 aplicado.
