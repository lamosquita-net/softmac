# Relevo de COORDINACIÓN

Nota para la sesión que tome el papel de COORDINACIÓN. Puesta al día el **15-10-2026, ~09:45 (Madrid)** por COORDINACIÓN-5
(`session_016j9wqSAibMrYnYJb1dHkcn`, 13-10 a 15-10, Opus 5.5 alto), que relevó a COORDINACIÓN-4 (archivada).
Leer antes: `CLAUDE.md` (**primera regla fija: datos personales del HUMANO nunca en GitHub**; al HUMANO se le llama
**Titín**), `docs/TAREAS.md` (tabla de agentes, **reglas 1–19**, filas FM.19, FS.13 y F7.3), `FlyWeb/docs/motor.md`
(«Nivel 129») y `FlyWeb/docs/relevo-motor.md`.

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
verified»). Los agentes locales te escriben con `SendMessage` a tu **nombre** de `ListAgents` («Nube Coordinación (6)»).
Si `send_message` responde `session_inactive`, el agente local ha perdido el Remote Control (pasa en **todas** cada vez
que Titín reinicia la app o el Mac): díselo a Titín al momento con el texto preparado.

| Agente | Sesión | Estado al 15-10, 09:45 |
|---|---|---|
| VIGÍA (Haiku) | `session_01XD1RBYQ5oESHWKeqZWSG4e` | Rutina cada hora, 8–23 h. **No acepta órdenes de agentes**: su destino lo cambia Titín |
| MOTOR-8 (Opus, xhigh) | `session_01YAuwa2BsTVR6GZqzr1wtex` | Solo **block-ruby-003** (rama `nube/ruby-003`); al acabar, nota y archivar. Contexto ~55 % |
| MOTOR-9 | por abrir | Nivel 130 (1.14, V8 13.0). Texto abajo |
| SEGURIDAD-PORTES (Opus, medio) | `session_01NkotiT2nNYznsrQu9rssiy` | FS.13 hecha. Poniendo al día `RELEVO-SEGURIDAD.md` para relevarse (78 %) |
| SEGURIDAD-PORTES-2 | por abrir | Texto abajo, cuando la nota esté |
| SEGURIDAD-VIGÍA (Haiku) | `session_019wTc3m4aVuvkKTEGMXdEHS` | Rutina semanal |
| CONTENIDOS-WEB-2 (Sonnet, medio) | `session_015tHV7uDdbAc6uZ1VwmgcqD` | Web de la 1.13 hecha (#209). Espera `version-1.14.md` |
| LOCAL-3 (7,1, Opus, alto) | `session_01YWS5bh1uWYu5iPLHX3qx3N` | Relevo listo: `flyweb` = 1.13 (37197fe0), nota en `FlyWeb/docs/relevo-local.md`. Archivar cuando LOCAL-4 esté activa |
| LOCAL-4 | por abrir | Texto abajo |
| PUBLICACIÓN (7,1, Sonnet) | `session_01H791v6t2GL9FoNPAxJR6tq` | **Archivada el 15-10 a las 09:31** (¿por Titín?). Para la 1.14 hará falta PUBLICACIÓN-2 (Sonnet, medio, `/remote-control`) |
| SERVIDOR-LOCAL, ARQUITECTURA (7,1) | ver su fila | Sin tareas abiertas |

Notas de tablero: commits con `[coord]` (el Vigía los ignora); reglas, CLAUDE.md y docs por PR, que fusionas tú.
**PR de otros agentes:** fusiona con `expectedHeadSha`; si un agente sube un commit tarde y se queda fuera del squash,
recupéralo con *cherry-pick* en un PR nuevo (pasó dos veces con MOTOR-8; ya avisa antes).

## Estado al relevo (15-10, ~09:45)

| Versión | Qué | Estado |
|---|---|---|
| 1.12.1 / 1.12.2 | RubyLB y resto de FS.12 | Publicadas (14-10) |
| **1.13** | Nivel 129 completo + V8 12.9 (ISel de Turboshaft y *wrapper* genérico wasm→JS encendidos, regla 19) + Menlo; brave-core `nube/motor-129` 325686916c, build 22 | **Firmada el 15-10 a las 09:28**; appcast 157.64.22. La web tardaba en publicarse: comprobado a las 09:56 con una rutina (`send_later`) |
| 1.14 | Nivel 130 con V8 13.0 (regla 18) | Por empezar (MOTOR-9) |

- **block-ruby-003** (WPT de ruby que falla con Menlo y en Chrome 129 pasa): MOTOR-8 en `nube/ruby-003`; va en la
  1.13.1 o con la 1.14, según lo que salga.
- **Decidido por Titín (15-10):** JetBrains Mono solo en la interfaz y las páginas internas de FlyWeb; la monoespaciada
  por defecto de las webs sigue en Menlo, como Chrome (huella y métricas). Anotado en FM.19.
- **Reglas nuevas de estos días:** 13 ampliada (no archivar antes de que el relevo esté activo; textos de arranque en
  mensaje propio con modelo y esfuerzo; órdenes también en la fila), 17 (revisión de seguridad de portes grandes),
  18 (un nivel, una versión, con su V8), 19 (lo apagado se enciende cuando upstream lo lleva de serie). Al HUMANO se
  le llama Titín (CLAUDE.md).
- **Maglev:** punto de decisión en el nivel 132 (V8 13.2 LTS). **WebGPU:** hacia el 140.

## Pendiente de otros

- **Titín:** abrir COORDINACIÓN-6 (texto abajo) y luego, con los ids de COORDINACIÓN-6, MOTOR-9, LOCAL-4 y
  SEGURIDAD-PORTES-2; PUBLICACIÓN-2 antes de la 1.14.
- **Archivar al activarse su relevo:** LOCAL-3, SEGURIDAD-PORTES; MOTOR-8 al terminar block-ruby-003; COORDINACIÓN-5
  (esta) en cuanto COORDINACIÓN-6 esté anotada.

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
- **Relevos de agentes locales: `/remote-control` siempre** (regla 13). El HUMANO lo tiene marcado en las preferencias de
  la app, pero se pierde al actualizarla. LOCAL-2 quedó archivada el 13-10 (~20:30) en mitad de la compilación de
  RubyLB y dejó de recibir mensajes sin que nadie lo notara: si un agente local calla, mirar `get_session`.
- **Antes de decir que algo espera la firma del HUMANO, mirar el appcast** (`curl …/stable/appcast.xml`). El 13-10 se
  le dijo dos veces que faltaba su firma cuando ya había firmado.

- **Una sesión local solo recibe `send_message` con Remote Control activo** y sin archivar. Comprobarlo con
  `list_sessions` (`connection_status`). Si alguien la archiva desde la web, la ventana sigue abierta en la 7,1 pero
  deja de recibir mensajes. Se arregla con `/remote-control` en esa ventana (PUBLICACIÓN, 12-10).

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

## Texto de arranque para COORDINACIÓN-6

Abrirla desde la app: nube, repos `softmac` y `brave-core`, **Opus 5.5, esfuerzo alto (`high`)**, y pegar:

```
Eres COORDINACIÓN de FlyWeb (monorepo lamosquita-net/softmac; fork lamosquita-net/brave-core): COORDINACIÓN-6, relevo de COORDINACIÓN-5 (session_016j9wqSAibMrYnYJb1dHkcn). Lee en este orden: CLAUDE.md, docs/TAREAS.md (tabla, reglas 1–19, filas FM.19, FS.13 y F7.3) y FlyWeb/docs/coordinacion.md (nota de relevo del 15-10).
1. Comprueba con get_session tu modelo y si tienes send_message. Dímelo en una línea.
2. Dame tu id de sesión y el texto exacto que debo pegar al Vigía para cambiarle el destino.
3. Anota en tu fila de docs/TAREAS.md (commit «[coord]») que COORDINACIÓN es ahora esta sesión. En coordinacion.md, «Textos de arranque pendientes», cambia el id y el nombre de COORDINACIÓN-5 por los tuyos (session_… y «Nube Coordinación (6)»). Archiva session_016j9wqSAibMrYnYJb1dHkcn.
4. Dame los textos de MOTOR-9, LOCAL-4 y SEGURIDAD-PORTES-2, cada uno listo para pegar, con modelo y esfuerzo en la primera línea, y resume el estado en 5 líneas.
Al HUMANO se le llama Titín. Español, commits en inglés con Co-Authored-By de Claude. Breve, crítico y con conclusión; a mí solo decisiones. No me escribas por avisos rutinarios.
```

## Textos de arranque pendientes (15-10)

Para Titín (ids de COORDINACIÓN-6 ya puestos, 15-10). Se borran de aquí cuando la sesión está activa y anotada en su fila. No se archiva la anterior hasta entonces.

**MOTOR-9** — nube, repos softmac y brave-core, **Opus 5.5, esfuerzo extra (xhigh)**. Ya se puede abrir.

```
Eres MOTOR de FlyWeb: MOTOR-9, relevo de MOTOR-8 (session_01YAuwa2BsTVR6GZqzr1wtex), que sigue activo solo para block-ruby-003; no toques ese tema. Lee CLAUDE.md, docs/TAREAS.md (tabla, reglas 1–19, filas FM.19 y FS.13), FlyWeb/docs/relevo-motor.md (sección de MOTOR-8 a MOTOR-9), FlyWeb/docs/motor.md «Nivel 129» y FlyWeb/tools/port/README.md (lecciones del 129).
1. Comprueba con get_session tu modelo, esfuerzo y si tienes send_message.
2. Anota tu id en la fila de MOTOR (commit «[motor]», por PR) y manda un mensaje de prueba a COORDINACIÓN (session_01DdLcRgFWWjq51j1Hs5pLsn).
3. Abre FM.20 con el inventario del nivel 130: Baseline y subfunciones, flags que pasan a stable 129→130, API de V8 13.0 contra la 116, cambios fuera de Blink que vean las webs (lección de Menlo) y la tabla de lo apagado (regla 19), con coste por porte. Regla 18: el 130 sale entero como 1.14, con V8 13.0. Manda la lista a COORDINACIÓN antes de portar nada.
Al HUMANO se le llama Titín. Español; commits en inglés con Co-Authored-By de Claude. Breve, crítico y con conclusión.
```

**SEGURIDAD-PORTES-2** — nube, repos softmac y brave-core, **Opus 5.5, esfuerzo medio**. Abrir cuando SEGURIDAD-PORTES
haya puesto al día `docs/RELEVO-SEGURIDAD.md`.

```
Eres SEGURIDAD-PORTES de FlyWeb: SEGURIDAD-PORTES-2, relevo de session_01NkotiT2nNYznsrQu9rssiy. Lee CLAUDE.md, docs/TAREAS.md (tabla, reglas 1–19, fila FS.13), docs/RELEVO-SEGURIDAD.md y docs/SEGURIDAD.md.
1. Comprueba con get_session tu modelo y si tienes send_message. Anota tu id en tu fila y manda un mensaje de prueba a COORDINACIÓN (session_01DdLcRgFWWjq51j1Hs5pLsn).
2. Sin tareas hasta que MOTOR-9 abra el paso de V8 13.0 del nivel 130. Entonces abres FS.14: ronda seg/v8-13.0 (parches de patches/v8 contra la 13.0, época de caché nueva, d8 y mjsunit), pasada de API del embedder entre 12.9 y 13.0, la tabla de lo apagado (regla 19) y lo nuevo que una web pueda alcanzar.
Al HUMANO se le llama Titín. Responde siempre en castellano. Commits en inglés con Co-Authored-By de Claude.
```

**LOCAL-4** — local en la MacPro7,1, **Opus 5.5, esfuerzo alto**. Abrir cuando LOCAL-3 haya movido `flyweb` a la
1.13 y escrito `FlyWeb/docs/relevo-local.md`.

```
/remote-control
```
y después:
```
Eres LOCAL de FlyWeb: LOCAL-4, relevo de LOCAL-3 (session_01YWS5bh1uWYu5iPLHX3qx3N). Lee CLAUDE.md, docs/TAREAS.md (tabla, reglas 1–19, fila FM.19) y FlyWeb/docs/relevo-local.md.
1. Comprueba con get_session tu modelo, esfuerzo y que tienes Remote Control. Anota en la fila de LOCAL tu id local_ y el session_ con el que te llega send_message desde la nube.
2. Manda un mensaje de prueba a COORDINACIÓN con SendMessage, tras ListAgents, al nombre «Nube Coordinación (6)».
3. Tareas, por orden: (a) cuando MOTOR-8 entregue el arreglo de block-ruby-003, Static incremental y esa WPT con el wpt-ref.py nuevo; (b) cuando MOTOR-9 entregue el paso de V8 13.0, Static y ASan aislados con claude.ai, YouTube y las webs con JIT. Cada compilación larga despierta tu sesión al terminar; cada resultado va a la fila y a COORDINACIÓN.
Al HUMANO se le llama Titín. Español.
```
