# Pruebas de HLS en `<video>`

Separan las hipótesis del fallo de HLS (error 4 con readyState 0 en 3.2.0 y 3.2.1). Todo va por 127.0.0.1 y,
salvo los dos casos de Apple, no sale a Internet.

| Fichero | Qué hace |
|---|---|
| `generar.sh [carpeta]` | Con ffmpeg (libx264 o VideoToolbox) genera un MP4 H.264 Main 3.0 + AAC-LC de 12 s (`control.mp4`) y, a partir de él, HLS en TS y en fMP4: `variante.m3u8`, `maestra.m3u8` (con `CODECS`), `maestra-sin-codecs.m3u8` y `maestra-sin-extension` (para forzar la vía de respaldo `DEMUXER_ERROR_DETECTED_HLS`). |
| `servir.py [carpeta]` | Abre dos orígenes: 127.0.0.1:8471 (la página) y :8472 (el cruzado). `/medios/…` va sin CORS y `/cors/medios/…` con `Access-Control-Allow-Origin: *`. Admite rangos. Guarda los resultados en `resultados.jsonl`. |
| `prueba.html` | Página con 15 casos: control MP4, TS/fMP4 × variante/maestra, mismo origen o cruzado con y sin CORS, y bipbop de Apple. Anota `error.code` **y `error.message`**, que lleva el estado del reproductor (`DEMUXER_ERROR_…`, `kNetworkReadError…`). |
| `correr.sh <binario> <etiqueta> [carpeta]` | Lanza cada caso en un navegador nuevo con `--headless=new`, sin ventana, con un perfil temporal y `--use-mock-keychain`. Guarda el registro VLOG del demuxer HLS y de la red de medios. Sale en `salida/<etiqueta>/`. |

## Uso (7,1, sin ventana)

```sh
cd /tmp && mkdir hls && cd hls
~/…/softmac/FlyWeb/tools/hls/generar.sh medios
~/…/softmac/FlyWeb/tools/hls/correr.sh /Applications/FlyWeb.app/Contents/MacOS/FlyWeb flyweb-321 medios
~/…/softmac/FlyWeb/tools/hls/correr.sh "<Chrome for Testing 156>/Contents/MacOS/Google Chrome for Testing" cft-156 medios
```

En la 6,1, con ventana, se puede abrir a mano: `python3 servir.py medios` y luego `http://127.0.0.1:8471/prueba.html`,
con `chrome://media-internals` abierto en otra pestaña.

## Cómo se lee

- `error.message` **no basta**: un fallo de red también sale como `DEMUXER_ERROR_COULD_NOT_PARSE` (comprobado en el
  control). La causa está en las líneas `HlsDemuxerStatus::…` / `HlsDataSourceProvider::…` del registro, que
  `correr.sh` saca bajo cada caso; en la 6,1 la da `chrome://media-internals`.
- `Network read stopped` / `Network read error` → la carga (red, CORS, nuestros parches de `UrlIndex`/ORB). `No renditions`,
  `Unsupported container`, `Invalid manifest` → el analizador. Si los controles MP4 fallan también, no es HLS: es la
  descodificación o la red de medios en general.

## Control ya hecho (22-11, Linux, Chrome for Testing 153.0.8010.12, sin parches)

Los 12 casos locales reproducen, cruzados incluidos. Falla `ts-variante-cruzado-cors-sin-cabecera`, como se esperaba
(`Network read stopped`). Los dos de Apple no cuentan: ese contenedor no tiene salida a ese servidor.
