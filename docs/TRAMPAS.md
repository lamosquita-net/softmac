# Trampas por papel

Lecciones que ya costaron horas, sacadas tal cual de «Trampas» de [`coordinacion.md`](../FlyWeb/docs/coordinacion.md)
(OR.1, 21-10-2026). Cada papel lee la suya al arrancar ([`ARRANQUE.md`](ARRANQUE.md)); las de fondo, en
[`DIRECTIVAS.md`](DIRECTIVAS.md). Quien aprenda una nueva, la añade aquí con fecha.

## MOTOR

- **Ids de commit**: el que se pasa a otro agente se comprueba con `git ls-remote` tras el push (MOTOR-10 dio uno de
  antes de un `--amend`).
- **Estimaciones de MOTOR en horas de reloj**, comparadas con el último nivel entregado: el «8–10 días» del 130 salió
  diez veces pesimista (el 129 fueron ~10 h).
- **(17–20-10) Compilaciones de FM.22:** cada error de una línea costaba una ronda (~1 h). Pedir a MOTOR, antes de
  entregar, un repaso contra las APIs de la 116 (absl::optional, base::expected, span, raw_ptr, gfx::SizeF, includes) y a
  LOCAL `-k 0`. Fijar siempre un sha concreto para LOCAL; si MOTOR sigue subiendo encima, rama aparte (`-c`).
- **WPT**: además de los `-expected.txt`, mirar `TestExpectations` de la versión de Chrome.
- **(21-10) La Static tapa includes que faltan:** usa cabeceras precompiladas (`build/config/pch.gni`: `enable_precompiled_headers = !is_official_build…`; Blink core, `precompile_core.h`) y la Release no. La 1.15.2 compiló en Static y la Release dio 110 errores (absl `optional`, `cppgc::Visitor` incompleto, una clase sin declarar): una ronda más. En los ficheros nuevos o muy tocados de un porte, incluir lo que se usa (`absl/types/optional.h`, `platform/heap/visitor.h` si hay `visitor->Trace`, declaraciones adelantadas) y pedir a LOCAL un punto de compilación con `enable_precompiled_headers=false` antes de la Release.
- **(22-10) WPT de 1–2 niveles de color en la 7,1 = ANGLE OpenGL, no el motor:** la base 128 usa ANGLE OpenGL (como Mojave) y CfT 131 Metal (desde `-p11`, Metal de serie en ≥ 10.15; en 10.14 sigue OpenGL y esas 2 WPT siguen difiriendo); el raster por GPU con OpenGL redondea distinto (`hsla-clamp-negative-saturation`, `position-visibility-anchors-visible-change-anchor`). Para comparar con CfT, FlyWeb con `--use-angle=metal` (o `--disable-gpu-rasterization` en los dos); `wpt-ref.py --detalle` dice dónde difieren los píxeles.

## LOCAL

- **`update_patches` nunca para un solo parche, y las tareas largas en segundo plano** (Titín, 16-10). LOCAL-4 lanzó
  `npm run update_patches` dentro de su sesión para regenerar un parche; la sesión de Claude Code se reinició (la 7,1 no
  se durmió), el proceso murió a medias, dejó 81 parches tocados y LOCAL estuvo 1 h 40 min parado. Un parche suelto se
  regenera con `git diff` de ese fichero; toda tarea larga va con `nohup` y registro, para que sobreviva al reinicio.
- **Las pruebas de JIT y Wasm, en un origen http(s)**, nunca en about:blank. Y en la 7,1 hay una política gestionada
  antigua de la app de desarrollo (`DefaultJavaScriptJitSetting = 2`) que deja las webs sin JIT: el 15-10 dio una falsa
  alarma de «el 130 no tiene WebAssembly». Con jitless no hay Wasm (también en la 116).
- **(19-10) LuLu retiene cada binario nuevo** aunque esté en una ruta aprobada: LOCAL abre una pestaña antes de cada tanda.

- **(21-10) Un cuelgue «de GPU» era LuLu:** la 128 se colgaba al arrancar (el navegador esperando un Flush al GPU). La hipótesis
  «alta, [V] en el código» del estudio en papel (CVDisplayLink del GPU) era falsa; lo resolvió una muestra (`sample`) de **todos**
  los hilos: el Chrome_IOThread estaba en `sendto` UDP del descubrimiento DIAL de Media Router, retenido por LuLu. En un cuelgue,
  **primero la muestra de todos los hilos de los dos procesos**, y luego hipótesis. Y con un binario nuevo, mirar antes LuLu.

## PUBLICACIÓN

- **Con la 1.12.1 y la 1.12.2 en cola, el orden de firma importa:** la web de la segunda no se fusiona hasta que la
  primera esté en el appcast; si no, `VERSION` se adelanta y la web se salta una versión.
