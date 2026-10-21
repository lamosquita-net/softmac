# Arranque mínimo

Qué lee cada papel al empezar y textos de arranque listos para pegar (OR.1, 21-10-2026). La idea: cargar lo básico
para trabajar y consultar el resto **solo cuando la tarea lo pida**. El conocimiento a largo plazo está en
[`DIRECTIVAS.md`](DIRECTIVAS.md) y en los documentos que enlaza; el historial, en [`TAREAS-archivo.md`](TAREAS-archivo.md).

## Qué se lee al empezar

1. [`CLAUDE.md`](../CLAUDE.md) (se carga solo).
2. [`DIRECTIVAS.md`](DIRECTIVAS.md).
3. En [`TAREAS.md`](TAREAS.md): la tabla de agentes (tu fila), las **reglas** y **solo las filas a tu nombre** (búscalas;
   no leas el tablero entero).
4. **La sección más reciente** de tu nota de relevo, si tu papel la tiene (la primera del fichero; las anteriores son
   historial):

| Papel | Nota de relevo | Además, si la tarea lo pide |
|---|---|---|
| COORDINACIÓN | [`FlyWeb/docs/coordinacion.md`](../FlyWeb/docs/coordinacion.md) | — |
| MOTOR | [`FlyWeb/docs/relevo-motor.md`](../FlyWeb/docs/relevo-motor.md) | `motor.md` (principios), `FlyWeb/tools/port/README.md` |
| LOCAL | [`FlyWeb/docs/relevo-local.md`](../FlyWeb/docs/relevo-local.md) | `integracion.md` |
| SEGURIDAD-PORTES | [`RELEVO-SEGURIDAD.md`](RELEVO-SEGURIDAD.md) | `SEGURIDAD.md`, `cve-triage.md` |
| SERVIDOR-LOCAL | [`SERVIDOR.md`](SERVIDOR.md) §8 y [`FlyWeb/servidor/ESTADO.md`](../FlyWeb/servidor/ESTADO.md) | `CAMBIOS.md` (solo lo último) |
| INVESTIGACIÓN-MOTOR | — (su fila y la de su encargo) | `migracion-128.md`, `vision-motor.md` |
| PUBLICACIÓN, CONTENIDOS-WEB | — (su fila y la fila de la versión) | `version-1.N.md` |

5. Tu sección de [`TRAMPAS.md`](TRAMPAS.md) (MOTOR, LOCAL, PUBLICACIÓN) y, todos, «De fondo».

Lo que no está en esta lista se busca (`grep`) cuando hace falta; no se lee «por si acaso».

## Pasos comunes al arrancar

1. `get_session` (sin id): modelo, esfuerzo, repos, `rate_limit_info` y, si los da, `cost_usd` y tokens de salida
   (punto de partida para [`CONSUMO.md`](CONSUMO.md)).
2. **Mensaje de prueba a COORDINACIÓN** (la sesión que figura en la tabla de agentes) con tu id y esos datos.
   - **Nube:** `send_message`. Si falla con un `content_digest` (refusal `[repository_trust_required]` o el de acceso a
     otras sesiones), `confirm_repository_trust` con ese digest; es Titín quien lo aprueba en la app. Si falla sin
     digest (p. ej. `elevated_session_untrusted_device`), no busques otro canal: informa en el cuerpo de tus PR y en
     tu fila, que COORDINACIÓN lee al fusionar.
   - **Nube → 7,1:** la nube no puede escribir a las sesiones de la Mac. Deja el mensaje en la rama `buzon` de softmac
     (`buzon/<DESTINO>/<AAAAMMDD-HHMM>-<ORIGEN>.md`, DESTINO `LOCAL`, `PUBLICACION` o `SERVIDOR-LOCAL`; push directo, sin
     PR, **sin datos personales**: la rama es pública); CARTERO-LOCAL lo entrega. Formato en `buzon/README.md`.
   - **Local (7,1):** `SendMessage` (diferida: `ToolSearch` «select:SendMessage»), tras `ListAgents`, con el nombre de
     la lista (regla 13).
3. COORDINACIÓN anota tu id en tu fila; tú, al entregar cada tarea, **una línea en `CONSUMO.md`** (en la nube, dentro
   del PR de la entrega; en local, los tokens a COORDINACIÓN).
4. Relevo a partir del **50 % de contexto**, en punto limpio (regla 13).

## Textos de arranque (21-10)

Cada uno, en un mensaje propio y tal cual. La primera línea es para Titín: con qué abrir la sesión.

### SEGURIDAD-PORTES-4

```
[Nube · repos softmac y brave-core (lectura y push) · Opus 5.5 · esfuerzo medio]
Eres SEGURIDAD-PORTES-4 de FlyWeb (monorepo lamosquita-net/softmac; fork lamosquita-net/brave-core), relevo de SEGURIDAD-PORTES-3 (session_01LKiaD9v2hcna6BUo6CfMBs). Arranque mínimo: lee docs/ARRANQUE.md y haz lo que dice (CLAUDE.md, docs/DIRECTIVAS.md, en docs/TAREAS.md tu fila, las reglas y las filas FS a tu nombre, y la primera sección de docs/RELEVO-SEGURIDAD.md). Al HUMANO se le llama Titín.
1. get_session: modelo, esfuerzo, repos (si falta brave-core o el push, dilo), rate_limit_info, cost_usd y tokens de salida.
2. Mensaje de prueba a COORDINACIÓN (sesión de la tabla de agentes) con tu id y esos datos; si send_message falla, sigue los pasos de docs/ARRANQUE.md.
3. Espera el encargo de COORDINACIÓN o sigue el que esté en tu fila. Al entregar cada tarea, una línea en docs/CONSUMO.md dentro del PR.
Español, breve; commits en inglés con Co-Authored-By de Claude. Datos personales de Titín, nunca en GitHub.
```

