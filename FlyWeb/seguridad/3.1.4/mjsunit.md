# FlyWeb 3.1.4: d8 y mjsunit con V8 15.6.75.66 y todos los patches/v8 (incluido 5787048), frente a la 3.1.3

D8-LINUX, 18-11-2026, encargo único de la 3.1.4 de SEGURIDAD-PORTES-26 (sustituye a
`buzon/D8-LINUX/20261118-1030-SEGURIDAD-PORTES-25-v8-3.1.5.md`, que no llegó a empezarse). No hay versión 3.1.5:
`FlyWeb/seguridad/3.1.5/` es la parte 3 de la 3.1.4. Informe de D8-LINUX-5 (`session_01MwmK2iT4hLWA1h2vv3cG9K`),
subido por SEGURIDAD-PORTES-26.

## Qué se probó

| | 3.1.3 (.66, 18-11) | 3.1.4 |
|---|---|---|
| V8 | tag 15.6.75.66 (`917584bd`) | el mismo |
| brave-core | `local/3.1.2` `ba428ad058` | `seg/3.1.4` `d916327900` + `git am` de `3.1.4/brave-core/0003`, `3.1.5/brave-core/0001` y `3.1.5/brave-core/0003` (sin `3.1.5/0002`, solo versión); `SHA256SUMS` correctos; **árbol `15c050d35a`**, el esperado |
| Árbol de V8 con todos los `patches/v8` | — | **`fe1194813a`**, el esperado (comprobado con `git apply --cached` sobre un índice aparte) |
| build/ y clang | Chromium 156.0.8078.109, clang `llvmorg-24-init-7747-g62397f8b-53` | Chromium **156.0.8078.110** (`package.json` de la 3.1.4), mismo clang |

- Receta: la de la 3.1.x, `FlyWeb/scripts/v8-d8.sh` con lo que pide la 15.6. Compilación: 8 min.
- **Sin `FLYWEB_D8_RESET=1`.** Sobre el árbol de la .66, el único parche ya aplicado que cambia es
  `src-utils-version.cc.patch` (`kFlyWebCacheEpoch` 31 → 34): se volvió atrás solo ese con `git apply -R` del de la
  3.1.3; la receta aplicó el nuevo y los 13 nuevos sin conflicto.
- El árbol compilado difiere de `fe1194813a` solo en `BUILD.gn`: `BUILD.gn.patch` necesita `brave/` y la receta lo omite,
  como en todas las d8 anteriores.
- **Con Maglev** = `--extra-flags=--maglev` (el parche de FlyWeb lo apaga de serie).

Lo nuevo frente a la 3.1.3:

| Arreglo | Qué toca | Prueba | Con Maglev | Sin Maglev |
|---|---|---|---|---|
| 659b8bf | regexp, CHECK en `Compiler::Assemble` | `regress/regress-573263262.js` | pasa | pasa |
| 19048d3 | Turboshaft wasm, `AssertNotNull` y `WasmTypeCheckOp` | `regress/wasm/regress-571348848.js` | pasa | pasa |
| 33ab43a | caché de regexp entre contextos | `regress/regress-576225189.js` | pasa | pasa |
| 65afc9f | trampas Proxy-on-Prototype de wasm | `regress/wasm/regress-577305505.js` | pasa | pasa |
| 5787048 | `JSCallReducer::Finalize` (es la V8 15.6.75.67) | `compiler/regress-577323082.js` | pasa | pasa |
| — | `kFlyWebCacheEpoch` 31 → 34 | — | — | — |

## Resultados

| Pasada | 3.1.3 (.66) | 3.1.4 |
|---|---|---|
| mjsunit **con Maglev** | 9188/9190 | **9193/9195** |
| mjsunit sin Maglev | 9188/9190 | **9193/9195** |
| Nombradas en el README de la 3.1.1, con Maglev: `maglev/generator-*`, `regress/regress-577453560` y `compiler/regress-577461556` | 21/21 | 21/21 |
| Las 5 pruebas nuevas, con y sin Maglev | — | 5/5 y 5/5 |
| `compiler/*`, `regexp*`, `harmony/regexp*`, `es6/unicode-regexp*`, `es6/string-replace*`, `wasm/gc*` y `wasm/*proxy*`, con y sin Maglev | — | 1038/1038 y 1038/1038 |

- Los 5 tests más (9195 frente a 9190) son las 5 pruebas nuevas de los parches; pasan.
- Ninguna caída ni timeout.
- **Fallos nuevos frente a la 3.1.3: ninguno.**
- Fallan las mismas 2 de siempre, que son tests de los parches del parser; solo difiere el texto del `SyntaxError`, ya
  visto en la 3.0.2, la 3.1.1 y la 3.1.3:
  - `mjsunit/es6/regress-arrow-cover-grammar-scope`;
  - `mjsunit/es6/regress-strict-param-error-order`.

**Conclusión (SEGURIDAD-PORTES-26):** los parches de V8 de la 3.1.4 (brave-core `3.1.4/0002`, `3.1.5/0001` y `3.1.5/0003`)
quedan aprobados para compilar.
