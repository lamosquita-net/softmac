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
- **Arreglado en `oficial-5` y `oficial-6` (LOCAL-19; ver más abajo):** el compilador de shaders de AMD de 10.14 (`AMDBronzeMTLCompilerPlugin`, LLVM `SelectionDAGISel::CannotYetSelect`) abortaba con algunos shaders que genera ANGLE. Lo que sigue es la descripción original.
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

## 05-11-2026 · MacPro6,1 · LOCAL-19: compilador Metal arreglado (`oficial-6`)

Batería completa con `chromium-156-b1d-oficial-6.zip` (sha256 `43fca6be…`), lanzada como un usuario (`--disable-features=MediaRouter,DialMediaRouteProvider`, con la caché persistente de serie).

| # | Prueba | 156 `oficial-6` |
|---|---|---|
| 1 | Aquarium 5 000 / 10 000 | 60 / 52 |
| 2 | WebGL Report | Sí / sí, «ANGLE Metal Renderer: FirePro D500» |
| 3 | three.js bloom / keyframes / shadowmap | **60 / 60 / 60**, se dibujan bien (bloom y sombras en las capturas) |
| 4 | Babylon Sponza | 53 de media; hay un parón de 0,6 s al compilar |
| 5 | Google Earth (Madrid 3D) | 39 de media por un parón de 1,5 s en la primera carga; después, 60 (la pasada de `oficial-5`: 60) |
| 6 | Photopea | 60 |
| 7 | Shadertoy Seascape / Elevated | 60 / **58** (antes 33) |
| 9 | YouTube 4K60 | El consentimiento ya no cuelga el guion. Se ofrece hd2160 a 60 fps, VP9 |
| 10 | vsynctester | 58 (un parón de 0,37 s) |
| 12 | WebGPU | Sin adaptador, como se esperaba |
| — | **Caídas** | **0 de MTLCompilerService, 0 reinicios de la GPU, 0 contextos perdidos, 0 caídas del navegador, 0 pipelines o librerías Metal fallidas** |

Los parones (Earth, Babylon, vsynctester) son la compilación síncrona de pipelines Metal en la primera carga, que ya estaba anotada como pendiente.

### Qué fallaba y cómo se ha arreglado

1. **La pérdida de contexto y el reinicio de la GPU no venían del command buffer.**
   - ANGLE trae `loseHardenedContextOnBackendError` activado de serie. En un contexto WebGL, cualquier error interno del backend marca el contexto como perdido con `UnknownContextReset` (`Context.cpp`, `ErrorSet::handleError`).
   - Chromium no sabe entonces a quién culpar y reinicia el proceso de GPU entero (exit 8704). Tras dos reinicios, bloquea WebGL.
2. **Google Earth y Photopea.**
   - En 10.14, `newLibraryWithSource` devuelve un `NSError` también cuando compila con solo advertencias («Compilation succeeded with: … unused variable 'p'»). `CreateMslShaderLib` lo tomaba por fallo.
   - Ahora el éxito exige solo que la `MTLLibrary` no sea nil, y nunca se mira el texto del error (condición 2 de SEGURIDAD-PORTES-17).
   - Si la librería es nil, falla el enlazado de ese programa, con su registro, y no se pierde el contexto.
3. **three.js (bloom y shadowmap).**
   - El compilador de AMD aborta al crear el **pipeline**, no al compilar el MSL.
   - Se volcó el MSL (`FLYWEB_MTL_DUMP=1`) y se reprodujo fuera de Chromium con una herramienta mínima (`newRenderPipelineStateWithDescriptor` sobre el MSL de ANGLE): en la 6,1 falla y en la 7,1 compila.
   - Reducción: la caída exige que `RE_Direct_Physical` (luces directas de `MeshStandardMaterial`) quede inlineada del todo.
   - No influyen `pow`, las divisiones, `fast math`, la versión del MSL, el formato de profundidad ni el `bool` de la estructura.
   - Con `__attribute__((noinline))` en esa función compila.
   - **Arreglo:** el traductor marca `noinline` las funciones de usuario con parámetros `out`/`inout` y sin parámetros de textura o sampler. Solo en GPU AMD con macOS anterior a 10.15; `FLYWEB_MTL_NOINLINE=0/1` lo fuerza.
4. **Defensa.** Si aun así un pipeline no se puede crear:
   - Se guarda como fallido y se salta solo ese dibujo. El siguiente dibujo vuelve a aplicar todo el estado.
   - No se pierde el contexto de la página ni el del compositor, y no se recompila en cada fotograma.
5. **Babylon (salió en la batería).**
   - El Metal 2.1 de 10.14 no tiene `matriz / escalar` ni `matriz /= escalar`, así que fallaba su shader principal y Babylon pasaba a uno de reserva.
   - Ahora el prelude del MSL añade los dos operadores antes de 10.15.

Parches de ANGLE: `b1d/angle/0006`, `0007` y `0008` (sobre `a66226b`; los ocho reproducen el árbol `3b24dd0`). src `flynk-b1d` `805e5d0cff`.

### `oficial-7` (ANGLE en la punta de `chromium/8078` y guardas de selectores), 05-11 20:10

- **Batería completa:** Aquarium 60 / 52; three.js 60 / 60 / 60; Babylon 60; Earth 60; Photopea 60; Seascape 60; Elevated 33; vsynctester 60; WebGPU sin adaptador.
  - **0 caídas** de MTLCompilerService, 0 reinicios de la GPU, 0 contextos perdidos, 0 pipelines o librerías fallidas, 0 «unrecognized selector».
  - El parón de la primera carga de Earth no salió esta vez.
  - Elevated vuelve a 33 (en `oficial-6`, 58). La diferencia entre pasadas parece del contenido de la página o de la descarga, no del cambio: oficial-7 no toca Metal.
- **Humo:** WebGL normal y de alto rendimiento, UA-CH «macOS 10.14.6», clic derecho, descarga, pantalla completa, `enumerateDevices`, `getUserMedia` (NotFoundError, no hay cámara) y Web MIDI: todo bien.
  - `navigator.share` abre el selector de compartir de macOS, que espera a que alguien elija, y deja la pestaña bloqueada para el resto del humo. Ya pasaba con `oficial-3`: es un efecto de la prueba, no una caída.
