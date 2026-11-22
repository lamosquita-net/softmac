# Para COORDINACIÓN-60 y MOTOR-47: HLS, corrección y batería de la 6,1 preparada (LOCAL-23)

Sale de ensayar en la 7,1 el banco del PR #1208 (96d0c0be) con `medios-hls-3seg.tgz` (sha256 comprobado).
Todo con Chrome for Testing 156.0.8078.80 sin parches y `--headless=new`, por código. FlyWeb no se ha vuelto a correr.

## Corrección de `20261122-1409-LOCAL-23-hls.md`

Di `apple-bipbop-ts` como fallo fijo «igual en los dos» con **una pasada por navegador. Es intermitente en Chrome sin parches:**

| Prueba, sumando todas las pasadas de hoy con CfT | Pasadas | Sin error | Error 3, rs 4 |
|---|---|---|---|
| `apple-bipbop-ts` (página http; para al pasar el umbral) | 8 | 1 | 7 |
| El mismo vídeo puesto en `about:blank` (25 s enteros) | 8 | 4 | 4 |

- Siempre que falla es `CHUNK_DEMUXER_ERROR_APPEND_FAILED: stream parsing failed`, unas veces en t = 0 y otra en t = 18,7.
- Las dos filas no se comparan entre sí: no miran el mismo tiempo de reproducción.
- Consecuencia: **una pasada de bipbop_4x3 no sirve para comparar versiones ni como puerta de una entrega.** La igualdad
  FlyWeb = CfT del primer informe se sostiene en los 13 casos locales; en ese de Apple, no con una sola pasada.
- El error 4 con rs 0 de la 6,1 **no ha salido en ninguna de las 16**.

## El banco nuevo, en la 7,1 con CfT

- Los 12 locales pasan al segundo segmento (t ≈ 5,2 s) con `VideoToolboxVideoDecoder`; el negativo falla como debe.
- `apple-bipbop-ts-cors` y `apple-bipbop-fmp4-cors`: error 4, rs 0, `HlsDemuxerStatus::Network read stopped`, igual que el
  negativo sin cabecera. Indica que ese servidor de Apple no manda CORS para este origen (inferido del error; no he mirado
  las cabeceras). Ojo al leerlos en la 6,1: dan el mismo código y `readyState` que el síntoma.

## Batería de la 6,1: preparada, sin lanzar (espera el sí de Titín, junto con M1)

1. `control-mp4-mismo`; si no reproduce, para ahí (parada comprobada con un caso que falla seguro).
2. El resto de los 17 casos, con los medios de 3 segmentos.
3. La prueba original desde `about:blank`, **tres veces** y alternada con su caso http, por lo intermitente.
4. `chrome://media-internals` abierta; `kVideoDecoderName` y el primer error de cada caso, además, por CDP (dominio Media).

— LOCAL-23
