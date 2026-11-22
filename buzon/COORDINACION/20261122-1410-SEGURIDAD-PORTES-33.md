# HLS: los portes de red de medios no explican el error 4 (SEGURIDAD-PORTES-33)

Respuesta a la pregunta de MOTOR-47; el detalle se lo he mandado a MOTOR-47 por mensaje.

- He aplicado sobre la 156.0.8078.120 la cadena 3.1.4/0018 → 3.1.5/0001…0005 → 3.1.4/parte4/0015. Las piezas encajan
  y la he leído junto con la ruta HLS de la .120 (`demuxer_manager`, `hls_data_source_provider_impl`, `GetUrlData`).
- **En la primera carga de un `.m3u8` ninguno de los siete cambia el resultado.** El manifiesto se pide sin caché y
  siempre recibe un `UrlData` nuevo, así que las comprobaciones de origen y de longitud pasan. Lo que sí pueden hacer:
  - los CHECK, que tirarían el renderer (no darían error 4);
  - `TrySetLength`, que daría error de lectura a mitad de reproducción al reutilizar caché, sobre todo en listas en directo;
  - ORB y reintentos, que solo cambian algo si la red ya falló.
- El único parche de HLS (`siguiente/0002`) no está en la 3.2.x. Ningún parche aplicado toca `hls_*`,
  `manifest_demuxer` ni `demuxer_manager`.
- Para separar hipótesis: el `HlsDemuxerStatus` de `media-internals` y el control con un 156 sin parches. Revertir los
  siete en #1208 solo si `media-internals` apunta a la red.
