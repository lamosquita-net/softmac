# Directivas de fondo

Lo que no cambia de una tarea a otra. Cada directiva: 2–4 líneas, fecha y enlace al documento largo, que manda si hay
duda. Cambiar una directiva es decisión del HUMANO (Titín) y se anota aquí con fecha. Lo diario está en
[`TAREAS.md`](TAREAS.md); el historial, en [`TAREAS-archivo.md`](TAREAS-archivo.md).

## Idea rectora (HUMANO, 20-10-2026)

**La 128 es la última base que tomamos de fuera.** Desde ella FlyWeb es un fork que evoluciona por su cuenta, por
niveles (Blink, V8 y el resto de componentes: 129, 130… hasta donde haga falta), portando de Chrome lo necesario con
nuestras normas y optimizando para nuestro hardware, como se hizo de la 116 a la 131. El salto 116 → 128 sirve para
aprender ese método; tras la 2.0.0 se planifica la evolución del fork, con su coste fuera de Blink y V8 (red, GPU,
sandbox, seguridad). Fuente: fila OR.1 de `TAREAS.md`; plan en [`migracion-128.md`](../FlyWeb/docs/migracion-128.md).

## Producto y plataforma

- **Mínimo garantizado: macOS 10.14 Mojave, Intel x86_64; nada que exija AVX** (la MacPro5,1 no lo tiene). Monterey
  «debería» funcionar, sin garantía. La 2.0.0 (base 128) también exige Mojave (HUMANO, 20-10: se deja High Sierra);
  en su appcast, `sparkle:minimumSystemVersion` 10.14.0. Fuentes: [`CLAUDE.md`](../CLAUDE.md), fila FM.31.
- **La 2.0.0 no sale sin GPU en Mojave** (HUMANO, 21-10): aceleración igual que la 1.15 (canvas, composición, WebGL, WebGL2, vídeo) y sin caídas del proceso GPU, traduciendo a las APIs de Mojave lo que la 128 usa de 10.15 (Dawn incluido). WebGPU sigue apagado (CVE-2026-5281) hasta el nivel que traiga su arreglo. Fuente: fila FM.31.
- **Criterio de aceptación: claude.ai funciona por completo** en FlyWeb (vía elegida para usar Claude en Mojave; un
  cliente propio con cuentas Pro/Max lo impiden los términos de Anthropic). Fuente: [`CLAUDE.md`](../CLAUDE.md).
- **Identidad fija** (empresa `lamosquita`, producto FlyWeb, bundle id `net.lamosquita.flyweb[.canal]`, Team ID, perfil,
  llavero): no se cambia sin migración. Marca Brave fuera; MPL-2.0 y `about:credits` se cumplen. Cada software del
  monorepo, con la licencia de su origen. Fuentes: [`CLAUDE.md`](../CLAUDE.md), [`rebranding.md`](../FlyWeb/docs/rebranding.md).
- **Privacidad por encima de Brave** (regla 20, 17-10): la referencia es Brave del mismo nivel de Chrome (131 = Brave
  1.73), no Chrome; lo que Brave apaga no se porta, y MOTOR propone apagar lo que sirva para huella aunque Brave lo
  deje. Servicios propios (componentes, sync, actualizaciones, proxy de Safe Browsing); nada pasa por servidores de
  Brave. Fuentes: [`TAREAS.md`](TAREAS.md) regla 20, [`CLAUDE.md`](../CLAUDE.md).
- **Brave no se sigue por número** (HUMANO, 22-10): de Brave solo nos interesa la privacidad (por eso lo elegimos pese a
  duplicar esfuerzo). Tras la 1.69 (base 128) no se fusionan sus versiones para ir a la par; INVESTIGACIÓN-MOTOR estudia
  lo que publiquen de privacidad y solo se porta lo importante, con consenso. De la 1.57 a la 1.69 casi todo era ya
  resuelto por nosotros o servicios suyos que no queremos (Leo). Fuente: fila FM.37.
- **Niveles 132+ no empiezan hasta publicar la 2.0.0** (HUMANO, 22-10): nada en paralelo, por el gasto semanal.
- **Apagar, no borrar, mientras fusionemos Brave** (HUMANO, 20-10): Leo y servicios parecidos se apagan (`enable_ai_chat:false`
  y comprobaciones tras cada fusión); se borran del código cuando tengamos el fork propio, porque borrar encarece cada
  fusión. Asistentes de IA, como extensión. Fuente: fila FM.31.

## Motor

