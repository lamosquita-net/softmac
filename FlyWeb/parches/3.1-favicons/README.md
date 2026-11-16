# 3.1: favicons de la NTP y de `flyweb://version`

Marca escapada que vio Titín en la 3.0.1 (6,1): la pestaña «Nueva pestaña» lleva el logo de Chrome. MOTOR-44, 10-11-2026.

- `0001-…patch` (brave-core, `git am`; binario por las PNG): sobre `bf4262a094` (3.0.0); aplica también sobre
  `local/3.0.1` (`77ae53e`). Licencia MPL-2.0, la de brave-core. **Sin compilar.**
- La 156 trae dos favicons con su logo que las sustituciones de Brave (`updateBranding`, `build/commands/lib/util.js`
  343–347) no cubren:
  - `IDR_NTP_FAVICON` = `chrome/app/theme/default_*/common/favicon_ntp.png`, el logo de Chrome en gris. Lo usan la NTP
    (también la privada), «Novedades» y las tareas contextuales.
  - `IDR_PRODUCT_FAVICON` = `components/resources/default_*/chromium/favicon_product.png`, el logo de Chromium. Lo usa
    `flyweb://version`.
- El parche añade los dos ficheros con la mosca. Son copias de `product_logo_16.png` (M2), los mismos píxeles que el
  resto de pestañas de FlyWeb.
- **Tematizado:** Chromium recolorea el favicon de la NTP porque el suyo es un glifo monocromo. La mosca contra una
  pestaña clara da un contraste de 2,2–2,9, y el umbral de `ThemeFavicon()` es 3,0: saldría como una silueta plana. El
  parche añade las NTP a la excepción que Brave ya tiene para la bienvenida (`chromium_src/chrome/browser/ui/tabs/tab_data.cc`).
  `version` no se tematiza.
- Revisado el resto de `common/favicon_*.png` de la 156 (marcadores, descargas, ajustes, conflictos, gestión,
  complementos) y los favicons de flags, componentes, extensiones y gestor de contraseñas: no llevan marca, o ya los
  sustituye FlyWeb.
- `FlyWeb/branding/scripts/generar-marca.sh` genera ya los dos ficheros desde M2.

**Prueba (LOCAL):** pestaña nueva en tema claro y oscuro, ventana privada y `flyweb://version`, con la mosca en color en
las cuatro. Después de `git am`, `npm run build` ejecuta `updateBranding`, que copia los ficheros sobre `src/`.
