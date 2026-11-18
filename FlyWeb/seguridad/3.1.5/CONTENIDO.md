# FlyWeb 3.1.5: contenido (parte 1)

SEGURIDAD-PORTES-25, 18-11-2026, por orden de COORDINACIÓN-47 (18-11 ~10:06): primero G3a de
[`PROPUESTA-MEDIOS.md`](PROPUESTA-MEDIOS.md), los [M156] de la 8078 posteriores a la .110, los dos medios de Media de
la 157 y el arreglo de Media de la 158 encima de fb2af07952; luego G3b; G4 al final (solo lo alcanzable sin
interacción del usuario); G1 y G2 fuera. **Nada compilado por mí.** **Parte 1 = todo lo de (1).** G3b y G4 quedan para
el relevo (abajo, «Pendiente»).

## Base y resultado (comprobados)

| Repositorio | Base | Serie | Resultado |
|---|---|---|---|
| chromium | 3.1.4: `local/313` `7ccbc27cf7` + `3.1.4/chromium` 0001–0026 (árbol `4e87f2898a`) | `chromium/` 0001–0013 | árbol **`2248183916`** (comprobado: `git am` de 3.1.4 0001–0026 y 3.1.5 0001–0013 sobre `local/313`) |
| V8 | 15.6.75.66 (`917584bd93`), sin cambio de gitlink | `patches/v8` de brave-core | con todos los `patches/v8`: árbol de V8 `ecf31d79a4` |
| brave-core | 3.1.4: `seg/3.1.4` `d91632790084` + `3.1.4/brave-core` 0003 (árbol `71e60c4558`) | `brave-core/` 0001–0002 (`.patch`: sin push a brave-core) | árbol **`e95338d8c9`** |

ANGLE, Dawn, FFmpeg, Skia y PDFium no cambian.

## G3a: los 14 medios de la 158

| Bug | CVE | Arreglo | Resultado |
|---|---|---|---|
| 568908052 | CVE-2026-130923 (V8) | 1942561 | **no aplica:** solo cambia la pila por defecto en Android |
| 571348848 | CVE-2026-131087 (V8) | 19048d3 | **entra** (brave-core 0001) |
| 576225189 | CVE-2026-131097 (V8) | 33ab43a | **entra** (brave-core 0001) |
| 577305505 | CVE-2026-130988 (V8) | 65afc9f | **entra** (brave-core 0001) |
| 536599243 | CVE-2026-130971 (ANGLE) | ANGLE 7f60c15 | **no aplica:** Vulkan |
| 561073365 | CVE-2026-131019 (ANGLE) | ANGLE 16cbe9b | **no aplica:** D3D11 |
| 551065275 | CVE-2026-131069 (WebGL) | ANGLE b40b594 | **no aplica:** el remedio (`recreateFboOnAttachmentRespecification`) solo se enciende en PowerVR, también en el respaldo GL |
| 571856431 | CVE-2026-131061 (Color) | fceb2ab8ad | **no aplica:** `components/eye_dropper` no existe en la 156 y el cuentagotas de Mac usa `NSColorSampler` (`eye_dropper_view_mac.mm`), no captura de fotogramas |
| 574302978 | CVE-2026-130976 (PDFium) | roll 26de93f124 (`~CFXJSE_FormCalcContext`) | **no aplica:** FormCalc es XFA, apagado en FlyWeb |
| 573262234 | CVE-2026-130936 (Media) | fb2af07952 | ya en la 3.1.4 (0018) |
| 573265164 | CVE-2026-131026 (Media) | daa730f185 | **entra** (0005) |
| 574311093, 574897062 | CVE-2026-130965, -130991 (Media) | 6a24d88908 | **entra** (0006), limpio |
| 581351423 | CVE-2026-131106 (Partition) | 367ca4e725 | **entra** (0007), limpio: el `fill_n` sin comprobar pasa a `base::span` (cierre controlado en vez de desbordamiento) |

## chromium 0001–0013

| Parche | Original | Bug / CVE | Qué | Cómo entra |
|---|---|---|---|---|
| 0001 | b71ea276fd | 40257965 | Media: los bloqueos de ORB cuentan como origen cruzado | limpio |
| 0002 | 8132e3a4c4 | 568972975, CVE-2026-121223 (medio de la 157) | Media: no reintentar peticiones bloqueadas por ORB | limpio (3 vías) |
| 0003 | dbd22daebd | 573253732 (sin CVE en las notas) | Media: no reintentar fallos deterministas (CORP/COEP, CORS, certificados): el ritmo de reintentos delataba si el servidor de otro origen respondía 206 o 416 | limpio |
| 0004 | propio | — | Media: `UrlData::CrossOriginFail()`, la parte de fb2af07952 que la 3.1.4 dejó fuera porque `DidFail()` no tenía aún el bloque de ORB | propio |
| 0005 | daa730f185 | 573265164, CVE-2026-131026 | Media: longitud coherente entre respuestas (`TrySetLength`/`HasCompatibleLength`) y no reintentar fallos de Service Worker | a mano solo `MergeFrom()` (con el 61b6e5652b de la 3.1.4) y la prueba de `TryInsert` (solo el caso de longitud) |
| 0006 | 6a24d88908 | 574311093, 574897062 | Media: píxeles sin inicializar en `ConvertVideoFrameToRGBPixels()` | limpio, con pruebas |
| 0007 | 367ca4e725 | 581351423, CVE-2026-131106 | PartitionAlloc: `PartitionPurgeSlotSpan` con `base::span` | limpio |
| 0008 | ba15fb1f7a [M156] | 576082223, 580866733, 578659916 | WebCodecs: *callbacks* por el *task runner* del contexto | limpio, `patch-id` igual |
| 0009 | 39e958e23e [M156] | 579277904 | `SyncLoadContext`: aplazar el final durante las redirecciones | limpio, `patch-id` igual |
| 0010 | 7f43e52174 [M156] | 582927496 | Streams: caché de las funciones de tamaño | 3 vías; ficheros resultantes **idénticos** a los de upstream (comprobado con gitiles) |
| 0011 | c404a3a5ff [M156] | 584997533 | Caché HTTP: validar entradas *sparse* antes de servir peticiones que necesitan red | limpio, `patch-id` igual |
| 0012 | d83ec3c16e [M156] | — | FSA: rutas UNC de escritorio remoto | limpio; solo Windows, inocuo en Mac (va porque comparte fichero con 0013) |
| 0013 | 859c5bc938 [M156] | 571250973 | FSA: sin resolución de rutas de la plataforma en incógnito | limpio, `patch-id` igual |

