# FlyWeb 3.1.1: contenido cerrado (para la orden a LOCAL)

SEGURIDAD-PORTES-22, 13-11-2026. Encargo urgente de COORDINACIÓN-40: Titín quiere sacar la 3.1.1 ya, sin esperar
al 17-11. **Nada compilado.** Los árboles de abajo salen de aplicar los parches con `git am` en un clon parcial; no hay
rama remota.

## La nota de Chrome 158 no entra: pasa a la 3.1.2

Feed Atom de Chrome Releases, leído el 13-11 a las 08:20 UTC: de la 158 solo hay el «Early Stable» 158.0.8127.36/.37
del 12-11, para Windows («Mac will be coming shortly»), **sin lista de CVE**. Con la nota y el KEV de ese día se hará
la 3.1.2.

- **KEV** (`cve-watch.py --desde 2026-10-15`, catálogo 2026.11.10): 2 de Chromium, los 2 ya triados; 0 nuevos.
- **Notas del 11-11** (157.0.8103.78/.79 estable y 156.0.8078.100 Extended Stable): son la misma tanda que ya cubren
  la 8078 hasta la .103 (serie previa) y la 8103 hasta la .81 (`docs/seguridad-3.1.1.md` §2–§3).

## Base (comprobada con `ls-remote` el 13-11)

| Repositorio | Rama | Commit |
|---|---|---|
| chromium (fork `lamosquita-net/chromium`) | `seg/3.0.2` | `502e3c5b85f534fa6b8c47135f7236b611b7ce1b` (= src de la 3.1.0) |
| brave-core | `local/3.1` | `fc9389773fe0d94338e1cf27e8a2256cbdae676c` |

## Orden de aplicación

**chromium**, sobre 502e3c5b85, con `git am` y en este orden:

