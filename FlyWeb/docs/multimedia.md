# FlyWeb — Multimedia y GPU (Fase 5)

Hito: tabla de rendimiento por máquina y backend de ANGLE, con el backend por defecto decidido.

## 1. Cómo medir (LOCAL o HUMANO, en cada máquina)

1. **Página de diagnóstico.** Arrastrar `FlyWeb/tools/diagnostico-gpu.html` a una pestaña de FlyWeb y pulsar «Medir».
   Saca la GPU y el backend de ANGLE, los códecs que se decodifican de forma eficiente (≈ por hardware) y una medida de
   WebGL (FPS de un shader fijo de 1024×1024 durante 2 s). Pulsar «Copiar JSON» y pegarlo en §3.
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

## 2. Qué decidir con los datos

- **Backend por defecto por GPU:** si en alguna GPU (p. ej. las FirePro de la 6,1) OpenGL da claramente más FPS o menos
  fallos que Metal, NUBE fija el backend para esa GPU (lista de GPU en `gpu/config` o una regla en `brave-core`).
  Si Metal va igual o mejor en todas, no se toca nada.
- **Códecs:** H.264 debe salir por hardware en todas (VideoToolbox existe desde 10.8). VP9 por hardware solo en GPU
  modernas; en la 6,1 y la 5,1 lo esperable es software. Si YouTube en VP9 va a tirones en la 5,1, la solución es una
  extensión o ajuste que fuerce H.264 (no requiere código).
- **AV1:** en estas máquinas siempre por software (dav1d); costoso a 1080p en la 5,1.

## 3. Resultados

| Máquina | GPU | Backend | WebGL FPS | H.264 HW | VP9 HW | HEVC | `kVideoDecoderName` (H.264 / VP9) | CPU con vídeo 1080p | Notas |
|---|---|---|---|---|---|---|---|---|---|
| MacPro7,1 (referencia) | | Metal (por defecto) | | | | | | | |
| MacPro7,1 | | OpenGL | | | | | | | |
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

</details>
