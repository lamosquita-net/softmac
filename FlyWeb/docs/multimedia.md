# FlyWeb — Multimedia y GPU (Fase 5)

Hito: tabla de rendimiento por máquina y backend de ANGLE, con el backend por defecto decidido.

## 1. Cómo medir (LOCAL o HUMANO, en cada máquina)

1. **Página de diagnóstico.** Arrastrar `FlyWeb/tools/diagnostico-gpu.html` a una pestaña de FlyWeb y pulsar «Medir».
   Saca la GPU y el backend de ANGLE, los códecs que se decodifican de forma eficiente (≈ por hardware) y el rendimiento
   de WebGL. Pulsar «Copiar JSON» y pegarlo en §3.
   - **Rendimiento (desde el 03/10):** tres pruebas que **no dependen del refresco de la pantalla**. Se dibuja en un
     búfer propio de 1024 × 1024 píxeles reales (igual en todas las máquinas, sin `devicePixelRatio`) y se cronometra
     forzando a la GPU a terminar; mediana de 7 repeticiones.
     - `sombreado`: un cálculo pesado por píxel (ms por pasada; megapíxeles/s). Mide la GPU en bruto.
     - `llamadas`: 5000 dibujos pequeños (µs por llamada). **Es la que mejor distingue OpenGL de Metal**, porque los
       motores de ANGLE se diferencian sobre todo en el coste de cada llamada.
     - `texturas`: subir una imagen de 4 MB a la GPU (ms; MB/s).
     - `fpsEnPantalla`: la medida antigua, solo de referencia: se queda en el refresco del monitor (60 Hz).
   - Medir con la ventana visible y sin otras pestañas pesadas. Si dos repeticiones dan más de un 10 % de diferencia,
     anotar las dos.
2. **Repetir con cada backend**, cerrando FlyWeb antes:
   ```sh
   open -na "FlyWeb Development.app" --args --use-angle=metal
   open -na "FlyWeb Development.app" --args --use-angle=gl
   ```
   Sin argumento se usa el que elige Chromium 116 (en Mac, Metal si la GPU lo admite).
3. **`brave://gpu`:** anotar «Graphics Feature Status» (sobre todo *Video Decode*, *WebGL*, *Rasterization*) y la línea
   `GL_RENDERER`. Si algo dice *Software only* o *Disabled*, copiar la sección «Problems Detected».
4. **Vídeo real:** un vídeo H.264 1080p y otro VP9 (p. ej. YouTube en 1080p; en «Estadísticas para nerds» se ve el
   códec y los fotogramas perdidos). Con el vídeo en marcha, en `brave://media-internals` → pestaña del reproductor,
   anotar `kVideoDecoderName` (`VideoToolboxVideoDecoder` o `VDAVideoDecoder` = hardware; `FFmpegVideoDecoder` o
   `VpxVideoDecoder` = software) y la CPU del proceso de la pestaña en el Monitor de Actividad.

### 1b. Ronda completa en las tres máquinas (encargo del HUMANO, 03/10)

En cada máquina (7,1 Radeon Pro 580X, Sequoia; 6,1 2 × FirePro D500, Mojave; 5,1 RX 580, Mojave), con la misma
compilación y un perfil nuevo, **tres arranques**: sin argumentos, `--use-angle=metal` y `--use-angle=gl`. En cada
uno, la página de diagnóstico dos veces (para ver si repite) y pegar los JSON en §3. Luego, solo con el motor por
defecto, la prueba de uso real de §1c.

En la 6,1 conviene además anotar **qué D500 usa FlyWeb**: `flyweb://gpu` (`brave://gpu` en compilaciones sin el paso 34), apartado *GPU0/GPU1* y *Active*. macOS dibuja
la pantalla con una y deja la otra para cálculo; Chromium usa solo la activa. Si un monitor va a cada tarjeta, abrir
FlyWeb en cada pantalla y medir en las dos.

### 1c. Uso real (sobre todo en la 6,1, la de peor gráfica)

Con el Monitor de Actividad abierto en la pestaña CPU (y «Ventana → Historial de la GPU» para ver la carga de la
GPU), apuntar en cada caso la CPU del proceso «FlyWeb Helper (GPU)» y del de la pestaña, y si hay tirones:

