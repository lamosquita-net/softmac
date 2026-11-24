# LOCAL-25 → COORDINACIÓN-62: los 8 commits para la Ubuntu, subidos

Orden `buzon/LOCAL/20261123-1908-COORDINACION-61-ocho-dependencias.md`; sí de Titín en mi sesión (24-11) para crear
los repos públicos. Todos en la rama **`flyweb/321-final`**, con el hash exacto del DEPS de Flynk `local/321-final`
`72f8a7f7`. Comprobados uno a uno con `git ls-remote` contra GitHub.

| Dependencia | Repositorio | Commit | Cómo |
|---|---|---|---|
| skia | https://github.com/lamosquita-net/skia | `d361a1e37122543c2c54fb4136d7232dc49d3ee8` | fork de google/skia |
| angle | https://github.com/lamosquita-net/angle | `271bafce1620bf9e283a394fc2414c74220093f5` | fork de google/angle |
| dawn | https://github.com/lamosquita-net/dawn | `5ee7543174adf616dfa6d22d8d0d0d8eeea72b69` | repo nuevo, historia completa de googlesource |
| devtools-frontend | https://github.com/lamosquita-net/devtools-frontend | `9ec9a3c76ecf1c49cf665d4576e4baba88664be1` | fork de ChromeDevTools/devtools-frontend |
| ffmpeg | https://github.com/lamosquita-net/ffmpeg | `d62d9c00d7ced9922410e6fe1f842f5a52b19a63` | repo nuevo, historia completa de googlesource |
| libaom | https://github.com/lamosquita-net/libaom | `172688efb7f697531888a3184cef24cd0529e7a3` | repo nuevo, historia completa de googlesource |
| libvpx | https://github.com/lamosquita-net/libvpx | `a00f6762dbcd39ebbdae546c514c898257f72c09` | fork de webmproject/libvpx |
| webrtc | https://github.com/lamosquita-net/webrtc | `6a76f7de4c6814d9fb57b70e2957d745e9355e16` | repo nuevo, historia completa de googlesource |

- **Revisión antes de subir:** de 1 a 19 commits por dependencia encima de la base oficial, solo código. No hay datos
  personales ni secretos en los mensajes ni en los diffs. Los autores son de Google o Chromium, o «santintin / LOCAL-19 /
  MOTOR-43 / lamosquita», con el correo `developer@lamosquita.com` (ya público en los forks) o `noreply@anthropic.com`.
- dawn, ffmpeg, libaom y webrtc no tienen espejo oficial en GitHub con su base (o no lo tienen en absoluto). Los checkouts de
  la 7,1 son superficiales y GitHub no acepta una subida así, así que van con la historia completa de googlesource más
  nuestros commits. En los repos nuevos solo está la rama `flyweb/321-final`, que es la rama por defecto.
- La base de webrtc (`19576e3787`) no está en ninguna rama de googlesource que baje un clon normal: hubo que pedirla por hash.
  Si D8-LINUX-6 clona webrtc desde googlesource, que pida el commit por hash, no por rama.
- Clones de trabajo en `temp/local25/deps/` de la 7,1 (bare; se pueden quitar cuando la Ubuntu haya compilado).

## Cruce de Macs Fan Control en M1 (orden 20261124-0846)

No coincide con las lentas. Las 11 pasadas lentas de M1 son las de Aquarium 15000 de m1b: 5 a 1024, 3 a 512 y 3 a 2048,
con 39,7–44 fps. En todas, FlyWeb estuvo delante en todas sus líneas (30 o 31 por pasada). Macs Fan Control estuvo delante
en 818 líneas de m1b: 817 caen dentro de Basemark Web 3.0, lo último de la tanda (969 líneas: 152 FlyWeb y
817 Macs Fan Control), y la otra cae fuera de los casos. En m1c, FlyWeb estuvo delante en todo salvo 35 líneas de Word, fuera
de los casos. m1 (la primera) no tiene `resultados.json`.

## Siguiente

M2 en la 6,1 (Speedometer con sample de la pasada entera, 5 s cada 10 s, para J3 con #1224; y Escudos 3 + 3 alternados).
M3 (a) con el mismo `muestreo61.py` que m3b cuando Titín desbloquee por su cuenta.
