# PGO de Google en Mojave (INVESTIGACIÓN-MOTOR-9, 06-11-2026)

Problema: `oficial-8-pgo`, compilada con el perfil de Google, mejora mucho en la MacPro7,1 con Sequoia
(Speedometer 15,8 → 19,6, MotionMark 2585 → 3244). En la MacPro6,1 con Mojave va muy lenta, se cuelga en
React-stockcharts-SVG y da «error al cargar el manifest».

**Conclusión:**
- El perfil de Google no vio nunca ejecutarse la ruta de dibujo que usa Mojave: Skia Ganesh GL sobre ANGLE/Metal.
  En Sequoia esa ruta no se usa, porque Chrome dibuja con Graphite.
- Con PGO, el compilador marca esas funciones como `cold`: les recorta el inlining y las optimiza para tamaño.
- El culpable no es la capa Mojave de flynk-b1d. Es código de serie de Chromium que solo se ejecuta en Mojave, porque
  allí apagamos Graphite. Las funciones que tocamos nosotros pierden el perfil, pero no las hace frías, y casi ninguna
  está en una ruta caliente.
- Esto explica la lentitud del dibujado. **Un cuelgue y el error de manifest no los explica**: optimizar para tamaño
  ralentiza una parte, no bloquea. Esos dos síntomas siguen abiertos (H5) hasta tener las medidas en local de LOCAL-19.

## 1. Qué hace clang con el código que el perfil no vio

Las fuentes son de llvm-project, `main` salvo que se indique `release/21.x`. El perfil es de instrumentación IR (bit
`VARIANT_MASK_IR_PROF` en la cabecera).

- **Función con todos los contadores a 0:**
  - `PGOInstrumentation.cpp`: `F.setEntryCount(0)` y la función entra en `ColdFunctions`.
  - Después recibe **`F->addFnAttr(Attribute::Cold)`** (líneas 2144-2148 y 2224-2241).
  - Las funciones con perfil caliente reciben `InlineHint`.
- **Inlining** (`InlineCost.cpp`: 64-89 y 2063-2101):
  - El umbral normal es 225; con `-inlinehint-threshold=360` de Chromium en ThinLTO, 360 para las calientes.
  - Una llamada fría o un callee frío usa **45**, sin bonificaciones.
  - El código frío casi no se inlinea, ni hacia dentro ni hacia fuera.
- **PGSO, optimizar para tamaño guiado por perfil** (`SizeOpts.cpp`: 18-35 y 51-89; `pgso=true` por defecto):
  - Con un perfil de *working set* grande, todo lo que no esté caliente al percentil 95 (`pgso-cutoff-instr-prof=950000`)
    se trata como `optsize`.
  - El perfil de Chrome **lo es**: el corte 990000 tiene 107.343 contadores, y el umbral está en 12.500
    (`ProfileSummaryBuilder.cpp`: 33-52).
  - Con `optsize` se desenrolla menos (`LoopUnrollPass.cpp`: 129-138, `OptSizeThreshold`).
  - Y se vectoriza peor (`LoopVectorize.cpp`: 7404-7413, sin comprobaciones en tiempo de ejecución, sin epílogo ni
    *tail folding*).
- **Función sin perfil** (hash distinto porque cambió su flujo de control, o función nueva):
  - `handleInstrProfError` avisa con «count discarded» y **no anota nada** (`PGOInstrumentation.cpp`: 1262-1312).
  - Chromium silencia ese aviso con `-Wno-profile-instr-out-of-date` y `-Wno-backend-plugin` (`build/config/compiler/pgo/BUILD.gn`: 158-173).
  - La función no recibe `cold`, porque `isFunctionColdInCallGraph` exige contadores (`ProfileSummaryInfo.h`: 163-185).
  - En cambio, PGSO con *working set* grande sí la trata como no caliente y la optimiza para tamaño. Esto se deduce
    del código de `ProfileSummaryInfo.h`: 298-323 y no está probado.
- **En Mac no hay separación de código frío:**
  - Mach-O ignora el prefijo `.text.unlikely` (`TargetLoweringObjectFileImpl.cpp`: 1473-1542).
  - `-fsplit-machine-functions` solo funciona con ELF (`release/21.x`, `clang/lib/Driver/ToolChains/Clang.cpp`: 6241-6246).
  - `hot-cold-split` viene apagado.
  - El efecto se queda en inlining y `optsize`; no hay saltos a una sección lejana.
- **Chromium 156 en Mac** (`build/config/compiler/pgo/*`, `compiler.gni`):
  - `chrome_pgo_phase=2` es el valor por defecto en las compilaciones oficiales, con ThinLTO.
  - Añade `-enable-ext-tsp-block-placement=1`.
  - `-pgo-cold-func-opt=minsize` va solo en Android y Fuchsia; en Mac los fríos usan las reglas de arriba, sin `minsize`.