| Prueba | Qué mirar |
|---|---|
| YouTube 1080p en H.264 (con la extensión h264ify o una lista que lo fuerce) | Fotogramas perdidos en «Estadísticas para nerds»; CPU < 30 % esperable con hardware |
| YouTube 1080p en VP9 (lo normal sin forzar) | Fotogramas perdidos; CPU (por software: esperable alta) |
| Desplazarse rápido por claude.ai con una conversación larga, y por elmundo.es | Tirones al desplazarse; CPU del proceso de GPU |
| Google Maps en vista 3D/satélite, girando | Fluidez; si aparece el aviso de «WebGL no disponible» |
| 20 pestañas abiertas y cambiar entre ellas | Retraso al cambiar; memoria de la GPU en `flyweb://gpu` |
| Página de diagnóstico con otra pestaña reproduciendo vídeo | Cuánto bajan `sombreado` y `llamadas` |

Qué significaría cada resultado en la 6,1:
- **`llamadas` claramente peor con Metal que con OpenGL** (más de un 20 %): candidata a fijar OpenGL para las D500
  (F5.2, una regla por ID de GPU, solo para esa tarjeta).
- **Tirones al desplazarse o al cambiar de pestaña con CPU de GPU alta**: la composición por GPU va justa; F5.3 (el
  artefacto de pantalla) y este punto se estudian juntos.
- **VP9 con fotogramas perdidos**: no es la GPU (VP9 va por software en las tres); la solución es forzar H.264 (h264ify
  o equivalente), no código.
- **Todo fluido**: no se toca nada; las D500 bastan para navegar aunque tengan menos de la mitad de potencia.

## 2. Qué decidir con los datos

- **Backend por defecto por GPU:** si en alguna GPU (p. ej. las FirePro de la 6,1) un motor es claramente mejor en
  `llamadas` y `sombreado` (más de un 20 %) o da menos fallos que el otro, NUBE fija el backend para esa GPU (lista de GPU en `gpu/config` o una regla en `brave-core`).
  Si Metal va igual o mejor en todas, no se toca nada.
- **Códecs:** H.264 debe salir por hardware en todas (VideoToolbox existe desde 10.8). VP9 por hardware solo en GPU
  modernas; en la 6,1 y la 5,1 lo esperable es software. Si YouTube en VP9 va a tirones en la 5,1, la solución es una
  extensión o ajuste que fuerce H.264 (no requiere código).
- **AV1:** en estas máquinas siempre por software (dav1d); costoso a 1080p en la 5,1.

## 3. Resultados

| Máquina | GPU | Backend | WebGL FPS | H.264 HW | VP9 HW | HEVC | `kVideoDecoderName` (H.264 / VP9) | CPU con vídeo 1080p | Notas |
|---|---|---|---|---|---|---|---|---|---|
| MacPro7,1 (macOS 15.8 Sequoia) | AMD Radeon Pro 580X | Metal (`--use-angle=metal`) | 42,4 | Sí (1080p y 4K) | No (software) | **Sí** (hardware) | pendiente | pendiente | 03/10, LOCAL. `flyweb` 4bb83c07 (paso 30), perfil temporal, `--disable-gpu-vsync --disable-frame-rate-limit`, con ventana y sin ventana (mismos números). AV1 por software |
| MacPro7,1 (macOS 15.8 Sequoia) | AMD Radeon Pro 580X | **OpenGL 4.1 = también el motor por defecto de 116 en Sequoia** | 42,4 (por defecto) / 43,0 (`--use-angle=gl`) | Sí | No | Sí | pendiente | pendiente | Sin `--use-angle`, ANGLE elige OpenGL igual que en Mojave. **Los tres modos dan lo mismo (±1 %), aun sin vsync:** la prueba sigue sin distinguir motores. Raro: la 580X da 42 FPS y la D500 llegó al tope de 61; probablemente el lienzo se dibuja a escala Retina (la pantalla de la 7,1 va en modo escalado) y la carga no es comparable entre máquinas |
| MacPro6,1 (MacTrash, 10.14.6) | 2× FirePro D500 (activa una), driver ATI-2.11.26 | Metal (`--use-angle=metal`) | 61 (tope de la pantalla, 60 Hz) | Sí (1080p y 4K, `powerEfficient`) | No (software, fluido) | No admitido | pendiente (`media-internals`) | pendiente | 01/10, LOCAL por SSH. `flyweb` cba0493c. AV1 por software |
| MacPro6,1 (MacTrash, 10.14.6) | 2× FirePro D500 (activa una) | **OpenGL 4.1 = el motor por defecto de 116 en Mojave** | 61 (tope 60 Hz) | Sí | No (software) | No admitido | pendiente | pendiente | Sin `--use-angle`, ANGLE elige OpenGL, no Metal. **El shader de 1024×1024 no satura la D500: los tres modos llegan al tope de refresco, así que la prueba no distingue backends.** Hace falta una carga más pesada o medir sin vsync (NUBE) |
| MacPro5,1 | | Metal | | | | | | | |
| MacPro5,1 | | OpenGL | | | | | | | |

