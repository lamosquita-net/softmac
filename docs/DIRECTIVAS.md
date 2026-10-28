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
- **Solo se incorpora lo que aporta funcionalidad real** (Titín, 22-10): lo que sube el coste de desarrollo sin aportar algo
  interesante no entra (como Leo: hay extensiones para cada IA y es un agujero de privacidad). Caso abierto: el widget de
  búsqueda de la NTP de la 1.69 (apagado en la 2.0.0; estudiar si se enlaza a DuckDuckGo con icono propio o no se incorpora).
- **Apagar, no borrar, mientras fusionemos Brave** (HUMANO, 20-10): Leo y servicios parecidos se apagan (`enable_ai_chat:false`
  y comprobaciones tras cada fusión); se borran del código cuando tengamos el fork propio, porque borrar encarece cada
  fusión. Asistentes de IA, como extensión. Fuente: fila FM.31.
- **El diseño visual aprobado no se toca sin que Titín lo vea antes** (Titín, 26-10): NTP, fondos, iconos, colores y
  textos de la interfaz aprobados desde la 1.x no cambian, ni para «arreglar» algo, sin una captura y el sí de Titín. Caso:
  la sombra de las estadísticas de la NTP de la -p16 puso un halo blanco ilegible en los fondos FlyWeb (arreglo en la 2.0.1, -p18).

- **Lo visible, con el visto bueno de Titín antes de publicar** (Titín, 27-10): si una versión cambia algo que se ve
  (NTP, fondos, iconos, colores, textos, pestañas, animaciones como la mosca), LOCAL deja el DMG de prueba y capturas
  antes y después, y PUBLICACIÓN no publica hasta su sí. Sin cambios visibles, se publica sin preguntar (regla 11). Caso:
  la mosca animada de la NTP, que se veía en la 1.15 y no en la 2.0, desapareció sin que nadie se lo enseñara (FM.43).
- **Versión visible sin Brave ni Chromium** (Titín, 26-10): «Información de FlyWeb» y `flyweb://version` dicen
  «FlyWeb 2.0.x (motor N)»; Brave y Chromium, solo en `about:credits` (lo que piden MPL-2.0 y BSD). La base real
  (Chromium 128.0.6613.138) vive en la documentación del repo, porque el triaje de seguridad depende de ella. Fila FM.41.
- **Compatible con Mojave = funciona igual en Mojave, traducido; no basta con que no se caiga** (Titín, 27-10): todo lo
  que la 128 hace con APIs de 10.15+ («si es 10.15 haz esto») tiene en Mojave otro camino compatible con 10.14 (API de
  10.14 o el código de la 116), no un «no hay» silencioso. Es el trabajo de fondo del fork, antes de optimizar. Inventario
  y traducción en la fila FM.42 (2.0.3+). **Nada del chip T2 ni del Secure Enclave**: en todas las Mac, los caminos
  anteriores a 10.15 (claves por software, llavero clásico) para claves y verificación de usuario.
- **Cifrado por software, estándar, modular y con la CPU** (Titín, 27-10): algoritmos existentes (nada inventado),
  AES-256-GCM como objetivo, con la aceleración que tenga cada CPU sin exigir AVX; en un módulo cambiable para subir de
  algoritmo cuando haga falta, y el procedimiento documentado. Pensado para Mojave y otras plataformas, sin T2. Fila FS.25.
- **Seguridad fuera de Blink/V8, en línea propia** (Titín, 26-10): subir de base (129/130) no arregla los CVE de 2025–2026;
  se portan en el fork. SEGURIDAD-VIGÍA semanal; cada base nueva obliga a rehacer el triaje (CVE-2026-11645 «no aplicaba»
  a la 116 y sí a la 128). Fila FS.24.

- **Capa de compatibilidad propia para Mojave** (Titín, 27-10): las APIs de macOS 10.15+ que pida cada nivel se traducen
  a 10.14 en un solo módulo de FlyWeb (constantes, métodos y funciones que faltan, frameworks débiles; diseño en
  [`macos11-niveles.md`](../FlyWeb/docs/macos11-niveles.md) §9), no en parches sueltos por todo Chromium: aísla los
  problemas y abarata cada nivel. Lo nuevo entra ya en la capa; los 26 parches de Mojave actuales pasan a ella por tandas
  propias, empezando por lo que se repite. Fila FM.45.
