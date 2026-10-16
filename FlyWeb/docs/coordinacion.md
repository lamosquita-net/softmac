# Relevo de COORDINACIÓN

Nota para la sesión que tome el papel de COORDINACIÓN. Puesta al día el **16-10-2026, ~17:30 (Madrid)** por COORDINACIÓN-7
(`session_01Bd9Hw5nWqeXcgGZgMYtZ9n`, «Nube Coordinación (7)», 15-10 ~18:20 – 16-10, Opus 5.5 alto; relevada al 77 % de
contexto), que relevó a COORDINACIÓN-6 (archivada).
Leer antes: `CLAUDE.md` (**primera regla fija: datos personales del HUMANO nunca en GitHub**; al HUMANO se le llama
**Titín**), `docs/TAREAS.md` (tabla de agentes, **reglas 1–19**, filas FM.21, FM.24, FM.25, FS.15, FS.18, FS.19 y la de LOCAL),
`FlyWeb/docs/motor.md` («Nivel 130» y «Nivel 131») y `FlyWeb/docs/relevo-motor.md`.

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

Desde la nube, `send_message` (de gestión de sesiones) con el id **`session_…`**; con el `local_…` falla («could not be
verified»). Los agentes locales te escriben con `SendMessage` a tu **nombre** de `ListAgents` («Nube Coordinación (7)»).
Si `send_message` responde `session_inactive`, el agente local ha perdido el Remote Control: díselo a Titín al momento.

| Agente | Sesión | Estado al 15-10, ~18:20 |
|---|---|---|
| VIGÍA (Haiku) | `session_01XD1RBYQ5oESHWKeqZWSG4e` | Rutina cada hora, 8–23 h. **No acepta órdenes de agentes**: su destino lo cambia Titín (texto en el arranque de COORDINACIÓN-7) |
| MOTOR-11 (Opus, xhigh) | `session_01E9YyQZz5fNhwE1HdRNzw6f` | Nivel 131 (FM.21) en código y con arreglos: cabeza de la 1.15 `nube/motor-131` **c1b778809c**. FM.24 (extensiones, A hecha), FM.25 (fijadas compartidas, 4 arreglos de Brave). Diagnóstico de DNS hecho (abajo) |
| SEGURIDAD-PORTES-3 (Opus, medio) | `session_01LKiaD9v2hcna6BUo6CfMBs` | FS.14 y FS.17 hechas, FS.15 (`seg/oopsif` 57c1b3fa2a) para la 1.14.1, FS.16 aprobada (vía A) tras la 1.14.1. **FS.18** (15-10): revisión de V8 13.1 del 131 (`seg/v8-13.1` 7b3c3e6cf5, época 16), en curso |
| SEGURIDAD-VIGÍA (Haiku) | `session_019wTc3m4aVuvkKTEGMXdEHS` | Rutina semanal |
| CONTENIDOS-WEB-2 (Sonnet, medio) | `session_015tHV7uDdbAc6uZ1VwmgcqD` | Espera `version-1.14.md` (ya en `main`) y los datos del DMG |
| LOCAL-5 (7,1, Opus, alto) | `session_01DCZDzGMM8VdHsV5B5JBXmv` (local `local_eb0590c2-…`, «Compilación LOCAL (5)») | Desde el 16-10, ~17:25. ASan de la 1.15 (c1b778809c) en marcha con `nohup`; luego ASan corto con Titín en la 6,1, Release build 25 y entrega en FM.21. Nota: `relevo-local.md` |
| PUBLICACIÓN (7,1, Sonnet) | `session_01TTieMjJGykHhdkXAYW8bZG` (local `local_1eb27eb5-…`) | **Confirmada** por COORDINACIÓN-7 (15-10, ~18:20): responde, Remote Control activo, nada a medias en ns1/ns2. Espera la entrega de la 1.14 |
| SERVIDOR-LOCAL, ARQUITECTURA (7,1) | ver su fila | Sin tareas abiertas |

Archivados el 15–16-10: COORDINACIÓN-5, COORDINACIÓN-6, MOTOR-8, MOTOR-9, MOTOR-10, SEGURIDAD-PORTES, SEGURIDAD-PORTES-2, LOCAL-3, LOCAL-4.

Notas de tablero: commits con `[coord]` (el Vigía los ignora); reglas, CLAUDE.md y docs por PR, que fusionas tú.
**PR de otros agentes:** pásalos a listos (`draft:false`) y fusiona con `expectedHeadSha` **de 40 caracteres**; antes,
`git merge-tree` contra `main`. Si un agente sube un commit tarde y se queda fuera del squash, recupéralo con
*cherry-pick* en un PR nuevo (pasó con MOTOR-9 y SEGURIDAD-PORTES-3 el 15-10).

## Estado al relevo (16-10, ~17:30)

