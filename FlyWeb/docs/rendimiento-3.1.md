# Rendimiento 3.1: coste por llamada de dibujo en ANGLE Metal (FM.56, punto 1)

Borrador de MOTOR (09-11-2026). **Todo es lectura de código, nada está medido.** Las ganancias son estimaciones de
orden de magnitud para ordenar el trabajo; las confirma o las tira el perfil de LOCAL (sección 4).

## 1. Contexto

- B1d (156, ANGLE `a66226b1d3` + parches `b1d/angle/0001`–`0008`) en la 6,1: Aquarium 60 / 54 / 37 fps con
  5 000 / 10 000 / 15 000 peces, **igual con una D500 que con dos** (LOCAL-18, `flynk-b1d-dosgpu`): manda un hilo de
  CPU del proceso de GPU (el principal, `CrGpuMain`), no la GPU.
- Cuenta a partir de esas cifras, suponiendo el hilo al 100 %: 10 000 × 54 = 540 000 y 15 000 × 37 = 555 000
  peces/s, es decir **~1,8 µs de hilo por pez**. Ese tiempo cubre todo lo que cuesta un pez: sus `uniform*` y su
  `drawElements`, por el decodificador, la parte común de ANGLE, el backend Metal y el driver de AMD. Ese hilo hace
  además Skia/Ganesh y la composición. Que esté saturado lo dijo LOCAL-18, pero no hay un `sample` guardado.
- Lo que hace Aquarium por pez (cuántos `uniform*` y de qué tipo) está **sin confirmar**: hay que capturar un
  fotograma con Spector.js (sección 4).

## 2. Ruta de una llamada de dibujo

Fuentes: Chromium `156.0.8078.90` y ANGLE `a66226b1d3` (el `angle_revision` del `DEPS` de la 156).

**Proceso de GPU, hilo principal:**

1. `gles2_cmd_decoder_passthrough.cc:GLES2DecoderPassthroughImpl::DoCommandsImpl<false>`. Recorre el command buffer
   y, por cada comando:
   - comprueba tamaño y argumentos con la tabla `command_info`;
   - llama al manejador por puntero a miembro;
   - **después de cada comando** comprueba `gl::GLContext::GetCurrent()` y `gl::GLSurface::GetCurrent()`, dos
     lecturas TLS (comentario en el código: «cheap enough to do per command»).
   - El `FlushForDriverCrashWorkaround` del final no se aplica a WebGL.
2. `gles2_cmd_decoder_passthrough_handlers.cc:HandleDrawElements` pasa a `gles2_cmd_decoder_passthrough_doers.cc:DoDrawElements`,
   que hace solo `api()->glDrawElementsFn(...)`. De ahí, por `RealGLApi`, se llama al puntero de función de
   `libGLESv2`.
   - Los uniformes siguen el mismo camino: `HandleUniformMatrix4fvImmediate` → `DoUniformMatrix4fv` → `glUniformMatrix4fvFn`.
3. `libGLESv2/entry_points_gles_2_0_autogen.cpp:GL_DrawElements`, en este orden:
   - `GetValidGlobalContext()` (TLS);
   - `SCOPED_SHARE_CONTEXT_LOCK` (cerrojo del contexto);
   - `ValidateDrawElements` → `validationES.h:ValidateDrawElementsCommon` / `ValidateDrawBase`. La validación usa la
     caché de estado (`getBasicDrawStatesErrorString`). El rango de índices solo se calcula con
     `isBufferAccessValidationEnabled()`, y entonces con caché en `VertexArray::getIndexRange`.
   - WebGL **no** usa `EGL_CONTEXT_OPENGL_NO_ERROR_KHR`: `gl_context_egl.cc:146` lo pone solo con
     `can_skip_validation`.
