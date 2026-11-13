# FlyWeb 3.1.x: d8 y mjsunit con V8 15.6.75.59 frente a la .58

D8-LINUX, 13-11-2026, encargo `buzon/D8-LINUX/20261113-0823-COORDINACION-40-v8-59.md`.

## Qué se probó

| | .58 (12-11, `mjsunit.md` de la 3.1.1) | .59 |
|---|---|---|
| V8 | tag 15.6.75.58 (`0064da7c`) | tag 15.6.75.59 (`d8064904`) |
| Parches | `patches/v8` y `patches/third_party-simdutf-*` de brave-core `local/3.1` **fc9389773f** | los mismos |
| build/ y clang | Chromium 156.0.8078.98 (`package.json` de `local/3.1`), clang `llvmorg-24-init-7747-g62397f8b-53` | igual |

- Receta: la misma que la de la 3.1.1, `FlyWeb/scripts/v8-d8.sh` con lo que pide la 15.6.
- **Sin `FLYWEB_D8_RESET=1`.** El cambio de tag deja el árbol limpio y aplica los parches; todos aplican sin
  conflicto.
- Compilación: 7 min a `-j24`.
- **Con Maglev** = `--extra-flags=--maglev`.

Lo único nuevo de la .58 a la .59 es **af144bc8**, `[M156] [builtins] Enforce no-JS execution scopes in
InvokeApiFunction` (bug 576333024, cherry-pick de 8bc5c68223), y el cambio de versión.
- **Qué hace el arreglo:** `InvokeApiFunction` pasa a respetar `AllowJavascriptExecution`,
  `ThrowOnJavascriptExecution` y `DumpOnJavascriptExecution`.
- **`ValueDeserializer`:** llena `Map` y `Set` en C++, sin ejecutar JS.
- **Tests que trae:** `test/mjsunit/value-serializer.js` (+59 líneas), `test/cctest/test-api.cc` y
  `value-serializer-unittest.cc`. Aquí solo se compila la d8, así que solo se pasa el de mjsunit.

## Resultados

| Pasada | .58 | .59 |
|---|---|---|
| mjsunit **con Maglev** | 9185/9187 | 9185/9187 |
| mjsunit sin Maglev | 9185/9187 | 9185/9187 |
| Nombradas en el README de la 3.1.1, con Maglev: `maglev/generator-*`, `regress/regress-577453560` y `compiler/regress-577461556` | 21/21 | 21/21 |
| `mjsunit/value-serializer` (test del [M156] de la .59), con y sin Maglev | — | 1/1 y 1/1 |

- Ninguna caída.
- **Fallos nuevos frente a la .58: ninguno.**
- Fallan las mismas 2 de siempre, que son tests de los parches del parser de `local/3.1`; solo difiere el texto del
  `SyntaxError`, ya visto en la 3.0.2 y la 3.1.1:
  - `mjsunit/es6/regress-arrow-cover-grammar-scope`;
  - `mjsunit/es6/regress-strict-param-error-order`.
- **Sin probar:** los tests de cctest y unittests del arreglo (no se compilan con la d8).
