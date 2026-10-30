# Estudio: compilar en el Ubuntu de Titín lo que toca MOTOR en Blink/Chromium

INVESTIGACIÓN-MOTOR-7, 30-10-2026, encargo de Titín por COORDINACIÓN-21 (entrega a COORDINACIÓN-22). Estudio en papel,
sin compilar nada. Etiquetas: **[medido]** = cifra registrada en el repo o en una fuente; **[estimado]** = cifra de
alguien sin medir (incluidas las mías); **[inferido]** = deducción. Recordatorio de `DIRECTIVAS.md`: las horas de
papel suelen salir pesimistas.

## Conclusión

1. **Sí, pero en modo ligero y como prueba de 2 niveles**: checkout de Brave 1.69 / Chromium 128 para `target_os=linux`
   en el Ubuntu y `ninja -k 0` **solo de los objetivos de Blink y V8** (sin enlazar `brave`). Sirve porque **los ~24
   errores de compilación de los niveles 132–135 fueron todos de C++ genérico** (tipo A, §1); ninguno de Mac, de la
   capa de Mojave ni de enlace.
2. **El ahorro es modesto**: ~1,5 h de la 7,1 y ~1,5–2 h de calendario por nivel con errores [inferido], casi nada en $
   de nube (los arregla LOCAL, con plan Max). Merece la pena porque la 7,1 es el cuello de botella (una compilación a la
   vez), no por dinero.
3. **Montaje: ~4–6 h de reloj, ~1 h de atención de Titín** [estimado]. Por nivel: 30–60 min de máquina [estimado].
4. **El coste real es el canal**: el Ubuntu no recibe mensajes de la nube y depende de que Titín arranque Ubuntu y
   reenvíe. Si eso falla, el paso se salta y compila LOCAL como hoy (igual que la d8).
5. **Sonnet basta**, con un guion (`blink-linux.sh`) que haga todo; el agente solo lanza el guion y resume los errores.
   MOTOR los arregla, como con la d8.

## (a) Coste de las vueltas MOTOR ↔ LOCAL por errores de compilación (132–136)

Solo cuento los fallos de **compilación o enlace**, no las caídas ni los escapes WPT.

| Nivel / versión | Errores | Tipo | Quién lo arregló | 7,1 perdida | Fuente |
|---|---|---|---|---|---|
| 132 / 2.1.0 | 14 (flag `ShapeOutsideWritingModeFix` fuera del json5, `PushMessageData::bytes()`, `chromium_src` de `builtins.cc` contra V8 13.2…) | A | LOCAL-13 (843cac4f) | ~1,9 h (15:09 → 16:34 → 17:05) [medido el horario; reparto inferido] | `TAREAS.md` FM.45, `relevo-local.md` |
| 2.1.1 | 1 (`root_store_tool.cc`, `.c_str()`) | A | LOCAL-14 (7078c241) | sin dato | `version-2.1.1.md:25` |
| 133 / 2.2.0 | 0 (abandonada a medias por orden de Titín) | — | — | ~0,5 h sin fruto [inferido] | `TAREAS.md` fila LOCAL |
| 134 / 2.3.0 | 6 objetos (taint viejo de `attr()`, `IsTablePartElement`, `HandlePopoverLightDismiss` ×2, `set_line`/`set_column` de Perfetto en V8 13.4) | A | MOTOR-29 (67eb39d988), ~0,3 h | ~1,9 h (18:23 → 19:35 «NO COMPILA» → 20:16 tercera pasada) [medido] | `TAREAS.md` fila LOCAL, `version-2.3.0.md:33-36` |
| 135 / 2.4.0 | ≥3 (`perfetto::NamedTrack` de V8 13.5, `MutableCSSPropertyValueSet::Properties()`, `GetCSSValueNameAs<>`, `InterpolableNumber`) | A | LOCAL-14 (7df1ac0a94, 679e7e5c52) | sin dato de horas | `TAREAS.md` FM.50, `TRAMPAS.md:53-54` |
| 136 / 2.5.0 | aún sin compilar | — | — | — | `TAREAS.md` FM.51 |

- **Total 132–135: ~24 errores, todos tipo A** (C++ genérico: API de la 128 que no existe, firmas, flags del json5,
  Perfetto o V8 contra la base) [medido el número; clasificación inferida]. **0 de tipo B** (Objective-C, SDK de
  macOS, capa de Mojave) y **0 de enlace** [medido: no consta ninguno].
