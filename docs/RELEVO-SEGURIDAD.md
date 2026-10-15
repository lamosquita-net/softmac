# Relevo de SEGURIDAD-PORTES (15-10-2026)

Para **SEGURIDAD-PORTES-2**, relevo de SEGURIDAD-PORTES (`session_01NkotiT2nNYznsrQu9rssiy`). Leer antes:
`CLAUDE.md`, `docs/TAREAS.md` (tabla, reglas 1–19, filas FS.10–FS.13), `docs/SEGURIDAD.md` y `FlyWeb/docs/cve-triage.md`.
La vigilancia diaria de CVE (FS.2) es de **SEGURIDAD-VIGÍA**; este papel porta y prueba.

**Idioma:** a Titín (el HUMANO), **siempre en castellano**, también justo después de leer commits o notas en inglés.
Commits en inglés.

## 1. Versiones y ramas de seguridad (15-10)

La 1.13 está publicada (157.64.22): `flyweb` = 37197fe04 = `nube/motor-129` 325686916c, cuyos `patches/v8` son
idénticos a `seg/v8-12.9` y el parche de WebAudio, idéntico a `seg/blink-129` (comprobado con `git diff`).

Cada nivel N lleva la V8 de Chrome N. Las ramas `seg/v8-X.Y` de brave-core salen de `nube/motor-N` (o del paso de V8
de MOTOR) y solo tocan `patches/v8/`; MOTOR las funde en `nube/motor-N` y LOCAL compila desde ahí. Cada una tiene
`patches/v8/FLYWEB-SECURITY.md` con su contenido exacto y sus pruebas. Distinguir siempre **«probado en `d8`»** (solo
V8, Linux, en la nube) de **«compilado en FlyWeb»** (LOCAL, en la 7,1).

| Nivel | Versión | V8 | Rama | Época de caché | Fila |
|---|---|---|---|---|---|
| 118–124 | 1.2–1.8.1 | 11.8 … 12.4 | `seg/v8-11.8` … `seg/v8-12.4` | — | FS.4–FS.7 (historia) |
| 125 | 1.9 | 12.5.227.13 | `seg/v8-12.5` 50624c65 | — | FS.7 |
| 126 | 1.10 | 12.6.228.49 (M126-LTS) | `seg/v8-12.6` c3d250ff | — | FS.8 |
| 127 | 1.11 | 12.7.224.20 | `seg/v8-12.7` 94914682 | — | FS.9 |
| 128 | 1.12, 1.12.1, 1.12.2 | 12.8.374.38 | `seg/v8-12.8` 5aa57049 | 12 | FS.10 |
| **129** | **1.13** | **12.9.202.28** | **`seg/v8-12.9` 2ffa1017** | **13** | **FS.13** |

Ramas de Blink (sin V8):

| Rama | Qué | Fila |
|---|---|---|
| `seg/rubylb-128` 44c2af83 | 12 arreglos de caídas y memoria de upstream en el código de RubyLB (6 parches); en la 1.12.1 | FS.11 |
| `seg/inline-116` 907c9507 | deuda de la 116 en LayoutNG inline: CHECK de `NeedsCollectInlines` (posible UAF por *container queries*) en la 1.12.1; d7020222f64 + 9df6f20935b en la 1.12.2 | FS.12 |
| `seg/blink-129` 63ea2663 | `automation_rate_` atómico en WebAudio (8669b50ce1c, crbug 357391257); en la 1.13 | FS.13 |

Ramas viejas sin uso (no borrar sin preguntar): `seg/cve-2024-7971`, `seg/cve-2025-13223`, `seg/v8-groupby-contexto`.
La época **14** se reservó para un plan B de la 1.12.3 que se abandonó (nunca se subió): **no usarla**.

## 2. Lo apagado o distinto de upstream (regla 19)

Principio (Titín, 14-10): lo que FlyWeb apaga se vuelve a encender cuando upstream lo lleva de serie, está maduro y
trae sus arreglos. Valores comprobados en `src/flags/flag-definitions.h` de cada etiqueta de V8.

