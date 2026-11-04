# ¿Se puede llevar el backend Metal de ANGLE de la 156 a Metal 2.1 de macOS 10.14?

INVESTIGACIÓN-MOTOR-8, 04-11-2026, encargo de COORDINACIÓN-26 (Titín, FM.55). **Solo papel**: nada compilado ni ejecutado. Marcas: **[V]** verificado en código o cabeceras citadas; **[I]** inferencia mía; **[N]** no comprobado.
No toca B1c (porte de OpenGL de LOCAL-17).

## 1. Conclusión (críticas incluidas)

1. **ANGLE Metal a 10.14: viable en papel y pequeño.** Todo lo que ANGLE usa por encima de 10.14 se concentra en **6 ficheros y ~15 puntos** [V, §3]; las ~35 decisiones por familia de GPU pasan por **dos funciones** (`SupportsAppleGPUFamily`, `SupportsMacGPUFamily`, `mtl_utils.mm:1389–1440`) y ANGLE ya tiene la maquinaria para degradar (flags `hasTextureSwizzle`, `allowRenderpassWithoutAttachment`, etc.) [V]. No hay API de 10.15+ sin equivalente: cada una tiene alternativa, se desactiva con un flag existente o es de depuración (§4).
2. **El camino de Chrome 156 en Mac no es solo ANGLE:** `kSkiaGraphite` está **encendido por defecto en Apple** (`gpu/config/gpu_finch_features.cc:383–389` de 156.0.8078.90) [V], y Graphite usa el Metal **propio de Skia** (no ANGLE), más Dawn para WebGPU. Con la «Graphite apagada» de B1 el camino es Ganesh-GL sobre **ANGLE-Metal** (el que se analiza aquí); **Graphite exigiría 3 ficheros más** de Skia y una duda abierta (MSL, §3.2) y **Dawn Metal 12 ficheros** (§3.3): la salida barata es **apagar WebGPU en Mojave**.
3. **Lo que el papel no resuelve:** (a) qué familia da cada GPU en 10.14 (Apple ya no publica las tablas de Intel/AMD: §5), (b) si el Metal 2.1 de Mojave, con sus drivers, compila y rinde el MSL que genera ANGLE en las Mac Pro 5,1/6,1 y las integradas de Intel, (c) las llamadas a Metal **fuera** de ANGLE (en `gpu/`, `ui/gl`, `components/viz`, `ui/gfx/mac` de Chromium: sin buscador de código en esta sesión) [N].
4. **Recomendación: viable solo para ANGLE sin Graphite, con prueba empírica antes de decidir.** Coste de la prueba: la sonda de §5 en cada Mac (minutos, sin compilar ANGLE) y un parche de ~6 ficheros que LOCAL compile contra el árbol de B1. Comparado con el porte de OpenGL de la 150 (~10 ficheros, según COORDINACIÓN): **menos ficheros, y sobre el único backend que Chrome mantiene en Mac** [V: ANGLE solo admite Metal en la 156, LOCAL-16], con lo que cada rebase trae conflictos pequeños y localizados en vez de mantener un backend que Chrome ya no ejecuta. No es un argumento definitivo: un backend Metal que nadie prueba en Mojave puede dar errores de render que un OpenGL maduro no daría [I].

## 2. Fuentes y método

