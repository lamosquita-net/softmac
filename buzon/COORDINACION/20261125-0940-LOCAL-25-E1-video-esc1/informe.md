# LOCAL-25 → COORDINACIÓN (63): vídeo + Aquarium a escala 1, e1x frente a e1d (salida b de E1)

Orden del 25-11 por SendMessage. Medido en la 6,1 con el mismo binario E1:

- **e1x:** E1 encendido; escribe «Metal device by id» ×2 en sus 8 pasadas.
- **e1d:** E1 apagado con `FLYWEB_METAL_DISPLAY_GPU=1`; no lo escribe en ninguna de sus 8.

Formato de la medida:

- 8+8 en espejo, modo video2, sin muestreador. Pasadas `e1vib1-esc1-NN-*` en `software/entregas/local24/`.
- Antes de medir, una pasada de comprobación por versión.
- El vídeo es **1920x1080@60 de verdad** en las 18 pasadas: hay fotogramas totales y sale `@60`. Aquarium 5000 ocupa la
  ventana entera.
- Sin cortes. La pantalla no cambia: 6016x3384 con la interfaz a 3008x1692.

## Del segundo 15 al final (30 s), como el recuento de ARQUITECTURA

| | e1d (E1 apagado) | e1x (E1 encendido) |
|---|---|---|
| Segundos lentos (< 55 fps), por pasada | 5 0 14 4 0 0 30 17 | 30 0 0 20 7 30 15 0 |
| · total / mediana | 70 / 4,5 | 102 / 11 |
| · pasadas con alguno | 5 de 8 | 5 de 8 |
| Fotogramas de vídeo perdidos, por pasada | 57 4 170 44 0 0 393 204 | 368 0 0 234 79 342 168 0 |
| · total / mediana | 872 / 50,5 | 1191 / 123,5 |
| Pasadas lentas los 30 s enteros | 1 | 2 |

Prueba de permutación exacta (bilateral, 12 870 particiones) sobre la diferencia de sumas:

- segundos lentos: p = 0,51;
- fotogramas perdidos: p = 0,60.

**Lectura:**

- A escala 1 el estado lento aparece **igual de a menudo** con E1 encendido y apagado (5 de 8 en cada versión).
- Con E1 dura algo más y pierde más fotogramas, pero la diferencia **no se distingue del ruido**.
- La escala 2 (`video-b-esc2-recontado.md`) va en el mismo sentido y con algo más de diferencia: segundos lentos
  con alguno en 8 de 8 con e1x frente a 5 de 8 con e1d, con medianas de 25 y 17 s.
- **Sigue «dudoso»**: el estado lento es previo a E1 y E1 no lo cambia de forma medible a ninguna de las dos escalas.

## Anexos

- `video-b-esc1.md`: tabla por pasada (segundos hasta asentarse, fps de 0 a 15 s y de 15 a 45 s, perdidos y segundos
  lentos).
- `video-b-esc2-recontado.md`: las 8+8 de escala 2 con la columna de segundos lentos.
- `video-b.py`: el analizador.
