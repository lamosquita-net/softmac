# Relevo de COORDINACIÓN

Nota para la sesión que tome el papel de COORDINACIÓN. Puesta al día el **15-10-2026, ~18:20 (Madrid)** por COORDINACIÓN-6
(`session_01DdLcRgFWWjq51j1Hs5pLsn`, «Nube Coordinación (6)», 15-10, Opus 5.5 alto), que relevó a COORDINACIÓN-5 (archivada).
**Desde el 15-10, ~18:20, el papel lo lleva COORDINACIÓN-7** (`session_01Bd9Hw5nWqeXcgGZgMYtZ9n`, «Nube Coordinación (7)»,
Opus 5.5 alto); COORDINACIÓN-6, archivada.
Leer antes: `CLAUDE.md` (**primera regla fija: datos personales del HUMANO nunca en GitHub**; al HUMANO se le llama
**Titín**), `docs/TAREAS.md` (tabla de agentes, **reglas 1–19**, filas FM.20, FM.21, FS.14–FS.17 y la de LOCAL),
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
| MOTOR-10 (Opus, xhigh) | `session_017osmPdTipjmbHoMeuQDeJ4` | Nivel 130 entregado en código; inventario del 131 hecho y decidido (FM.21). **Parado hasta el reinicio del límite** (regla 15) salvo fallos de la 1.14 |
| SEGURIDAD-PORTES-3 (Opus, medio) | `session_01LKiaD9v2hcna6BUo6CfMBs` | FS.14 y FS.17 hechas, FS.15 (`seg/oopsif` 57c1b3fa2a) para la 1.14.1, FS.16 aprobada (vía A) tras la 1.14.1. Parada |
| SEGURIDAD-VIGÍA (Haiku) | `session_019wTc3m4aVuvkKTEGMXdEHS` | Rutina semanal |
| CONTENIDOS-WEB-2 (Sonnet, medio) | `session_015tHV7uDdbAc6uZ1VwmgcqD` | Espera `version-1.14.md` (ya en `main`) y los datos del DMG |
| LOCAL-4 (7,1, Opus, alto) | `session_014pVFQScvJwumdaBwufvESX` | Compilando y probando la 1.14 (Static, ASan, pruebas **en la 6,1**). Luego la 1.14.1 |
| PUBLICACIÓN (7,1, Sonnet) | `session_01TTieMjJGykHhdkXAYW8bZG` (local `local_1eb27eb5-…`) | **Confirmada** por COORDINACIÓN-7 (15-10, ~18:20): responde, Remote Control activo, nada a medias en ns1/ns2. Espera la entrega de la 1.14 |
| SERVIDOR-LOCAL, ARQUITECTURA (7,1) | ver su fila | Sin tareas abiertas |

Archivados el 15-10: COORDINACIÓN-5, MOTOR-8, MOTOR-9, SEGURIDAD-PORTES, SEGURIDAD-PORTES-2, LOCAL-3.

Notas de tablero: commits con `[coord]` (el Vigía los ignora); reglas, CLAUDE.md y docs por PR, que fusionas tú.
**PR de otros agentes:** pásalos a listos (`draft:false`) y fusiona con `expectedHeadSha` **de 40 caracteres**; antes,
`git merge-tree` contra `main`. Si un agente sube un commit tarde y se queda fuera del squash, recupéralo con
*cherry-pick* en un PR nuevo (pasó con MOTOR-9 y SEGURIDAD-PORTES-3 el 15-10).

## Estado al relevo (15-10, ~18:20)