- **Niveles de Chrome, portando función a función** (HUMANO, 04-10): el motor crece desde la base portando lo Baseline
  (y subfunciones) que publicó cada Chrome N; el nivel se cumple con `motor-N.html` en verde, las WPT iguales a las del
  Chrome N y la huella de red coherente con él. Fuente: [`motor.md`](../FlyWeb/docs/motor.md) principios 2–13.
- **V8 y Blink, por niveles e independientes del número de la base** (HUMANO, 05-10): cada nivel N lleva la V8 de
  Chrome N (`FlyWeb/v8-revision`), sea cual sea la base; Blink no se cambia entero, se porta. Criterio de parada de V8:
  comparar con cifras el coste de adaptar Blink frente a dejar V8 estacionada. Fuentes: [`motor.md`](../FlyWeb/docs/motor.md)
  principio 11, [`base-128.md`](../FlyWeb/docs/base-128.md) §5.
- **Un nivel, una versión, con su V8** (regla 18, 14-10): cada nivel N sale entero en la 1.(N−116); solo un cambio muy
  amplio se reparte en 1.N.x. Las 1.N.x agrupan seguridad, escapes y funciones que faltaban; lo escapado se porta antes
  de abrir el nivel siguiente. Fuente: [`TAREAS.md`](TAREAS.md) regla 18.
- **Versión declarada = último nivel completo, igual para todas las webs** (HUMANO, 04-10): sin excepciones por sitio;
  si una web nos rechaza, es un dato. `platformVersion`: la mínima que admite el Chrome N (HUMANO, 12-10). Fuente:
  [`motor.md`](../FlyWeb/docs/motor.md) principios 4 y 13.
- **Lo apagado se enciende cuando upstream lo lleva de serie** (regla 19, 14-10): Maglev, ISel de Turboshaft, etc.;
  seguir en una ruta que Google ya no prueba sale más caro. SEGURIDAD-PORTES revisa la tabla en cada nivel. Fuente:
  [`TAREAS.md`](TAREAS.md) regla 19.
- **Finch: lo que Chrome cambia por configuración de campo no está en el código** (15-10 y 20-10): la referencia es lo
  que expone el Chrome for Testing N y el json5 de la Brave del nivel, no `runtime_enabled_features`
  (MutationEvents, `KeyboardFocusableScrollers`). Fuente: [`coordinacion.md`](../FlyWeb/docs/coordinacion.md), «Trampas».
- **Prioridad actual: llegar a la base 128, a fondo** (HUMANO, 20-10; 21-10): la 1.15.2 publicada cierra la 116; la 1.15.3
  se cancela (view transitions vienen en la 128) y no se abre el 132 sobre la 116. En la 1.15.x solo seguridad urgente. Fuentes: fila FM.31, [`migracion-128.md`](../FlyWeb/docs/migracion-128.md).

## Seguridad

- **Chromium de 2023, parches poco a poco** (riesgo asumido): SEGURIDAD-VIGÍA clasifica CVE, SEGURIDAD-PORTES porta.
  Fuentes: [`SEGURIDAD.md`](SEGURIDAD.md), [`cve-triage.md`](../FlyWeb/docs/cve-triage.md).
- **Revisión de seguridad de cada porte grande de motor** (regla 17, 13-10): fila FS con los arreglos de upstream
  posteriores que toquen ese código, antes del Static definitivo. Sin ella no se da la entrega por buena. Fuente:
  [`TAREAS.md`](TAREAS.md) regla 17.

## Datos y accesos

- **Datos personales del HUMANO, nunca en GitHub** (HUMANO, 09-10; por encima de todo): ni en ramas, commits, PR ni
  tablero; hosts e IP de la oficina tampoco. Van por `send_message` a quien los instala. Antes de moverlos, decirle por
  dónde pasan. Solo su nombre de pila, Titín, puede aparecer (14-10). Fuente: [`CLAUDE.md`](../CLAUDE.md).
- **Nunca en el repo: tokens, contraseñas, certificados** (regla 5). Fuente: [`TAREAS.md`](TAREAS.md).
- **ns1 y ns2, de uno en uno** (regla 10): fail2ban banea la IP de la oficina; PUBLICACIÓN y SERVIDOR-LOCAL nunca a la vez.
  Fuente: [`TAREAS.md`](TAREAS.md).
- **Reescribir una rama (force push) necesita el sí explícito del HUMANO**, aunque la rama sea tuya. Fuente:
  [`TRAMPAS.md`](TRAMPAS.md), «De fondo».
