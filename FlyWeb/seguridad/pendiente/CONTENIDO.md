# Seguridad pendiente: para la siguiente versión de FlyWeb

**Decisión de Titín (19-11-2026, vía COORDINACIÓN-51):** la 3.1.4 build 47 queda publicada tal cual y **no hay 3.1.5 por
ahora**. Lo que llegó a la rama 8078 después de compilarla espera aquí y entra en **la siguiente versión que salga**:
la próxima tanda de seguridad (Chrome 159) o la 3.2.0, la que llegue antes.

**Si alguno de estos bugs resulta Alto o Crítico, entra en el catálogo KEV de CISA o se explota, se avisa enseguida a
COORDINACIÓN**, que propondrá una 3.1.5 a Titín.

Lo prepara y lo vigila SEGURIDAD-PORTES (desde la -32). Cada arreglo nuevo de la 8078, o de la rama de la 159 cuando
salga, que aplique a Mac se añade aquí con APTO: `chromium/` con número correlativo, `angle/` aparte, y su línea en
`SHA256SUMS`.

## Base

Los dos parches se hicieron y comprobaron sobre los árboles **finales de la 3.1.4** (build 47):

| Repo | Base | Parches de aquí | Árbol resultante |
|---|---|---|---|
| chromium | árbol **`e7162cd585`** (`local/314-adapt` `aaa7d7508d` + `3.1.4/integracion/chromium` 0002–0004; sin el commit de fijación) | `chromium/0001`–`0004` | **`a621f0a668`** (tras `0001`: `2c8ef28a99`; tras `0002`: `39054ebf03`; tras `0003`: `5f0d2b4d3e`) |
| ANGLE | árbol **`db885a866b`** (`f10470c77e` + `3.0.1/angle` 0001–0012 + `parches/3.1-angle` 0001–0004 + `3.1.4/angle` 0001–0003) | `angle/0001` | **`fb21437e81`** |
| brave-core | `local/3.1.4-adapt` **`e660929`** (V8 15.6.75.66 con todos los `patches/v8`) | `brave-core/0001` | **`90134a4e08`** |
| Skia | árbol **`a934afed14`** (gitlink `27c31ca415` + `3.1.4/parte4/skia/0001` + `parte5/skia/0001`) | `skia/0001`–`0003` | **`1ef25455d7`** (tras `0001`: `32f1340fb3`; tras `0002`: `47b14cb49e`) |

Si la siguiente versión cambia de base (p. ej. la 3.2.0 o la 159), **hay que volver a comprobar que aplican**; puede que
la base nueva ya los traiga.

## Rama 8078 después de la build 47

| Commit de la 8078 | Qué | ¿Mac? | Parche |
|---|---|---|---|
| `0ca9887568` (19-11 08:32 UTC) | *Roll* de ANGLE `f4f835734108..0b547a1161fb`: **41c5deee45** y 0b547a1161 | 41c5deee45 sí; 0b547a1161 no (abajo) | `angle/0001` |
| `b243cdcc16` (19-11 09:19 UTC) | «[M156] Disallow creating symbolic links in the macOS network service sandbox» | Sí (solo Mac) | `chromium/0001` |