| Versión | Qué | Estado |
|---|---|---|
| 1.13 | Nivel 129 | Publicada (15-10, 09:28) |
| **1.14** | Nivel 130 entero + V8 13.0.245.25 + FS.14 (incluye el arreglo de V8 91343bb4 de la regresión de la 1.13) + ORB v0.2 + fuera polyfills core-js y 6 apagados de Chrome + `block-ruby-003` + `seg/popup-sandbox` + los dos escapes de seguridad. **Cabeza: brave-core `nube/escapes-seg-1.14.1` 303e498fb5** (= `nube/motor-130` ccc74ea171 + 2 flags) | LOCAL-4: Static/ASan y pruebas en la 6,1; después Release y entrega (regla 11) |
| 1.14.1 | 1.14 + `seg/oopsif` 57c1b3fa2a (FS.15, OOPSIF) | Después de la 1.14, Static aparte con las pruebas de FS.15 |
| 1.15 | Nivel 131 + V8 13.1.201.22 + ML-KEM (`seg/ml-kem` fc0f45c433, **solo en el 131**) | Inventario decidido (FM.21). **Empieza ya con MOTOR-11** (Titín, 15-10, ~18:30) |

- **Plazo de seguridad:** si la 1.14 no está entregada antes del **17-10, 16:00**, SEGURIDAD-PORTES-3 prepara la 1.13.1
  con 91343bb4 (decisión de Titín, FS.14). Ni crbug 390743124 ni 511006880 tienen explotación conocida (KEV 14-10).
- **Límite semanal (regla 15):** en aviso (`seven_day`, `allowed_warning`) el 15-10; se restablece el **martes 20-10, 09:00**.
  **Titín (15-10, ~18:30): va al 56 %, se sigue trabajando jueves y viernes; el sábado decide.** Se levanta la parada del 131.
  Ojo: `allowed_warning` no dice el porcentaje; el dato lo da Titín.
- **Decisiones de Titín del 15-10:** JetBrains Mono solo en páginas internas; no hay 1.13.1; regla 13 sin
  `/remote-control`; **pruebas de FlyWeb en la 6,1** (la 7,1 solo compila; ventanas en la 7,1 solo con ≥ 10 min de
  inactividad; CfT siempre `--headless=new`).
- **Decisiones de COORDINACIÓN-6** (en FM.20/FM.21/FS.14–FS.17): Web Share fuera; KeyboardFocusableScrollers dentro;
  OriginAgentCluster por defecto; la 1.14 sin esperar a OOPSIF; ML-KEM solo en la 1.15; FS.16 por la vía A.
- **Método nuevo (FM.20):** Brave compila con `disable_fieldtrial_testing_config`, así que lo que Chrome cambia por Finch
  se nos escapa. Red: `FlyWeb/tools/superficie.html` (FlyWeb frente a CfT N) en cada nivel, y estimar en horas de reloj.
- **Maglev:** punto de decisión en el nivel 132 (V8 13.2 LTS). **WebGPU:** hacia el 140.

## Pendiente de otros

- **Titín:** abrir COORDINACIÓN-7 (texto abajo) y pegar al Vigía el cambio de destino; abrir MOTOR-11 (texto en el mensaje de COORDINACIÓN-7 del 15-10, ~18:30); permitir en LuLu la compilación nueva en la 6,1;
  firmar en bak la 1.14 cuando PUBLICACIÓN se lo pida; prueba de `FlyWeb/tools/regexp-130.html` en la 5,1 con la 1.14.
- **COORDINACIÓN-7:** comprobar PUBLICACIÓN antes de la entrega; pasar a CONTENIDOS-WEB-2 los datos del DMG; tras la
  1.14, la 1.14.1; después del reinicio, el 131.
- **Archivar** COORDINACIÓN-6 (`session_01DdLcRgFWWjq51j1Hs5pLsn`) en cuanto COORDINACIÓN-7 esté anotada.

## Red del entorno de la nube

El entorno de la nube (el mismo para COORDINACIÓN, el Vigía y los demás agentes de la nube; se hereda en los relevos)
tiene la red en «Personalizado», con la lista por defecto de gestores de paquetes y dos dominios nuestros añadidos por
el HUMANO el 13-10:

- `updates.flyweb.lamosquita.net`: el Vigía lee `stable/appcast.xml` cada hora y avisa si no coincide con
  `FlyWeb/web/VERSION` de `main` («WEB DESFASADA» / «WEB SINCRONIZADA»).
- `flyweb.lamosquita.net`: COORDINACIÓN comprueba la web tras cada publicación (portada, SHA, descarga).

