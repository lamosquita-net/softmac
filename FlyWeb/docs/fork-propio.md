# De parches sobre la 128 a un árbol propio de Chromium (estudio de ARQUITECTURA)

ARQUITECTURA (Fable 5.1), 03-11-2026. Encargo de Titín por COORDINACIÓN-24 (`DIRECTIVAS.md`, «Evolucionar el fork en vez de
parchear»). **Solo papel.** Lee `vision-motor.md`, `legacy-evolucion.md`, `chromium-legacy.md`, `g5-viabilidad.md`, `base-128.md`,
`mojave-128.md`, `macos11-niveles.md`, `motor-niveles.md`, `investigacion-pendiente.md`, `plan-fork.md`, `relevo-motor.md`,
`version-2.0.0.md`…`version-2.7.0.md` y `docs/CONSUMO.md`, y mide el fork de brave-core (`origin/flyweb` ac280a17df3 frente a
`v1.69.168`) y el checkout de la 128 de la 7,1. Marcas: **[V]** medido o leído en código o informe; **[I]** inferencia mía;
**[N]** sin comprobar.

## 1. Conclusión

**Sí, y pronto: justo después de publicar la 2.7.0, antes de que el 139 llegue a LOCAL.** Pero con dos precisiones que cambian el
sentido de la pregunta:

1. **Cambiar la representación, no la base.** Lo que se propone es que los cambios de FlyWeb sobre Chromium 128.0.6613.138 vivan
   como **commits en un árbol git propio** (fork de `chromium/src` y de `v8/v8`), en vez de como 1 957 ficheros `.patch` que
   `apply_patches` vuelve a aplicar en cada compilación. La base sigue siendo la 128 y los niveles siguen siendo portes función a
   función (`motor.md`), como manda la idea rectora del 20-10. **No** se propone seguir el tronco de Chrome ni rebasar el árbol
   entero a cada Chrome N: ese es el método de Chromium Legacy (fusión diaria, 17 % de commits dedicados a arreglar fusiones,
   `chromium-legacy.md` §3) y, además, nos traería de golpe las subidas de mínimo de macOS (129 → 11, 139 → 12, 151 → 13) que la
   doctrina actual esquiva (`macos11-niveles.md` §7, `plan-fork.md` §1).
2. **Dos capas con destino distinto.** Capa **permanente**: lo que es nuestro de verdad (traducción a Mojave, privacidad, identidad,
   apagados, seguridad propia; hoy ~26 parches de Mojave con ~620 líneas más `chromium_src`, `macos11-niveles.md` §9.1). Capa **de
   nivel**: los portes de Chrome N, que por definición ya existen upstream y **se tiran** el día que la base suba. Con parches las dos
   capas están mezcladas en el mismo fichero `.patch` (un diff por fichero de Chromium «que incluye lo de Brave», `tools/port/README.md`);
   con commits etiquetados se separan, y eso es lo que convierte el próximo salto de era (139 o 151, cuando Titín lo decida con los
   criterios de `plan-fork.md` §6) de «rehacer 1 400 parches a mano» en «rebasar la capa permanente y descartar la de nivel».

Lo que **no** arregla el árbol propio, y hay que decirlo claro: la deuda que más crece por nivel es que **la 128 no tiene la
infraestructura de la que dependen los portes** (parser CSS por *stream*, `SizeType`/`calc-size`, `BoxFragmentBuilder`,
`ThenCallable`, `ExternalPointerTable`…; §3). Eso es un problema de **base**, no de formato, y la decisión de cuándo subirla sigue
siendo la de `plan-fork.md`. El árbol propio la hace más barata (traer una cadena de refactor es `git cherry-pick A..B`, no «65 commits
que chocan consigo mismos») y hace medible el salto (un ensayo en seco de rebase da la cifra), pero no la elimina.

## 2. Cómo está montado hoy [V]