| `ff774db0a2` (19-11 16:03 UTC) | *Roll* de Dawn `6d772bc9e5c5..062164c3c784` | **No** (abajo; comprobado por LOCAL-19) | — |
| V8 15.6 `9f5c567b62` (.72, 16:01 UTC) | **d68cecd900** [M156] «[debug] Invalidate kNotAssigned assumptions on debugger context stores» | Sí | `brave-core/0001` |
| `a70a3e9f68` (19-11 16:54 UTC) | [M156] [TouchSelection] Notify client after state changes complete (539012373, 564450482) | **No** (abajo) | — |
| `f1f8c18` (17:02 UTC) | *Roll* de V8 `a97fec97ff..9f5c567b62` (= la .72 de arriba) | — | `brave-core/0001` |
| `02642ab` (17:32 UTC) | *Roll* de Skia `b236589b3e12..13d0b32615a3`: **13d0b32615** [M156] «Guard GrBufferAllocPool against overflow» (584003006, merge 587681020) | Sí | `skia/0001` |
| `b526fdd` (17:36 UTC) | [M156] [TouchSelection] Keep drag events in order when a move hides selection (539012373) | **No** (abajo) | — |
| V8 15.6 `c4641b4` (.73) | 020b95f «[test] Speed up regress-584005343 under --gc-stress»: solo una prueba | — | — |
| `5655356`, `b5f8579`, `62cd52a`, `b225b45` (19-11 17:46–18:28 UTC) | Pruebas desactivadas y `TestExpectations` (Glic TSan, WebAppIntegration, webdriver WPT) | — | — |
| `65b1ce5` (19-11 18:04 UTC) | *Roll* de V8 `9f5c567b62..c4641b4cbe` (= la .73 de arriba) y de Skia `13d0b32615a3..16a9d4d9a345`: **16a9d4d9a3** [M156] «[graphite] Ensure depth is reset for draws which overwritesAllPixels» (b/586169898, merge 587681113) | **No** (abajo) | — |
| `9275276` (19-11 19:02 UTC) | *Roll* de Dawn `062164c3c784..218eeee7469d`: solo DXC otra vez | **No** (abajo; comprobado por LOCAL-19) | — |
| `848c24c` (19-11 19:31 UTC) | *Roll* de Skia `16a9d4d9a345..7dc6c0c3424a`: **7dc6c0c342** [M156] «[SkScalerContext] Harden LCD16 and getImage bounds» (b/576955738, merge 585801577) | Sí (abajo) | `skia/0002` |
| `8d177bf` (19-11 19:43 UTC) | [M156] «Drop pending main-frame navigations when tab is added to task» (568905533, merge 584997715), `chrome/browser/actor` | **No** (abajo) | — |
| `64aaf98`, `c20a953` (19-11 21:38–21:40 UTC) | Pruebas desactivadas (omnibox WebUI, WebGPU en Windows) | — | — |
| `b7fd761` (19-11 21:41 UTC) | [M156] «Fix UAF in XRCameraUpdateHelper» (571871625, merge 587680304) | **No** (abajo) | — |
| `e414deb` (19-11 22:09 UTC) | Pruebas desactivadas (sxg-reporting en Linux Debug) | — | — |
| `7cd7567` (19-11 22:32 UTC) | *Roll* de Skia `7dc6c0c3424a..9d96dfeb451c`: **9d96dfeb45** [M156] «[Ganesh] Restrict scissor by dst-read bounds» (584764517, merge 587951190) | Sí (abajo) | `skia/0003` |
| `880ca0428f` (20-11 02:03 UTC) | [M156] «Fix synchronous completion in LocalFileStreamReader» (586656231, merge 587681925) | Sí (abajo) | `chromium/0002` |
| `e2352b4cf6` (20-11 02:19 UTC) | «Incrementing VERSION to 156.0.8078.113» | — | — |
| `6b1211357d` (20-11 03:25 UTC) | [M156] «Guard ImageProcessor against destruction during get_pixels_» (586219154, merge 587225635) | Sí, por prudencia (abajo) | `chromium/0003` |
| `7e5aab9f6a` (20-11 04:26 UTC) | [M156] «Scope InputDeviceCapabilities to target window for focus events» (577377858, merge 587680830) | Sí (abajo) | `chromium/0004` |

**Tag 156.0.8078.112 = `880ca0428f`** (visto el 20-11 a las 03:24 UTC; la rama sigue en .113 desde `e2352b4cf6`, solo
`chrome/VERSION`). Todo lo de `.111` (`c22b215559`, base de la build 47) a `.112` está en esta tabla: con `pendiente/`
entero, la siguiente versión puede declarar .112 (lo decide Titín). DEPS de la .112: V8 `c4641b4cbe`, Skia `9d96dfeb45`,
ANGLE `0b547a1161`, Dawn `218eeee7` (no aplica) y PDFium `8b21800d` (igual que en la .111).

## `angle/0001`: ANGLE 41c5deee45 (bug 574209990, merge 579732514)

Validación del *frontend* de libANGLE (`src/libANGLE/validationES3.cpp`): `glTexSubImage*D` aceptaba `GL_RGB8` y
`GL_RGB565` con `GL_UNSIGNED_INT_2_10_10_10_REV_EXT` sin `GL_OES_required_internalformat` ni
`GL_EXT_texture_type_2_10_10_10_REV`, porque la comprobación de extensiones solo estaba en el camino de creación. Ahora
`ValidES3ExtensionFormatCombination` mira las extensiones en los dos caminos. Se compila y se usa en Mac, con Metal y
con el respaldo GL.

- Aplica limpio con `git am` sobre `db885a866b` y deja el árbol en `fb21437e81`. Mismo `patch-id` que el original
  (`53571bf905`).
- Los campos que usa (`requiredInternalformatOES`, `depthTextureOES`, `depth32OES`, `textureType2101010REVEXT`) existen
  en `gles_extensions_autogen.h`, y los dos únicos llamantes de la función quedan actualizados.
- `validationES3.cpp` pasa `clang++ -fsyntax-only` con el parche.
- La prueba nueva va en `TextureTest.cpp` (`angle_end2end_tests`; no entra en la build del navegador).
- **Gravedad: no se sabe.** El bug está restringido y no aparece en ningún texto público leído (búsqueda web y notas
  de Chrome Releases; los cuerpos de las entradas de escritorio del 27-10, el 29-10 y el 3-11 llegaron vacíos). No hay
  CVE ni consta explotación. Google lo portó a la M156 (*extended stable*). Estimación sin confirmar: Medio.