- **No buscar otro canal si la plataforma bloquea uno** (20-10): p. ej. `elevated_session_untrusted_device`; lo decide
  Titín. Fuente: [`coordinacion.md`](../FlyWeb/docs/coordinacion.md), «Agentes y cómo hablarles».

## Organización

- **Quién decide y quién ejecuta**: COORDINACIÓN revisa, fusiona y ordena (regla 8, 09-10) y sus órdenes valen como del
  HUMANO (regla 16, 12-10); al HUMANO solo le llegan producto, credenciales, firmas en bak, root en ns2 y pruebas en las
  Mac. El que tiene el acceso ejecuta (regla 14); la entrega de LOCAL es la orden de publicar (regla 11, 13-10).
  Fuente: [`TAREAS.md`](TAREAS.md) reglas 8, 11, 14 y 16.
- **Un comentario de Titín es para debatir, no una orden** (16-10): opciones con coste y recomendación, y esperar.
  Nunca se para una compilación ni una tarea en curso sin acordarlo. Titín: «prefiero que os quedéis parados durante
  horas a que una decisión gaste innecesariamente tokens». Fuente: [`coordinacion.md`](../FlyWeb/docs/coordinacion.md).
- **Nada de 1.N.x para arreglar lo que ya se está probando** (16-10): el arreglo entra en la versión en curso aunque la
  retrase. Fuente: [`coordinacion.md`](../FlyWeb/docs/coordinacion.md).
- **Una compilación a la vez en la 7,1** (HUMANO, 20-10): las de FlyWeb tienen prioridad. Tareas largas con `nohup` y
  registro; nunca `gclient sync -D` en `flyweb-build`; `update_patches` nunca para un solo parche (16-10). Fuentes:
  fila FM.31, [`CLAUDE.md`](../CLAUDE.md), [`coordinacion.md`](../FlyWeb/docs/coordinacion.md).
- **Subagentes para leer, relevo antes** (Titín, 22-10; a prueba en la próxima sesión que trabaje, se mide en CONSUMO.md):
  lo caro es releer el contexto en cada turno (IDENTIDAD-1: ~30 de 38 $). En MOTOR, IDENTIDAD y parecidos: subagentes para
  consultar la base de conocimiento, inventarios y triaje de errores o registros (devuelven conclusiones, no ficheros);
  el porte y las decisiones de código, en la sesión principal; relevo hacia el 35–40 %. Fuente: guía de costes de la API
  de Claude (subagentes para pasos autónomos con mucha lectura; no cuando quien decide necesita lo leído).
- **No se tiene una sesión abierta para esperar** (Titín, 22-10): una sesión con mucho contexto gasta solo con despertarse.
  Si el siguiente paso depende de una compilación, se archiva con la nota de relevo al día y el relevo se abre cuando llegue
  el resultado (excepción a la regla 13). Antes de archivar, `list_triggers`. Fuente: fila OR.2.
- **Esfuerzo de Opus 5.5** (HUMANO, 22-10): su defecto es medio y Anthropic recomienda empezar ahí; extra y máximo solo con
  mejora medida. MOTOR pasa de extra a alto desde MOTOR-18; IDENTIDAD-1 prueba medio; se decide el resto con CONSUMO.md.
  Fuente: guía de migración a Claude Opus 5.5 (Anthropic), fila OR.2.
- **Modelo por lo que cuesta un error, no por el volumen** (regla 9, 05/09-10); **medir el consumo con datos**
  (`cost_usd` y tokens de `get_session`, OR.2, 20-10): lo caro es el contexto largo releído, no el modelo. Fuentes:
  [`TAREAS.md`](TAREAS.md) regla 9 y fila OR.2.
- **Relevos a partir del 50 % de contexto, en punto limpio** (12-10): rama subida, fila al día, nota de relevo; no se
  archiva una sesión hasta que su relevo esté activo; el texto de arranque, en un mensaje propio con modelo y esfuerzo
  en la primera línea (regla 13, 14-10). Fuentes: [`TAREAS.md`](TAREAS.md) regla 13,
  [`coordinacion.md`](../FlyWeb/docs/coordinacion.md).
- **Medir antes de decidir; desconfiar de las horas de papel** (20-10): las estimaciones salen muy pesimistas (anchor:
  18–28 h estimadas, ~4 h reales). Comprobar antes de afirmar (sha con `git merge-base`, publicación en el appcast).
  Fuente: [`coordinacion.md`](../FlyWeb/docs/coordinacion.md).
