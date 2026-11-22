# Para COORDINACIÓN-60 y ARQUITECTURA: control de MotionMark previo a E1 (LOCAL-23)

Orden de Titín del 22-11 (por COORDINACIÓN-60). MacPro6,1, 16:58–17:27 (Madrid). Cuatro arranques con perfil nuevo, sin muestreador,
mismo guion, ventana 1920×1200, 60 s de reposo más 20 s entre arranques, orden alternado. «3.0.0» = la publicada (firmada,
UUID 4C4C4466-…-71D8), la de la referencia `ref-perf` del 09-11. Todo comprobado por código.

## Veredicto: **no hay retroceso de la 3.2.1.** Corrige el punto 4 de `20261122-1539-LOCAL-23-M1.md`

La 3.0.0 de hoy cae igual en Suits y Design. La caída es del entorno, no de la versión ni del muestreador.

| Prueba | 3.0.0 el 09-11 (3) | 3.0.0 hoy (pasadas 2, 3) | 3.2.1 hoy (pasadas 1, 4) | 3.2.1 / 3.0.0 hoy (medias) |
|---|---|---|---|---|
| Multiply | 676–718 | 655 · 668 | 1692 · 1688 | +156 % |
| Canvas Arcs | 3292–3334 | 3193 · 3204 | 3292 · 3321 | +3 % |
| Leaves | 870–891 | 839 · 861 | 1308 · 1335 | +56 % |
| Paths | 15038–15422 | 15162 · 15071 | 15929 · 16108 | +6 % |
| Canvas Lines | 19308–19550 | 18885 · 19260 | 19980 · 20572 | +6 % |
| Images | 214–221 | 212 · 213 | 215 · 210 | 0 % |
| **Design** | **201–207** | **128 · 125** | **129 · 127** | +1 % |
| **Suits** | **417–426** | **12,8 · 22,0** | **15,3 · 6,5** | no medible (±60–160 %) |
| **Total** | 1350–1355 | 804 · 865 | 998 · 901 | +14 % (lo ensucia Suits) |

La 3.2.1 va igual o mejor que la 3.0.0 en las siete pruebas medibles.

## Qué cambió desde el 09-11: la escala de la pantalla

| | 09-11 (registros de LOCAL-21) | 22-11 |
|---|---|---|
| `system_profiler` | 3008×1692, «UI Looks like» 3008×1692 | 6016×3384, «UI Looks like» 3008×1692 |
| Ventana | 1920×1119 a `devicePixelRatio` **1** | 1920×1119 a `devicePixelRatio` **2** |

Son cuatro veces más píxeles. **Es la causa probable, no demostrada:** no he repetido a escala 1. Encaja con que caiga lo que
limita la tarjeta con mucho relleno (Suits, Design; también Shadertoy y three.js, que el 05-11 además iban en ventana menor).
Suits cae mucho más de cuatro veces, así que a Retina puede haber además un escalón (memoria de la D500, superficies de SVG). Es
un problema de rendimiento real para quien use esa escala, **y ya estaba en la 3.0.0**.

## Para E1

- La condición de parada (retroceso real en la 3.2.1) **no se cumple**. No he compilado nada.
- **El A/B de ≤ 2 % no vale tal cual a escala 2:** Suits varía más del doble entre pasadas de la misma versión, y Canvas Lines
  un 3 %. Propuesta para que la fije ARQUITECTURA: medir a las dos escalas (la 1 con `--force-device-scale-factor=1`, sin
  tocar la pantalla de Titín), con varias pasadas alternadas, y juzgar Suits solo a escala 1. Antes, una pasada a escala 1
  con la 3.2.1 (~7 min, con el sí de Titín) confirma la causa: debe volver a ~420 en Suits y ~205 en Design.
- Toda medida de la 6,1 debe anotar `devicePixelRatio`. Las cifras de antes y de después del cambio de escala no se comparan.
- P4 sigue como «primera mitad, provisional»: a escala 2 manda la tarjeta con más motivo.

Datos: `entregas/local23/ctrl{1-321,2-300,3-300,4-321}-conductor`; guion `temp/local23/control-mm.sh`.

— LOCAL-23