- **Para LOCAL:** `git am` sobre su ANGLE y volver a fijar el gitlink de `third_party/angle` y `angle_revision` en `DEPS`
  (como con `3.1.4/angle/`). No toca chromium ni brave-core.

**No aplica: 0b547a1161** (bug 550489336, merge 579732851), «GL: Double clear for robust resource init on Mali and
Adreno». Es una solución del backend GL que solo se enciende con GPU Mali o Adreno ≤ 6xx (`renderergl_utils.cpp`:
`isMali || IsAdreno6xxOrOlder`). Ningún Mac lleva esas GPU. Mismo criterio que 569191970 (PowerVR, `3.1.4/CONTENIDO.md` §D).

### Veredicto (regla 17): **APTO**, `angle/0001`

Es el *cherry-pick* de upstream sin cambios. Solo endurece la validación: subir una textura `RGB8`/`RGB565` con el tipo
`2_10_10_10_REV` sin las dos extensiones da `GL_INVALID_OPERATION`, como ya pasaba al crearla. Las combinaciones de ES
3.0 (`GL_UNSIGNED_BYTE`, `GL_UNSIGNED_SHORT_5_6_5`) no cambian. Prueba: `angle_end2end_tests --gtest_filter='*TextureTest*'`
si se compilan; a mano, una página WebGL 2 que dibuje texturas.

## `chromium/0001`: b243cdcc16 (bugs 577326267 y 578671128)

El perfil de sandbox del servicio de red de Mac (`sandbox/policy/mac/network.sb`) prohíbe crear enlaces simbólicos
(`(deny file-write-create (vnode-type SYMLINK))`) en sus directorios de almacenamiento y caché. Lleva el interruptor
`kMacSandboxAllowNetworkSymlinkCreation` (`content/browser/sandbox_parameters_mac.{h,mm}`), **apagado** por defecto,
que se pasa al perfil como `ALLOW_NETWORK_SYMLINK_CREATION`. La constante `kParam…` la genera `generate_params.py` a
partir del `define` del `.sb`.

- Las líneas `+`/`-` son idénticas a las de upstream. Solo se recolocó la del `.h` junto a `kMacSandboxAllowRendererPidinfo`,
  que añadió `3.1.5/chromium/0024` (choque solo de contexto). El `patch-id` cambia por eso (`dc4849b6ac` frente a
  `9563de45a9`).
- Comprobado con `git am`: sobre `local/314-adapt` `aaa7d7508d`, `3.1.4/integracion/chromium` 0002–0004 reproducen sus
  árboles (`25a6269c6b`, `32203fc124`, `e7162cd585`), y este parche deja **`2c8ef28a99`**.
- brave-core no tiene parches ni `chromium_src` para estos ficheros (`local/3.1.4-adapt` `e660929`).
- **Mojave:** `vnode-type` y `file-write-create` ya se usan en `common.sb` y `gpu.sb`, que funcionan en 10.14. `unless`
  es nuevo en nuestros `.sb` (`common.sb` usa `when`, su pareja). Nuestras *variations* son inertes, así que el
  interruptor no se puede encender a distancia: si algo fallara, solo se arregla con otra build.

### Veredicto (regla 17): **APTO**, `chromium/0001`

Riesgo: si el perfil no compilara en 10.14, el servicio de red no arrancaría y no habría red. Por eso la prueba en
Mojave es **obligatoria**:

0. **Antes de compilar**, en Terminal de la 6,1:
   `sandbox-exec -p '(version 1)(allow default)(unless #f (deny file-write-create (vnode-type SYMLINK)))' /bin/ln -s /tmp/a /tmp/sbx-test`
   debe fallar con «Operation not permitted»; con `(unless #t …)` y otro nombre, debe crear el enlace. Si da error de
   sintaxis, el perfil no compila en 10.14: avisar antes de compilar.
1. Arranque y red con el perfil ya existente: 3–4 webs y claude.ai (inicio de sesión y un chat en *streaming*). El
   «FlyWeb Helper (Network Service)» sigue vivo, sin reinicios.
2. Cerrar y reabrir: siguen la sesión de claude.ai y la de la sync, y HSTS (`Default/Network/`: Cookies,
   TransportSecurity, Network Persistent State).
3. Caché de disco: una web pesada dos veces. `~/Library/Caches/LaMosquita/FlyWeb/Default/Cache/Cache_Data` crece y la
   segunda carga sale «(disk cache)» en DevTools.
4. Descargas: un `.zip` y un `.dmg` grandes, con pausa y reanudación.
5. Perfil en volumen Samba (`--user-data-dir=/Volumes/<recurso>/flyweb-prueba`): navegar, iniciar sesión y reabrir.
   La regla impide **crear** enlaces simbólicos, no seguirlos: un perfil o una caché que ya sean enlace deben seguir
   funcionando.
