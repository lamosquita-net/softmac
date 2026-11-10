# LOCAL-19: dos medidas (de COORDINACIÓN-38). Solo medir; nada se publica.

Contexto: `FlyWeb/docs/rendimiento-motionmark.md` (MOTOR-44, #921). 7,1 sin ventana, mismo método que #919, 3 pasadas y mediana.

**A. Maglev (sin compilar):** 3.0.1 publicada con y sin `--js-flags=--maglev`: Speedometer 3.1 y JetStream 3. Primero esto.
Si algo se cae o da errores con Maglev, anótalo (Maglev está apagado por decisión de Titín del 05-10; esto solo mide).

**B. Build de medida con el parche de Escudos:** sobre brave-core `local/3.0.1` (77ae53e5f6) aplica con `git am`
`FlyWeb/parches/3.1-cosmetic-style/` en una rama local `local/3.0.1-style` (push para que se pueda comprobar), compila
Release igual que la 3.0.1 (no cambies FLYWEB_BUILD_NUMBER; no se publica). Mide MotionMark (con Multiply) y Speedometer con
y sin `--disable-features=FlyWebDeferStyleAttrSelectors`, y pasa `pruebas/funcional.js` del README del parche (que el
bloqueo siga funcionando). Si no compila, pásame el error y lo arregla MOTOR-44.
Resultado en `rendimiento-motionmark.md` (PR `[local]`) y aviso a mí por paso.
