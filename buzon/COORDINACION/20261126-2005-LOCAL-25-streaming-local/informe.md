# LOCAL-25 → COORDINACIÓN (65) y ARQUITECTURA: streaming local + Aquarium, pasada de comprobación

## Orden

Titín, en el chat de LOCAL-25 el 26-11, descarta todas las pruebas de vídeo online:

- la red 5G de la oficina es lenta, inestable y la comparten más dispositivos;
- YouTube añade cookies y otras cargas.

Quedan desacreditadas las tandas de vídeo con YouTube: `e1vib*`, `vb16`, `vl2`, `vl3`, `aq` y `cps`. Eso incluye el
informe `20261126-1420-LOCAL-25-video-lento`. Su orden es bajar el vídeo a local y montar una prueba de streaming
con servidor local.

## Montaje (sin descargas nuevas)

**Material.** Big Buck Bunny 1080p60 (Blender, CC BY 3.0), los mismos ficheros con sha256 del informe anterior.
Troceado con ffmpeg 9.1 (`-c copy`, HLS fMP4, `-hls_time 2`) en `entregas/bench-local/vlocal/`:

- `mse-h264/`: 110 segmentos, de 1,7 a 4,2 s porque respeta los fotogramas clave del original; 133 MB.
- `mse-vp9/`: 150 segmentos de 2 s; 234 MB. Preparado, no medido. Según Titín, la D500 no descodifica VP9 por
  hardware: si se mide, solo como control de CPU y aparte.

**Reproductor.** `vlocal/mse.html` (copia aquí; sha256 `fc9b4f00…a223`): MSE propio, sin bibliotecas, como el de
YouTube.

- Va pidiendo segmentos por `fetch` cada vez que el búfer por delante baja de 30 s.
- Borra lo que queda más de 30 s por detrás.
- Al acabar la lista vuelve a empezar (modo `sequence`).
- Se sirve solo en 127.0.0.1:8125 de la 6,1.
- Deja en el registro el búfer, las peticiones con su tiempo, los atascos (`waiting`) y los fotogramas perdidos.

**Conductor.** `m1.py` con `VIDEO_LOCAL=mse-h264`:

- sin YouTube, sin cookies y sin red exterior;
- captura de la pestaña del vídeo al cargar Aquarium y al acabar;
- datos del reproductor cada 5 s;
- el descodificador por CDP (`Media.enable` → `kVideoDecoderName`, `kIsPlatformVideoDecoder`), como pidió ARQUITECTURA.

## Resultado

Dos pasadas con la 3.2.2 publicada, escala 2, muestreador de ps encendido, 30 s de vídeo solo y después Aquarium 5000
al lado durante 45 s: `ml-mse-h264-esc2-1` y `-2`, en `entregas/local24/`.

| | pasada 1 | pasada 2 |
|---|---|---|
| Descodificador | (aún no se registraba) | `VideoToolboxVideoDecoder`, de plataforma (`true`) |
| Vídeo | 1920x1080@60 de principio a fin | igual |
| Capturas | se pinta el vídeo al cargar y al acabar | igual |
| fps de Aquarium s1–s4 | –, 7,8, 22,2, 50,6 | –, 8,3, 22,0, 55,2 |
| fps de Aquarium s5–s45 | 59,6–60,4 | 59,3–60,9 |
| s < 55 fps desde el s3 | 2 (s3 y s4, carga) | 1 (s3, carga) |
| 3 o más s lentos seguidos tras el s3 | **ninguno** | **ninguno** |
| Fotogramas perdidos: antes, carga, s15, fin | 3, 3, 60, 60 | 2, 2, 57, 57 |
| Atascos del reproductor | 3 antes y 5 al acabar; los 2 nuevos, al cargar Aquarium | 4 |
| Búfer por delante | 30–33 s todo el tiempo | 30–33 s |
| Peticiones | 41 en total, una cada ~2 s; mediana 12 ms, máximo 146 ms | 41; 13 ms, 273 ms |
| Hilo principal de la GPU, s5–s45 | 43–44 % (máximo 44,4) | 42–44 % (máximo 43,9) |
| Renderer de Aquarium, dos hilos más activos | ~51 % / 3,5 % | igual |

Las tablas por segundo están en `firma-ml-mse-h264-esc2-*.md`.

**La firma del estado lento no aparece:** el hilo principal de la GPU no pasa del 63 % en ningún segundo; el máximo
cae en el s4, en la carga. Con streaming local la única pérdida es la carga de Aquarium: unos 55 fotogramas de vídeo
y uno o dos atascos en los s1–4. Después, nada.

## Lectura

Con el criterio fijado por ARQUITECTURA («muestra algo» = 3 o más segundos lentos seguidos tras el s3), el streaming
local no reproduce el estado lento en ninguna de las dos pasadas.

ARQUITECTURA dijo que, si con streaming local no hay ni un segundo lento tras la carga, no pediría ni el interruptor
ni la traza. Que decida si hace falta la tanda de 8 con H.264 para cerrarlo con más pasadas.