6. Sync propia, actualización de componentes y comprobación de Sparkle.
7. Console.app durante 1–6, filtrando por «Sandbox» y por el Network Service. No debe haber «failed to compile». Cada
   «deny(1) file-write-create» es una ruta que intentó crear un enlace: se anota y se pasa a SEGURIDAD-PORTES.

Pruebas automáticas: `content_unittests --gtest_filter='*SandboxMac*'` y `sandbox_mac_unittests`.

**Paso 0 hecho (LOCAL-19, 19-11, en la 6,1, macOS 10.14.6 18G9323):** `(unless #f (deny file-write-create (vnode-type
SYMLINK)))` → `ln: Operation not permitted` (salida 1, no se crea el enlace); `(unless #t …)` → salida 0, enlace creado.
Mojave entiende `unless` y `vnode-type SYMLINK` sin error de sintaxis: queda descartado el riesgo principal (que el
perfil no compile en 10.14). **APTO para Mojave**, a falta de los pasos 1–7 con la versión compilada.

## `chromium/0002`: 880ca0428f (bug 586656231, merge 587681925)

`LocalFileStreamReader` (`storage/browser/file_system`) rompía el contrato de `FileStreamReader`: en `Read()` podía
ejecutar el *callback* de forma síncrona y además devolver el resultado, y si `file_access` denegaba el acceso en línea
llamaba al *callback* antes de devolver `ERR_IO_PENDING`. Un llamador reentrante como `MojoBlobReader` podía destruir
el lector mientras `Read()` aún se deshacía: **UAF**. El arreglo solo guarda el *callback* cuando hay `ERR_IO_PENDING`
y publica la denegación en una tarea.

- **Mac: sí.** El código es multiplataforma y lo usan los blobs respaldados por fichero (subidas con `<input type=file>`,
  `FileReader` sobre `File`). La denegación en línea viene de `file_access` (DLP, sobre todo
  ChromeOS); el primer cambio, el del resultado síncrono, es general. Razonado, no probado en ejecución.
- Las líneas `+`/`-` son idénticas a las de upstream (`patch-id` `a79a19e66d` igual). Se aplica limpio sobre
  `2c8ef28a99` y deja **`39054ebf03`** (árbol reproducido como dice §22 de `docs/RELEVO-SEGURIDAD.md`).
- brave-core no tiene parches ni `chromium_src` para estos ficheros (`local/3.1.4-adapt` `e660929`).
- Gravedad: no consta (bug restringido).

### Veredicto (regla 17): **APTO**, `chromium/0002`

Cambio pequeño y local (10 líneas en un `.cc`), sin API nueva ni dependencia de 10.15. Prueba:
`storage_unittests --gtest_filter='LocalFileStreamReaderTest.*'` (trae dos pruebas nuevas) y, en la build, una subida de
fichero grande (un adjunto en claude.ai y un `<input type=file>` cualquiera) y leer un fichero local con `FileReader`.

## `chromium/0003`: 6b1211357d (bug 586219154, merge 587225635)

`image_annotation::ImageProcessor` (`services/image_annotation/public/cpp`) llama a `get_pixels_`, que en algunas
imágenes fuerza un *relayout* que destruye el propio `ImageProcessor` de forma síncrona: **UAF**. El arreglo pone una
`WeakPtr` de guarda y sale si el objeto ya no existe.

- **Mac: sí, por prudencia.** Se compila en Mac y lo usa el renderer para las descripciones de imágenes de accesibilidad
  (`AXImageAnnotator`), que solo se ejecutan si se activan a mano con un lector de pantalla. No he comprobado si
  Brave 1.57/FlyWeb ocultan esa opción. Mismo criterio que `3.0.1/chromium/0019`: código que se compila y no está quitado.
- Diff idéntico al de upstream (`patch-id` `6c1cd59dd2`). Se aplica limpio sobre `39054ebf03` y deja **`5f0d2b4d3e`**.
  brave-core no tiene parches ni `chromium_src` para estos ficheros.

### Veredicto (regla 17): **APTO**, `chromium/0003`

Cambio pequeño (10 líneas), sin API nueva. Prueba: `image_annotation_unittests` (o el binario que incluya
`image_processor_unittest.cc` según `services/image_annotation/public/cpp/BUILD.gn`), con su prueba nueva.

## `chromium/0004`: 7e5aab9f6a (bug 577377858, merge 587680830)

En la navegación secuencial del foco (Tab) entre marcos, `FocusController::AdvanceFocusInDocumentOrder` pasaba el
`InputDeviceCapabilities` de la ventana de origen al `Element::Focus()` de otro documento, que lo exponía como
`FocusEvent.sourceCapabilities`: **un objeto de otra ventana (posiblemente de otro origen) al alcance de la página**.
El arreglo resuelve el objeto con la `DOMWindow` del elemento destino, y `FocusEvent` siempre usa el de su propia vista.

