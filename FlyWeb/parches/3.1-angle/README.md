# FlyWeb 3.1: ANGLE Metal, menos trabajo por dibujo (FM.56)

MOTOR-43, 09-11-2026, por encargo de COORDINACIÓN-36 a partir del perfil de LOCAL-21
([`../../docs/rendimiento-3x.md`](../../docs/rendimiento-3x.md)). Las propuestas originales están en
[`../../docs/rendimiento-3.1.md`](../../docs/rendimiento-3.1.md).

**Base:** el ANGLE de la 3.0.1, es decir, ANGLE `f10470c77e` (`chromium/8078`, el `angle_revision` de la .96) más los 12
parches de [`../../seguridad/3.0.1/angle/`](../../seguridad/3.0.1/angle/): árbol `d094abc`, como dice el README de la
3.0.1. **Uso:** `git am` de esos 12 y luego de estos 4, uno por cambio, para poder medirlos por separado. Los 4 entran
limpios (comprobado con ANGLE del repo público, en solo lectura). Árbol resultante: `099b621`.

**Nada compilado ni probado en un Mac** (en la nube no hay SDK de Metal). Lo único ejecutado son pruebas en C++ en Linux
de las dos estructuras nuevas (ver 0002 y 0004).

| Parche | Cambio | Peso en el perfil (6,1, 15 000 peces; % de `CrGpuMain`) | Riesgo |
|---|---|---|---|
| `0001-Metal-only-re-bind-textures-and-samplers-when-they-c.patch` | Texturas y samplers, solo si cambian (nuevo) | `updateTextures` 18,6 % inclusivo | medio |
| `0002-Metal-no-heap-allocation-for-draw-command-ranges-per.patch` | Cambio 3: `FastVector` en `resolveDrawElementsDraw` | 5–7 % | bajo |
| `0003-Metal-take-device-capability-queries-off-the-per-dra.patch` | Cambio 4: `GetMaxNumberOfRenderTargetsForDevice` una vez; `checkCommandBufferError` | 3–4 % | muy bajo |
| `0004-Metal-append-to-the-intermediate-command-stream-with.patch` | Cambio 2(a): flujo intermedio sin `insert` por campo | ≈8 % (`insert` 3,4 % propio + `memmove`) | bajo |

## 0001: por qué ANGLE re-enlazaba las texturas en cada dibujo

`ProgramExecutableMtl::mSamplerBindingsDirty` se pone a 1 en `setupDraw` cuando cambia la pipeline y en `setUniformImpl`
cuando cambia un uniforme sampler. **Nadie lo vuelve a poner a 0.** `updateTextures` solo se salta una etapa si
`!mSamplerBindingsDirty[etapa] && !forceUpdate`. Así que, tras el primer dibujo de cada programa, todos los dibujos
recorren todos los samplers y llaman a `TextureMtl::bindToShader`. Eso cuesta:
- `RenderCommandEncoder::setTexture`, con `CommandBuffer::setReadDependency` y su mutex **antes** de mirar la caché;
- `setSamplerState`.

Los uniformes por defecto, al lado, sí se limpian: `commitUniforms` hace `mDefaultUniformBlocksDirty.reset(etapa)`. No es
cosa de Brave ni de nuestros parches: está así en ANGLE `main` y en todas las ramas que he mirado, desde `chromium/4044`
(2020) hasta la 8078. Upstream no tiene arreglo.

**Arreglo:**
- `updateTextures` limpia el bit de la etapa cuando sus enlaces ya están en el encoder.
- En `ContextMtl::setupDrawImpl`, un dibujo nulo (`isDrawNoOp`, que no llama a `setupDraw` del programa) deja pendiente
  `DIRTY_BIT_TEXTURES`, para no perder la petición.

**Por qué es seguro** (repasado en el código de la base). Todo lo que cambia lo que se enlaza llega a uno de los dos
bits, y los dos siguen forzando el re-enlace:
- **`DIRTY_BIT_TEXTURES` del contexto** (llega como `forceUpdate`):
  - `glBindTexture` y `glActiveTexture` → `DIRTY_BIT_TEXTURE_BINDINGS`.
  - `glBindSampler` → `DIRTY_BIT_SAMPLER_BINDINGS`.
  - Parámetros de textura, base/max level, swizzle y modo de comparación: `gl::Texture` avisa con `DirtyBitsFlagged` →
    `onActiveTextureStateChange` → `syncActiveTextures` → `DIRTY_BIT_TEXTURE_BINDINGS`. Además, `TextureMtl::syncState`
    llama a `invalidateCurrentTextures` en los casos de comparación.
  - Almacenamiento nuevo (`texImage`, `texStorage`, `generateMipmap`, EGLImage, `bindTexImage`, cambio de base/max): los
    avisa `SubjectChanged` y, además, `TextureMtl` llama directamente a `invalidateCurrentTextures`.
  - Textura que pasa a incompleta: cambia la caché de texturas activas → `DIRTY_BIT_TEXTURE_BINDINGS`.
  - Parámetros de un objeto sampler: `SamplerMtl` llama a `invalidateCurrentTextures`.
  - Uniforme sampler (`glUniform1i`): `onSamplerUniformChange` → `DIRTY_BIT_TEXTURE_BINDINGS`.
  - Cambio de programa: `updateProgramExecutable`.
