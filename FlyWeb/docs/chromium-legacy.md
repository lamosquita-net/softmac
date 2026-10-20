# FlyWeb — Chromium Legacy como referencia y punto de partida del fork (INVESTIGACIÓN-MOTOR, 20-10-2026)

Estudio en papel (fila FM.33; completa `base-128.md` y `migracion-128.md`). Sin código ni ramas. **Propone; decide Titín.**
Fuente principal: el repositorio [blueboxd/chromium-legacy](https://github.com/blueboxd/chromium-legacy) (BSD-3), leído por la página web y por Git (solo árboles y
mensajes de commit, sin descargar el código), más los *issues* públicos.

**Etiquetas:** **[V]** medido o visto en una fuente; **[I]** inferido; **[H]** hipótesis. «(resultado)» = visto solo como resultado de búsqueda.
Las horas, cuando salen, son **estimación mía**.

## 1. Resumen (las cinco preguntas)

1. **No hay una 128 ni posterior.** Su última publicación es la **127.0.6494.0** (canary, 29 de mayo de 2024) y la última «estable» es la **124.0.6367.207.1**
   (16 de mayo de 2024). El tronco (`master.lion`) llega a la **129.0.6657.0**, pero por una fusión mecánica del 19-04-2025 («Try to merge»), sin los parches ni
   comprobación de que compile [V]. Los *issues* no tienen respuesta del mantenedor desde 2024 (su último commit, de abril de 2025, es una fusión); en marzo de 2026 un usuario cerró el hilo «¿Está muerto?» con «it's dead».
2. **Su método:** una sola rama larga que **fusiona `origin/main` casi a diario** (68 fusiones en 2023–2025), sobre la que van **34 reverts de commits de
   Chromium**, **21 guardas** `@available` por versión de macOS, **18 «evitar tal API»**, 3 *frameworks* débiles y **23 arreglos de «fusiones mal hechas»**
   (el 17 % de sus commits propios), más ramas de las bibliotecas de terceros (Skia, ANGLE, Dawn…) que se superponen a las revisiones de `DEPS` [V: 200 commits propios].
3. **Casi la mitad de sus cambios sobra:** de 226 ficheros con cambios por versión de macOS, **101 solo tocan 10.7–10.12**; **69** son de 10.13/10.14 (High Sierra y
   Mojave); **52** tocan 10.15 (lo nuestro) [V].
4. **Sus problemas en Mojave** (§5) son pocos y concretos; **lo que Titín vio en la 6,1 con la 127.0.6494.0 tiene explicación probable:** el **«Ya no se admite esta
   versión» y Gmail sin estilos** es la versión declarada (127) frente al mínimo actual de Google, el mismo caso que FlyWeb ya resolvió con la versión declarada [H, con
   prueba de 10 min]; las **cinco caídas de la GPU al arrancar** apuntan a **Dawn/WebGPU** (que su 127 enciende y la 116 de FlyWeb apaga) [H, con prueba de 10 min].
5. **Recomendación (confianza media):** **no partir de su árbol; aplicar sus parches de 10.15 sobre Brave 1.69.168**, como ya propone `migracion-128.md`
   (31 de 44 ficheros se aplican idénticos). Y **guardar un espejo de su repositorio** (el proyecto está abandonado y existe el riesgo de que desaparezca de GitHub).
   Licencias compatibles (§7).

## 2. Estado del proyecto (pregunta 1)

