# Parches de seguridad de 2025–2026 sobre la base 128 (FM.31, clase D)

SEGURIDAD-PORTES-4, 21-10-2026. Paso 1, en papel y sin compilar. Base de destino: Chromium **128.0.6613.138**
(Brave 1.69.168); ANGLE `71310277`, Skia `938144dd` (DEPS de la 128). Origen: brave-core `nube/motor-131-anchor-f16`
af0328adeb (la 1.15.2).

## Método (reproducible)

- **Qué entra:** los commits de seguridad de brave-core desde el 29-09-2026 (CVE, crbug, FS.x, `seg/*`), sin
  `patches/v8/` (V8 se queda, clase D aparte) ni pruebas.
- **Cómo se mide:** por cada `.patch`, se reconstruye el diff del arreglo a nivel de Chromium:
  - `116 + .patch del padre → 116 + .patch del commit`, con los ficheros sacados de `raw.githubusercontent.com`.
  - Ese diff se prueba sobre el fichero de la 128 con `patch --dry-run`, primero al revés y luego al derecho.
  - Las rutas `ng/…`/`ng_…` se traducen a las de la 128.
  - Guion de una sola vez, `check.sh`, hecho en la sesión; no está en el repositorio.
- **Códigos:**
  - **R:** ya está en la 128 (el diff entra al revés).
  - **A:** aplica limpio.
  - **F:** aplica con *fuzz*.
  - **X:** no aplica (código cambiado).
  - **N:** el fichero no existe en la 128.
- **Cuándo cuenta X como «ya en la 128»:** solo si upstream lo arregló antes de la rama de la 128 (~22-07-2024) o si lo
  he comprobado leyendo el fichero de la 128 (marcado [V]). Si no, es «adaptar».

## Resultado

### Ya en la 128: desaparecen (no se vuelven a cortar)

| Arreglo de FlyWeb | Upstream | Evidencia |
|---|---|---|
| CVE-2023-6345 (Skia), CVE-2024-4671 (viz), CVE-2023-7024 (WebRTC) | 2023 – mayo de 2024 | anteriores a la rama de la 128 |
| Arreglos de la rama 116 sin versión de macOS (9c752a6954) | 2023 | R / anteriores |
| FS.22, los cuatro críticos de 118–127: CVE-2023-5218 (Site Isolation), CVE-2024-2883, CVE-2024-4058 y CVE-2024-7532 (ANGLE) | M118–M127 | R en la mayoría; `PruneInfiniteLoops` está en el ANGLE de la 128 [V] |
| 12bfef324f99 (campos OOF tras la maquetación de subárbol, F12) | 2023 | `CopyMutableOutOfFlowData` en `layout_result.cc`/`layout_box.cc` de la 128 [V] |
| FS.12: 527e0a1c8a8 y 690ccf3b8df | finales de 2023 | R en `style_containment_scope.cc` y `line_breaker.cc` |
| ORB v0.2, `OriginAgentClusterDefaultEnable`, OOPSIF (función base y arreglos ≤ jul. 2024) | de serie desde la 119–127 | flags de serie |
| 303e498fb5 (`RemoveDanglingMarkupInTarget`, `RemoveDataUrlInSvgUse`) | 119–120 | `status: "stable"` en la 128 [V] |
| FM.22 B, WebAuthn en iframe de otro origen (ab904a465bb) | ≤128 | R en 4 de 5 ficheros |

### A volver a cortar sobre la 128 (41 `.patch`)

