# lamosquita-browser

Navegador moderno para macOS 10.14 Mojave. Objetivo de aceptación: que **claude.ai** y la web actual
funcionen por completo.

Base: [Chromium Legacy](https://github.com/blueboxd/chromium-legacy) (fork de Chromium para
10.7–10.14). Licencia: BSD-3 de Chromium, más las licencias de los componentes de terceros
(`LICENSE` y `third_party/*/LICENSE` del árbol de origen). Toda distribución binaria debe incluir
`about:credits`.

## Por qué solo parches y no el código fuente completo

El árbol de Chromium ocupa decenas de GB y no cabe en un repositorio de GitHub (límite de 100 MB
por fichero, repositorios de más de 5 GB desaconsejados). Aquí solo guardamos:

- `patches/` — nuestros parches, aplicados en orden según `patches/series`.
- `scripts/` — (pendiente) descargar Chromium Legacy en un commit fijado, aplicar parches y compilar.

Es el mismo modelo que usa ungoogled-chromium.

## Requisitos de compilación (y el problema)

Según la [wiki de Chromium Legacy](https://github.com/blueboxd/chromium-legacy/wiki/Building):
**SDK de macOS 14 o superior** (con dos parches en cabeceras de GameController) y **clang 18 o superior**.
Xcode 11.3.1 en Mojave **no sirve**. Opciones, por orden de preferencia (pendiente de probar):

1. MacPro6,1 con Monterey, clang de la toolchain de Chromium y el SDK 14 copiado de Xcode 15.
2. Un Mac con macOS 13.5 o superior (Xcode 15+) solo para compilar; se prueba en Mojave.
3. Compilación cruzada desde Linux (Chromium no la soporta oficialmente para macOS).

Tiempos de referencia de la wiki: de 3 a 4 horas o más desde cero con un i9-9980HK.
En la MacPro6,1 (24 hilos) debería ser parecido.

## Hoja de ruta

1. Decidir la máquina de compilación y fijar el commit base de Chromium Legacy.
2. Script `scripts/build.sh` reproducible.
3. Lista de fallos en Mojave (lo que "no funciona" hoy) → issues → parches.
4. Marca propia (nombre, iconos, desactivar servicios de Google que requieran claves).
