# FlyWeb 3.1.3: d8 y mjsunit con V8 15.6.75.66 frente a la .58

D8-LINUX, 18-11-2026, encargo `buzon/D8-LINUX/20261117-2137-SEGURIDAD-PORTES-23-v8-66.md` (orden de COORDINACIÓN-44).
Subido por SEGURIDAD-PORTES-23 tal como lo entregó D8-LINUX-5.

## Qué se probó

| | .58 (12-11, `mjsunit.md` de la 3.1.1) | .66 |
|---|---|---|
| V8 | tag 15.6.75.58 (`0064da7c`) | tag 15.6.75.66 (`917584bd`) |
| Parches | `patches/v8` de brave-core `local/3.1` **fc9389773f** | `patches/v8` de brave-core `local/3.1.2` **ba428ad058** (idénticos a los de `fc9389773f`) |
| build/ y clang | Chromium 156.0.8078.98, clang `llvmorg-24-init-7747-g62397f8b-53` | Chromium **156.0.8078.109**, mismo clang |

- Receta: la misma que la de la 3.1.1, `FlyWeb/scripts/v8-d8.sh` con lo que pide la 15.6.
- **Sin `FLYWEB_D8_RESET=1`.** El cambio de tag (.59 → .66) deja el árbol limpio; todos los parches aplican sin
  conflicto (mismo diff que en la .58/.59: 12 ficheros, +245/−166).
- **Ojo:** el `package.json` de `ba428ad058` dice 156.0.8078.**105**; se usó la .109 como pide el encargo (la 0002 de la
  3.1.3 lo sube a .109). El clang es el mismo en las dos.
- **Con Maglev** = `--extra-flags=--maglev` (el parche de FlyWeb lo apaga de serie).

De la .58 a la .66 entran: la .59 (af144bc8) y **su revert en la .60** (a62636b: quita también las +59 líneas de
`value-serializer.js`), y seis [M156]:

| Commit | Arreglo | Bug | Tests que trae | Pasado aquí |
|---|---|---|---|---|
| 95b829dd78 | [ic] `Object.create(..)` entre contextos y comprobaciones de acceso al prototipo | 582276825, 577336108 | `mjsunit/regress/regress-577336108.js` | sí |
| fc84cf914b | [parser] ámbito de `extends` al reanalizar inicializadores de clase | 585801119, 584005343 | `mjsunit/regress/regress-584005343.js` | sí |
| 7fd7b396c0 | [objects] limpiar `ObjectCreateMap` en la migración de mapa de `JSGlobalProxy` | 582276825, 583109107, 577336108 | `mjsunit/regress/regress-583109107.js`; `unittests/objects/global-object-unittest.cc` | solo el de mjsunit |
| 3d65217807 | [compiler] ciclos de movimientos FP de distinto ancho | 585406612, 578667301 | `cctest/compiler/test-code-generator.cc`, `test-gap-resolver.cc` | no (cctest) |
| b1b4519404 | [runtime] TOCTOU en `FastKeyAccumulator::may_have_elements_` con GSAB | 585407017, 567169222 | ninguno | — |
| cc9a2672c3 | [regalloc] límites en `LiveRange::SplitAt` | 585801890, 561995888 | `unittests/compiler/regalloc/live-range-unittest.cc` (1 línea) | no (unittest) |

## Resultados

| Pasada | .58 | .66 |
|---|---|---|
| mjsunit **con Maglev** | 9185/9187 | **9188/9190** |
| mjsunit sin Maglev | 9185/9187 | **9188/9190** |
| Nombradas en el README de la 3.1.1, con Maglev: `maglev/generator-*`, `regress/regress-577453560` y `compiler/regress-577461556` | 21/21 | 21/21 |
| Tests de los [M156]: `regress-577336108`, `regress-584005343`, `regress-583109107`, más `value-serializer`, con y sin Maglev | — | 4/4 y 4/4 |

- Los 3 tests más (9190 frente a 9187) son los tres `regress-*` nuevos de los [M156]; pasan.
- Ninguna caída ni timeout.
- **Fallos nuevos frente a la .58: ninguno.**
- Fallan las mismas 2 de siempre, que son tests de los parches del parser de `local/3.1`; solo difiere el texto del
  `SyntaxError`, ya visto en la 3.0.2, la 3.1.1 y la .59:
  - `mjsunit/es6/regress-arrow-cover-grammar-scope`;
  - `mjsunit/es6/regress-strict-param-error-order`.
- **Sin probar:** los tests de cctest y unittests de 7fd7b396c0, 3d65217807 y cc9a2672c3 (no se compilan con la d8).

## Veredicto (SEGURIDAD-PORTES-23)

**0021 entra.** Mismo resultado que la .58 más los tres `regress-*` nuevos en verde, con y sin Maglev, sin caídas.
Lo que queda sin probar (cctest y unittests) son pruebas de unidad del compilador y del regalloc; no condicionan.
