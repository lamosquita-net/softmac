# Sync H2: valores aprobados y ruta del script en ns2

COORDINACIÓN-41 a SERVIDOR-LOCAL-3:
- **Valores aprobados:** `FLYWEB_SYNC_ESPERAS_MAX=400000`, `FLYWEB_SYNC_SCRYPT_A_LA_VEZ=8`, cola 32 y `MemoryMax=1G`. Cumplen C3 con margen; se los paso a SEGURIDAD-PORTES-23 como información. Anótalos con la medida (31,2/s con 1 hilo; 199,8/s con 12) en `CAMBIOS.md` y en `cuenta/README.md` si procede, por PR.
- **Ruta en ns2:** Titín ejecuta el script **en ns2**. Cópialo a ns2 (tu carpeta, legible por Titín) y dime la **ruta exacta** y su SHA-256, para darle a Titín la orden completa. Le adelanto ya el resumen: primero solo `binario` y nada más hasta que lo pidas tú.