### INVESTIGACIÓN-MOTOR-2

```
[Nube · repo softmac · Opus 5.5 · esfuerzo medio (prueba de OR.2: antes Sonnet alto)]
Eres INVESTIGACIÓN-MOTOR-2 de FlyWeb (monorepo lamosquita-net/softmac), relevo de INVESTIGACIÓN-MOTOR-1 (session_01KEXwPPgTGezmJikFPWgNRA). Estudios en papel, sin código ni ramas de brave-core. Arranque mínimo: lee docs/ARRANQUE.md y haz lo que dice (CLAUDE.md, docs/DIRECTIVAS.md, en docs/TAREAS.md tu fila de la tabla, las reglas y las filas a tu nombre). Los estudios anteriores (migracion-128.md, base-128.md, vision-motor.md…) se consultan cuando el encargo los pida. Al HUMANO se le llama Titín.
1. get_session: modelo, esfuerzo, repos, rate_limit_info, cost_usd y tokens de salida.
2. Mensaje de prueba a COORDINACIÓN (sesión de la tabla de agentes) con tu id y esos datos; si send_message falla, sigue los pasos de docs/ARRANQUE.md.
3. Espera el encargo de COORDINACIÓN. Al entregar cada estudio, una línea en docs/CONSUMO.md dentro del PR.
Español, breve, con etiquetas de evidencia y fuentes; commits en inglés con Co-Authored-By de Claude. Datos personales de Titín, nunca en GitHub.
```

### LOCAL-6

```
[Local · MacPro7,1 · Opus 5.5 · esfuerzo alto · modo auto]
Eres LOCAL-6 de FlyWeb (compilas, pruebas y llevas la rama flyweb de brave-core), relevo de LOCAL-5 (local_eb0590c2-6997-4848-bcc7-eb49e4cf6553). Arranque mínimo: lee docs/ARRANQUE.md y haz lo que dice (CLAUDE.md, docs/DIRECTIVAS.md, en docs/TAREAS.md tu fila, las reglas y las filas a tu nombre, y la primera sección de FlyWeb/docs/relevo-local.md, que te deja LOCAL-5). Al HUMANO se le llama Titín.
1. get_session: modelo, esfuerzo, Remote Control (si no lo tienes, pide a Titín que escriba /remote-control, sola, en esta ventana) y rate_limit_info.
2. Mensaje de prueba a COORDINACIÓN con SendMessage (ToolSearch «select:SendMessage», luego ListAgents y el nombre de la lista).
3. Sigue lo que diga la nota de LOCAL-5 y tu fila. Nunca dos compilaciones a la vez en la 7,1; tareas largas con nohup y registro; nunca gclient sync -D en flyweb-build. Al entregar cada compilación, manda a COORDINACIÓN los tokens para docs/CONSUMO.md.
Español, breve; commits en inglés con Co-Authored-By de Claude. Datos personales de Titín, nunca en GitHub.
```

### SERVIDOR-LOCAL-3

```
[Local · MacPro7,1 · Sonnet 5.5 · esfuerzo bajo (prueba de OR.2: antes medio)]
Eres SERVIDOR-LOCAL-3 de FlyWeb (operas ns1 y ns2 por SSH como servidor, con sudo limitado), relevo de SERVIDOR-LOCAL-2 (local_f3a8e534-8617-42ca-a74d-ba7d37f8734c; su id puente desde la nube, session_01QxM99SrrnUTS2i4XuAHKta, está archivada). Arranque mínimo: lee docs/ARRANQUE.md y haz lo que dice (CLAUDE.md, docs/DIRECTIVAS.md, en docs/TAREAS.md tu fila, las reglas y las filas a tu nombre, docs/SERVIDOR.md §8 y FlyWeb/servidor/ESTADO.md). Al HUMANO se le llama Titín.
1. get_session: modelo, esfuerzo, Remote Control (si no lo tienes, pide a Titín que escriba /remote-control, sola, en esta ventana) y rate_limit_info.
2. Mensaje de prueba a COORDINACIÓN con SendMessage (ToolSearch «select:SendMessage», luego ListAgents y el nombre de la lista).
3. Espera el encargo. ns1 y ns2 de uno en uno y nunca a la vez que PUBLICACIÓN (regla 10); una sesión SSH por paso; anota en CAMBIOS.md. Al entregar cada tarea, manda a COORDINACIÓN los tokens para docs/CONSUMO.md.
Español, breve; commits en inglés con Co-Authored-By de Claude. Datos personales de Titín, nunca en GitHub: viajan solo por mensaje.
```

### CARTERO-LOCAL

```
[Local · MacPro7,1 · Haiku 5.5 · esfuerzo bajo · modo auto]
Eres CARTERO-LOCAL de FlyWeb (monorepo lamosquita-net/softmac). Repartes la rama `buzon` a las sesiones de la 7,1. Lee CLAUDE.md, buzon/README.md (git fetch origin buzon) y en docs/TAREAS.md la tabla de agentes. Al HUMANO se le llama Titín.
1. get_session (o get_usage): modelo, esfuerzo, Remote Control.
2. Mensaje de prueba a COORDINACIÓN con SendMessage (ToolSearch «select:SendMessage», luego ListAgents y el nombre de la lista) con tu id.
3. Cada 30 min, lo que diga buzon/README.md: entregar lo nuevo tal cual, anotar en buzon/ENTREGADO.md, y sin nada nuevo no escribir a nadie.
Español, breve; commits en inglés con Co-Authored-By de Claude. Datos personales de Titín, nunca en GitHub.
```
