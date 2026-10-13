# Relevo de COORDINACIÓN

Nota para la sesión que tome el papel de COORDINACIÓN. Escrita el 12-10-2026, ~19:00 (Madrid), y puesta al día el 13-10, ~01:00,, por COORDINACIÓN-4
(`session_01PiGz6Mzdjza8YJbFEFz4JP`, 09-10 a 12-10), que relevó a COORDINACIÓN-3 (archivada).
Leer antes: `CLAUDE.md` (**primera regla fija: datos personales del HUMANO nunca en GitHub**), `docs/TAREAS.md`
(tabla de agentes, reglas 1–15, filas FM.15, FM.16, FM.17, FS.9 y SV.1/SV.6), `FlyWeb/docs/motor.md` (principio 11) y
`FlyWeb/docs/v8-12.8-blink.md` (plan y registro de FM.17).

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

| Agente | Sesión | Cómo |
|---|---|---|
| VIGÍA (Haiku) | `session_01XD1RBYQ5oESHWKeqZWSG4e` | Te manda los cambios cada hora. **No acepta órdenes de otros agentes**: cambiarle el destino o el script lo tiene que pedir el HUMANO en su sesión |
| MOTOR-6 (Opus 5.5, `xhigh`) | `session_01L1KPtm9u4214pcJi5ipUit` (desde el 13-10, ~01:25; MOTOR-3, -4 y -5 archivadas) | `send_message`. Lleva la 1.11.2, el 128 (1.12) y RubyLB (1.12.1) |
| SEGURIDAD-PORTES (Opus) | `session_01NkotiT2nNYznsrQu9rssiy` | `send_message` |
| SEGURIDAD-VIGÍA (Haiku) | `session_019wTc3m4aVuvkKTEGMXdEHS` | `send_message` |
| CONTENIDOS-WEB (Sonnet) | `session_014vNkVoSXJ91jX4QRXD7Szp` | `send_message` |
| SERVIDOR-LOCAL-2 (7,1) | `session_01QxM99SrrnUTS2i4XuAHKta` (Remote Control; **archivada el 12-10**) | Nota en su fila (SV.6) hasta que el HUMANO le active `/remote-control` |
| ARQUITECTURA (7,1, Fable) | `session_01QT5cTiyXsBVnJfoXg2PJF7` (Remote Control) | Te escribe ella; anota en el tablero lo que pida |
| LOCAL-2 (7,1, Opus) | `session_01PenyqfVJwxLUc7kaS55MR3` (Remote Control) | `send_message`; las entregas, además, en su fila (FM.15) |
| PUBLICACIÓN (7,1, Sonnet) | `session_01H791v6t2GL9FoNPAxJR6tq` (Remote Control, reactivada el 12-10; id local `local_1eb27eb5…`) | `send_message` |

Notas de tablero: commits con `[coord]` (el Vigía los ignora), push directo a `main` solo de notas; reglas, CLAUDE.md y
docs por PR. Trabajar solo en la rama asignada a tu sesión. Antes de afirmar el estado de una rama, mirarla en GitHub.

## Estado al relevo (13-10, ~01:00)

Versiones (decisiones del HUMANO del 12-10; detalle en las filas F4.8, FM.15, FM.16 y FM.17):

| Versión | Qué | Estado |
|---|---|---|
| 1.11 | Nivel 127 (V8 12.7) | **Publicada** (12-10) |
| 1.11.1 | Huella de red: *client hints*, Kyber/ECH, HTTP/2 sin `3:1000`, `platformVersion` 10.15.7 (F4.8, brave-core `local/huella-127` 44c1d6e4) | Entregada por LOCAL-2; **PUBLICACIÓN publicando** (orden de COORDINACIÓN-4) |
| 1.11.2 | FM.17: Blink sobre la API de V8 12.8 + V8 12.8 (`seg/v8-12.8` f8cbd8c9, FS.10 hecho) | Static y ASan de e9c4ad85 **hechos** (LOCAL-2); falta montar huella + `flyweb_version` 1.11.2 sobre f8cbd8c9 (MOTOR-6) y compilar |
| 1.12 | Nivel 128 **sin `ruby-align`** (`nube/motor-128` 84735505) | En código; hay que rebasarla sobre `seg/v8-12.8` (MOTOR-6) |
| 1.12.1 | RubyLB completo (R1–R5) en `nube/motor-128-ruby` | R1, R2 y R3a hechos (e727339d); R3 en curso. LOCAL compila tras R2 (4f1ee98b, en marcha) y tras R3; se publica todo junto |