- **Mac: sí.** Blink, todas las plataformas; lo alcanza cualquier web con `<iframe>` y Tab.
- Diff idéntico al de upstream (`patch-id` `dcf2b0abc0`), con sus dos WPT nuevas. Se aplica limpio sobre `5f0d2b4d3e`
  y deja **`a621f0a668`**. brave-core no tiene parches ni `chromium_src` para estos ficheros.
- Es el mismo arreglo que `b33d4b153d` de la 8154 (159), que llegó a la 8078 a los 34 minutos.

### Veredicto (regla 17): **APTO**, `chromium/0004`

Prueba: `run_web_tests.py external/wpt/input-device-capabilities/` (incluye
`sourcecapabilities-sequential-focus-navigation.tentative.html`) y, en la build, recorrer con Tab una página con
iframes (formulario de claude.ai y uno con `<iframe>` de otro origen) sin que se pierda el foco.

## `brave-core/0001`: V8 d68cecd900 (bugs 583479274 y 587681789; V8 15.6.75.72)

Cuando el depurador escribe en una variable de contexto que el *parser* marcó `kNotAssigned`, el código optimizado
seguía tratándola como constante. Con el arreglo, el *isolate* anota que `kNotAssigned` ya no es fiable, desoptimiza
el código existente, y TurboFan (`bytecode-graph-builder.cc`, `js-heap-broker.cc`) y Maglev (`maglev-reducer-inl.h`)
dejan de plegar esas variables como constantes (`debug-scopes.cc`, `runtime-scopes.cc`, `isolate.{h,cc}`). Solo se
alcanza con el depurador conectado (DevTools o una extensión con `chrome.debugger`). Aplica a Mac (V8).

- Los siete ficheros de código son idénticos byte a byte en la 15.6.75.66 y en el padre del arreglo (`a97fec97ff`,
  .71), y ningún `patches/v8` de brave-core los toca: *cherry-pick* limpio. Cada fichero va como `patches/v8/*.patch`
  nuevo (formato de brave-core), más la prueba `test/inspector/debugger/context-set-unassigned-optimized{.js,-expected.txt}`.
- Comprobado: los nueve parches por fichero aplican sobre la .66 y `git apply --cached` del `.patch` de aquí sobre
  `local/3.1.4-adapt` `e660929` da el árbol **`90134a4e08`**. Los avisos de espacios al aplicar son las líneas de
  contexto de los diffs anidados (normal en `patches/`).
- **Época de caché:** no se sube aquí (todo parche de V8 la sube, `docs/SEGURIDAD.md`); la fija quien lo integre en
  la versión siguiente.
- **Gravedad: no consta** (bug restringido). Sin indicios de explotación.
- **Falta, antes de entrar:** d8/mjsunit con y sin Maglev y la suite `inspector` (D8-LINUX), en especial
  `debugger/context-set-unassigned-optimized`. **Sin eso en verde, no entra** (como los demás parches de V8).

### Veredicto (regla 17): **APTO** (condicionado a D8-LINUX en verde), `brave-core/0001`

Es el *cherry-pick* de upstream sin cambios. Efecto visible: con el depurador abierto, cambiar una variable de un
*closure* desde DevTools desoptimiza el código que la usaba (más lento solo mientras se depura; sin efecto fuera del
depurador).

## Dawn `6d772bc9e5c5..062164c3c784` (roll `ff774db0a2`): no aplica

Leído por LOCAL-19 en su checkout (19-11): **un solo commit**, `062164c3c7` «[M156] DEPS: Update DXC to patched branch»
(bug 585800876), que solo cambia `DEPS` y el gitlink `third_party/directx-shader-compiler/src` (DXC `28ae92ffb6f1` →
`4c890fcb0366`). DXC es el compilador de HLSL a DXIL que usa solo el backend **D3D12** de Dawn (Windows). En Mac Dawn
usa el backend Metal con el generador MSL de Tint, sin DXC; y en 10.14 WebGPU y Dawn están además apagados en código
(`docs/b1d/README.md`). Chromium apunta `dawn_dxc_dir` a esa ruta (`build_overrides/dawn.gni`), pero la puerta que
decide si se compila (`dawn_use_built_dxc`, `dawn_enable_d3d12` en `scripts/dawn_features.gni` de Dawn) no se pudo
leer desde la nube (host bloqueado). **Comprobación de un minuto para LOCAL** en el checkout de compilación:
`gn args out/<dir> --list=dawn_use_built_dxc --short` y `--list=dawn_enable_d3d12 --short` deben dar `false` en Mac.

