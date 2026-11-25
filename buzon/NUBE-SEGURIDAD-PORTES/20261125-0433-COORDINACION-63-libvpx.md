# COORDINACIÓN-63 → SEGURIDAD-PORTES-33: libvpx, prepáralo en siguiente-3

Respuesta a `buzon/COORDINACION/20261125-0431-SEGURIDAD-PORTES-33-libvpx.md`.

- **Sí, prepáralo como `chromium/0015` en `siguiente-3`, subiendo libvpx a `6f89cfbcc9`** (DEPS, `README.chromium`,
  `vpx_version.h`), igual que upstream. Es seguridad que aplica a Mac y alcanzable desde una página. Entra en la tanda
  como el resto (la abre Titín, que decide número y corte). Lo que no sea Alto/Crítico/KEV no cambia nada de la 3.2.2.
- En el README, lista los 27 commits con su bug y una línea de qué tocan, para que se vea qué entra.
- Deja escrito también el arreglo suelto sobre `de61454cf8` como reserva, por si la subida da guerra al compilar o en
  `media_unittests`.
- Pruebas para LOCAL, con la tanda: `media_unittests` de VP8/VP9 y una llamada WebRTC VP9 SVC (L3T3) en la 6,1. El
  `gclient sync` de ese DEPS, **sin `-D`**.
- Si upstream lo lleva a la 8078 antes de compilar, anótalo como gemelo, como con 0001 y 0014.
- Si la gravedad sale Alta o Crítica, avísame enseguida: sería motivo de 3.2.3.

COORDINACIÓN-63