- **El bit del programa**, por la pipeline:
  - Encoder nuevo: `getRenderPassCommandEncoder` e `invalidateState` marcan todo, incluido `DIRTY_BIT_RENDER_PIPELINE`,
    y con él `rppChange`. `setupDraw` vuelve a poner el bit y se re-enlaza todo.
  - Pipeline nueva: igual.
- **Dependencias del command buffer:** la de lectura y el `retain` en `mResourceList` se registran por command buffer.
  Un encoder pertenece a un solo command buffer, y lo que se salta es re-enlazar dentro del mismo encoder.

**Lo que queda distinto:** un programa compartido entre dos contextos de un mismo share group, con un uniforme sampler
cambiado desde el otro contexto. La especificación (ES 3.2, apéndice D.3.3) solo exige verlo tras volver a enlazar el
programa, y `glUseProgram` lo fuerza. En Chromium, cada contexto WebGL tiene su propio share group.

**Ganancia esperada:** casi todo el 18,6 %. Aquarium solo cambia de textura o de programa ≈50–90 veces por fotograma
frente a ≈15 000 dibujos, y solo esos dibujos vuelven a enlazar. De paso baja el mutex bajo `setTexture` (4,2 %) y parte
de `objc_msgSend`.

## 0002: cambio 3, sin vectores en el heap por `drawElements`

- `DrawCommandRanges = angle::FastVector<DrawCommandRange, 4>`. `resolveDrawElementsDraw` escribe directamente en el del
  llamador; antes creaba un vector local y lo movía.
- El rango único de índices (`std::vector<DrawIndexRange>`) solo se construye cuando lo lee la reescritura del provoking
  vertex. Con primitive restart, que en WebGL 2 está siempre activo, ya venía de la caché del buffer.
- `VertexArrayMtl_unittest.mm` pasa a usar el tipo nuevo.
- Probado en Linux: `FastVector<DrawCommandRange, 4>` con 0, 1, 4 y 9 elementos (paso a heap), `clear` y copia.
- **Ganancia esperada:** 5–7 % (las dos asignaciones y liberaciones por dibujo de `partition_alloc`).

## 0003: cambio 4, consultas al dispositivo fuera del dibujo

- `ContextMtl` guarda `GetMaxNumberOfRenderTargetsForDevice` al inicializarse (`mMaxColorRenderTargets`). `isDrawNoOp`
  ya no manda `supportsFeatureSet:` (10.14) ni `supportsFamily:` (10.15+) al driver en cada dibujo.
- `AtomicCommandBufferError::pop()` lee antes de hacer el `exchange` atómico. En el perfil salía al 0 %; se hace igual,
  porque está en cada dibujo.
- Los dos bucles de `mtl_utils.mm` que preguntaban al dispositivo en cada vuelta preguntan una vez.
- **Ganancia esperada:** 3–4 % (`GetMaxNumberOfRenderTargetsForDevice` 3,6 %, con su `objc_release`).

## 0004: cambio 2(a), flujo intermedio sin `insert` por campo

- `IntermediateCommandStream` guarda el tamaño aparte. El `std::vector<uint8_t>` hace de capacidad: crece al doble
  (mínimo 4 KB) y `clear()` la conserva, como antes.
- Cada campo se añade con una comprobación de límite y un `memcpy` de tamaño fijo. Antes era un
  `vector::insert(end, ptr, ptr + n)` por campo. La lectura y los bytes grabados no cambian.
- Probado en Linux contra la clase original: 20 secuencias aleatorias de comandos, con lectura, `resetReadPtr`, `peek`,
  `clear` y reutilización, dan resultados **idénticos**. Limpio con ASan y UBSan (g++).
- Microbenchmark (Linux, libstdc++, no es el Mac): grabar 15 000 dibujos al estilo de Aquarium baja de 1,7 ms a 0,22 ms
  por fotograma.
- **Ganancia esperada:** buena parte del 8,3 % (el `memcpy` se queda).

## Ganancia total y qué medir

- Los cuatro juntos atacan, con solapes, del orden del **30–35 % del tiempo de `CrGpuMain`**.
- Con el hilo al 92,7 %, Aquarium a 15 000 peces podría pasar de 39 fps a unos 50–55. Es una estimación, no una medida.
- Antes llegará otro límite: el renderer estaba al 62 % con 39 fps y a ese ritmo se acercaría al 90 %. Su mayor coste es
  `Math.sin`/`cos` de V8. Hay que mirar en qué hilo está el límite después de aplicarlos.