**Media, después de 0001–0005:** `resource_multi_buffer_data_provider.{cc,h}` quedan como en **158.0.8127.65** salvo la
clave de `UrlIndex` por origen (7b99dd29ba) y nombres de parámetros; `url_index.{cc,h}`, como la 158 más 61b6e5652b y sin
`kDisallowMixedOpaqueMediaResponses` (apagada en la 158).

**No portado: 7b99dd29ba** (571058818, CVE-2026-121105, medio de la 157, clave de `UrlIndex` por el origen del
documento). Choca con el constructor de `WebMediaPlayerImpl` (`WebLocalFrame*` frente a `FrameScheduler*` + origen +
URL y título del documento), así que habría que tocar también a todos los que lo crean. Upstream lo justifica con WebView
sin aislamiento de sitios; en escritorio, con aislamiento de sitios, solo afecta a documentos del mismo sitio y distinto
origen en un mismo proceso. Riesgo bajo; **lo decide COORDINACIÓN**.

**8078 tras la .110:** congelada en la **punta de la rama al empezar, `859c5bc938` (08:50 UTC del 18-11), sin tag**: la
.111 aún no lo tiene (`ls-remote` 10:14 UTC). Los parches salen de gitiles (`+/<sha>%5E%21/?format=TEXT`), porque el
espejo de GitHub solo tiene los tags. **`chrome/VERSION` se queda en .110**: no se declara una versión que Google no ha
publicado. Cuando salga la .111, cruzarla con 0008–0013 y subir `VERSION`.

## brave-core 0001–0002

| Parche | Qué |
|---|---|
| 0001 | `patches/v8`: 19048d3, 33ab43a y 65afc9f (limpios sobre la .66 con los `patches/v8` existentes) con sus tres pruebas de mjsunit; `kFlyWebCacheEpoch` 32 → **33**; nota en `patches/v8/FLYWEB-SECURITY.md` |
| 0002 | `flyweb_version` 3.1.4 → **3.1.5** |

**d8/mjsunit:** pedido a D8-LINUX por buzón, junto con el 659b8bf de la 3.1.4. **Sin el verde, 0001 no entra.**

## Cruce con brave-core

- `patches/` y `chromium_src/`: ninguno de los 48 ficheros de la serie tiene `.patch` ni `chromium_src` en brave-core.
- Los `#include` nuevos existen en el árbol, salvo los generados (`url_response_head.mojom.h`, `v8_encoded_video_chunk.h`,
  `v8_video_encoder_support.h`).
- **Huella:** 0011 cambia cuándo se sirve una entrada *sparse* de la caché HTTP (validación previa, como Chrome 156
  .111); nada toca TLS, cabeceras ni Client Hints.

## Veredicto (regla 17): **APTO**, parte 1

Revisado el código de cada parche contra la 156. Riesgos para LOCAL:
- **Media (0001–0005):** más fallos sin reintentos y comprobación de longitud. Pruebas:
  `blink_platform_unittests --gtest_filter='UrlIndexTest.*:ResourceMultiBufferDataProviderTest.*:MultiBufferDataSourceTest.*'`;
  y a mano: vídeo con saltos (YouTube 720p, Vimeo), audio de otro origen (radio en línea) y un vídeo servido por un
  Service Worker (p. ej. una PWA sin conexión).
- **0006:** `media_unittests --gtest_filter='PaintCanvasVideoRendererTest.*'`; vídeo en `<canvas>` (`drawImage` de un
  `<video>`) y WebGL con vídeo.
- **0008:** WebCodecs (`VideoEncoder`/`VideoDecoder`) en una demo de codificación.
- **0011:** vídeo largo con saltos y recarga (la caché *sparse* es la de los rangos de media).
- **V8:** el verde de D8-LINUX.

## Pendiente (relevo)

1. **G3b** (23 medios de la 158; lista en `PROPUESTA-MEDIOS.md`): buscar el commit de cada uno, comprobar si aplica y
   portar. Luego **G4**, solo lo alcanzable sin interacción del usuario.
2. **Medios de la 157** (`MEDIOS-157.md`): inventario por grupos, sin portar; falta buscar los commits.
3. CVE-2026-131081: vigilar la 159 (`kDisallowMixedOpaqueMediaResponses`).
4. D8-LINUX: verde de 659b8bf (3.1.4) y de brave-core 0001 (3.1.5).
5. 7b99dd29ba: decisión de COORDINACIÓN.
