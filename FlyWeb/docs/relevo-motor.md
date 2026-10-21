# Relevo de MOTOR: de MOTOR-14 a MOTOR-15 (21-10-2026, ~20:00)

MOTOR-14 (`session_01PZNSmdebZSnLvAr2v93osp`, Opus 5.5, `xhigh`) cerró FM.28 (la 1.15.2 publicada desde la F16), midió y
canceló FM.29 (Titín, 21-10) y abrió la **Fase 3, clase D** de la migración a la 128 (fila FM.31). **Tu encargo: los pasos
(2)–(5) de la clase D** sobre `nube/base-128-motor`. La medida y el orden están en la fila FM.31 («FASE 3, CLASE D») y en
`FlyWeb/tools/port/d128-medida.tsv`; aquí, lo que no está allí.

**Ramas de brave-core:**

| Rama | Cabeza | Estado |
|---|---|---|
| `nube/base-128` | 6918a99aa6 | Brave 1.69.168 exacto (upstream), de SEGURIDAD-PORTES-5. Base común; no se toca |
| `nube/base-128-motor` | **3419255c87** | `-p1` + `seg/128-s3` 1e9de56f43 (S3 de SEGURIDAD-PORTES-5, fundido por regla 2; sin ficheros en común con el paso 1). **Desde aquí sigue MOTOR-15** |
| `nube/base-128-motor-p1` | 492dffb41d | **paso (1) hecho**: V8 13.1.201.22 (`FlyWeb/v8-revision`), los 63 `patches/v8` de la 1.15.2, `fast_float`, gin sin `ZoneBackingAllocator` (abf6e5b63e6) y upstream 8e42980ed5d (colas de V8 UserVisible/BestEffort; en la 116 fue la «opción B»). Sin compilar |
| `nube/motor-131-anchor-f16` | af0328adeb | la 1.15.2 publicada; referencia de flags y de lo hecho a mano |

**Pasos que quedan (aprobados por COORDINACIÓN-11):** (2) niveles 129 → 130 → 131, commit a commit, en el orden de
`d128-medida.tsv`; (3) anchor (26 commits, más 1624b1441b9 + 0e454ce616); (4) flags y lo hecho a mano, comparando el json5
de la nueva rama con el de la F16 (`flags-nivel.py`), más ML-KEM (net: 1fef3fb10d7, 4beeb73c814; BoringSSL: 500fa1f9d,
f1b043c28, 06aff989b, 7fb4d3da5, 72a60506d sobre la de la 128, f01108e4) y las claves de `RTCDataChannel` (e8c575a07f de
FlyWeb) con el 130; FS.19 desaparece; (5) puntos de compilación. **No pidas la 7,1 hasta tener (2)+(4)** (LOCAL-7 está con
Dawn y Brave 1.69).

**Condiciones:**

- **Regla 2, S3 de seguridad ya está dentro** (`seg/128-s3` 1e9de56f43, fundido en 3419255c87; SEGURIDAD-PORTES-5
  `session_01H7fz6r296TWMGBgDfYzRgX`). Toca `inline/line_breaker.*`, `line_info.cc`, `inline_cursor.cc`,
  `justification_utils.cc`, `logical_line_builder.cc`, `inline_item.*`, `inline_items_builder.cc`,
  `inline_layout_algorithm.cc`, `layout_object.cc`, `css/resolver/style_adjuster.cc` y `webaudio/audio_param_handler.h`:
  al portar ee5d3f203d9 (N130), 1fea2fe8c97 (N131), af046fa668e (anchor) u otro commit sobre esos ficheros, el área se
  monta desde **el parche de S3**, no desde el de Brave, y el resultado lo sustituye. S1 roza `local_frame_view.cc`.
- **Includes sin cabeceras precompiladas** (`TRAMPAS.md`, MOTOR): la Release de la 1.15.2 falló por eso. En el paso (5),
  el primer punto de compilación con `enable_precompiled_headers=false`.

**Entorno** (lo montado aquí, ~20 min; nada queda en la nube):

- Historia de Chromium sin blobs, con las etiquetas 116, 128.0.6613.138, 129.0.6668.112 y 131.0.6778.264:
  `git init` + `git fetch --filter=blob:none --shallow-since=2023-05-15 origin refs/tags/<tag>:refs/tags/<tag>` (~500 MB).
- Copias parciales `mkcr.sh /tmp/claude-0/port/cr128 128.0.6613.138` (y `cr131`), con `/content/browser/`, `/cc/`,
  `/components/viz/`, `/services/`, `/net/` y `/base/tracing/protos/` añadidos al sparse.
- `patches/` de Brave v1.69.168: `git fetch --depth 1 origin refs/tags/v1.69.168` de `brave/brave-core` y
  `git checkout v1.69.168 -- patches chromium_src`.
- `medirbase.sh` (nuevo) mide sobre esa base; para portar, el área se monta igual: copia de `cr128` + parche de Brave del
  fichero si existe, commit «128», aplicar el commit de upstream y `git diff --full-index <commit 128>` por fichero a
  `patches/<ruta-con-guiones>.patch` (el parche incluye lo de Brave, como en la 116).
- V8: `github.com/v8/v8` con `--filter=blob:none --depth=1` de 6f774f92 (12.8.374.31, la de la 128) y 9c09e787 (13.1.201.22).
  BoringSSL: `github.com/google/boringssl` (googlesource da 403 por el proxy).

**Trampas nuevas:**

- **Sobre la 128 no hace falta el traductor de LayoutNG** (`ngmap.json`): la 128 ya usa los nombres nuevos.
- **Muchos commits de la 131 dependen de otros posteriores a la 128 que no portamos**: el rechazo de 8e42980ed5d era
  `SetCanBeDeferredForRendering`, de un commit de `DeferRendererTasksAfterInput`. Adaptar el hunk; no arrastrar el otro
  commit si no es del nivel.
- **No trabajes encima de una rama de punto de compilación ya entregada** (`-pN`): cada punto, rama fija nueva.

---

**Relevos anteriores** (MOTOR-2 a MOTOR-14): [`relevo-motor-historial.md`](relevo-motor-historial.md).
