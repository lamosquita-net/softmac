# Pruebas de HLS en `<video>`

Separan las hipótesis del fallo de HLS (error 4 con readyState 0 en 3.2.0 y 3.2.1). Todo va por 127.0.0.1 y,
salvo los cuatro casos de Apple, no sale a Internet.

| Fichero | Qué hace |
|---|---|
| `generar.sh [carpeta]` | Con ffmpeg (libx264 o VideoToolbox) genera un MP4 H.264 Main 3.0 + AAC-LC de 12 s (`control.mp4`) y, a partir de él, HLS en TS y en fMP4: `variante.m3u8`, `maestra.m3u8` (con `CODECS`), `maestra-sin-codecs.m3u8` y `maestra-sin-extension` (para forzar la vía de respaldo `DEMUXER_ERROR_DETECTED_HLS`). |
| `servir.py [carpeta]` | Abre dos orígenes: 127.0.0.1:8471 (la página) y :8472 (el cruzado). `/medios/…` va sin CORS y `/cors/medios/…` con `Access-Control-Allow-Origin: *`. Admite rangos. Guarda los resultados en `resultados.jsonl`. |
| `prueba.html` | Página con 17 casos: control MP4, TS/fMP4 × variante/maestra, mismo origen o cruzado con y sin CORS, y bipbop de Apple sin y con `crossorigin`. Anota `error.code` **y `error.message`**, que lleva el estado del reproductor (`DEMUXER_ERROR_…`, `kNetworkReadError…`). |
| `correr.sh <binario> <etiqueta> [carpeta]` | Lanza cada caso en un navegador nuevo con `--headless=new`, sin ventana, con un perfil nuevo que se queda en `salida/<etiqueta>/perfiles/` (no se borra nada) y `--use-mock-keychain`; sin actualizador ni componentes, y con lamosquita.net cortado, para que los arranques seguidos no lleguen a ns2. Guarda el registro VLOG del demuxer HLS y de la red de medios. Sale en `salida/<etiqueta>/`. |

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

## Corrida en la 7,1 (LOCAL-23, 22-11): FlyWeb 3.2.1 = Chrome for Testing 156.0.8078.80

Los dos dan lo mismo en los 15 casos de entonces. Los de Apple fallan **también sin parches**:
- `bipbop_4x3` (TS): `CHUNK_DEMUXER_ERROR_APPEND_FAILED` al analizar un segmento.
- `adv_example_fmp4`: `Range requests are not allowed for cross-origin content`. Usa `EXT-X-BYTERANGE` y la página es de
  otro origen: Chromium lo rechaza a propósito si no hay CORS. De ahí los dos casos `-cors`.

**Corrección (LOCAL-23, 22-11):** `bipbop_4x3` es **intermitente** en Chrome 156 sin parches. En http pasó 1 de 8 veces, y
desde `about:blank`, 4 de 8. Los casos `-cors` de Apple dan error 4, rs 0, también en Chrome (`Network read stopped`). Por eso
`correr.sh` corre cada caso `apple-*` **8 veces** (`PASADAS_APPLE`) y al final da el recuento «reproduce/pasadas». Esos
casos se comparan por recuento entre navegadores; **no son puerta de entrega**. La puerta es `control-mp4-mismo` y los
casos locales, que son deterministas: una pasada.

## Corrida en la 6,1 (LOCAL-23, 22-11, Mojave, FlyWeb 3.2.1 con ventana)

Los controles MP4 y los 10 HLS locales reproducen y cruzan de segmento, con `VideoToolboxVideoDecoder`. Los casos de Apple
fallan igual que en Chrome for Testing 156 sin parches: bipbop_4x3 de forma intermitente, y los cruzados con rangos o sin
CORS siempre. **No hay regresión propia reproducible.**
