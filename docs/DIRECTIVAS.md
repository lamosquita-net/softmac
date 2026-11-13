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
- **Nada de `chrome` entero en la Ubuntu** (Titín, 07-11): la build Mac completa (objetivo de la app, con Chromium y
  Blink de Mac y el enlace) ya cubre las roturas de Chromium por overrides; en la Ubuntu se mantiene «nunca compilar
  Blink». Si hace falta más cobertura allí, se amplía el P2 a los .cc de Chromium que incluyen una cabecera con override.
  Linger de la Ubuntu: quitado. Fuente: [`coordinacion.md`](../FlyWeb/docs/coordinacion.md) (07-11).
- **LuLu en las Mac de pruebas** (Titín, 06-11; ya lo había pedido antes): un binario nuevo de FlyWeb queda retenido
  por LuLu hasta que Titín lo permite. Un aviso de LuLu en pantalla **no significa que la máquina esté ocupada**. Si
  una build nueva no tiene red (webs que no cargan, Sparkle o sync sin respuesta), LOCAL lo dice a COORDINACIÓN con la
  ruta del binario, y COORDINACIÓN avisa a Titín para que lo permita en LuLu. Mientras tanto, se sigue con lo que no
  necesita red.
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
- **Un error se analiza y se arregla antes de seguir** (Titín, 28-10; criterio, no receta): en cuanto se detecta un
  error, se para lo que dependa de él, se busca por qué pasa y se arregla, porque todo lo que se haga encima queda anulado.
  Quien pueda arreglarlo antes lo arregla: si LOCAL puede, lo hace en su rama `local/*` y se lo pasa a MOTOR para que lo
  estandarice y no se repita en los niveles siguientes; si no, MOTOR lo arregla y se lo pasa a LOCAL. Cada problema pide su
  propia solución; lo que no cambia es el orden: detectar, analizar, arreglar, seguir. Lo que se pruebe primero tras compilar
  (webs reales como claude.ai, GitHub, YouTube o Wikipedia antes que las pruebas largas) lo decide LOCAL según el cambio.
  Caso: la 2.3.0 se cayó en webs reales y se siguió compilando y probando encima antes de analizarlo.
- **Nadie se queda parado** (Titín, 28-10): ante un bloqueo, cada agente sigue con lo que no dependa de él y decide el
  siguiente paso si ya tiene los datos; a COORDINACIÓN, el resultado. A Titín solo las decisiones.
- **La 5,1 se prueba cuando se puede; no bloquea una salida** (Titín, 29-10): las pruebas de peor caso (sin AVX) en la
  MacPro5,1 dependen de que Titín esté en el estudio; la versión sale con la 6,1 en verde. Si la 5,1 falla con alguna
  versión, se analiza entonces qué hacer. Caso: la 2.3.0 (nivel 134). Tras publicar una versión que Titín considere
  necesaria, la prueba en la 5,1 la pide él y es manual (actualizar con Sparkle y probar); la 5,1 no informa sola. Que
  falle una versión ya publicada en la 5,1 es aceptable: se traslada y se arregla. Riesgo acotado: en Mojave, las únicas
  Mac sin AVX son las Mac Pro 4,1/5,1 (las demás Mac con soporte oficial de Mojave tienen AVX).
- **LOCAL compila la siguiente mientras prueba en la 6,1** (Titín, 27-10): las pruebas van a la 6,1, así que la 7,1
  compila la versión siguiente en cuanto la anterior está compilada y guardada su app y su DMG. Sigue habiendo una sola
  compilación a la vez.
- **La d8 se compila en el Ubuntu de Titín, nunca en la nube** (Titín, 30-10): los portes de V8 se prueban con la d8 de
  Linux x64 y mjsunit que compila **D8-LINUX** en el PC de Titín (i9 de 13.ª gen, 32 hilos, Ubuntu 26.04; arranque dual,
  solo cuando está en Ubuntu). La nube escribe el código y no compila V8; si el Ubuntu está apagado, la compila LOCAL.
  Motivo: SEGURIDAD-PORTES-13 costó 96 $ (frente a 17 $ de la -12) por esperar horas a la d8 en la nube; en el Ubuntu,
  la 13.5 compila en 6 min 37 s (`ninja -j32`) y mjsunit tarda 17 s. Esa máquina solo compila y prueba: sin push, sin
  llaves y sin datos de Titín; instala paquetes solo con `sudo apt-instalar` (envoltorio de Titín, nunca `apt-get`).
  Se compara cada porte con la base de la misma máquina (13.5.212.10: mjsunit 7656/7657, solo falla
  `maglev/extras-cped`), no con las cifras de la 7,1 (7681/7682; las 25 de diferencia, sin explicar). Los mensajes de
  la nube no le llegan: los encargos se los pasa Titín y sus informes llegan reenviados.