- **Chromium 156.0.8078.90** (`DEPS`): `angle_revision` a66226b1d3c0, `skia_revision` 835d560ccd6c, `dawn_revision` 8ce9806ee580. ANGLE y Skia se leyeron **en esas revisiones** (espejos `google/angle`, `google/skia`) [V]. **Dawn: la revisión fijada no se pudo bajar** (el espejo no la sirve por hash); se leyó `main` del 04-11 (b7b7381d8) → **[I]: puede diferir de la 156**.
- **SDK de macOS 10.14, 10.15 y 11.3** (cabeceras de `Metal.framework`, del repositorio `phracker/MacOSX-SDKs`). Método: los identificadores que aparecen en la cabecera 10.15 y no en la 10.14 son API de 10.15; los de la 11.3 y no en la 10.15, de 11.x. Se buscaron esos identificadores en el código [V]. **Límite:** las APIs de macOS 12–15 **no** salen de esta comparación (no hay SDK 12+ en ese repositorio); se buscaron aparte por su nombre y por guardas `@available` (§3.1, última tabla) [I].
- **Metal Feature Set Tables de Apple (PDF de 23-10-2026):** **solo trae familias Apple1–Apple11** (Apple silicon); las familias de Mac de Intel/AMD (Mac1/Mac2, `macOS_GPUFamily1/2`) **ya no figuran** [V: texto del PDF]. No hay fuente oficial a mano para qué GPU de Intel/AMD/NVIDIA cae en cada familia.
- Ejecutado: `-Wunguarded-availability` **no** se ha ejecutado; **la lista de avisos de B1 (LOCAL-16) es la comprobación independiente** de este inventario y conviene cruzarla.

## 3. Inventario de lo que usa el camino de Chrome por encima de 10.14

### 3.1 ANGLE Metal (`third_party/angle/src/libANGLE/renderer/metal`: 83 ficheros de código; 106 con shaders y tablas)

Solo hay **dos guardas de versión** en todo el directorio: `@available(macCatalyst 16.4, iOS 16.4, *)` en `DisplayMtl.mm:1388` y la de macOS 15 de `mathMode` en `mtl_utils.mm:~915` [V]. En Chromium la versión mínima es muy superior a 10.14, así que **ANGLE llama sin guarda** a casi todo; en 10.14 cada llamada a un selector inexistente **aborta** (`unrecognized selector`), que es lo que ve LOCAL-16.

| # | API | Mín. | Fichero:línea | ¿Guarda? | Alternativa en 10.14 |
|---|---|---|---|---|---|
| 1 | `supportsFamily:` + `MTLGPUFamilyMac1/Mac2/MacCatalyst1-2/Apple1–7` | 10.15 (Apple6/7: 11) | `mtl_utils.mm:1389–1440` (único sitio; **todo el resto lo llama a través de él**: `DisplayMtl.mm` ~35 puntos, `mtl_format_table_autogen.mm` ~150, `mtl_resources.mm:436`) | No | `supportsFeatureSet:` (10.14 tiene `macOS_GPUFamily1_v1…v4` y `macOS_GPUFamily2_v1` [V: SDK 10.14]). Mac1 → `GPUFamily1_v1`; Mac2 → `GPUFamily2_v1` [I: equivalencia por nombre]; todas las Apple → falso |
| 2 | `supportsBCTextureCompression` | 11 | `DisplayMtl.mm:1386–1390`; llamado sin cortocircuito en ~17 puntos del `mtl_format_table_autogen.mm` | La guarda es de Catalyst/iOS: **en macOS pasa y llama** | En Mac devolver **verdadero** (BC es nativo en las GPU de Mac) [I] |
| 3 | `supports32BitFloatFiltering` | 11 | `DisplayMtl.mm:1377`; la tabla de formatos lo llama detrás de `supportsMacGPUFamily(1) \|\|` (en Mac se corta antes) | No | En Mac, verdadero [I]; basta tocar el envoltorio |
| 4 | `supportsPullModelInterpolation` | 11 | `DisplayMtl.mm:1022` | No | Falso (apaga `GL_OES_shader_multisample_interpolation`) [I: no sé si las GPU Mac lo darían] |
| 5 | `preserveInvariance` | 11 | `mtl_utils.mm:910` (**en cada compilación de shader**) | No | Omitir en 10.14 (`respondsToSelector:`); riesgo: shaders con `invariant` pierden la garantía [I] |
| 6 | `hasUnifiedMemory` | 10.15 | `mtl_context_device.mm:135–137`, `mtl_resources.mm:1087` | No | `isLowPower` (10.11) como proxy de GPU integrada [I] |
| 7 | `MTLRenderPassDescriptor.renderTargetWidth/Height`, `defaultRasterSampleCount` | 10.15 | `mtl_state_cache.mm:632–639` (**la rama `else` los asigna siempre**), `mtl_command_buffer.mm:1565` (lectura en `ASSERT`) | No | Omitir (pasadas sin adjuntos: ya hay flag `allowRenderpassWithoutAttachment`, `DisplayMtl.mm:1292`, que debe quedar apagado en 10.14) |
| 8 | `MTLTextureSwizzleChannels` y vistas con *swizzle* | 10.15 | `TextureMtl.mm:867,2008`, `mtl_resources.h:276,414`, `mtl_resources.mm:558,782`, `mtl_utils.mm:1239–1254` | **Sí, por flag**: `hasTextureSwizzle` (`DisplayMtl.mm:1238`; `TextureMtl.mm:2004`) | Forzar `hasTextureSwizzle = false` en 10.14: ANGLE ya emula el *swizzle* (`OverrideSwizzleValue`, `format.swizzled`) [V] |
| 9 | `MTLCaptureDescriptor`, `startCaptureWithDescriptor:` | 10.15 | `mtl_utils.mm:191–210` | Solo se usa al capturar | Dejar (depuración); si compila en 10.14 con `@available` |
| 10 | `MTLLanguageVersion2_2/2_3/2_4` | 10.15/11/12 | `mtl_utils.mm:874–878` | Solo con las variables de entorno `ANGLE_MSL_VERSION_*` | Nada; el valor por defecto sale del SO (`options.languageVersion = GetUserSetOrHighestMSLVersion(options.languageVersion)`, `:945`) = **MSL 2.1 en Mojave** [V] |
| 11 | `mathMode`, `mathFloatingPointFunctions` | 15 | `mtl_utils.mm:915–925` | **Sí** (`@available(macOS 15.0…)`; si no, `fastMathEnabled`) | Nada |
| 12 | `MTLPixelFormatASTC_*_HDR` y formatos de 16 bits empaquetados | 11 | `mtl_format_table_autogen.mm` (`#if … __MAC_OS_X_VERSION_MAX_ALLOWED >= 110000`) | Compilación y, en ejecución, solo bajo `supportsAppleGPUFamily(…)` (falso en Mac) | Nada |

