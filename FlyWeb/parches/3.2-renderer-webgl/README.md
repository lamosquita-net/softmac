# FlyWeb 3.2: hilo principal del renderer en WebGL, más barato

MOTOR-45, 12-11-2026, por encargo de Titín (vía COORDINACIÓN-39). Fuente: [`../../docs/multihilo-multigpu.md`](../../docs/multihilo-multigpu.md)
§9.2 y §9.6, «Lo que no depende de M2».

**Nada compilado ni probado en un Mac.** Se compilan con E1/M1/M2, después de la 3.2. Lo único que se ha ejecutado son
las pruebas de `sin`/`cos` de [`trig/`](trig/), en Linux (Xeon de la nube) y con LLVM libc suelta.

**Bases** (las de la 3.1.0 publicada):

| Parche | Árbol | Base (ls-remote / DEPS) | `git am` |
|---|---|---|---|
| `0001`, `0002` | chromium, fork `lamosquita-net/chromium` | `seg/3.0.2` **502e3c5b85** (= src de la 3.1.0) | limpio; árbol `ef5a09d27e` |
| `0003` | V8 | **182f13107b** (`v8_revision` de `seg/3.0.2`, 15.6.75.51) | limpio; árbol `8feae0cfd6` |

brave-core `local/3.1` (`fc9389773fe`) no toca ninguno de estos ficheros (ni `patches/`, ni `chromium_src/`, ni `patches/v8`).
Para meter `0003` en brave-core hay que pasarlo a `patches/v8/src-base-ieee754.cc.patch`.

## Resumen

Columnas de la tabla de §9.2 (Aquarium, 15 000 peces, 6,1; % de las muestras activas del hilo principal del renderer).

| Parche | Línea de §9.2 | 3.0.0 / c31 t4 / serie | Ganancia esperada | Riesgo |
|---|---|---|---|---|
| `0001` DrawingBuffer sin `FeatureList` por dibujo | `base::FeatureList` | 5,3 / 4,7 / 5,0 % | **casi toda la línea**: unos 5 puntos | muy bajo |
| `0002` tipo de los argumentos WebGL por etiqueta | ≈ ⅕ de «Enlaces WebGL» (`HasInstance`) | ≈ 5,8 / 5,1 / 4,5 % | **3–4 puntos** [S] | medio: toca la comprobación de tipos de los enlaces. **Que lo revise SEGURIDAD-PORTES** |
| `0003` `LIBC_MATH` de upstream (V8 `fe6631925621`) | `Math.sin`/`cos` | 22,4 / 21,2 / 23,1 % | **≈ 0 en Aquarium**; solo acelera Inf, NaN, 0 y `log*` | muy bajo: mismos bits (comprobado) |

**Ojo con lo que se espera en fps.** En la 6,1, Aquarium está limitado por el hilo principal del proceso de GPU
(`CrGpuMain` al 92 %, renderer al 60 %; `rendimiento-3x.md` §2.1). Estos parches abaratan el renderer, así que
**bajan CPU, pero no suben los fps mientras el límite siga en `CrGpuMain`**. Con la 3.1 (parches de ANGLE), Aquarium
pasó de ≈40 a 41,9 fps de mediana; no se sabe si el límite se ha movido. Hay que medir los fps y el `ps -M` de los dos
hilos (renderer y `CrGpuMain`).

**`Math.sin`/`cos`: no hay ninguna implementación más rápida y exacta que portar.** V8 15.6 ya usa la de LLVM libc, que
es la más reciente de upstream y está correctamente redondeada. Las más rápidas (fdlibm, que es la que usaba V8 antes,
glibc o la de Apple) no dan siempre el resultado correctamente redondeado, así que cambiarían los resultados. Hay dos
ideas que dan los mismos bits; las he medido y no las propongo para la 3.2 (detalle en la sección de `0003`).

## 0001: `DrawingBuffer` sin consultar `FeatureList` en cada dibujo

**Dónde.** `drawArrays`/`drawElements` → `DrawWrapper` → `OnBeforeDrawCall` → `ClearIfComposited`. Cuando no hay un
framebuffer propio enlazado (el caso de Aquarium), esta función llama a `DrawingBuffer::EnsureBuffers()` en **cada
dibujo**, y esta hace dos consultas:
- `EnsureBackColorBuffer()`: `IsEnabled(kWebGLDiscardBackBuffer)`;
- `EnsureMSAADepthStencilBuffers()`: `IsEnabled(kWebGLDeleteBuffersInBackground)`.

