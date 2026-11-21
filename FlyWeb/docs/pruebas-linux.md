# Estudio: pasar al PC de Ubuntu las pruebas de Chromium que no dependen del Mac

ARQUITECTURA, 21-11-2026. Encargo de Titín (DIRECTIVAS, «Carga de la MacPro7,1», 20-11 ~21:00 UTC) por COORDINACIÓN-57
(`buzon/ARQUITECTURA/20261120-2100-COORDINACION-57-pruebas-linux.md`); entrega a COORDINACIÓN-58. Estudio en papel: **no he
compilado ni ejecutado nada**. Sí he leído el árbol de la 156, las series de `FlyWeb/seguridad/` y los registros de ninja
de la 7,1 (solo lectura).

Marcas: **[V]** comprobado por mí en el árbol o en un registro; **[R]** consta en el repo, sin volver a comprobar;
**[I]** deducción sobre datos [V] o [R]; **[S]** suposición, sin dato.

## 1. Conclusión

1. **Sí se puede, y recomiendo probarlo, pero quita una parte de la carga de la 7,1, no la mayor.** Lo que pesa de las
   pruebas en la 7,1 no es pasarlas, es enlazarlas: cada binario de pruebas se enlaza con ThinLTO en la carpeta de la
   oficial, entre 1 y 14 minutos a todos los núcleos [V, §2]. Los binarios que pueden irse suman ~39 min de enlaces y
   ~45 min más de compilación la primera vez [I]. La compilación de la app (3 h 20 min la oficial [R]), las pruebas de
   interfaz y las de brave-core se quedan en la 7,1.
2. **Qué vale en Linux** (§3): las pruebas unitarias de código común (Blink, `url`, `net`, `content`, `components`…)
   cuando el parche no toca ficheros de Mac ni condicionales de plataforma. De los 292 parches de chromium de las tandas
   3.0.1 → pendiente, **el 41 % se puede dar por probado solo con Linux**, el 4 % en las dos máquinas, el 15 % solo en
   Mac (interfaz, `chrome/`, ficheros de Mac), el 20 % solo trae pruebas de navegador (segunda fase) y el 20 % no trae
   ninguna prueba [V el recuento; I la regla].
3. **El árbol tiene que ser el nuestro** (fork de chromium + brave-core), no un Chromium limpio (§4). Sobre un Chromium
   limpio, un *cherry-pick* idéntico al de Google ya lo probó Google; lo que nos falta saber es si pasa **con nuestros
   cambios encima**.
4. **Linux prueba más que la 7,1 en un punto:** las pruebas de la 7,1 corren sin DCHECK (`dcheck_always_on=false` [V]).
   En la Ubuntu irían con DCHECK, como la d8, y se puede pasar el binario entero en vez de un filtro.
5. **El obstáculo es el disco, no la RAM** (§5): hacen falta del orden de 60–75 GB [I] y el 05-11 quedaban 38 GB [R].
   Con 30 GB de RAM basta, sin LTO y con `-j 12`–`16` [R]. Primera compilación: 3–5 h [S]. Por tanda: 15–40 min [S].
6. **Tres riesgos:** (a) nadie ha compilado nuestro brave-core en Linux desde el 05-11 [R]: puede haber roturas que
   arreglar antes de la primera prueba; (b) el PC solo trabaja cuando Titín está en Ubuntu: si está apagado, las pasa
   LOCAL, como con la d8; (c) hoy lo prohíbe una directiva («nunca compilar Blink» en la Ubuntu, 07-11): hay que
   cambiarla, y eso es de Titín y de COORDINACIÓN (§7).
7. **Quién:** la misma D8-LINUX, ampliada, con un guion; Sonnet basta (§6).
8. **Propuesta para Titín:** un piloto en la tanda siguiente, pasando las mismas pruebas en las dos máquinas una vez y
   comparando; si coinciden, LOCAL deja de pasar las del nivel A (§8).

## 2. Qué carga se quitaría de la 7,1

Fuente: `out/Completa320f/.ninja_log` y `args_generated.gni` del árbol de LOCAL (`~/proyectos/b2-porte-mac/src`), leídos
el 21-11 [V]. Una fila por binario; cuento la última compilación de cada objeto.

