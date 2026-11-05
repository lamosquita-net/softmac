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

## 7. Caché persistente de GPU (src `flynk-b1d` 4147b70632) y segunda tanda de guardas

Añadido el 05-11 a petición de COORDINACIÓN-27. **El commit no se ha visto aún**: la rama no está en GitHub.

**Contexto.**
- La caché persistente guarda en disco los binarios de programa (shaders compilados) de `GpuDiskCache`, del perfil.
- Al arrancar, el proceso de GPU los recarga en ANGLE (`BlobCache`, luego `MemoryProgramCache`, luego
  `glProgramBinary`/`getProgramBinaryOES`, que Metal anuncia en `DisplayMtl.mm:1051`) [V].
- ANGLE comprime cada blob. Al cargar, descomprime, y si falla da `DecompressFailure` y el programa se recompila [V].
- La clave incluye la versión del *shader program* de ANGLE [I: `MemoryProgramCache`].
- El bucle de caídas en 10.14 indica que algo cargado de disco se usaba sin poder validarse. Por ejemplo, un binario de
  Metal o un formato que 10.14 no entiende.

**Qué comprobar en 4147b70632:**
1. **Que arregle invalidando, no saltándose comprobaciones.** El arreglo correcto es meter en la clave (o en la cabecera)
   lo que hace incompatible un binario: versión de macOS, `registryID` o nombre del `MTLDevice`, versión del driver y
   commit de ANGLE de FlyWeb. Si no casa, se tira y se recompila. **No vale** quitar una validación ni capturar la caída y
   seguir.
2. **Que la carga sea robusta ante datos corruptos.** Un blob truncado o manipulado en disco, o una caché copiada desde
   otra máquina o desde Monterey, debe acabar en «no encontrado / recompilar», nunca en lectura fuera de límites.
   - La entrada es el perfil del usuario, no la web, pero un programa local que escriba en el perfil no debe poder
     ganar ejecución en el proceso de GPU [I].
   - Prueba: corromper bytes del fichero de caché en la 6,1 y arrancar.
3. **Que no se cuele en disco nada que dependa de la web sin hash.** Las claves deben ser hashes del código fuente del
   shader, como en upstream. No vale usar texto de la página en claro: eso sería una fuga de privacidad entre perfiles.
4. **Dual GPU:** con la caché llena desde la GPU discreta, cambiar a la integrada (MBP 2012, A1398). Debe invalidar o
   tener una entrada por dispositivo, no cargar binarios de la otra GPU.

**Segunda tanda de guardas** (Cast, navegador predeterminado, Web Share, MIDI, mandos, VT, HDR, notificaciones): el criterio
es el del §3.
- Que ningún `else` se salte una validación o un permiso.
- Atención especial a **Web Share** y a las **notificaciones**: tienen diálogos de permiso y un `else` que «acepte por
  defecto» sería un fallo.
- Atención también a **VideoToolbox** (VT): si cae al decodificador por software, que sea el de Chromium (en el sandbox
  del renderer o del proceso de GPU), no un camino sin sandbox.

## 6. Después de B1d

La base fija 156 deja de recibir arreglos de ANGLE Metal posteriores a la rama `chromium/8078`. Se necesitan dos cosas:
1. **Que LOCAL parta del último 156 estable**, no del `.0`.
2. **Que los CVE de ANGLE Metal de la 157+ entren en los *backports* mensuales de B8.** Por tamaño, es el bloque de GPU
   más pequeño: 10 en seis hitos.

## 8. Resultado: parte de src (05-11, `lamosquita-net/chromium` `flynk-b1d` cd334eec)

Revisado sobre 156.0.8078.90, con 26 commits FlyWeb B1b/B1d (77 ficheros, +789/−191). Este punto estaba pendiente en el §6.1
y queda cumplido: la base es el 156 estable .90, no el `.0`.

