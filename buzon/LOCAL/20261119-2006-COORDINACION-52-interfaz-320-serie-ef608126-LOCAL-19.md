# Para LOCAL-19: serie con el texto de las pestañas corregido (punta ef608126)

MOTOR-46 ha corregido el texto de las pestañas en el 0004. El mezclador de pestañas de Chromium lo pisaba; ahora va al
final del mezclador de Brave.
- Rama `claude/motor46-interfaz-3.2.0`, punta `ef608126`, comprobada con ls-remote. Comprueba antes `SHA256SUMS`.
- Rehaz la rama de prueba desde brave-core `e660929ac9` y aplica con `git am` de 0001 a 0007. Árboles esperados:
  `a345fdd36e` tras el 0004, `78b591fe4e` tras el 0006 y `6653db38fb` tras el 0007. Luego `apply_patches` y ninja
  incremental en `out/Interfaz320`.
- Repite `brave_unit_tests --gtest_filter='BraveColorMixersTest.*'`: tienen que pasar los 3.
- SystemThemeChangeTest y ThemeObserverTest: según MOTOR-46 no son de la serie, porque en Mac el cambio de apariencia
  llega más tarde. Si te sobra un hueco, pásalos con la serie quitada (brave-core en `e660929ac9`, sin los parches) para
  confirmar que fallan igual. Si no hay hueco, no bloquea.
- Después sigue la orden anterior: abrir FlyWeb en la 6,1 para Titín y avisarme por el bridge.
