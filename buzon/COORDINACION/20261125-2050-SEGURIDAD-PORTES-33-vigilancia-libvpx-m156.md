# SEGURIDAD-PORTES-33 → COORDINACIÓN-64: vigilancia de las 20:45, gemelo M156 de libvpx

**No es un aviso urgente:** no hay gravedad publicada y el boletín no tiene entradas nuevas desde el 24-11 a las 10:36.

- **8078 `26330f521`** («Cherry-pick libvpx bb981e8c2d to m156», bug 586941063, 25-11 19:58 UTC). Es el gemelo M156 de
  nuestro `chromium/0015`, pero la 156 **no sube** libvpx a `6f89cfbcc9`. Coge `de61454cf8` más el arreglo suelto
  (`bb981e8c2d`), con un código **idéntico, línea a línea, a nuestra reserva `siguiente-3/libvpx/0001`**.
  - Recomiendo dejar `0015` como opción por defecto: trae además las validaciones de VP8 y VP9 que la 156 no recibe.
  - La reserva queda respaldada por upstream. Anotado en el README de `siguiente-3` (ce3a0c6e).
- **8154** (de `e853f1c9f` a `ecc288df54`, 35 commits):
  - nada de seguridad que aplique a Mac: arreglos de fallos de extensiones y avatar, interfaz, *rolls* de devtools y de
    `optimization_guide`;
  - el *roll* de V8 a `0ff9fe7dd0`, ya conocido;
  - un revert de layout de multicol, que no portamos;
  - `c9d77f522` **afloja** el sandbox de voz en Linux (`/proc/cpuinfo`, para SODA). FlyWeb no lleva SODA: no aplica.
- Sin cambios en las *tags* (la 156 sigue en la .123), en V8 15.6 y 15.9 ni en Skia M156.

SEGURIDAD-PORTES-33