- **Qué perfila Google** (`tools/pgo/generate_profile.py`: 1180-1281):
  - Speedometer 3, JetStream 3 y `system_health.common_desktop`.
  - En darwin, además, MotionMark normal y MotionMark con `SkiaGraphite`.
  - En Mac 156, `kSkiaGraphite` está activado por defecto (`gpu/config/gpu_finch_features.cc`: 383-389).
  - Ninguna pasada dibuja con Ganesh.
- **Documentación de clang** (UsersManual, sección PGO, `release/21.x` 3115-3124): «As you make changes to your
  code, clang may no longer be able to use the profile data. It will warn you when this happens.»

## 2. Datos del perfil

- **Perfil:** `chrome-mac-8078-1793642157-09366e2d…-4f610018….profdata` (321 MB). Es el de `chrome/build/mac.pgo.txt`,
  tanto en el tag 156.0.8078.90 como en la punta de `flynk-b1d`. Se bajó de
  `storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/`.
- **Formato:** índice v14. El `llvm-profdata` 18 de Ubuntu no lo lee, así que se leyó con un lector propio en Python
  (apéndice).
- **Validación del lector:** recorre el fichero entero sin errores y saca 1.177.903 registros, frente a los 1.178.927
  que declara el resumen.
- **Umbrales del resumen:**
  - Caliente (corte 990000): contador ≥ 25.481.
  - PGSO (corte 950000): ≥ 228.419.
  - Frío (corte 999999): ≤ 4.

Porcentaje de funciones con todos los contadores a 0. Los grupos se definen por el nombre *mangled*:

| Grupo | funciones | % a 0 |
|---|---|---|
| **Todo el perfil** | 1.177.903 | 77,6 % |
| **Skia Ganesh GL (`GrGL*`)** | 821 | **100 %** |
| Skia Ganesh (`Gr*`, `skgpu::ganesh`)¹ | 4.837 | 98,6 % |
| `GrTriangulator`, `ganesh::AtlasPathRenderer`, `TessellationPathRenderer`, `PathTessellator`, `GrGLSLProgramBuilder` | 162 | **100 %** |
| Skia Graphite (`skgpu::graphite`) | 2.389 | 40,9 % |
| Skia común (`Sk*`) | 15.765 | 70,6 % |
| ANGLE back-end Metal (`rx::mtl`, `*Mtl`)² | 1.479 | 55,2 % |
| ANGLE back-end GL (`rx::*GL`), sin uso en B1d | 691 | 90,6 % |
| ANGLE front-end (`gl::`) | 6.648 | 80,2 % |
| ANGLE traductor (`sh::`) | 2.285 | 65,0 % |
| V8 (`v8::internal`) | 74.158 | 60,3 % |
| Blink (`blink::`) | 270.406 | 76,9 % |
| Blink `LayoutSVG*` | 626 | 51,6 % |
| cc | 6.597 | 39,4 % |
| viz | 10.568 | 52,2 % |

¹ Las 69 funciones con cuenta del grupo Ganesh son tipos compartidos que usa Graphite (`GrBackendSemaphore`,
`GrPromiseImageTexture`…). No hay ninguna función de dibujo de Ganesh con cuenta.
² Solo tienen cuenta la inicialización y las tablas de formatos. El dibujo está frío: `rx::ContextMtl::drawElements`
da 0, `drawArrays` 1, `RenderCommandEncoder::draw` 2, y las entradas `GL_DrawElements*`, `GL_TexSubImage2D` dan 0.

Ejemplo de la ruta de SVG:

| Función | Contador de entrada |
|---|---|
| `blink::LayoutSVGShape::Paint` | 405.965 |
| `SkCanvas::drawPath` | 866.546 |
| `skgpu::graphite::Device::drawPath` | 840.774 |
| `skgpu::ganesh::Device::drawPath` | **0** |
| `skgpu::ganesh::SurfaceDrawContext::drawPath` | **0** |

En Mojave, Blink y el `SkCanvas` del renderer están calientes y bien optimizados. Las mismas llamadas, en el proceso
de GPU, entran en Ganesh y luego en ANGLE, que el perfil marca como frío.

**Funciones de flynk-b1d.**
- Método: 104 funciones sacadas de los *hunks* de `git diff 23b0e24a..flynk-b1d`, en los 92 `.cc`/`.mm` (sin contar
  los rolls de ANGLE y Dawn).
  - 49 tienen todos los contadores a 0 en la 156 de serie.
  - 32 no aparecen, porque se *inlinearon* o son nuevas.
  - 23 tienen cuenta, casi todas de arranque o configuración (< 2.000): `GetCPUType`, `IsSkiaGraphiteEnabled`,
    `ParseGpuPreferences`, `InitializeGpuModes`…
  - El emparejamiento es por nombre, así que es aproximado.