| Binario | Objetos de prueba | Compilarlos (min-hilo) | Enlace | ¿Puede irse? |
|---|---|---|---|---|
| `blink_unittests` | 1 478 | 614 | 536 s | Sí |
| `components_unittests` | 2 854 | 484 | 837 s | Sí |
| `content_unittests` | 579 | 189 | 246 s | Sí |
| `net_unittests` | 457 | 78 | 388 s | Sí |
| `media_unittests` | 357 | 43 | 78 s | Sí, salvo lo de VideoToolbox |
| `blink_platform_unittests` | 273 | 31 | 132 s | Sí |
| `extensions_unittests` | 249 | 27 | 117 s | Sí |
| **Suma de los que pueden irse** | **6 247** | **1 466** | **2 334 s (39 min)** | |
| `unit_tests` (de `chrome/`) | 2 349 | 565 | 819 s | No (interfaz) |
| `browser_tests` | 1 888 | 853 | 691 s | No |
| `views_unittests` | 149 | 25 | 156 s | No (§3.1) |
| `brave_unit_tests`, `brave_browser_tests` | — | — | 379 s y 369 s | No (código nuestro, solo Mac) |

- **Los enlaces son ThinLTO** [V]: las pruebas se compilan en la misma carpeta que la app, con `is_official_build=true`;
  `build/config/compiler/compiler.gni:90-94` lo activa en Mac con lld, y `out/Completa320f/thinlto-cache` tiene 136 107
  entradas. Un enlace así ocupa todos los núcleos. Es lo que más se nota al trabajar en la máquina [I].
- **Los min-hilo sobrestiman** (suma de duraciones con 32 trabajos a la vez); sirven para comparar binarios, no como
  reloj. A reloj, los siete binarios desde cero son ~45 min de compilación más 39 min de enlaces [I].
- **Por tanda** se repiten los enlaces de los binarios que se pidan (un parche cambia el código y obliga a enlazar de
  nuevo) y se recompila lo que dependa de las cabeceras tocadas. En la 3.1.4 se pidieron cinco binarios
  (`ninja-314-*.log` [V]); en la 3.2.0, seis (`buzon/LOCAL/20261120-1623-…` y `…-2025-…` [R]).
- **Lo que no cambia:** la compilación incremental de la app en cada tanda (9 150 pasos en bt-320e [R]), los enlaces de
  la app, `brave_unit_tests`, `brave_browser_tests`, `browser_tests` y las pruebas a mano en la 6,1.

Mi estimación: se va **entre media hora y hora y media de 7,1 saturada por tanda** [I], de unas 4–6 h. Ayuda, pero la
medida que más alivia es la que Titín ya ha ordenado (prioridad de fondo y `-j 24`).

Sin montar nada, hay otra mejora: **pedir en cada tanda solo el binario más pequeño que contenga la prueba**.
`components_unittests` y `unit_tests` cuestan 14 min de enlace cada uno; `blink_platform_unittests`, 2.

## 3. Qué pruebas valen en Linux como prueba de un parche que sale en Mac

### 3.1 Criterio

Una prueba pasada en Linux vale si **el código que ejercita es el mismo fichero fuente en las dos plataformas** y el
parche no cambia de comportamiento según la plataforma. Lo que Linux **no** prueba, y sigue en la 7,1 o en la 6,1:

- que el parche compila y enlaza para Mac (lo prueba la compilación de la app, que no se mueve);
- las ramas `BUILDFLAG(IS_MAC)`, los `.mm` y `*_mac.*`, Cocoa, el sandbox de Mac, la GPU real y macOS 10.14;
- la interfaz: en Mac, Views usa otra implementación.

Datos del árbol de la 156 [V]:

- **Blink:** de 13 292 ficheros `.cc/.h/.mm` de `third_party/blink/renderer`, 44 son de Mac (0,3 %) y 169 tienen algún
  condicional `IS_MAC`/`IS_APPLE` (1,3 %). **`url/`:** ninguno.
- **Views (menús):** `ui/views/controls/menu` tiene 17 ficheros propios de Mac (`menu_runner_impl_cocoa`,
  `…_remote_cocoa`, `…_mac`) y `menu_runner_unittest.cc` lleva bloques `IS_MAC`. Pasar `MenuRunnerTest` en Linux
  ejercita otra implementación: **no vale** para el UAF de menús de `portes-159/chromium/0001`.

### 3.2 Regla propuesta, en tres niveles

