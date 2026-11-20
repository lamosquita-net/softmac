# Seguridad pendiente: para la siguiente versión de FlyWeb

**Decisión de Titín (19-11-2026, vía COORDINACIÓN-51):** la 3.1.4 build 47 queda publicada tal cual y **no hay 3.1.5 por
ahora**. Lo que llegó a la rama 8078 después de compilarla espera aquí y entra en **la siguiente versión que salga**:
la próxima tanda de seguridad (Chrome 159) o la 3.2.0, la que llegue antes.

**Si alguno de estos bugs resulta Alto o Crítico, entra en el catálogo KEV de CISA o se explota, se avisa enseguida a
COORDINACIÓN**, que propondrá una 3.1.5 a Titín.

**Decisión de Titín (20-11-2026, vía COORDINACIÓN-55; `docs/DIRECTIVAS.md`, #1152):** lo de aquí entra en la **3.2.0**, también `brave-core/0002`–`0004` y `chromium/0006`, y **no habrá 3.1.5**. Condición: D8-LINUX en verde (encargo en `buzon` `58d3cf8a5c`); lo que salga rojo se quita.

**Cierre de la tanda (COORDINACIÓN-57, 20-11, 20:01 UTC):** desde ahora, lo que llegue que no sea Alto, Crítico o KEV va a una **tanda posterior** y no a esta, salvo que Titín diga otra cosa. Esta tanda queda en `chromium/0001`–`0008`, `angle/0001`, `skia/0001`–`0003` y `brave-core/0001`–`0005`. Los portes de la 159 van aparte, en `FlyWeb/seguridad/portes-159/` (#1159).

Lo prepara y lo vigila SEGURIDAD-PORTES (desde la -32). Cada arreglo nuevo de la 8078, o de la rama de la 159 cuando
salga, que aplique a Mac se añade aquí con APTO: `chromium/` con número correlativo, `angle/` aparte, y su línea en
`SHA256SUMS`.

## Base

Los dos parches se hicieron y comprobaron sobre los árboles **finales de la 3.1.4** (build 47):

| Repo | Base | Parches de aquí | Árbol resultante |
|---|---|---|---|
| chromium | árbol **`e7162cd585`** (`local/314-adapt` `aaa7d7508d` + `3.1.4/integracion/chromium` 0002–0004; sin el commit de fijación) | `chromium/0001`–`0008` | **`90418ba4fd`** (tras `0007`: `1b06f59f4d`; tras `0006`: `064a5696b2`; tras `0005`: `a9b357bc47`; tras `0001`: `2c8ef28a99`; tras `0002`: `39054ebf03`; tras `0003`: `5f0d2b4d3e`; tras `0004`: `a621f0a668`) |
| ANGLE | árbol **`db885a866b`** (`f10470c77e` + `3.0.1/angle` 0001–0012 + `parches/3.1-angle` 0001–0004 + `3.1.4/angle` 0001–0003) | `angle/0001` | **`fb21437e81`** |
| brave-core | `local/3.1.4-adapt` **`e660929`** (V8 15.6.75.66 con todos los `patches/v8`) | `brave-core/0001`–`0004` | **`29d6bcf5e3`** (tras `0001`: `90134a4e08`; tras `0002`: `639401fb8e`; tras `0003`: `0caa04c2dd`) |
| brave-core (3.2.0) | lo anterior + `FlyWeb/parches/3.2-v8/0001`–`0002` (#1144, `1e978ba37c`): **`78514b92af`** | `brave-core/0005` (va **detrás** de `3.2-v8/0002`) | **`78df46b5d6`** (V8 con todos los `patches/v8`: `9914512d91`) |
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
| `29851e2f7f` (20-11 06:59 UTC) | Prueba desactivada (webdriver en Linux) | — | — |
| `dad9e4d83c` (20-11 10:04 UTC) | [M156] «[SimpleCache] Prevent doomed entries from mutating SimpleIndex» (583238770, merge 588197443) | Sí (abajo) | `chromium/0005` |
| V8 15.6 `18cf2b9282` (.74, 12:54 UTC) | **ceb90d38eb** [M156] «[snapshot] Ship --code-cache-source-hash-sha256 by default» (568907349, 582651043, 582260175; merge 587680873) | Sí | `brave-core/0003` |
| `baba8daae1` (20-11 12:28 UTC) | [M156] Reland «Update last committed service worker client on navigation commit» (581369093, merge 587226523) | Sí (abajo) | `chromium/0006` |
| `581e177a60` (20-11 15:14 UTC) | *Roll* de V8 `c4641b4cbe..18cf2b9282` (= la .74 de arriba) | — | `brave-core/0003` |
| V8 15.6 `751cfac05f` (.75, 15:34 UTC) | **01a299bf4c** [M156] «[compiler] Preserve control inputs on non-cell context operations» (585625642, merge 587680540) | Sí | `brave-core/0002` (**idéntico**, abajo) |
| `9ebc6bd712` (20-11 16:32 UTC) | *Roll* de V8 `18cf2b9282..751cfac05f` (= la .75 de arriba) | — | `brave-core/0002` |
| V8 15.6 `f08ef923d3` (.76, 16:59 UTC) | **c37ab55c4a** [M156] «[sandbox] Bound length in String::ToStdString and ToCString» (579314138, 585869521; merge 587681388) | Sí | `brave-core/0005` |
| `04c385f13f` (20-11 18:31 UTC) | *Roll* de V8 `751cfac05f..f08ef923d3` (= la .76 de arriba) | — | `brave-core/0005` |
| `7ec583a50d` (20-11 18:41 UTC) | [M156] «[Blink] Zero-initialize ImageDataBuffer readback buffer» (585617234, merge 587682327) | Sí (abajo) | `chromium/0007` |
| `8dceb29b09` (20-11 19:07 UTC) | [M156] «Ensure clean style and slot assignments before canvas transform update» (584385833, merge 586066876), `core/dom/element.cc` | Sí (abajo) | `chromium/0008` |

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

## `chromium/0005`: dad9e4d83c (bug 583238770, merge 588197443)

En la caché simple (`net/disk_cache/simple/simple_entry_impl.cc`), una entrada ya condenada (*doomed*) que seguía
abierta podía quitar del `SimpleIndex` el hash de la entrada nueva con la misma clave tras un fallo de E/S o de
*checksum*, o pisar sus metadatos. La entrada viva quedaba invisible para `OpenEntry` aunque sus ficheros seguían en
disco: Cache Storage no la borraba y luego la reabría. Es el disparador por la caché simple del bug 583238770; la otra
mitad (`CacheStorage`, truncar flujos al sobrescribir) está en la 8154 como `cc42b75af2` y aún no ha llegado a la 8078.
El arreglo solo toca el índice si `doom_state_ == DOOM_NONE` y añade un `CHECK(!active_entry_proxy_)` si se condena dos
veces (cierre controlado en vez de estado incoherente).

- **Mac: sí.** La caché simple es el *backend* de disco de la caché HTTP y de Cache Storage en Mac.
- Diff idéntico al de upstream (`patch-id` `9f0aa3d333`). Se aplica limpio sobre `a621f0a668` y deja **`a9b357bc47`**.
  brave-core no tiene parches ni `chromium_src` en `net/disk_cache` ni `content/browser/cache_storage`.
- Gravedad: no consta (bug restringido).

### Veredicto (regla 17): **APTO**, `chromium/0005`

Cambio pequeño y local. El `CHECK` nuevo convierte un estado imposible en un cierre del proceso que usa la caché en vez de
corrupción; es lo mismo que lleva Chrome 156. Prueba: `net_unittests --gtest_filter='*SimpleCache*:*DiskCache*Entry*'`
(trae pruebas nuevas en `entry_unittest.cc`) y, en la build, navegar con la caché llena (recargas y web pesada dos
veces) y una web con *service worker* y Cache Storage (p. ej. una PWA), cerrar y reabrir.

## `chromium/0006`: baba8daae1 (bug 581369093, merge 587226523)

Reland del arreglo de ServiceWorker en el proceso del navegador. Cuando se reutilizaba un `RenderFrameHost` en una
navegación entre documentos, `RenderFrameHostImpl::AddServiceWorkerClient()` actualizaba
`last_committed_service_worker_client_` al preparar el *commit*. Así `GetLastCommittedServiceWorkerClient()` podía
devolver el cliente de la navegación pendiente mientras el documento anterior seguía activo, y un *worker* de `blob:`
creado en ese hueco heredaba el controlador del origen de destino, saltándose CORS. Ahora el cliente se fija al
terminar el *commit*, y antes de heredar el controlador se comprueba que el origen del padre o del creador coincide
con el de la clave del cliente (`AreOriginsCompatibleForServiceWorkerClient`, en el interceptor, en
`DedicatedWorkerHost`, en `SharedWorkerServiceImpl` y en `InheritServiceWorkerControllerFromParentIfNeeded`). Se
alcanza desde cualquier web con *service workers* e iframes. Aplica a Mac.

- Mismo diff que upstream en los 11 ficheros de código y en el *unittest* (`patch-id` igual, fichero a fichero). En
  `service_worker_browsertest.cc` entra con offsets y las 232 líneas añadidas son idénticas, pero se ancla a mano: en
  ese punto un porte anterior de FlyWeb añadió la prueba `NoContainerHostForPdfDocument` y el contexto de cola no
  casaba. El bloque va justo después de la prueba anterior, igual que en upstream.
- **brave-core toca dos de estos ficheros:** `patches/content-browser-renderer_host-navigation_request.cc.patch`
  (donde va nuestro arreglo del PDF) y `…render_frame_host_impl.cc.patch`. Los dos siguen aplicando encima de este
  (solo desplazamientos). En `InheritServiceWorkerControllerFromParentIfNeeded` quedan dos salidas tempranas
  independientes: la comprobación de origen nueva y la nuestra de PDF o *sandbox*. Los `chromium_src` de esos ficheros
  no tocan los clientes de ServiceWorker.
- Comprobado: `git apply --cached` sobre `a9b357bc47` da el árbol **`064a5696b2`**.
- **Gravedad: no consta** (bug restringido).

### Veredicto (regla 17): **APTO**, `chromium/0006`

Es el arreglo de Chrome 156 sin cambios en el código. Efecto visible: ninguno. Un iframe con `blob:` *workers* creado
durante una navegación entre orígenes ya no hereda el *service worker* del destino. Prueba:
`content_browsertests --gtest_filter='*ServiceWorker*NoOriginKeyed*:*LastCommittedServiceWorkerClient*'`,
`content_unittests --gtest_filter='WorkerScriptLoaderFactory*'` y, en la build, una PWA con *service worker* (abrir,
recargar, desconectar la red).

## `chromium/0007`: 7ec583a50d (bug 585617234, merge 587682327)

`ImageDataBuffer`, que se usa para `toDataURL`/`toBlob` de un canvas acelerado, reservaba el buffer de destino sin
inicializar (`SkData::MakeUninitialized`) antes de leer los píxeles de la GPU. Con `kDisableErrorHandlingForReadback`
(activado por defecto), si la lectura falla devuelve `true` sin escribir nada. Así la web recibía **memoria del heap del
*renderer* sin inicializar** dentro de la imagen: una fuga de información. El arreglo reserva el buffer a cero
(`MakeZeroInitialized`), como ya hacen las otras lecturas de GPU. Se alcanza con un canvas acelerado y
`toDataURL`/`toBlob`, y en la práctica cuando la lectura de la GPU falla. Aplica a Mac.

- Mismo diff que upstream (`patch-id` igual, fichero a fichero). Aplica limpio sobre `064a5696b2`.
- brave-core tiene `chromium_src/.../image_data_buffer.h`, que solo añade un acceso a `pixmap_` para el *farbling* del
  canvas y no toca la reserva. Poner el buffer a cero antes de la lectura no cambia lo que hace el *farbling* después.
- Comprobado: `git apply --cached` sobre `064a5696b2` da el árbol **`1b06f59f4d`**.
- **Gravedad: no consta** (bug restringido).

### Veredicto (regla 17): **APTO**, `chromium/0007`

Es el arreglo de Chrome 156 sin cambios. Efecto visible: ninguno; si la lectura de la GPU falla, la imagen sale
transparente o negra en vez de con basura. Prueba: `blink_platform_unittests
--gtest_filter='AcceleratedStaticBitmapImageTest.*'` (trae una prueba nueva) y, en la build, `canvas.toDataURL()` de un
canvas WebGL o 2D acelerado.

## `chromium/0008`: 8dceb29b09 (bug 584385833, merge 586066876)

`InvalidateForCanvasTransformChange` llamaba a `PaintLayer::UpdateTransform()` con el estilo y las asignaciones de
*slots* sucios. Desde `ComputedStyle::ApplyTransform()` eso podía disparar una asignación de *slots* y una
actualización de estilo anidada, que reiniciaba `PaintLayer::transform_` mientras la llamada exterior aún tenía una
referencia: un **UAF en el *renderer***. El arreglo actualiza antes el árbol de estilo y *layout*
(`Document::UpdateStyleAndLayoutTree()`) y toma el `LayoutObject` después. Se alcanza desde cualquier web, con
`<canvas>` y *shadow DOM*/*slots*. Aplica a Mac.

- Mismo diff que upstream (`patch-id` igual). Aplica limpio sobre `1b06f59f4d`. brave-core no toca `element.cc`.
- Comprobado: `git apply --cached` sobre `1b06f59f4d` da el árbol **`90418ba4fd`**. El porte de `portes-159/0001`
  (#1159, menús) sigue aplicando encima: son ficheros distintos.
- **Gravedad: no consta** (bug restringido).

### Veredicto (regla 17): **APTO**, `chromium/0008`

Es el arreglo de Chrome 156 sin cambios. Efecto visible: ninguno. Puede añadir una actualización de estilo cuando
cambia la transformación de un canvas, lo mismo que hace Chrome 156. Prueba: `blink_unittests
--gtest_filter='*Canvas*Transform*:*ElementTest*'` y, en la build, una página con canvas dentro de un *shadow root*
con `<slot>` que cambia `transform` (p. ej. la galería de pruebas de *Web Platform Tests* `css/css-transforms`).

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

## `brave-core/0002`: V8 a0f2c9f8c3 (bug 585625642), portado del merge M159 27e138a575

**Actualización (20-11, 15:46 UTC): ya está en la 15.6** como **01a299bf4c** (V8 15.6.75.75, merge 587680540). Comparado: los seis ficheros que da `0002` sobre la .66 son **idénticos byte a byte** a los de upstream en ese commit, incluida la prueba llevada al cctest, que upstream ha portado igual. `0002` queda como el merge oficial de la .75.

**Por qué se prepara antes de tiempo.** Lo de la 8154 normalmente espera (arriba). Este es un fallo del JIT de V8 con
merge rápido a la 159 (llegó a `main` el 17-11 y a la 15.9 el 20-11), que es lo que suele tener gravedad Alta, y
**aún no hay merge a la 15.6**. Si llega a la 15.6, se compara con este y se anota; si no llega, este es el arreglo.
Aviso dado a COORDINACIÓN-54 el 20-11 (regla de Alto: la gravedad no consta, así que el aviso es por prudencia).

El fallo: TurboFan bajaba `JSLoadContextNoCell`, `JSStoreContextNoCell` y `JSHasContextExtension` con
`graph()->start()` como control. En un generador o una función `async`, esas cargas de contexto podían quedar
programadas antes del `SwitchOnGeneratorState` del bucle reanudable y leer el contexto que no es. Con el arreglo, los
dos operadores llevan entrada de control, `JSTypedLowering` usa la del propio nodo y `JSNativeContextSpecialization`
la pasa. Se alcanza con JavaScript normal de cualquier web (generadores o `async` optimizados por TurboFan). Aplica a
Mac (V8).

- `js-typed-lowering.cc`, `js-operator.cc` y `js-native-context-specialization.cc` son idénticos byte a byte en la
  15.6.75.66 y en la cabeza de la 15.6 (.73), y ningún `patches/v8` de brave-core los toca. Difieren de la 15.9 en
  otras partes, pero todos los *hunks* entran en la .66 solo con desplazamiento de líneas y el mismo contenido
  (`patch-id` igual al de upstream, fichero a fichero), más la prueba `test/mjsunit/compiler/regress-585625642.js` y
  los cambios de `js-typed-lowering-unittest.cc`.
- En la 15.6 no hay más sitios que creen estos nodos con entradas explícitas: `bytecode-graph-builder.cc` usa
  `NewNode(op)`, que añade el control según el operador, y `js-context-specialization.cc` usa `ChangeOp`, que
  conserva las entradas.
- **Única adaptación (solo pruebas):** en la 15.6 las pruebas de especialización de contexto siguen en
  `test/cctest/compiler/test-js-context-specialization.cc` (upstream las pasó luego a
  `test/unittests/compiler/js-context-specialization-unittest.cc`). Los *hunks* de upstream para ese fichero aplican
  limpios al cctest y van ahí, así que todos los nodos `LoadContextNoCell` de esa prueba llevan ya control.
- Comprobado: los seis parches por fichero aplican sobre la .66, y `git apply --cached` del `.patch` de aquí sobre
  `90134a4e08` (tras `0001`) da el árbol **`639401fb8e`**.
- **Época de caché:** no se sube aquí; la fija quien lo integre (una sola subida para `0001` y `0002`).
- **Gravedad: no consta** (bugs restringidos). Sin indicios de explotación conocidos.
- **Falta, antes de entrar (D8-LINUX):** d8/mjsunit con y sin Maglev, en especial `compiler/regress-585625642`;
  `cctest/test-js-context-specialization/*` y `unittests --gtest_filter='JSTypedLoweringTest.*'`, en *release* y en
  *debug* (en *debug*, el verificador del grafo comprueba los recuentos de entradas nuevos). **Sin eso en verde, no
  entra.**

### Veredicto (regla 17): **APTO** (condicionado a D8-LINUX en verde), `brave-core/0002`

Es el arreglo de upstream sin cambios en el código; solo la prueba va a otro fichero. Efecto visible: ninguno.
Añadir una entrada de control a una carga de contexto solo limita dónde puede programarla TurboFan; el coste de
rendimiento es despreciable.

## `brave-core/0003`: V8 ceb90d38eb (V8 15.6.75.74; bugs 568907349, 582651043 y 582260175)

La validación de la caché de código de V8 solo comparaba la **longitud** del código fuente: una caché hecha para un
*script* podía aceptarse para otro distinto de la misma longitud. El cambio junta tres de *trunk*: el `SourceHash`
pasa a ser un SHA-256 de todo el código y de los argumentos envueltos (separando cadenas de uno y dos bytes), y la
opción `--code-cache-source-hash-sha256` sale activada. Aplica a Mac: Chromium usa la caché de código de V8 en cada
web.

- Aplicados sobre la 15.6.75.66, los cinco ficheros quedan **idénticos byte a byte** a los de upstream en la .74.
  Ningún `patches/v8` los toca, y `src/utils/sha-256.h` ya está en la .66.
- Efecto secundario: cambia el formato de la caché de código, así que todas las cachés existentes se rechazan una vez
  y se regeneran (la primera carga de cada web es un poco más lenta). Va en la misma dirección que la subida de la
  época de caché.
- Comprobado: `git apply --cached` sobre `639401fb8e` (tras `0002`) da el árbol **`0caa04c2dd`**.
- **Época de caché:** no se sube aquí (una sola subida al integrar `0001`–`0004`).
- **Falta, antes de entrar (D8-LINUX):** d8, mjsunit (en especial `code-cache-sha256`) y `cctest/test-serialize/*`.

### Veredicto (regla 17): **APTO** (condicionado a D8-LINUX en verde), `brave-core/0003`

Es el cambio de la 15.6.75.74 sin tocar nada.

## `brave-core/0004`: V8 51512210b3 (bug 585614984), portado del merge M159 202e0e7f26

**Por qué se prepara antes de tiempo:** por el mismo motivo que `0002`. Es un fallo del motor de JS, con merge rápido a
la 159 (llegó a `main` el 18-11 y a la 15.9 el 20-11), y **aún no hay merge a la 15.6**. Aviso dado a COORDINACIÓN-55
el 20-11.

El fallo: en llamadas con encadenamiento opcional como `(a?.foo().bar)()`, el generador de *bytecode* no escribía el
registro del receptor en el atajo `null`/`undefined`, pero `CallAnyReceiver` lo leía igualmente. El análisis de vida
(`BytecodeAnalysis`) daba entonces ese registro por vivo a través de los `try/catch` anteriores, y Maglev o TurboFan
podían usar un valor viejo de ese registro. Arreglo:
- se escribe `undefined` en el registro en ese camino (nueva sobrecarga de `BuildOptionalChain`);
- `LivenessIsValid` comprueba también las aristas de excepción (solo en *debug*);
- Maglev limpia los registros muertos en `InterpreterFrameState::CopyFrom` (salvo en las unidades *dummy*) y rellena
  los destinos de reanudación en `VisitSwitchOnGeneratorState`.

Se alcanza con JavaScript normal de cualquier web. Aplica a Mac.

- Mismo contenido que upstream en todos los *hunks*. Uno se reancla: en la 15.6, `CopyFrom` también llama a
  `known_node_aspects_->virtual_objects().Snapshot()` dentro del `if (known_node_aspects_)`, y el bloque nuevo va justo
  después de ese `if`, como en upstream. Todo lo que usa existe en la .66: `HandlerTable::LookupHandlerIndexForRange`,
  el iterador de `BytecodeLivenessState`, `GetRootConstant`, `NewDummy` y `SubgraphBase`.
- `bytecode-generator.cc` y `maglev-graph-builder.cc` ya tenían `patches/v8` de brave-core. Los dos se regeneran
  contra la .66 con lo que ya llevaban más este arreglo; el del intérprete tenía una preimagen anterior y aplicaba con
  una línea de desplazamiento. Los otros seis ficheros son nuevos.
- Comprobado: los ocho parches por fichero, aplicados sobre una .66 limpia, dan exactamente los mismos ficheros que el
  montaje; `git apply --cached` sobre `0caa04c2dd` (tras `0003`) da el árbol **`29d6bcf5e3`**.
- **Riesgo propio de la 15.6:** los `DCHECK_NOT_NULL` nuevos en las lecturas del *frame* de Maglev detectarían en
  *debug* cualquier camino exclusivo de la 15.6 que lea un registro ya limpiado. En *release*, ese caso sería una
  lectura de puntero nulo (cierre, no corrupción). Por eso la prueba en *debug* es obligatoria.
- **Gravedad: no consta** (bugs restringidos). **Época de caché:** no se sube aquí. El *bytecode* cambia, así que la
  subida al integrar es imprescindible.
- **Falta, antes de entrar (D8-LINUX):** d8 y mjsunit con y sin Maglev, en especial `maglev/regress-585614984`, en
  *release* y en *debug*. **Sin eso en verde, no entra.**

### Veredicto (regla 17): **APTO** (condicionado a D8-LINUX en verde, también en *debug*), `brave-core/0004`

Es el arreglo de upstream, con un único *hunk* reanclado por contexto. Efecto visible: ninguno.

## `brave-core/0005`: V8 c37ab55c4a (V8 15.6.75.76; bugs 579314138 y 585869521)

Endurece el sandbox de V8. Una cadena corrompida dentro del sandbox (un `ConsString` con longitud falsa de 0x55555555
y caracteres de 3 bytes en UTF-8) hacía que `String::ToStdString()` y `ToCString()` calcularan 0xFFFFFFFF bytes. ICU
truncaba ese tamaño a -1 y acababa escribiendo fuera de límites (`ultag_parse`, vía `Intl`). El arreglo son dos
`SBXCHECK_LE(length, String::kMaxLength)`, que acotan el tamaño por debajo de `INT32_MAX`. Para explotarlo hace falta
haber corrompido ya la memoria del sandbox, es decir, otro fallo previo: es una defensa en profundidad. Aplica a Mac:
FlyWeb compila con el sandbox de V8.

- Aplicado sobre la 15.6.75.66 (con todos los `patches/v8` de la 3.2.0), da `string.cc` y las dos pruebas **idénticos
  byte a byte** a upstream en la .76. Ningún `patches/v8` toca `string.cc`. `SBXCHECK_LE` y `String::kMaxLength` ya
  están en la .66.
- **Orden:** va **detrás de `3.2-v8/0002`** (la época de la 3.2.0, #1144), no detrás de `0004`. Así no hay que volver a
  regenerar la nota de MOTOR-47 en `FLYWEB-SECURITY.md`. Las series de la 3.2.0 que vienen después no tocan
  `patches/v8`.
- Comprobado: `git apply --cached` sobre `78514b92af` (`pendiente/0001`–`0004` + `3.2-v8/0001`–`0002`) da
  **`78df46b5d6`**. Con todos los `patches/v8`, el árbol de V8 es **`9914512d91`**.
- **Época de caché:** no hace falta. Solo cambia C++ del *runtime*, no el *bytecode* ni el código generado, y la subida
  a 38 de la 3.2.0 cubre la versión igualmente.
- **Gravedad: no consta** (bug restringido).
- **Falta, antes de entrar (D8-LINUX):** d8 y las pruebas `sandbox/regress/regress-579314138-1` y `-2`. Necesitan
  `--sandbox-testing`; si la build no lo tiene, se dice y se dan por no probadas.

### Veredicto (regla 17): **APTO** (condicionado a D8-LINUX en verde), `brave-core/0005`

Es el cambio de la 15.6.75.76 sin tocar nada. Efecto visible: ninguno, salvo que una cadena ya corrompida cierra el
proceso en vez de escribir fuera de límites.

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
| `97e1b5bdc3` (20-11 09:03 UTC) | [M159] «[SimpleCache] Prevent doomed entries from mutating SimpleIndex» (583238770, merge 588197278), `net/disk_cache/simple` | Sí | Llegó a la 8078 como `dad9e4d83c` → `chromium/0005` |
| `cc42b75af2` (20-11 09:20 UTC) | [M159] «[CacheStorage] Truncate pre-existing entry streams on empty puts» (583238770, merge 588197278), `content/browser/cache_storage` | Sí | Candidato; sin parche: si llega a la 8078, a `pendiente/` |
| `eb140e9ee3` (20-11 11:04 UTC) | *Roll* de V8 15.9 `dd683a21bf..a1896f1005` (15.9.128.21): **27e138a575** [M159] «[compiler] Preserve control inputs on non-cell context operations» (585625642, merge 587680496) | Sí (TurboFan) | **Excepción: preparado ya** como `brave-core/0002` (abajo), sin esperar al merge en la 15.6 |
| `41c9a648fb` (20-11 11:20 UTC) | [M159] «Enforce worker script origin match for ServiceWorker clients» (585383394, merge 587681032), `content/browser/service_worker` y `worker_host` | Sí (proceso del navegador; exige un *renderer* comprometido) | Candidato; sin parche: el código vulnerable está en la 156 (`service_worker_client.cc`, `WithOrigin()` en las líneas 665 y 679), pero el diff **no aplica** sobre `a9b357bc47` (5 de 7 ficheros con *hunks* rechazados): si llega a la 8078, a `pendiente/` |
| V8 15.9 `fcaf218c74` (15.9.128.22, 13:15 UTC) | **202e0e7f26** [M159] «[interpreter] Initialize receiver on optional-chain call short-circuit» (585614984, merge 587681919) | Sí (intérprete, Maglev y TurboFan) | **Excepción: preparado ya** como `brave-core/0004` (abajo), sin esperar al merge en la 15.6 |
| `afa45b8e16` (20-11 18:06 UTC) | [M159] «views: Fix FOR_DROP menu drag and drop teardown UAF» (565066840, merge 588202414), `ui/views/controls/menu` | Sí (proceso del navegador; hace falta arrastrar algo a un menú abierto para soltar) | **Portado** en `portes-159/chromium/0001` (#1159). Antes: candidato sin parche. El código vulnerable **está en la 156**: en `GetDropCallback`, tras `OnMenuClosed` (que borra `this`) se sigue usando, y `OnDragUpdated` devuelve la operación con `destroy_pending_`. El diff no aplica tal cual solo por contexto (`DCHECK` frente a `CHECK(…, NotFatalUntil::M163)`); el arreglo son dos líneas. Si llega a la 8078, a `pendiente/` |
| `d54c6b5d5d`, `969701a32a` (20-11 19:00–19:23 UTC) | [M159] ImageDataBuffer (585617234) y transformación del canvas (584385833) | Sí | Llegaron a la 8078 como `7ec583a50d` y `8dceb29b09` → `chromium/0007` y `0008` |
| `b079c8f6c8` (20-11 19:34 UTC) | [M159] «SchemeHostPort: Reject empty host for non-file SCHEME_WITH_HOST schemes» (586171393, merge 588196490), `url/` | Sí (validación de IPC: un `SchemeHostPort`/`Origin` con host vacío recibido por IPC podía confundir la navegación) | **Portado** en `portes-159/chromium/0002` (#1159), por orden de COORDINACIÓN-57 |
| `6738e48e6c` (20-11 18:55 UTC) | [M159] «[BreakoutBox] Add a closed attribute to FrameQueue» (585500473, 560113909) | Sí, pero es una fuga de contabilidad de `VideoFrameMonitor`, no de memoria | No se porta (COORDINACIÓN-57). No aplica tal cual (3 ficheros) |
| `384f43c711` (20-11 19:43 UTC) | [M159] Revert de un `CHECK_GE` a `DCHECK_GE` en `CreateWebTouchPoint` | — (quita un cierre, no arregla un fallo) | — |
| V8 15.9 `ee7bdd086c` (15.9.128.24, 19:50 UTC) | **0cb2a47092** [M159] «[wasm][streaming] Defer streaming completion to foreground task» (580857997, merge 586791986) | Sí (`WebAssembly.compileStreaming`) | Candidato; sin parche. Está en la 15.6 (`PostNonNestableTask`, requisito previo, presente), pero 2 de 4 ficheros no aplican y la prueba vive en otro sitio en la 15.6. COORDINACIÓN-57: **se espera al merge oficial en la 15.6** salvo Alto/Crítico/KEV |

**`690f348e8d`** (SEGURIDAD-PORTES-33, 20-11): `SessionImpl::AddContextImpl()` y `OnDeviceContext::SetInput()`
ejecutan `callback_` de forma síncrona, y `AIManager` guarda en ese *callback* la propiedad de la `OnDeviceSession`
pendiente: UAF si se ejecuta o se suelta con `this` en la pila. El código vulnerable **está en la 156** (8078
`7cd7567b30`: `on_device_context.cc` líneas 120–141 y 227–232). El diff aplica sobre la 8078 salvo dos *hunks*
de contexto: el de `#include` de `on_device_context.cc` (la 156 no tiene `string_number_conversions.h` ni
`substitution.h`) y el de `session_impl_unittest.cc` (solo prueba). En FlyWeb no se alcanza: las APIs de IA siguen
experimentales y sin componente de modelo (`motor-niveles.md`, fila «APIs de IA en el navegador»; el servidor de
componentes no sirve `optimization_guide`), así que no se crea ninguna `OnDeviceSession`. Precedente: `3.0.1/chromium/0019`
(`ModelSubscriber`, mismo subsistema), que entró por prudencia. Gravedad: no consta (bugs restringidos).