| Dato | Valor |
|---|---|
| Última publicación | **127.0.6494.0** (tag `1303823`), 29 de mayo (año no impreso; por la versión, 2024) [V/I] |
| Última «estable» | **124.0.6367.207.1**, 16 de mayo de 2024 (las anteriores: 121.0.6167.160.1, 121.0.6167.139.1 y 120.0.6099.199.1) [V] |
| Publicaciones | unas **1 000** (100 páginas de 10), casi todas *canary* («varias veces por semana, sin pruebas») [V: paginación y README] |
| Cadencia | hasta 2024, estables **cada ~2 meses** y canary casi a diario; el hilo de #239 lo resume igual [V] |
| Actividad del mantenedor | Commits propios: jun–oct de 2023 (el pico: 33 en junio), feb de 2024, **mayo de 2024 (el último trabajo real)**; **2 commits el 19–20-04-2025** (fusiones) [V: `git log`] |
| ¿128 o posterior? | **No.** `master.lion` = 129.0.6657.0 con la fusión de abril de 2025; sin tags ni ramas de 125–129 [V: `chrome/VERSION`] |
| Estado declarado | Issue [#239](https://github.com/blueboxd/chromium-legacy/issues/239) «¿Está muerto?» (24-09-2024): sin respuesta del mantenedor; cerrado el 16-03-2026 con «it's dead :(». [#265](https://github.com/blueboxd/chromium-legacy/issues/265) (jul. de 2025): usuarios en 120–124; «la 123.0.6303.0 es la última sin problemas». [Discusión #274](https://github.com/blueboxd/chromium-legacy/discussions/274) (19-05-2026): «Alternativas a Chromium-legacy» [V] |

**Alternativa viva para Mojave (contexto):** **Momiji**, continuación de *Firefox Dynasty*, con una versión estable sobre **Firefox ESR 140** y otra rodante **v156**, para
macOS 10.12–10.14 (Sierra a Mojave); no reproduce contenido con DRM por defecto [V (resultado): [Low End Mac, 2026](https://lowendmac.com/2026/momiji-v156-a-cutting-edge-firefox-for-10-7-10-14/)].
Sustituye al Firefox ESR 115 de `vision-motor.md` (V14) como **referencia de otro motor en el mismo Mac**.

## 3. Cómo mantienen sus cambios (pregunta 2)

**Medido sobre 200 commits propios (desde 2023-05-01) [V]:**

| Mecanismo | Commits | Para qué |
|---|---|---|
| **Fusiones de `origin/main`** a `master.lion` | 68 | seguir el tronco de Chromium casi a diario (hasta 33 en un mes) |
| **Reverts de commits de Chromium** | 34 | el grueso: la serie «Remove 10.13, 10.14 support» (22 reverts del 29-06 y el 13-07-2023) y «Bump the macOS deployment target to 10.15»; más la limpieza de listas de GPU |
| **Arreglos de fusión** («fix merge misses/build errors») | 23 | el coste de ir detrás del tronco: **el 17 % de los commits no-fusión** |
| **Guardas por versión** («guard X on 10.y-») | 21 | `@available`, `__builtin_available`, `dlopen` |
| **«Evitar tal API»** («avoid using…») | 18 | sustituir una llamada por otra más antigua |
| **Frameworks débiles** («weaken …framework») | 3 | `AuthenticationServices`, `CryptoTokenKit`, `AVFAudio`/`CFNetwork` |
| Otros | ~30 | ajustes de firma, `get-task-allow`, `RTLD_NOW`, etc. |

- **Terceros:** ramas propias en forks (`skia` en `for-lion`; `angle`, `dawn`, `swiftshader`, `vulkan_memory_allocator`, `webrtc`, `libc++`, `boringssl` en `master.lion`) que se
  **superponen** sobre la revisión fijada en `DEPS` con `git checkout <rama> -- .` [V: wiki *Building*].
- **Construcción:** SDK de macOS 14 o posterior con dos parches de cabecera (`GameController`: `strong` → `assign`), clang 18 o posterior, `gclient` [V: wiki].
- **Versiones por tipo de commit en los títulos:** 10.13 (30), 10.14 (27), 10.8 (8), 10.9 (5), 10.7 (4), 10.10 (3), 10.12 (2), 10.11 (2), 10.15 (1) [V].

**Qué nos sirve y qué no [I]:**

| Sirve | No sirve (y por qué) |
|---|---|
| **Revertir primero en la frontera**: la serie de limpieza de 10.13/10.14 está hecha **por Chromium en commits sueltos**, y deshacerlos es más barato que reescribir | **Una rama larga con fusión diaria**: ellos pagan un 17 % en «fusiones mal hechas»; nosotros **congelamos en la 128** y cogemos solo seguridad |
| **Guardas y enlace débil** en lugar de borrar código (conservan el camino nuevo) | **Sin pruebas**: sus *canary* «no tienen tests» y los problemas llegan a los usuarios (§5); nosotros tenemos `motor-N.html`, WPT, Static y ASan |
| **Ramas aparte por biblioteca** (Skia, Dawn, ANGLE) | **Un solo mantenedor** y sin tablero: el proyecto se paró al irse él |
| **Un registro por commit** con la versión de macOS en el título (`on 10.13-`) | **Sin parches de seguridad**: su «estable» 124 no recibió correcciones de Google tras mayo de 2024 |

**Para nosotros** el equivalente natural es **`patches/` de Brave** (un `.patch` por fichero de Chromium) con una capa `mojave-` por directorio (V1 de `vision-motor.md`), no una
rama fusionada a diario.

## 4. Qué parte sobra (pregunta 3)

Medido sobre el diff de Legacy 127.0.6494.0 frente a Chromium 127.0.6494.0: **226 ficheros** con cambios por versión de macOS (1 947 ficheros distintos en total, casi todos deriva
del tronco) [V]:

| Clase | Ficheros | Líneas (+/−) | Para nosotros |
|---|---|---|---|
| **A.** tocan **10.15** | 52 (42 sin `remoting/` ni README) | +1 962 / −558 | **Lo que hace falta** (clase I de `migracion-128.md`) |
| **B.** 10.13/10.14 **sin** 10.15 | 69 | +1 935 / −501 | **Solo High Sierra** (guardas de 10.13); **Mojave ya tiene** esas APIs. Directorios: `services/shape_detection` 9, `chrome/services` 7, `components/system_media_controls` 6, `device/bluetooth` 4, `gpu/config` 3… |
| **C.** solo **10.7–10.12** | **101** | +3 068 / −1 102 | **Sobra** (`device/fido` 10, `components/remote_cocoa` 9, `partition_allocator`, `base/synchronization`…) |
| D. sin versión en las líneas | 4 | +497 / −647 | revisar |

**También sobra:** los parches de GPU para 10.7–10.9 (OpenGL antiguo), de `libc++` y `boringssl` para SO viejos, y la política que apaga la GPU en 10.7.
**Decisión de Titín pendiente:** si el mínimo es **Mojave**, la clase B sobra entera; si es **High Sierra**, la B entra (≈ 69 ficheros, unas 2 400 líneas).

## 5. Problemas conocidos en Mojave y lo visto en la 6,1 (pregunta 4)

**Issues de Legacy [V: títulos y hilos]:**

| Issue | Versión | Qué | Causa (si se sabe) |
|---|---|---|---|
| [#191](https://github.com/blueboxd/chromium-legacy/issues/191) | 117–119 | Colores mal con la GPU en Mojave (MacBook Air 2018) | Chromium borró apaños de GPU de SO antiguos; Legacy los repuso el 03-02-2024; sin causa confirmada |
| [#242](https://github.com/blueboxd/chromium-legacy/issues/242) | ≥ 121 (la 120 va) | Caída en `AutofillModelExecutor::Preprocess` (TFLite) | `OptimizationGuide`; se evita con `--disable-features=OptimizationHints` |
| [#221](https://github.com/blueboxd/chromium-legacy/issues/221) | 126.0.6460.0 | Mojave 10.14.6: se cierra al arrastrar una URL a una carpeta de pestañas | sin explicar; en #265, «la 123.0.6303.0 es la última sin problemas» |
| [#206](https://github.com/blueboxd/chromium-legacy/issues/206), [#276](https://github.com/blueboxd/chromium-legacy/issues/276) | 121, 124 | Caídas de páginas y al actualizar extensiones | #276 con arreglo propuesto |
| [#188](https://github.com/blueboxd/chromium-legacy/issues/188), [#231](https://github.com/blueboxd/chromium-legacy/issues/231) | — | Imágenes corruptas | sin causa; cerrados |
| [#256](https://github.com/blueboxd/chromium-legacy/issues/256), [#257](https://github.com/blueboxd/chromium-legacy/issues/257) | 127 (feb. de 2025) | **Gmail «garabateado»**; en #257 la 120 y la 124 abren Gmail, la 109 no | sin respuesta del mantenedor; **Waterfox 56 y Chrome 87 sí lo pintan** |
| [#210](https://github.com/blueboxd/chromium-legacy/issues/210) | 121 | GPU Helper aborta: «Symbol not found: `_VTIsHardwareDecodeSupported`» (10.9.5) | símbolo de 10.13; arreglado con guarda (mayo de 2024) |
| [#144](https://github.com/blueboxd/chromium-legacy/issues/144) | build 995 | GPU Helper cae al abrir `chrome://gpu` | traza por `MTLCopyAllDevices` → **Dawn** (`DiscoverDefaultAdapters`, `CollectDawnInfo`); sin arreglo documentado |
| [#198](https://github.com/blueboxd/chromium-legacy/issues/198), [#258](https://github.com/blueboxd/chromium-legacy/issues/258) | — | Congelaciones de pantalla; captcha de Cloudflare | sin causa |

**Lo que vio Titín en la 6,1 con la 127.0.6494.0** (`chrome://gpu`: ANGLE sobre Metal, WebGL2 y **WebGPU** aceleradas; claude.ai bien; **5 caídas de la GPU al arrancar**;
Gmail con «Ya no se admite esta versión» y sin estilos):

- **Gmail [H, probable]:** el aviso y la página «garabateada» salen cuando Google considera **vieja la versión declarada**. FlyWeb lo vivió con la 116: Drive decía «Ya no se admite esta versión»
  hasta que declaró una versión actual (`integracion.md`, pasos 21 y 24) [V]. Legacy declara **Chrome 127 (de mayo de 2024)**, ahora muy por debajo del mínimo de Google, y además es *Chromium*, no *Chrome*.
  Coincide con #256 y #257 (la 124 abre Gmail en 2025; la 127 no). **Prueba de 10 min:** lanzar con `--user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"`;
  si Gmail pinta, es la versión; si sigue sin estilos, hay una función que falta. (Los *Client Hints* seguirían diciendo 127: puede hacer falta cambiarlos también.)
- **Caídas de GPU al arrancar [H]:** la 127 de Titín tiene **WebGPU activo (Dawn sobre Metal)**; en Legacy la única traza de GPU Helper al arrancar pasa por **Dawn** (#144) y la 116 de FlyWeb **apaga** el servicio de WebGPU
  (`integracion.md`, paso 2). La 6,1 tiene **dos D500**, así que Dawn lista dos adaptadores. **Prueba de 10 min:** arrancar con `--disable-features=WebGPU` (y, si no basta, `--use-angle=gl`)
  y mirar `chrome://gpu` («GPU process crash count») y los informes de `~/Library/Logs/DiagnosticReports/Chromium Helper (GPU)*.crash`: **el nombre del módulo en la pila** (`dawn::native::metal`, `rx::mtl`, `gpu::CollectDawnInfo`)
  distingue Dawn de ANGLE. **Comparar** con FlyWeb 1.15.1 en la misma 6,1 (cuenta de caídas) y repetir en la 5,1.

## 6. Qué cambia en el plan de FM.31/FM.32

- **La clase I queda como estaba (25–55 h)** y se refuerza: el *donante* sigue siendo el diff de Legacy, **pero la parte de GPU (Dawn y ANGLE) es el punto sin cubrir y ahora tiene un síntoma real**: las caídas de la 6,1.
  Por eso la prueba de Titín (arranque con y sin WebGPU) **va antes de la Puerta 0**: cuesta 10 minutos y dice si la GPU es un riesgo grande o pequeño.
- **Gmail** no es un riesgo de la base, sino de la versión declarada: depende de la política de FlyWeb (nivel 131 declarado a todas las webs, sin excepciones por sitio; `motor.md`).

## 7. Recomendación (pregunta 5)

| Opción | Pros | Contras | Licencias |
|---|---|---|---|
| **A. Parches de Legacy sobre Brave 1.69.168** (recomendada) | Conserva Brave (privacidad, Shields, sync, componentes) y toda la identidad de FlyWeb; **31 de 44 ficheros de 10.15 idénticos en la 128**; solo se extraen los hunks de 10.15 (≈ 2 500 líneas) | Hay que **fusionar a mano** 13 ficheros y 2 parches de Brave; Dawn/ANGLE/Skia no vienen en su diff | Chromium y Legacy: **BSD-3**; brave-core: **MPL-2.0** (los ficheros de Brave que modifiquemos se publican); cada software con su licencia, raíz MIT |
| **B. Partir de su árbol de la 128** | — | **No existe**: su última rama real es 127 y el tronco 129 está sin parchear | — |
| **C. Partir de su árbol 127.0.6494.0 y subir a 128** | Parte de algo que arranca en Mojave (lo probó Titín) | Pierde Brave y toda la capa FlyWeb; sin parches de seguridad; sin comprobaciones; un único mantenedor ausente | BSD-3 |
| **D. Solo como referencia y banco de pruebas** | Sirve ya para la Fase 0 (qué cae primero en la 6,1 y la 5,1) | — | — |

**Además:**
1. **Espejo de seguridad (LOCAL, ~1 h):** `git clone --mirror` de `blueboxd/chromium-legacy` y de sus forks de terceros; el proyecto está parado y se ha visto que repos de Chromium antiguo desaparecen de GitHub [V (resultado): [libhunt](https://www.libhunt.com/r/chromium-legacy) y comentarios de HN]. BSD-3 lo permite; **conservar el aviso de copyright**.
2. **Dar crédito** en `about:credits` y en `FlyWeb/docs/` (BSD-3 exige conservar el aviso).
3. **Las dos pruebas de 10 min de §5** antes de la Puerta 0, con la 127.0.6494.0 que Titín ya tiene.

## 8. Qué falta

- Las dos pruebas de §5 y los informes de caída de la GPU (Titín o LOCAL).
- El tamaño de los forks de Dawn, ANGLE y Skia frente a su revisión de `DEPS` (solo vi los títulos de commit; las fusiones ocultan el contenido).
- El mínimo definitivo (High Sierra o Mojave): decide si entra la clase B.
- Confirmar con Momiji (v156) en la 6,1 como referencia de otro motor (V14 de `vision-motor.md`).

## 9. Fuentes

- [blueboxd/chromium-legacy](https://github.com/blueboxd/chromium-legacy): [releases](https://github.com/blueboxd/chromium-legacy/releases), [rama `master.lion`](https://github.com/blueboxd/chromium-legacy/commits/master.lion/?author=blueboxd),
  [wiki Building](https://github.com/blueboxd/chromium-legacy/wiki/Building), forks [dawn](https://github.com/blueboxd/dawn/commits/master.lion?author=blueboxd) y [skia](https://github.com/blueboxd/skia/commits/for-lion?author=blueboxd);
  issues [#144](https://github.com/blueboxd/chromium-legacy/issues/144), [#191](https://github.com/blueboxd/chromium-legacy/issues/191), [#206](https://github.com/blueboxd/chromium-legacy/issues/206), [#210](https://github.com/blueboxd/chromium-legacy/issues/210),
  [#221](https://github.com/blueboxd/chromium-legacy/issues/221), [#239](https://github.com/blueboxd/chromium-legacy/issues/239), [#242](https://github.com/blueboxd/chromium-legacy/issues/242), [#256](https://github.com/blueboxd/chromium-legacy/issues/256),
  [#257](https://github.com/blueboxd/chromium-legacy/issues/257), [#265](https://github.com/blueboxd/chromium-legacy/issues/265), [#276](https://github.com/blueboxd/chromium-legacy/issues/276).
- Medidas propias por Git: `blueboxd/chromium-legacy` (tag `1303823`, rama `master.lion`) frente a `chromium/chromium` (tags 127.0.6494.0 y 128.0.6613.138), solo árboles [V].
- [Momiji v156, Low End Mac](https://lowendmac.com/2026/momiji-v156-a-cutting-edge-firefox-for-10-7-10-14/) (resultado).
- Proyecto: `base-128.md`, `migracion-128.md`, `integracion.md` (pasos 2, 21, 24), `vision-motor.md`, `docs/TAREAS.md` (FM.31, FM.32, FM.33).
