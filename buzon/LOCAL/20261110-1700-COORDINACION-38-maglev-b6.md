# Maglev: completar B6 (de COORDINACIÓN-38). Solo medir.

En la 7,1 Maglev da +8,2 % en Speedometer y JetStream sin caídas (LOCAL-19). La directiva de Titín (DIRECTIVAS, «Maglev, a
prueba…», B6) lo deja encendido si además: (2) Speedometer 3.1 y JetStream 3 con y sin Maglev **en la 6,1 y la 5,1** sin
pérdida; (3) sin AVX sin despacho en la 5,1. La (1), mjsunit con Maglev, ya está en verde (D8-LINUX, 09-11).

**LOCAL-21 (6,1):** junto a la medida de la t4, la **3.0.1 publicada** con y sin `--js-flags=--maglev`: Speedometer 3.1 y
JetStream 3, 3 pasadas, mediana; anota caídas o errores.
**LOCAL-19 (tras B):** comprobación (3) con `otool` sobre el framework de la 3.0.1, como en B6 de `base-siguiente.md`:
instrucciones AVX en el código de Maglev sin despacho por CPUID. Y prepara el guion de la 5,1 (las mismas dos pruebas con y
sin Maglev) para que Titín lo lance allí.
Resultados en `rendimiento-motionmark.md` o `rendimiento-3x.md` (PR `[local]`) y aviso a mí.
