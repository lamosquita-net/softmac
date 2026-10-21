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

## Límites

- `patch --dry-run` sobre ficheros sueltos no compila nada: A no garantiza que el código siga teniendo sentido en la 128
  (por ejemplo, un nombre que cambió).
- En el grupo S3 hay que leer cada X; son los únicos que piden criterio.