Cada `FeatureList::IsEnabled` es una llamada fuera de línea que registra el acceso con una operación atómica y desempaqueta
el estado guardado. Por pez se hace un dibujo, así que son unos 1,2 M de llamadas por segundo a 40 fps. Lo de
`rendimiento-3x.md` §2.1 («`IsFeatureEnabled` … desde `OnBeforeDrawCall` → `ClearIfComposited`») sale de aquí. Upstream
sigue igual en `main` y en la 158.0.8127.40.

**Cambio.** Se miran primero los miembros y la consulta va al final de la condición. `back_buffer_discarded_` solo lo
pone `DiscardBackBuffer()`, y los búferes MSAA y de profundidad solo faltan si se descartaron con la pestaña oculta.
Así, en régimen estable no se hace ninguna consulta. Las dos características vienen apagadas de serie y no son
`RuntimeMutable`.

**Por qué no cambia nada.** Cada condición sigue siendo la misma conjunción de términos sin efectos secundarios, solo
evaluada en otro orden. La única diferencia observable es el histograma `Variations.FeatureAccess`, que se registra
una sola vez por característica y que FlyWeb no envía.

**Pruebas.**
- `blink_platform_unittests --gtest_filter='DrawingBuffer*'`.
- Conformidad WebGL 1 y 2 (`content/test/gpu`, `webgl_conformance`).
- WPT `webgl/` y `html/canvas/offscreen/`.
- A mano, con `--enable-features=WebGLDiscardBackBuffer,WebGLDeleteBuffersInBackground`: Aquarium en una pestaña,
  ocultarla 10 s y volver. Tiene que seguir dibujando, sin `CHECK` en `EnsureBackColorBuffer`.

## 0002: comprobar por la etiqueta el tipo de los argumentos WebGL

**Dónde.** Los métodos calientes ya llevan `[NoAllocDirectCall]` (llamada rápida de V8; Aquarium hace 4 `uniform*` y un
`drawElements` por pez). En esa vía, el `WebGLUniformLocation?` se convierte con
`NativeValueTraits<IDLNullable<T>>::ArgumentValue`, que llama a `V8PerIsolateData::HasInstance`. Esa función:
- busca el `WrapperTypeInfo` en una tabla hash, y lo busca dos veces si el valor no es una instancia;
- llama a `v8::FunctionTemplate::HasInstance`, que recorre la cadena de plantillas.

Upstream no lo ha cambiado: en la 158 y en `main`, `v8_interface_bridge.h` aún tiene el TODO de japhet que dice que
`Unwrap` ya comprueba el tipo.

**Cambio.** Es un atajo que cada tipo tiene que pedir (`static constexpr bool kWrapperTagTypeCheck = true`; lo piden
`WebGLObject`, con todas sus subclases, y `WebGLUniformLocation`). Si el valor es un objeto envoltorio de la API
(`v8::Object::IsApiWrapper()`), se usa `ToScriptWrappable<T>()`. Esta función ya comprueba que la etiqueta guardada en
la tabla de punteros del heap de C++ cae en el rango de `T`, que incluye sus subclases, y si no cae devuelve `nullptr`.
Si el resultado es `nullptr` por cualquier motivo, se sigue por el camino de siempre (`HasInstance`). Por eso `null`,
`undefined`, los tipos ajenos y los errores (`TypeError`) se comportan exactamente igual que antes.

**Por qué es seguro.**
- Solo se activa con compresión de punteros (`V8_COMPRESS_POINTERS`, la de serie en x64). Sin ella, `Unwrap` lee el
  puntero en bruto y no comprueba la etiqueta (`v8-sandbox.h`, `ReadCppHeapPointerField`).
- **No se puede quitar `HasInstance` sin más.** En Release, `Unwrap` lee el campo sin mirar si el objeto es un
  envoltorio: con un objeto JS cualquiera leería una propiedad como si fuera el índice de la tabla. Por eso hace falta
  `IsApiWrapper()`. Cubre `JSAPIObjectWithEmbedderSlots` y `JSSpecialObject`, y los dos tienen `cpp_heap_wrappable`
  justo detrás de la cabecera (`js-objects.tq`).
- Blink envuelve cada objeto con el `this_tag` del `WrapperTypeInfo` con cuya plantilla lo creó, así que una etiqueta en
  el rango de `T` implica una plantilla de `T` o de una subclase, que es lo que responde `HasInstance`. La etiqueta vive
  fuera del sandbox de V8; el mapa en el que se basa `HasInstance` está dentro. Ante un atacante que ya corrompe el heap
  de V8, la comprobación por etiqueta no es más débil.