| Nivel | Cuándo | Dónde se prueba |
|---|---|---|
| **A. Linux basta** | El parche no toca ficheros de Mac, sus trozos no llevan condicionales de plataforma y su prueba unitaria está en un binario de código común: `blink_unittests`, `blink_platform_unittests`, `url_unittests`, `net_unittests`, `content_unittests`, `components_unittests`, `extensions_unittests`, `storage_unittests`, `services_unittests`, `media_unittests`, `cc_unittests`, `base_unittests` | Ubuntu |
| **B. Las dos** | Igual, pero algún trozo del parche lleva un condicional de plataforma | Ubuntu (parte común) y 7,1 (el filtro de siempre) |
| **C. Solo Mac** | Ficheros de Mac; `views_unittests`; `unit_tests` y todo `chrome/browser/ui`; `sandbox_mac_unittests`; `brave_unit_tests` y `brave_browser_tests`; `browser_tests`; lo que necesite GPU real; todas las pruebas a mano | 7,1 y 6,1, como hoy |

El nivel lo decide SEGURIDAD-PORTES al dar el APTO de cada parche, igual que hoy escribe qué prueba pasar. Con duda, C.

### 3.3 Cuántos parches caen en cada nivel

Recuento con un guion sobre los `chromium/*.patch` de `FlyWeb/seguridad/` (3.0.1 a `pendiente`), sin repetidos por
asunto: **292 parches** [V]. Método: ficheros que toca cada parche, por nombre (Mac, otra plataforma, prueba),
condicionales dentro de los trozos, y carpeta de la prueba unitaria que trae.

| Resultado | Parches | % |
|---|---|---|
| A. Linux basta | 119 | 41 % |
| B. Las dos | 12 | 4 % |
| C. Solo Mac: prueba en `views`, `chrome/` o `chrome/browser/ui` | 39 | 13 % |
| C. Solo Mac: toca ficheros de Mac | 4 | 1 % |
| Solo trae pruebas de navegador o `web_tests` (sin unitaria) | 58 | 20 % |
| No trae ninguna prueba | 57 | 20 % |
| Sin clasificar | 3 | 1 % |

- De los **175 que traen prueba unitaria**, 119 (68 %) son A.
- Solo en la 3.1.4, la 3.1.5 y `pendiente` (164 parches): A 67 (41 %), B 7, C 27, solo navegador 35, sin prueba 27.
- **Límites del recuento** [I]: clasifica por nombres y por el texto del parche, no por lo que ejecuta la prueba.
  «`chrome/`» va entero a C aunque parte no sea interfaz (el 13 % es un techo). El 20 % sin prueba no cambia: se sigue
  dando por bueno por lectura o a mano.
- Ejemplo con las cuatro pruebas pedidas el 20-11 para la 3.2.0 [R]: `AcceleratedStaticBitmapImageTest`
  (`blink_platform_unittests`), `*Canvas*Transform*:*ElementTest*` (`blink_unittests`) y `SchemeHostPortTest`/`OriginTest`
  (`url_unittests`) son A; `MenuRunnerTest` (`views_unittests`) es C.

### 3.4 Lo que Linux añade

- **DCHECK encendido.** En la 7,1 las pruebas van con `dcheck_always_on=false` [V]; muchas pruebas de regresión de
  seguridad detectan el fallo con un DCHECK. Mismo criterio que la d8 («encuentra más», `v8-d8.sh`).
- **Binarios enteros.** En la 7,1 se pasa un filtro por falta de tiempo. En la Ubuntu se puede pasar el binario entero y
  ver si el parche rompe una prueba vecina.
- **Base en la misma máquina.** Como con mjsunit: se pasa primero la base, se guarda la lista de fallos y cada tanda se
  compara con ella, no con la 7,1. Con DCHECK y nuestro árbol habrá fallos de base que no son del parche [S].
- **ASan, opcional y más adelante.** Muchos arreglos son UAF; con ASan la prueba falla de verdad sin el arreglo. Cuesta
  otra carpeta de salida (más disco). No lo propongo para el piloto.

### 3.5 Segunda fase (no ahora)

Los 58 parches que solo traen `content_browsertests` o `web_tests` son los más caros en la 7,1 (`content_browsertests`
no compiló en bt-320f sin excluir ficheros [R]). En Linux se pasan sin pantalla (`testing/xvfb.py` existe [V]), pero
piden enlazar `content_shell` y ejecutar un navegador en esa máquina. Lo dejaría para después del piloto y con decisión
aparte de Titín.

## 4. El checkout y cómo se mantiene al día

