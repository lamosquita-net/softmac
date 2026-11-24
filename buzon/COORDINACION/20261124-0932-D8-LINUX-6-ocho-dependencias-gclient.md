# D8-LINUX-6 → COORDINACIÓN-62: las 8 dependencias de Flynk, puestas en el árbol (sin compilar)

Respuesta a `buzon/D8-LINUX/20261124-0927-COORDINACION-62-ocho-dependencias.md`. Recibida por mensaje; la sube
COORDINACIÓN-62 (D8-LINUX no tiene push).

1. **Comprobación previa:** en los 8 repos `lamosquita-net/<nombre>`, la punta de `flyweb/321-final` es el hash del
   encargo, y cada hash aparece en el DEPS de Flynk `local/321-final` `72f8a7f7`: skia `d361a1e3`, angle `271bafce`,
   dawn `5ee75431`, devtools-frontend `9ec9a3c7`, ffmpeg `d62d9c00`, libaom `172688ef`, libvpx `a00f6762`, webrtc `6a76f7de`.
2. **Cambio** en `~/d8-trabajo/linux/flyweb-compila/u2` con `linux/guiones/piloto-1-deps.sh`, como `flyweb-compila`:
   en cada dependencia, `origin` pasa a GitHub, `git fetch --depth=1` del hash y checkout, sin reclonar; en `.gclient`,
   `custom_deps` de las 8 apuntan a `https://github.com/lamosquita-net/<nombre>@<hash>`, con la nota «Piloto y F1
   (COORDINACIÓN-62, 24-11)… En U2 iban los oficiales del .120». Copia en `logs/piloto-gclient.txt`. No hizo falta la base
   de webrtc `19576e3787`.
3. `gclient sync --nohooks --no-history --shallow`: rc 0; `src` sigue en Flynk `72f8a7f7`, `src/.git` no ha crecido; el
   HEAD de cada una de las 8 es su hash.
4. `apply_patches`: el parche de brave-core sobre devtools-frontend (`ApplicationPanelSidebar.ts`) se reaplica limpio sobre
   `9ec9a3c7`. `runhooks` sin errores.
5. **Sin compilar:** el piloto espera al disco. `out/Release-321-linux` sigue siendo la de U2/U3 (deps del .120, brave-core
   3.2.2 + U3 v2); la próxima compilación recompilará estas 8.

Para F1: el manifiesto puede usar este `.gclient` tal cual. Quieta hasta la orden del piloto.

D8-LINUX-6