**Comprobado (LOCAL-19, 19-11, build de la 3.1.4: src `local/314` `e9b670773e`, Dawn `5ee7543174`; solo lectura):**
`dawn_use_built_dxc = false` y `dawn_enable_d3d12 = false`; ningún objeto de `third_party/directx-shader-compiler` en
`out/Release` (ni `validate.o`); `gn path` desde `//chrome:chrome_framework_shared_library` hasta
`tint/lang/hlsl/validate` y `tint:dxcompiler-for-fuzzer`: «No non-data paths found» (control: hasta `dawn/native:native`,
1534 caminos). El roll de Dawn **no aplica**, comprobado.

## `skia/0001`: Skia 13d0b32615 (bug 584003006, merge 587681020)

Ganesh (`src/gpu/ganesh/GrBufferAllocPool.{h,cpp}`, `GrCpuBuffer.h`, `GrVertexChunkArray.{h,cpp}`):
`GrBufferAllocPool::makeSpaceAtLeast` sumaba `minSize + pad` sin comprobar desbordamiento, y con `minSize` cerca de
`SIZE_MAX` escribía relleno fuera de límites. El arreglo hace con `SkSafeMath` el redondeo, el relleno y las
multiplicaciones de bytes de vértices, índices e indirectos; rechaza tamaños cero o negativos; limita un bloque a 1,5 GiB;
hace que `GrCpuBuffer::Make` pueda fallar (`sk_malloc_canfail`) y que, si falla, se salte el dibujo; y limita la reserva
inicial de `GrVertexChunkBuilder` a 512 KiB (crece hasta 16 MiB por trozo). **Aplica a Mac:** en 10.14 Graphite está
apagado en código (`docs/b1d/README.md`), así que todo el raster por GPU va por Ganesh.

- Aplica limpio con `git am` sobre el Skia de la 3.1.4 (reproducido: `27c31ca415` + `parte4/skia/0001` +
  `parte5/skia/0001` = **`a934afed14`**): árbol **`32f1340fb3`**. Mismo `patch-id` que el original (`eb434cd430`).
- `GrBufferAllocPool.cpp` y `GrVertexChunkArray.cpp` pasan `clang++ -fsyntax-only` con el parche. `gn/tests.gni`,
  `tests/BUILD.bazel` y `tests/GrBufferAllocPoolTest.cpp` son de las pruebas de Skia, que Chromium no compila.
- **Gravedad: no consta** (bug restringido).
- **Para LOCAL:** `git am` sobre su Skia (el de `a934afed14`) y volver a fijar el gitlink de `third_party/skia` y
  `skia_revision` en `DEPS`, como en la 3.1.4.

### Veredicto (regla 17): **APTO**, `skia/0001`

Es el *cherry-pick* de upstream sin cambios. Efecto: un dibujo que pediría un búfer absurdo (más de 1,5 GiB o con
desbordamiento) se salta en vez de corromper memoria; los tamaños normales no cambian, salvo la reserva inicial de
vértices, que empieza más pequeña y crece. Prueba para LOCAL: páginas con canvas 2D y SVG grandes y una con muchos
trazos (p. ej. los demos de `FlyWeb/tools/`), en la 6,1 y en la 5,1.

## `skia/0002`: Skia 7dc6c0c342 (b/576955738, merge 585801577)

`src/ports/SkFontHost_FreeType_common.cpp` y `src/core/SkScalerContext.cpp`: en `generateGlyphImage`, la ruta LCD16
cruzaba los límites de la máscara (en píxeles) con las medidas del mapa de bits LCD de FreeType (en subpíxeles, ×3) y
restaba desplazamientos sin escalar a anchos y punteros: escritura desalineada en `copyFT2LCD16` cuando dos cargas del
mismo glifo divergen. El arreglo pasa los límites LCD a píxeles antes de cruzarlos, valida el modo LCD y la divisibilidad
por 3, recorta mapa y máscara a la parte común, protege la traslación de contornos no LCD contra el desbordamiento de
`SkFDot6` y añade comprobaciones a la entrada de `SkScalerContext::getImage`.

**Aplica a Mac, por prudencia.** En Mac `enable_freetype` es `true` (`build/config/freetype/freetype.gni`) y el
`skia/BUILD.gn` de Chromium compila `skia_ports_freetype_sources` y define `SK_TYPEFACE_FACTORY_FREETYPE`; el propio
fichero dice que PDFium usa este backend al dibujar su caché de glifos con Skia. Las fuentes web **no** pasan por aquí en
Mac (`web_font_typeface_factory.cc`: CoreText o Fontations). No pude leer PDFium desde la nube (host bloqueado) para
confirmar la ruta exacta; si LOCAL ve que FlyWeb no la alcanza, el parche es inocuo igual.

- Aplica limpio con `git am` sobre `32f1340fb3` (tras `skia/0001`): árbol **`47b14cb49e`**. Mismo `patch-id` que el
  original (`38a6e5929e`).