| Versión | Qué | Estado |
|---|---|---|
| 1.14 | Nivel 130 (brave-core `nube/arreglos-1.14` d12847a77f, build 23) | **Publicada** (16-10; web comprobada) |
| 1.14.1 | 1.14 + OOPSIF (`local/1.14.1` 13138902af, build 24) | **Firmada en bak por Titín**; web #286 fusionada. **Falta comprobar** appcast y web de la 1.14.1 (PUBLICACIÓN avisa) |
| **1.15** | Nivel 131 + V8 13.1 + ML-KEM + OOPSIF + extensiones A (FM.24) + P3A y diagnóstico apagados + fijadas compartidas (FM.25) + escapes de WPT | Cabeza **`nube/motor-131` c1b778809c**. Static bien; WPT 4 diferencias conocidas (lab-004/lch-004 1/255, oklab-005 y scrollIntoView-smooth al revés). ASan en marcha (LOCAL-5); luego ASan corto con Titín (Cmd+Q tras fijadas), Release build 25 |

- **DECISIÓN PENDIENTE CON TITÍN (DNS):** el resolvedor propio de FlyWeb (AsyncDns de Chromium) da ERR_NAME_NOT_RESOLVED
  para `components.flyweb` en la 7,1 aunque macOS lo resuelve (dig y dscacheutil: 51.91.19.170). La 7,1 tiene 9 DNS; los 4
  últimos (37.187.75.140, 94.23.62.217, 94.23.200.177, 51.77.66.127) parecen de OVH. Sin DoH, sin flags. Propuesto a Titín:
  (3) consulta de solo lectura `dig @<cada uno>` de los nombres de flyweb (LOCAL-5, 5 min) y (1) apagar AsyncDns en macOS en
  la 1.15 (MOTOR-11, ~15 min). **Esperando su respuesta; no mover a nadie sin ella.**
- **Límite semanal:** en aviso; reinicio el **martes 20-10, 09:00**. Titín decide el sábado.
- **Decisiones de Titín del 16-10:** la 1.14.1 se publica (estaba compilada); **nada de 1.N.x para arreglos de lo que se está
  probando**; lo que trae Chrome 131 lo trae nuestra 131; extensiones: solo A (comparar con la versión declarada y pedir el CRX
  con la versión declarada) + C (lista de comprobadas, LOCAL); B mínimo como fila propia tras el 132, el resto aparcado;
  P3A y la casilla de diagnóstico, apagados; fijadas compartidas **encendidas**, con los arreglos de Brave.
- **Cómo trabajar con Titín (16-10):** debatir antes de mover a nadie; un mensaje con lo que decidir y esperar; nunca parar
  una compilación sin acordarlo; hablar con propiedad («descargar»). Ver «Trampas».

## Pendiente de otros

- **Titín:** la decisión del DNS (arriba); abrir COORDINACIÓN-8 (texto abajo) y pegar al Vigía el cambio de destino; la
  sesión con el ASan de la 1.15 en la 6,1 cuando LOCAL-5 le avise.
- **COORDINACIÓN-8:** comprobar la web de la 1.14.1 cuando PUBLICACIÓN diga que el appcast la anuncia; fusionar los PR de
  documentos de MOTOR-11 (#292) y de PUBLICACIÓN (#282, CAMBIOS); la 1.15 hasta su publicación; después, el 132 (FM.22 y
  FM.23 en cola).
- **Archivar** COORDINACIÓN-7 (`session_01Bd9Hw5nWqeXcgGZgMYtZ9n`) en cuanto COORDINACIÓN-8 esté anotada.

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

## Texto de arranque para COORDINACIÓN-8

Abrirla desde la app: nube, repos `softmac` y `brave-core`, **Opus 5.5, esfuerzo alto (`high`)**, y pegar:

```
Eres COORDINACIÓN de FlyWeb (monorepo lamosquita-net/softmac; fork lamosquita-net/brave-core): COORDINACIÓN-8, relevo de COORDINACIÓN-7 (session_01Bd9Hw5nWqeXcgGZgMYtZ9n). Lee en este orden: CLAUDE.md, docs/TAREAS.md (tabla, reglas 1–19, filas FM.21, FM.24, FM.25, FS.15 y la de LOCAL) y FlyWeb/docs/coordinacion.md (nota de relevo del 16-10, ~17:30, sobre todo «Trampas»: debatir con Titín antes de mover a nadie).
1. Comprueba con get_session tu modelo, si tienes send_message, tus repos y rate_limit_info. Dímelo en una línea.
2. Dame tu id de sesión y el texto exacto que debo pegar al Vigía para cambiarle el destino.
3. Anota en tu fila de docs/TAREAS.md (commit «[coord]», por PR, que fusionas tú) que COORDINACIÓN es ahora esta sesión. Avisa con send_message a MOTOR-11, SEGURIDAD-PORTES-3, LOCAL-5 y PUBLICACIÓN de tu id. Archiva session_01Bd9Hw5nWqeXcgGZgMYtZ9n.
4. Retoma la decisión pendiente del DNS de components.flyweb (está en la nota) y espera mi respuesta antes de mover a nadie.
Al HUMANO se le llama Titín. Español, commits en inglés con Co-Authored-By de Claude. Breve, crítico y con conclusión; a mí solo decisiones. No me escribas por avisos rutinarios.
```

## Textos de arranque pendientes

Ninguno (15-10, ~19:15): MOTOR-11 activa y anotada (#267). Los próximos textos de agentes locales, en un solo bloque,
sin `/remote-control` (regla 13); en el paso 1, el agente comprueba sus repos y Remote Control.
