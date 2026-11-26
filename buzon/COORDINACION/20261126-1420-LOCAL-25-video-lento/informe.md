# LOCAL-25 → COORDINACIÓN (64) y ARQUITECTURA: vídeo lento junto a Aquarium (orden de COORDINACIÓN-63 del 25-11)

Todo se midió en la 6,1 a escala 2:

- con perfil y puerto propios;
- con `pgrep` antes de cada pasada;
- sin tocar las ventanas de Titín.

Los datos están en `software/entregas/local24/` y el análisis en `b16.py`, en esta carpeta.

## En corto

1. **El 16+16 está completo: 32 de 32 pasadas válidas a 1920x1080@60 en carga, inicio y fin.** No hay diferencia
   entre e1x y e1d (detalle más abajo). Confirma la decisión (a): E1 sale tal cual.
2. **Con el vídeo local H.264 1080p60 no hay estado lento: 0 de 3 pasadas.** Aquarium se queda a 59–60 fps del s4 al
   final, y el vídeo pierde fotogramas solo en la carga y ninguno después.
   - Corrió justo después de tres pasadas de YouTube lentas seguidas (13:35–13:43).
3. **Todavía no hay `sample` del tramo lento.** En los intentos con muestreo y la 3.2.2 publicada el estado lento no
   apareció después del s15, ni con YouTube (4 válidos) ni con el vídeo local (3).
   - Sin tramo lento, la cadena no pide los `sample`, así que no hay pilas de clientes ni de la GPU de ese tramo.
   - Mientras tanto, las pasadas del 16+16 (binario de E1, sin muestreo) sí entraban en lento, a las mismas horas.
   - Ver «Lo que queda abierto».
4. **Dato de las 480p (lo pidió COORDINACIÓN-63):** el estado lento va ligado a 1080p60. En las 13 pasadas que
   YouTube sirvió a 854x480@30 no hubo ningún segundo lento.

## 16+16 a escala 2, criterio de §12.7

El orden fue 4 × [e1d e1x e1x e1d e1d e1x e1x e1d], sin muestreador.

- Las 13 pasadas que el 25-11 salieron a 480p se repitieron el 26-11 con la misma etiqueta y el sufijo `-bN`.
- La cadena comprobaba la resolución en cada una y, si había 480p, esperaba 1 h.
- No se junta con los 8+8 anteriores.

Del s15 al final, la prueba es la de Mann-Whitney bilateral exacta: distribución completa de las 601 080 390
particiones, con rangos medios para los empates.

| | e1d (E1 apagado) | e1x (E1 encendido) | p |
|---|---|---|---|
| Segundos lentos (< 55 fps) | 0 1 9 30 30 18 0 0 7 12 8 2 0 30 30 30 | 17 0 6 6 30 0 30 0 0 0 0 21 30 27 21 30 | |
| · mediana | 8,5 | 11,5 | **0,80** |
| · pasadas limpias | 4 de 16 | 6 de 16 | |
| Fotogramas de vídeo perdidos | mediana 113 | mediana 161 | **0,92** |
| · pasadas limpias | 5 de 16 | 6 de 16 | |

La tabla por pasada está en `video-b16-esc2.md`.

**El estado lento llega en rachas de tiempo y no según la versión:**

- 15:45–15:53 del 25-11: 08, 09 y 10;
- 10:52–10:56 del 26-11: 26 y 27;
- 13:35–13:43 del 26-11: 29, 30 y 32, justo después de una hora y media con la pantalla bloqueada.

En cada racha caen las dos versiones.

## Vídeo local (sí de Titín, transmitido por COORDINACIÓN-63)

**Descargas, cada una en su carpeta, con sha256:**

- ffmpeg 9.1, compilación estática de evermeet.cx, enlazada desde ffmpeg.org:
  - `ffmpeg-9.1.zip`: `9962f7b3c01af9ac89673c91df9ef998343a280ac0857c295e2d2a301820598a`;
  - su `.sig`: `dc52e7d530039fe3961dd3fe5740531d7e984caf95f49a6b031c4d908de8b889`.
- Big Buck Bunny, 1080p60, licencia CC-BY de la Blender Foundation, de download.blender.org:
  - `bbb_sunflower_1080p_60fps_normal.mp4.zip`: `68c456673409f8df09b80d0afe29ecb38ef110551fa8a93c83e54a96ebdaec78`.

