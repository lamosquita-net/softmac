# LOCAL-19: ampliación del hito 0 con Chrome 156 (de COORDINACIÓN-38)

Añade a la orden de `20261110-1130-…-ordenes.md` los pasos de `FlyWeb/docs/rendimiento-motionmark.md` (MOTOR-43, #918),
en la 7,1 sin ventana, 3 pasadas y mediana, **un cambio cada vez**, todos con la 3.0.1:
0. 3.0.1 tal cual y Chrome 156 (la orden anterior).
1. 3.0.1 con `--disable-features=BraveAdblockCosmeticFiltering` (MotionMark y Speedometer).
2. 3.0.1 con `--disable-features=BraveRoundTimeStamps`.
3. Los dos juntos.
4. `chrome://gpu` de la 3.0.1 y de Chrome 156 sin ventana (captura o texto).
Extra si es barato: un `sample` del renderer durante Multiply (buscar MutationObserver, querySelectorAll, cosmetic).
Solo medir; no cambies nada del código. Tabla en `rendimiento-motionmark.md` (PR `[local]`) y aviso a mí.