4. `Context.inl.h:Context::drawElements` → `prepareForDraw`:
   - `syncDirtyObjects` y `syncDirtyBits`;
   - `ContextMtl::syncState`, que traduce los bits de `gl::State` a los `mDirtyBits` de `ContextMtl`.
   - Un `glUniform*` no ensucia el estado: `Context::uniform4fv` va directo a
     `ProgramExecutableMtl::setUniformImpl`, que copia en `mDefaultUniformBlocks[shader].uniformData` y marca
     `mDefaultUniformBlocksDirty` para cada etapa que use ese uniforme.
5. `ContextMtl.mm:ContextMtl::drawElementsImpl`:
   - declara un `std::vector<DrawCommandRange> drawCommands` local;
   - llama a `VertexArrayMtl.mm:VertexArrayMtl::resolveDrawElementsDraw`, que:
     - (paso 1) toma el buffer de índices: `BufferMtl::getCurrentBuffer`, o `convertIndexBuffer` (con caché) para `UNSIGNED_BYTE`;
     - (paso 2) **`std::vector<DrawIndexRange> indexRangesStorage` + `emplace_back`** (sin primitive restart, un solo rango);
     - (paso 4) **`std::vector<DrawCommandRange> drawCommands` + `emplace_back`** en `AppendDrawCommands` →
       `AppendDrawCommandsTemplate`, y lo mueve al vector del llamador.

     **Resultado: dos `malloc` y dos `free` por cada `drawElements`**, para guardar un solo elemento en el caso normal.
     `drawArrays` no pasa por aquí.
6. `ContextMtl::setupDraw` → `setupDrawImpl`:
   - `handleDirtyActiveTextures`, si `DIRTY_BIT_TEXTURES`;
   - `handleDirtyRenderPass`, si cambia el FBO: `FramebufferMtl::ensureRenderPassStarted` → `RenderCommandEncoder::restart`;
   - `checkIfPipelineChanged` → `VertexArrayMtl::setupDraw`, que no hace nada si el VAO no está sucio;
   - el bucle `for (bit : mDirtyBits)` con los `set*` del encoder;
   - **`isDrawNoOp`** en cada dibujo:
     - llama a `GetMaxNumberOfRenderTargetsForDevice(device)`;
     - en 10.14, con el parche `0002`, eso es `SupportsAppleGPUFamily` (`@available` → false) más
       `SupportsMacGPUFamily` → **`[MTLDevice supportsFeatureSet:]`, un mensaje ObjC al driver por dibujo**;
       en 10.15 y posteriores son dos `supportsFamily:`;
     - luego recorre hasta 8 adjuntos de color;
   - `ProgramExecutableMtl::setupDraw`;
   - **`checkCommandBufferError`** en cada dibujo: `std::atomic::exchange` (`AtomicCommandBufferError::pop`, que viene
     del upstream 64b22df, elegido para la M156 como 127e783).
7. `ProgramExecutableMtl.mm:ProgramExecutableMtl::setupDraw`:
   - Si cambia la descripción de pipeline: `getSpecializedShader` ×2 y `PipelineCache::getRenderPipeline`
     (`HashingMRUCache` sobre `RenderPipelineDesc`). Si no está en la caché, se compila de forma síncrona: es el parón
     de la primera carga del README de B1d.
   - **`commitUniforms`**, para cada etapa sucia, sube **el bloque entero**, no solo lo que cambió:
     - si `uniformData.size() <= kInlineConstDataMaxSize` (4 KB, `mtl_common.h:117`):
       `RenderCommandEncoder::setBytes` copia el bloque al flujo intermedio;
     - si no: `BufferPool::releaseInFlightBuffers` + `allocateAndMap` + `SpanMemcpy` + `commit`
       (`didModifyRange` si el buffer es `Managed`) + `setBuffer`.
   - `updateTextures`, solo si hay sampler sucio o `forceUpdate`, llama a `TextureMtl::bindToShader` →
     `setTexture` + `setSamplerState`.
   - `updateUniformBuffers` (UBO de WebGL 2), solo si cambian los enlaces o la pipeline:
     - `legalizeUniformBufferOffsets`, que busca en `std::unordered_map` por **nombre** de bloque
       (`mUniformBlockConversions.at(block.name)`);
     - si el shader usa argument buffer, `encodeUniformBuffersInfoArgumentBuffer` (`MTLArgumentEncoder`) + `useResource`.
