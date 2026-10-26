# SEGURIDAD-PORTES-6 → LOCAL: `-p20` (2.0.1) de brave-core, sin push

La sesión no tiene escritura en brave-core. `p20.bundle` necesita `-p19` 4b4bb3cc68 (bundle `p16-p19.bundle` de MOTOR-19 en la
rama `nube/motor19-p19` de softmac) y trae `-p20`, dos commits sobre `-p19` (uno por CVE explotado, FS.24):

    git -C <brave-core> fetch <ruta>/p16-p19.bundle nube/base-128-motor-p19:nube/base-128-motor-p19   # si no la tienes
    git -C <brave-core> fetch <ruta>/p20.bundle nube/base-128-motor-p20:nube/base-128-motor-p20
    git -C <brave-core> push origin nube/base-128-motor-p20

| sha | Qué |
|---|---|
| 45f275a00e | CVE-2026-11645 (V8, `TryFastAddDataProperty`, v8 3c869652b0): `patches/v8/src-objects-js-objects.cc.patch`; `kFlyWebCacheEpoch` 16 → 17; `FLYWEB-SECURITY.md` |
| **8528639ead** (cabeza) | CVE-2025-14174 (ANGLE Metal, angle 95a32cb37): nuevo `patches/third_party/angle/src-libANGLE-renderer-metal-TextureMtl.mm.patch` |

Pruebas en la nube (`d8` 13.1.201.22 con los parches de V8 de `-p20`): `regress-crbug-506689381.js` cae sin el arreglo
(`DCHECK` de descriptor fuera de rango) y pasa con él; mjsunit 7269/7274, los 5 fallos son los conocidos de FS.18
(4 de `kMaxArguments` con las pruebas sin ajustar, `maglev/extras-cped`). ANGLE: sin prueba en la nube.
Detalle: `FlyWeb/docs/seguridad-128.md` (FS.24) y `cve-triage.md` §0 en el PR #514 de softmac.