- **Orden fijo de cada nivel (Titín, 02-11): d8 en el Ubuntu ANTES de entregar a LOCAL.** MOTOR y SEGURIDAD-PORTES
  suben sus ramas → D8-LINUX compila la d8 y pasa mjsunit (base y ramas de seguridad) → solo con la d8 en verde
  COORDINACIÓN manda la entrega a LOCAL por el buzón → LOCAL compila y prueba → PUBLICACIÓN → web. No se cambia sin Titín.
- **Flynk (Titín, 03-11):** internamente, nuestro motor deja de ser «Blink 128 parcheado» y se llama **Flynk N**, con N
  = nivel de Chrome (Flynk 138 = 2.7.0; a la par de Chrome, 140–156). Solo nombre interno y de la web: el código no se
  renombra, `about:credits` sigue citando Blink (licencias) y el agente de usuario y las Client Hints siguen siendo los
  de Chrome N sin marca propia (compatibilidad y huella; ver nota de COORDINACIÓN-24 del 03-11).
- **Evolucionar el fork en vez de parchear (Titín, 03-11):** tras publicar la 2.7.0, ARQUITECTURA estudia pasar de
  parches sobre la 128 a un árbol propio de Chromium en git. El estudio lee los informes de los otros motores y tiene
  en cuenta los portes futuros (Android, iOS, Linux y, como posibilidad, Leopard/PowerPC). «Apagar, no borrar» sigue.