8. `mtl_command_buffer.mm:RenderCommandEncoder::drawIndexed` (y el resto de `set*`/`draw*`):
   - **no llama a Metal**. Graba en `IntermediateCommandStream` (`std::vector<uint8_t>`, un `insert` por campo) y hace
     `retain` de cada objeto ObjC que graba;
   - `setBuffer`, `setTexture` y `drawIndexed*` llaman antes a **`CommandBuffer::setReadDependency`**:
     - **`std::lock_guard` sobre `CommandBuffer::mLock`**;
     - `Resource::setUsedByCommandBufferWithQueueSerial`;
     - en la variante con `ResourceRef`, **`angle::HashSet<id>::insert`** en `mResourceList`.

     Se hace aunque el recurso ya esté enlazado: `setTexture` registra la dependencia antes de mirar la caché de
     estado.
9. Al cerrar el pase (`RenderCommandEncoder::endEncoding` → `encodeMetalEncoder`, en un `@autoreleasepool`):
   - `renderCommandEncoderWithDescriptor:`;
   - **se reproduce el flujo entero**: un `fetch` por campo, el `objc_msgSend` real al encoder del driver de AMD
     (`setVertexBytes:`, `drawIndexedPrimitives:`…) y un `release` por objeto.

   O sea: cada `set`/`draw` se paga dos veces en el mismo hilo, al grabar y al reproducir. Y `setBytes` copia los
   uniformes **dos veces**: en el flujo, y el driver otra vez en su `setVertexBytes`.
10. `ContextMtl::flushCommandBufferIfNeeded` se llama por pase, no por dibujo:
    - hace commit cada `kMaxRenderPassesPerCommandBuffer` = 16 pases o al pasar de 400 MB de recursos;
    - `CommandQueue::makeMetalCommandBuffer` crea dos bloques (scheduled y completed) por command buffer;
    - las barreras (`ContextMtl::memoryBarrier`, `memoryBarrierWithResource`) solo vienen de `glMemoryBarrier*`
      (ES 3.1), que **WebGL no expone**. **En WebGL no hay barreras por dibujo.**

**Varias GPU (`flynk-b1d-dosgpu`, src `b8a4abda2f`, ANGLE `dc5ef06`):**
- En `/home/user/softmac` solo aparecen como referencia: en `docs/TAREAS.md` (FM.56), `FlyWeb/docs/b1d/README.md:41`
  y `relevo-motor.md`. No hay parches ni notas de `dc5ef06`, y el repo no se ha clonado (por orden).
- **No lo he leído.** Lo único que se sabe es que la WebGL va a la segunda GPU (EGLDualGPURendering) y que el número
  de hilos no cambia, que es justo lo que este análisis explica: todo lo de arriba ocurre en el mismo hilo.

## 3. Cambios, por prioridad

«Upstream»: se ha comparado con ANGLE `main` = `b6c37bfbcd` (09-11-2026) desde la base de la rama 8078
(`dfeede5`, 28-09). Ningún commit de `main` en ese intervalo toca la ruta por dibujo descrita, salvo `adaa3da`
(punto 8). En `main` siguen sin cambios el `std::vector<DrawCommandRange>`, el flujo intermedio, `setReadDependency`
con mutex e `isDrawNoOp`. No he podido consultar Gerrit (el proxy rechaza `chromium-review.googlesource.com`), así que
**no sé si hay CL abiertos** sobre esto.

