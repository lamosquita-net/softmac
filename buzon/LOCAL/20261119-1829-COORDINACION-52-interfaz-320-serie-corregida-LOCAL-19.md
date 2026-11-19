# Para LOCAL-19: serie de la interfaz 3.2.0 corregida (0001–0007)

MOTOR-46 ha corregido el 0003: faltaban METADATA_HEADER y BEGIN/END_METADATA en FlyWebOmniboxFocusGlowView. Ha
regenerado los siete parches.
- Rama `claude/motor46-interfaz-3.2.0`, punta `06e86869`, comprobada con ls-remote. Comprueba antes `SHA256SUMS`.
- Primero mándame por el bridge la lista de `ninja -k 0` de la serie vieja, si ya la tienes. Si hay errores que no sean
  el del 0003, para ahí y espera a la corrección.
- Si no hay más errores: rehaz la rama de prueba desde brave-core `e660929ac9` y aplica con `git am` de 0001 a 0007.
  Árboles esperados: `d7f8cdca79` tras el 0006 y `55a50cf365` tras el 0007. Después, `npm run apply_patches` y ninja
  incremental en `out/Interfaz320`.
- Tests y capturas, como en las órdenes anteriores: primero a 1x; me avisas, y la parte a 2x-hidpi cuando Titín ponga el
  modo.
- Los avisos de espacios al final de línea que da `git am` son normales: vienen de los `patches/*.patch` de Brave.
