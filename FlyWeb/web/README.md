# Web flyweb.lamosquita.net

Publicada por LOCAL el 04-10-2026 en ns2 (`/var/www/flyweb.lamosquita.net`, supermosquita:lamosquita, 644/755).
Provisional hasta el diseño del HUMANO (W1 de `../docs/web-flyweb.md`); cubre W2 (privacidad) y W3 (descarga).

- `index.html`: qué es, descarga de la 1.0 (`descargas/FlyWeb-1.0.dmg` y `descargas/FlyWeb-1.0-sha256.txt`),
  instalación, notas de la versión, código y licencias.
- `privacidad.html`: el texto de privacidad (§2 de `web-flyweb.md`), con el plazo de la web: **14 días**
  (`/etc/logrotate.d/flyweb`, registros de `/var/log/flyweb/flyweb.lamosquita.net/`).
- `ayuda/index.html` y `ayuda/sincronizar/index.html` (SERVIDOR-LOCAL, 05-10-2026): ayuda con todas las anclas que abre
  la 1.1.2 (`../docs/web-flyweb.md` §5). Contenido comprobado contra brave-core `c5d7569574e`; el diseño lo hará el HUMANO.
  Se publica con `flyweb-desplegar web <commit> ayuda/index.html <sha256>` (necesita el `flyweb-desplegar` ampliado).
- `estilo.css`: D-DIN y colores del proyecto. El vhost tiene `Content-Security-Policy: default-src 'self'`: nada
  de estilos ni scripts en línea, ni recursos de otros sitios.
- Fuera del repo (en el servidor): `fuentes/` (D-DIN WOFF2 + `OFL.txt`, los de brave-core
  `components/flyweb_ntp/resources/fuentes/`), `img/flyweb.svg` (= `branding/M1-01.svg`) y `descargas/`.
- `VERSION` (SV.6): una línea `<versión> <CFBundleVersion> <DMG> <sha256>` con la versión que describe la web. La
  web se publica sola cuando coincide con la versión aprobada del appcast (`../servidor/web-auto/README.md`). Se
  actualiza en el PR de la web de cada versión.

## Diseño (HUMANO, 06-10-2026; maquetado por SERVIDOR-LOCAL)

Todas las páginas siguen el mismo patrón, sin modo oscuro:
- `<header class="cabecera">` con `.logo` (`img/circulo.svg` + `img/mosca.svg`) y el `h1` (con `<small>` de subtítulo).
- `<main>` con bandas a todo lo ancho: `<section class="banda naranja|blanca"><div class="columna">…</div></section>`,
  alternas. En las blancas los `h2` van en morado; en las naranjas, en negro. Código y direcciones internas
  (`<code>`), en JetBrains Mono y morado.
- `<footer class="pie">` con la mosca del pie dentro del HTML (revolotea solo con CSS) y los créditos.
- Portada: la descarga va en `<div class="descarga">` (el botón y el SHA-256 que comprueba `flyweb-web-auto`) y la
  banda de las notas lleva `id="fin-vuelo"` (hasta ahí vuela la mosca de `mosca.js`).
- Fuentes: D-DIN (en el servidor, como antes) y `fuentes/JetBrainsMono.woff2` (OFL 1.1, variable 100–800, solo
  latín). Con «reducir movimiento», ninguna mosca se mueve.