**Shaders internos de ANGLE:** solo usan `__METAL_VERSION__ >= 210` (salida de *stencil*, `blit.metal:331`) [V]; no se encontró uso de atributos MSL ≥ 2.2 (barycentric, etc.) en `shaders/` ni en el traductor MSL (`compiler/translator/msl`) con las búsquedas hechas [I: no leído entero].
**Sincronización:** `MTLSharedEvent` es de 10.14 [V: comentario en `SyncMtl.mm:53`] y no hace falta cambiar.
**Resumen:** **6 ficheros** (`mtl_utils.mm`, `DisplayMtl.mm`, `mtl_context_device.{h,mm}`, `mtl_resources.mm`, `mtl_state_cache.mm`, `mtl_command_buffer.mm`) y unos **15 puntos**; 80 usos de identificadores nuevos en 12 ficheros, de los cuales casi todos están detrás de los envoltorios #1–#3 o de un flag.
**Lo que no sale de esta comparación [N]:** selectores de macOS 12–15 llamados sin guarda (no hay SDK 12+); la lista de avisos de B1 los cubre.

### 3.2 Skia Graphite (Metal propio de Skia; **encendido por defecto en Apple** en 156 [V])

| API | Mín. | Fichero:línea | ¿Guarda? | Efecto en 10.14 |
|---|---|---|---|---|
| Bucle de `supportsFamily:` (Apple9…Mac2) y **`SK_ABORT` si ninguna familia casa** | 10.15 | `graphite/mtl/MtlCaps.mm:40–66` | No | Aborta (Mojave) y en cualquier Mac que no sea Mac2 |
| `MTLLanguageVersion2_2` / `2_3` | 10.15 / 11 | `MtlGraphiteUtils.mm:70–76` | `@available(macOS 11)`: 2.3; si no, **2.2** | **2.2 no existe en 10.14**: la compilación de shaders falla. Habría que usar 2.1, y Skia declara que necesita 2.3 para *framebuffer fetch* [V: comentario] → [N] si el SkSL funciona en 2.1 |
| `commandBufferWithDescriptor:` | 11 | `MtlCommandBuffer.mm:72–80` | **Sí** (`@available(macOS 11…)` con respaldo `commandBufferWithUnretainedReferences`) | Nada |
| `startCaptureWithDescriptor:` | 10.15 | `MtlQueueManager.mm:72–76` | Depuración | Nada |