| Qué | Medida (brave-core `origin/flyweb` frente a `v1.69.168`, 03-11) |
|---|---|
| Commits de FlyWeb sobre Brave 1.69.168 | 1 266 |
| Ficheros `.patch` en `patches/` | 590 (Brave) → **1 957** (+1 367 nuestros, 29 de Brave modificados) |
| Peso de `patches/` | 0,5 MB (Brave) → **21,7 MB** (×43) |
| Parches de Blink | 54 → **956** |
| Parches de V8 | 2 → **253** (se rehacen contra la V8 de cada nivel) |
| Parches de dependencias (`third_party/`: boringssl 24, skia 8, angle 5, simdutf 5) | 49 |
| `chromium_src/` (identidad, privacidad; mecanismo de Brave, no se toca aquí) | 1 549 → 1 555 ficheros |
| Tamaño de los parches | 1 419 de menos de 2 KB; 10 de más de 200 KB. Los 12 mayores (14 MB) **no son parches, son versiones nuevas de dependencias y datos**: vectores de prueba de ML-KEM de BoringSSL (8,9 MB), `simdutf.cpp` (2,8 MB), `transport_security_state_static.json` (4,2 MB), Root Store |
| Árbol de Chromium 128 (`~/proyectos/chromium-128/src`) | 443 320 ficheros, 3,8 GB sin comprimir; `.git` con historia completa 65 GB |

Flujo de un nivel (`tools/port/README.md`, `motor-niveles.md`): MOTOR monta un área `w-<nombre>` con los ficheros de la 128 más los
parches de la rama, aplica commits de upstream con `git apply --reject`, resuelve `.rej` (desde el 136, a tres bandas en fuente con
`ap3.sh` y `git merge-file`), y **regenera** cada `.patch` como diff completo contra la 128 (`generar128.sh`). LOCAL, en cada
compilación, pone la V8 del nivel (`FlyWeb/v8-revision`), trae `fast_float`/`dragonbox` (`build.sh`, `traer_dep_v8`), ejecuta
`npm run apply_patches` sobre el checkout de la 128 y comprueba enums (`comprobar-enums.py`). V8 ya es, de hecho, un árbol aparte
(etiqueta de Chrome N) **con 253 parches encima que se rehacen cada nivel** con `v8re.sh`: es la peor combinación de las dos
representaciones, base móvil y cambios en formato parche.

## 3. Lo que cuesta el método actual, con datos

Resumen de `motor-niveles.md`, `relevo-motor.md` y `version-2.x.md` (tabla completa en los informes; aquí lo que pesa):

| Nivel (versión) | Blink real | V8: parches rehechos, de ellos fallan | Solo salió al compilar o ejecutar | Vueltas MOTOR↔LOCAL |
|---|---|---|---|---|
| 132 (2.1.0) | 9–14 h papel | 61 → 32 | 2 arreglos | 2 |
| 133 (2.2.0, no publicada) | 20–28 h papel | 76, fallan 5 | 3 *flips* perdidos al regenerar el json5 | — |
| 134 (2.3.0) | 6–9 h | 79, fallan 10 | 6 errores (4 parches huérfanos), **2 caídas** (`SpinningMutex` en Mojave; `CHECK` de V8 contra IDL de la 128) | 4 |
| 135 (2.4.0) | 14–22 h | 104, fallan 7 | 2 rondas | 2 |
| 136 (2.5.0) | 21–27 h | 239, fallan 4 | **13 arreglos, 3 caídas, 9 regresiones** (hunks con *fuzz* fuera de su función: nace `fuera.py`) | ≥4 |
| 137 (2.6.0/2.6.1) | ~21 h | 256, fallan 11 | 0 errores; **2.6.1** por un enum fuera de orden (UseCounter aborta en Speedometer) | 2 |
| 138 (2.7.0, en curso) | ~23 h (33 h total) | **252, fallan 44 (17,5 %; 9,8 % en el 137)**; 27 borrados, 7 a SEGURIDAD | 6 ficheros de «adaptación al árbol de la 128»; 5 bloques aplazados al 139 (14–22 h) | 1, en curso |