- Excepciones con cuenta alta:
  - **`SpinningMutex::LockSlow`** de PartitionAlloc: 19.035. Es la ruta lenta del cerrojo con contención.
  - **`IOSurfaceSetColorSpace`**: 9.507.
- Al cambiar su flujo de control, estas funciones **pierden su perfil**: se compilan sin datos y no como frías. Rinden
  más o menos como sin PGO; PGSO puede optimizarlas para tamaño, algo que no está probado.
- `LockSlow` en 10.14 no usa `OS_UNFAIR_LOCK_ADAPTIVE_SPIN`. Esa diferencia existe igual con PGO que sin él, así que
  no explica la diferencia entre `oficial-8` y `oficial-8-pgo`.

## 3. Hipótesis

| | Veredicto con los datos del perfil | Falta |
|---|---|---|
| **H1**: los caminos de 10.14 de flynk-b1d salen fríos | **Débil.** Sus funciones pierden el perfil (no reciben `cold`) y casi ninguna es caliente | `sample` de la 6,1: ¿aparece `LockSlow` arriba? |
| **H2**: Skia Ganesh frío | **Muy probable para la lentitud de dibujo.** Ganesh GL, la teselación y los *path renderers* están al 100 % a 0, así que reciben `cold`, inline 45 y `optsize` | `sample` del proceso de GPU con `Gr*`/`skgpu::ganesh` arriba; prueba con Ganesh en la 7,1 |
| **H3**: ANGLE | **Probable, en la misma cadena que H2.** El dibujo de `ContextMtl` y las entradas `GL_*` están frías porque Chrome en Mac apenas usa ANGLE (Graphite va por Dawn). Afecta a todo, no solo a nuestros parches de Metal 2.1 y AMD | ídem |
| **H4**: V8 | **Sí: el JIT no cambia y el runtime C++ está perfilado** (Speedometer y JetStream sí entran en el perfil). No es lo que en Mojave se ejecuta distinto | — |
| **H5**: red u otra cosa | **Necesaria para el cuelgue y el manifest.** `optsize` y `cold` hacen el código más lento, no lo bloquean. Un «colgado» puede ser una lentitud extrema (stockcharts dibuja miles de *paths*) o una red que falla (ERR_HTTP2_PROTOCOL_ERROR en browserbench.org) | Medidas en local (paso 0 de LOCAL) |

**Sobre la hipótesis de Titín:** acierta en que es algo que solo pasa en Mojave, pero no está en «nuestra capa». Es la
ruta de serie, Ganesh/GL + ANGLE, que nuestra capa activa en Mojave y que Google no perfila.

**La prueba que lo separa:** en la 7,1 (Sequoia), arrancar `oficial-8` y `oficial-8-pgo` con `--disable-skia-graphite`.
Así Ganesh corre sin ninguna guarda de 10.14.
- Si con PGO cae MotionMark o el SVG → H2/H3. La capa Mojave queda descartada.

## 4. Pasos para LOCAL en la 6,1 (enviados a COORDINACIÓN-29 el 06-11)

0. Servir Speedometer 3 y JetStream en local (LOCAL-19).
   - Si en local `oficial-8-pgo` no se cuelga y no da el error de manifest, el cuelgue era H5.
1. Lanzar cada compilación con `--user-data-dir` limpio y `--enable-logging=stderr`, guardando la salida en un `.log`.
   Guardar `chrome://gpu` de cada una: las dos tienen que decir GaneshGL y el mismo ANGLE Metal.
2. Manifest: abrir DevTools (consola y red) antes de cargar la página. Apuntar el mensaje exacto, la URL y el código
   HTTP. Repetir con `--disable-http2`.
3. Durante el cuelgue en React-stockcharts-SVG, y en TodoMVC-React como control, en cada compilación:
   - `sample <pid> 10 -file …` del renderer, de la GPU y del navegador (5 s).
   - `top -l 3`.
   - Anotar qué proceso está al 100 %.
4. Speedometer en local: 3 pasadas por compilación, con el desglose por subprueba.
   - Si solo caen las de SVG/canvas → H2.
   - Si caen todas → otra causa.
5. MotionMark 1.3 en local, con el desglose por prueba.
6. La prueba de la 7,1 con `--disable-skia-graphite` de la sección 3.
7. Mandar los `sample`, los logs, `chrome://gpu` y las tablas. Con los `sample` se ve si el tiempo se va a
   `Gr*`/`skgpu::ganesh`, a `rx::`/`gl::`, a funciones de flynk-b1d o a V8.