**3 ficheros** (`MtlCaps.{h,mm}`, `MtlGraphiteUtils.mm`, `MtlQueueManager.mm`). El problema no es el volumen sino la duda del MSL y que en Mac1-only el `SK_ABORT` mata todo.

### 3.3 Dawn Metal (WebGPU; **snapshot `main`, [I]**)

53 ficheros en `dawn/src/dawn/native/metal`, **12 con API de 10.15+/11**: `supportsFamily` (32 usos), muestreo de contadores (`MTLCounterSampleBuffer`, `sampleCountersInBuffer`; 10.15), `MTLTextureSwizzleChannels`, `MTLComputePassDescriptor`/`MTLBlitPassDescriptor` (11), `supportsCounterSampling`, `preserveInvariance` (`ShaderModuleMTL.mm:519`). Hay 23 líneas con guardas de versión, pero el diseño asume 10.15+/11. **No se recomienda portarlo: apagar WebGPU en Mojave** (decisión de motor, no de Metal).

## 4. Para cada API sin alternativa directa

Ninguna del §3.1 es «imposible»: #1–#8 tienen equivalente, valor fijo o flag de degradación; #9–#12 no afectan. Lo que **no** tiene equivalente es **funcional, no de API**: en 10.14 faltan *swizzle* de texturas, pasadas sin adjuntos y MSL > 2.1; ANGLE los **emula o desactiva** (§3.1). Pérdidas esperables [I]: peor rendimiento del *swizzle* emulado y de las pasadas sin adjuntos (WebGL/GLES 3.1 *framebuffer no attachments*), y que las GPU sin `GPUFamily2_v1` pierdan `hasDepthAutoResolve`, `hasStencilAutoResolve` y `allowRenderpassWithoutAttachment` (`DisplayMtl.mm:1222–1223,1292`).

## 5. Familias y feature sets: lo que exige ANGLE y lo que da 10.14

**Lo que exige ANGLE (en Mac) [V]:**
- **Mac1** (`supportsMacGPUFamily(1)`): GL ES máximo (`DisplayMtl.mm:434`, resto de familias en `supportsEitherGPUFamily(4, 1)`), MRT completos (`:763`), bits de color por pasada (`:784`), MSAA/resolve de los formatos de 32 bits (`mtl_format_table_autogen.mm:3915…`). **Es el mínimo real.**
- **Mac2** (`supportsMacGPUFamily(2)`): `hasDepthAutoResolve`, `hasStencilAutoResolve`, `hasTextureSwizzle`, `allowRenderpassWithoutAttachment` (`DisplayMtl.mm:1222–1292`). **Opcional**: sin Mac2, ANGLE degrada.
- `requireGpuFamily2` (flag, apagado por defecto [I]) haría fallar el arranque sin Mac1/Mac2 (`DisplayMtl.mm:141`).
- Las familias Apple1–7 no existen en Mac: devuelven falso.

**Lo que da 10.14 [V: SDK 10.14]:** `MTLFeatureSet_macOS_GPUFamily1_v1…v4` (10.11–10.14), `MTLFeatureSet_macOS_GPUFamily2_v1` (**10.14**) y `ReadWriteTextureTier2` (10.12). `supportsFamily:` no existe.