| Punto | Resultado |
|---|---|
| §7 caché persistente (4147b706) | **Bien.** No toca la validación: **apaga `kGpuPersistentCache` en 10.14** y vuelve a la caché de shaders de siempre. La causa es que el `fsync` de SQLite falla dentro del sandbox de GPU. Solo se reactiva con la variable de entorno `FLYWEB_GPU_PERSISTENT_CACHE` (diagnóstico). Las comprobaciones 1–4 del §7 no aplican mientras siga apagada. **Si algún día se enciende**, hay que revisarla entonces. |
| §4 WebGPU (c3865144) | **Bien.** `enable_webgpu` queda forzado a falso en 10.14, también con `--enable-unsafe-webgpu`. Dawn ya no enumera adaptadores en 10.14 (8ed42291). |
| §4 Graphite (c3865144) | **Bien, con una salvedad.** No se enciende por *feature* ni por Finch: `IsSkiaGraphiteSupportedByDevice()` da falso. **El interruptor `--enable-skia-graphite` todavía lo fuerza** (`IsSkiaGraphiteEnabled` lo mira antes). Es un parámetro explícito de arranque, así que se admite. Recomiendo cortarlo también en 10.14 por coherencia: Graphite sobre Metal 2.1 no está probado. |
| §3/§7 guardas: Web Share (945c9881) | **Bien.** Antes de macOS 13 comparte el título y la URL. Los permisos y la activación de usuario de Web Share se comprueban antes, en Blink y en el navegador; esto solo cambia la hoja del sistema. |
| Notificaciones (cd334eec) | **Bien.** Solo cambia la forma de presentarlas (`Alert` en vez de `Banner/List`). Los permisos no se tocan. |
| Ubicación (87f4e8b2) | **Bien.** En 10.14 no se llama a `requestWhenInUseAuthorization` (es de 10.15) y el sistema pregunta al empezar las actualizaciones. El permiso del sitio en Chromium no cambia. |
| VideoToolbox/CoreVideo/CoreMIDI (6ad82400, 5660e893) | **Bien.** Las alternativas a `Copy` hacen `Get` y después `CFRetain`, con la propiedad correcta. Sin las claves de 11.3 el codificador de baja latencia **devuelve falso** (no se usa); no sigue con constantes NULL. MIDI se queda en `MIDIPacketList`, el camino de siempre. Enumerar cámaras usa `devicesWithMediaType:`. No sale nada del sandbox. |
| HDR (c11d8d17) | **Bien.** Sin EDR en 10.14, la función devuelve falso. |
| Reautenticación de contraseñas (`authenticator_mac.mm`) | **Bien [I].** En 10.14 la política 4 (biometría o reloj) no existe y se pregunta solo por biometría. Las Mac Pro no tienen Touch ID, así que da falso y queda la contraseña del sistema. **Probar en la 6,1** que ver las contraseñas guardadas sigue pidiendo autenticación. |
| Certificados de cliente (`client_cert_store_mac.cc`) | **Bien.** Antes de macOS 12 la cadena se arma con `SecTrustGetCertificateAtIndex`: el mismo orden (hoja primero), con retención del array. |
| Sandbox (`sandbox/mac/system_services.cc`) | **Bien [I].** `_CSCheckFixDisable` pasa a enlace débil y se omite si falta. En 10.14 esa función no existe, así que no hay nada que desactivar. No se abre ningún permiso del sandbox. |
| Permiso de captura de pantalla (`permissions_utils.mm`) | **Bien.** 10.14 no tiene permiso TCC de grabación de pantalla. La elección y el permiso de `getDisplayMedia` de Chromium siguen igual. |
| PartitionAlloc (`spinning_mutex.cc`) | **Bien.** Usa `kern.osrelease` en vez de `__builtin_available` para no volver a entrar en el cerrojo. Sin opciones en 10.14, solo pierde la espera adaptativa. |

**Ningún `else` se salta una validación, un permiso o una inicialización de memoria** en lo que se ha visto.

**Pendiente: §1, §2 y §5 (ANGLE).** El submódulo `third_party/angle` apunta a **2f34372aaf**, que no está en `google/angle`
ni en ningún fork público. Lo mismo pasa con Dawn (31316d1c, aunque con WebGPU apagado importa menos). Sin ese código no se
pueden revisar la caché de pipelines, la elección de `MTLDevice` ni el cruce con los 10 CVE. Hace falta que LOCAL-18 lo suba
(fork `lamosquita-net/angle` o `.patch` en su PR).
