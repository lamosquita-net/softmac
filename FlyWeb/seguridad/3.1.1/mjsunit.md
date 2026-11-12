# FlyWeb 3.1.1: d8 y mjsunit (V8 15.6.75.58) frente a la 3.1.0 (15.6.75.51)

D8-LINUX, 12-11-2026, encargo `buzon/D8-LINUX/20261112-1750-COORDINACION-39-311-mjsunit.md`.

## Qué se probó

| | 3.1.0 (base) | 3.1.1 |
|---|---|---|
| V8 | tag 15.6.75.51 (`182f1310`) | tag 15.6.75.58 (`0064da7c`, el `v8_revision` de la serie) |
| Parches | `patches/v8` y `patches/third_party-simdutf-*` de brave-core `local/3.1` **fc9389773f** | los mismos |
| build/ y clang | Chromium 156.0.8078.98 (`package.json` de `local/3.1`), clang `llvmorg-24-init-7747-g62397f8b-53` | igual |

- Receta: `FlyWeb/scripts/v8-d8.sh` con lo que pide la 15.6: gn de Chromium, libc++ de Chromium (el sandbox exige
  `use_safe_libcxx`), simdutf y llvm-libclang. Linux x64, `dcheck_always_on`, sin ICU.
- `BUILD.gn.patch` se omite: todo él necesita `brave/`.
- Los `patches/v8` aplican limpios sobre la .58, como dice el README.
- Compilación: 7 min por d8 a `-j24`.
- **Con Maglev** = `--extra-flags=--maglev`: el parche de `flag-definitions` de FlyWeb lo apaga de serie en la d8.

## Resultados (mjsunit completo)

| Pasada | 3.1.0 (.51) | 3.1.1 (.58) |
|---|---|---|
| mjsunit **con Maglev** | 9181/9183 | 9185/9187 |
| mjsunit sin Maglev | 9181/9183 | 9185/9187 |
| Nombradas en el README, con Maglev: `mjsunit/maglev/generator-*`, `regress/regress-577453560` y `compiler/regress-577461556` | 18/18 (las dos `regress-*` no existen en la .51) | **21/21** |

- Ninguna caída, `CHECK` ni `DCHECK`.
- La .58 trae 4 tests más:
  - las dos regresiones nombradas;
  - `maglev/generator-next-yield-undefined`;
  - `turbolev/regress-577461556`.
  Pasan los cuatro.

## Fallos

**Fallos nuevos de la 3.1.1 frente a la 3.1.0: ninguno.** Fallan las mismas 2 pruebas en las cuatro pasadas:

- `mjsunit/es6/regress-arrow-cover-grammar-scope`:
  - esperado «Invalid destructuring assignment target»;
  - sale «Unexpected eval or arguments in strict mode».
- `mjsunit/es6/regress-strict-param-error-order`:
  - esperado «Illegal property in declaration context»;
  - sale «Invalid destructuring assignment target».

Las dos son tests que añaden los propios parches del parser de `local/3.1` (de la 3.0.2). Solo falla el texto del
`SyntaxError`, no que se lance. Ya fallaban igual el 09-11 en la d8 «C» (3.0.2, .51). No es cosa de la .58.
