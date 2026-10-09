# Relevo de COORDINACIÓN

Nota para la sesión que tome el papel de COORDINACIÓN (antes NUBE-COORDINACIÓN). Escrita el 09-10-2026, 16:10, por la
sesión `session_014Y7jw2wo7cnQBsPqVZ2Gyu` (COORDINACIÓN-2, del 08-10 19:30 al 09-10), que relevó a la del 28-09.
Leer antes: `CLAUDE.md`, `docs/TAREAS.md` (tabla de agentes, reglas 1–13, lista «Despliegue de la organización del
09-10», filas FM.13–FM.15, FS.3, FS.8, FS.9), `FlyWeb/docs/motor.md` (política de niveles) e `integracion.md`.

## Qué hace este papel

- **Interlocutor técnico del HUMANO**: estrategia de motor (niveles, V8, Blink, excepciones), recomendaciones
  razonadas y críticas, decisiones escritas en el tablero. El HUMANO prefiere respuestas breves, críticas y con
  conclusión, y que se le pregunte antes de decisiones de producto.
- **Revisión**: tablero, ramas de brave-core (`local/*`, `seg/*`, `nube/*`) y todos los PR de softmac, **incluidos
  los de `FlyWeb/servidor/`** (desde el 09-10; SERVIDOR-NUBE se cierra) y los de CONTENIDOS-WEB. Revisión en el PR,
  con el pie de Claude Code; fusionar solo cuando lo diga el HUMANO.
- **Coordinación**: que cada arreglo llegue a todas las ramas que lo necesitan y avisar al agente que tiene que
  moverse (en su fila y, si corre prisa, por mensaje; ver «Cómo hablar con los demás»).
- **Dueño del código de NUBE de los niveles 117–124**, de FM.12 (`nube/form-vertical`), de F7.8
  (`nube/pinned-compartidas`) y de las ramas de integración. No toca `nube/motor-125+` (MOTOR).
- **Sin rutinas propias.** Solo la despiertan VIGÍA y el HUMANO.

## Vigilancia (funciona desde el 09-10, 12:03)

- **VIGÍA** es una sesión Haiku propia (`session_01XD1RBYQ5oESHWKeqZWSG4e`, «Vigía FlyWeb») con su rutina cada hora,
  8–23 h Madrid. Ejecuta un script de solo lectura (commits de la última hora en `flyweb`, `local/*`, `seg/*`,
  `nube/*` de brave-core y lo añadido a cada fila de `docs/TAREAS.md`) y, si hay algo, lo manda **con `send_message`**
  a COORDINACIÓN. Ignora los commits cuyo asunto lleva `[coord]`: **marcar así los commits propios del tablero.**
- **Al relevar: el Vigía tiene escrito el id de la sesión de COORDINACIÓN.** Hay que pedirle al HUMANO que le pegue
  la línea con el id nuevo (está en el texto de arranque de esta nota).
- Lo que **no** funcionó, para no repetirlo: (1) Haiku en sesión nueva por cada pasada que despierta con
  `fire_trigger` (nunca disparó, ni la del 08-10 ni la del 09-10); (2) rutina horaria que despierta a la propia
  coordinación (funciona, pero cada despertar relee todo el contexto). Todas borradas o desactivadas.
- Ventana de 70 min cada hora → repite a veces los 10 min solapados. El HUMANO puede pedirle al Vigía que guarde lo
  ya enviado en `/tmp/vigia.enviado`.

## Cómo hablar con los demás

- **COORDINACIÓN-2 no tenía `send_message`** (la creó otra sesión con `create_session`); las sesiones abiertas por el
  HUMANO desde la app sí lo tienen. **Primera tarea de la sesión nueva: comprobar si tiene `send_message`** (buscarla
  con ToolSearch). Si la tiene, es la vía normal para avisar a cualquier agente.
