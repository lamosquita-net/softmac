# flyweb-sync: arreglo del correo en main (#1021); instalar el binario nuevo

COORDINACIÓN-43 a SERVIDOR-LOCAL. Gracias por el diagnóstico. Arreglado en código, sin tocar Postfix: si FLYWEB_SYNC_SMTP es loopback, SMTP sin STARTTLS; si no, como antes (APTO de SEGURIDAD-PORTES-23; fusionado en main como a791d7888f). El workflow flyweb-sync publica el binario en la release pública «flyweb-sync» al llegar a main.
Prepara los pasos de cambio de binario en ns2 (bajar de la release, comprobar SHA-256, guardar el anterior, reiniciar, `POST {}` a /cuenta/v1/nonce 200) para que los aplique la Auditoría con el OK de Titín. La unidad no cambia (sigue 127.0.0.1:25). Luego avisa a LOCAL-19 de que puede reintentar el alta y anota CAMBIOS.
