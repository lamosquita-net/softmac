# Relevo de COORDINACIÓN

Nota para la sesión que tome el papel de COORDINACIÓN. Puesta al día el **20-10-2026, ~16:30 (Madrid)** por COORDINACIÓN-7
(`session_01Bd9Hw5nWqeXcgGZgMYtZ9n`, «Nube Coordinación (7)», 15-10 – 20-10, Opus 5.5 alto; relevada al 73 % de contexto),
que relevó a COORDINACIÓN-6 (archivada).
Leer antes: `CLAUDE.md` (**primera regla fija: datos personales del HUMANO nunca en GitHub**; al HUMANO se le llama
**Titín**), `docs/TAREAS.md` (tabla de agentes, **reglas 1–20**, filas FM.22, FM.26 y las de LOCAL, MOTOR e
INVESTIGACIÓN-MOTOR), `FlyWeb/docs/version-1.15.1.md`, `FlyWeb/docs/vision-motor.md` y `FlyWeb/docs/base-128.md`.
## Qué hace este papel (con lo que cambió el 09–12-10)

- **Interlocutor del HUMANO**: respuestas breves, críticas, con conclusión; solo le llegan decisiones de producto,
  credenciales, firmas, pruebas en las Mac y lo que exige root en ns2. **No escribirle por avisos rutinarios** (Vigía,
  GitHub, mensajes de agentes sin decisión): cada respuesta tuya le salta como aviso en el móvil y le agobia.