Tendencias [V]:

- **La capa de V8 crece y aplica peor**: 61 parches (132) → 252 (138); rechazos del 10 % al 17,5 %. Cada nivel se rehacen a mano, se
  «sueltan» los que upstream ya lleva (27 en el 138) y se vuelven a poner los 11 arreglos solo-LTS. Esto es exactamente lo que
  `git rebase --onto <etiqueta N> <etiqueta N−1>` hace solo: descarta lo ya upstream por `patch-id`, fusiona a tres bandas y recuerda
  resoluciones (`rerere`).
- **Los fallos propios del formato parche son reales y repetidos**: hunks aplicados con *fuzz* fuera de su función (136, 137; `fuera.py` y
  `enumorden.py` existen para cazarlos), regenerar un `.patch` desde un área montada antes borra commits (MOTOR-27/28), un 503 de gitiles
  convierte un fichero en «nuevo» (MOTOR-44), parches huérfanos del *taint* viejo (2.3.0), *flips* perdidos del json5 (2.2.0). Un
  `cherry-pick` a tres bandas deja marcas de conflicto en vez de colocar mal un trozo; un commit no se «regenera».
- **Lo que de verdad crece es la deuda de base**: aplazados «porque la 128 no tiene el refactor» 1 (132) → 2 (135) → 4 (136) → 5 bloques
  (138); dependencias que la 128 no tiene desde el 134 (simdutf, fast_float, dragonbox, Temporal en Rust); caídas V8-nueva × Blink-128
  que solo salen en ejecución (0 en 132–133 → 2 en 134 → 1 en 136 → riesgo anotado en 138). Esto **no lo arregla el formato**; ver §1.
- **El coste en dinero no está medido por nivel**: `CONSUMO.md` da mínimos de sesión (MOTOR-42: 15 $; SEGURIDAD-PORTES 20–25 $ por nivel)
  y nada de LOCAL ni D8. No baso la decisión en dólares; sí en horas reales (Blink 21–27 h por nivel desde el 136, estable) y en los
  recuentos de arriba.
- **LOCAL pesa más que MOTOR en reloj**: en el 130, 1,6 h de MOTOR frente a 7–8 h de compilación (`motor-niveles.md` «Nivel 131» §9). Las
  vueltas por errores de compilación son el multiplicador; cada fallo del formato parche es una vuelta más.

## 4. Lo que dicen los informes de otros motores

- **Ninguno plantea un árbol git propio con la base fija**; todos asumen `patches/` de Brave. Lo que critican (`chromium-legacy.md` §3,
  `legacy-evolucion.md` §5.5) es **seguir el tronco a diario**, no git: «el coste de seguir a Chromium cada día es del método y no lo
  pagamos: nuestra base es fija». Así que los informes no aportan evidencia en contra de esta propuesta, y tampoco a favor: nadie midió
  rehacer parches frente a rebasar commits.
- **Legacy** mantiene su árbol como rama larga con 200 commits propios, forks superpuestos de Skia, ANGLE, Dawn, SwiftShader, WebRTC,
  libc++ y BoringSSL, sin fork de V8 y sin pruebas (`chromium-legacy.md` §3). Su parche permanente es de 470–650 ficheros según el
  mínimo de macOS (`legacy-evolucion.md` §6): ese es el tamaño que debería tener nuestra **capa permanente**, no los 1 957 parches.
- **WebKit/Gecko** (`vision-motor.md`): lo aceptado es de distancia 0–1 (capa de plataforma aislada por directorio, reglas de C++ seguro,
  Rust solo en código nuevo, política ESR escrita). Nada de ello toca zona caliente de Blink ni depende del formato; la capa de plataforma
  aislada (V1, modelo `platform/` de WebKit) es justamente la capa permanente de §1 y la capa de compatibilidad de la fila FM.45.
