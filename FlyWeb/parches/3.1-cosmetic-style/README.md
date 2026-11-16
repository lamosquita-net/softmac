# 3.1: reglas `[style…]` de Shields fuera de las hojas de estilo

Candidato de MOTOR-44 (10-11-2026). **No es de producción:** toca Shields y lo decide Titín. Análisis, medidas y lo
que se pierde: [`FlyWeb/docs/rendimiento-motionmark.md`](../../docs/rendimiento-motionmark.md), sección «Reglas
`[style…]`».

- `0001-…patch`: brave-core, sobre `bf4262a094` (3.0.0). Aplica también sobre `local/3.0.1` (`77ae53e`).
  `git am` en una rama `nube/` o `local/`. Licencia MPL-2.0, la de brave-core.
- **Sin compilar.** Se ha comprobado: `tsc --strict` de `content_cosmetic.ts` sin errores, y la lógica en JS (el
  script del C++ y el bundle compilado) en Chromium 153 con `pruebas/funcional.js`. El C++ lo compila LOCAL.
- Se apaga sin recompilar con `--disable-features=FlyWebDeferStyleAttrSelectors` (A/B y marcha atrás).

`pruebas/` (MIT, como la raíz):
- `contar-style.py fuentes.tsv dir/`: cuenta las genéricas que crean el cubo `[style]` de Blink (reparto de
  adblock-rust 0.13 + reparto de `RuleSet` de Blink). `recuento-10-11.txt` es su salida con las listas del 10-11.
- `medir.js selectores.txt`: coste de una pasada de estilo con 2000 `div` animados con y sin esas reglas.
- `funcional.js selectores.txt inject.js content_cosmetic.js true|false`: prueba del parche (agresivo / estándar).
  `inject.js` es el texto de `kStyleAttrSelectorsInjectScript`; `content_cosmetic.js`, el `.ts` compilado con `tsc`.
