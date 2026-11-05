# Regla 17 de B1d (GPU por Metal en 10.14): preparación

SEGURIDAD-PORTES-17, 05-11-2026, a petición de COORDINACIÓN-27. **Solo preparación.** Las ramas `flynk-b1d` de LOCAL-18
todavía no están en GitHub (`lamosquita-net/chromium` y `angle` no las tienen). Se revisa el ANGLE de la 156
(`chromium/8078`) en los puntos que tocarán sus commits. Cuando llegue el PR se aplica esta lista. Marcas: [V] verificado
en código o fuente; [I] inferencia.

## 1. Cachés de pipelines (128 → 1024): `mtl_pipeline_cache` y `mtl_library_cache`

- En la 156 [V]:
  - `PipelineCache::kMaxPipelines = 128` y `LibraryCache::kMaxCachedLibraries = 128`, ambos con `kGCLimit = 32`.
  - El recorte lo hace `angle::TrimCache`.
- **Precedente directo: CVE-2026-7901** (crbug 497724490, ANGLE 3bb4e242, 01-04-2026, ya está en la 156) [V].
  - Fue un UAF en `LibraryCache`: con más de `kMaxCachedLibraries` compilaciones a la vez, el recorte borraba entradas
    que otros hilos aún escribían.
  - El arreglo guarda cada `LibraryCacheEntry` en un `shared_ptr`.
- **Qué comprobar en el PR:**
  1. Que solo cambie la constante. No se toca `TrimCache`, ni el `shared_ptr` de 3bb4e242, ni el orden
     buscar → compilar → insertar.
  2. Si LOCAL sube también `kMaxCachedLibraries`: el arreglo no depende del tamaño [I]. Con 1024 el recorte será más
     raro, y por eso las pruebas lo ejercitarán menos. Pido una prueba que llene la caché por encima del límite con
     compilaciones concurrentes (la del propio arreglo, si existe en `angle_end2end_tests`).
  3. Memoria: 1024 `MTLRenderPipelineState` por contexto, multiplicados por los contextos que pueda abrir una web. El
     límite de contextos WebGL de Chrome (16) acota el total, pero conviene medir el pico en la 5,1 (48 GB) y en la Air
     2013 (4/8 GB). No es un fallo de seguridad sino una vía de agotamiento [I].
  4. Que la clave de caché siga incluyendo todo lo que define el pipeline: 41bdaae9 («descriptors hash consistent») y
     059d0829 (ID de programa en la clave) son arreglos recientes de colisiones de clave. Con más entradas, una colisión
     dura más tiempo en caché.

## 2. Elección del `MTLDevice`: `DisplayMtl::getMetalDeviceMatchingAttribute`

- En la 156 [V], el orden es:
  1. `EGL_PLATFORM_ANGLE_DEVICE_ID_*` (`registryID`).
  2. Después `EGL_POWER_PREFERENCE` alto o bajo (GPU discreta o integrada, sin pantalla excluida).
  3. Después `GetPreferredDeviceString()`, que se lee del entorno.
  4. Al final, `MTLCreateSystemDefaultDevice()`.
- Las APIs que usa (`MTLCopyAllDevices`, `removable`, `lowPower`, `registryID`, `isHeadless`) existen en 10.13 o antes.
  No hacen falta guardas [V: documentación de Apple].
- **Qué comprobar en el PR:**
  1. Que una web no elija el dispositivo más allá de `powerPreference` de WebGL, que es lo que ya hace Chrome.
  2. Que el dispositivo elegido sea el mismo que usa el compositor para los IOSurface compartidos. Si no coinciden, hay
     copias entre GPU o fallos de textura (en la MBP 2012 y la A1398, que tienen dos GPU).
  3. Cambio de GPU en caliente (gráficos automáticos) → `MTLDevice` perdido: debe acabar en pérdida de contexto limpia,
     no en el uso de un dispositivo liberado. Probarlo en la MBP 2012 y la A1398 conectando un monitor externo con una
     página WebGL abierta.
  4. Que `GetPreferredDeviceString()` (variable de entorno) no se pueda fijar desde la web ni por política [I: solo
     entorno del proceso].

## 3. Guardas de débiles en 10.14 (src `5660e8931d..87f4e8b263`, 8 commits)

- **Qué comprobar en cada guarda:** qué hace cuando la API no está.
  - **Aceptable:** el `else` desactiva la función o pierde el contexto.
  - **No aceptable:** el `else` se salta una validación, una limpieza o una inicialización de memoria. Por ejemplo, borrar
    una textura con una API de 10.15 y, en 10.14, no borrarla.
- La clase «Uninitialized resource/use» es justo la de tres de los CVE de abajo (17667, 91720 y parte de 79142).

## 4. Graphite, WebGPU y Dawn apagados en 10.14

- Reducen superficie: quitan los CVE de Dawn y Graphite de la 151–156.
- **Qué comprobar:** que el apagado sea de compilación o de lista de bloqueo de GPU, y no solo de una *feature* que se
  pueda encender con `chrome://flags`, `--enable-unsafe-webgpu` o una política.
  - Si se puede encender, que solo sea con un parámetro explícito en el arranque.

## 5. CVE de ANGLE Metal de la 151–156 (ya en la 156; que el PR no los deshaga)

Son 10 altos y ningún crítico (de `gl-150-156-seg.md`, categoría C). Commits de ANGLE:

| CVE | Hito | Sev. | Descripción | Commits ANGLE |
|---|---|---|---|---|
| CVE-2026-17667 | 151 | Alto | Uninitialized Use in ANGLE | b7f8900a94 e2cafaae76 89a2a20add 0d5df40d4a a1f1461fe0 6c4783073b 5242f8c415 |
| CVE-2026-17678 | 151 | Alto | Out of bounds read in ANGLE | 9464aca650 |
| CVE-2026-17701 | 151 | Alto | Out of bounds read in ANGLE | bf459445a7 |
| CVE-2026-76046 | 151 | Alto | Buffer overflow in ANGLE | 0cec00c68e 8bbfb03f8f |
| CVE-2026-79131 | 152 | Alto | Out of bounds write in ANGLE | bfbd2ccf3e |
| CVE-2026-79142 | 152 | Alto | Buffer overflow in ANGLE | f1cc6b2e2f 99ee9910c6 922804e751 3a674cbcae 0bdeec3fc0 d6247827bf |
| CVE-2026-87596 | 153 | Alto | Out of bounds read in ANGLE | c553dab3a7 |
| CVE-2026-91720 | 153 | Alto | Uninitialized resource in ANGLE | 3126733e09 9ebe6aecc5 |
| CVE-2026-118322 | 156 | Alto | Memory corruption in ANGLE | 64b22df8fc |
| CVE-2026-118329 | 156 | Alto | Improper input validation in ANGLE | 974b79ad14 |

**Comprobación mecánica:** cruzar los ficheros de `6f8cb67` y `2f34372` con los de estos commits. Si coinciden, leer el
bloque y asegurarse de que el arreglo sigue ahí.

## 6. Después de B1d

La base fija 156 deja de recibir arreglos de ANGLE Metal posteriores a la rama `chromium/8078`. Se necesitan dos cosas:
1. **Que LOCAL parta del último 156 estable**, no del `.0`.
2. **Que los CVE de ANGLE Metal de la 157+ entren en los *backports* mensuales de B8.** Por tamaño, es el bloque de GPU
   más pequeño: 10 en seis hitos.