- **Mismo montaje que LOCAL** [V en su árbol]: `src` es `lamosquita-net/chromium` y `src/brave` es
  `lamosquita-net/brave-core` (los dos públicos, fetch anónimo por HTTPS); los parches de brave-core se aplican sobre el
  árbol de trabajo con `apply_patches`. Sin `src/brave` el árbol no genera (`root_extra_deps=["//brave"]`).
- **Hay precedente** [R]: el 05-11 MOTOR-30 tuvo en esa máquina Chromium 156.0.8078.90 para Linux con brave-core, en
  *component build*, con `-j 12` y un tope de 24 GB (`brave-propio.md` §12.1; `coordinacion.md`). No sé si ese checkout
  sigue ahí [S]: es lo primero que hay que mirar, porque ahorra la descarga.
- **Al día por identidad de árbol, no por confianza.** SEGURIDAD-PORTES ya da para cada serie la base, los parches y el
  árbol que debe salir (p. ej. «tras 0008 = 90418ba4fd» [R]). La Ubuntu hace lo mismo que LOCAL: `fetch`, `checkout` de
  la base, `git am` de la serie desde su clon de softmac y comparar `git rev-parse HEAD^{tree}`. Si no coincide, para y
  avisa. Con el mismo árbol, las dos máquinas prueban el mismo código.
- **Hueco que hay que cerrar: las bases tienen que estar subidas.** En el fork de chromium están `local/312` a
  `local/314-tests` y `seg/3.0.1` a `seg/3.1.1` [V], pero el trabajo de la 3.2.0 está solo en la 7,1 («sin subir» [R]).
  Propongo que LOCAL suba la rama base de cada candidata a los dos forks antes de pedir pruebas. Mientras tanto, la
  Ubuntu puede reconstruir la base desde la última rama subida más las series de softmac, comprobando cada árbol.
- **V8, Skia y ANGLE no cambian:** V8 sigue con la d8 y mjsunit; los parches de Skia y de ANGLE no traen pruebas que
  compilemos (`pendiente/CONTENIDO.md` [R]).
- **Pruebas que no compilan en nuestro árbol:** pasa también en la 7,1 (en la 3.1.4, `blink_unittests`,
  `content_unittests` y `browser_tests` se pararon en ficheros de prueba [V: `ninja-314-*.log`]). En Linux se excluyen
  igual, en una rama solo de pruebas, y se anota.

## 5. La máquina: disco, RAM y tiempos

- **Disco.** Chromium pide 100 GB libres (`docs/linux/build_instructions.md:18` [V]), pero para todo. Referencia medida
  en la 7,1 (`du`, 21-11 [V]): las fuentes con sus dependencias y un `.git` sin historial ocupan **33 GB**, y la carpeta
  de la oficial con la app y quince binarios de pruebas, **25 GB**. En Linux espero 35–40 GB de fuentes (con el
  *sysroot*) y 25–35 GB de salida en *component build* sin símbolos [I]. Total **60–75 GB** [I]. El 05-11 quedaban
  38 GB, con parada a 10 [R]. Si el checkout de MOTOR-30 sigue ahí, cabe muy justo; si no, **no cabe sin liberar o
  añadir disco**. Primer paso: `df -h` y `du -sh ~/d8-trabajo/*` en la Ubuntu.
- **RAM.** 30 GB bastan: sin LTO y en *component build* los enlaces son pequeños. Compilar Blink con `-j 32` no cabe
  (la d8 sola llega a 27 GB con `-j 32` [R]); `-j 12` con tope de 24 GB ya funcionó [R]. Empezar ahí y subir si aguanta.
- **Argumentos** (los de §12.1 de `brave-propio.md` [R]): `is_debug=false is_component_build=true symbol_level=0
  blink_symbol_level=0 use_remoteexec=false treat_warnings_as_errors=false`, más `dcheck_always_on=true`.
- **Tiempos.** No hay ninguna medida de Chromium en esa máquina [V: no consta en el repo]. Espero 3–5 h la primera
  compilación con `-j 12` [S] y 15–40 min por tanda, con enlaces de segundos [S]. Son los primeros datos que debe dar
  el piloto.
- **Pantalla.** Las pruebas unitarias del nivel A no la necesitan [S: no lo he ejecutado].

## 6. Quién lo opera

- **D8-LINUX, ampliada:** misma máquina, mismas reglas (sin push, sin llaves, sin datos de Titín, paquetes solo con
  `sudo apt-instalar`) y un solo canal. Es trabajo de receta: Sonnet 5.5 a esfuerzo medio, que es lo que COORDINACIÓN
  ya recomienda para la d8 [R].