- `SkFontHost_FreeType_common.cpp` y `SkScalerContext.cpp` pasan `clang++ -fsyntax-only` con el parche (cabeceras de
  FreeType del sistema). `BUILD.gn`, `modules/canvaskit/compile_gm.sh` y `tests/FontHostFreeTypeTest.cpp` son de la
  build y las pruebas propias de Skia, que Chromium no usa.
- **Gravedad: no consta** (bug restringido).
- **Para LOCAL:** `git am` después de `skia/0001` y volver a fijar el gitlink de `third_party/skia` y `skia_revision`.

### Veredicto (regla 17): **APTO**, `skia/0002`

Es el *cherry-pick* de upstream sin cambios. Efecto: glifos con mapas LCD incoherentes se recortan o se descartan en vez
de escribirse fuera de sitio; el texto normal no cambia. Prueba para LOCAL: abrir e imprimir a PDF unos PDF con mucho
texto (fuentes incrustadas TrueType y Type 1) en el visor de FlyWeb, en la 6,1 y en la 5,1.

## `skia/0003`: Skia 9d96dfeb45 (bug 584764517, merge 587951190)

Ganesh (`GrPipeline.h`, `GrDstProxyView.h`, `GrOpsRenderPass.h`, `SurfaceDrawContext.cpp` y los *render passes* de GL,
Metal, Vulkan y D3D): cuando un dibujo lee el destino (*dst-read*), el *scissor* que se manda a la GPU se cruza siempre con
los límites de esa lectura, y se activa siempre. Así, una geometría con límites mal calculados que se salga del área ya
no escribe píxeles fuera de la copia del destino. **Aplica a Mac:** en 10.14 el ráster por GPU va por Ganesh sobre GL
(ANGLE), y en Monterey también. El cambio en `GrMtlOpsRenderPass` es el mismo arreglo para el backend Metal de Ganesh; no hace falta saber si FlyWeb lo usa, porque el parche es el de upstream entero.

- Aplica limpio con `git am` sobre `47b14cb49e` (tras `skia/0002`): árbol **`1ef25455d7`**. Mismo `patch-id` que el
  original (`a80446c2f5`).
- `GrGLOpsRenderPass.cpp`, `GrGLGpu.cpp` y `SurfaceDrawContext.cpp` pasan `clang++ -fsyntax-only` con el parche.
- **Gravedad: no consta** (bug restringido).
- **Para LOCAL:** `git am` después de `skia/0002` y volver a fijar el gitlink de `third_party/skia` y `skia_revision`.

### Veredicto (regla 17): **APTO**, `skia/0003`

Es el *cherry-pick* de upstream sin cambios. Efecto: con *dst-read* (modos de fusión avanzados, `mix-blend-mode`,
filtros que leen el fondo) el dibujo queda recortado a la zona leída; sin *dst-read* nada cambia. Prueba para LOCAL:
páginas con `mix-blend-mode` (multiply, difference, color-dodge) sobre fondos con degradado y canvas 2D con
`globalCompositeOperation` avanzados, en la 6,1 y en la 5,1; comparar con la 3.1.4 que no haya bordes cortados.

## Actor (8d177bf): no aplica

Toca solo `chrome/browser/actor/actor_task.cc` (más su prueba): al pasar una pestaña al control de una tarea de Actor se
descartan las navegaciones pendientes del marco principal, que si no se saltaban el control de orígenes. Actor se
compila en Mac, pero una `ActorTask` solo la crea Glic (Gemini en Chrome), que exige una cuenta de Google con sesión
iniciada; FlyWeb no tiene inicio de sesión de Google (Brave lo quita). Sin tarea de Actor no hay pestaña que gatear. No
comprobado en ejecución; si LOCAL ve Glic activo en la build, se revisa.

## WebXR b7fd761 (`XRCameraUpdateHelper`): no aplica

Toca solo `third_party/blink/renderer/modules/xr/xr_camera_update_helper.{h,cc}` (UAF de la textura de cámara con el
contexto WebGL perdido). Ese objeto solo lo crea `XRWebGLBinding`, que exige una sesión **inmersiva**
(`xr_webgl_binding.cc`: «Cannot create an XRWebGLBinding for an inline XRSession»), y la cámara solo la da ARCore. En Mac
no hay ningún runtime XR inmersivo: `enable_arcore` y `enable_cardboard` son solo de Android y `enable_openxr` de
Windows/Linux (`device/vr/buildflags/buildflags.gni`). Sin sesión inmersiva no hay binding ni helper.

## Skia 16a9d4d9a3 (roll `65b1ce5`): no aplica

