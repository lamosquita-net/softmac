# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: libvpx, un arreglo nuevo de la 159 y un hueco de 27 commits en la 156

Vigilancia de las 04:28 UTC (25-11). **Pide decisión** (de Titín, si lo ves así): no he preparado nada.

- **8154 `5c240af776`** (03:23 UTC): «Cherry-pick libvpx 6f89cfbcc9 to m159» (crbug 586941063). libvpx `6f89cfbcc9`
  arregla el codificador VP9 en SVC, que leía el `base_mv` de una capa inferior que no se había codificado. **Se alcanza desde
  una página** (WebRTC con `scalabilityMode` y capas inferiores desactivadas con `setParameters`). Aplica a Mac. Gravedad
  no publicada; sin merge a la 8078 todavía.
- **El hueco:** la 156 usa libvpx `de61454cf8`. La base de la 159 (`fb0a26ad92`) lleva 27 commits más, unos 20 de ellos
  endurecimientos con bug: validaciones en los controles del codificador VP8/VP9 (564326909, 564326761…), el decodificador
  VP8 (571147583), el denoiser (573760540), el SVC de VP9 (575903327, 575939911), `vpx_img_flip`, `mfqe`… Ninguno tiene
  merge a la 8078.
- **Propuesta:** subir libvpx de FlyWeb a `6f89cfbcc9`, igual que hace el commit de upstream: DEPS, `README.chromium` y
  `vpx_version.h`, un `chromium/0015` pequeño. Comprobado: `libvpx_srcs.gni` y `config/mac/x64/vpx_config.h` son
  **idénticos** en la 8078 y la 8154, así que no hay que regenerar nada. El `BUILD.gn` de la 159 solo añade una bandera
  de Chromium que no hace falta. El código del arreglo también entra suelto sobre `de61454cf8`, si se prefiere solo ese.
  - **Coste para LOCAL:** traer la nueva revisión del subrepositorio `third_party/libvpx/source/libvpx` (un `gclient sync`
    normal de ese DEPS, **sin `-D`**) y recompilar libvpx. Pruebas: `media_unittests` de VP8/VP9 y una llamada WebRTC con
    VP9 SVC (L3T3) en la 6,1.
  - Alternativa más conservadora: esperar a ver si upstream lleva el arreglo a la 8078 (M156) y quedarnos solo con eso.
- Anotado en el README de `siguiente-3` (commit `afd79f02`) como propuesta pendiente. Dime si lo preparo y de qué forma.

Además: la 156.0.8078.124 sigue sin entrada en el boletín. Nada más en las ramas.

SEGURIDAD-PORTES-33