- **Con un guion**, como `v8-d8.sh`: lee el encargo (bases, series, árboles esperados, binarios y filtros), prepara el
  árbol, compila, pasa las pruebas y deja una tabla (binario, pasan/total, fallos nuevos frente a la base). Lo escribe
  la nube; no es trabajo mío.
- **El encargo** lo escribe SEGURIDAD-PORTES en `buzon/D8-LINUX/`, en el mismo paso que el de la d8. El orden fijo queda
  igual: Ubuntu antes de LOCAL.
- **Si el Ubuntu está apagado, las pasa LOCAL**, como la d8 (DIRECTIVAS [R]). Un KEV (48 h) no puede depender de una
  máquina con arranque dual.
- **Seguridad de la máquina:** un checkout entero ejecuta más código ajeno que la d8 (hooks de `gclient`, `npm`,
  generadores). Valen las medidas de `estudio-compilar-ubuntu.md` §(c): usuario propio sin `sudo` ni acceso al `$HOME` de
  Titín, y clones anónimos sin URL de push.
- **Canal con la COORDINACIÓN en local:** hay que comprobar que D8-LINUX le puede escribir a la 58 [S].

## 7. Lo que habría que cambiar si Titín dice que sí (no lo toco yo)

- `docs/DIRECTIVAS.md`, «Nada de `chrome` entero en la Ubuntu» (07-11): hoy dice «nunca compilar Blink». Seguiría sin
  compilarse `chrome`; se compilarían binarios de pruebas, que incluyen Blink.
- `FlyWeb/tools/d8/CLAUDE-d8-trabajo.md` («Nunca… compilar Blink», y solo dos carpetas) y la fila D8-LINUX de
  `docs/TAREAS.md`.
- `docs/RELEVO-SEGURIDAD.md`: que cada APTO diga el nivel (A, B o C) de su prueba.

## 8. Propuesta para Titín

1. **P0 (10 min):** mirar el disco de la Ubuntu y si queda el checkout de MOTOR-30. Sin sitio para 60–75 GB en total,
   no se sigue.
2. **P1 (3–5 h de máquina, una vez):** montar el árbol con nuestra base, compilar los binarios del nivel A y pasar la
   base entera. Aquí sale el riesgo (a): cuánto de brave-core no compila en Linux.
3. **P2, piloto:** en la tanda siguiente, las pruebas del nivel A se pasan **en las dos máquinas** y se comparan. No
   ahorra nada esa vez; da el dato que falta.
4. **P3:** si coinciden, LOCAL deja de compilar y pasar las del nivel A.

La tanda del piloto la elige Titín. La siguiente según DIRECTIVAS es la 3.2.1 (#1165); no propongo retrasar la 3.2.0.

**Criterios de abandono:** una prueba del nivel A da distinto en Linux que en la 7,1 sin explicación; el Ubuntu está
apagado en la mitad de las tandas o más; arreglar brave-core para Linux cuesta más de una jornada.

**Decisiones que pido:** (1) piloto sí o no; (2) si se libera o se añade disco en la Ubuntu; (3) que LOCAL suba las
ramas base a los forks; (4) la segunda fase (§3.5) y ASan, después del piloto.

## 9. Qué he comprobado y qué no

- **Leído por mí:** `~/proyectos/chromium-156/src` (156.0.8078.90: `compiler.gni`, `ui/views/controls/menu`, Blink,
  `url`, documentos de Linux y de ASan); el árbol de LOCAL en solo lectura (`args_generated.gni`, `.ninja_log`,
  `ninja-314-*.log`, remotos, ramas subidas y tamaño en disco); los 292 parches de `FlyWeb/seguridad/`; DIRECTIVAS, la fila D8-LINUX,
  `v8-d8.sh`, `estudio-compilar-ubuntu.md` y `brave-propio.md` §11.7 y §12.
- **Sin comprobar:**
  - el disco libre de la Ubuntu hoy y si queda el checkout del 05-11;
  - que el brave-core actual compile para Linux;
  - los tiempos de §5 (todos [S]) y los tamaños en Linux (deducidos de los de la 7,1);
  - que los binarios del nivel A pasen sin pantalla en esa máquina;
  - que la clasificación automática de §3.3 acierte parche a parche: es para dar proporciones, no para decidir cada caso.