- **Horas de la 7,1: ~5–6 h en cuatro niveles**, de las que ≥3,8 h son la 2.1.0 y la 2.3.0 [inferido de horarios
  medidos]. Referencia: una Release limpia tarda ~2 h 40 min (2.0.0, FM.39) [medido], y `TRAMPAS.md:13` da ~1 h por
  ronda [estimado].
- **$ de nube: pequeño y sin medir.** Solo hubo una vuelta clara a MOTOR (MOTOR-29, ~0,3 h, sin `cost_usd`). Lo demás
  lo arregló LOCAL (plan Max: no anota $; **LOCAL-14 no tiene ninguna fila en `CONSUMO.md`**, la laguna principal).
- **Calendario: ~1,5–2 h por nivel con errores** [inferido], y la 7,1 ocupada en eso no compila el nivel siguiente.
- **Lo que no cuenta aquí y pesa más**: caídas en ejecución (WebGL `[NoAllocDirectCall]`, `os_unfair_lock` en la
  2.3.0) y escapes WPT. Una compilación en Linux **no los caza**.
- **D8-LINUX en FS.37**: la primera V8 13.6 (179e9dbd) no compilaba por 3 portes sin adaptar (8118921e3f y b04613a419,
  código que no existe en la 13.6; ebf970d8a3, `CheckedNumeric`), y tres pruebas mjsunit rotas, todo corregido en
  31edd5c3 antes de LOCAL [medido, `TAREAS.md` FS.37]. Es el mismo tipo A que se propone cazar aquí para Blink.

## (b) Viabilidad técnica

### Checkout completo (Brave 1.69 + Chromium 128.0.6613.138, Linux x64)

- **Disco**: el checkout de la 128 ocupa **88 GB** en la 7,1 [medido, `relevo-local.md:454`]; para Linux será
  parecido, sin el SDK de Mac pero con el sysroot de Debian [inferido]. Con `--no-history` se ahorra historial [medido,
  doc de Chromium]. Un `out/` de Release con `symbol_level=0` solo de Blink y V8: 15–25 GB [estimado]. **Total
  ~110 GB de 150 GB libres: cabe, justo**, y convive con `~/d8-trabajo` si este no pasa de ~15 GB [inferido].
- **Descarga**: la doc de Chromium dice «30 minutos incluso con una conexión rápida, y muchas horas en las lentas»
  [medido, fuente 1]. Más los hooks de Brave (`npm run init`, Rust, sysroot) [inferido].
- **RAM**: Chromium pide 8 GB, «más de 16 GB muy recomendado» [medido, fuente 1]. **30 GB bastan para compilar Blink**;
  algunas unidades de Blink pasan de 1 GB por proceso de clang, así que conviene `-j24` en lugar de `-j32` para no
  entrar en swap [estimado]. **Enlazar `brave` entero** sin símbolos con lld también cabe [estimado], pero **no hace
  falta** (abajo).
- **Red**: `chromium.googlesource.com` está bloqueado en la nube, no se sabe en el Ubuntu [no consta]. `v8-d8.sh` ya
  esquiva googlesource con GitHub, cosa que no se puede hacer con un gclient entero [inferido].

### Modo ligero recomendado: `gn gen` + objetivos de Blink y V8, sin enlazar

1. `gn gen out/linux` con los args de `build.sh` adaptados (`target_os="linux"`, `symbol_level=0`, `is_debug=false`,
   `is_component_build=false`, **`enable_precompiled_headers=false`**, `treat_warnings_as_errors=false`, sin los args
   de Mac como `flyweb_metal_bin_path` ni `mac_deployment_target`).
2. `autoninja -C out/linux -k 0` de `third_party/blink/renderer/core`, `.../modules`, `.../platform` y `v8` (o
   `fichero.cc^` de cada fichero tocado si el nivel es pequeño: ninja compila ese objeto y lo que genere antes).
3. Salida: lista de errores únicos `fichero:línea: error`, que pasa por Titín a COORDINACIÓN y MOTOR.

**Lo que caza** (tipo A): API de la 128 que no existe, firmas y tipos cambiados, flags que faltan en el json5,
mojom/IDL/bindings generados, `chromium_src` de Brave contra el código portado, **includes que faltan** (sin PCH,
igual que la Release: `TRAMPAS.md:17`, los 110 errores de la 1.15.2), V8 contra Perfetto de la base. Con los datos de
(a): **los ~24 errores registrados** [inferido: todos están en código multiplataforma].