- **Cola de LOCAL** (FM.16): 1.11.1 → ASan de FM.17 (hecho) → 1.11.2 → 1.12 → Static R1+R2 → Static tras R3.
- **No se empieza el nivel 129 hasta terminar RubyLB** (HUMANO). Renombres de LayoutNG: no se portan; traductor de diffs
  en `FlyWeb/tools/port/`.
- **Red y gráfica:** no se migran (F5.4 cerrada). Principio 13 de `motor.md`: huella coherente con el Chrome N
  (medición de F4.8 en cada nivel). WebGPU: punto de decisión hacia el nivel 140 (hoja de ruta), experimento F5.5
  pendiente en la 6,1.
- **Límite semanal:** el HUMANO dice que no frene el trabajo por él (12-10, 23:00).

## Pendiente de otros

- **MOTOR-6** (abierta): sigue R3 desde 4a4c18ebbdd y los puntos
  4–6 de la nota de MOTOR-4 (1.11.2 sobre f8cbd8c9, rebase del 128).
- **HUMANO:** firmar en bak la 1.11.1 cuando PUBLICACIÓN le pase las órdenes; pegar en la ventana de PUBLICACIÓN que
  no pida confirmación para publicar (regla 11; también en `CLAUDE.md`); `/remote-control` en SERVIDOR-LOCAL-2
  (archivada); formulario de GitHub Support; borrar `claude/regla-14`.
- **SERVIDOR-LOCAL** (SV.1, SV.6): lo de siempre, por su fila (no recibe mensajes hasta que tenga Remote Control).

## Red del entorno de la nube

El entorno de la nube (el mismo para COORDINACIÓN, el Vigía y los demás agentes de la nube; se hereda en los relevos)
tiene la red en «Personalizado», con la lista por defecto de gestores de paquetes y dos dominios nuestros añadidos por
el HUMANO el 13-10:

- `updates.flyweb.lamosquita.net`: el Vigía lee `stable/appcast.xml` cada hora y avisa si no coincide con
  `FlyWeb/web/VERSION` de `main` («WEB DESFASADA» / «WEB SINCRONIZADA»).
- `flyweb.lamosquita.net`: COORDINACIÓN comprueba la web tras cada publicación (portada, SHA, descarga).

Solo lectura y pocas peticiones. Otro dominio se le pide al HUMANO.

## Trampas de estos días

- **La web solo se publica sola si su PR (con `FlyWeb/web/VERSION`) está fusionado antes de la firma** (SV.6). En la
  1.11.1 no lo estaba: el HUMANO firmó a las 9:00 y la web siguió en la 1.11 hasta las 16:00. Desde el 13-10,
  PUBLICACIÓN no pasa órdenes de firma sin ese PR fusionado. Y el estado de una sesión puede ser viejo: para saber si
  algo está publicado, mirar el appcast, no la sesión.
- **PUBLICACIÓN (local) no llega por `send_message` a las sesiones de la nube** (CONTENIDOS-WEB, MOTOR…): deja los
  datos del DMG en el tablero y COORDINACIÓN se los pasa a CONTENIDOS-WEB. Las sesiones de la nube sí le llegan a ella.
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

## Texto de arranque para COORDINACIÓN-5

Abrirla desde la app: nube, repos `softmac` y `brave-core`, **Opus 5.5, esfuerzo alto (`high`)**, y pegar:

```
Eres COORDINACIÓN de FlyWeb (monorepo lamosquita-net/softmac; fork lamosquita-net/brave-core), relevo de COORDINACIÓN-4 (session_01PiGz6Mzdjza8YJbFEFz4JP). Lee en este orden: CLAUDE.md, docs/TAREAS.md (tabla, reglas 1–15, filas FM.15–FM.17, FS.9, SV.1, SV.6) y FlyWeb/docs/coordinacion.md (nota de relevo). Después:
1. Comprueba con get_session tu modelo y si tienes send_message. Dímelo en una línea.
2. Dame tu id de sesión y el texto exacto que debo pegar al Vigía para cambiarle el destino (no acepta órdenes de agentes).
3. Anota en tu fila de docs/TAREAS.md (commit «[coord]») que COORDINACIÓN es ahora esta sesión, y archiva session_01PiGz6Mzdjza8YJbFEFz4JP.
4. Resume el estado en 5 líneas.
Español, commits en inglés con Co-Authored-By de Claude. Breve, crítico y con conclusión; a mí solo decisiones. No me escribas por avisos rutinarios.
```