- El caso en que `HasInstance` hace algo distinto es el `JSGlobalProxy` (mira el objeto global de detrás y rechaza los
  separados). Ninguno de los tipos que piden el atajo es un global.

**Lo que no he tocado** (el resto de «Enlaces WebGL», ≈ ⅘):
- la transición de la llamada rápida;
- el `HandleScope` que abren los stubs cuando hay argumentos de objeto (el camino lento lo necesita, porque `Eternal::Get`
  crea un `Local`);
- la validación de Blink (`ValidateUniformLocation`, que ya es mínima);
- la serialización de `GLES2Implementation`.

Las conversiones de `Float32List` (`[PassAsSpan]`) ya son ligeras en la 156: un array pequeño en el heap se copia a
almacenamiento en línea, sin crear el `DOMFloat32Array`. Lo que cambió en 157–158 en `native_value_traits_impl.h` es el
límite de tamaño y los búferes compartidos, no el coste.

**Ganancia.** La comprobación de tipos es ≈ ⅕ de los enlaces según §9.2. El atajo quita la tabla hash y la llamada a
`FunctionTemplate::HasInstance`, y añade `IsApiWrapper()` (otra llamada fuera de línea, pero corta). Calculo 3–4 puntos
[S]; sin perfil nuevo no se puede afinar.

**Pruebas.**
- `blink_unittests --gtest_filter='*NativeValueTraits*:*V8Binding*'`.
- Conformidad WebGL. Sobre todo las de argumentos mal tipados: `conformance/misc/type-conversion-test.html`,
  `conformance/misc/invalid-passed-params.html`, `conformance/more/functions/uniformfBadArgs.html`, `uniformiBadArgs.html`,
  `conformance/misc/object-deletion-behaviour.html` y `conformance2/misc/uninitialized-test-2.html`.
- WPT `webgl/idlharness.any.js` (tipos de las interfaces).
- A mano, en la consola, cada uno tiene que lanzar `TypeError`, igual que en la 3.1:
  - `gl.uniform1f({}, 1)`;
  - `gl.uniform1f(Object.create(WebGLUniformLocation.prototype), 1)`;
  - `gl.uniform1f(gl.createBuffer(), 1)` (otro tipo WebGL, porque las etiquetas de `WebGLBuffer` y
    `WebGLUniformLocation` no se solapan);
  - `gl.bindBuffer(gl.ARRAY_BUFFER, document.body)`.

  Además, una `location` de otro contexto WebGL da `INVALID_OPERATION`, sin `TypeError`.
- Una extensión con content script (mundo aislado) que llame a WebGL con objetos creados en ese mundo.

## 0003: `LIBC_MATH` de upstream, y por qué no hay más en `sin`/`cos`

**Lo que hay en la 156.** `base::ieee754::sin`/`cos` = `LIBC_NAMESPACE::shared::sin`/`cos` de LLVM libc (revisión
`b8b28272d32b`), en una sola unidad (`src/base/ieee754.cc`). Hacen la reducción del argumento, evalúan el seno y el
coseno del resto y pasan la prueba de Ziv; solo si falla, toman la vía precisa.

**El parche** es la selección (cherry-pick `-x`) de V8 `fe6631925621` (Nico Weber, 02-11-2026, «No behavior change»):
`#define LIBC_MATH (NO_ERRNO | NO_EXCEPT | ASSUME_ROUND_NEAREST_ONLY)` antes de los includes. V8 nunca lee `errno`
ni los indicadores de excepción, y siempre corre redondeando al más cercano. Las tres macros existen en la revisión de
LLVM libc de la 156 (`src/__support/macros/optimization.h`).
- **Mismos bits, comprobado:** 109 990 318 entradas, con y sin las macros (`trig/libc-math-flags.cc`). Son patrones de
  bits al azar (todos los exponentes) y uniformes en ±10⁻³ … ±10⁹. Inf, NaN, ±0 y subnormales, iguales.
- **Ganancia:** en `sin`/`cos` normales, ninguna (upstream: «unchanged»; aquí, 5 tandas intercaladas sin FMA, 16,8–19,0 ns
  por llamada con y sin las macros, diferencias de ±3 % en los dos sentidos). Acelera Inf, NaN, 0 y fuera de dominio (2–5 veces) y `log*` (4–7 %). Va porque es upstream, no cuesta nada
  y deja la línea más cerca de la 15.9.

