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