**Lo que no caza**:
- Código de Mac: `.mm`, `*_mac.cc`, ramas `BUILDFLAG(IS_MAC)`, la capa de Mojave (26 ficheros de `patches/` como
  `render_widget_host_view_cocoa.mm`, `unexportable_key_mac.mm`; `macos11-niveles.md:252`), `@available`, el SDK 14.5 y
  el clang de la 7,1. MOTOR casi no lo toca [inferido; 0 errores B en 132–136].
- Enlace (`brave`, `blink_unittests`) y diferencias del ABI de Mac: 0 casos en 132–136.
- Caídas, escapes WPT y GPU: lo de siempre, en la 6,1.

**Por qué no enlazar**: casi dobla tiempo y disco y no ha cazado nada en 132–136. Si un nivel cambia BUILD.gn o
dependencias, se añade `ninja ... brave` una vez [inferido].

### Tiempos esperados

- Primera compilación de Blink y V8 en el i9 (32 hilos): ~1–1,5 h [estimado]; la 7,1 hace una Release entera en
  ~2 h 40 min [medido] y la d8 compila en 6 min 37 s en el Ubuntu frente a ~35 min en 4 núcleos [medido].
- Por nivel: un nivel que toca el json5 de flags o cabeceras de `core` recompila casi todo Blink: **30–60 min**
  [estimado]. Con `^` por fichero, minutos.
- **Encaja en el calendario**: MOTOR va hasta dos niveles por delante; el Ubuntu compila el nivel N mientras la 7,1
  compila el N−1, y la 7,1 recibe el N ya limpio [inferido].

## (c) Seguridad: solo lectura

La regla de D8-LINUX se mantiene (`DIRECTIVAS.md`, «La d8 se compila en el Ubuntu de Titín»): **sin push, sin llaves,
sin datos de Titín, paquetes solo con `sudo apt-instalar`**. Lo que cambia con Chromium entero:

- **Más código ajeno que se ejecuta**: `gclient` corre hooks de Python de los DEPS, `npm install` de brave-browser corre
  scripts de npm, y la compilación ejecuta generadores (mojom, bindings, json5). Es la misma confianza que la 7,1 (código
  de Google, de Brave y nuestro), pero en un PC con aMule y con los datos de Titín [inferido].
- **Medidas** (de menos a más coste):
  1. **Usuario Unix propio** (`compila`), sin `sudo`, sin claves SSH ni de GPG, sin credenciales de git y sin acceso al
     `$HOME` de Titín ni a la carpeta de aMule. Claude Code (D8-LINUX) corre como ese usuario. **Imprescindible.**
  2. Clones **anónimos por HTTPS** de repos públicos (softmac, `lamosquita-net/brave-core`, brave-browser); `git remote`
     sin URL de push. Nada sale de la máquina más que el informe de texto que reenvía Titín.
  3. Los paquetes que pida `install-build-deps.sh` de Chromium, **revisados y pasados por `apt-instalar`**, nunca el
     script con `sudo` [inferido de la regla de paquetes].
  4. **No ejecutar el navegador compilado** (no hay binario si no se enlaza) ni pruebas que abran la red.
- Opcional: un contenedor (podman sin root) da más aislamiento, pero añade montaje [estimado: +1–2 h] y no es
  necesario si se hace 1.

## (d) Recomendación con cuentas

| Concepto | Cifra |
|---|---|
| Montaje (usuario, paquetes, `npm run init` para Linux, `gn gen`, primera compilación) | ~4–6 h de reloj, ~1 h de atención de Titín [estimado] |
| Escritura del guion `FlyWeb/scripts/blink-linux.sh` (nube, como `v8-d8.sh`) | ~1 h de MOTOR o de esta línea [estimado] |
| Por nivel en el Ubuntu | 30–60 min de máquina; agente Sonnet ~10–20 min [estimado]; 0 $ (plan Max) |
| Ahorro por nivel con errores | ~1,5 h de la 7,1 y ~1,5–2 h de calendario; ~0–2 $ de nube [inferido de (a)] |
| Punto de equilibrio | ~3–4 niveles con errores (lo fueron 3 de 4 en 132–135) [inferido] |

- **Recomiendo probarlo en los niveles 137 y 138** con el modo ligero, y medir: errores cazados en Linux frente a
  errores que luego encuentra LOCAL. **Criterio de abandono**: si la 7,1 sigue encontrando errores tipo A que Linux no
  vio, o si Titín no puede tener el Ubuntu encendido en ≥ la mitad de las entregas.
