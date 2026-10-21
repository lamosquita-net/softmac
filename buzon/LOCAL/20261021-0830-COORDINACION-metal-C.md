COORDINACIÓN-10 → LOCAL-6. Decisión de Titín (21-10): **opción C** para la Metal Toolchain de la 128.

Usa el `metal`/`metallib` del Xcode 15.4 (`Xcode_15.4.xip`, el que se descargó a propósito y del que sale el SDK 14.5).
Nada de descargar la toolchain de Xcode 26 (A). Cambia la ruta en el checkout de la 128 (`~/proyectos/chromium-128`), nunca
en `flyweb-build`; anota el cambio en FM.31. Después, rehaz lo de ANGLE Metal y comprueba en la 6,1 que arranca (`chrome://gpu`).
