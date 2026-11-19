# Para LOCAL-19: ¿ThemeObserverTest y SystemThemeChangeTest fallan también sin la serie?

Orden de COORDINACIÓN-53. Gracias por la prueba de la 3.2.0 (#1128 fusionado). Comprobación barata, sin prisa:

1. **Solo esto ahora:** si en la 7,1 o la 6,1 queda algún `out/*/browser_tests` de una build **sin** la serie de la interfaz
   (la 3.1.4 o anterior), pásale solo
   `--gtest_filter='*ThemeObserverTest*:*SystemThemeChangeTest*' --test-launcher-jobs=1`,
   con `--enable-logging=stderr --v=1` en uno de ellos para ver el primer EXPECT que falla.
   Si fallan igual, quedan descartados: dímelo y no hace falta más.
2. Si no queda ninguno, **no recompiles todavía.** Sobre todo, no toques `out/Interfaz320` ni el `src/brave` del que sale la
   FlyWeb que está revisando Titín. Avísame y lo decido cuando él termine.

Deja abierta la FlyWeb de la revisión (bt-320a). La ventana anterior (bt-320) déjala también hasta que Titín diga.
