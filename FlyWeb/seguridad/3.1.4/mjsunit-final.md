# FlyWeb 3.1.4 final: d8, mjsunit e inspector con V8 15.6.75.66 y todos los patches/v8 (partes 4–6 e integración)

D8-LINUX, 18-11-2026, encargo `buzon/D8-LINUX/20261118-1740-SEGURIDAD-PORTES-30-v8-3.1.4.md` (orden de COORDINACIÓN-49).
La parte anterior (hasta 5787048, época 34; árbol de V8 `fe1194813a`) ya estaba en verde (#1072, [`mjsunit.md`](mjsunit.md)).
Subido por SEGURIDAD-PORTES-30, que corrigió los números de bug de los tres arreglos del inspector según
`patches/v8/FLYWEB-SECURITY.md`.

**Veredicto: VERDE.** No hay que quitar ningún parche.

## Qué se probó

| | 3.1.4 hasta 5787048 (#1072) | 3.1.4 final |
|---|---|---|
| V8 | tag 15.6.75.66 (`917584bd`) | el mismo |
| brave-core | `15c050d35a` (árbol) | `seg/3.1.4-integracion` **`6441095f59`**, árbol **`2ab25d6a23`** (= `local/3.1.4` `9932552867` + 4 commits) |
| Árbol de V8 con todos los `patches/v8` | `fe1194813a` | **`17b5af44cd`**, el esperado (comprobado con `git apply --cached` sobre un índice aparte) |
| build/ y clang | Chromium 156.0.8078.110, clang `llvmorg-24-init-7747-g62397f8b-53` | los mismos |

- Receta: la de la 3.1.x, `FlyWeb/scripts/v8-d8.sh` con lo que pide la 15.6. Compilación de d8: 7 min.
- **Sin `FLYWEB_D8_RESET=1`.** Sobre el árbol anterior, solo cambian dos parches ya aplicados:
  `src-utils-version.cc.patch` (`kFlyWebCacheEpoch` 34 → 37) y `src-runtime-runtime-regexp.cc.patch` (c9afe36). Se
  volvieron atrás solo esos dos con `git apply -R`; la receta aplicó sus versiones nuevas y los 31 parches nuevos sin
  conflicto.
- El árbol compilado difiere de `17b5af44cd` solo en `BUILD.gn`: `BUILD.gn.patch` necesita `brave/` y la receta lo omite,
  como en todas las d8 anteriores.
- **Con Maglev** = `--extra-flags=--maglev` (el parche de FlyWeb lo apaga de serie).
- **inspector:** además de d8 se compiló `inspector-test` (misma configuración). `regress/regress-crbug-568986689` lo
  salta `inspector.status` (el parche lo marca `['not memory_corruption_api', SKIP]`), así que se compiló aparte una
  segunda d8 + `inspector-test` con `v8_enable_memory_corruption_api = true` solo para pasarla.

Lo nuevo frente a la última verde:

| Arreglo | Bug | Qué toca | Prueba | Con Maglev | Sin Maglev |
|---|---|---|---|---|---|
| 46c1404 | 581561827 | Turboshaft, sin *jump threading* a través de transiciones de marco | `mjsunit/regress/wasm/regress-simd-581561827.js` | pasa | pasa |
| c9afe36 | 576957750 | regexp, relleno tras recortar en `replace` | `mjsunit/regress/regress-576957750.js` | pasa | pasa |
| 42d78d0f3d | 564190098 | `WasmEngine` reutiliza el `Script` solo si coincide la URL | sin prueba propia (cubierto por `wasm/*`) | — | — |
| b1457bd47a | 568010379 | Maglev, cargas de contexto `PREVIOUS_INDEX` | `mjsunit/turbolev/regress-568010379.js` | pasa | pasa |
| 0b3bd2b | 553263303 | inspector, `Runtime.getHeapUsage`/`getIsolateId` solo para clientes de confianza | `inspector/runtime/get-heap-usage.js`, `inspector/runtime/get-isolate-id.js` | pasan | pasan |
| 336a6b3 | 568986689 | inspector, índices en vez de punteros en la deduplicación de la serialización | `inspector/regress/regress-crbug-568986689.js` (con la API de corrupción de memoria) | pasa | pasa |
| fb3bcc3 | 572312093 | inspector, datos de `V8Console` en un `CppHeapExternal` | sin prueba propia (cubierto por la suite `inspector`) | pasa | pasa |
| 0ac2b27 | 574412712 | Maglev, `StringLengthStaticLowerBound` | `mjsunit/maglev/regress-574412712.js` | pasa | pasa |
| fdbb7b1 | 577314726 | literales con `NameDictionary` en orden de enumeración (V8 15.6.75.70) | `mjsunit/regress/regress-577314726.js` | pasa | pasa |
| — | — | `kFlyWebCacheEpoch` 34 → 37 | — | — | — |

## Resultados

| Pasada | .66 (3.1.3) | 3.1.4 hasta 5787048 | 3.1.4 final |
|---|---|---|---|
| mjsunit **con Maglev** | 9188/9190 | 9193/9195 | **9198/9200** |
| mjsunit sin Maglev | 9188/9190 | 9193/9195 | **9198/9200** |
| Nombradas en el README de la 3.1.1, con Maglev | 21/21 | 21/21 | 21/21 |
| Las 5 pruebas nuevas de mjsunit, con y sin Maglev | — | — | 5/5 y 5/5 |
| `compiler/*`, `regexp*`, `wasm/*simd*`, `maglev/*`, `turbolev/*` y `wasm/*`, con y sin Maglev | — | — | 2814/2814 y 2814/2814 |
| Suite `inspector` completa, con y sin Maglev | — | — | 454/454 y 454/454 |
| Las 3 de inspector (con `memory_corruption_api`), con y sin Maglev | — | — | 3/3 y 3/3 |

- Los 5 tests más de mjsunit (9200 frente a 9195) son las 5 pruebas nuevas; pasan.
- Ninguna caída ni timeout.
- **Fallos nuevos: ninguno.** No hay que quitar ningún parche.
- Fallan las mismas 2 de siempre, que son tests de los parches del parser; solo difiere el texto del `SyntaxError`:
  - `mjsunit/es6/regress-arrow-cover-grammar-scope`;
  - `mjsunit/es6/regress-strict-param-error-order`.
- **Sin probar:** cctest y unittests (no se compilan con la d8).
