# FlyWeb 3.1.2: contenido (cerrado el 14-11, sin la 158)

SEGURIDAD-PORTES-23, 13-11-2026; **cerrado el 14-11**. Es la directiva «3.1.2 antes de la 3.2.0» (Titín, 13-11 noche;
COORDINACIÓN-41). **Titín decidió el 14-11 sacarla ya, sin la 158** (COORDINACIÓN-42): el delta de la 158 va en una
**3.1.3 solo de seguridad** (pasos en «Para la 3.1.3», abajo).

Lleva:
- seguridad: el delta **156.0.8078.104 → .105** de la rama 8078 (salió el 13-11 por la noche; entra con el acuerdo de
  COORDINACIÓN-42) y el KEV sin nuevos; la V8 se queda en la .58;
- el **respaldo GL** de ANGLE (`3.1.2-gl-reserva` 0001–0005, G-C2 cerrada);
- el **«error 11»** (brave-core 0002).

**Nada compilado por mí**: compila LOCAL-19 con la serie de «Orden de aplicación».

## Base (comprobada con `ls-remote` el 13-11)

Es la 3.1.1 publicada (198.63.44).

| Repositorio | Rama | Commit | Árbol |
|---|---|---|---|
| chromium (fork `lamosquita-net/chromium`) | `seg/3.1.1` | `9e0d83137fde575222a8ad3c41fe55468bd8d9f1` | `38c6e1d3e3` |
| brave-core | `local/3.1.1` | `3e2c12fad571ebc9341994792fa20e91c3fe1e2f` | — |

## Lo que ya está

| Qué | Estado | Dónde |
|---|---|---|
| **KEV** | `cve-watch.py --desde 2026-10-15`, pasado de nuevo el **14-11 a las 12:40 UTC**: el catálogo sigue en la **2026.11.13**; 2 de Chromium, los 2 ya triados, **0 nuevos** | — |
| **chromium 0001–0010** | El delta de **156.0.8078.105** (abajo), con `chrome/VERSION` | [`chromium/`](chromium/) (sumas en [`SHA256SUMS`](SHA256SUMS)) |
| **brave-core 0003** | `package.json`: etiqueta del proyecto chrome 156.0.8078.104 → **.105** (como 59680cc en la 3.1.1) | [`brave-core/`](brave-core/) |
| **brave-core 0001** | `flyweb_version` 3.1.1 → **3.1.2**, en un commit aparte (`docs/SEGURIDAD.md`). `git apply --check` limpio sobre 3e2c12fad57; árbol tras el commit: `78684355db` | [`brave-core/`](brave-core/) (sumas dentro) |
| **brave-core 0002** | Arreglo del «error 11»: los dos plugins falsos del farbling pasan de 1 a 2 tipos MIME, igual que en Brave upstream. Sin él, el renderer cae (desreferencia de nulo, no OOB ni UAF) cuando una página enumera `navigator.mimeTypes`. Origen: brave-core `local/311-error11` 6bc695443675 (LOCAL-19). Entra por el sí de Titín (14-11, COORDINACIÓN-42). Revisión: APTO, en #985 (comentario 6877066617). patch-id `d65f0669…`. Aplica limpio tras 0001; árbol `64b632d5ed` | [`brave-core/`](brave-core/) (sumas dentro) |
| **V8** | **se queda en 15.6.75.58**, la de la 3.1.1, ya probada (`3.1.1/mjsunit.md`). La .59 se retira: ver abajo | — |
| **Rama 8078** | `ls-remote` del 14-11: **156.0.8078.105** (el 13-11 no estaba). Entra: ver «Delta de la .105» | — |
| **Chrome Releases** | feed leído el 14-11 a las 12:35 UTC: sin nota de seguridad nueva para escritorio desde la del 11-11 (la última entrada es de ChromeOS, 13-11). Los CVE de los arreglos de la .105 saldrán con la nota de la 158 | — |

### V8 15.6.75.59: retirada (no entra en la 3.1.2)

La 15.6.75.60 (13-11) **revierte** el único cambio de la .59: af144bc, «[M156] Enforce no-JS execution scopes in
InvokeApiFunction», con los bugs 584997097 y 576333024. Esto dice el revert a62636b:

