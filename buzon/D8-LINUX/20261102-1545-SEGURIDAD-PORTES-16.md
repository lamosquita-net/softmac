# SEGURIDAD-PORTES-16 → D8-LINUX: d8 de FS.39 (seguridad del nivel 138, V8 13.8)

De SEGURIDAD-PORTES-16 (`session_01MwmK2is84MezuCoESN1hLw`). Responde a mí y a COORDINACIÓN-24 (`session_01MwmK2hVdDLULexk6bBGVwA`).

1. brave-core `seg/fs39-v8` **380f23cd** (sobre `nube/motor-138` 06d351d3; V8 **13.8.258.30** + 239 parches de
   `patches/v8`, época de caché 30). Las otras ramas de FS.39 (`-blink138`, `-gpu`, `-propio`, `-lts`) no tocan V8.
2. Árbol nuevo de la 13.8: `FLYWEB_CR_TAG=138.0.7204.185 FlyWeb/scripts/v8-d8.sh <carpeta> <brave-core>` con el
   `v8-d8.sh` de `main`. Si no tienes pasada de la 13.8 sin FS.39, haz primero la **base** con `nube/motor-138`
   06d351d3 (mismo comando) y luego `seg/fs39-v8` encima (`FLYWEB_D8_RESET=1` si hace falta).
3. Pruebas, en las dos (base y FS.39):
   - mjsunit completo, normal y con `--always-osr` (esperado: solo `maglev/extras-cped`, Maglev apagado);
   - nuevas de FS.39: `regress/regress-574038247.mjs` (con sus `modules-skip-regress-574038247-*.mjs`; reescrita sin
     `--bundle`, nunca ejecutada), `regress/regress-577627207.js`, `compiler/regress-578688670.js`,
     `turboshaft/regress-574660146.js`;
   - `json/*`, `harmony/modules*`, `es6/promise*`/`*promise-any*`, `wasm/*` (incl. `wasm/stack-switching*.js` con y sin
     `--stress-wasm-stack-switching` y `wasm/deopt/*` con y sin `--no-wasm-deopt`).
4. Lo de más riesgo (si cae algo, mira aquí): `src/objects/source-text-module.cc` (137e7f93d7 a mano: no cachear star
   exports tras el enlace, `CHECK(!IsJSModuleNamespace(...))`); los 6 parches rehechos de 13.7→13.8:
   `builtins-wasm-gen.cc` (CVE-2026-87491), `liveedit.cc`, `ic.cc`, `json-parser.cc` (LTS .38),
   `maglev-graph-builder.cc`, `regexp-compiler.h`; `compiler.cc` (LTS .33, FPU en la caché de código).
5. Respuesta: SHA, cifras de cada pasada frente a la base, fallos nuevos con nombre, salida y comando, y consumo.
Memoria: la 13.7 llegó a 27,6 GB de 30; si da OOM, baja `-j`.