**Qué GPU cae dónde: [N].** No hay tabla oficial vigente para Intel/AMD/NVIDIA (ver §2). Datos sueltos: la 6,1 usa Metal en Monterey y pasa el bucle de Skia, es decir, **dice Mac2** allí (COORDINACIÓN, de LOCAL-16) [V de segunda mano]; las demás (FirePro D500/D700, Intel HD 4000/5000, GT 650M, la GPU de la 5,1) **no tienen dato**. **No lo deduzco de memoria.**
**Cómo cerrarlo (sin compilar ANGLE):** `FlyWeb/tools/metal-sonda/sonda.m` (nuevo, **escrito sin compilar ni probar**): imprime, por GPU, `supportsFeatureSet` de los seis feature sets, `supportsFamily` (si existe), los selectores de 10.15/11 que ANGLE llama sin guarda (con `respondsToSelector:`), MSL 2.0/2.1/2.2/2.3 que **compila de verdad**, muestras MSAA, `argumentBuffersSupport` y `readWriteTextureSupport`. Un volcado por Mac y macOS: 5,1 y 6,1 en Mojave (y la 6,1 en Monterey como control), MBA 2013 (Mojave), Mac mini 2012 y MBP 2012 (Catalina, dos GPU), A1398 (Monterey).

## 6. Ficheros y riesgos frente al porte de OpenGL (B1c, ~10 ficheros)

| | ANGLE-Metal a 10.14 | Graphite a 10.14 | Dawn (WebGPU) | B1c (OpenGL de la 150) |
|---|---|---|---|---|
| Ficheros | **6** (ANGLE) | +3 (Skia) | +12 | ~10 |
| Tipo de cambio | guardas `respondsToSelector:`, envoltorio de familias, flags | familias y MSL 2.1 | rehacer contadores, *swizzle*, pasadas | volver a poner un backend que Chrome quitó |
| Mantenimiento por rebase | conflictos pequeños en 3–4 funciones (`mtl_utils.mm`, `DisplayMtl.mm`) | pequeños pero en código que Skia reescribe a menudo [I] | altos (Dawn cambia casi cada semana) [I] | los que traiga cada hito de GL |
| Riesgo de rendimiento | *swizzle* emulado; pasadas sin adjuntos; sin Mac2 se degrada [I] | desconocido [N] | n/a | el conocido de ANGLE-GL |
| Riesgo de corrección | **el Metal 2.1 de Mojave con los drivers viejos** (no lo cubre ningún test de Chromium) [I] | idem + MSL del SkSL [N] | alto | OpenGL maduro en esas Mac |
| Interfaz con el resto | con Graphite apagada es el único camino de Metal en Mac [V] | enciende un segundo camino | solo WebGPU | independiente de Metal |

**Riesgos transversales [I]:** (1) **Chrome ya no prueba nada en Mojave**: si ANGLE-Metal falla por un bug de driver de 2018, no hay forma de arreglarlo; (2) el parche toca un backend que ANGLE cambia a diario: la **disciplina de rebase** (un commit `Flynk-Class: compat` único y pequeño) es lo que lo hace mantenible; (3) hay que **apagar Graphite** (el flag tiene valor por defecto «encendido» en Apple) y **WebGPU** y comprobar que no queda un camino que llame a `supportsFamily:` por otro lado.

## 7. Qué haría yo, en orden (hitos, sin horas)

1. **Sonda** en las Mac (§5). Hito: un volcado por Mac y macOS en `FlyWeb/docs/metal-mojave-sondas.md` (sin datos personales).
2. **Cruzar** con la lista de `-Wunguarded-availability` de B1 (LOCAL-16): ¿aparecen los mismos sitios de §3.1 y no otros? Hito: lista de sitios extra (si los hay).
3. **Parche mínimo de ANGLE** (los 6 ficheros de §3.1) como rama `local/metal-mojave` o commit `compat`; compilar contra el árbol de B1 con el SDK 13.3 y destino 10.14. Hito: arranca la 6,1 en Mojave con WebGL sin abortar y un subconjunto de la conformidad de WebGL.
4. **Decidir** entre Metal-2.1 y OpenGL (B1c) **con** esos datos; si ambos funcionan, elegir el de menos mantenimiento (mi inclinación, [I]: Metal, por estar en el camino que Chrome mantiene).

Lo que **no** hay que hacer: tocar Graphite ni Dawn hasta que el paso 3 funcione.