| Paso | Parches | Árbol tras el paso |
|---|---|---|
| 1 | [`chromium/`](chromium/) 0001–0034, la serie previa del 12-11 ([README](README.md)) | `3d9092e4e33af893a862d9ad06c553ddf7fc4bbf` |
| 2 | [`chromium/`](chromium/) 0035–0043, el delta de 156.0.8078.104 (abajo) | `d9f6c5c67e7353ec331e83c2271a41d137392cb2` |
| 3 | [`../../parches/3.1.1-catalina/`](../../parches/3.1.1-catalina/) 0001–0004 (MOTOR-45, revisado en #957) | `38c6e1d3e320e606831d633d511f3c80c6fc994f` |
| 4 | **Opcional:** [`v8-15.6.75.59/`](v8-15.6.75.59/) 0001, **solo con d8 y mjsunit en verde** (abajo) | `ff34d8cbc0276d42a821be972daeff247e8e3a0f` |

- Catalina no comparte ningún fichero con la serie de seguridad. Aplicada sola sobre 502e3c5b85 da `35d2c99d7b`, el
  árbol que dio MOTOR-45.
- Sumas antes de `git am`: las de `chromium/` están en `FlyWeb/seguridad/3.1.1/SHA256SUMS` (desde `chromium/`:
  `sha256sum -c ../SHA256SUMS`); `v8-15.6.75.59/`, `brave-core/` y `3.1.1-catalina/` llevan la suya dentro.
- Después, `gclient sync`:
  - V8: 15.6.75.58, o la .59 si entra el paso 4;
  - Skia: 8e7863a6ff;
  - ANGLE (`flynk-b1d`), Dawn, PDFium y ffmpeg: sin cambios.

**brave-core**, sobre `local/3.1`: [`brave-core/`](brave-core/) 0001 (`flyweb_version` 3.1.0 → 3.1.1). Es un solo
commit, aparte, como pide `docs/SEGURIDAD.md`. No hay push desde la nube, así que lo aplica LOCAL con `git am`.

## Delta de 156.0.8078.104 (0035–0043)

La rama 8078 siguió viva: 156.0.8078.104 y V8 15.6.75.59 aparecieron después de la serie previa, ambas comprobadas
con `ls-remote` el 13-11. Los 8 cherry-picks tienen el mismo `git patch-id --stable` que el commit de la 8078 y
llevan `-x`.

| Parche | Commit (8078) | Qué | Bugs |
|---|---|---|---|
| 0035 | 9c37eee | [canvas2d] resolver el filtro del contexto antes de tomar el `PaintCanvas` y el estado | 584579626, 568831763 |
| 0036 | db43049 | [canvas2d] `DrawInternal` dentro de `Draw` (va con 0035) | ídem |
| 0037 | 72d7e62 | [DBSC] borrado de sesiones a salvo de reentrada | 582594431, 575007933 |
| 0038, 0039 | 48607ee, 3e5fc19 | Skia 24e65cdd9b → d35eba7fe6 → **8e7863a6ff**: [skif] `float2` en el desplazamiento del filtro de desplazamiento (584996883, 574222027) y comprobar `vkWaitForFences` (solo Vulkan, inocuo en Mac) | — |
| 0040 | 39b2c48 | `P2PSocketManager::DestroySocket` a salvo de reentrada (WebRTC, proceso de red) | 584996641, 575525274, 579289829 |
| 0041 | 0da3736 | reentrada en el cierre de `P2PSocketManager` (va con 0040) | 575525274, 579289829 |
| 0042 | 0424b83 | [FedCM] salir de `ShowVerifyingDialog()` si la vista se destruye | 583014916, 574609353 |
| 0043 | — | `chrome/VERSION` 156.0.8078.103 → .104 | — |

**Fuera, con motivo:**
- a5e41cc, roll de ANGLE f10470c77e → 2080bf27e5: los dos commits son de Vulkan y del driver IMG, que no se usan en
  Mac. Además, FlyWeb tiene su propio ANGLE (`flynk-b1d`).
- e9c1373 (`src/internal`), los perfiles AFDO y el LKGM de ChromeOS.
- Los 14 «🌺 … test»: solo apagan o arreglan pruebas.

## Paso 4, opcional: V8 15.6.75.58 → .59

Lleva un `[M156]`: af144bc, «Enforce no-JS execution scopes in InvokeApiFunction» (bugs 584997097, 576333024).
`Builtins::InvokeApiFunction` llamaba a los callbacks de C++ sin las comprobaciones de «no ejecutar JS», y
`ValueDeserializer` deja de necesitarlas.

- **Ficheros:** `builtins-api.cc`, `execution.cc`, `api.cc`, `value-serializer.cc` y `v8-function.h`. Los
  `patches/v8` de `local/3.1` no tocan ninguno: van sobre el intérprete, el parser, `version.cc` y `BUILD.gn`.
- **Época de caché:** se queda en 31, por lo mismo que con la .58: `V8_PATCH_LEVEL` sube a 59 y `Hash()` lo incluye.
- **Condición:** la regla de DIRECTIVAS pide d8 y mjsunit con Maglev en verde antes de LOCAL. Para D8-LINUX es la
  misma receta que `mjsunit.md`, con `FlyWeb/v8-revision` = `15.6.75.59`, más `mjsunit/value-serializer.js`.
- **Si no hay verde antes de la orden,** la 3.1.1 sale sin el paso 4 y la .59 va a la 3.1.2. Nada más depende de él.

## Versión y build

| Qué | Valor | Quién y cómo |
|---|---|---|
| `flyweb_version` | **3.1.1** | brave-core 0001, aplicado por LOCAL |
| `FLYWEB_BUILD_NUMBER` | **44** (la 3.1.0 fue la 43) | LOCAL, en `build.sh` |
| CFBundleVersion | **198.63.44** | sale solo: `<flyweb_bundle_version_base>.<build>` |
| `flyweb_bundle_version_base` | `"198.63"` | **ya está** en `local/3.1` (`build/config.gni:37`, comprobado en fc9389773fe). No hay nada que hacer |
| `chrome/VERSION` | 156.0.8078.104 | 0043 |
| `flyweb_engine_full_version` (Client Hints) | 156.0.8078.82, sin cambios | — |
| `kFlyWebCacheEpoch` | 31, sin cambios | — |

## Pruebas para LOCAL

1. **V8:** con la .58, d8 y mjsunit ya están hechos (`mjsunit.md`, #961). Si entra el paso 4, antes el verde de la
   .59.
2. **Perfil PGO de V8:** `download_profiles.py --check-v8-revision`, con la revisión de V8 que quede.
3. **Navegación (`0030`, `0031`):**
   - un popup desde CSP `sandbox` con `allow-popups-to-escape-sandbox`;
   - iframes `about:blank` y `srcdoc`;
   - una página `file://` que abra `about:blank`;
   - claude.ai entero.
   - Si algo falla, el síntoma es un renderer cerrado («bad message»).
4. **FSA con mayúsculas (`0003`):** `showDirectoryPicker()` sobre `~/LIBRARY` tiene que avisar igual que sobre
   `~/Library`.
5. **Huella de Chrome 156** (`motor.md`, principio 13): `https://tls.peet.ws/api/all` desde la app, comparado con un
   Chrome 156 real:
   - JA4;
   - HTTP/2;
   - orden de cabeceras;
   - Client Hints.
   - Riesgo bajo: del delta, 0037 (DBSC) y 0040–0041 (sockets P2P) son de red, pero no tocan TLS, HTTP/2 ni las
     cabeceras que se envían.
6. **Novedades de la .104:**
   - una videollamada WebRTC de 2–3 min, colgando a mitad de una conexión (0040, 0041);
   - una página con `ctx.filter` en canvas 2D, también con un filtro SVG (0035, 0036).
7. **Catalina** (README de `3.1.1-catalina`, pruebas 1–9), en el Mac mini y el MacBook Pro de 2012 (con las dos
   GPU):
   - `comprobar-importes-1015.py` sobre el `FlyWeb Framework` compilado;
   - el `grep` de ANGLE (`chromium/8078..flynk-b1d`) en la 7,1.
8. **Mojave (6,1 y 5,1):** la batería de siempre. Nada de lo de arriba cambia la ruta de 10.14.