> Reason for revert: depends on https://issues.chromium.org/issues/566156384

El fallo salió en el bot `fuchsia-x64-cast-receiver-rel` de la m156.

Así quedan las versiones:
- **.60 = .58 + número de versión**: `git diff 15.6.75.58 15.6.75.60` solo toca `include/v8-version.h`.
- **No subimos a la .60.** Solo cambiaría `V8_PATCH_LEVEL`, y con él el hash de la caché de código, sin arreglar nada.
- **El parche `3.1.1/v8-15.6.75.59/0001` no se usa.** Su d8 en verde no basta: upstream lo retiró porque le falta un
  cambio previo.
- **D8-LINUX:** como la V8 no cambia, no hay encargo de d8 para la 3.1.2. Si la 3.1.3 cambia de V8, el encargo va
  a `buzon/D8-LINUX`.
- **En la 3.1.3 (17-11):** mirar si el arreglo de 576333024 vuelve a la rama 15.6 junto con 566156384 (una .61 o posterior), o
  si viene en la V8 de la 158. Si vuelve a la 15.6, se porta con su dependencia, se vuelve a pasar el d8 y se sube
  la V8.

## Delta de 156.0.8078.105 (chromium 0001–0010)

`git log 156.0.8078.104..156.0.8078.105` (gitiles, 14-11): 16 commits. Entran 9 con `git am` y el mismo `patch-id`
que el original (comprobado uno a uno, también en los ficheros de `chromium/`), más `chrome/VERSION`. **Todos aplican
limpios sobre `seg/3.1.1`.**

| Parche | Original | Qué | En Mac |
|---|---|---|---|
| 0001 | 41621133b8 | [blink] Avisar a Oilpan por elemento en las operaciones en bloque de `HeapVector` (584997513) | sí |
| 0002 | 6eee876a74 | Validación de estado en las instantáneas de scroll timeline (584579940) | sí |
| 0003 | 87c42a60d4 | [FedCM] Cerrar el diálogo en otra tarea (584119460) | sí |
| 0004 | 05cfdaf093 | UAF en `WidgetInputHandlerImpl::DispatchEvent` (584579056) | sí |
| 0005 | 5e7cdaef02 | Destrucción de `RenderProcessHost` en `ChromePluginServiceFilter` (584998072) | sí |
| 0006 | 694f26a1fe | [FedCM] Salir pronto de `RedirectTo()` si la navegación lo destruye (584119540) | sí |
| 0007 | 61219a9df6 | PDFium c97f02a351 → e3e6c43ef6 (roll) | sí |
| 0008 | 369f7bb08c | XR: framebuffers sin enlazar antes de borrar (585406848) | **no** (solo Android; inocuo, se lleva por fidelidad a la etiqueta) |
| 0009 | 198456d1db | PDFium → 8b21800ddb y Skia 8e7863a6ff → 4c5f57e4fa: «[M156] [SkScalerContext] Harden mask-filtered getImage» (584998030) | sí |
| 0010 | — | `chrome/VERSION` 156.0.8078.104 → **.105** | — |

**Fuera:**
- **Dawn** (9aaeecc7cc y a49d1bc2d9: 8bc8ddaf28 → 68b5c1f3f2). Nuestro Dawn es un fork (`31316d1c`, `DEPS` 8ce9806ee5),
  así que las subidas no aplican; además WebGPU está apagado en 10.14 (`FlyWeb/docs/b1d-regla17.md` §4). No he podido
  leer esos commits (dawn.googlesource.com está bloqueado desde aquí). **Pendiente para la 3.1.3**: que LOCAL mire si
  alguno es de seguridad y aplica a nuestro fork.
- **V8** (896e6149ef): sube a 15.6.75.60, que es la .58 más el número de versión (ver abajo). Seguimos en la .58.
- **Tests** (c88c943ea3, ef28c8e52d, fb3a910695): solo arreglan pruebas inestables.