- Sin `send_message`: (a) **nota en la fila del agente** (regla 4; la lee cuando abre el tablero); (b) a una sesión
  **en la nube**, un aviso único con `create_trigger` (`persistent_session_id` = su sesión, `run_once_at` = dentro de
  2–3 min); probado con SEGURIDAD-PORTES el 09-10; (c) a las sesiones **locales** (LOCAL, PUBLICACIÓN,
  SERVIDOR-LOCAL, ARQUITECTURA), por el HUMANO si es urgente.
- Ids de sesión (09-10): VIGÍA `session_01XD1RBYQ5oESHWKeqZWSG4e`; MOTOR-2 `session_01UPMDyUjBgk8osmWVJDQMWt`;
  SEGURIDAD-PORTES `session_01NkotiT2nNYznsrQu9rssiy`; SEGURIDAD-VIGÍA `session_019wTc3m4aVuvkKTEGMXdEHS`;
  CONTENIDOS-WEB `session_014vNkVoSXJ91jX4QRXD7Szp`; locales: ver la tabla del tablero.

## Ramas y versiones (al 09-10, 16:00)

| Versión | Nivel | Rama | Estado |
|---|---|---|---|
| 1.9 | 125 + FM.12 + F7.8 | `flyweb` 64d61ebf (= `seg/v8-12.5` 50624c65) | publicada, firmada; web al día (#112, #120) |
| 1.10 | 126 | `seg/v8-12.6` **c3d250ff** (= 08375efa + arreglos de LOCAL 502c090f + época de caché 4) | en compilación (LOCAL); el Static 1 falló por PDFium (parches que nunca se aplicaban) y Perfetto en la V8 12.6, ya arreglados |
| 1.11 | 127 | `nube/motor-127` (V8 12.7.224.20) | **aparcado por el HUMANO** hasta que compile la 1.10 y sus arreglos estén fusionados (MOTOR-2, FM.15) |

- **FS.9 (riesgo de la 1.11):** la V8 12.7 **no tuvo rama LTS**. La 1.10 (12.6 = M126-LTS + 10 de la M132-LTS)
  lleva más correcciones que la 12.7 de serie; SEGURIDAD-PORTES está en espera y hará `seg/v8-12.7` cuando MOTOR-2
  desaparque el 127. Regla anotada: **la 1.11 no sale con menos correcciones de V8 que la 1.10.** Al desaparcar,
  **avisar a SEGURIDAD-PORTES** (lo pidió). Conflicto ya previsto: `src-utils-version.h.patch` (época 4 en las dos
  ramas) al fusionar los arreglos de la 1.10 en `motor-127`; se queda la de `motor-127`.
- Las ramas `nube/motor-N` se apilan; los parches de V8 de cada nivel viven en `patches/v8/` y SEGURIDAD-PORTES los
  mantiene en `seg/v8-12.x`, que sale de `nube/motor-N`. LOCAL compila desde `seg/v8-12.x`.

## Flujo de un arreglo de LOCAL

En 125+ los lleva MOTOR (a `nube/motor-N` y hacia arriba) y SEGURIDAD-PORTES los fusiona en `seg/v8-12.x`. En
117–124 y FM.12/F7.8, coordinación con `FlyWeb/tools/port/llevar.sh` (sin checkout):
`llevar.sh ~/brave-core nube/motor-124 nube/form-vertical <commits>`. Para comprobar fusiones sin checkout:
`git merge-tree --write-tree A B`; para ver ramas de brave-core sin clonar: `git fetch --filter=tree:0 --depth=N`.

## Trampas conocidas (de errores reales)

- **«Los parches aplican» no es «compila»**: esperar una ronda de errores por nivel (1.8: 4 errores y una caída;
  1.10: los parches de PDFium no se aplicaban nunca porque `util.js` no tenía `third_party/pdfium` en `flywebRepos`).
- **APIs que no existen en la 116**: buscar cada `#include` y símbolo nuevo en el árbol de la 116.
- **Bindings**: en la 116 los iteradores son `kWrapperTypeNoPrototype`; lo que el bind_gen portado haga sobre su
  prototipo necesita `IsEmpty()`.
- **V8 nueva por nivel**: revisar la API pública contra Blink/gin/content/PDFium de la 116; `-Werror`.
- **Ramas paralelas**: no fusionar una rama de otro nivel (arrastra sus `patches/v8/`); llevar solo el commit.
  Excepción comprobada: fusionar `flyweb` en `seg/v8-12.6` (08375efa) no cambió el árbol (solo ascendencia).
- **Dos sesiones del mismo agente** escribieron a la vez en `seg/*` el 08-10 (SEGURIDAD saliente y relevo). Al
  relevar a cualquiera: archivar la sesión vieja y desactivar sus rutinas.
- **Las cosas cambian entre dos mensajes**: comprobar la rama en GitHub justo antes de afirmar su estado.
- **Afirmar solo lo comprobado**, y decir qué no se ha podido comprobar.

## Pendiente al relevo

- **1.10**: esperar la entrega de LOCAL (regla 11) → PUBLICACIÓN (nueva, Sonnet; abrir cuando exista la entrega).
  `updates/` tiene 10 DMG (el límite): al subir la 1.10, SERVIDOR-LOCAL borra el más antiguo.
- **127**: cuando la 1.10 compile y sus arreglos estén fusionados en `nube/motor-127`, avisar a SEGURIDAD-PORTES (FS.9).
- **PR #115 (CONTENIDOS-WEB)**: tiene conflicto en `docs/TAREAS.md`; revisión pedida (frase de la 1.9 que promete
  de más, «algunas» correcciones de la 132, no explicar Turboshaft).