**Ideas medidas y descartadas para la 3.2** (prototipos y banco en [`trig/`](trig/); `run.sh <ruta de llvm-libc>`
compila con clang en segundos, sin tocar FlyWeb):

1. **Memo perezosa de `sin`/`cos`.** Al calcular `sin(x)` se guarda la reducción (k, sin y, cos y, error), por hilo y con
   las dos últimas. Un `cos(x)` con el mismo `x` solo hace la combinación final. Por qué tiene sentido:
   - Aquarium lo pide. Con `fishXClock = fishZClock = 1` (los valores de serie), cada pez hace `sin(A)`, `sin(B)`, `cos(A)`,
     `sin(A')`, `sin(B')` y `cos(A')`: 2 de cada 6 llamadas repiten argumento. Es el patrón de toda matriz de rotación
     (three.js, gl-matrix).
   - El JIT no puede fusionarlas: `xClock` y `zClock` son valores distintos que solo coinciden en ejecución. Además, V8
     no tiene `sincos`.

   Resultados:
   - **Mismos bits:** 0 diferencias en 54 M de casos, incluidas mezclas al azar de `sin`/`cos` sobre los mismos valores.
     Cuando falla la prueba de Ziv, llama a la referencia.
   - **Velocidad, sin FMA (como la 6,1), fijado a una CPU:** Aquarium −3 a −10 %, pares `sin`+`cos` −10 a −15 %, solo `sin`
     entre −1 y +16 %. Con lo que pesa `ieee754`, son unos 2 puntos del hilo en el mejor caso.

   **No la propongo:** gana poco y puede perder en código que solo llama a `sin`. Además, en macOS `thread_local` dentro
   del framework va por `__tlv_get_addr`, que es más caro que en Linux. Solo valdría si `run.sh` en la 6,1 diera ≥ 10 % en
   Aquarium y ≤ 2 % de pérdida en solo `sin`.
2. **Despachar la versión con FMA donde haya FMA.** Una segunda copia compilada con `-mfma`, en otro `LIBC_NAMESPACE`
   para no violar la ODR, y elegida por CPUID. En el patrón de Aquarium pasa de ≈ 19 a ≈ 12 ns por llamada (−35 %).
   - **No da exactamente los mismos bits:** 9 782 diferencias en 110 M, **todas en `sin(x)` con |x| < 2⁻¹⁰¹⁵**. Ahí la
     versión sin FMA (la que lleva hoy Chrome x64, y FlyWeb) se equivoca en 1 ulp: el producto `x·2⁻⁵⁴` cae en subnormal
     y se redondea dos veces. Fuera de ese rango, iguales. Se arregla mandando |x| < 2⁻²⁶ a la versión sin FMA.
   - **No sirve donde importa:** la 6,1 (Ivy Bridge-EP), la 5,1 (Westmere), el Mac mini y el MacBook Pro de 2012 no tienen
     FMA. Solo ganarían la 7,1 y los portátiles de 2013 en adelante.
   - Lleva código VEX (solo se ejecuta tras CPUID; la regla de AVX prohíbe *exigirlo*, no despacharlo).

   Lo dejo como opción si M1/M2 muestran el renderer como límite en máquinas con FMA.

**Pruebas de `0003`.**
- V8: `unittests --gtest_filter='Ieee754*'`.
- mjsunit: `math-*`, `sin-cos.js`, `regress/regress-crbug-*` de `Math`.
- test262: `built-ins/Math/{sin,cos,tan,log*,exp*,atan2}`.

Nada debería cambiar de resultado.

## Para LOCAL (cuando toque, tras la 3.2)

1. Chromium: `git am 0001-*.patch 0002-*.patch` sobre `seg/3.0.2` (o sobre la rama de la 3.2 si ya existe; ninguno de
   los dos ficheros cambia en `seg/3.0.2` frente a la .98).
2. V8: `0003` como `patches/v8/src-base-ieee754.cc.patch` en brave-core, o con `git am` en `v8/`.
3. Medir en la 6,1 con la batería de §9.6 (M2): Aquarium 15k (fps y `ps -M` del renderer y de `CrGpuMain`), y `sample`
   del renderer pasado por `reparto-renderer.py`. Se espera que la línea de `FeatureList` caiga a ≈ 0 y que «Enlaces
   WebGL» baje unos 3–4 puntos. Por separado (un parche cada vez) si hay tiempo, como con `3.1-angle`.
4. Pruebas de cada parche, arriba. **0002, antes de producción: revisión de SEGURIDAD-PORTES.**