- **Fork propio: SÍ (Titín, 03-11; `FlyWeb/docs/fork-propio.md`, #700), tras publicar la 2.7.0 y antes de entregar
  el 139 a LOCAL.** Aprobados los seis puntos de su §9: forks públicos `lamosquita-net/chromium` y `lamosquita-net/v8`;
  el árbol vive en el disco local de la 7,1 y en GitHub (excepción a «ficheros de trabajo en la red»); los parches de
  Brave 1.69 como primer commit; convierte LOCAL (F0, solo git); la base no sube con el fork. **Copia en Samba tras
  cada versión publicada**: espejo git *bare* en `/Volumes/googledrive/clientes/software/softmac/` (nombre a fijar en
  F0), actualizado con `git push --mirror` (solo sube lo nuevo) y con `gc.auto=0` para no reempaquetar y obligar a
  Drive a volver a subir los 65 GB. Sirve de copia en la nube y de origen rápido para el Ubuntu (D8-LINUX) en la red local.
- **Siguiente base (Titín, 03-11; `FlyWeb/docs/base-siguiente.md`, #703): medir antes de decidir.** Tras publicar la
  2.7.0: B0 (CVE: ¿aplican limpios a la 128? fechas reales), B1 (Chromium 156 y 150 limpios para 10.14, ¿arrancan en la
  6,1?) y B3 (ensayo de llevar la capa permanente a la 156, tras F0–F1 del fork), en paralelo con F0–F1. B2 mide la
  opción que salga de `brave-propio.md` (estudio de absorber lo útil de Brave en nuestro fork en vez de llevar
  brave-core 1.69 entero). **El 139 a mano queda en pausa** mientras se mide; SEGURIDAD-PORTES sigue con los CVE
  explotados (2.7.x si hace falta). Con los datos, Titín decide: 156, 150 o seguir a mano. Hasta entonces sigue vigente
  «la 128 es la última base». La interfaz irá hacia la de Chrome más que hacia la de Brave.
- **Puerta de la base: 156, con el OpenGL de Mac devuelto (Titín, 04-11; FM.55):** la siguiente base es Chromium
  **156** (156.0.8078.90), no la 150 ni seguir a mano en la 128. Motivo de Titín: avanzar a una posición actual; para
  futuras plataformas conviene ir en la última y no con parches («pan para hoy y hambre para mañana», comprobado con la
  116 y la 128). Como la 156 quitó en Mac el camino OpenGL (Ganesh/GL y ANGLE GL) y ANGLE Metal no sirve en nuestras GPU
  de Mojave (familia Mac1), FlyWeb **porta entero el OpenGL de Mac desde la 150** (LOCAL-17; B1c). Ese porte se mantiene
  como capa aparte e identificable (commits propios, revertibles, por subsistema) para medir su coste en cada rebase. Hito
  de B1c: en la 6,1 pinta, WebGL funciona y MotionMark queda al nivel de la 2.7.0. Anula la recomendación de 150 de
  COORDINACIÓN-26 y la puerta abierta del 03-11 («la 128 es la última base» deja de valer cuando B1c cumpla el hito).
- **Contraseñas en el salto a la 156: sync primero (Titín, 04-11; `brave-propio.md` §11.8.2):** perder datos al migrar es
  un mal menor, pero se evita si se puede. La puerta del llavero de la 156 (recuentos `v10`/`fw1` iguales, sin «Chromium
  Safe Storage», sin aviso nuevo del llavero, sin borrados con la clave `fw1` ausente) suma una prueba: **la 156 con un
  perfil vacío, contra nuestro sync (`sync.flyweb.lamosquita.net`), recupera todas las contraseñas de la 2.7.0**. El sync
  es la vía preferida de rescate; **la importación (CSV en claro) solo como último recurso**, y el CSV se borra después. AES-256-GCM
  (`fw1`) no cambia de formato. El eslabón débil es dónde vive la clave: el llavero antiguo de Mojave queda protegido
  por la contraseña de sesión. Recomendación a usuarios y en la web: **FileVault activado y contraseña de sesión larga**;
  no dar «Permitir siempre» del llavero a programas ajenos.
- **Vía Metal en Mojave, en estudio (Titín, 04-11; FM.55):** la 6,1 llega a Monterey y allí su GPU usa Metal. En Mojave
  lo impide el Metal 2.1 (la 156 usa APIs de macOS 10.15/11), no el hardware. INVESTIGACIÓN-MOTOR estudia en papel si el
  ANGLE Metal de la 156 se puede adaptar a Metal 2.1, para compararlo con el porte de OpenGL de la 150 (B1c, que
  sigue). Decide Titín con los dos datos.
- **Brave: fuera todo lo que descartamos; destino, nuestro fork (Titín, 05-11; `brave-propio.md`):** lo de Brave que FlyWeb
  descarta se **borra sin paliativos**. FlyWeb es nuestro fork optimizado: de Brave se quedan solo las **mejoras de
  privacidad** (Shields, sync propio, políticas y lo que las sostiene) y, como mucho, **la capa de interfaz**, para
  modificarla después según las especificaciones de Titín. «Apagar, no borrar» valía solo para lo que pueda hacer falta
  en migraciones a otros sistemas, nunca para la basura de Brave. Destino = opción B de `brave-propio.md` (lo útil,
  absorbido en el fork; `brave-core` desaparece); camino = poda primero y después absorción por pasos medibles (C). La
  pregunta «A, B o C» de §8 queda cerrada. Donante del porte: Brave 1.98.63.
- **Widevine se queda desactivado; Tor fuera (Titín, 05-11; `brave-propio.md` §8.4–8.5):** Widevine (Netflix, Spotify
  web…) se conserva **desactivado por defecto**, como en Brave; el usuario lo activa y se descarga de Google. LOCAL
  comprueba en la 6,1 si llega a reproducir sin la firma VMP; si no funciona, se quita. Las **ventanas Tor se borran**
  con la poda (cliente Tor, componente y UI); si algún día se quieren para Mojave, como función propia.
- **Después de la 3.0.0: nuestro fork a nuestro ritmo (Titín, 05-11 noche; precisa B8 de `base-siguiente.md`):** no se
  sigue a Chrome versión a versión. Se va **a la par en funciones y en seguridad portando** lo que hagan Chrome y los
  demás navegadores, sobre nuestra base y con nuestro calendario. Foco: **exprimir rendimiento** (PGO, GPU, hilos y
  varias GPU, Maglev, OpenGL de comparación). Cuando haya desahogo, **plan de expansión a otras plataformas, de la más
  fácil a la más difícil** (Linux, Android, iOS, Leopard/PowerPC…). Se acaba el ritmo actual. Salvaguarda propuesta por
  COORDINACIÓN: medir cada mes cuántos arreglos de seguridad entran limpios; si la proporción cae mucho (como pasó con la
  128), se le propone a Titín un salto de base con datos, no por calendario.
- **Maglev, a prueba en la validación de la 3.0.0 (Titín, 05-11 noche; B6 de `base-siguiente.md`):** en la 2.x está
  apagado (FS.28, 27-10) por los arreglos de seguridad de Maglev que había que portar a mano; la V8 de la 156 ya los trae.
  En B6 se enciende y se queda encendido solo si: (1) mjsunit de la V8 de la 156 con Maglev en verde en d8 (D8-LINUX);
  (2) Speedometer 3.1 y JetStream 3 con y sin Maglev en la 6,1 y la 5,1, sin pérdida; (3) sin instrucciones AVX sin
  despacho en la 5,1 (`otool`). Si falla algo, se publica apagado y se mira en optimizaciones.
- **GPU: Metal (B1d); la vía OpenGL (B1c) queda parada hasta después de la 3.0.0 (Titín, 05-11 noche):** no se hacen más
  commits ni compilaciones de la opción GL; el cuello de botella es compilar. Motivos: MotionMark 1381 frente a 566,
  batería sin caídas con `oficial-6`, y en seguridad la vía GL obligaba a portar a mano 34 CVE (16 críticos) que la
  vía Metal ya trae. Lo que queda peor con Metal (parón en la primera carga, crear programas ~20× más lento) se trata
  como optimización. `flynk-b1b`/B1c se conserva sin borrar; si la 5,1 fallara con Metal, se reabre. **Anula** el punto 3
  de la orden a LOCAL 9b0fc7a (comparación Metal/GL): basta la tabla de `pruebas-gpu.md`.
- **Versiones desde la 3.0.0 (Titín, 07-11; sustituye a la regla 18 y a «1.N = nivel» para la 3.x):** el **segundo dígito**
  (3.1, 3.2…) son nuestros avances: el primero, rendimiento (PGO, GPU, hilos y varias GPU, Maglev, OpenGL de comparación;
  directiva del 05-11 noche), con claude.ai como criterio de aceptación de cada uno. El **tercer dígito** (3.0.1, 3.0.2…)
  son tandas de seguridad al ritmo de Chrome estable (una cada 2–4 semanas; críticos y KEV en cuanto salgan) más los arreglos
  de fallos y lo que quedó sin portar. Cada mes se mide cuántos arreglos de seguridad entran limpios. El estudio del plan de
  avances lo hace ARQUITECTURA con datos de SEGURIDAD-PORTES y MOTOR; decide Titín. FLYWEB_BUILD_NUMBER sigue subiendo en
  cada versión (CFBundleVersion 198.63.N; si se deja de partir de Brave, debe seguir creciendo o Sparkle no la ofrecerá).
  La 3.0.0 se publicó sin esperar a la 5,1 (Titín, 07-11): si falla allí, 3.0.1 o vuelta manual a la 2.7.0 con la copia «antes de 3.0».
- **Plan de la 3.x aprobado (Titín, 09-11; detalle en `FlyWeb/docs/plan-3x.md`):** la línea 3.0.x de seguridad, siempre
  en marcha → **3.1, GPU e hilos (FM.56), adelante ya** → 3.2, sync con cuenta (F7.7), con su diseño en paralelo a la 3.1.
  - **La 3.0.1 va en paralelo con la 3.1**, con los parches ya preparados, sin competir por la 7,1: la compilación de la 3.0.1
    va primero, y el perfilado de la 3.1 puede ir en la 6,1.
  - **Seguridad continua con SEGURIDAD-PORTES, siempre en marcha:** tandas cada 2–4 semanas, KEV y críticos al momento,
    y la medida mensual de cuántos arreglos entran limpios.
  - **Novedades de los motores (Chrome 157+, Blink, V8):** INVESTIGACIÓN-MOTOR vigila y propone, con un informe periódico
    de qué trae cada Chrome, qué se puede portar a la 156 y qué interesa. MOTOR implementa solo lo que Titín apruebe, dentro
    de una 3.x, para no distraerse de la 3.1.
  - **Primer hito de la 3.1:** perfil del hilo del proceso de GPU en la 6,1 y la 7,1 (LOCAL) y lectura de ANGLE Metal (MOTOR).
  - **Decisiones de `plan-3x.md` §7 y de `novedades-motor.md` (Titín, 09-11, todas sí):**
    1. El criterio de la 3.1 en la 7,1 (hueco con Chrome) se fija con el hito 0, con el mismo guion para los dos navegadores.
    2. Puerta de los hilos: hilo del proceso de GPU ≥ 90 % y driver > 25 %.
    3. Base nueva: umbrales S1 50/35 % y S2 5/10 críticos (§6.3); se revisan con la medida de diciembre.
    4. `flyweb_bundle_version_base = "198.63"`: entra en la 3.0.2 (la 3.0.1 ya compilaba).
    5. Sparkle 2: se valora durante la 3.1 y se migra en la 3.3.
    6. Containers no; WebGPU apagado y fuera de la 3.x.
    7. Vigilancia diaria de KEV entre tandas (rutina de SEGURIDAD-VIGÍA en Haiku, pasada diaria).
    8. **Versión declarada:** FlyWeb sigue declarando 156 en toda la 3.x. Una función de un Chrome posterior se enciende
       solo si una web real la necesita (claude.ai, el primero), nunca por paridad.
    9. 3.0.2: apagar XSLT (antes, SEGURIDAD cuenta los CVE de libxslt), CORS en Background Fetch y bloqueo del foco sin
       interacción del usuario; LOCAL comprueba si la 3.0.x expone WebHID, Web Install y Direct Sockets, y si sí, se apagan.
- **Contenido cerrado antes de compilar (Titín, 09-11):** antes de cada orden de compilar una versión, COORDINACIÓN cierra
  la lista de contenido. Cada decisión pendiente que la toque se pregunta antes o se pasa por escrito a la versión siguiente.
  Nunca se compila con una pregunta abierta sobre lo que va dentro.
- **Contenido de la 3.1 (Titín, 10-11, «apruebo todo»; COORDINACIÓN-38):** sobre la 3.0.1 (brave-core `local/3.0.1`
  77ae53e5f6, chromium `seg/3.0.2` 502e3c5b85): (1) ANGLE Metal `FlyWeb/parches/3.1-angle/` 0001–0004 (t4: Aquarium 10k a
  60 fps, 15k +3–10 %, texturas 69/69); (2) NTP privada de FlyWeb, 0004 + 0005 de `3.0.2-sync-ajustes`; (3) favicons con la
  mosca, `3.1-favicons` (#926); (4) Escudos, `3.1-cosmetic-style` (#921), si la build de medida de LOCAL-19 confirma la
  mejora en MotionMark y pasa la prueba funcional de bloqueo; si no, a la 3.2; (5) **Maglev encendido** (Titín, 10-11 noche: con
  7,1 +8,2 %, 6,1 +6,8/+6,6 %, AVX sin despacho 0 en Maglev y mjsunit en verde, la 5,1 no bloquea; su medida va
  después de publicar, con la versión instalada y el perfil de quien la use, y si pierde se estudia para la 3.2). Las dos condiciones son medidas, no preguntas: se comprueban
  antes de la orden de compilar. **Fuera, a la 3.2:** el diseño de Titín de la pantalla privada (parte de la de la 3.1) y
  los cambios ligeros de las pestañas (colores, esquinas, separadores, pestaña activa; no la forma ni el alto).
- **Seguridad tras la 3.1.0 (Titín, 12-11; COORDINACIÓN-39):** no hay 3.0.2. La línea 3.0.x se cierra y las tandas de
  seguridad siguen en el tercer dígito de la versión publicada: la de Chrome 158 (estable 17-11) es la **3.1.1**, sin
  esperar a la 3.2.0 (si coinciden, se juntan). Lo previsto para la «3.0.2» que no entró en la 3.0.1 (p. ej.
  `flyweb_bundle_version_base`) pasa a la 3.1.1. Se sigue declarando 156 (decisión 8 del plan de la 3.x). **Prueba de huella en la 3.1.1** (Titín, 12-11): con los
  parches puestos, JA4, HTTP/2, orden de cabeceras y Client Hints tienen que cuadrar con un Chrome 156 real (`motor.md`).
  **Cambio (Titín, 13-11; COORDINACIÓN-40): la 3.1.1 sale ya, sin la 158**: seguridad 0001–0034 (V8 .58, Skia, M156/M157),
  arreglo de Catalina (`FlyWeb/parches/3.1.1-catalina/`) y lo heredado de la «3.0.2». El delta de la 158 se prepara el
  17-11 y Titín decide entonces si va en una 3.1.2 solo de seguridad o en la 3.2.0. Sync de la 3.2: **H1 aprobado** (13-11).
- **Sync con cuenta de la 3.2 (Titín, 12-11; COORDINACIÓN-39):** diseño en `FlyWeb/docs/sync-cuenta.md` (#905). Añadir
  un Mac con el **modelo de Firefox Accounts** (clave envuelta con una clave que sale de la contraseña; el servidor no ve
  contraseña ni semilla): email + contraseña + código por email, **sin aprobación desde otro Mac**.
  Riesgo aceptado: con la base de datos robada, las contraseñas débiles se pueden atacar fuera de línea. Las 24 palabras
  siguen siendo la recuperación. Sin tope diario de códigos: aviso por
  email de cada operación (y ritmo contra la fuerza bruta). Demora de borrado: 14 días. Mac
  identificado por modelo y nombre que elige el usuario. Página «Cuenta y sincronización»; correos desde `noreply@`.
  RGPD: correo 7 días, `sync.db` 30 días, copia en bak cifrada 30 días; registro de actividades, contrato con OVH y
  brechas: propuesta nuestra con marcadores, sin datos personales en el repo.
  - **Simplificación (Titín, 12-11 noche; COORDINACIÓN-40): sencillo para el usuario y para el desarrollo, sin diseñar
    para casos extremos.** (A) **No hay bloqueo de cuenta.** (B) **Contraseña de cuenta obligatoria; no hay «código
    visible».** Cambiar la contraseña, o ponerla nueva si se olvidó («He olvidado la contraseña»): desde cualquier Mac que
    ya sincroniza, con un código por email. Mac nuevo: email + contraseña + código por email; si se olvidó, primero se
    cambia en un Mac que ya sincroniza. Sin ningún Mac y sin contraseña: las 24 palabras. (C) Un solo plazo de 14 días.
    (D) La copia de bak se borra de verdad a los 30 días (excepción a la cuarentena). (E) **No** se añade espera de 3 días
    para el Mac robado con el correo abierto. **Riesgo aceptado:** quien tenga un Mac desbloqueado y el correo del usuario
    tiene su cuenta; un Mac apagado o bloqueado lo protege la contraseña de macOS.
- **Contenido de la 3.2.0 cerrado (Titín, 13-11; COORDINACIÓN-41):** (1) sync con cuenta: servidor (H2, #977, tras la
  revisión de SEGURIDAD-PORTES) y cliente (H3), que se encarga ya a MOTOR para escribirlo en paralelo; se compila
  cuando la 3.1 esté medida (`plan-3x.md` §5.2); (2) diseño de Titín de la pantalla privada y cambios ligeros de las
  pestañas (`entregas/local21/diseno-32/`); (3) parches `FlyWeb/parches/3.2-renderer-webgl/` 0001–0003. Nada más entra
  sin pasar por Titín. El delta de la 158 y la V8 .59 no son contenido de la 3.2.0 salvo que Titín lo decida el 17-11
  (recomendación de COORDINACIÓN: 3.1.2 solo de seguridad).
- **3.1.2 antes de la 3.2.0 (Titín, 13-11 noche; COORDINACIÓN-41):** la 3.2.0 está lejos (sync sin revisar ni compilar),
  así que sale antes una **3.1.2 de seguridad**: V8 .59, delta de la 158 (estable el 17-11) y KEV; nada que no sea
  seguridad salvo un arreglo pequeño y ya diagnosticado (p. ej. la caída de «Continuar con Google» o el respaldo GL de
  ANGLE en los Mac de 2012, si ARQUITECTURA lo da por seguro). Contenido cerrado antes de compilar. Los fallos se
  arreglan en paralelo y **no paran** la 3.2.0. Se adelanta la revisión de SEGURIDAD de la sync (#977, #981) para no
  esperar al 17-11. INVESTIGACIÓN-MOTOR vigila además Gecko, WebKit y los estándares (WHATWG HTML, CSSWG, TC39,
  Interop) para detectar tendencias que convenga traer.
- **FlyWeb también innova (Titín, 13-11 noche; COORDINACIÓN-41; amplía «Flink a nuestro ritmo»):** además de seguir a
  Chrome, FlyWeb puede implementar funciones nuevas de los estándares (HTML, CSS, JS, APIs) aunque ningún otro navegador
  las tenga aún. **Las elige Titín como diseñador web.** INVESTIGACIÓN-MOTOR le presenta las tendencias nuevas, con
  ejemplo, estado de la especificación, riesgo y coste, para que marque sí o no; MOTOR implementa lo aprobado. Lo de los
  navegadores para macOS viejos deja de vigilarse. Riesgo aceptado: una función que se implemente antes de tiempo puede
  cambiar en la especificación; se prefiere lo que tenga consenso o borrador estable, y se avisa cuando no.
- **Plataformas (Titín, 13-11 noche; COORDINACIÓN-41):** después de la 3.2 y **sin coste nuevo** (nada de comprar
  RAM ni licencias por ahora). Orden: (0) automatizar la fábrica de Mac (compilar, probar, publicar sin pasos a mano);
  (1) **Ubuntu**, en la máquina de D8-LINUX (i9 de 13.ª, 32 GB: se compila con menos trabajos en paralelo);
  (2) **Android**, en la misma máquina, publicado en la cuenta de Google Play de Titín; (3) **iOS**, con motor propio en
  la UE (cuenta de Apple ya pagada); (4) **Windows**, al final (exige certificado de firma de pago). Los parches de
  seguridad son comunes; lo que se multiplica es compilar, probar y publicar. ARQUITECTURA hace antes el estudio en
  papel (coste en hitos, máquinas, firma y tiendas, automatización); el orden se revisa con sus datos.
- **Flink a nuestro ritmo (Titín, 12-11 noche; COORDINACIÓN-40):** Chrome marca hacia dónde va la web y lo seguimos,
  pero con criterio propio: se trae lo que interese y lo que necesiten webs reales, y no se mete lo que no aporta o
  rechazan Firefox y Safari (sigue la decisión 8 del plan de la 3.x: se declara 156). Objetivo: **no quedarse nunca atrás**.
  INVESTIGACIÓN-MOTOR vigila Chrome y, desde el informe 2 (17-11), también Firefox, Safari y otros navegadores que se
  mantienen con versiones viejas de macOS o del motor, para dar tiempo a traer lo útil de donde sea.
- **Multihilo y multiGPU (Titín, 11-11; COORDINACIÓN-39):** estudio de ARQUITECTURA en
  `FlyWeb/docs/multihilo-multigpu.md` (#941). Reparto de calor (toda la WebGL en la segunda D500) decidido: se entrega si
  no pierde más del 2 %. La compilación E1 y la medida M1 van **después de la 3.2** (la sync va primero). Apartado nuevo
  del estudio, tras cerrar la sync: JavaScript y CPU de muchos hilos (límites de hilos de Chromium/V8, estilo en paralelo).
  Batería de GPU: `pruebas-gpu.md` más Basemark Web 3.0 (#942).
- **Design Fly Suite (Craft, Titín, 09-11):** el fork de vectorcraft espera a que storytold llegue a beta
  (`docs/investigacion/craft-apps.md`). Mientras, el agente del proyecto hace el módulo de importación de FreeHand.
  La jaula `craft` de la 6,1 lleva, cuando se monte, pf por usuario, `Match User craft`, `sudo -k` y la comprobación de
  `/Volumes` y `/Users/Shared`. `craft-update` se quita antes de la primera ejecución fuera de la jaula. COORDINACIÓN
  fusiona sus PR.
- **La base 156 se publica como FlyWeb 3.0.0 (Titín, 05-11; `base-siguiente.md` §7):** es un salto de base, no un nivel.
  Excepción escrita a la regla 18: los niveles 139–155 no llevan versión propia; `flyweb_engine_level` = 156 y
  `flyweb_version` = 3.0.0. Después, 3.0.x para backports de seguridad y arreglos (B8).
- **La MacPro6,1 también trabaja para LOCAL (Titín, 05-11), con acceso por ssh desde la 7,1** (los datos de acceso, fuera
  del repo). Ojo: con Mojave y Xcode 11.3.1 **no puede compilar la 156** (pide Xcode 26 / SDK 26). Uso: banco de pruebas
  automático (batería de GPU, `motor-N.html`, WPT, llavero) lanzado desde la 7,1 mientras esta compila; compilar en ella
  solo si LOCAL mide que la ejecución remota de acciones de compilación compensa.
- **Plan ultra: sin límite semanal ni de agentes en paralelo (Titín, 05-11), a prueba** hasta que Titín vea cómo va.
  COORDINACIÓN reparte en paralelo todo lo que no dependa entre sí (p. ej. F1 con LOCAL mientras sigue el porte B2 con
  MOTOR) y deja de racionar vigilancias por consumo. Se sigue midiendo `cost_usd` (OR.2) para que Titín lo valore.
  **Sin overage y sin tope de agentes** (Titín, 05-11 noche; **06-11: revisión cerrada, se queda así y no se le vuelve a
  preguntar**: «olvídate del límite»). El límite de 5 horas es de **toda la
  cuenta** (el 05-11 a las 15:40 lo agotaron los 6 subagentes de MOTOR-32 y paró todo hasta las 17:30; un mensaje de Titín
  en ese hueco se perdió). Red de seguridad: el agente al que le salte el límite se programa con `send_later` un aviso
  para la hora de renovación (`resetsAt`) y sigue solo; COORDINACIÓN lo comprueba tras cada renovación.
- **Funciones de Brave fuera; el NTP, el nuestro (Titín, 05-11; `brave-propio.md` §12.6, T5/T9):** **Playlist,
  Speedreader, WebTorrent, Wayback, Commander y la Sidebar de Brave se borran** con la poda (en su lugar, el panel
  lateral y el modo lectura que ya trae Chromium). **La nueva pestaña es la de FlyWeb** (`components/flyweb_ntp`, el
  diseño y los elementos que ya salen en la 2.7.0) y se porta tal cual; el NTP de Brave (`ntp_background_images`,
  `brave_new_tab_ui` y widgets) se borra salvo lo que `flyweb_ntp` use de verdad. **Anula** la propuesta de COORDINACIÓN-27
  de pasar al NTP de Chromium. Desbloquea T5 y T9.
- **Hilos y varias GPU: línea de optimización de Flynk para el futuro (Titín, 05-11; FM.56):** con la B1d el límite de
  la 6,1 es un hilo de CPU del proceso de GPU, no la GPU. Optimizar ese hilo y repartir trabajo entre hilos y entre
  GPU (dos D500 en la 6,1; hasta cuatro en la 7,1 con Sequoia, memoria de texturas por GPU) queda apuntado como línea de
  Flynk. No entra en la base 156; se abre cuando la base esté publicada.
- **Poda de Brave: borrar, no apagar (Titín, 03-11; `brave-propio.md` §11, B2):** el código de Brave que FlyWeb ya no usa
  (Wallet, Rewards y demás apagados; 74 directorios medidos) se **borra** en vez de mantenerse apagado. «Apagar, no borrar»
  queda para lo que sirva a futuras plataformas (Android, iOS, Linux, Leopard/PowerPC), no para lo muerto de Brave.
  Cómo: en el fork propio, después de F1, un commit por directorio (revertible), y nada que siga en uso aunque esté apagado
  por ajuste. Si la puerta de la base decide seguir a mano en la 128, se revisa si compensa.
- **BackupDrive trabaja directamente con Titín, sin COORDINACIÓN (Titín, 03-11):** el agente BACKUPDRIVE recibe los
  encargos y resultados de Titín y le contesta a él; fusiona él mismo sus PR de `BackupDrive/` (y su fila del tablero)
  con la CI en verde, como excepción a la regla 8; y abre él mismo su relevo (si su linaje se agota, lo abre Titín desde
  la app). COORDINACIÓN no le escribe ni le fusiona nada; solo se cruzan si un cambio toca ficheros comunes (CLAUDE.md,
  reglas del tablero), que siguen por PR revisado por COORDINACIÓN. Sin coordinador propio: es un único agente.
- **`add_repo` de brave-core lo ordena COORDINACIÓN, no Titín (Titín, 02-11):** COORDINACIÓN lo pone en el texto de
  arranque de cada agente que lo necesita (excepción fija de la regla 16). Solo si aun así se deniega, se le dice a
  Titín con el texto exacto de la denegación.
- **Las faltas, antes de compilar** (Titín, 29-10; **fija desde el 30-10**, tras el 135: 11 min, 1–2 $ y 68 faltas encontradas): MOTOR cruza el inventario de cada nivel con lo que
  Chrome N pasa en WPT y Chrome N−1 no (wpt.fyi), y porta esas faltas y los escapes del nivel anterior antes de entregar.
  LOCAL se centra en errores de compilación y en los fallos que salgan después (caídas, webs reales). Se mide el coste en
  MOTOR frente a los escapes que ahorra. Caso: los 16 escapes WPT de la 2.3.0 (`wpt-230-investigacion.md`).
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