Solo toca `src/gpu/graphite/Device.cpp` (más su prueba): al descartar los dibujos tapados por uno que cubre todo, no
se reiniciaba `fCurrentDepth`, y la profundidad podía dar la vuelta y pintar fuera de orden. Es código de **Graphite**,
que FlyWeb tiene apagado en Mojave y en Monterey (DIRECTIVAS, 27-10; `FlyWeb/docs/b1d-regla17.md` §4): el ráster por GPU
va por Ganesh. Solo lo encendería el parámetro explícito `--enable-skia-graphite`. Mismo criterio que los arreglos de
Graphite de `3.1.4/INVENTARIO.md` (CVE-2026-131103 y compañía). La base Skia de aquí (`32f1340fb3`) no cambia.

## Dawn `062164c3c784..218eeee7469d` (roll `9275276`): no aplica

Leído por LOCAL-19 (19-11): **un solo commit**, `218eeee746` «[M156] DEPS: Update DXC to patched branch» (bugs 585800876,
587226013, 587681396, 587680878, 587681118 y 587681373). Solo cambia `DEPS` y el gitlink
`third_party/directx-shader-compiler/src` (DXC `4c890fcb0366` → `454ac22efea5`). Mismo caso que el roll `ff774db0a2` de
arriba: DXC es solo del backend D3D12 (Windows) y en Mac no se compila (`dawn_use_built_dxc` y `dawn_enable_d3d12` en
`false`, `gn path` sin caminos; comprobado en la build de la 3.1.4). **No aplica.**

## TouchSelection (a70a3e9f68 y b526fdd): no aplican

Los dos arreglan `ui/touch_selection` (`TouchSelectionController`, y `TouchSelectionControllerClientChildFrame` para
iframes de otro proceso). Se compilan en Mac, pero no se alcanzan: el controlador solo lo crean las vistas de Aura y
Android, y el cliente de marco hijo pide el gestor a la vista raíz (`GetTouchSelectionControllerClientManager()`).
En Mac la raíz es `RenderWidgetHostViewMac`, que no lo redefine, y la base devuelve `nullptr`
(`render_widget_host_view_base.cc`); `render_widget_host_view_mac.{h,mm}` no mencionan la selección táctil. Mismo
criterio que 553151406 (Aura) en `3.1.4/parte4`.

## Rama de la 159 (`branch-heads/8154`, en beta): vistos para la tanda de la 159

Lo de la 8154 no se prepara mientras la 159 siga en beta: se anota aquí y entra con la tanda de la 159 si sigue
aplicando, salvo que llegue antes a la 8078 como merge M156 (entonces va arriba, en la tabla de la 8078).

| Commit de la 8154 | Qué | ¿Mac? | Estado |
|---|---|---|---|
| `690f348e8d` (20-11 00:37 UTC) | [M159] «[optimization_guide] Defer SetInput() callbacks to avoid UAF» (587680474; arregla 570347667 y 562796602) | Se compila; **inalcanzable** sin modelo on-device (razonado, no probado) | Candidato; sin parche |
| `b33d4b153d` (20-11 03:52 UTC) | [M159] «Scope InputDeviceCapabilities to target window for focus events» (577377858) | Sí | Llegó a la 8078 como `7e5aab9f6a` → `chromium/0004` |
| `97e1b5bdc3` (20-11 09:03 UTC) | [M159] «[SimpleCache] Prevent doomed entries from mutating SimpleIndex» (583238770, merge 588197278), `net/disk_cache/simple` | Sí (la caché simple se usa en Mac) | Candidato; sin parche: si llega a la 8078, a `pendiente/` |
| `cc42b75af2` (20-11 09:20 UTC) | [M159] «[CacheStorage] Truncate pre-existing entry streams on empty puts» (583238770, merge 588197278), `content/browser/cache_storage` | Sí | Candidato; sin parche: si llega a la 8078, a `pendiente/` |

**`690f348e8d`** (SEGURIDAD-PORTES-33, 20-11): `SessionImpl::AddContextImpl()` y `OnDeviceContext::SetInput()`
ejecutan `callback_` de forma síncrona, y `AIManager` guarda en ese *callback* la propiedad de la `OnDeviceSession`
pendiente: UAF si se ejecuta o se suelta con `this` en la pila. El código vulnerable **está en la 156** (8078
`7cd7567b30`: `on_device_context.cc` líneas 120–141 y 227–232). El diff aplica sobre la 8078 salvo dos *hunks*
de contexto: el de `#include` de `on_device_context.cc` (la 156 no tiene `string_number_conversions.h` ni
`substitution.h`) y el de `session_impl_unittest.cc` (solo prueba). En FlyWeb no se alcanza: las APIs de IA siguen
experimentales y sin componente de modelo (`motor-niveles.md`, fila «APIs de IA en el navegador»; el servidor de
componentes no sirve `optimization_guide`), así que no se crea ninguna `OnDeviceSession`. Precedente: `3.0.1/chromium/0019`
(`ModelSubscriber`, mismo subsistema), que entró por prudencia. Gravedad: no consta (bugs restringidos).