- **Portes futuros**: Linux es «recompilar el mismo árbol con GN de Linux» (V10): un fork de `chromium/src` es exactamente lo que un porte a
  Linux o Android necesita, y la capa permanente etiquetada dice qué es solo de Mac. iOS es WebKit obligado (V9) y el G5 no admite motor
  moderno (`g5-viabilidad.md` §4.2): a ninguno de los dos lo cierra ni lo abre esta decisión. El diseño no debe cerrar nada: por eso la
  capa permanente va por **clase y plataforma** (§5.2), no mezclada con los portes.

## 5. Diseño propuesto

### 5.1 Repositorios

| Repo | Qué | Cómo [I] |
|---|---|---|
| `lamosquita-net/chromium` | fork de `chromium/src`; rama `flynk` desde la etiqueta `128.0.6613.138` | **Fork en GitHub de `chromium/chromium`**, no repo nuevo: los objetos de upstream los comparte GitHub y solo subimos nuestros commits [N: comprobar que GitHub deja bifurcar ese espejo]. Si no, repo nuevo con la 128 como commit raíz injertado (3,8 GB sin comprimir, ~1–1,5 GB en pack [N]) subido por partes (límite de 2 GB por `push`) |
| `lamosquita-net/v8` | fork de `v8/v8`; rama `flynk-v8` sobre la etiqueta de la V8 de Chrome N | igual; el `DEPS` de nuestro Chromium fija el commit de nuestra rama (adiós `FlyWeb/v8-revision`) |
| `lamosquita-net/brave-core` | sigue: `chromium_src/`, `build/config.gni` (`flyweb_engine_level`, `flyweb_version`), argumentos, iconos | `patches/` **vacía para `src` y para `v8`**; quedan de momento los 49 de `third_party/` (angle, skia, boringssl, simdutf), que son subrepositorios de `DEPS` y se migran en §6 F4 |
| `lamosquita-net/brave-browser` | sin cambios | `.gclient` apunta `src` a nuestro fork |

El árbol de Chromium vive **solo en local (7,1) y en GitHub**, nunca en la carpeta de red (Samba/Drive no puede con 443 000 ficheros ni
con un `.git` de 65 GB). Es una excepción a «ficheros de trabajo en la red» de `CLAUDE.md` y la decide Titín (§9). Hoy ya es así de hecho:
`flyweb-build` y `chromium-128` son locales.

### 5.2 Reglas de los commits

- **Portes de upstream**: `git cherry-pick -x <commit>` (deja «cherry picked from commit …»); cuando no se porta la cadena sino «la forma
  final del N» (`relevo-motor.md`, MOTOR-27), el mensaje cita la etiqueta y los ficheros de referencia.
- **Trailers obligatorios**: `Flynk-Level: 139` y `Flynk-Class:` con uno de `port` (de upstream, desechable al subir de base), `compat`
  (traducción a 10.14; la capa de FM.45), `privacy`, `identity`, `disable` (apagados: Graphite, Leo, Finch…), `security` (CVE portado;
  cita el commit de upstream), `dep` (subida de dependencia en `DEPS`). Y, si solo vale para una plataforma, `Flynk-Platform: mac`.
- **Ramas**: `flynk` (lo publicado; etiqueta `flyweb-2.N.0` por versión), `motor/N` (MOTOR), `seg/<fila>` (SEGURIDAD-PORTES),
  `local/<versión>-arreglos` (LOCAL), como hoy en brave-core. Un nivel entra en `flynk` por fusión, no por *squash*: la historia es el
  inventario.
- **Nada se borra** («apagar, no borrar», Titín 03-11): los apagados son commits `disable`, pequeños y revertibles.
- `rerere` activado y su caché compartida en el repo (`git rerere` + `contrib/rerere-train.sh`) para que la nube y la 7,1 no resuelvan dos
  veces el mismo conflicto.

### 5.3 Flujo por nivel (lo que cambia para MOTOR)

1. Inventario como hoy (`baseline-nivel.js`, `flags-nivel.py`, cruce wpt.fyi, `git log <N−1>..<N>`; el espejo `chromium/chromium` con
   `--filter=tree:0` sigue valiendo para `git log --grep`; también puede ser un `remote` del fork).
