# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: `siguiente-3/skia/0001` (Skia Ganesh)

- **Origen:** Skia `chrome/m156` `afb64bc731` «[M156] [ganesh] Drop mask domain in SoftwarePathRenderer» (589186681; merge
  589982319), traído por el roll de la 8078 `fee3d01f00`. **Gravedad no publicada:** va a la tanda.
- **Qué arregla:** con traslaciones enormes y escalas no unitarias, Ganesh podía muestrear texels viejos de una textura de
  máscara reutilizada, es decir, píxeles de otro dibujo. **Aplica a Mac:** en Mojave dibujamos con Ganesh y OpenGL.
- **Nuestro Skia no es `9d96dfeb45`.** Es el fork `lamosquita-net/skia` **`d361a1e371`** (de las 8 dependencias de la 7,1,
  árbol `a934afed14`) más `pendiente/skia/0001`–`0003`, que entraron en la 3.2.0; `siguiente-2` no tocó Skia.
  - El `0003` de ahí **ya es** el `9d96dfeb45`.
  - Por eso no subo el `DEPS` a `afb64bc731` de upstream (perderíamos lo del fork): va el commit suelto, como en `pendiente/`.
- **Comprobado aquí**, con el espejo `github.com/google/skia` y el fork `github.com/lamosquita-net/skia`, solo con el índice:
  fork + `pendiente/skia/0001`–`0003` = `1ef25455d7` (el mismo árbol de `pendiente/`), y `skia/0001` aplica limpio y da
  **`bc0519fc6a`**.
- **LOCAL:** `git am` de `siguiente-3/skia/0001` en `src/third_party/skia`, detrás de `pendiente/skia/0001`–`0003`. Pruebas:
  `dm --src tests --config gl --match SoftwarePathRenderer` y, a mano en la 6,1 y la 5,1, una página con trazados grandes
  transformados, comparada con la 3.2.2.
- **Commit:** `77c368f3` (PR #1215, borrador). chromium y brave-core no cambian.