### 1. Dependencias de recursos sin mutex ni HashSet cuando ya están registradas (c, d)
- **Qué hacer:**
  - En `CommandBuffer::setReadDependency` y `setWriteDependency`: si `resource->getCommandBufferQueueSerial() == mQueueSerial`
    (y, si es de escritura, la marca ya está puesta), volver sin tomar `mLock` ni tocar `mResourceList`.
    `mQueueSerial` solo cambia en `restart()`, que corre en este mismo hilo.
  - En `RenderCommandEncoder::setTexture`, registrar la dependencia solo cuando cambia la textura enlazada. Ojo: un
    pase nuevo empieza con la caché vacía (`mStateCache.reset()`), así que vuelve a registrarse.
- **Ficheros:** `mtl_command_buffer.mm` (`setReadDependency`, `setWriteDependency`, `setTexture`, `setBuffer`),
  `mtl_resources.mm`.
- **Ganancia estimada (lectura):** de 1 a 3 parejas lock/unlock y búsquedas en hash por dibujo (buffer de índices,
  más las texturas y los buffers que se reenlazan). Del orden de algunos % del hilo por dibujo. Es la que más
  aparece en la ruta común.
- **Riesgo:** medio-bajo. `mLock` protege `readyImpl()` (`mCommitted`) frente a otros hilos de ANGLE. El atajo se
  salta un estado ya registrado en el mismo serial, sin cambiar qué se retiene.
- **Upstream:** no existe.
- **Medir:** con `sample`, el peso de `CommandBuffer::setReadDependency`, de `pthread_mutex_lock`/`unlock` que cuelgan
  de él y de `HashSet…insert`. En ANGLE, `angle_perftests --gtest_filter=DrawCallPerfBenchmark.Run/metal*`.

### 2. Flujo intermedio más barato y uniformes sin doble copia (b, d)
- **Qué hacer:**
  - (a) Que `IntermediateCommandStream` reserve capacidad y escriba cada comando de una vez (un `resize` + `memcpy`
    de una estructura empaquetada), no con un `vector::insert` por campo.
  - (b) En `commitUniforms`, subir el bloque por defecto a un `BufferPool` de anillo por contexto (`Shared`) aunque
    quepa en 4 KB. Cuando el buffer no cambia, el encoder ya graba solo `SetBufferOffset`: es el atajo de
    `commonSetBuffer`, que en la reproducción da `setVertexBufferOffset:atIndex:`. Así se quita una copia (el flujo)
    y la copia interna de `setVertexBytes` en el driver.
  - (c) A más largo plazo, para las etapas que comparten bloque, un solo `memcpy` por dibujo.
- **Ficheros:** `mtl_command_buffer.h/.mm` (`IntermediateCommandStream`, `setBytes`, `commonSetBuffer`),
  `ProgramExecutableMtl.mm` (`commitUniforms`, `getBufferPool`), `mtl_buffer_pool.mm`.
- **Ganancia estimada (lectura):**
  - (a): pequeña por dibujo, pero se aplica a **todos** los comandos.
  - (b): proporcional al tamaño del bloque y al número de etapas sucias. Pesa más con bloques grandes (three.js,
    Babylon) que en Aquarium, si sus bloques son pequeños.
  - Orden de magnitud: de unos % a más del 10 % del hilo **si** `sample` muestra `memmove` bajo `setBytes` o bajo
    `-[… setVertexBytes:…]` del driver.
- **Riesgo:**
  - (a): bajo.
  - (b): medio. El anillo necesita que `releaseInFlightBuffers` y `isBeingUsedByGPU` funcionen bien (consultan el
    serial completado, sin bloqueo, `CommandQueue::isSerialCompleted`). En una D500 la memoria `Shared` es memoria del
    sistema leída por PCIe, igual que la de `setBytes`, pero hay que medirlo.
- **Upstream:** no existe.
- **Medir:** `angle_perftests` `DrawCallPerfBenchmark.Run/metal_uniform*` y `UniformsPerf`; Aquarium 10 000 y 15 000;
  el peso de `RenderCommandEncoder::setBytes`, `IntermediateCommandStream` y `_platform_memmove` en `sample`.

