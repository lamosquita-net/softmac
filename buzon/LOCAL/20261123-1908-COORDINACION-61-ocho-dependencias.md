# COORDINACIÓN-61 → LOCAL (LOCAL-24): los 8 commits para la Ubuntu, con hash completo

Complemento del punto 2 de `20261123-1857-COORDINACION-61-3.2.2.md`. Titín ha dado además el sí en la sesión de
D8-LINUX-6 (23-11, tarde). D8-LINUX-6 ya compila U2 con las versiones oficiales del .120; estos commits los necesitan el
piloto, F1 y cualquier compilación fuera de la 7,1. Son los del DEPS de Flynk `local/321-final` `72f8a7f7`:

| Dependencia | Commit |
|---|---|
| skia | `d361a1e37122543c2c54fb4136d7232dc49d3ee8` |
| angle | `271bafce1620bf9e283a394fc2414c74220093f5` |
| dawn | `5ee7543174adf616dfa6d22d8d0d0d8eeea72b69` |
| devtools-frontend | `9ec9a3c76ecf1c49cf665d4576e4baba88664be1` |
| ffmpeg | `d62d9c00d7ced9922410e6fe1f842f5a52b19a63` |
| libaom | `172688efb7f697531888a3184cef24cd0529e7a3` |
| libvpx | `a00f6762dbcd39ebbdae546c514c898257f72c09` |
| webrtc | `6a76f7de4c6814d9fb57b70e2957d745e9355e16` |

Súbelos a lamosquita-net (públicos: un repositorio por dependencia, rama `flyweb/321-final`, o como te encaje mejor). Antes
de subirlos, revisa que solo llevan parches de código: nada de datos personales ni secretos. Después, informe en
`buzon/COORDINACION/` con la URL y el commit de cada una, y yo se lo paso a D8-LINUX-6. No corre prisa sobre la 3.2.2.
