# Relevo de COORDINACIÓN

Nota para la sesión que tome el papel de COORDINACIÓN. Escrita el 12-10-2026, ~19:00 (Madrid), por COORDINACIÓN-4
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
| MOTOR-3 (Opus 5.5, `xhigh`) | `session_01UiNp8ASzm2Sn5mbDycomnk` | `send_message`. Lleva FM.17 |
| SEGURIDAD-PORTES (Opus) | `session_01NkotiT2nNYznsrQu9rssiy` | `send_message` |
| SEGURIDAD-VIGÍA (Haiku) | `session_019wTc3m4aVuvkKTEGMXdEHS` | `send_message` |
| CONTENIDOS-WEB (Sonnet) | `session_014vNkVoSXJ91jX4QRXD7Szp` | `send_message` |
| SERVIDOR-LOCAL-2 (7,1) | `session_01QxM99SrrnUTS2i4XuAHKta` (Remote Control; **archivada el 12-10**) | Nota en su fila (SV.6) hasta que el HUMANO le active `/remote-control` |
| ARQUITECTURA (7,1, Fable) | `session_01QT5cTiyXsBVnJfoXg2PJF7` (Remote Control) | Te escribe ella; anota en el tablero lo que pida |
| LOCAL-2 (7,1, Opus) | `session_01PenyqfVJwxLUc7kaS55MR3` (Remote Control) | `send_message`; las entregas, además, en su fila (FM.15) |
| PUBLICACIÓN (7,1, Sonnet) | `session_01H791v6t2GL9FoNPAxJR6tq` (Remote Control, reactivada el 12-10; id local `local_1eb27eb5…`) | `send_message` |

Notas de tablero: commits con `[coord]` (el Vigía los ignora), push directo a `main` solo de notas; reglas, CLAUDE.md y
docs por PR. Trabajar solo en la rama asignada a tu sesión. Antes de afirmar el estado de una rama, mirarla en GitHub.

## Estado al relevo (12-10, ~19:00)

- **1.10** publicada (157.64.15, nivel 126). Pruebas de PDF del HUMANO bien (FM.14).
- **1.11** (nivel 127, V8 12.7): Release **157.64.16** de brave-core `seg/v8-12.7` **94914682** en marcha (LOCAL-2).
  Antes de publicar, LOCAL repite la pasada de PDF (Hacienda, EE. UU., BOE). `onselectionchange` NO falta (Chrome 127
  tampoco: `TestExpectations`; llega en la 143). Después: entrega a PUBLICACIÓN (regla 11), web por PR de LOCAL/PUBLICACIÓN
  (revisarlo y fusionarlo: publica la web sola).
- **1.11.1 = FM.17** (Blink sobre la API de V8 12.8; nivel 127): MOTOR-3, plan en `v8-12.8-blink.md`. Fases 1 y 2
  hechas (`nube/v8-12.8-api` ade843c5, sin compilar). **Fase 3a en curso** (refactors de `ScriptWrappable`, cadena
  aprobada: faf089b95a79 → 1b454576028b → 1e59163c7b24 → 766b09e84f37 → b148acd34a84 → 04bd00feaa86…). **No se portan**
  2137f1da3a53/3379a89654e1 (`DOMWrapperWorld` al GC) ni c29211406542; `FastApiTypedArray` aplazada a la 13.3; V8
  aaa23fc87 como parche de desarrollo en esa rama (condiciones de SEGURIDAD-PORTES en FM.17), llega a usuarios con la
  1.11.1. Cada commit de `Object::Wrap` pasa por SEGURIDAD-PORTES antes de LOCAL (con ASan). **Reglas de relevo de
  ARQUITECTURA en FM.17** (plan del ítem (b) escrito tras la compactación, tres pasos al cerrar cada fase, relevo si el
  contexto pasa del 50 % al cerrar una fase; MOTOR-4 en `xhigh`). LOCAL compila FM.17 cuando se publique la 1.11.
- **Nivel 128** (FM.16): después de la 1.11.1, ya sobre la V8 12.8; `ruby-align` completo (decisión del HUMANO).
- **Web y datos personales**: ningún dato personal del HUMANO en la web ni en GitHub (decisiones del 09 y 10-10). El
  aviso legal queda con lamosquita + `admin@`. Los commits de #134 que los llevaban se quitaron de la rama; **queda que el
  HUMANO envíe el formulario a GitHub Support** (texto ya dado) y que GitHub confirme.

## Pendiente de otros

- **SERVIDOR-LOCAL** (SV.1, SV.6, FM.14): borrar el DMG más antiguo de `updates/` y comprobar la web de la 1.10;
  instalar el `flyweb-web-auto` de #126; instalar la unidad `flyweb-sync` de #132 (365 días); borrar las copias de las
  imágenes del aviso legal; pasar al HUMANO las órdenes para instalar como root `flyweb-desplegar` de `main`
  (SHA-256 `09cf93bd…`, modos `imagen` y `cifras` que leen como `servidor`).
- **HUMANO**: formulario de GitHub Support; borrar la rama sobrante `claude/regla-14` de softmac (no tiene PR).
- **Propuesta sin decidir** (COORDINACIÓN-4, 12-10): que LOCAL compare la huella TLS/HTTP2 de la 1.11 con la de Chrome
  127 real (p. ej. `tls.peet.ws`), porque la red sigue siendo la de la 116 aunque se declare 127.

## Trampas de estos días

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