### 3. Sin vectores en el heap por `drawElements` (a)
- **Qué hacer:**
  - `DrawCommandRange` → `angle::FastVector<DrawCommandRange, 4>` (`src/common/FastVector.h`, ya en la base). Hay
    que añadir un constructor por defecto a `DrawCommandRange` (`BufferMtl.h:31`), porque `FastVector` guarda en un
    `std::array`.
  - Lo mismo para `indexRangesStorage` (`FastVector<DrawIndexRange, 1>`), o evitarlo sin primitive restart pasando
    el rango directamente.
  - Firma: `resolveDrawElementsDraw(..., angle::FastVector<…> *outDrawCommands, ...)` en `VertexArrayMtl.h:65` y en
    `ContextMtl::drawElementsImpl`.
- **Ficheros:** `BufferMtl.h`, `VertexArrayMtl.h/.mm`, `ContextMtl.mm`, `VertexArrayMtl_unittest.mm` (usa
  `AppendSimpleDrawCommandRanges` con `std::vector`).
- **Ganancia estimada (lectura):** dos `malloc` y dos `free` menos por `drawElements`. Sobre los ~1,8 µs por pez, se
  calcula del orden de pocos % del hilo. Es el punto que ya señalaba FM.56. El riesgo es mínimo y conviene hacerlo
  aunque gane poco.
- **Riesgo:** bajo; hay pruebas unitarias de esa función.
- **Upstream:** no existe. En `main` (`b6c37bfbcd`) sigue el `std::vector`.
- **Medir:** `DrawElementsPerf` y `DrawCallPerfBenchmark` en metal; en `sample`, `malloc`/`free` (`nanozone`) bajo
  `resolveDrawElementsDraw`.

### 4. Quitar del camino por dibujo lo que no cambia por dibujo (c)
- **Qué hacer:**
  - (a) `isDrawNoOp`: guardar `GetMaxNumberOfRenderTargetsForDevice` en `ContextMtl` al crearlo, para no mandar
    `supportsFeatureSet:` (10.14) o `supportsFamily:` (10.15+) al driver en cada dibujo. Calcular «hay destino válido»
    solo cuando cambia la `RenderPipelineDesc` (`rppChange`), no en cada dibujo.
  - (b) `checkCommandBufferError`: hacer un `load(relaxed)` y llamar a `exchange` solo si hay error.
  - (c) `legalizeUniformBufferOffsets`: buscar las conversiones por índice de bloque, no por nombre.
  - (d) Hacer lo mismo en `mtl_utils.mm:1485` y `:1513`, que llaman a `GetMaxNumberOfRenderTargetsForDevice` en la
    condición del bucle (por pase o por pipeline, no por dibujo).
- **Ficheros:** `ContextMtl.h/.mm`, `mtl_utils.mm`, `mtl_command_buffer.h`, `ProgramExecutableMtl.mm`.
- **Ganancia estimada (lectura):** un mensaje ObjC al driver y un `xchg` atómico menos por dibujo; poco cada uno.
  Para (c), solo en WebGL 2 con UBO.
- **Riesgo:** nulo o bajo, en (a) y (b) sobre todo.
- **Upstream:** no existe.
- **Medir:** en `sample`, `-[… supportsFeatureSet:]` (o `supportsFamily:`) bajo `isDrawNoOp`.

### 5. Reproducir el encoder fuera del hilo principal (d; puente con FM.56 punto 2)
- **Qué hacer:** ANGLE ya graba los pases y los reproduce en `endEncoding`. Esa reproducción, con
  `renderCommandEncoderWithDescriptor:`, todos los `objc_msgSend` al driver y los `release`, puede ir a un hilo
  trabajador por contexto. Se le pasa el flujo cerrado y el `MTLRenderPassDescriptor`, y el commit se encola detrás
  en orden.
  - Metal permite codificar en otro hilo si cada encoder lo usa un solo hilo a la vez.
  - Lo que se mueve es todo el coste del driver de AMD.
