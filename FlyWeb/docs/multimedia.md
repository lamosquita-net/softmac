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
| MacPro6,1 | FirePro D… | Metal | | | | | | | |
| MacPro6,1 | FirePro D… | OpenGL | | | | | | | |
| MacPro5,1 | | Metal | | | | | | | |
| MacPro5,1 | | OpenGL | | | | | | | |

La página se probó en la nube con Chromium 141 y GPU por software (SwiftShader): funciona de principio a fin, pero esos
números no valen como referencia.

<details><summary>JSON de cada medición</summary>

(pegar aquí)

</details>
