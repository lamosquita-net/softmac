# SEGURIDAD-PORTES-6 → LOCAL: la Release de la 2.0.1 es la `-p20`

Orden de COORDINACIÓN-14 (26-10): **la 2.0.1 se compila desde brave-core `nube/base-128-motor-p20` = 8528639ead**
(`-p19` de MOTOR-19 + dos CVE explotados, un commit cada uno). Si ya empezaste con `-p19`, sigue y compila después
incrementalmente con `-p20`.

1. Trae la rama: bundle `p20.bundle` en la rama `nube/seg6-p20` de softmac (necesita `-p19` 4b4bb3cc68, del bundle de
   `nube/motor19-p19`); los comandos están en su `LEEME.md`. Sube `nube/base-128-motor-p20` a brave-core.
2. Qué trae:
   - 45f275a00e — **CVE-2026-11645** (V8, explotado; jitless no lo mitiga): `patches/v8/src-objects-js-objects.cc.patch`.
     **Sube `kFlyWebCacheEpoch` a 17**: recompila V8 y descarta la caché de código de la 2.0.0 (es lo esperado).
   - 8528639ead — **CVE-2025-14174** (ANGLE Metal, explotado): `.patch` nuevo en `patches/third_party/angle/`.
     Comprueba en el log de `build.sh` que se aplica (los parches de ANGLE los aplica `util.js` desde S2).
3. Pruebas:
   - Las de siempre de la 2.0.1, más claude.ai.
   - La de V8 ya está hecha en la nube: d8 13.1, prueba de regresión y mjsunit.
   - **Del ANGLE, si hay una Mac con 10.15+ a mano** (MBP 2015 con Monterey, `about:gpu` con ANGLE Metal):
     - WebGL2 normal (texturas de profundidad incluidas), sin caídas del proceso GPU.
     - La prueba de upstream `PackUnpackTest.D32FSaturateDepth`: subir una `DEPTH_COMPONENT32F` de 1×512 desde un
       `PIXEL_UNPACK_BUFFER` con `UNPACK_IMAGE_HEIGHT` = 128.
   - En Mojave, ANGLE va por OpenGL: el parche no cambia nada allí.
4. Al terminar, la entrega en la fila de la 2.0.1, como siempre (regla 11).

Detalle: `FlyWeb/docs/seguridad-128.md` (FS.24) y `cve-triage.md` §0, PR #514 de softmac.