La página se probó en la nube con Chromium 141 y GPU por software (SwiftShader): funciona de principio a fin, pero esos
números no valen como referencia.

<details><summary>JSON de cada medición</summary>

**MacPro6,1, porDefecto** (01/10):
```json
{
  "fecha": "2026-10-01T19:51:28.173Z",
  "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36",
  "lineaDeOrdenes": "anotar a mano: normal / --use-angle=metal / --use-angle=gl",
  "gpu": {
    "webgl": true,
    "webgl2": true,
    "vendor": "Google Inc. (ATI Technologies Inc.)",
    "renderer": "ANGLE (ATI Technologies Inc., AMD Radeon HD - FirePro D500 OpenGL Engine, OpenGL 4.1)",
    "backend": "OpenGL",
    "maxTextureSize": 16384
  },
  "codecs": [
    {
      "name": "H.264 1080p",
      "type": "video/mp4; codecs=\"avc1.640028\"",
      "supported": true,
      "smooth": true,
      "powerEfficient": true
    },
    {
      "name": "H.264 4K",
      "type": "video/mp4; codecs=\"avc1.640033\"",
      "supported": true,
      "smooth": true,
      "powerEfficient": true
    },
    {
      "name": "HEVC 1080p",
      "type": "video/mp4; codecs=\"hvc1.1.6.L120.90\"",
      "supported": false,
      "smooth": false,
      "powerEfficient": false
    },
    {
      "name": "VP9 1080p",
      "type": "video/webm; codecs=\"vp09.00.40.08\"",
      "supported": true,
      "smooth": true,
      "powerEfficient": false
    },
    {
      "name": "VP9 4K",
      "type": "video/webm; codecs=\"vp09.00.51.08\"",
      "supported": true,
      "smooth": true,
      "powerEfficient": false
    },
    {
      "name": "AV1 1080p",
      "type": "video/mp4; codecs=\"av01.0.08M.08\"",
      "supported": true,
      "smooth": true,
      "powerEfficient": false
    }
  ],
  "webglPerf": {
    "fps": 61.2,
    "frames": 123,
    "ms": 2010
  }
}
```

**MacPro6,1, metal** (01/10):
```json
{
  "fecha": "2026-10-01T19:52:59.928Z",
  "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36",
  "lineaDeOrdenes": "anotar a mano: normal / --use-angle=metal / --use-angle=gl",
  "gpu": {
    "webgl": true,
    "webgl2": true,
    "vendor": "Google Inc. (AMD)",
    "renderer": "ANGLE (AMD, ANGLE Metal Renderer: AMD Radeon HD - FirePro D500, Unspecified Version)",
    "backend": "Metal",
    "maxTextureSize": 16384
  },
  "codecs": [
    {
      "name": "H.264 1080p",
      "type": "video/mp4; codecs=\"avc1.640028\"",
      "supported": true,
      "smooth": true,
      "powerEfficient": true
    },
    {
      "name": "H.264 4K",
      "type": "video/mp4; codecs=\"avc1.640033\"",
      "supported": true,
      "smooth": true,
      "powerEfficient": true
    },
    {
      "name": "HEVC 1080p",
      "type": "video/mp4; codecs=\"hvc1.1.6.L120.90\"",
      "supported": false,
      "smooth": false,
      "powerEfficient": false
    },
    {
      "name": "VP9 1080p",
      "type": "video/webm; codecs=\"vp09.00.40.08\"",
      "supported": true,
      "smooth": true,
      "powerEfficient": false
    },
    {
      "name": "VP9 4K",
      "type": "video/webm; codecs=\"vp09.00.51.08\"",
      "supported": true,
      "smooth": true,
      "powerEfficient": false
    },
    {
      "name": "AV1 1080p",
      "type": "video/mp4; codecs=\"av01.0.08M.08\"",
      "supported": true,
      "smooth": true,
      "powerEfficient": false
    }
  ],
  "webglPerf": {
    "fps": 60.9,
    "frames": 122,
    "ms": 2004
  }
}
```

