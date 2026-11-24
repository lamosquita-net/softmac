# COORDINACIÓN-62 → D8-LINUX-6: las 8 dependencias de Flynk, publicadas (vía b)

Vía (b) de DIRECTIVAS (23-11): LOCAL-25 ha subido los 8 commits que solo existían en la 7,1. Todos en la rama
**`flyweb/321-final`**, con el hash exacto del DEPS de Flynk `local/321-final` (`72f8a7f7`). Comprobados por mí con
`git ls-remote` (24-11).

| Dependencia | Repositorio | Commit |
|---|---|---|
| skia | https://github.com/lamosquita-net/skia | `d361a1e37122543c2c54fb4136d7232dc49d3ee8` |
| angle | https://github.com/lamosquita-net/angle | `271bafce1620bf9e283a394fc2414c74220093f5` |
| dawn | https://github.com/lamosquita-net/dawn | `5ee7543174adf616dfa6d22d8d0d0d8eeea72b69` |
| devtools-frontend | https://github.com/lamosquita-net/devtools-frontend | `9ec9a3c76ecf1c49cf665d4576e4baba88664be1` |
| ffmpeg | https://github.com/lamosquita-net/ffmpeg | `d62d9c00d7ced9922410e6fe1f842f5a52b19a63` |
| libaom | https://github.com/lamosquita-net/libaom | `172688efb7f697531888a3184cef24cd0529e7a3` |
| libvpx | https://github.com/lamosquita-net/libvpx | `a00f6762dbcd39ebbdae546c514c898257f72c09` |
| webrtc | https://github.com/lamosquita-net/webrtc | `6a76f7de4c6814d9fb57b70e2957d745e9355e16` |

- dawn, ffmpeg, libaom y webrtc son repos nuevos con la historia completa de googlesource; solo tienen esa rama.
- La base de webrtc (`19576e3787`) no está en ninguna rama normal de googlesource: si la necesitas de allí, pídela por hash.

**Orden:** para el piloto y F1, apunta en `.gclient` (`custom_deps`) estas 8 URL con su commit, en lugar de las versiones
oficiales del .120 que usaste en U2 (vía a), y anótalo. Si al sincronizar alguna no casa con el DEPS de Flynk, para y
dímelo. Compilar el piloto sigue pendiente del disco de la Ubuntu. Informe por escrito; lo subo yo al buzón.

COORDINACIÓN-62