**PDFium:** tampoco he podido leer pdfium.googlesource.com: las subidas entran porque nuestra base es la misma de
upstream (c97f02a351) y son de la rama M156. Los CVE saldrán con la nota de la 158.

**Cruce con brave-core** (`local/3.1.1` más 0001–0002): ninguno de los ficheros de 0001–0009 tiene `patches/…patch`
ni `chromium_src/…` en brave-core. Ninguno toca red, TLS ni cabeceras: basta la prueba de huella de la 3.1.1.

## Para la 3.1.3 (desde el 17-11, cuando salga la nota de Chrome 158 estable)

1. **Nota de la 158.** Feed Atom: `https://chromereleases.googleblog.com/feeds/posts/default?redirect=false&max-results=40`.
   Sin `redirect=false` redirige a feedburner, que no resuelve.
   - Cruzar cada CVE con `FlyWeb/docs/seguridad-3.1.1.md` §1–§3, con `3.1.1/CONTENIDO.md` y con la .105 de arriba (sus
     arreglos ya estarán en la 3.1.2).
   - Por cada CVE que afecte a la 156, buscar el `[M158]` en la rama 8127 y el commit original en `main`.
2. **Rama 8078 y V8 15.6.** `ls-remote` de los tags `156.0.8078.*` (¿hay .106 o más?) y `15.6.75.*` (¿vuelve
   576333024?). Lo nuevo entra con `cherry-pick -x` y el mismo `patch-id`.
3. **Dawn** de la .105 y **KEV** del día. Dawn, revisado por LOCAL-19 en `chromium/8078` el 14-11 (COORDINACIÓN-42).
   Nuestro fork `31316d1c` no tiene los tres commits posteriores a `8ce9806ee`. Decisión (SEGURIDAD-PORTES-23):
   - **Entra 68b5c1f3f**, «[wgsl] Fix minBindingSize propagations» (584579013; cherry-pick de 98912a81). Es Tint y vale
     para todas las plataformas. En 10.14 y 10.15 WebGPU está apagado, pero en Monterey («debería funcionar») no. Aplica
     limpio.
   - **Entra 8bc8ddaf2**, «[vulkan] Reset the recording context in Queue::DestroyImpl» (un UAF). En Mac no se usa Vulkan:
     va por fidelidad con la rama, porque aplica limpio y no cambia nada de lo que se ejecuta.
   - **Fuera f5ba7dc9e** (sube DXC, que es de D3D12/Windows).
   - Se aplican sobre `31316d1c` con `cherry-pick -x` y el mismo `patch-id`, y el gitlink y el `DEPS` de Dawn van al
     commit resultante en el mismo parche que fija ANGLE y FFmpeg (paso 4). Antes hay que subirlo a un remoto que
     `gclient` pueda bajar.
4. **Serie chromium** sobre el árbol final de la 3.1.2 (`8abc877c10`), con el cruce con `patches/` de brave-core
   antes de cerrar (la trampa de `navigation_request.cc` de la 3.1.1).
   - El primer parche fija los gitlinks y el `DEPS` de lo que se compila de verdad:
     - `third_party/angle` → `bc2ebdd211` (árbol `099b621f10`);
     - `third_party/ffmpeg` → `a15fcf87d2`.
   - Así `gclient sync` reproduce lo publicado. Antes, comprobar con `ls-remote` que esos commits están en un remoto que `gclient` pueda bajar; si no, se suben a los forks.
5. **Huella:** si algún parche toca red (TLS, HTTP/2, cabeceras, Client Hints), se repite la prueba de huella.

## Respaldo GL de ANGLE en los Mac de 2012–2015: revisión de la regla 17 (candidato)

