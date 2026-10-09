# Pruebas de V8 para los portes de seguridad

Se pasan con un `d8` de la V8 del nivel que toque (`FlyWeb/v8-revision`), compilado con `FlyWeb/scripts/v8-d8.sh <carpeta> <brave-core>`, no con FlyWeb
(usan `%` de `--allow-natives-syntax`). Copiar los `.js` a `test/mjsunit/compiler/` (o `regress/wasm/` el de Wasm) del
árbol de V8 y ejecutar `tools/run-tests.py --outdir=out/x64 mjsunit/compiler/<nombre>`, que aplica la línea `// Flags:`.

| Fichero | Origen | Comprueba |
|---|---|---|
| `regress-360700873.js` | V8 4ddcbf2 | CVE-2024-7971: falla (aborta) en la 11.6 sin parche, pasa con `seg/cve-2024-7971` |
| `regress-475479135-1.js`, `-2.js` | V8 9b5250b9 | El fallo que introducía el arreglo de CVE-2025-13223 si se portaba sin la dependencia de representación |
| `flyweb-13223-mixed.js` | SEGURIDAD | CVE-2025-13223: ampliación del almacén de propiedades optimizada con campos Smi, Double, HeapObject y Tagged mezclados con accesores; con `--trace-turbo-graph --turbo-filter=extend` se ve el tipo de cada hueco |
| `flyweb-groupby-oom.js` | SEGURIDAD | FS.3: `Object.groupBy`/`Map.groupBy` con ~17 millones de grupos lanzan `RangeError`; sin `seg/v8-groupby-contexto`, el proceso cae (SEGV en Release). También se puede pegar en la consola de FlyWeb |
| `regress-420636529.js` | V8 7bc0a67e (M132-LTS 80600881) | CVE-2025-5419: *store-store elimination* de Turboshaft con una carga indexada |
| `regress-543557673.js` | V8 36079c36 | CVE-2026-87491: `WasmGetOwnProperty` no debe invocar *getters* (`--sandbox-testing`) |
| `regress-430344952.js` | V8 9a884b1b (M132-LTS 42421010) | `ev\u0061l('var z = 3;')` sigue siendo `eval` (FS.8, nivel 126) |

Las del nivel 126 (FS.8) se copian a `test/mjsunit/regress/` (o `sandbox/regress/`); para los cambios de `kMaxArguments`
(f6961c40) hay que bajar también los límites de `regress-11491.js` (`new Array(65526)`) y `regress-crbug-724153.js`
(`65525 - 2`) como hizo Google, y marcar este último como `[SLOW]` en `mjsunit.status`.
