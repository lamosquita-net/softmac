# Relevo del agente SEGURIDAD (08-10-2026)

Para la sesión que sigue a SEGURIDAD. Leer antes: `CLAUDE.md`, `docs/TAREAS.md` (filas FS.*), `docs/SEGURIDAD.md`
(procedimiento) y `FlyWeb/docs/cve-triage.md`. Los tres están al día en `main` desde el 09-10 (PR #72 fusionado,
dac9ac98).

> **Relevo hecho (09-10-2026).** El papel se partió en SEGURIDAD-PORTES (`session_01NkotiT2nNYznsrQu9rssiy`, que tomó
> FS.3, FS.8 y FS.9) y SEGURIDAD-VIGÍA (vigilancia de CVE; ver `docs/TAREAS.md`). Por eso, con el visto bueno del
> HUMANO, se fusionó el PR #72 y se desactivó la rutina diaria de la sesión saliente (`trig_017eHmWVtUM8zquwVjXRAvAD`,
> sección 4): lo que esta nota dice sobre ella y sobre el PR es historia.

**Idioma:** al HUMANO, **siempre en castellano**, también justo después de leer commits o notas en inglés (es un
despiste que ha pasado varias veces). Commits en inglés.

## 1. Estado de las versiones y de las ramas de seguridad (08-10, mediodía)

Cada nivel N lleva la V8 de Chrome N (FM.5). Mis ramas `seg/v8-X.Y` de brave-core salen de `nube/motor-N` y solo
añaden `patches/v8/` (y, en la 12.3, `flyweb_version`). LOCAL compila desde ellas (a veces con una rama
`local/motor-N-arreglos` encima, que debe **contener** la mía).

| Nivel | Versión | V8 | Rama de seguridad | Estado |
|---|---|---|---|---|
| 118 | 1.2 | 11.8.172.18 | `seg/v8-11.8` 75bee800 | publicada |
| 119 | 1.3 | 11.9.169.7 | `seg/v8-11.9` cbf720c9 | publicada |
| 120 | 1.4 | 12.0.267.36 (M120-LTS) | `seg/v8-12.0` 0640a4be | publicada |
| 121 | 1.5 | 12.1.285.28 | `seg/v8-12.1` 23da5621 | publicada |
| 122 | 1.6 | 12.2.281.22 | `seg/v8-12.2` 1d7c7f69 | publicada (JIT abierto desde aquí) |
| 123 | 1.7 / **1.7.1** | 12.3.219.16 | `seg/v8-12.3` **5cb5bbe2** | 1.7.1 publicada (`flyweb` = b71c7a5e) |
| 124 | 1.8 / 1.8.1 | 12.4.254.15 + ac8da461 | `seg/v8-12.4` **d88873b8** | 1.8 publicada (desde `local/motor-124-arreglos`, que añade `<iomanip>` en V8); 1.8.1 = `nube/v1.8.1` (funciones, no seguridad) |
| 125 | 1.9 | 12.5.227.13 | `seg/v8-12.5` **d69f81aa** | lista para compilar (lleva FM.12, F7.8 y `getHTML()`; = `local/v1.9` 24ffcf37); en seco 1017/1017 sobre la 116 antes de esa fusión |
| 126 | 1.10 | 12.6.228.49 | `seg/v8-12.6` **00cef94c** | parches de V8 de la sesión nueva (67d7fdbf) + FM.12, F7.8 y `getHTML()` (fusión de `nube/motor-126` d2a823f3) |

Cada rama tiene `patches/v8/FLYWEB-SECURITY.md` con su contenido exacto y las pruebas hechas. Distinguir siempre
**«probado en `d8`»** (solo V8, Linux, en la nube) de **«compilado en FlyWeb»** (lo hace LOCAL en la 7,1).

**08-10, 18:40 — no deshacer:** las fusiones d69f81aa y 00cef94c las aprobó el HUMANO; cualquier cambio en esas ramas parte de ellas.

## 2. Decisiones en vigor (no cambiarlas sin el HUMANO)