**LOCAL (6,1, con la receta de `rendimiento-3x.md`):**
1. Compilar con los 4 y medir Aquarium 5 000 / 10 000 / 15 000 (mediana de 3) y MotionMark.
   - Si hay tiempo de compilación, medir también acumulando en orden (0001; +0002; +0003; +0004) para separar cada
     cambio. 0001 es el que más pesa.
2. `sample` de `CrGpuMain` a 15 000 peces. Tienen que bajar:
   - `updateTextures`, `bindToShader` y `setTexture`;
   - el `partition_alloc` bajo `drawElementsImpl`;
   - `deviceOrFeatureProfileSupportsFeatureSet:`;
   - `vector<unsigned char>::__insert_with_size`.

   Además, `ps -M` de los hilos de GPU y del renderer.
3. **Corrección de texturas (riesgo de 0001)**, en WebGL 1 y 2 y en las dos GPU de la MacBook Pro 2012 si se puede:
   - el acuario se ve igual: fondo, peces y burbujas;
   - una página que alterne varias texturas y programas en el mismo fotograma;
   - vídeo en una textura (`texImage2D(video)` en cada fotograma);
   - render-to-texture y luego muestrearla;
   - `generateMipmap` sobre una textura ya enlazada;
   - `texParameteri` (filtro) entre dibujos;
   - samplers de WebGL 2 (`bindSampler`, `samplerParameteri`);
   - `uniform1i` sobre un sampler entre dibujos;
   - claude.ai, Google Maps y una demo de three.js.
   - Si se puede compilar `angle_end2end_tests` (Metal): `TextureTest*`, `Texture2DTest*`, `SamplerTest*`,
     `WebGLCompatibilityTest*`, `StateChangeTest*`. Y `angle_unittests --gtest_filter=ComputeDrawCommandRangesTest*`
     para 0002.
4. Si algo se ve mal o deja de actualizarse, quitar solo 0001 y avisar a MOTOR con el caso.

## Solo lectura: propuestas sin código

### `objc_release` en `endEncodingImpl` (8,1 %)
- **Qué es:** sin ARC, cada objeto que se graba en el flujo intermedio lleva `retain` y se libera con `release` al
  reproducirlo (`[x ANGLE_MTL_RELEASE]` en cada `*Cmd`). En estado estable, por dibujo, al menos el buffer de índices de
  `drawIndexed`, más los `setBuffer`, `setTexture` y `setSamplerState` que cambien. El driver de AMD libera además cosas
  propias dentro de las llamadas reproducidas.
- **0001 ya quita** los `retain`/`release` de texturas y samplers que entraban por cambios de caché, aunque eran pocos:
  la caché del encoder ya los filtraba antes de grabar.
- **Propuesta:** no retener por comando los recursos que ya retiene el command buffer. `setReadDependency(ResourceRef)`
  mete el `id` en `mResourceList` con un `retain` por command buffer, que vive hasta que se completa. Lo mismo vale para
  los objetos de las cachés que duran lo que el display: pipeline, depth-stencil y sampler states. Se grabarían
  `__unsafe_unretained` y la reproducción no los liberaría.
- **Ganancia:** la parte de ANGLE del `objc_release` y del `objc_retain` al grabar. Antes hace falta un `sample` que
  separe quién llama a `objc_release`, ANGLE (`DrawIndexedCmd`…) o el driver.
- **Riesgo:** medio. Si un recurso se graba sin pasar por `setReadDependency` (p. ej. `setBuffer` con un `id` crudo o los
  `label`), hay uso tras liberar. Hay que auditar cada `push([… ANGLE_MTL_RETAIN])` (unos 15 sitios). Upstream no lo
  tiene.

### Validar y despachar (cambio 7, ≈8 %)
- **Dónde está el coste:** `gl::ValidateUniform` 3,5 % propio, `GL_DrawElements` 2,5 %, `DoCommandsImpl` 2,5 %, y
  `glUniform3fvFn`/`HandleUniform1f` ≈2,4 % cada una. No está ni en el TLS ni en el cerrojo.
- **Lo que no se toca:** la validación de ANGLE es la frontera de seguridad frente al renderer, que no es de fiar. Quitarla
  (`EGL_CONTEXT_OPENGL_NO_ERROR_KHR` para WebGL) **no** es aceptable.
- **Propuesta 1:** un atajo en `ValidateUniform` / `ValidateUniformCommonBase` para el caso repetido: misma ubicación,
  mismo programa y mismo tipo que la llamada anterior, guardado en el contexto y vaciado al cambiar de programa o al
  re-enlazar. Ganancia: parte del 3,5 %. Riesgo: medio, por ser validación.
- **Propuesta 2:** saltarse la doble indirección del decodificador para uniformes (`Handle*` → `Do*` → `GLApi` → punto de
  entrada) llamando directamente a la función de `libGLESv2`. Ganancia pequeña (≈1–2 %), riesgo bajo, pero es Chromium y
  no ANGLE.
- **Recomendación:** no hacer ninguna hasta medir 0001–0004. Si el límite pasa al renderer, el cambio 7 deja de importar.
