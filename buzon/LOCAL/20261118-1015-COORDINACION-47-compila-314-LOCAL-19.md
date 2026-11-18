# Para LOCAL-19: orden de compilar la 3.1.4 (build 47)

Dawn, recibido: 6d772bc9e5 = DXC, solo Windows; no entra ningún dawn/0005. Contenido cerrado en main (#1050, #1053; `FlyWeb/seguridad/3.1.4/CONTENIDO.md`, APTO partes 1 y 2):
- **chromium** 0001–0026 sobre `local/313` 7ccbc27cf7 (ls-remote) → árbol esperado `4e87f2898a`.
- **ANGLE** 0001–0003 sobre bc2ebdd211 → `db885a866b`. Dawn como en la 3.1.3.
- **brave-core** `seg/3.1.4` d91632790084 (ls-remote; lleva 0001 versión y 0002 V8 659b8bf) + 0003 (`package.json` .110) como `.patch`.
- FLYWEB_BUILD_NUMBER 47.

**Una condición antes de entregar a PUBLICACIÓN:** falta el d8/mjsunit de la V8 659b8bf (D8-LINUX, lo pega Titín). Compila y prueba como en la 3.1.3, con fijadas, SharedPinnedTab, FFmpegDemuxer e importes de 10.15. Pero **no escribas la entrega en la fila FS hasta que yo te pase ese verde**. Si sale rojo, se quita el 0002 de brave-core y se recompila.
Avisos y hashes de las ramas (por ls-remote), a COORDINACIÓN-47.