2. En vez de `portar128.sh` + `generar128.sh`: clon parcial del fork (`--filter=blob:none` + `sparse-checkout` de `third_party/blink`…),
   rama `motor/N`, `git cherry-pick -x` por commit; conflicto = marcas en el fichero, no `.rej`. `fuera.py` y `enumorden.py` pasan a leer
   `git diff <base>..HEAD` (misma lógica, otra entrada); `chk128.sh` desaparece (ya no hay nada que «aplique»).
3. V8: `git rebase --onto <etiqueta N> <etiqueta N−1> flynk-v8`; lo ya upstream cae solo; lo que choca se resuelve una vez. Los 11
   arreglos solo-LTS son commits normales que viajan en el rebase.
4. Entrega: ramas en los dos forks + rama de brave-core (si toca `chromium_src` o `config.gni`). D8-LINUX compila la d8 desde
   `lamosquita-net/v8` rama `motor/N` sin brave-core ni parches.

### 5.4 Lo que no cambia

La doctrina del motor (`motor.md` 1–13), la ficha de nivel (`plan-fork.md` §4), el orden fijo d8 → LOCAL → PUBLICACIÓN (Titín 02-11), la
versión declarada, la privacidad (regla 20), `chromium_src`, `about:credits` (Blink y Chromium siguen citados), la obligación de publicar
las fuentes (MPL-2.0 para lo de Brave, en brave-core; BSD para Chromium, en el fork público) y «nunca `gclient sync -D`».

## 6. Plan por fases con hitos (sin horas)

| Fase | Qué | Hito que la cierra | Quién |
|---|---|---|---|
| **F0 Prueba** (puede empezar ya, no compila nada) | Crear los forks; guion `convertir.sh` que **reproduce la historia** de brave-core `flyweb` (1 266 commits) como commits del árbol: para cada commit, aplicar sus `.patch` a la 128 limpia (`~/proyectos/chromium-128/src`) y hacer commit con el mismo mensaje y los trailers deducibles (nivel por `config.gni`; clase por ruta y autor). Igual para `patches/v8` sobre la V8 de cada nivel | `diff -r` **vacío** entre el árbol convertido en `flynk` y el `src` de la 7,1 tras `apply_patches` de la 2.7.0 (sin `.git`); medidos el tamaño del `push`, el tiempo de clon parcial desde la nube y el de `git status` en la 7,1 | LOCAL (guion de ARQUITECTURA/MOTOR; solo git, sin compilar, no compite con la Release) |
| **F1 Corte** (tras publicar la 2.7.0 y **antes** de que el 139 llegue a LOCAL) | `flynk` = 2.7.0; `patches/` de brave-core vacía para `src` y `v8`; `.gclient` y `setup-build.sh` al fork; `build.sh` sin `apply_patches` ni `v8-revision` ni `traer_dep_v8`; la rama `motor/139` en curso se convierte con el mismo guion (no hay congelación: la conversión es determinista) | Una compilación de la 2.7.0 desde el árbol arranca en la 6,1 con `motor-138.html` en verde y las mismas WPT que la publicada. No se publica nada nuevo; la 2.8.0 ya sale del árbol | LOCAL, con COORDINACIÓN |
| **F2 Herramientas** | Flujo de §5.3; `fuera.py`/`enumorden.py` sobre git; `rerere` compartido; `TRAMPAS.md` y `tools/port/README.md` reescritos; `add_repo` de los dos forks en el arranque de MOTOR y SEGURIDAD-PORTES | **El 139 (2.8.0) entregado desde el árbol**: primer nivel nativo, con su fila FS por `cherry-pick -x` | MOTOR, SEGURIDAD-PORTES |
| **F3 V8 y d8** | `flynk-v8` por rebase; `DEPS` del fork fija V8; D8-LINUX clona el fork | El 140 con V8 por rebase; d8 compilada en el Ubuntu desde el fork sin parches | MOTOR, D8-LINUX, LOCAL |
| **F4 Limpieza** | Lo que es dependencia va a `DEPS` (simdutf, dragonbox, fast_float, BoringSSL con ML-KEM, Root Store, HSTS); los 26 parches de Mojave pasan a commits `compat` en la capa de FM.45; los 49 de `third_party/` a forks o `DEPS`; inventario `Flynk-Class` completo | `patches/` de brave-core a cero; `git log --grep='Flynk-Class: compat'` es la lista de la capa de compatibilidad | MOTOR, LOCAL |
| **F5 Ensayo del salto** (cuando `plan-fork.md` §6 lo pida; antes, solo como medida) | En seco: `git rebase --onto 139.0.x` (o 151) **solo de la capa permanente**; contar conflictos y ficheros | Cifra real del coste de subir de base, para que Titín decida con medidas y no con horas de papel | INVESTIGACIÓN-MOTOR, MOTOR |

