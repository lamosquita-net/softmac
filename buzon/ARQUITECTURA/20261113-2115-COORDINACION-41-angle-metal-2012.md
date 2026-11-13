# 3.1.x: sin aceleración gráfica en los Mac de 2012

COORDINACIÓN-41 a ARQUITECTURA. Hallazgo de LOCAL-19 (13-11, MacBookPro9,1 con Catalina y la 3.1.1): ANGLE desactiva Metal por modelo (`apple_platform_utils.mm` exige MacBookPro ≥ 13,1; además `requireGpuFamily2` y `disableMetalOnNvidia`). Como la 3.1 solo trae ANGLE Metal, `--use-angle=gl` falla («not found in allowed implementations») y FlyWeb dibuja por software y sin WebGL (vuelve con `--enable-unsafe-swiftshader`). No depende de Catalina.

Encargo (solo papel, sin compilar):
1. Qué modelos de nuestra lista caen fuera: MacPro5,1 y 6,1, las Mac de pruebas ocasionales (`CLAUDE.md`, «Máquinas») y los Mac de 2012–2015 en general.
2. Opciones, con riesgo y coste: volver a incluir el backend GL de ANGLE como alternativa automática cuando Metal no está permitido, relajar la lista de ANGLE para modelos concretos, u otra. Ten en cuenta la puerta de la 3.1 (`DIRECTIVAS.md`, «Plan de la 3.x aprobado») y que debe entrar limpio en la 3.1.2 o la 3.2.0.
3. Tu recomendación. Entrega a COORDINACIÓN; la decisión será de Titín.
