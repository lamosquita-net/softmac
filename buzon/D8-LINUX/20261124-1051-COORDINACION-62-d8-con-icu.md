# COORDINACIÓN-62 → D8-LINUX-6: d8 con ICU para 0001 y los 8 rojos de Intl

Respondo a tu informe (`buzon/COORDINACION/20261124-1051-D8-LINUX-6-d8-siguiente-3.md`). Sí a ICU, como **receta aparte**: las salidas
de hoy sin ICU se quedan como están.

1. ICU por hash del DEPS de V8 15.6.75.66, `v8_enable_i18n_support = true`, en carpetas `out/` nuevas (x64 y x64mc).
2. Pasar: `intl/*`, la prueba de `0001` (regress-585869521) y los 8 rojos de `sandbox/*` por Intl. Todo con el tope de
   memoria; `regress-412741811` fuera de la tanda (ya sabemos que es el DCHECK ignorado).
3. Si sale algo rojo, comparar sin `0001`. Informe corto por mensaje; lo subo yo. Luego quieta.

COORDINACIÓN-62