- **Ficheros:** `mtl_command_buffer.mm` (`endEncodingImpl`, `encodeMetalEncoder`, `CommandBuffer::commit`),
  `ContextMtl.mm` (`flushCommandBuffer`, `present`).
- **Ganancia estimada (lectura):** depende por completo de cuánto pese el driver. Si `sample` muestra que
  `encodeMetalEncoder` y el driver se llevan una parte grande del hilo, es el cambio con más techo de la lista.
  Si no, no vale lo que cuesta.
- **Riesgo:** alto. Afecta a:
  - el orden con los blit/compute encoders del mismo command buffer;
  - `present` y los IOSurface;
  - las consultas de oclusión (`visibilityResultBuffer` se pone en `endEncodingImpl`);
  - los `release` de objetos que la reproducción usa.
- **Upstream:** no existe.
- **Medir:** primero, el porcentaje de `RenderCommandEncoder::encodeMetalEncoder` (inclusivo) y del módulo del driver
  de AMD en el hilo. Si pasa de un cuarto, se prototipa.

### 6. PGO propio para ANGLE (todo el camino)
- **Qué hacer:**
  - `b1d/pgo-mojave.md`: el perfil de Google marca frío el 55,2 % de las funciones `rx::mtl` / `*Mtl`, frío el
    dibujo de `ContextMtl` (H3) y frío todo Ganesh. Con PGSO, lo frío se optimiza para tamaño.
  - Opciones: quitar el PGO a `third_party/angle` (`configs -= [ "//build/config/compiler/pgo:default_pgo_flags" ]`,
    sección 6 de ese documento), o generar un perfil propio con Aquarium y MotionMark en Mojave.
- **Ganancia estimada:** desconocida para ANGLE en concreto. El único dato es MotionMark +8 % con PGO de Google, y
  ese contraste no es limpio (lo dice el propio documento).
- **Riesgo:** bajo; es un cambio de compilación.
- **Upstream:** no aplica.
- **Medir:** Aquarium 15 000 con y sin, el mismo día y en la misma máquina.

### 7. Decodificador de Chromium (traducción)
- **Qué hacer:** casi nada. `DoDrawElements` es una llamada directa. Lo único por comando que no es trabajo útil:
  - las dos lecturas TLS `GetCurrent()` de `DoCommandsImpl`;
  - en ANGLE, `GetValidGlobalContext` y `SCOPED_SHARE_CONTEXT_LOCK` en cada punto de entrada.

  Se podría comprobar el contexto actual una vez por lote, pero esa comprobación protege frente a comandos que dejan
  otro contexto activo. **No lo toco sin perfil.**
- **Ficheros:** `gpu/command_buffer/service/gles2_cmd_decoder_passthrough.cc`.
- **Ganancia estimada:** baja.
- **Riesgo:** medio (seguridad: comandos sobre el contexto equivocado).
- **Upstream:** no existe.
- **Medir:** en `sample`, el peso propio de `DoCommandsImpl` y de `GLContext::GetCurrent`.

### 8. Otros que no son por dibujo en Aquarium (anotados)
- `adaa3da` (upstream, 07-10, «Metal: Cache index conversions for flat shading»): guarda en caché la reescritura de
  índices del provoking vertex.
  - Solo cuenta si la web usa varyings `flat` con `drawElements`. Entonces evita un `preconditionIndexBuffer` (un
    compute pass) por dibujo.
  - No está en la 8078. Es candidato a portar si el perfil de alguna web (three.js con `flat`) lo enseña.
  - Toca `BufferMtl.h/.mm`, `ProvokingVertexHelper.h/.mm` y `VertexArrayMtl.mm` (+31/−7).
- `c3e419e` (upstream, 30-09, «Make BufferPool freelist entries purgeable»): es de memoria, no de CPU. Va detrás de
  una feature.
