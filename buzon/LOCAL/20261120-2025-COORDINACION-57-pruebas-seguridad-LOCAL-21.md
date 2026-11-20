# Para LOCAL-21: pruebas de la seguridad nueva de la 3.2.0 (COORDINACIÓN-57)

Titín ha decidido (20-11 ~20:15 UTC; DIRECTIVAS #1160) que entran en la 3.2.0 cinco arreglos más. Antes de la compilación
final hacen falta sus pruebas. **Después** de lo que tienes en marcha (pruebas de bt-320f de las órdenes de las 16:23 y 16:50,
OmniboxColorTest con el 0018), y sin tocar bt-320f en la 6,1 ni la versión:

1. En una rama solo de pruebas sobre la chromium de bt-320f (punta efde5db485), aplica:
   - `FlyWeb/seguridad/pendiente/chromium/0007` y `0008` de la rama de softmac `claude/seguridad-portes-33-v8-585625642`
     (punta c0808f171a; comprueba con `git ls-remote` y SHA256SUMS);
   - encima, `FlyWeb/seguridad/portes-159/chromium/0001` y `0002` de la rama `claude/seguridad-portes-33-menu-drop-uaf`
     (punta bf5c3689c7). Árboles esperados (SEGURIDAD-PORTES-33): tras 0008 = 90418ba4fd; tras portes-159/0002 = 2bb85047ec.
     Si no coinciden, para y avisa.
2. Pasa en la 7,1:
   - `blink_platform_unittests --gtest_filter='AcceleratedStaticBitmapImageTest.*'`
   - `blink_unittests --gtest_filter='*Canvas*Transform*:*ElementTest*'`
   - `views_unittests --gtest_filter='MenuRunnerTest.*:MenuRunnerImplTest.*'`
   - `url_unittests --gtest_filter='SchemeHostPortTest.*:OriginTest.*:MojoGURLStructTraitsTest.*'`
3. Entrega el resultado de cada uno (verde/rojo, con las que fallen). Si algo sale rojo, avisa antes de quitar nada.

brave-core/0005 (V8) lo prueba D8-LINUX; no lo pases tú. Las pruebas a mano (arrastrar a una carpeta de marcadores, Esc
durante el arrastre, file:///, settings y una extensión) se harán en la build final. Todo en español.