**Por qué justo ahí el corte:** la 2.7.0 es la condición que puso Titín; el 139 es el primer nivel con la serie vetada de macOS 12
(`macos11-niveles.md` §3b) y con 5 bloques aplazados del 138 que exigen traer cadenas de refactor: es el nivel que más gana con
`cherry-pick` y el que peor casaría con parches. Esperar al 140 o al 141 no abarata nada y suma dos niveles más de parches que convertir.

## 7. Riesgos

| Riesgo | Gravedad | Cómo se acota |
|---|---|---|
| GitHub no deja bifurcar `chromium/chromium` o el fork tarda horas [N] | media | Plan B en §5.1: repo nuevo injertado, subido por partes. F0 lo mide antes de decidir |
| La conversión no reproduce el árbol de `apply_patches` (algún parche con *fuzz* aplica distinto) | alta si pasa, baja de probabilidad | Hito de F0 es `diff -r` vacío; si hay diferencias, se miran una a una (son hallazgos: hunks mal colocados hoy) |
| La nube trabaja peor con un repo de 443 000 ficheros | media | Clon parcial + `sparse-checkout` (ya usan `tree:0` para el espejo); `cherry-pick` baja blobs bajo demanda. F0 mide el tiempo |
| Dos checkouts de 100–150 GB en la 7,1 durante F0–F1 | baja | `chromium-128` ya existe y comparte objetos; se compila en otro `out/`; no hace falta bajar nada |
| MOTOR pierde ritmo rehaciendo herramientas en pleno 139 | media | F2 se entrega **con** el 139, no antes; la conversión de `motor/139` es por guion; ARQUITECTURA ayuda con el flujo |
| Tentación de «ya que tenemos árbol, rebasamos a Chrome N» | alta | Directiva explícita: la base sube solo por decisión de Titín con los criterios de `plan-fork.md` §6; el fork no cambia eso |
| Los 590 parches de Brave quedan como primer commit del árbol y una futura fusión de Brave se complica | baja | «Brave no se sigue por número» (22-10): lo de privacidad se trae a mano y con consenso (FM.37); un diff de Brave se aplica igual de bien sobre commits |
| La historia intermedia de `flynk` no compila: **515 de 817** commits llevan `Flynk-Convert-Failed` (LOCAL-20, 06-11; `flynk-v8`: 86) | media (solo la punta vale para *bisect*) | **Límite conocido y estructural**, no de contexto: 514 de los 515 son la historia 1.x de brave-core (parches para Chromium 115/116: 74 de 76 y 440 de 481 commits) proyectada sobre la 128; esos parches nunca fueron para la 128 y reconvertir con más contexto no los arregla. En los 260 commits con base 128 falla **uno** (4d8dd2c2a9, `core/dom/build.gni` «ya existe», arreglado en el commit siguiente). Arreglo barato mientras no haya *push*: convertir desde el primer commit de base 128 (brave-core 6918a99aa6, `RANGE=6918a99aa6^..flyweb`), con la 1.x fuera del árbol (sigue en brave-core). Decide COORDINACIÓN antes del primer *push* |
| Secretos o datos personales en el árbol público | alta | Igual que hoy en brave-core (público): nada de claves ni datos; `lastchange` y `build-info` no llevan rutas de usuario |

