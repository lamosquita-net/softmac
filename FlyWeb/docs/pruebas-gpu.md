# Pruebas de GPU de FlyWeb (batería de la 2.7.0)

Lista de Titín (04-11-2026). Es la batería del **hito común de GPU** de FM.55 (vía GL B1c y vía Metal B1d) y de cualquier
versión que toque la GPU. Se pasa en la **6,1 con Mojave**, en las mismas condiciones que con la 2.7.0, y se compara con
ella. Para cada web se apunta la cifra, si va fluido y si algo sale mal dibujado. Antes de empezar, `chrome://gpu` tiene que decir
«Hardware accelerated» en Compositing, Rasterization y WebGL/WebGL2; se anota la GPU y el backend (`angle=opengl` o `angle=metal`).

| # | Web | Qué hacer | Qué apuntar |
|---|---|---|---|
| 1 | WebGL Aquarium — https://webglsamples.org/aquarium/aquarium.html | 5 000 peces y luego 10 000 | fps de cada uno |
| 2 | WebGL Report — https://webglreport.com | Pestañas WebGL 1 y WebGL 2 | Funcionan sí/no; GPU que dice usar (unmasked renderer) |
| 3 | three.js — https://threejs.org/examples/ | `webgl_postprocessing_unreal_bloom`, `webgl_animation_keyframes`, `webgl_shadowmap` | Fluido sí/no; fallos de dibujo |
| 4 | Babylon.js — https://www.babylonjs.com/featureDemos/ | Una escena grande («Sponza» o «Espilit») | Fluido sí/no; fallos de dibujo |
| 5 | Google Earth — https://earth.google.com/web/ | Volar por una ciudad en 3D | Fluido sí/no; fallos de dibujo |
| 6 | Photopea — https://www.photopea.com | Abrir una imagen grande y aplicar filtros | Respuesta; fallos |
| 7 | Shadertoy — https://www.shadertoy.com | Un par de shaders de la portada | fps de cada uno |
| 8 | Fishbowl — https://testdrive-archive.azurewebsites.net/performance/fishbowl/ | Muchos objetos en 2D | fps; si no carga, se salta |
| 9 | YouTube 4K a 60 fps | Clic derecho → «Estadísticas para nerds» | Fotogramas perdidos; códec. En Mojave, VP9/AV1 van por software: anotar el códec. En `chrome://media-internals`, si el decodificador es por hardware (H.264/HEVC) |
| 10 | vsynctester — https://www.vsynctester.com | Dejarlo correr | Regular o con tirones |
| 11 | MotionMark | Prueba completa | Puntuación frente a la 2.7.0 (incluye animación CSS, canvas y SVG) |
| 12 | WebGPU | `chrome://gpu` y una demo | Anotar si funciona (en Mojave se espera que no) |

Resultados: tabla por versión y backend en este fichero (sección nueva por prueba), con la fecha y la máquina, sin números de serie.

## 05-11-2026 · MacPro6,1 (FirePro D500 ×2, macOS 10.14.6) · LOCAL-18

Las dos versiones se lanzan con un perfil nuevo y se manejan por CDP con `bat.py`. Las cifras son fps por `requestAnimationFrame` durante 10 s; en la tabla va la media. Con fps «60» el p95 está entre 18 y 19 ms.