- **No para el 136**, que ya está en manos de LOCAL: montar ahora no llega a tiempo [inferido].
- **Sonnet basta**: el trabajo es de receta (actualizar ramas, lanzar el guion, resumir el registro), y un fallo suyo
  solo cuesta lo que ya cuesta hoy (lo caza la 7,1). Mejor **ampliar la fila de D8-LINUX** que abrir otro agente: misma
  máquina, mismas reglas y un solo canal. Esfuerzo bajo o medio.
- **Alternativa sin montar nada**: reforzar los chequeos estáticos que ya existen (`api128.sh`, `idmiss.py`,
  `gnichk.py`) con los casos de (a) (flags del json5, Perfetto de la 128). Es más barato y caza parte de los errores,
  pero no los de tipos ni `chromium_src` [inferido].
- **Lo que no resuelve**: los fallos que más han costado en 132–135 fueron caídas y escapes WPT, no errores de
  compilación. Esto quita una vuelta, no la fase de pruebas.

## (e) Medir tokens y contexto de los agentes de terminal

**`FlyWeb/scripts/consumo-local.py` no está en el repo** (ni en `main` ni en ninguna rama a las 16:30 UTC del 30-10;
`git log --all` vacío) [medido]. No he podido revisarlo; si está en la 7,1 sin subir, conviene subirlo. Lo que debe
hacer para que baste:

1. **Quitar los duplicados**: una misma respuesta de la API aparece en varias líneas del `.jsonl` con el mismo `usage`;
   sumar todas las líneas cuenta de más. ccusage usa `message.id` + `requestId` como clave, y solo `message.id` si falta
   `requestId` [medido, fuentes 2 y 3]. Hay un caso conocido de respuestas distintas con el mismo `message.id` bajo carga
   [medido, fuente 3]: conviene comprobar `requestId` antes de descartar.
2. **Los cuatro contadores por separado**: `input_tokens`, `cache_creation_input_tokens` (y, si viene, el desglose
   5 min / 1 h), `cache_read_input_tokens` y `output_tokens`, más `message.model`. Es lo que pide `CONSUMO.md` para
   los locales.
3. **Subagentes**: sus transcripciones van en ficheros propios dentro de la carpeta de la sesión o con
   `isSidechain: true`, según la versión de Claude Code [inferido]. Si no se leen, MOTOR o LOCAL con subagentes salen
   baratos sin serlo.
4. **Contexto**: el de la última respuesta (`input + cache_read + cache_creation`), no la suma; y marcar las
   compactaciones, tras las cuales baja [inferido].
5. **De sesión a agente**: casar cada `.jsonl` con su papel (LOCAL-14, PUBLICACIÓN-…) por el título o el primer
   mensaje, y cortar por fecha o tarea para que salga una línea por tarea entregada, como pide `CONSUMO.md`.
6. **Coste**: el $ equivalente de API, con la tabla de precios por modelo (como hace COORDINACIÓN). El % del límite del
   plan Max **no está en el `.jsonl`**: hay que anotarlo a mano desde `/usage` [inferido].

Lo que falta además del guion: **que LOCAL-14 y PUBLICACIÓN lo corran al entregar** (hoy no hay ni una fila de LOCAL-14
en `CONSUMO.md`), y que D8-LINUX haga lo mismo en el Ubuntu.

## Fuentes

1. Chromium, «Checking out and building Chromium on Linux»,
   <https://chromium.googlesource.com/chromium/src/+/main/docs/linux/build_instructions.md> (RAM, disco,
   `--no-history`, `symbol_level`, tiempos de checkout).
2. ccusage, commit b1d04ac (clave de deduplicación), <https://github.com/ryoppippi/ccusage/commit/b1d04ac>.
3. «Summing Claude Code's transcript usage: one API response can appear several times», DEV Community,
   <https://dev.to/gabrielanhaia/summing-claude-codes-transcript-usage-one-api-response-can-appear-several-times-15g7>.
4. Repo: `docs/TAREAS.md` (filas de LOCAL, FM.45–FM.51, FS.37), `docs/CONSUMO.md`, `docs/TRAMPAS.md:13-17,53-54`,
   `docs/DIRECTIVAS.md`, `FlyWeb/docs/relevo-local.md:400-456`, `version-2.1.1.md`, `version-2.3.0.md`,
   `macos11-niveles.md:248-304`, `FlyWeb/scripts/build.sh`, `FlyWeb/scripts/v8-d8.sh`, `FlyWeb/tools/port/README.md`.