| Qué | FlyWeb | Upstream | Punto de decisión |
|---|---|---|---|
| `maglev` | apagado (Titín, 05-10; también en la 116) | encendido desde 11.x | **nivel 132** (V8 13.2, M132-LTS, con sus fusiones de Maglev) |
| `maglev_untagged_phis` | apagado (CVE-2026-3910) | encendido | con Maglev, en el **132** |
| `turboshaft_wasm` | apagado (sin parche: es lo de upstream) | apagado en 12.9, 13.0 y 13.1; **encendido en 13.2** | **132**: si upstream lo enciende, regla 19 → encender con sus arreglos (`WasmGCTypeAnalyzer`, `array.fill`, `call_indirect` inlining…) |
| `turboshaft_instruction_selection` | apagado 12.3–12.8; **encendido desde 12.9** | encendido desde 12.5 | hecho (1.13). Con él apagado la 12.9 caía en `ToConstant()` (`kTrustedHeapConstant`) |
| `wasm_to_js_generic_wrapper` | apagado 12.3–12.8; **encendido desde 12.9** | encendido desde 12.3 | hecho (1.13) |
| JSPI, `wasm_deopt`, *stack switching* | apagados (experimentales; Blink 116 no tiene *origin trial* de JSPI) | experimentales | cuando upstream los envíe y Blink los exponga |
| WebGPU (`kWebGPUService`, CVE-2026-5281) | apagado (`chromium_src/gpu/config/gpu_finch_features.cc`, de `nube/webgpu-off`; está en la 1.13) | encendido | **nivel ~140** |
| JIT y WebAssembly | abiertos a todas las webs desde la 1.6 | ídem | interruptor sin recompilar: política `DefaultJavaScriptJitSetting = 2` |

Lo que no es de seguridad (Wallet, Rewards, News, Talk, Leo, VPN, P3A, Omaha) está en `CLAUDE.md`, no aquí.

## 3. Lo que espero de la 13.0 (nivel 130, FS.14)

Empieza cuando MOTOR-9 abra el paso de V8 13.0 (`nube/motor-130` o la rama de paso que indique). Regla: **la 1.14
no sale con menos arreglos de V8 que la 1.13**.

1. **Ronda `seg/v8-13.0`** desde la rama de MOTOR-9. Partir de los parches de `seg/v8-12.9` y clasificar cada uno
   contra la 13.0 limpia: `git apply --check` (falta), `git apply -R --check` (ya está), conflicto → a mano. Ya
   comprobado en el historial de V8: **a7c018806, 153d4e84e y bc67262 son antecesores de 13.0.245.25** (sobran);
   94e495e1d, 34587b687, fc26d62d0, 357d0dd4 y 279d28029 **no** lo son (comprobar con `-R`; si no están, portarlos).
2. **Fusiones posteriores:** las de la rama 13.0 por encima de la revisión que fije MOTOR-9, más 13.1.201.22 y
   13.2.152.56 (M132-LTS), contra la 13.0. Ojo: lo que di por «no aplicable» en la 12.9 porque nació en la 13.0
   **puede aplicar ahora**: la caché global de *regexp* ATOM, los arreglos de tipos canónicos de 13.x y, si la 13.0 ya
   la tiene por proceso, la caché de *wrappers* de importación (`is_dying_`, crbug 391907159). Maglev y
   Turboshaft-Wasm siguen sin aplicar (apagados) hasta el 132.
3. **Época de caché:** una nueva, mayor que 13 y que la que ponga MOTOR-9 en su paso; nunca la 14.
4. **Pasada de API del embedder 12.9 → 13.0:** `git diff 12.9.202.28 <revisión> -- include/` y revisar lo que Blink
   adapte MOTOR-9 (como en la 12.9 con `FastApiCallbackOptions`: los callbacks rápidos lanzan ellos mismos).
   Mirar sobre todo: callbacks rápidos, `ExceptionPropagationCallback`, etiquetas de punteros externos y del
   *sandbox*, `CppHeap`/cppgc y constantes de `Internals`.
