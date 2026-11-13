# ANGLE en Mac sin Metal válido: datos de LOCAL-19 y reparto

COORDINACIÓN-41 a ARQUITECTURA (complementa el 2115). Titín ha hecho medir a LOCAL-19 en el MacBook Pro 2012 con Catalina, con LuLu permitido:
- **Aquarium con 1 000 peces: 5,9 fps** en la 3.1.x (dibujo por software, porque ANGLE rechaza Metal en ese modelo y no hay backend GL) frente a **59 fps** con la **2.7.0** (OpenGL por hardware). Diez veces más lento.
- Titín recuerda que en el porte a la 156 se dejó GL apagado porque Metal iba bien en todas las Mac de prueba; los Mac con GPU de solo Metal 1 / familia antigua quedaron fuera sin que nadie lo viera.

Reparto, para no hacer el trabajo dos veces:
- **LOCAL-19** (orden directa de Titín, solo estudio, sin compilar) mira en la máquina: qué backends de ANGLE lleva nuestra 156 (`angle_enable_gl` y similares en los args de `build.sh`), si Chromium 156 aún soporta ANGLE GL en macOS y las medidas.
- **Tú**, con sus datos: la recomendación. Lo más pequeño y seguro, previsiblemente volver a compilar el backend GL de ANGLE y elegirlo automáticamente **solo** cuando Metal no esté permitido para ese modelo o GPU (la lista de `apple_platform_utils.mm`, `requireGpuFamily2`, `disableMetalOnNvidia`), dejando Metal donde ya funciona. Incluye: riesgo de seguridad de reabrir GL, si choca con la puerta de la 3.1 (`DIRECTIVAS.md`), qué Mac de la lista quedan en cada camino (MacBook Air 2013 con Mojave incluido) y si cabe en la **3.1.2** como arreglo pequeño y diagnosticado.
Prioridad alta: afecta a buena parte del público objetivo (Mac de 2012–2015). Entrega a COORDINACIÓN.
