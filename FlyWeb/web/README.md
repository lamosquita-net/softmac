# Web flyweb.lamosquita.net

Publicada por LOCAL el 04-10-2026 en ns2 (`/var/www/flyweb.lamosquita.net`, supermosquita:lamosquita, 644/755).
Provisional hasta el diseño del HUMANO (W1 de `../docs/web-flyweb.md`); cubre W2 (privacidad) y W3 (descarga).

- `index.html`: qué es, descarga de la 1.0 (`descargas/FlyWeb-1.0.dmg` y `descargas/FlyWeb-1.0-sha256.txt`),
  instalación, notas de la versión, código y licencias.
- `privacidad.html`: el texto de privacidad (§2 de `web-flyweb.md`), con el plazo de la web: **14 días**
  (`/etc/logrotate.d/flyweb`, registros de `/var/log/flyweb/flyweb.lamosquita.net/`).
- `estilo.css`: D-DIN y colores del proyecto. El vhost tiene `Content-Security-Policy: default-src 'self'`: nada
  de estilos ni scripts en línea, ni recursos de otros sitios.
- Fuera del repo (en el servidor): `fuentes/` (D-DIN WOFF2 + `OFL.txt`, los de brave-core
  `components/flyweb_ntp/resources/fuentes/`), `img/flyweb.svg` (= `branding/M1-01.svg`) y `descargas/`.