- **Skia Graphite, fuera** (Titín, 27-10): mientras Chromium conserve el camino actual de dibujo (Ganesh; en Mac, ANGLE
  sobre OpenGL en Mojave y sobre Metal desde 10.15, como en la 7,1), Graphite queda apagado por parche propio desde el
  nivel 146. Traducirlo a Mojave sería >20 h con riesgo alto de regresión de GPU; se reabre solo si upstream borra ese
  camino. Fuente: `macos11-niveles.md` §8.4, `plan-fork.md`.

- **Saltos grandes por era de macOS, capa para lo intermedio** (Titín, 27-10): como el salto 116 → 128 (de Chromium Legacy
  127 a la 128, con su Brave), la base cambia de golpe al final de cada era de macOS, ahorrando los pasos intermedios; el
  siguiente gran salto, cuando lo abierto esté estable, será la era de macOS 11 (ya valorado en `plan-fork.md` y
  `macos11-niveles.md`). Entre saltos, los niveles avanzan rápido con la capa de compatibilidad. Por nivel no solo Blink y
  V8: también GPU, red y sandbox (FM.46), en una 2.1.x aparte y **solo si la huella sigue coincidiendo con la del Chrome
  declarado** (TLS/JA4, HTTP/2, QUIC, Client Hints, WebGL/canvas): los antibots nos detectan por ahí.

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
- **Sin versiones de seguridad que la siguiente vaya a sustituir** (Titín, 27-10): si un arreglo no explotado se queda obsoleto con
  el nivel que ya está listo para compilar, no se saca una 1.N.x/2.N.x para él; entra en ese nivel. Caso: la 2.0.4 (4 arreglos de V8 13.1)
  cancelada por la 2.1.0 (V8 13.2). Reserva: si el nivel se atasca días, se publica la rama de seguridad ya hecha.
- **Maglev, encendido como tarde en el nivel 134** (Titín, 27-10): apagado acumula deuda de seguridad (arreglos que hay que portar
  al encenderlo, ~15 hoy) y se aleja de lo que Google prueba (regla 19). Antes de encenderlo, la deuda portada (SEGURIDAD-PORTES)
  y pruebas de rendimiento con y sin él en la 5,1 y la 6,1; si empeora en la 5,1, vuelve a Titín con el dato. Fila FM.45.
- **Raíces de certificados al día, aparte de la versión declarada** (Titín, 27-10): los cortes de confianza del Root Store se
  aplican con una constante propia **fijada en 139.0.0.0** (Chunghwa, Netlock), no con la versión declarada; se sube a mano y
  revisando que la base entienda las restricciones nuevas. Una CA se desconfía por mala praxis, no por nivel. Fila FS.31.
  **Con el 133 (2.2.0) sube a 153.0.8010.0** (Titín, 28-10): aplica las retiradas de raíces antiguas del Root Store v43 que
  sirve el espejo (46 anclas; FS.33).
- **`Sec-Fetch-Storage-Access`, apagada** (Titín, 28-10; nivel 133): revela el estado de las cookies de terceros; manda la
  privacidad (regla 20) sobre la huella del Chrome declarado. Fila FM.49.
- **WebGL sin falsear** (Titín, 27-10): en Mojave la cadena del renderizador es la de OpenGL, distinta de la de Chrome 132 en Metal;
  no se iguala con `ANGLE_GL_RENDERER`. Fuente: `gpu-red-129-132.md` (FM.46).
- **Finch: lo que Chrome cambia por configuración de campo no está en el código** (15-10 y 20-10): la referencia es lo
  que expone el Chrome for Testing N y el json5 de la Brave del nivel, no `runtime_enabled_features`
  (MutationEvents, `KeyboardFocusableScrollers`). Fuente: [`coordinacion.md`](../FlyWeb/docs/coordinacion.md), «Trampas».
- **Prioridad actual: llegar a la base 128, a fondo** (HUMANO, 20-10; 21-10): la 1.15.2 publicada cierra la 116; la 1.15.3
  se cancela (view transitions vienen en la 128) y no se abre el 132 sobre la 116. En la 1.15.x solo seguridad urgente. Fuentes: fila FM.31, [`migracion-128.md`](../FlyWeb/docs/migracion-128.md).

- **Servidor a la par del motor** (Titín, 28-10): el espejo de componentes de ns2 (`components.flyweb.lamosquita.net`:
  CT, Root Store, Safe Browsing, Shields y demás) sirve los datos del nivel del motor que llevamos, igual que V8 y Blink, no
  los de la base 128. Si el navegador pide o recibe algo «de 128», se sube el servidor (y, si hace falta, el lector del
  navegador), nunca se rebaja. Caso: CT apagado desde la 2.0.0 por un `ct_config` que la 128 no entendía (FS.30).

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
- **Reescribir una rama (force push) necesita el sí explícito del HUMANO**, aunque la rama sea tuya. **Excepción (Titín,
  27-10):** en las ramas `nube/*` propias se permite mientras nadie parta de ellas (ni rama encima ni orden de compilación
  con ese sha). Fuente: [`TRAMPAS.md`](TRAMPAS.md), «De fondo».
