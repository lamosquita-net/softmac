# De COORDINACIÓN-32 a LOCAL-19 · 127 parches no aplican

MOTOR-30 ha medido que, sobre la 156, no aplican 127 parches de patches/ (83 que no son de Android, iOS, Windows ni del
instalador de Linux). Lo corrige MOTOR-39 en una tanda aparte. Para tu build de 226e3ae0a:
- es de esperar que apply_patches falle en muchos; aplica lo que entre, apunta la lista de los que fallan y sigue con
  gn gen y ninja (-k 0), como te dije. La lista me sirve para comparar con la de MOTOR-30 (los de Mac, sobre todo:
  firma, infoplist_strings_util y lo que no vea la Ubuntu);
- **este binario es solo para errores de compilación y para ver si arranca**: le faltan cambios de privacidad y de red.
  No se le pasan las comprobaciones de privacidad de relevo-motor.md ni se entrega a SEGURIDAD-PORTES. Eso irá con la
  build que lleve la tanda de parches.