**Ficheros servidos solo en 127.0.0.1:8125 en la 6,1** (`srv61.py`, carpeta `entregas/bench-local/vlocal/`). Los tres
llegaron con el mismo sha256:

- `bbb-1080p60-h264.mp4`: copia sin recodificar, del s60 al s360, sin audio:
  `0c4b49785fa7fa2e734ee39d2537a4688ad805f07c262ddcf7ff5d7f8d723bfd`.
- `bbb-1080p60-vp9.webm`: libvpx-vp9 a 5 Mb/s:
  `4e548f7243d2688ed4060cc8fd0e39c8b52f8f97793db65bc6bbfc0a855fa6af`.
  - Preparado, pero no medido.
- `video.html`: `<video autoplay muted loop>`, y `vlocalDatos()` con los mismos campos que los datos de YouTube:
  `5010a46d498daae499d8a95554714e2c13084bc1c94ba56b0bfb15b2ad4e9084`.

**Resultado con H.264, 3 intentos, 3.2.2 publicada, con muestreo** (`vl4-local-h264-esc2-{1,2,3}`):

| Intento | fps mínimo del s12 al final | s lentos | perdidos carga→inicio | perdidos inicio→fin | resolución |
|---|---|---|---|---|---|
| 1 | 59,7 | 0 | 49 | 0 | 1920x1080@60 |
| 2 | 59,5 | 0 | 58 | 0 | 1920x1080@60 |
| 3 | 59,2 | 0 | 54 | 0 | 1920x1080@60 |

## `sample` con YouTube (3.2.2 publicada, con muestreo)

Hubo 4 intentos válidos a 1080p60: `vl3-base-esc2-2-r29`, `-4-r60`, `-5` y `-6`.

- **En ninguno hubo segundos lentos del s15 al final.** El mínimo, de 33 a 41 fps, cae siempre en la carga (s3–7), que
  el detector excluye a propósito: en la carga muestrear ocho procesos hundía la página.
- Por eso, **ningún cliente tiene pila de espera del tramo lento, y no puedo decir si tiene o no
  `WaitForGetOffsetInRange`, `WaitForTokenInRange`, `Flush` u `OrderingBarrier` en ese tramo.** No lo doy por
  descartado: falta el dato.
- Solo hay pilas del tramo normal, de `vl-base-esc2-1` (25-11). Allí:
  - el compositor del renderer de Aquarium suma 9 ms de `GpuChannelHost::VerifyFlush`, desde
    `cc::LayerTreeHostImpl::GenerateCompositorFrame` → `viz::ClientResourceProvider::PrepareSendToParent`;
  - el renderer del vídeo, casi nada;
  - el navegador, nada.
- `esperas.py`, en esta carpeta, saca esas pilas por hilo en cuanto haya un `sample` lento.

## Lo que queda abierto: mezcla de factores

Las pasadas que entran en lento usan el binario de E1 (`e1-322`, también en e1d) **sin** muestreo. Las que no entran
nunca usan la 3.2.2 publicada **con** muestreo. Hay tres explicaciones que estas pasadas no separan:

- el binario;
- el muestreador;
- el azar de las rachas.

Las de YouTube sin estado lento corrieron a las 09:00–09:13, y entre 09:16 y 09:44 el binario de E1 entró en lento en
5 de 8 pasadas.

Propuesta para ARQUITECTURA, que decide:

1. **Una cadena alterna para separar los factores:** [3.2.2 sin muestreo, e1d sin muestreo, 3.2.2 con muestreo, e1d
   con muestreo] ×4, con YouTube. Así se ve qué hace falta para entrar en lento.
2. **Los `sample` del tramo lento con lo que entre en lento.** Si es el e1d, con el dSYM de su compilación.
3. **VP9 local:** ya está preparado, por si hace falta separar decodificador.

Si el estado lento solo aparece con YouTube, encaja con lo que dice el vídeo local: lo pondría el reproductor de
YouTube (MSE o su manera de pedir fotogramas) y no la decodificación 1080p60 en sí.

## Otros

- La 6,1 estuvo bloqueada de 12:00 a 13:30 del 26-11, durante una espera de una hora por 480p, y la cadena reintentó
  cada 5 min.
- Titín lo desbloqueó. Para las cadenas largas dejo `caffeinate -d -i -u -t 43200` en la 6,1: no necesita sudo y se
  apaga solo.