- **JIT y WebAssembly abiertos a todas las webs desde la 1.6** (HUMANO, 07-10). Interruptor de emergencia sin
  recompilar: política `DefaultJavaScriptJitSetting = 2`. Por eso la revisión es **diaria** y el objetivo es
  **≤ 48 h** desde un zero-day de V8 que aplique hasta la 1.x.y con el parche.
- **Maglev apagado** en todas las V8 de nivel (`maglev` = false) y `maglev_untagged_phis` = false (CVE-2026-3910).
- **Selección de instrucciones de Turboshaft apagada** (`turboshaft_instruction_selection` = false) desde la 12.3.
- **Wrapper genérico wasm→JS apagado** (`wasm_to_js_generic_wrapper` = false) en 12.3 (1.7.1), 12.4 y 12.5, como
  estaba hasta la 12.2. En la 12.3 hizo falta además recuperar el interruptor de la 12.2 en
  `GetOrCreateWasmInternalFunction` (porte de c8c02de5); en 12.4/12.5 basta la opción.
- **CVE-2026-87491** solo se porta desde la 12.3 (el sandbox de V8 es frontera desde Chrome 123).
- El **tercer dígito** es de SEGURIDAD: `flyweb_version` en `build/config.gni`, commit aparte, solo sobre el último
  nivel publicado. `FLYWEB_BUILD_NUMBER` lo pone LOCAL.
- Nunca: escribir en `flyweb`, forzar push en ramas compartidas, reescribir a mano un porte de motor de NUBE, secretos
  en el repo, `gclient sync -D`. Push directo solo de las filas FS.* de `TAREAS.md`; lo demás por PR.

## 3. Pendiente: FS.8, nivel 126 (V8 12.6.228.49) para la 1.10

Base: `nube/motor-126` (20ecf145 o posterior; NUBE ya llevó ahí los arreglos de LOCAL de la 1.8). Pasos:

1. Rama `seg/v8-12.6` desde `nube/motor-126`. Partir del conjunto de `seg/v8-12.5` y clasificar cada parche contra
   la 12.6 limpia (`git apply --check` = falta; `git apply -R --check` = ya está; conflicto = mirar a mano).
   La 12.6.228.49 **es** la M126-LTS: deberían sobrar casi todos los arreglos de la M126-LTS que porté a 12.3–12.5,
   y también los de la M120-LTS. Lo que seguro hay que comprobar: CVE-2025-13223 (+ 9b5250b9), CVE-2025-5419 y
   Turboshaft A3/A4/A6, CVE-2025-6554 (NUBE dice que lo rehízo limpio: comparar con el mío), CVE-2026-87491,
   CVE-2024-7971, `groupBy` (77df647d + 92aba703) y `kFlyWebCacheEpoch`.
2. **Arreglos posteriores a la M126-LTS (desde 01-2025):** la M126-LTS terminó; la siguiente LTS de Google es la
   **M132-LTS (V8 13.2.152.x)**. Listar sus fusiones (`git ls-remote --tags https://github.com/v8/v8
   'refs/tags/13.2.152.*'`, traer la última etiqueta con `--depth` ~200 y `git log -E --grep='Merged|LTS'`) y
   clasificarlas contra la 12.6 igual que en el paso 1. Es la fuente principal de arreglos de 2025 para nuestras V8.
3. Opciones (`src/flags/flag-definitions.h`): Maglev, `maglev_untagged_phis`, `turboshaft_instruction_selection` y
   `wasm_to_js_generic_wrapper` apagados. Ojo: la 12.6 ya trae c8c02de5 y 8d6bd5e1, así que el *wrapper* genérico
   podría quedarse encendido; por coherencia con 1.7.1–1.9 lo dejé apagado en todas. Mirar también si la 12.6
   enciende por defecto algo nuevo (`turboshaft_wasm`, `turbolev`, *load elimination*…): si es así, apagarlo y
   avisar al HUMANO, como con Maglev.
4. `d8`: `FlyWeb/scripts/v8-d8.sh <carpeta> <worktree de seg/v8-12.6>` (ya baja FP16). Pasar las pruebas de
   `FlyWeb/tools/v8-pruebas/`, las de regresión de cada arreglo portado, `groupBy` 17 M → `RangeError` y mjsunit
   completo (`tools/run-tests.py --outdir=out/x64 -j4 mjsunit`). Con 4 núcleos, la `d8` tarda ~1 h 30 y mjsunit ~1 h.