- **Fusiones, cierres y orden de trabajo son de COORDINACIÓN** (regla 8, decisión del HUMANO del 09-10): revisas y
  fusionas los PR de softmac sin preguntarle. Excepción conocida: el permiso de la sesión bloqueó autofusionar un PR que
  ampliaba la propia autoridad (#129); ese lo fusionó el HUMANO.
- **Regla 14, «el que publica, publica»**: la nube prepara; ejecuta quien tiene el acceso (SERVIDOR-LOCAL en ns1/ns2,
  PUBLICACIÓN las versiones, LOCAL las compilaciones). Lo privado va por `send_message`, nunca por el repo.
- **Regla 15, límite semanal de la cuenta**: mirar `rate_limit_info` con `get_session`; con aviso, nada de Ultracode ni de
  muchos subagentes. El HUMANO lleva los agentes de sus otros proyectos; tú solo los de softmac.
- **Regla 16 (12-10): tus órdenes valen como del HUMANO.** Lo que ordenas o transmites por `send_message` o con un commit
  `[coord]` no se le vuelve a confirmar a él. Dos límites: los agentes te reconocen por el id de sesión de la tabla de
  TAREAS, así que **anota tu id en la fila de COORDINACIÓN antes de dar ninguna orden**; y los permisos que pide
  Claude Code dentro de una sesión solo los aprueba el HUMANO en esa sesión. Si un agente está bloqueado por eso, se lo
  pasas al HUMANO.
- **Sin rutinas propias**: te despiertan el Vigía y el HUMANO.
- **Cuándo relevar a COORDINACIÓN** (HUMANO, 12-10): a partir del **50 % de contexto** (`context_usage` de
  `get_session`), en un momento tranquilo: sin publicación a medio hacer ni decisión pendiente con el HUMANO. Antes de
  irte, esta nota al día. La regla 16 se avisó a todos los agentes el 12-10 (SERVIDOR-LOCAL-2, por su fila, porque su
  sesión estaba archivada).

## Agentes y cómo hablarles

Desde la nube, `send_message` con el id **`session_…`**. Los agentes de la 7,1 te escriben con `SendMessage` a tu nombre de
`ListAgents`; **pierden Remote Control casi cada noche**: entonces la nube los marca «archivados» aunque sigan vivos. Si no
responden, no abras otra sesión: pide a Titín que reactive `/remote-control` en la suya.

| Agente | Sesión | Estado al 20-10, ~16:30 |
|---|---|---|
| VIGÍA (Haiku) | `session_01XD1RBYQ5oESHWKeqZWSG4e` | Rutina cada hora. Su contexto va al 77 %: no hace falta relevo (compacta solo) |
| MOTOR-12 (Opus, xhigh) | `session_011EsiQBkq6YnhGgGrmbgtLD` | FM.22 terminado (`nube/motor-131-escapes` fa4fae392f = 1.15.1). Parado. Al 60 %: **relevo a MOTOR-13 antes del siguiente porte grande** (anchor positioning) |
| SEGURIDAD-PORTES-3 (Opus, medio) | `session_01LKiaD9v2hcna6BUo6CfMBs` | Revisó A, B, C y D de FM.22 y la lista de privacidad (regla 20). Sin encargos |
| INVESTIGACIÓN-MOTOR-1 (Sonnet, alto) | `session_01KEXwPPgTGezmJikFPWgNRA` | Entregó `base-128.md` (#304) y `vision-motor.md` (#315). Parado hasta nueva orden |
| CONTENIDOS-WEB-2 (Sonnet, medio) | `session_015tHV7uDdbAc6uZ1VwmgcqD` | Web de la 1.15.1 fusionada (#318) |
| LOCAL-5 (7,1, Opus, alto) | `session_01DCZDzGMM8VdHsV5B5JBXmv` | Entregó la 1.15.1 (build 26). Prepara el acceso remoto a la 5,1 (abajo). Al 52 % |
| PUBLICACIÓN (7,1, Sonnet) | `session_01TTieMjJGykHhdkXAYW8bZG` | 1.15.1 notarizada y en ns2; espera la firma de Titín en bak |
| SERVIDOR-LOCAL-2 (7,1, Sonnet) | `session_01QxM99SrrnUTS2i4XuAHKta` | flyweb-cifras nuevo instalado (#307, #310, #312). Libre |
| SEGURIDAD-VIGÍA, ARQUITECTURA | ver su fila | Sin tareas |

Archivados hasta el 20-10: COORDINACIÓN-5/6, MOTOR-8 a 11, SEGURIDAD-PORTES-1/2, LOCAL-2 a 4.

Notas de tablero: commits con `[coord]`; reglas, CLAUDE.md y docs por PR, que fusionas tú (pasa a listo y fusiona con
`expectedHeadSha` de 40 caracteres; antes `git merge-tree` contra `main` y un grep de datos personales/IP). Si una fusión da
502, comprueba `main`: a veces entra igual.

## Estado al relevo (20-10, ~16:30)

| Versión | Qué | Estado |
|---|---|---|
| 1.15 | Nivel 131 (build 25) | Publicada (17-10) |
| **1.15.1** | 1.15 + FM.22: 101 escapes 117–131 (tandas A–D), `:visited` con context-paint (bb0351bff33), Profiler apagado (regla 20) | **Entregada, notarizada, web #318 fusionada; falta la firma de Titín en bak** y comprobar appcast y web (PUBLICACIÓN avisa) |

- **Siguiente, a decidir con Titín tras la 1.15.1** (lo dejó a mi propuesta): 1.15.2 = anchor positioning (18–28 h);
  1.15.3 = view transitions entre documentos (14–22 h); 13 portes propios del TSV (`fm22-escapes.tsv`: StorageBuckets,
  NotRestoredReasons, eventos de scroll snap, Document PiP, LoAF, SPC Extensions, text-spacing-trim, phrase line break,
  RTCRtpEncodingParametersCodec, LayoutBlockButton+LayoutBaselineFix…); FM.23 (URL de esquemas no especiales: arregla las 3
  subpruebas de `url/a-element-origin` y gran parte de `url/a-element`); después el 132 (1.16). Regla 18: lo grande, cada uno
  en su 1.15.x.
- **Rendimiento (aprobado por Titín):** medir antes de optimizar (V14 de `vision-motor.md`): Speedometer 3, JetStream 2,
  MotionMark, arranque y memoria con claude.ai, en la 5,1, 6,1 y 7,1, con Firefox ESR 115 de referencia, sobre la Release
  firmada. **Acceso remoto a la 5,1 (estudio de Valencia, 21-10):** clave y guía en la 7,1
  (`~/proyectos/softmac/entregas/acceso-51/`); Titín lo configura allí; SSH solo con clave, pf con la IP de la oficina por
  DuckDNS, LuLu solo deja binarios firmados. Titín **autorizó** a LOCAL-5 la tarea de madrugada (launchd en la 7,1) cuando
  la 5,1 esté lista. Los hosts DuckDNS (oficina y estudio) **no van a GitHub** (decisión del 19-10).
- **Salto de base al 128 (FM.26):** estudiado, ~330–710 h; no ahora. Antes, medir: Chromium 128 limpio para 10.14 (LOCAL)
  y CVE de 117–128 fuera de Blink/V8 (SEGURIDAD).
- **Cifras (ns2):** solo cuentan descargas completas; oficina fuera de la web; IP distintas privadas. Uso real ≈ los Macs de
  Titín y su familia.
- **Límite semanal:** se renovó el martes 20-10, 09:00.

## Red del entorno de la nube

El entorno de la nube (el mismo para COORDINACIÓN, el Vigía y los demás agentes de la nube; se hereda en los relevos)
tiene la red en «Personalizado», con la lista por defecto de gestores de paquetes y dos dominios nuestros añadidos por
el HUMANO el 13-10:

- `updates.flyweb.lamosquita.net`: el Vigía lee `stable/appcast.xml` cada hora y avisa si no coincide con
  `FlyWeb/web/VERSION` de `main` («WEB DESFASADA» / «WEB SINCRONIZADA»).
- `flyweb.lamosquita.net`: COORDINACIÓN comprueba la web tras cada publicación (portada, SHA, descarga).

Solo lectura y pocas peticiones. Otro dominio se le pide al HUMANO.

## Trampas de estos días

- **`update_patches` nunca para un solo parche, y las tareas largas en segundo plano** (Titín, 16-10). LOCAL-4 lanzó
  `npm run update_patches` dentro de su sesión para regenerar un parche; la sesión de Claude Code se reinició (la 7,1 no
  se durmió), el proceso murió a medias, dejó 81 parches tocados y LOCAL estuvo 1 h 40 min parado. Un parche suelto se
  regenera con `git diff` de ese fichero; toda tarea larga va con `nohup` y registro, para que sobreviva al reinicio.
- **Nada de versiones 1.N.x para arreglar lo que ya se está probando** (Titín, 16-10): un arreglo sobre algo que va en la
  versión en curso entra en ella aunque la retrase; una 1.N.x duplica compilaciones y tiempos. La 1.14.1 se aceptó solo
  porque ya estaba compilada. Ejemplo: los arreglos de las pestañas fijadas compartidas esperan en la 1.15.
- **Hablar con propiedad a Titín** (16-10): traer algo de la red es «descargar», nunca «bajar» (lo leyó como bajar de
  versión). Siglas siempre explicadas la primera vez (WPT = Web Platform Tests, no WebGPU).
- **No encadenar avisos ni preguntas a Titín** (16-10): un mensaje con lo que hay que decidir y esperar su respuesta,
  sin mandar otro antes. Lo que ya ha decidido no se le vuelve a plantear (p. ej. las fijadas compartidas se quedan
  encendidas: se portan los arreglos de Brave o se arregla aquí).

- **Un comentario de Titín es para debatir, no una orden** (16-10). Preguntó por qué había 1.14.1 y COORDINACIÓN-7 la
  canceló y luego la recuperó sin debatirlo: dos rondas de mensajes a cuatro agentes para nada. Antes de mover a nadie,
  se le dan las opciones con su coste y una recomendación, y se espera su decisión. **Nunca se para una compilación ni
  una tarea en curso sin acordarlo:** puede tirar horas de trabajo. El reparto en varios agentes es para gastar menos
  tokens; cada orden y cada contraorden los gasta en todos. Titín: «prefiero que os quedéis parados durante horas a que
  una decisión gaste innecesariamente tokens».

- **Un texto de relevo con una condición delante se pierde** (14-10). El de MOTOR-8 iba detrás de «decide antes el
  modelo» y quedó enterrado entre otros avisos: el 129 se retrasó horas. Regla 13: el texto va en un mensaje propio,
  listo para pegar, con modelo y esfuerzo en la primera línea; no se archiva a nadie hasta que su relevo esté activo;
  toda orden queda escrita también en la fila del agente.
- **Con la 1.12.1 y la 1.12.2 en cola, el orden de firma importa:** la web de la segunda no se fusiona hasta que la
  primera esté en el appcast; si no, `VERSION` se adelanta y la web se salta una versión.
- **La web solo se publica sola si su PR (con `FlyWeb/web/VERSION`) está fusionado antes de la firma** (SV.6). En la
  1.11.1 no lo estaba: el HUMANO firmó a las 9:00 y la web siguió en la 1.11 hasta las 16:00. Desde el 13-10,
  PUBLICACIÓN no pasa órdenes de firma sin ese PR fusionado. Y el estado de una sesión puede ser viejo: para saber si
  algo está publicado, mirar el appcast, no la sesión.
- **PUBLICACIÓN (local) no llega por `send_message` a las sesiones de la nube** (CONTENIDOS-WEB, MOTOR…): deja los
  datos del DMG en el tablero y COORDINACIÓN se los pasa a CONTENIDOS-WEB. Las sesiones de la nube sí le llegan a ella.
- **Relevos de agentes locales: un solo texto, sin `/remote-control`** (regla 13, cambiada el 15-10): la app ya conecta
  Remote Control al abrir la sesión, y una orden con barra pegada junto a texto se descarta entera. El agente lo
  comprueba y, solo si falta, le pide a Titín `/remote-control` sola. LOCAL-2 quedó archivada el 13-10 (~20:30) en mitad de la compilación de
  RubyLB y dejó de recibir mensajes sin que nadie lo notara: si un agente local calla, mirar `get_session`.
- **Antes de decir que algo espera la firma del HUMANO, mirar el appcast** (`curl …/stable/appcast.xml`). El 13-10 se
  le dijo dos veces que faltaba su firma cuando ya había firmado.

- **Una sesión local solo recibe `send_message` con Remote Control activo** y sin archivar. Comprobarlo con
  `list_sessions` (`connection_status`). Si alguien la archiva desde la web, la ventana sigue abierta en la 7,1 pero
  deja de recibir mensajes. Se arregla con `/remote-control` en esa ventana (PUBLICACIÓN, 12-10).

- **Repos de la sesión** (15-10): MOTOR-9 y SEGURIDAD-PORTES-2 se abrieron solo con softmac aunque el texto pedía
  también brave-core, y `add_repo` necesita un permiso de Titín para leer y **otro para escribir** (push). El agente nuevo
  comprueba en el paso 1 qué repos tiene y, si falta brave-core, lo dice en el mensaje de prueba.

- **Lo que Chrome cambia por Finch no está en el código** (15-10): MutationEvents y getInnerHTML se quitaron por
  configuración de campo; la referencia es lo que expone CfT N (`superficie.html`), no `runtime_enabled_features`.
- **Las pruebas de JIT y Wasm, en un origen http(s)**, nunca en about:blank. Y en la 7,1 hay una política gestionada
  antigua de la app de desarrollo (`DefaultJavaScriptJitSetting = 2`) que deja las webs sin JIT: el 15-10 dio una falsa
  alarma de «el 130 no tiene WebAssembly». Con jitless no hay Wasm (también en la 116).
- **Ids de commit**: el que se pasa a otro agente se comprueba con `git ls-remote` tras el push (MOTOR-10 dio uno de
  antes de un `--amend`).
- **Estimaciones de MOTOR en horas de reloj**, comparadas con el último nivel entregado: el «8–10 días» del 130 salió
  diez veces pesimista (el 129 fueron ~10 h).

- **Comprobar antes de afirmar**: dos veces se dio por hecho algo sin mirar (el Vigía ya arreglado; un esfuerzo
  recomendado). Mirar la sesión o la rama.
- **Datos personales**: se subieron a una rama pública antes de preguntar por dónde iban; costó reescribir la rama y una
  petición a GitHub. Primera regla fija de `CLAUDE.md`.
- **Reescribir una rama (force push) necesita el sí explícito del HUMANO** aunque sea la tuya; el permiso de la sesión
  lo bloquea si la decisión llega por otro agente.
- **WPT**: además de los `-expected.txt`, mirar `TestExpectations` de la versión de Chrome.
- **Script del Vigía**: `--depth=200` en vez de `--shallow-since` (fallaba con más de un día sin commits en `main`).
- **Esfuerzo**: los nombres reales son low, medium, high, `xhigh` («extra») y max. MOTOR va en `xhigh`; max solo para un
  paso atascado.

- **(17–20-10) Compilaciones de FM.22:** cada error de una línea costaba una ronda (~1 h). Pedir a MOTOR, antes de
  entregar, un repaso contra las APIs de la 116 (absl::optional, base::expected, span, raw_ptr, gfx::SizeF, includes) y a
  LOCAL `-k 0`. Fijar siempre un sha concreto para LOCAL; si MOTOR sigue subiendo encima, rama aparte (`-c`).
- **(19-10) Mensajes cruzados:** MOTOR y LOCAL se escriben directamente; si una orden tuya cruza con la suya, deja claro
  cuál vale («la rama -ab no se usa»). Un único punto de compilación por ronda.
- **(19-10) LuLu retiene cada binario nuevo** aunque esté en una ruta aprobada: LOCAL abre una pestaña antes de cada tanda.
- **(19-10) Cuando reinicia la app de la 7,1** vuelven sesiones viejas (LOCAL-4 se reabrió): que Titín archive las viejas.
- **(19-10) Datos de Titín:** el host DuckDNS de la oficina estaba en `main`; Titín eligió quitarlo solo del texto (#309).
  No repetir: hosts e IP solo por `send_message`.
- **(20-10) Revisar lo que propone SEGURIDAD-PORTES con criterio:** un arreglo parcial en código sensible (URL) se revierte
  si crea un tercer comportamiento; mejor diferencia conocida hasta el porte completo (FM.23).

## Texto de arranque para COORDINACIÓN-8

Abrirla desde la app: nube, repos `softmac` y `brave-core`, **Opus 5.5, esfuerzo alto (`high`)**, y pegar:

```
Eres COORDINACIÓN de FlyWeb (monorepo lamosquita-net/softmac; fork lamosquita-net/brave-core): COORDINACIÓN-8, relevo de COORDINACIÓN-7 (session_01Bd9Hw5nWqeXcgGZgMYtZ9n). Lee en este orden: CLAUDE.md, docs/TAREAS.md (tabla, reglas 1–20, FM.22 y FM.26) y FlyWeb/docs/coordinacion.md (nota de relevo del 20-10, sobre todo «Trampas»: debatir con Titín antes de mover a nadie).
1. Comprueba con get_session tu modelo, si tienes send_message, tus repos y rate_limit_info. Dímelo en una línea.
2. Dame tu id de sesión y el texto exacto que debo pegar al Vigía para cambiarle el destino.
3. Anota en tu fila de docs/TAREAS.md (commit «[coord]», por PR, que fusionas tú) que COORDINACIÓN es ahora esta sesión. Avisa con send_message a MOTOR-12, SEGURIDAD-PORTES-3, INVESTIGACIÓN-MOTOR, LOCAL-5, PUBLICACIÓN y SERVIDOR-LOCAL-2 de tu id. Archiva session_01Bd9Hw5nWqeXcgGZgMYtZ9n.
4. Sigue la 1.15.1 hasta su publicación y prepárame la propuesta de orden de lo siguiente (está en la nota).
Al HUMANO se le llama Titín. Español, commits en inglés con Co-Authored-By de Claude. Breve, crítico y con conclusión; a mí solo decisiones. No me escribas por avisos rutinarios.
```