| # | Prueba | 156 B1d (`angle=metal`, `oficial-4`) | 2.7.0 (`angle=opengl`) |
|---|---|---|---|
| — | `chrome://gpu` | Todo «Hardware accelerated». Skia GaneshGL. WebGPU desactivado | Todo «Hardware accelerated» |
| 1 | Aquarium 5 000 / 10 000 | 60 / 54 | 60 / 45 |
| 2 | WebGL Report 1 y 2 | Sí / sí. «ANGLE Metal Renderer: FirePro D500» | Sí / sí. «D500 OpenGL Engine, OpenGL 4.1» |
| 3 | three.js bloom / keyframes / shadowmap | 60 · **caída del compilador Metal** / 60 / 60 (después, «Error creating WebGL context») | 60 / 60 / 37 |
| 4 | Babylon Sponza | 60 aislada. En serie, «WebGL not supported» por el bloqueo de WebGL | 60 |
| 5 | Google Earth (Madrid 3D) | 60. Aislada, un reinicio de la GPU | 60 |
| 6 | Photopea (6 000 px y desenfoque) | 60. Aislada, un reinicio de la GPU y «Could not initialise shaders» | 60 |
| 7 | Shadertoy Seascape / Elevated | 60 / 33 | 60 / 60 |
| 8 | Fishbowl | No carga (la web ya no existe). Se salta | Igual |
| 9 | YouTube 4K60 | **2160p60 VP9** (`vp09.00.51.08`, por software): 679 fotogramas y 10 perdidos en 15 s | Máximo 1080p60 H.264 (`avc1.64002A`), 0 perdidos |
| 10 | vsynctester | 60, regular | 60, regular |
| 11 | MotionMark 1.3.2 | **1381,31** | 566,38 |
| 12 | WebGPU | Desactivado («sin adaptador»), como se esperaba | Igual |
| — | Caídas en la batería completa | **3 de MTLCompilerService, 2 reinicios de la GPU, 7 contextos perdidos** | 0 |

Fallos que han salido con la 156:

- **Arreglado** (`8f4b6e971c`): Babylon y Shadertoy tiraban **el navegador entero**.
  - La causa era `+[GCController setShouldMonitorBackgroundEvents:]`, de macOS 11.3, que daba «unrecognized selector» al leer los mandos.
  - Ahora el fetcher de GameController no se registra antes de 11.3 y los mandos van por HID.
  - La auditoría de débiles no lo veía porque los selectores de Objective-C no son símbolos.
- **Abierto, y bloquea la entrega:** el compilador de shaders de AMD de 10.14 (`AMDBronzeMTLCompilerPlugin`, LLVM `SelectionDAGISel::CannotYetSelect`) aborta con algunos shaders que genera ANGLE.
  - Es seguro con `webgl_postprocessing_unreal_bloom` y `webgl_shadowmap`.
  - La caída llega a ANGLE, la GPU se reinicia y, tras dos reinicios, Chromium bloquea WebGL para el resto de la sesión.
  - Google Earth y Photopea reinician la GPU sin que caiga el compilador, posiblemente por un error del command buffer.
  - Con GL (2.7.0) no pasa.

### Widevine (orden de COORDINACIÓN-27, 05-11 11:28)

Sin cuentas. Prueba EME `requestMediaKeySystemAccess('com.widevine.alpha')`, con 170 s de espera para que el component updater descargue el CDM, y el contenido Widevine público de Shaka (Angel One, licencia sin autenticación).

| | 156 B1d | 2.7.0 |
|---|---|---|
| EME Widevine | **No**: «Unsupported keySystem» | **No**: «Unsupported keySystem» |
| CDM en `chrome://components` | No aparece | No aparece |
| Shaka Angel One | No se reproduce | No se reproduce |
| Netflix, Spotify web, Prime Video, Movistar+ | La página carga, pero sin Widevine no se puede reproducir | Igual |

**Causa:** ninguna de las dos lleva Widevine.
- La 156 se compila como Chromium sin marca, así que `enable_widevine` queda en false (`third_party/widevine/cdm/widevine.gni`).
- La 156 tampoco lleva códecs propietarios (`proprietary_codecs`, `ffmpeg_branding`). Sin H.264 ni AAC, Netflix, Spotify y Prime fallarían aunque hubiera Widevine.

**Lo que haría falta, y es decisión de Titín o de COORDINACIÓN:**
1. `enable_widevine=true` para que el component updater descargue el CDM de Google.
2. Para Netflix y Prime, la firma VMP del navegador (castlabs EVS) y aceptar la licencia de Widevine.
3. `proprietary_codecs=true` y `ffmpeg_branding="Chrome"` (licencias de H.264 y AAC).
4. Comprobar que el CDM que se descargue hoy sigue funcionando en 10.14.
