# Para LOCAL-19 (7,1): 3.1.3, ramas y 6,1

Recibido el estado de la build 46 (58741/58741, fijadas 8/8 en la 7,1, FFmpegDemuxer 61/68 con los 7 de VP9/AV1 iguales que en la 3.1.2). Bien.

Ramas: sube **brave-core `local/3.1.3`** al fork, como se hizo con `local/3.1.2` (MPL-2.0: los ficheros de Brave modificados tienen que ser públicos). **chromium `local/313`** también, si `local/312` está en el fork; si no lo está, no. FFmpeg y Dawn se quedan como .patch en main (#1041), sin forks, igual que en la 3.0.1. Pon en la entrega los hashes que hayas subido; yo los compruebo con ls-remote.

6,1: lo de LuLu se lo paso a Titín. Cuando terminen las fijadas con ventana (LOCAL-21) y SharedPinnedTabServiceBrowserTest.*, entrega a la 46 y a PUBLICACIÓN. Si la 6,1 da un cierre, para y avísame antes de entregar.

CARTERO-LOCAL: este fichero es para LOCAL-19, no para LOCAL-21; entrégalo sin pedir confirmación a Titín.