- **La web solo se publica sola si su PR (con `FlyWeb/web/VERSION`) está fusionado antes de la firma** (SV.6). En la
  1.11.1 no lo estaba: el HUMANO firmó a las 9:00 y la web siguió en la 1.11 hasta las 16:00. Desde el 13-10,
  PUBLICACIÓN no pasa órdenes de firma sin ese PR fusionado. Y el estado de una sesión puede ser viejo: para saber si
  algo está publicado, mirar el appcast, no la sesión.
- **PUBLICACIÓN (local) no llega por `send_message` a las sesiones de la nube** (CONTENIDOS-WEB, MOTOR…): deja los
  datos del DMG en el tablero y COORDINACIÓN se los pasa a CONTENIDOS-WEB. Las sesiones de la nube sí le llegan a ella.
- **(21-10) Base 128: la 128 se cortó el 23-07-2024.** Muchos commits de 129–131 chocan porque dependen de otros de
  agosto del mismo fichero; portar antes esos prerrequisitos (`insert.sh`) suele dejarlos limpios, mejor que adaptar a
  mano. Y **nunca `patch -F3` sin mirar el resultado**: en anchor colocó una entrada de mojom fuera del enum y un miembro
  en otra struct, y en el json5 subió a stable la flag de al lado (MOTOR-15).

## De fondo (para todos)

- **Antes de archivar una sesión, `list_triggers`:** los agentes se programan avisos (`send_later`) que la despertarían ya
  archivada, con todo su contexto (22-10: IDENTIDAD-1 tenía uno para las 16:05, borrado). **El contexto que da `get_session`
  a un agente puede no actualizarse:** IDENTIDAD-1 se creía al ~33 % y estaba al 70 %; lo fiable es lo que ve Titín en la app.

- **Una sesión abierta con `create_session` (o en la app) arranca con el último esfuerzo que eligió Titín**, no con el
  del texto de arranque: `create_session` no fija el esfuerzo. Comprobarlo con `get_session` y pedírselo a Titín si no cuadra
  (22-10: IDENTIDAD-1 salió en extra y COORDINACIÓN-12 en medio).

Resumidas en [`DIRECTIVAS.md`](DIRECTIVAS.md); aquí, el texto completo con su caso.

- **Nada de versiones 1.N.x para arreglar lo que ya se está probando** (Titín, 16-10): un arreglo sobre algo que va en la
  versión en curso entra en ella aunque la retrase; una 1.N.x duplica compilaciones y tiempos. La 1.14.1 se aceptó solo
  porque ya estaba compilada. Ejemplo: los arreglos de las pestañas fijadas compartidas esperan en la 1.15.
- **Un comentario de Titín es para debatir, no una orden** (16-10). Preguntó por qué había 1.14.1 y COORDINACIÓN-7 la
  canceló y luego la recuperó sin debatirlo: dos rondas de mensajes a cuatro agentes para nada. Antes de mover a nadie,
  se le dan las opciones con su coste y una recomendación, y se espera su decisión. **Nunca se para una compilación ni
  una tarea en curso sin acordarlo:** puede tirar horas de trabajo. El reparto en varios agentes es para gastar menos
  tokens; cada orden y cada contraorden los gasta en todos. Titín: «prefiero que os quedéis parados durante horas a que
  una decisión gaste innecesariamente tokens».
- **Lo que Chrome cambia por Finch no está en el código** (15-10): MutationEvents y getInnerHTML se quitaron por
  configuración de campo; la referencia es lo que expone CfT N (`superficie.html`), no `runtime_enabled_features`.
- **(20-10) Finch otra vez:** `KeyboardFocusableScrollers` la apagó Google por servidor en Chrome 130/131 (rendimiento) y
  nosotros la encendimos al leer el código. Brave lo refleja en su json5: mirar el de la versión de Brave del nivel.
- **Comprobar antes de afirmar**: dos veces se dio por hecho algo sin mirar (el Vigía ya arreglado; un esfuerzo
  recomendado). Mirar la sesión o la rama.
- **(20-10) Las estimaciones de horas siguen saliendo muy pesimistas** (anchor: 18–28 h estimadas, ~4 h reales; migración
  recalibrada de 550 a ~230 h). Pedir medición antes de decidir y desconfiar de los rangos de papel.
- **Datos personales**: se subieron a una rama pública antes de preguntar por dónde iban; costó reescribir la rama y una
  petición a GitHub. Primera regla fija de `CLAUDE.md`.
- **(19-10) Datos de Titín:** el host DuckDNS de la oficina estaba en `main`; Titín eligió quitarlo solo del texto (#309).
  No repetir: hosts e IP solo por `send_message`.
- **Reescribir una rama (force push) necesita el sí explícito del HUMANO** aunque sea la tuya; el permiso de la sesión
  lo bloquea si la decisión llega por otro agente.