| Grupo | Arreglo | Upstream (fecha) | Ficheros (resultado) |
|---|---|---|---|
| **S1 Blink, limpio** | CVE-2026-2441, iterador de `CSSFontFeatureValuesMap` (UAF) | crbug 483569511 (2026) | 1 A (la 128 conserva el puntero crudo [V]) |
| | CVE-2025-4664, *referrer* de la cabecera Link | main #1457510 (2025) | 1 A |
| | Clic sintético en marcos con *popup* aislado | fd7c878da2 (13-08-2026) | 1 A |
| | Claves de `TransferList`/`Attachment` | f66bd3243b (13-05-2026) | 10 A |
| | Alfa de `:visited` en `VisitedDependentContextPaint` | bb0351bff3 (21-05-2026) | 1 A |
| | Copia de las raíces de subárbol en `PerformLayout` (posible UAF) | c215f8e6f0 (2026) | 3 A |
| **S2 GPU** | CVE-2025-6558, ANGLE: *transform feedback* | angle 2f8193ecf (2025) | 2 A + `validationES2.cpp` X (adaptar) |
| | CVE-2026-3909, Skia: atlas de texto | skia 0cab3e4ee (2026) | 6 A + 1 F; `graphite/text/AtlasManager.cpp` N (renombrado; adaptar) |
| **S3 Maquetación** | RubyLB, FS.11 | 56be91796b, 14ce1a8697, c744b03566 (jul.–sep. 2024), a914a61963 (2025), c4b4073953, a88ef98354 (2026) | 3 A + 2 F |
| | FS.12: OOF sin `SetNeedsCollectInlines` entre IFC | cc7d71057b (20-05-2026) | `layout_object.cc` A + `style_containment_scope_tree.cc` X |
| | FS.12: bucle infinito con `shape-outside` y copia de `InlineItem` | d7020222f6 (2025), 9df6f20935 (10-09-2024) | 1 A + 3 X (adaptar) |
| | WebAudio, `automation_rate_` atómico | 8669b50ce1c (crbug 357391257) | 1 X: el 128.0.6613.138 no lo lleva [V] (adaptar) |
| **S4 Extensiones** | OOPSIF: parámetros de la fábrica para marcos aislados | e8dd7bb694 (17-09-2026) | `url_loader_factory_manager.cc` A |

### Van con el nivel que los trae (los vuelve a cortar MOTOR, no esta lista)

- 0e454ce616 (`seg/top-layer-box`): va con 1624b1441b9 (nivel 130, capa superior al final). Sin él no tiene sentido.
- Claves de `RTCDataChannel` (`e8c575a07f`): van con el `RTCDataChannel` transferible del nivel 130.
- ML-KEM (FS.17) y la petición de recursos SVG externos (FS.19): van con el nivel 131.

### Sin cambios

- WebGPU apagado (`chromium_src/gpu/config/gpu_finch_features.cc`): `kWebGPUService` sigue en la 128 [V].
- Los 14 de `patches/v8/`, que siguen la V8 de cada nivel.

## Orden y horas por PR (rama `seg/128-*` sobre la base 128 limpia de la Fase 1)

| PR | Contenido | Ficheros | Horas [H] |
|---|---|---|---|
| 1 | **S1**: todo aplica limpio | 17 | 1,5–2 |
| 2 | **S2**: ANGLE y Skia; 2 ficheros que adaptar | 11 | 2–3 |
| 3 | **S3**: RubyLB, FS.12 y WebAudio; 5 que adaptar | 12 | 3–4 |
| 4 | **S4**: extensiones | 1 | 0,5 |
| | **Total** | **41** | **7–10 h** |

- **Ritmo de las horas:** la aplicación limpia va al ritmo medido de 7–9 ficheros/h; cada X se cuenta a 0,3–0,5 h.
  Las horas no incluyen compilar (LOCAL).
- **Orden:** el 1 primero, porque lleva los dos UAF de 2026 y aplica tal cual.
- **Regla 2:** el 3 toca los mismos `.patch` que MOTOR va a volver a cortar en los niveles 129–131 (`line_breaker`,
  `inline_cursor`, `inline_item*`, `layout_object.cc`). Va primero la seguridad y se avisa a MOTOR-14 antes de abrirlo.
  El 1 roza `local_frame_view.cc`; el 2 y el 4 no cruzan con el motor.

## Corte hecho (SEGURIDAD-PORTES-5, 21-10)

Base: brave-core `nube/base-128` = **6918a99aa6** (commit del tag anotado `v1.69.168`, b44ebef655; sin nada de FlyWeb).
Un PR en borrador por grupo, todos a `nube/base-128` e independientes entre sí:

| Grupo | Rama y commit | PR | `.patch` | Cambios frente a la tabla de arriba |
|---|---|---|---|---|
| S1 | `seg/128-s1` 80c784e3be | brave-core #1 | 17 | Ninguno: todos A |
| S2 | `seg/128-s2` d2be70346b | brave-core #2 | 11 + `util.js` | `validationES2.cpp` adaptado a `ANGLE_VALIDATION_ERROR`; graphite `AtlasManager.cpp` es `TextAtlasManager.cpp` en la 128. Hace falta portar a `util.js` el `applyPatches()` de `patches/third_party/{angle,skia,libvpx}` (Brave 1.69 no parchea esos repos) |
| S3 | `seg/128-s3` 1e9de56f43 | brave-core #3 | 13 | `style_containment_scope_tree.cc` ya está en la 128 [V] (no se corta). **WebAudio:** la 128.0.6613.138 sí lleva 8669b50ce1c (`rate_lock_`), pero `IsAudioRate()` lee sin *lock*; solo se corta eso. `inline_item.h`, `inline_items_builder.cc` e `inline_layout_algorithm.cc`, adaptados a mano |
| S4 | `seg/128-s4` 104f03ab62 | brave-core #4 | 1 | Ninguno |