## 8. Qué cambia para cada agente

- **MOTOR**: trabaja en el fork de Chromium (y de V8) con `cherry-pick`/`rebase`, trailers de §5.2 y `rerere`; deja de generar `.patch`;
  los `nivelN-commits.tsv` pasan a ser `git log`. Su tabla de aplazados «la 128 no tiene» se convierte en cadenas de refactor
  candidatas a traer entera (F2+).
- **SEGURIDAD-PORTES**: CVE por `cherry-pick -x` en los dos forks con `Flynk-Class: security`; la lista de lo portado es
  `git log --grep`; la revisión de la regla 17 compara `git log <N−1>..<N> -- <ficheros del porte>` con lo que ya está en `flynk`.
- **SEGURIDAD-VIGÍA**: el triaje cita commits de upstream y comprueba con `git merge-base --is-ancestor` si ya están.
- **LOCAL**: F0 y F1 (conversión y compilación de comprobación); `setup-build.sh`/`build.sh` más cortos (sin `apply_patches`, `v8-revision`,
  `traer_dep_v8`, `.patchinfo`); los arreglos de compilación son commits en `local/<versión>-arreglos` del fork, no parches; `git bisect`
  entre niveles pasa a ser posible.
- **D8-LINUX**: clona `lamosquita-net/v8` en la rama del nivel; `gn gen` y `ninja`; sin brave-core ni `apply_patches`.
- **PUBLICACIÓN**: `flyweb-build-info.txt` y `flyweb://version` registran el commit del fork además del de brave-core; `about:credits` no
  cambia.
- **COORDINACIÓN**: filas y textos de arranque con los repos nuevos (`add_repo` lo ordena ella, Titín 02-11); `DIRECTIVAS.md`, `ARRANQUE.md`
  y `TRAMPAS.md` al día tras F1; vigila la tentación del riesgo 6.
- **INVESTIGACIÓN-MOTOR**: sus recetas por nivel citan commits a traer (`cherry-pick`) y refactors enteros; F5 es suyo.

## 9. Qué decide Titín

1. **Sí o no** al árbol propio, y el corte propuesto (tras publicar la 2.7.0, antes de entregar el 139 a LOCAL).
2. **Crear los forks públicos** `lamosquita-net/chromium` y `lamosquita-net/v8` en GitHub (licencia BSD; el nombre del repo, no de la
   marca: el código no se renombra, Titín 03-11).
3. **Excepción a «ficheros de trabajo en la red»** para el árbol de Chromium: solo local en la 7,1 y GitHub (§5.1).
4. **Que los 590 parches de Brave 1.69.168 entren como primer commit del árbol** (recomiendo sí: deja `patches/` a cero y evita que la
   capa de Brave y la nuestra choquen en 29 ficheros; «apagar, no borrar» sigue valiendo).
5. **Quién convierte**: propongo LOCAL en la 7,1 (tiene la 128 limpia y el checkout de la 2.7.0; es trabajo de git, sin compilar, y una
   compilación de comprobación en F1).
6. Reafirmar que **la base no sube con el fork**: solo por su decisión, con las medidas de F5 y los criterios de `plan-fork.md` §6.

## Fuentes

Medidas propias del 03-11: brave-core `origin/flyweb` ac280a17df3 frente a `v1.69.168` (6918a99aa67) con `git diff --name-status`,
`git ls-tree -r -l`; `~/proyectos/chromium-128/src` (d6209c7e65ea9, `git ls-tree -r -l HEAD`, `git count-objects`);
`FlyWeb/scripts/build.sh`; `FlyWeb/tools/port/README.md`. Informes: los citados en la cabecera, leídos por cuatro subagentes y
contrastados con el código donde había cifra.