Parches de ARQUITECTURA: `FlyWeb/parches/3.1.2-gl-reserva/` 0001–0005 (#982, fusionado). `SHA256SUMS` cuadra. Estudio en
`FlyWeb/docs/gpu-mac-antiguos.md`. Revisado por SEGURIDAD-PORTES-23 el 14-11 sobre el código de `seg/3.1.1` (9e0d83137f) y
el ANGLE de su `DEPS` (`f10470c77e`, rama `chromium/8078`). **Veredicto: APTO con condiciones (G-C1 a G-C3).** Entra por decisión de
Titín (14-11).

**ANGLE real de la 3.1.2 (aviso de LOCAL-19 por COORDINACIÓN-42, 14-11):**
- **Qué se compila.** La 3.1.1 publicada y la 3.1.2 se compilan con ANGLE `bc2ebdd211`, árbol **`099b621f10`**. Lo dice la cadena «ANGLE 2.1.20 git hash: bc2ebdd2115f» del framework. No se compilan con el gitlink de `seg/3.1.1` (`e3917d69d5`).
- **Qué es ese ANGLE.** Lo he reproducido: es `f10470c77e` más `3.0.1/angle` 0001–0012 (árbol `d094abc`, la base de mi revisión) más `FlyWeb/parches/3.1-angle/` 0001–0004.
- **Por qué no cambia el veredicto.** Esos cuatro parches solo tocan `src/libANGLE/renderer/metal/`. Los «Translator» de los que habla LOCAL-19 ya están en `3.0.1/angle`, dentro de `d094abc`. Las partes de GL, CGL, EGL y del traductor son idénticas a las que revisé. **El APTO sigue en pie**: el recuento de CVE y la tabla de commits GL no cambian.
- **FFmpeg.** Lo mismo: se compila con `a15fcf87d2` (`local/301`, los 3 arreglos de la 3.0.1), no con el gitlink `9db86ce5b5`. **En la 3.1.3 se fijan los gitlinks de ANGLE y FFmpeg en la serie de chromium**, para que `gclient sync` reproduzca lo publicado (paso 4 de «Para la 3.1.3»).

**Estado (14-11): ENTRA en la 3.1.2.** Lo decidió Titín (DIRECTIVAS, «Respaldo GL en la 3.1.2», por COORDINACIÓN-42).
Lo que vio: en la 6,1, Metal sigue por defecto y va mejor que GL; en el 9,1 con Catalina, OpenGL se elige solo y va
como Safari o mejor. **G-C2 se mantiene antes de cerrar el contenido**: si falla algo, se avisa a COORDINACIÓN y Titín
decide. La preliminar
de LOCAL-19 (`local/311-gl-reserva`) pinta: en la 6,1 con `--use-angle=gl` y en el MacBookPro9,1, que elige
`angle=opengl` por sí solo, hay 0 caídas, 0 minidumps y 0 denegaciones del sandbox. **No se toca el sandbox**, así que
no hace falta otra regla 17. Queda G-C2 en el 9,1: cambio de GPU, reposo y monitor externo (en medida).

### Selección: ¿se puede forzar GL donde Metal funciona?
- **Por defecto, no.** Con el 0001, `GetEGLInitDisplays` prueba METAL primero, y OPENGL y OPENGLES solo si la pantalla de
  Metal no se inicia. En la 6,1 y la 5,1 nada cambia (la prueba A de LOCAL lo confirma).
- **Una web, no:**
  - en la 156, `chrome://flags#use-angle` solo existe en Windows y Android, y brave-core no lo añade;
  - cuando el proceso de GPU se cae y retrocede de modo (`HARDWARE_GL`, SwiftShader…), no cambia el backend de ANGLE;
  - la lista de fallos de controladores no tiene ninguna entrada con `disable_metal`.
- **macOS 11 o posterior: nada cambia** (`MacOSVersion() < 11`).
- **A mano, sí:** con `--use-angle=gl` en la línea de órdenes, en cualquier Mac con 10.14 o 10.15, Mac Pro incluidos.
  Lo acepto: es del usuario local, como `--no-sandbox`, y hace falta para la prueba B. Si se quisiera cerrar, se haría
  en una versión posterior.

### Ficheros nuestros (0002–0005)
- **Devuelven código que upstream tuvo hasta la 156**: `GetTextureTargetForIOSurfaces`, el campo del mojom, el destino
  de textura en `ClientSharedImage` y el formato de viz. Solo añaden; no deshacen ningún arreglo de la 156 en esos
  ficheros.
- **Con Metal o SwiftShader, `GetTextureTargetForIOSurfaces()` devuelve `GL_TEXTURE_2D`**, el mismo destino que hoy:
  en los Mac con Metal, el 0005 da el mismo formato que antes.
- **Mojom (0003):** el campo va del proceso de GPU al cliente. No abre ninguna frontera nueva: un renderer ya puede usar
  cualquier destino en sus órdenes, y quien valida es el frontal de ANGLE.

### Recuento real de CVE del OpenGL de ANGLE
- **Los 34 de la 151–156 (`gl-150-156-seg.md`): ya están.** 37 de los 39 commits de ANGLE de esa lista son ancestros
  de `f10470c77e`. Los otros dos son `8f1c9f81de`, la revert de `ed78400986` (que sí está), y `0855dd00f9`, de abajo.
  La parte de Chromium que tocaban (decodificador *validating*) B1c no la devuelve. La deuda de esa lista es **cero**.
- **Desde la 156 hasta la base de la 158**: 31 commits tocan `src/libANGLE/renderer/gl/`
  (`git log chromium/8078..chromium/8127 -- src/libANGLE/renderer/gl`). Los revisé uno a uno el 14-11, aplicándolos con
  `cherry-pick` sobre nuestro ANGLE (`f10470c77e` más `3.0.1/angle` 0001–0012, árbol `d094abc`, reproducido). **Ninguno
  aplica en Mac:**

  | Commit | Qué | Bug | Por qué no aplica en Mac |
  |---|---|---|---|
  | `a965a227` [M158] | Recreate 3D texture on depth increase from zero-extent level | 584998888, 577140687 | apaño `recreateTextureOnTexImage3dDepthIncrease`: solo Qualcomm en Android |
  | `0855dd00` | forcefullyFlush in useTempForNonZeroBaseLevelGenmipmap | 566683383 | apaños `flushBeforeGenerateMipmap` y `useTempForNonZeroBaseLevel…`: solo PowerVR |
  | `b40b5946` | Avoid FBO driver hash collisions | 551065275 | apaño nuevo `recreateFboOnAttachmentRespecification`: solo PowerVR |
  | `fb01175` (+ `66b09c8`) | Avoid user memory when querying sync status | 573982271 | el doble acceso lo creó `c553b33` (`defer_gl_delete_buffers`, 21-09), que no tenemos: nuestro `SyncGL` y el de Metal escriben una vez y no vuelven a leer |
  | `5cb273f` [M158] | Fix blend state in ComputeDirtyBitsBetweenStates | 582276340, 566667041 | solo en `syncFromNativeContext`, el contexto externo de WebView |
  | `69b419c` [M158], revertido | Fix layer-growth check in TextureGL::setStorage() | 584998441, 569165856 | apaño `reattachTextureToFboAfterLayerIncrease`: solo PowerVR en Android |
  | `1f25c8e` [M158], revertido | Don't skip 3D texture recreation without glCopyImageSubData | 585406922, 568903530 | el mismo apaño que `a965a227`: Qualcomm en Android |
  | **`7a33c47` [M158], revertido el 13-11** | **Pause transform feedback before forcing program binding** | 584998126, 582926167 | **Es genérico y sí aplicaría.** Upstream lo ha revertido: **se vigila** y se porta si vuelve (a la 8127 o a `main`) o si la nota de la 158 lo cita |

  El resto son apaños de otros controladores (Mali, Adreno, IMG, PowerVR), refactorizaciones o la parte de EGL de
  Linux. **`FlyWeb/seguridad/3.1.2/angle/` queda vacío: la 3.1.2 sale sin parches de ANGLE.** Se
  repasa en la 3.1.3 con la nota de la 158.
- **Capa CGL** (`renderer/gl/cgl/`): desde la 156 solo hay refactorizaciones del cerrojo de pantalla (`deeaa4b`,
  `e5913a5`, `77be48b`), ninguna de seguridad. Que esté a medio desmontar (sin `prepareForCall`, `testDeviceLost` ni
  aviso de cambio de GPU) es un riesgo de **estabilidad** (pérdida de contexto, cambio de GPU). No he encontrado
  ningún fallo de memoria conocido. Se mide en la preliminar.

### Condiciones
- **G-C1.** GL entra en la 3.1.2 sin parches de ANGLE (tabla de arriba). Lo que diga la nota de la 158 sobre ANGLE
  GL, y `7a33c47` si vuelve, se mira en la 3.1.3. El camino lo fijó COORDINACIÓN-41 el 14-11: ficheros
  en `FlyWeb/seguridad/3.1.2/angle/`, que LOCAL aplica sobre el ANGLE de `DEPS` y `3.0.1/angle`, como en la 3.0.1,
  sin cambiar de remoto.
- **G-C2.** Pruebas antes de cerrar el contenido:
  - la A de LOCAL (Mac Pro con `angle=metal`, sin cambios);
  - en el MacBookPro9,1, el **cambio automático de GPU** (HD 4000 ↔ GT 650M), dormir y conectar un monitor, sin caídas
    ni pantalla negra. Si falla, ARQUITECTURA decide entre fijar la GPU dedicada en GL o devolver `prepareForCall`.
  - **Resultado (14-11, LOCAL-19, `buzon/ARQUITECTURA/20261114-1140-LOCAL-19-gl-preliminar-resultados.md`, buzon
    aa048d7): G-C2 CERRADA (SEGURIDAD-PORTES-23).** Dos pasos:
    1. **Reabierta** por el reparo de ARQUITECTURA (COORDINACIÓN-42). El primer reposo de las 11:31 no dejó rastro:
       `registro.jsonl` acaba a las 11:30:42 y el muestreo de CPU no tiene huecos. `pmset -g log` confirmó después que
       solo duró 2 s. Error mío: no crucé las horas con los registros.
    2. **Repetida** con muestreo que sobrevive al reposo, y **cruzada** la hora de `pmset` con el muestreo:
       - **HD 4000** (la prueba fuerte):
         - `pmset`: Idle Sleep 12:38:30 → Wake 12:47:37, 547 s.
         - Hueco en el muestreo: 12:38:33 → 12:47:40, también 547 s, con el mismo desfase de 3 s en los dos extremos.
           Casa.
       - **GT 650M**:
         - `pmset`: Clamshell Sleep 11:49:36 → Wake 11:54:43, con dos DarkWake de mantenimiento a las 11:49:50 y a
           las 11:51:44.
         - Huecos en el muestreo: 76 s y 135 s. Encajan con dormir entre DarkWake, porque en un DarkWake los procesos
           corren, pero el cruce no es exacto sin la duración de cada DarkWake.
       - **En las dos:**
         - 0 contextos WebGL perdidos o restaurados, 60 fps al despertar y `angle=opengl` en la misma GPU;
         - 0 en «GPU process crash count» y 0 informes en DiagnosticReports.
       - **Vídeo:** se reanuda con la GT 650M. Con la HD 4000 no se pudo evaluar (estaba en pausa por un anuncio).
         Queda en la medida pendiente de «vídeo con la HD 4000» del informe. No bloquea: la decodificación va por
         VideoToolbox, no por la ruta de pérdida de dispositivo de ANGLE.
       - Nota: el hueco de `requestAnimationFrame` (481 s y 108 s) es menor que el reposo. Lo atribuyo a que el reloj
         monótono de Chromium en Mac (`mach_absolute_time`) no avanza mientras el Mac duerme. Es una explicación
         probable, no comprobada, y no afecta al resultado.
       - Los ficheros en bruto (`pmset-sleep-wake.txt` y el muestreo) están en el Mac de pruebas, no en el repo. Mi
         cruce se basa en las cifras del informe.

    Así queda ejercitado lo que ANGLE quitó (`testDeviceLost`) con un reposo real de 5 a 9 min y WebGL activo, sin
    perder el contexto ni tirar el proceso de GPU.

    Lo demás sí lo doy por bueno:
    - Cambio de GPU en caliente, de la Intel a la NVIDIA: sin pérdida de contexto, 60 fps y el vídeo sigue. FlyWeb se
      queda en la Intel, con la pantalla en la NVIDIA: sin el aviso de cambio de GPU, el contexto no migra, pero
      funciona.
    - Dormir y despertar: el reposo repetido (arriba).
    - 0 caídas, 0 minidumps y 0 denegaciones del sandbox. Ninguno de los errores de GL buscados.
    - **El monitor externo no se probó** (faltaba el adaptador). Pasa a **prueba después de publicar**: en el 9,1,
      conectar un monitor fuerza la NVIDIA, que es el mismo tipo de evento que el cambio de GPU que ya ha pasado. Si
      falla, el riesgo es de estabilidad (pantalla en negro o caída del proceso de GPU, que se reinicia), no de
      seguridad, y el arreglo va en una 3.1.x. No bloquea.
- **G-C3.** Desde la 3.1.2, las tandas de seguridad (y SEGURIDAD-VIGÍA) tratan como **aplicables en Mac**
  `renderer/gl/` y `renderer/gl/cgl/` de ANGLE. Hasta ahora se descartaban: eran código muerto.
- **Opcional:** que los *traits* del 0003 acepten solo `0`, `GL_TEXTURE_2D` y `GL_TEXTURE_RECTANGLE_ARB`.

## Orden de aplicación

**chromium**, sobre `seg/3.1.1` (`9e0d83137f`, árbol `38c6e1d3e3`), con `git am` y en este orden. Las sumas, antes:
desde `chromium/`, `sha256sum -c ../SHA256SUMS`; `3.1.2-gl-reserva/` y `brave-core/` llevan la suya dentro.

| Paso | Parches | Árbol tras el paso |
|---|---|---|
| chromium 1 | [`chromium/`](chromium/) 0001–0010: delta de 156.0.8078.105 | `edde584296c651e216d066e4901a79feb28d1dac` |
| chromium 2 | [`../../parches/3.1.2-gl-reserva/`](../../parches/3.1.2-gl-reserva/) 0001–0005: respaldo GL (G-C2 cerrada el 14-11; monitor externo después de publicar) | **`8abc877c102fd677270125cac7ba0b15756fbe7f`** |

Los dos pasos no comparten ningún fichero. El respaldo GL solo, sobre `seg/3.1.1`, da `623d304505` (lo que probó
LOCAL-19 en la preliminar).

**brave-core**, sobre `local/3.1.1` (`3e2c12fad57`), con `git am`:

| Paso | Parche | Árbol tras el paso |
|---|---|---|
| brave-core 1 | [`brave-core/`](brave-core/) 0001: `flyweb_version` 3.1.1 → 3.1.2 | `78684355db` |
| brave-core 2 | `brave-core/` 0002: «error 11» (plugins falsos con 2 tipos MIME) | `64b632d5ed` |
| brave-core 3 | `brave-core/` 0003: `package.json`, etiqueta 156.0.8078.105 | **`da680a3270a4a18d9b320f9bdfa6ebf515d736dc`** |

Los árboles los he sacado aplicando los ficheros tal como están aquí. La serie de brave-core la he vuelto a aplicar
desde cero y da el mismo árbol.

**Después de aplicar:**
- `gclient sync` sin `-D` (nunca en `flyweb-build`). Trae PDFium 8b21800ddb y Skia 4c5f57e4fa; **Dawn y V8 no
  cambian**.
- Comprobar `chrome/VERSION` = 156.0.8078.105.

## Versión y build

| Qué | Valor | Quién y cómo |
|---|---|---|
| `flyweb_version` | **3.1.2** | brave-core 0001 |
| `FLYWEB_BUILD_NUMBER` | **45** (la 3.1.1 fue la 44, publicada como 198.63.44) | LOCAL, en `build.sh` |
| CFBundleVersion | **198.63.45** | sale solo: `<flyweb_bundle_version_base>.<build>` |
| `chrome/VERSION` | **156.0.8078.105** | chromium 0010 |
| V8 | 15.6.75.58, sin cambios | — |
| `flyweb_engine_full_version` (Client Hints) | 156.0.8078.82, sin cambios (se sigue declarando 156) | — |
| `kFlyWebCacheEpoch` | 31, sin cambios (sin parches de V8) | — |