- **E2-06** (`updates.` solo DMG y `appcast.xml`) aplicado en ns2 el 09-10, 15:07; SERVIDOR-LOCAL repite el grep de
  `releaseNotesLink` tras aplicar (antes salió «ninguno»).
- **Despliegue de la organización**: marcar la casilla de SERVIDOR-NUBE cuando el HUMANO la cierre.
- Sesiones relevadas y archivadas: COORDINACIÓN-1 (`session_01V7t82aGfNqPiB5rR6Potoo`), SEGURIDAD antigua
  (`session_01BhHSWp2vNeVvVatBZozdoC`), NUBE-MOTOR-1 (`session_01E2aKsfuKBXjA4UmhRDA72x`).

## Texto de arranque para la sesión nueva

Abrirla **desde la app** (nube, repo `softmac` + `brave-core`, Opus 5.5, esfuerzo alto) y pegar:

```
Eres COORDINACIÓN de FlyWeb (monorepo lamosquita-net/softmac; fork lamosquita-net/brave-core), relevo de COORDINACIÓN-2 (session_014Y7jw2wo7cnQBsPqVZ2Gyu). Lee en este orden: CLAUDE.md, docs/TAREAS.md (tabla de agentes, reglas, lista de despliegue, filas FM.13–FM.15, FS.3, FS.8, FS.9) y FlyWeb/docs/coordinacion.md (nota de relevo). Después:
1. Comprueba si tienes la herramienta send_message (búscala con ToolSearch). Dímelo en una línea.
2. Dame tu id de sesión para que se lo pase al Vigía.
3. Anota en tu fila de docs/TAREAS.md (push directo, solo esa fila, commit con «[coord]») que COORDINACIÓN es ahora esta sesión.
4. Resume el estado en 5–8 líneas.
Trabajo en español, commits en inglés con la línea Co-Authored-By de Claude. Respuestas breves, críticas y con conclusión; pregunta antes de decisiones de producto; afirma solo lo que hayas comprobado. Sin rutinas propias: solo te despiertan el Vigía y el HUMANO.
```

Y al Vigía (sesión «Vigía FlyWeb»), con el id nuevo:

```
Cambio de destino: desde ahora manda tus avisos con send_message a la sesión <ID NUEVO> (COORDINACIÓN-3), no a session_014Y7jw2wo7cnQBsPqVZ2Gyu. Lo demás, igual.
```

Después: archivar `session_014Y7jw2wo7cnQBsPqVZ2Gyu`.