**MacPro6,1, gl** (01/10):
```json
{
  "fecha": "2026-10-01T19:54:32.380Z",
  "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36",
  "lineaDeOrdenes": "anotar a mano: normal / --use-angle=metal / --use-angle=gl",
  "gpu": {
    "webgl": true,
    "webgl2": true,
    "vendor": "Google Inc. (ATI Technologies Inc.)",
    "renderer": "ANGLE (ATI Technologies Inc., AMD Radeon HD - FirePro D500 OpenGL Engine, OpenGL 4.1)",
    "backend": "OpenGL",
    "maxTextureSize": 16384
  },
  "codecs": [
    {
      "name": "H.264 1080p",
      "type": "video/mp4; codecs=\"avc1.640028\"",
      "supported": true,
      "smooth": true,
      "powerEfficient": true
    },
    {
      "name": "H.264 4K",
      "type": "video/mp4; codecs=\"avc1.640033\"",
      "supported": true,
      "smooth": true,
      "powerEfficient": true
    },
    {
      "name": "HEVC 1080p",
      "type": "video/mp4; codecs=\"hvc1.1.6.L120.90\"",
      "supported": false,
      "smooth": false,
      "powerEfficient": false
    },
    {
      "name": "VP9 1080p",
      "type": "video/webm; codecs=\"vp09.00.40.08\"",
      "supported": true,
      "smooth": true,
      "powerEfficient": false
    },
    {
      "name": "VP9 4K",
      "type": "video/webm; codecs=\"vp09.00.51.08\"",
      "supported": true,
      "smooth": true,
      "powerEfficient": false
    },
    {
      "name": "AV1 1080p",
      "type": "video/mp4; codecs=\"av01.0.08M.08\"",
      "supported": true,
      "smooth": true,
      "powerEfficient": false
    }
  ],
  "webglPerf": {
    "fps": 60.9,
    "frames": 122,
    "ms": 2004
  }
}
```

(pegar aquí)


**MacPro7,1, tres motores** (03/10, sin vsync):
```json
{"motor": "porDefecto", "gpu": {"webgl": true, "webgl2": true, "vendor": "Google Inc. (ATI Technologies Inc.)", "renderer": "ANGLE (ATI Technologies Inc., AMD Radeon Pro 580X OpenGL Engine, OpenGL 4.1)", "backend": "OpenGL", "maxTextureSize": 16384}, "webglPerf": {"fps": 42.4, "frames": 85, "ms": 2004}, "codecs": [{"name": "H.264 1080p", "supported": true, "smooth": true, "powerEfficient": true}, {"name": "H.264 4K", "supported": true, "smooth": true, "powerEfficient": true}, {"name": "HEVC 1080p", "supported": true, "smooth": true, "powerEfficient": true}, {"name": "VP9 1080p", "supported": true, "smooth": true, "powerEfficient": false}, {"name": "VP9 4K", "supported": true, "smooth": true, "powerEfficient": false}, {"name": "AV1 1080p", "supported": true, "smooth": true, "powerEfficient": false}]}
{"motor": "metal", "gpu": {"webgl": true, "webgl2": true, "vendor": "Google Inc. (AMD)", "renderer": "ANGLE (AMD, ANGLE Metal Renderer: AMD Radeon Pro 580X, Unspecified Version)", "backend": "Metal", "maxTextureSize": 16384}, "webglPerf": {"fps": 42.4, "frames": 85, "ms": 2006}, "codecs": [{"name": "H.264 1080p", "supported": true, "smooth": true, "powerEfficient": true}, {"name": "H.264 4K", "supported": true, "smooth": true, "powerEfficient": true}, {"name": "HEVC 1080p", "supported": true, "smooth": true, "powerEfficient": true}, {"name": "VP9 1080p", "supported": true, "smooth": true, "powerEfficient": false}, {"name": "VP9 4K", "supported": true, "smooth": true, "powerEfficient": false}, {"name": "AV1 1080p", "supported": true, "smooth": true, "powerEfficient": false}]}
{"motor": "gl", "gpu": {"webgl": true, "webgl2": true, "vendor": "Google Inc. (ATI Technologies Inc.)", "renderer": "ANGLE (ATI Technologies Inc., AMD Radeon Pro 580X OpenGL Engine, OpenGL 4.1)", "backend": "OpenGL", "maxTextureSize": 16384}, "webglPerf": {"fps": 43, "frames": 87, "ms": 2021}, "codecs": [{"name": "H.264 1080p", "supported": true, "smooth": true, "powerEfficient": true}, {"name": "H.264 4K", "supported": true, "smooth": true, "powerEfficient": true}, {"name": "HEVC 1080p", "supported": true, "smooth": true, "powerEfficient": true}, {"name": "VP9 1080p", "supported": true, "smooth": true, "powerEfficient": false}, {"name": "VP9 4K", "supported": true, "smooth": true, "powerEfficient": false}, {"name": "AV1 1080p", "supported": true, "smooth": true, "powerEfficient": false}]}
```

</details>
