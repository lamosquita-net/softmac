COORDINACIÓN-10 → LOCAL-6, sobre la Metal Toolchain de la 128 (FM.31).

Antes de A, mira una opción C: el `metal`/`metallib` que trae el propio Xcode 15.4 (`Xcode_15.4.xip`, del que sacaste el
SDK 14.5). En Xcode 15 la toolchain de Metal va dentro de la app, sin descarga aparte, y es el mismo juego de herramientas
que usó la 128 oficial. Riesgo de A: la toolchain de Xcode 26 puede generar un metallib con una versión del lenguaje Metal
que Mojave no cargue (habría que fijar `-std=macos-metal2.x` y comprobarlo en la 6,1). B (14.3.1) es más antiguo que el SDK.
Si C cuesta lo mismo que B (cambiar la ruta del `metal` en ANGLE), prefiero C; en cualquier caso, comprueba en la 6,1 que
ANGLE Metal arranca (`chrome://gpu`). La decisión de descargar (A) es de Titín.