- **Método:** el `check.sh` de la nota de relevo, que además escribe el `.patch` (`git diff --full-index`, rutas relativas
  al repo del parche) y traduce `ng/` y `NG*`. Cada X y cada *fuzz* se leyó contra el fichero de la 128.
- **Para LOCAL:** los cuatro se aplican juntos sobre `nube/base-128` sin conflictos (no comparten ficheros).

## Límites

- `patch --dry-run` sobre ficheros sueltos no compila nada: A no garantiza que el código siga teniendo sentido en la 128
  (por ejemplo, un nombre que cambió).
- En el grupo S3 hay que leer cada X; son los únicos que piden criterio.

## FS.24: explotados posteriores a la 128 y plan de porte (SEGURIDAD-PORTES-6, 26-10-2026)

Triaje completo en [`cve-triage.md`](cve-triage.md) §0: 16 explotados después de 128.0.6613.138, todos comprobados contra
el código de la base (V8 13.1.201.22, ANGLE `713102774487`, `.patch` de `-p19`). **Dos aplicaban a la 2.0.0 sin arreglo**,
y ambos están portados para la 2.0.1:

| Orden | CVE | Por qué ese puesto | Porte (brave-core, sobre `-p19` 4b4bb3cc68) | `.patch` | Horas medidas |
|---|---|---|---|---|---|
| 1 | CVE-2026-11645 (V8, objetos) | Explotado; JS normal, en el renderer, **jitless no lo mitiga**; afecta a todos los Mac | `seg6/cve-2026-11645` 45f275a00e: v8 3c869652b0 tal cual + época 16 → 17 | `patches/v8/src-objects-js-objects.cc.patch`, `src-utils-version.h.patch` | ~0,2 h (con triaje) |
| 2 | CVE-2025-14174 (ANGLE Metal) | Explotado; escritura fuera de límites **en el proceso GPU** (fuera del sandbox del renderer) por WebGL2; solo en 10.15+ (en Mojave, ANGLE va por OpenGL) | 8528639ead (encima): angle 95a32cb37 tal cual | `patches/third_party/angle/src-libANGLE-renderer-metal-TextureMtl.mm.patch` (nuevo) | ~0,2 h |

- **Regla 2:** ninguno cruza con `-p18`/`-p19` de MOTOR-19 (sus cambios son NTP, `config.js`, `gitPatcher.js`, `config.gni`,
  sync); `patches/v8/` y ANGLE no los toca nadie más.
- **Regla 17 (arreglos posteriores en el mismo código):**
  - V8: después de 3c869652b0 no hay más commits con el bug 506689381; su prueba (`regress-crbug-506689381.js`) se pasa
    en la `d8` 13.1 (abajo).
  - ANGLE: el mismo bug tiene dos seguimientos. **0be1fe5a48** (12-05-2026) unifica en
    `computeRowDepthSkipBytes` el cálculo de pitch y saltos para no usar UNPACK_IMAGE_HEIGHT en subidas 2D (14 ficheros,
    todos los backends): lo motivó un fallo de validación de Metal, y en las rutas 2D de OpenGL (la de Mojave) el
    `imageBytes` mal calculado no se usa (`computeSkipBytes` sin 3D lo ignora). **No se porta** (limpieza amplia sin
    escritura fuera de límites demostrada). **29b4d05425** es solo de Vulkan (no se usa en Mac). Lo que queda con
    `pixelsDepthPitch` en `setPerSliceSubImage` es la ruta PVRTC, que en Mac Intel no se expone (PVRTC solo con GPU
    de Apple).
- **Para LOCAL:** compilar la 2.0.1 con los dos commits (bundle por `buzon`). Prueba de humo del ANGLE: WebGL2 en una
  Mac con Catalina o Monterey (MBP 2015, `about:gpu` con ANGLE Metal): una subida `DEPTH_COMPONENT32F` de 1×512 desde un
  `PIXEL_UNPACK_BUFFER` con `UNPACK_IMAGE_HEIGHT` = 128 (la prueba `PackUnpackTest.D32FSaturateDepth` de 95a32cb37,
  pasada a WebGL2) debe dibujar sin errores y sin caída del proceso GPU.

**Lo que no hace falta portar** (§0 de `cve-triage.md`): 9 ya estaban en la 2.0.0 (S1, S2, `patches/v8/`), 5 no aplican o
están apagados (Windows, ARM64, Maglev, `sort` sin incrustar en la 13.1, WebGPU).