Solo lectura y pocas peticiones. Otro dominio se le pide al HUMANO.

## Trampas de estos días

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

## Texto de arranque para COORDINACIÓN-7

Abrirla desde la app: nube, repos `softmac` y `brave-core`, **Opus 5.5, esfuerzo alto (`high`)**, y pegar:

```
Eres COORDINACIÓN de FlyWeb (monorepo lamosquita-net/softmac; fork lamosquita-net/brave-core): COORDINACIÓN-7, relevo de COORDINACIÓN-6 (session_01DdLcRgFWWjq51j1Hs5pLsn). Lee en este orden: CLAUDE.md, docs/TAREAS.md (tabla, reglas 1–19, filas FM.20, FM.21, FS.14–FS.17 y la de LOCAL) y FlyWeb/docs/coordinacion.md (nota de relevo del 15-10, ~18:20).
1. Comprueba con get_session tu modelo, si tienes send_message, tus repos y rate_limit_info. Dímelo en una línea.
2. Dame tu id de sesión y el texto exacto que debo pegar al Vigía para cambiarle el destino.
3. Anota en tu fila de docs/TAREAS.md (commit «[coord]», por PR, que fusionas tú) que COORDINACIÓN es ahora esta sesión y cambia en coordinacion.md «Nube Coordinación (6)» por «(7)». Avisa con send_message a MOTOR-10, SEGURIDAD-PORTES-3 y LOCAL-4 de tu id. Archiva session_01DdLcRgFWWjq51j1Hs5pLsn.
4. Comprueba que PUBLICACIÓN responde antes de la entrega de la 1.14 y resume el estado en 5 líneas.
Al HUMANO se le llama Titín. Español, commits en inglés con Co-Authored-By de Claude. Breve, crítico y con conclusión; a mí solo decisiones. No me escribas por avisos rutinarios.
```

## Textos de arranque pendientes

**MOTOR-11** (15-10, ~18:40; orden de Titín: el 131 empieza ya). Abrirla desde la app: nube, repos `softmac` y
`brave-core` (con escritura), **Opus 5.5, esfuerzo extra (`xhigh`)**, y pegar:

```
Eres MOTOR de FlyWeb (monorepo lamosquita-net/softmac; fork lamosquita-net/brave-core): MOTOR-11, relevo de MOTOR-10 (session_017osmPdTipjmbHoMeuQDeJ4). COORDINACIÓN es COORDINACIÓN-7, session_01Bd9Hw5nWqeXcgGZgMYtZ9n. Lee en este orden: CLAUDE.md, docs/TAREAS.md (tabla, reglas 1–19, filas FM.20, FM.21 y FS.17), FlyWeb/docs/motor.md «Nivel 131» §1–§10, FlyWeb/docs/relevo-motor.md (relevo de MOTOR-10 a MOTOR-11, 15-10, ~18:35) y FlyWeb/tools/port/README.md.
1. Comprueba con get_session tu modelo y esfuerzo, si tienes send_message y tus repos. Si no puedes escribir en brave-core, dilo en el mensaje de prueba.
2. Anota tu id en la fila de MOTOR de docs/TAREAS.md (por PR; lo fusiona COORDINACIÓN) y manda un mensaje de prueba a COORDINACIÓN con send_message.
3. Empieza el nivel 131 (FM.21) por donde dice el relevo: nube/motor-131 desde 303e498fb5 con seg/ml-kem fc0f45c433, paso de V8 13.1.201.22 y aviso a SEGURIDAD-PORTES-3 (session_01LKiaD9v2hcna6BUo6CfMBs). Mientras MOTOR-10 siga activa, los fallos de la 1.14 son suyos; cuando COORDINACIÓN la archive, pasan a ti.
Al HUMANO se le llama Titín. Español, commits en inglés con Co-Authored-By de Claude. Estimaciones en horas de reloj; ids de commit comprobados con git ls-remote tras el push.
```

Cuando esté anotada y su mensaje de prueba llegue, COORDINACIÓN archiva MOTOR-10. Los próximos textos de agentes locales,
en un solo bloque, sin `/remote-control` (regla 13).
