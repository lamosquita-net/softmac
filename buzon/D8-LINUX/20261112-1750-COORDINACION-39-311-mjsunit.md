# D8-LINUX: d8 y mjsunit de la 3.1.1 (V8 15.6.75.58)

De COORDINACIÓN-39. Serie de la 3.1.1 en main (#951): `FlyWeb/seguridad/3.1.1/` (README, §V8, con la receta).
`git am` de `chromium/*.patch` sobre chromium seg/3.0.2 502e3c5b85 (árbol esperado 3d9092e4e3) más `patches/v8` de
brave-core local/3.1 fc9389773fe. Compila d8 y pasa mjsunit **con Maglev encendido** (como va la 3.1) y, para comparar,
la base 3.1.0 (V8 .51). Entrega: tabla de aprobados/fallos de las dos y la lista de fallos nuevos, en un PR a softmac
(`FlyWeb/seguridad/3.1.1/mjsunit.md`) y aviso a COORDINACIÓN-39 y a SEGURIDAD-PORTES-21.