5. Comprobar en seco los parches de Chromium: `FlyWeb/scripts/chk116.py`. **Nuevo en el 126:** NUBE añadió parches
   en `patches/third_party/pdfium/` (otro subrepo): el script los dará como «sin base» si PDFium no está en el clon
   parcial; comprobarlos aparte o pedírselo a LOCAL.
6. `FLYWEB-SECURITY.md` de la rama, nota en `TAREAS.md` (fila nueva FS.8) con el commit para LOCAL.

## 4. Revisión diaria (FS.2)

Hoy la lanza una rutina («SEGURIDAD: revisión diaria de CVE», `trig_012mAwnVKtRrskyyVN2XAUGC`, cada día a las 8:52
hora de Madrid) **atada a la sesión saliente**. La sesión nueva debe crear la suya (mismo texto) y pedir al HUMANO
que desactive o borre la antigua, para que no salten dos. Lo que hace cada día:

1. `python3 FlyWeb/scripts/cve-watch.py` (catálogo KEV de CISA contra `cve-triage.md`).
2. Prensa: zero-days de Chrome/V8 posteriores al último anotado (hoy, **CVE-2026-87491**, 08-09-2026). El blog de
   Chrome Releases no se puede leer desde el contenedor.
3. Fusiones nuevas en las ramas de V8 por encima de la V8 del último nivel publicado (hoy 12.4–12.6; con la 1.10, la
   M132-LTS) y si aplican a nuestras `seg/v8-*`.
4. Notas nuevas de LOCAL y NUBE para SEGURIDAD en `TAREAS.md`; si LOCAL toca `patches/v8/`, revisarlo (último
   caso: `<iomanip>` en `wasm-disassembler.cc` para la 12.4, correcto y sin efecto en la seguridad).
5. Una línea en FS.2 y el periodo de `cve-triage.md` (PR #72). Si algo explotado aplica: urgencia al HUMANO y
   porte en una rama `seg/*`.

## 5. Riesgos abiertos conocidos (anotados, sin portar)

- 31c7633a / 74d82249 (M126-LTS, compactación de la EPT durante el *scavenge*): escritos para el montículo de la
  12.6, no aplican tal cual a 12.3–12.5; un fallo de tiempos del GC que una página no dispara directamente. La 12.6
  ya los trae.
- Las 1.4–1.6 publicadas (12.0–12.2) no llevan los arreglos de la M126-LTS; quedan superadas por las versiones
  nuevas vía Sparkle.
- La M126-LTS no cubre nada de 2025 en adelante: es lo que aporta el paso 2 de FS.8 (M132-LTS) para todos los niveles.

## 6. Entorno y trampas

- El contenedor es efímero: las `d8` y los clones se pierden. `v8-d8.sh` lo rehace todo (GitHub y commondatastorage;
  googlesource y CIPD están bloqueados). Un clon de brave-core con `--filter=blob:none` y *sparse-checkout* de
  `patches/v8`, `build` y `FlyWeb` basta; los `.patch` de Chromium se leen con `git show` / `git cat-file`.
- `git worktree add` con ruta relativa la crea dentro del repo: usar rutas absolutas.
- `patch -F3` (contexto flexible) puede dejar un trozo en un sitio equivocado (me pasó dentro de un comentario y dentro
  de un `switch`): revisar siempre el resultado con `git diff`.
- Para matar procesos, buscar el PID con `ps` y `kill <PID>`; `pkill -f` con un patrón mató la shell.
- `d8` sin fichero espera en modo interactivo: `-e '' < /dev/null`.
- La `d8` compila con la libstdc++ del sistema: no ve los `#include` que faltan con la libc++ de Chromium 116 (el
  caso `<iomanip>`); eso lo encuentra LOCAL.
- Un clasificador de seguridad bloqueó una vez preparar variantes de un exploit para una prueba de regresión: no
  insistir; usar las pruebas de regresión de upstream.