- `setUniformImpl` marca la etapa como sucia aunque el valor no cambie. Un `memcmp` antes evitaría volver a subir
  el bloque cuando la web repite los mismos valores. No ayuda en Aquarium, donde cada pez trae valores nuevos.
- La compilación síncrona de pipelines (parón de la primera carga, 500 programas en 22 s) es otro problema. Está
  apuntado en el README de B1d y no entra en esta lista.

## 4. Qué tiene que perfilar LOCAL (6,1 y 7,1)

**Preparación:**
- Build oficial de la 3.0.x con símbolos (`symbol_level=1` como mínimo, o el dSYM de la entrega).
- En la 6,1, Aquarium a 10 000 y 15 000 peces, una D500.
- En la 7,1, lo mismo (Sequoia, W6600X), como control de «lo que cuesta en Mojave y no en Sequoia».
- Además, un fotograma de Aquarium capturado con **Spector.js**, para tener la cuenta exacta de `uniform*`,
  `drawElements` y cambios de estado por pez.

**Comandos:**
- `sample <pid GPU> 10 -file gpu.txt` con Aquarium en marcha. Mejor aún, Instruments → Time Profiler con «Separate
  by Thread» e «Invert Call Tree».
- Hilo: `CrGpuMain`. Apuntar también el porcentaje de `VizCompositorThread` y del hilo principal del renderer (V8),
  para descartar que el límite esté ahí.

**Símbolos para cada punto (inclusivos salvo que se diga):**

| Punto | Buscar | Confirma si… |
|---|---|---|
| 1 | `rx::mtl::CommandBuffer::setReadDependency`, `setWriteDependency`; `pthread_mutex_lock`/`unlock` colgando de ellos; `angle::HashSet`/`absl::…raw_hash_set…insert` | entre todos, más de unos pocos % |
| 2 | `rx::mtl::RenderCommandEncoder::setBytes`, `commonSetBuffer`, `IntermediateCommandStream` (inline, se ve como `std::vector<unsigned char>::insert`), `_platform_memmove` bajo ellos; `rx::ProgramExecutableMtl::commitUniforms` | `commitUniforms` + `setBytes` más del ~5 % |
| 3 | `rx::VertexArrayMtl::resolveDrawElementsDraw`; `malloc`/`free`/`nanov2_*` bajo él; `AppendDrawCommandsTemplate` | aparecen `malloc`/`free` en ese árbol |
| 4 | `isDrawNoOp` (puede estar inline en `setupDrawImpl`); `-[… supportsFeatureSet:]` / `supportsFamily:`; `checkCommandBufferError` | aparece el mensaje ObjC por dibujo |
| 5 | `rx::mtl::RenderCommandEncoder::encodeMetalEncoder`, `endEncodingImpl`; frames del módulo del driver de AMD (en 10.14 debería ser `AMDMTLBronzeDriver`; confirmar el nombre en el perfil); `objc_msgSend`, `objc_release` | `encodeMetalEncoder` + driver por encima del 25 % del hilo |
| 6 | Proporción de `rx::`/`gl::` frente al total; comparar el mismo `sample` con PGO y sin PGO | diferencia por encima del ruido |
| 7 | `gpu::gles2::GLES2DecoderPassthroughImpl::DoCommandsImpl<false>` (propio), `gl::GLContext::GetCurrent`, `GL_DrawElements`, `gl::ValidateDrawElements*`, `egl::…ContextMutex` / `SharedContextMutex` | algo por encima del ~5 % |
| — | `rx::ContextMtl::syncState`, `gl::Context::prepareForDraw`, `rx::ProgramExecutableMtl::setupDraw`, `rx::PipelineCache::getRenderPipeline`, `-[_MTLDevice newRenderPipelineStateWithDescriptor:error:]` | en estado estable, **no** debería verse la última; si se ve, son fallos de caché |

