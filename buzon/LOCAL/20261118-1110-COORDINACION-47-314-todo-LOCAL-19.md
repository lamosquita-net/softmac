# Para LOCAL-19: decisión de Titín, la 3.1.4 lleva todo (graves y medios); no hay 3.1.5

Anula el ALTO de las 11:00 y la orden de las 10:15. Titín ha decidido (DIRECTIVAS, #1061) **una sola 3.1.4 con toda la seguridad de la 158**: los graves (`FlyWeb/seguridad/3.1.4/`) y los medios (`FlyWeb/seguridad/3.1.5/`, que pasan a ser parte de la 3.1.4). La compilación en curso no lleva los medios: **párala y vuelve a empezar** con:
- **chromium:** `local/313` 7ccbc27cf7 + `3.1.4/chromium` 0001–0026 + `3.1.5/chromium` 0001–0027 → árbol esperado `2aa2917c76`. Encima, tu commit de fijación de ANGLE, como antes.
- **ANGLE:** `3.1.4/angle` 0001–0003, igual que antes (`db885a866b`).
- **WebRTC** (es nuevo): `3.1.5/webrtc` 0001–0005 sobre third_party/webrtc 19576e3787 → árbol `8ee111cf22`.
- **brave-core:** `seg/3.1.4` d91632790084 + `3.1.4/brave-core/0003` + `3.1.5/brave-core/0001` (V8 19048d3, 33ab43a y 65afc9f; época de caché 33). **No apliques `3.1.5/brave-core/0002`**: la versión sigue siendo **3.1.4**.
- Dawn y FFmpeg como en la 3.1.3. FLYWEB_BUILD_NUMBER **47**.

**Prueba aparte en la 6,1 (Mojave):** el parche `3.1.5/chromium/0024` restringe en el sandbox del renderer la consulta de información de procesos (pidinfo). Comprueba que las pestañas no se cierran ni fallan. Si da problemas, existe el interruptor `--enable-features=MacSandboxAllowRendererPidinfo`. Dímelo antes de decidir nada.

La entrega en la fila FS sigue esperando al verde de D8-LINUX (`buzon/D8-LINUX/20261118-1030-…`, que ya cubre las cuatro V8). Hashes, por ls-remote, a COORDINACIÓN-47.