## 5. Remedios, de menos a más trabajo

En cada caso, primero se confirma con los `sample` de la sección 4.

1. **Quitar PGO a Skia Ganesh y ANGLE** (`configs -= [ "//build/config/compiler/pgo:default_pgo_flags" ]` en sus
   objetivos de GN; 1 hito).
   - Esos módulos se compilan como sin PGO: sin resumen de perfil, así que sin PGSO ni `cold` propios.
   - Conserva la ganancia en Blink y V8.
   - Dos dudas sin verificar:
     - Con ThinLTO, ¿PGSO trata como no calientes las funciones sin perfil al *inlinearlas* en módulos con perfil?
     - Graphite pierde PGO también en Monterey y versiones posteriores (efecto menor; Monterey no tiene garantía).
   - Hay que elegir bien los objetivos: Skia es un solo objetivo con Ganesh y Graphite dentro, así que quizá haga falta
     separar los `sources` de Ganesh.
2. **Variante global barata: `-mllvm -pgso=false`** (1 hito, un solo arg).
   - Quita `optsize` a todo lo no caliente, pero mantiene `cold` y el inline a 45 en Ganesh.
   - Arreglo parcial: sirve como experimento A/B para medir cuánto pesa cada mecanismo.
3. **PGO solo en V8 y Blink** (1-2 hitos).
   - Es lo contrario del remedio 1: más sencillo de razonar, pero pierde la ganancia de cc, viz y net en Sequoia.
4. **Perfil propio en Mojave** (3-4 hitos el primero, 1 por cada versión nueva de Chrome).
   - Compilar con `chrome_pgo_phase=1` en la 7,1.
   - En la 6,1, ejecutar `tools/pgo/generate_profile.py` (docs/pgo.md): Speedometer 3, JetStream 3 y MotionMark, más
     un recorrido SVG/canvas.
   - Fusionar con el de Google: `llvm-profdata merge --weighted-input=…` (lo admite `generate_profile.py`: 384-398 y
     1024-1044). Hay que usar el `llvm-profdata` de la propia toolchain de Chromium (formato v14).
   - Calienta Ganesh y ANGLE y conserva lo de Google.
   - Riesgos:
     - Un perfil hecho con poca carga calienta de más lo que se midió.
     - Hay que rehacerlo en cada subida de Chromium, porque los hashes cambian.
     - El binario instrumentado tiene que funcionar en Mojave.
5. **No usar PGO en las compilaciones para Mojave** (0 hitos).
   - Mojave es el objetivo garantizado, así que en la práctica sería quitar PGO a la 3.0.0 entera. Se pierde lo ganado
     en Sequoia, aunque deja de ser un riesgo.
   - Es la opción de reserva si 1 o 2 no recuperan el SVG.

**Recomendación:** medir primero (secciones 3 y 4). Si se confirma H2/H3, probar el 2 como A/B rápido y aplicar el 1. El
4 solo merece la pena si después de aplicar el 1 sigue habiendo distancia en Mojave.

## Apéndice: lector del perfil (v14, IR)

```python
# python3 -I dump.py perfil.profdata salida.tsv  → nombre, nº contadores, entrada, máx, suma
import sys, struct, mmap
m = mmap.mmap(open(sys.argv[1], 'rb').fileno(), 0, access=mmap.ACCESS_READ)
u = lambda o: struct.unpack_from('<Q', m, o)[0]
out = open(sys.argv[2], 'w'); hashoff = u(32)            # cabecera: 9 × u64
o = 72; nf, nc = u(o), u(o + 8); o += 16 + nf * 8 + nc * 24  # resumen
while o < hashoff:                                         # cadenas del OnDiskChainedHashTable
    cnt = struct.unpack_from('<H', m, o)[0]; o += 2
    for _ in range(cnt):
        kl, dl = u(o + 8), u(o + 16); o += 24              # hash, long. clave, long. datos
        name = m[o:o + kl].decode('utf-8', 'replace'); o += kl
        d, end = o, o + dl; o = end
        while d < end:                                     # un registro por hash de CFG
            k = u(d + 8); d += 16
            cs = struct.unpack_from('<%dQ' % k, m, d); d += 8 * k
            nb = u(d); d += 8 + 8 * nb                     # bitmap (MC/DC)
            ex = u(d); d += 8 + 8 * ex                     # campo añadido en v13/v14
            d += struct.unpack_from('<I', m, d)[0]         # ValueProfData (TotalSize)
            out.write('%s\t%d\t%d\t%d\t%d\n' % (name, k, cs[0] if k else 0, max(cs, default=0), sum(cs)))
```