5. **Opciones:** confirmar con `d8 --print-flag-values` que siguen `--no-maglev --no-maglev-untagged-phis
   --turboshaft-instruction-selection --wasm-to-js-generic-wrapper` y que la 13.0 no enciende nada nuevo de JIT; si
   lo hace, avisar a COORDINACIÓN y a Titín antes de decidir.
6. Lo nuevo que una web pueda alcanzar en el nivel 130 (APIs que MOTOR-9 porte a Blink): buscar en Chromium 130–132
   y `main` los arreglos posteriores de esos ficheros, por fichero y no por `--grep` (así salieron los de RubyLB).
7. `d8`: pruebas de `FlyWeb/tools/v8-pruebas/`, regresión de cada arreglo portado y mjsunit completo (en la 12.9,
   7216/7217; el fallo es `maglev/extras-cped`, que exige código de Maglev). `FLYWEB-SECURITY.md` de la rama y fila
   FS.14 con el commit.

## 4. Riesgos abiertos (anotados, sin portar)

- a7c018806 (crbug 364917763; nunca se fusionó a una rama de release): posible confusión de tipos en la conversión
  JS→Wasm a tipos solo-nulos; **afecta a 1.11–1.12.2**, no confirmada, gravedad media-baja. Titín decidió no sacar
  1.12.3: lo cubre la 1.13 vía Sparkle.
- Igual que antes: las 1.4–1.6 (12.0–12.2) no llevan la M126-LTS; quedan superadas por Sparkle.
- No portados a propósito en FS.12: b94803ac920 y la conversión a `raw_ptr` (demasiado amplios para la 116).

## 5. Entorno y trampas de la `d8`

- El contenedor es efímero: `FlyWeb/scripts/v8-d8.sh` lo rehace todo desde GitHub y commondatastorage (googlesource y
  CIPD están bloqueados). Para no recompilar: `FLYWEB_D8_NO_BUILD=1 v8-d8.sh <carpeta> [brave-core]` y luego `ninja`.
- **Memoria: el contenedor tiene ~15 GB; `ninja -j32` se queda sin memoria.** Usar `-j8`, o `-j4` en los enlaces.
- En el árbol de la `d8`, quitar los ganchos de Brave: `BUILD.gn` importa `//brave/v8/sources.gni` y
  `src/codegen/compiler.cc` usa `BRAVE_COMPILER_GET_FUNCTION_FROM_EVAL`; si no, falla `build.ninja.stamp`.
- **Desde la 12.9**, `BUILD.gn` importa `//third_party/icu/config.gni`: basta un fichero mínimo con
  `icu_use_data_file = false` (si no, `gn gen` pide `copy_icudata`). Sin ICU no se prueba Intl.
- Regenerar parches: rama temporal con **solo** los commits de seguridad (nunca los de pruebas de la `d8`),
  `git diff --full-index` desde la revisión fijada, un `.patch` por fichero, nombre = ruta con `/` → `-`.
- `git am` puede fallar por falta de blobs para el 3-way en clones parciales: `git apply` y revisar a mano.
- `git worktree add` con ruta relativa la crea dentro del repo: rutas absolutas.
- `patch -F3` puede dejar un trozo en un sitio equivocado (comentarios, `switch`): revisar siempre con `git diff`.
- Para matar procesos, `ps` y `kill <PID>`; `pkill -f` con un patrón mató la shell.
- `d8` sin fichero espera en modo interactivo: `-e '' < /dev/null`.
- La `d8` compila con la libstdc++ del sistema: no ve los `#include` que faltan con la libc++ de Chromium (caso
  `<iomanip>`); eso lo encuentra LOCAL.
- **No preparar pruebas de concepto ni variantes de exploits**: un clasificador de seguridad paró dos veces ese
  trabajo. Validar con las pruebas de regresión de upstream, mjsunit y revisión de código.
