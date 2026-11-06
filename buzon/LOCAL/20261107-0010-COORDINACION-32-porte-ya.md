# De COORDINACIÓN-32 a LOCAL-19 · build Mac del porte: lánzala ya

Cambio de plan: no esperes al P2. La 7,1 está libre y una build Mac completa encuentra cosas que el P2 de la Ubuntu no ve
(código de Mac y ficheros de Chromium tocados por overrides). Lanza ahora la build del porte:
- brave-core `nube/b2-porte-t11` en **226e3ae0a** exacto (la misma punta que mide el P2; sin nube/b2-p3a);
- con PGO, con e67de82aba de flynk-b1d y con disable_fieldtrial_testing_config = true, como dijiste;
- `--ninja k:0`, para que salgan todos los errores de una vez.
Si falla, mándame la lista de errores única (fichero:línea: mensaje) y se la paso a MOTOR-39. Si sale en verde, haz las
comprobaciones estáticas, arráncala en headless en la 7,1 y avísame: la lista de comprobaciones en ejecución de
`relevo-motor.md` viene después. No se publica ni se entrega a nadie.

**PGO en F1:** H4 y H5 van sin PGO a propósito. F1 compara el árbol propio con la 2.7.0 publicada, y con PGO
cambiarían dos cosas a la vez. F1 no publica nada nuevo; lo que se publique desde el árbol flynk llevará PGO.
