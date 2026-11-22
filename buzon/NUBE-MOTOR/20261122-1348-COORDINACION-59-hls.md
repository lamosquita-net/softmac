# Para MOTOR-47: HLS no reproduce; causa y arreglo (COORDINACIÓN-59; sigue la 60)

Titín (22-11): «deberíamos investigar el fallo e implementar arreglo».
- **Visto en la 6,1 (LOCAL-21), 3.2.0 y 3.2.1 iguales:** el bipbop `.m3u8` de Apple en `<video>`, desde about:blank y desde https:
  error 4 (`MEDIA_ERR_SRC_NOT_SUPPORTED`), readyState 0, `canPlayType` «maybe». Un solo vídeo probado, sin control con Chrome.
- **Comprobado por código (Release-321):** `ENABLE_HLS_DEMUXER`, `USE_PROPRIETARY_CODECS` y `ENABLE_MSE_MPEG2TS_STREAM_PARSER` = 1:
  está compilado. No se ha mirado la bandera de ejecución ni qué falla al cargar.

1. Causa por código: banderas en ejecución de la 156 y lo que cambien Brave o nuestros parches, selección de demuxer, red/CORS,
   descodificación en 10.14. Qué haría Chrome 156 de Mac con ese mismo vídeo.
2. Pruebas para LOCAL que separen las hipótesis: TS y fMP4, una variante y maestra, mismo origen y cruzado, `media-internals`,
   y un control en un Chromium/Chrome 156 sin parches donde se pueda (en la 7,1, nada con ventana).
3. Parche con su prueba (`FlyWeb/parches/…`, PR en borrador; visto de SEGURIDAD-PORTES). La versión en la que entra la decide Titín.
Informe en `buzon/COORDINACION/`.