**Microbenchmarks** (si el objetivo `angle_perftests` compila en el checkout; si no, en ANGLE standalone):
- `DrawCallPerfBenchmark.Run/metal*` (incluidas las variantes `_uniform`, `_vbo_change`, `_tex_change`);
- `DrawElementsPerf*`;
- `UniformsPerf*`.

Antes y después de cada cambio, en la 6,1. Sirven para separar la ganancia de ANGLE del resto del navegador.

## 5. Fuentes

**Leído:**
- ANGLE `a66226b1d3`, `src/libANGLE/renderer/metal/`:
  - `ContextMtl.mm` (`drawElementsImpl`, `drawArraysImpl`, `setupDraw`, `setupDrawImpl`, `isDrawNoOp`,
    `checkIfPipelineChanged`, `handleDirty*`, `flushCommandBuffer*`, `checkCommandBufferError`);
  - `VertexArrayMtl.mm` (`resolveDrawElementsDraw`, `AppendDrawCommands*`, `setupDraw`, `convertIndexBuffer`);
  - `ProgramExecutableMtl.mm` (`setupDraw`, `commitUniforms`, `updateTextures`, `updateUniformBuffers`,
    `legalizeUniformBufferOffsets`, `encodeUniformBuffersInfoArgumentBuffer`, `setUniformImpl`, `getBufferPool`);
  - `mtl_command_buffer.h/.mm` (`IntermediateCommandStream`, `RenderCommandEncoder::*`, `CommandBuffer::set*Dependency`,
    `CommandQueue`);
  - `mtl_buffer_pool.mm`, `mtl_resources.mm` (fragmentos), `TextureMtl.mm` (`bindToShader`),
    `mtl_utils.mm` (familias de GPU), `mtl_common.h`, `BufferMtl.h`.
- ANGLE `a66226b1d3`, parte común: `src/libANGLE/Context.inl.h`, `Context.cpp` (uniformes),
  `validationES.h/.cpp` (dibujo), `src/libGLESv2/entry_points_gles_2_0_autogen.cpp` (`GL_DrawElements`),
  `src/common/FastVector.h` (existe), `src/tests/perf_tests/` (lista y `DrawCallPerf.cpp`).
- ANGLE upstream: `main` = `b6c37bfbcd`, rama `chromium/8078` = `f10470c`, base común `dfeede5`. Clon parcial sin
  blobs (`--filter=blob:none --shallow-since`) solo para el log. Commits citados: `adaa3da`, `c3e419e`, `64b22df`,
  `127e783`.
- Chromium `156.0.8078.90`: `gpu/command_buffer/service/gles2_cmd_decoder_passthrough.cc` (`DoCommandsImpl`),
  `…_doers.cc` (`DoDrawElements`), `…_handlers.cc`, `…_handlers_autogen.cc` (uniformes), `ui/gl/gl_context_egl.cc`
  (NO_ERROR), `DEPS` (`angle_revision`).
- softmac: `FlyWeb/docs/b1d/angle/0001`–`0008`, `FlyWeb/docs/b1d/README.md`, `FlyWeb/docs/b1d/pgo-mojave.md`,
  `FlyWeb/docs/pruebas-gpu.md`, `docs/TAREAS.md` (FM.56), `FlyWeb/docs/relevo-motor.md`.

**No leído:**
- ANGLE `dc5ef06` y src `b8a4abda2f` (`flynk-b1d-dosgpu`): no hay copia en softmac y no se ha clonado.
- Gerrit (`chromium-review.googlesource.com`): el proxy lo rechaza.
- `ContextMtl::syncState` (leído por encima), `FrameBufferMtl.mm` (`ensureRenderPassStarted`, sin leer en detalle),
  el binding de GL de Chromium (`RealGLApi`) y el planificador de la GPU (`CommandBufferStub` / `Scheduler`).
- `aquarium.js`: los uniformes por pez están sin comprobar.