- **No buscar otro canal si la plataforma bloquea uno** (20-10): p. ej. `elevated_session_untrusted_device`; lo decide
  Titín. Fuente: [`coordinacion.md`](../FlyWeb/docs/coordinacion.md), «Agentes y cómo hablarles».

## Organización
- **Primera versión funcional; lo menor se afina después** (Titín, 28-10): un arreglo menor (fuera del objetivo
  garantizado o de poco alcance, como la Futura en Sequoia) entra en una versión con lo que funcione en la primera
  compilación, sin vueltas extra de MOTOR ↔ LOCAL; si queda a medias sin regresión, se publica y se termina en la versión
  siguiente. Solo bloquean una regresión o un fallo de seguridad. Caso: la 2.1.1 (FM.47).
- **Versión intermedia (2.N.x) solo si compensa** (Titín, 28-10, tras la 2.1.1): se abre únicamente si arregla una
  **regresión** o un **fallo de seguridad explotado** (KEV, «in the wild») **y** el nivel siguiente está a **más de ~3 días**
  de publicarse. Todo lo demás (escapes, arreglos menores, parches sin explotar) entra en el nivel siguiente. Antes de
  abrirla, COORDINACIÓN anota en la fila el motivo y la cuenta (días hasta el nivel, coste previsto). La 7,1 compila
  primero el último nivel entregado por MOTOR; mediciones y guiones (Maglev, etc.) van después. En cada despertar,
  COORDINACIÓN comprueba que haya compilación en marcha si hay un nivel entregado sin compilar. Caso: la 2.1.1 (~20–25 $
  de nube, 4+ compilaciones) mientras la 2.2.0, entregada a las 10:16, seguía sin compilar a las 16:40.
- **Revisión de gastos** (Titín, 28-10): COORDINACIÓN revisa `CONSUMO.md` y `get_session` de las sesiones vivas **en cada
  relevo y una vez al día**; si un tipo de agente gasta más de lo que su tarea pide (sesión larga para trabajo con receta,
  Opus donde Sonnet basta, esfuerzo alto sin fallos que lo justifiquen), propone a Titín bajarlo (modelo, esfuerzo o
  relevo antes) con la cifra; la decisión es suya. El resultado, una línea en la nota de relevo.
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
- **MOTOR se archiva al entregar** (Titín, 28-10; sustituye a «MOTOR vivo hasta publicar» del 27-10): la sesión de MOTOR
  que entrega una versión deja su nota de relevo y se archiva. Los errores de LOCAL y los `seg/*` de SEGURIDAD los atiende
  la MOTOR siguiente, que COORDINACIÓN abre solo cuando hay algo que hacer (errores o el nivel siguiente). Motivo: una sesión
  parada con 40–50 % de contexto cuesta varios dólares cada vez que la despiertan; el 28-10, MOTOR-26 y MOTOR-28 sumaban
  46 $ esperando. **No apagarla no es pararla** sigue valiendo para la sesión activa: avanza el nivel siguiente mientras
  LOCAL compila, hasta el máximo de dos niveles. Lo mismo para cualquier agente de la nube que espera una decisión de Titín
  con mucho contexto (p. ej. BACKUPDRIVE): nota de relevo y se archiva; se abre otra cuando haya respuesta.
- **LOCAL compila la siguiente mientras prueba en la 6,1** (Titín, 27-10): las pruebas van a la 6,1, así que la 7,1
  compila la versión siguiente en cuanto la anterior está compilada y guardada su app y su DMG. Sigue habiendo una sola
  compilación a la vez.
- **MOTOR, hasta dos niveles por delante de lo compilado** (Titín, 07-10, 27-10 y 28-10): es el máximo, no una espera; MOTOR
  avanza sin pararse hasta llegar a él. INVESTIGACIÓN va por delante de MOTOR, hasta
  el 141 y después del 142 al 156: recetas por nivel, con la traducción a Mojave de lo que cada Chrome exige de macOS
  (10.15, 11, desde el 139 macOS 12…). Es la gracia del fork: Blink, V8 y el resto avanzan asumiendo esas APIs con
  caminos de 10.14, como se hizo con el cifrado y la GPU. Filas FM.44 y FM.45.
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
