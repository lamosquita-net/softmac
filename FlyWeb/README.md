# FlyWeb

Navegador de lamosquita.net para macOS 10.14 Mojave. Criterio de aceptación: **claude.ai** y la web actual funcionan
por completo.

## Base: Brave 1.57.64

- `brave-core` **v1.57.64** sobre **Chromium 116.0.5845.188**. Chromium 116 es la última versión
  que Google soportó oficialmente en macOS 10.13/10.14. Por eso funciona mejor en Mojave que las
  versiones modernas parcheadas de Chromium Legacy.
- Brave ya está organizado como **parches sobre Chromium**: `brave-browser` (scripts de compilación),
  `brave-core` (código y `patches/`) y `brave/chromium` (Chromium en el tag fijado).
- Alternativa descartada por ahora: [Chromium Legacy](https://github.com/blueboxd/chromium-legacy)
  (Chromium moderno para 10.7–10.14; exige SDK 14+ y clang 18+, y tiene fallos en Mojave).

## Licencias y marca

- `brave-core`: **MPL-2.0**. Los ficheros de Brave que modifiquemos siguen siendo MPL-2.0 y su
  código fuente debe publicarse si distribuimos binarios. Los ficheros nuevos pueden llevar otra licencia.
- Chromium: BSD-3 más licencias de terceros. Hay que distribuir `about:credits`.
- **"Brave" y su logotipo son marcas registradas**: la MPL no da permiso para usarlas. Hay que cambiar
  nombre, iconos, bundle id (`net.lamosquita.flyweb`) y URLs de actualización.
- Hay que desactivar o sustituir los servicios de Brave: actualizaciones, Rewards, Sync, estadísticas
  y claves de API.

## Riesgo principal: seguridad

Chromium 116 es de septiembre de 2023. Desde entonces se han corregido cientos de fallos de
seguridad, varios explotados activamente. Un fork congelado en 1.57.64 es **inseguro por diseño**.
Posibles mitigaciones (hay que decidir cuál):

1. Portar a nuestra base los parches de seguridad críticos de Chromium (V8, Skia, WebRTC, etc.).
   Es mucho trabajo continuo.
2. A medio plazo, llevar los parches de compatibilidad con Mojave de Chromium Legacy a una versión
   más nueva de Brave.
3. Usarlo solo para sitios de confianza (claude.ai, Google Drive, etc.) y no como navegador general.

## Dónde vive el código

El árbol completo (Chromium más dependencias) ocupa entre 100 y 150 GB con la compilación, y no cabe en GitHub.

| Qué | Dónde |
|---|---|
| Nuestros commits sobre Brave | forks [`lamosquita-net/brave-core`](https://github.com/lamosquita-net/brave-core) y [`lamosquita-net/brave-browser`](https://github.com/lamosquita-net/brave-browser), rama **`flyweb`** (desde el tag `v1.57.64`) |
| Árbol de trabajo de los forks | `FlyWeb/brave-core/` y `FlyWeb/brave-browser/`: repos aparte, excluidos por el `.gitignore` de softmac |
| Checkout de Chromium y compilación | `~/proyectos/flyweb-build/`, en local (no se sube ni se sincroniza) |
| Esta carpeta | documentación y `patches/` (parches sobre Chromium que no encajen en `brave-core`) |

Para montarlo en un Mac nuevo, ver la tabla "Estructura en disco" de [`CLAUDE.md`](../CLAUDE.md):

```sh
git clone -b flyweb https://github.com/lamosquita-net/brave-browser.git FlyWeb/brave-browser
git clone -b flyweb https://github.com/lamosquita-net/brave-core.git FlyWeb/brave-core
```

## Compilación

Chromium 116 compila oficialmente con **Xcode 14.3 (14E222b) y el SDK de macOS 13.3**
(`build/config/mac/mac_sdk.gni`: `mac_sdk_official_version = "13.3"`).

- **Host: MacPro7,1** (Sequoia, Xcode 26.3). Usar el `MacOSX13.3.sdk` extraído de Xcode 14.3.1
  mediante `mac_sdk_path`, no el SDK 26.
- **Pruebas: MacPro6,1 y MacPro5,1** (Mojave). Su Xcode 11.3.1 no sirve para compilar Chromium 116.

`mac_deployment_target = "10.13"` es el valor por defecto de Chromium 116, así que no hay que cambiarlo.

## Licencia de esta carpeta

[MPL-2.0](LICENSE), la misma que `brave-core`. Los parches sobre ficheros de Chromium conservan
además la BSD-3 de Chromium.
