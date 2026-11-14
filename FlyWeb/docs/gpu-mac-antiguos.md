# La 3.x sin aceleración gráfica fuera de los Mac Pro: las puertas de ANGLE Metal

ARQUITECTURA, 13-11-2026. Encargo de COORDINACIÓN-41 (buzón `20261113-2115`), a partir del hallazgo de LOCAL-19 en el
MacBookPro9,1 con Catalina y la 3.1.1. **Solo papel: nada compilado, nada lanzado, nada medido.** Leído: el árbol
`~/proyectos/chromium-156/src` (rama `flynk-b1d` `33a1745949`, la base de la 3.0.0; ANGLE `e3917d6`), la rama `flynk-b1b`
(B1c), los parches de la 3.1.x del repositorio y el binario de la 3.1.1 instalada en la 7,1 (`strings` y `nm`).
**Ampliado el 13-11 por la noche** en dos veces: con las medidas de LOCAL-19 (buzón `20261113-2220`: conclusión 2 y 5,
§2.3 y §5.1) con la historia de la retirada que pidió Titín (buzón `20261113-2235`: conclusión 7 y 8, §6) y con los datos de
LOCAL-19 (buzón `20261113-2300`: §6.5, y dos correcciones mías en §6.1 y §6.4).
**Actualizado el 14-11** con el resultado de la compilación preliminar de LOCAL-19 (buzón `20261114-1140`): conclusión
10 y §7, que incluye la pregunta de SEGURIDAD sobre el cambio de GPU (§7.5). Las medidas son suyas; yo sigo sin
compilar ni lanzar nada. Lo escrito antes del 14-11 se deja como estaba: donde la medida lo supera, lo dice §7.
El mismo 14-11, segunda y tercera pasada: la prueba de reposo no valía y LOCAL-19 la repitió bien (§7.3).

Marcas: **[V]** leído en la fuente citada; **[I]** inferencia mía; **[S]** suposición sin comprobar.

## 1. Conclusión

1. **No es Catalina ni son solo los Mac de 2012.** ANGLE se niega a usar Metal, por identificador de modelo, en todo
   MacBook Pro anterior a 2016, MacBook Air y Mac mini anteriores a 2018, MacBook anterior a 2016 e iMac anterior al 5K de
   finales de 2015 [V]. De los Mac que admiten Mojave solo conservan la aceleración los Mac Pro, ese iMac y el iMac Pro.
   **Es casi todo el público natural de FlyWeb que no tiene un Mac Pro.**
2. **Viene de serie en Chromium 156 y está en todas las 3.x** [V: ningún parche nuestro cambia la lista de modelos]. En la 2.x esos
   Mac dibujaban con OpenGL. Es una regresión de la 3.0.0 que no se vio porque las pruebas se hicieron en los Mac Pro
   y porque en Catalina la 3.0.0–3.1.0 ni arrancaba. **Medido por LOCAL-19 el 13-11 en el MacBook Pro de 2012:**
   Aquarium con 1 000 peces da 5,9 fps en la 3.1.x y 59 fps en la 2.7.0 (buzón `20261113-2220`).
3. **De nuestras siete máquinas, las tres Mac Pro están bien y las cuatro de pruebas ocasionales caen** (§3.1).
4. **El OpenGL de ANGLE ya va compilado dentro de la 3.1.1** [V: en el binario]. Lo cierran dos puertas de Chromium y
   una pieza que la 156 quitó (las texturas rectangulares de IOSurface). La rama B1c lo devolvía con **unas 140 líneas en 15
   ficheros**, pero se paró a medias: en la 6,1 arrancaba en hardware y sin errores, con la pintura y WebGL **sin
   comprobar** [V: `docs/TAREAS.md`, FM.55].
5. **Recomiendo la opción A:** OpenGL automático solo donde ANGLE no admite Metal. No recomiendo relajar la lista de
   ANGLE (B). **Cabe en la 3.1.2 recortada a Mojave y Catalina y con una prueba previa de que pinta** (§5.1, añadido
   tras las medidas de LOCAL-19); los Mac con macOS 11 o posterior, en la 3.2.0.
6. **La cifra de «34 CVE que portar a mano» no vale para B1c tal como quedó** [I]: se contó para una capa copiada de la
   150 y B1c no copia nada de la 150. Hay que recontarla (SEGURIDAD) antes de que pese en esta decisión.
7. **Google lo quitó por limpieza, no por seguridad** [V: mensajes de los commits, §6]. Chrome dejó de soportar macOS 12 y, con
   él, el último hardware que necesitaba OpenGL; entre julio y septiembre de 2026 retiró la puerta, las
   texturas rectangulares y el aviso de cambio de GPU. Ningún mensaje cita un CVE ni un fallo de controlador.
8. **Respuesta corta a Titín: sí, y en la 3.1.2 si pinta.** No hace falta ningún argumento de GN. El coste real son seis
   hitos pequeños (§6.3).
9. **A sus dos preocupaciones** (§6.5): el OpenGL de la 156 en Mac **no lo ha probado nadie con ninguna tarjeta**, ni
   Google desde julio ni nosotros más allá de un arranque en la D500; por eso la prueba va antes que la decisión. En
   seguridad no abre nada que la 2.7.0 no tuviera abierto en esos mismos Mac.
10. **Resultado del 14-11: pinta, y Titín ha decidido que entra en la 3.1.2** (`docs/DIRECTIVAS.md`, #994). La
    preliminar (3.1.1 más los cinco parches de `3.1.2-gl-reserva`) no necesitó ninguna pieza más ni tocar el sandbox.
    En la 6,1 Metal sigue por defecto y no cambia. El MacBook Pro de 2012 elige OpenGL solo: WebGL vuelve, Aquarium va
    como la 2.7.0 o mejor y MotionMark no pierde frente al software (731 frente a 733). SEGURIDAD ha dado apto y ha
    cerrado sus pruebas (#985). **Mantengo el veredicto y no hace falta una 3.1.3.** La prueba de reposo no valía (el
    Mac había dormido 2 segundos); **repetida el mismo día con 5 y 9 minutos de reposo real, pasa con las dos GPU**
    (§7.3). Por mi parte no queda nada que bloquee. Siguen sin probar el monitor externo y el Air de 2013 (§7.4).
    Además, con la NVIDIA activa el canvas 2D va por software, por una entrada de la lista de Chromium, no por el
    parche.

## 2. Qué pasa exactamente

### 2.1 Las tres puertas de ANGLE [V]

| Puerta | Dónde | Qué exige |
|---|---|---|
| Modelo | `third_party/angle/src/common/apple_platform_utils.mm:38-70` | MacBookAir ≥ 8,1 · MacBookPro ≥ 13,1 · MacBook ≥ 9,1 · Macmini ≥ 8,1 · iMac ≥ 17,1 · iMacPro ≥ 1,1. Un nombre que no esté en la lista (MacPro) pasa |
| Familia de GPU | mismo fichero, `:98-124`, y `DisplayMtl.mm:145` (`requireGpuFamily2`, siempre encendida, `:1357`) | Que la GPU por defecto del sistema sea de la familia Mac2. En 10.14, `MTLFeatureSet_macOS_GPUFamily2_v1` (parche B1b) |
| NVIDIA | `DisplayMtl.mm:151` (`disableMetalOnNvidia`, siempre encendida, `:1349`) | Que la GPU no sea NVIDIA. Motivo que da ANGLE: «scarcity of the hardware» |

Las tres son de upstream. El motivo de la familia, según el comentario de ANGLE: las GPU de la familia 1 «such as
MacBookPro11,4» no están soportadas por el backend Metal (anglebug 40096869).

### 2.2 Por qué no hay alternativa [V]

- `ui/gl/init/gl_factory_mac.cc:26-31`: en Mac solo se admiten ANGLE Metal y SwiftShader. Por eso `--use-angle=gl` acaba
  en «not found in allowed implementations».
- `content/browser/gpu/gpu_data_manager_impl_private.cc:442`: el modo «GL por hardware» (Ganesh sobre ANGLE) solo existe
  antes de macOS 11 (`IsMacOSBelow11()` desde el parche `0004` de `3.1.1-catalina`). De macOS 11 en adelante solo hay
  Graphite.
- La 156 quitó el objetivo de textura rectangular para IOSurface, y el OpenGL de ANGLE solo enlaza una IOSurface como
  rectangular [V: TAREAS FM.55, LOCAL-16, «eglBindTexImage requires 2D»].
- El backend OpenGL de ANGLE, en cambio, **sigue dentro**: el binario de la 3.1.1 trae la ruta
  `renderer/gl/cgl/IOSurfaceSurfaceCGL.cpp`, importa `_CGLChoosePixelFormat` y anuncia
  `EGL_ANGLE_platform_angle_opengl`. No hay que añadir código de ANGLE.
- WebGL vuelve con `--enable-unsafe-swiftshader` porque Chromium ya no cae a SwiftShader para WebGL sin ese permiso.

### 2.3 Lo que no sé

- **En qué punto se queda el 9,1: resuelto leyendo el código** [V: `gl_display_initializer.cc:208-213`].
  Chromium solo prueba la pantalla de ANGLE OpenGL si OpenGL está en la lista de admitidos, y en Mac no lo está. Con Metal
  rechazado no queda ninguna pantalla que probar, el proceso de GPU no arranca y todo cae a software. Cuadra con lo
  medido. Consecuencia: **la misma línea** de `gl_factory_mac.cc` abre el indicador `--use-angle=gl` y el paso
  automático (Metal primero, OpenGL si Metal falla; `:76-79` y `:105-113`).
- **Cuál de las tres puertas corta en cada GPU.** El modelo corta siempre antes. **Medido por LOCAL-19 en el 9,1:** la
  HD 4000 y la GT 650M son las dos «GPUFamily1 v4», así que ahí cortan las tres. Siguen sin medir la HD 5000 y la
  R9 M370X.

## 3. Qué máquinas caen

### 3.1 Las nuestras (`CLAUDE.md`, «Máquinas»)

| Máquina | GPU · sistema | Modelo | Resultado en la 3.x |
|---|---|---|---|
| MacPro7,1 | 580X / W6600X · Sequoia | pasa | **Metal** [V] |
| MacPro6,1 | 2× FirePro D500 · Mojave | pasa | **Metal**: la sonda dice familia 2 [V: `metal-sonda/MacPro6,1-10.14.6.txt`] |
| MacPro5,1 | RX 580 · Mojave | pasa | **Metal**, familia 2 [V: `pruebas-gpu.md:139`] |
| MacBook Pro 15" 2012 (9,1) | GT 650M + HD 4000 · Catalina | **cae** (< 13,1) | Por software y sin WebGL [V: LOCAL-19]. Además, NVIDIA. Con el respaldo de la 3.1.2, OpenGL (§7) |
| Mac mini 2012 (6,x) | HD 4000 · Catalina | **cae** (< 8,1) | Igual [I: mismo código] |
| MacBook Air 2013 (6,x) | HD 5000 · Mojave | **cae** (< 8,1) | Igual, **y desde la 3.0.0** [I]: no depende de Catalina |
| MacBook Pro Retina 2015 (11,5) | R9 M370X + Iris Pro 5200 · Monterey | **cae** (< 13,1) | Sin WebGL por hardware; el resto, sin determinar [S]: en macOS 11+ compone Graphite, que no pasa por ANGLE |

El 11,5 era «el caso que debería funcionar» del objetivo.

### 3.2 Los Mac de 2012–2015 en general

Sale de la lista de ANGLE [V] cruzada con los años de cada identificador, que pongo de memoria [S] salvo los que ANGLE
anota en sus comentarios:

| Familia | Caen | Se salvan |
|---|---|---|
| MacBook Pro | 2012–2015 (9,x a 12,x) | desde 2016 (13,1) |
| MacBook Air | 2012–2017 (5,x a 7,x) | desde 2018 (8,1) |
| MacBook | 2015 (8,1) | desde 2016 (9,1) |
| Mac mini | 2012–2014 (6,x y 7,1) | desde 2018 (8,1) |
| iMac | 2012–2015 (13,x a 16,x), también el 5K de 2014 y el de 21,5" de 2015 | 27" 5K de finales de 2015 (17,1) y posteriores |
| Mac Pro | — | todos por modelo; después decide la tarjeta |

En la **5,1 de otros usuarios** decide la tarjeta: con una NVIDIA (GTX 680, Quadro K5000, corrientes en las 5,1 con
Mojave) cae por la tercera puerta [I]; con una AMD moderna es de esperar familia 2 [S].

## 4. Opciones

### A. OpenGL automático donde ANGLE no admite Metal

Terminar B1c y adaptarlo a la 3.x. El reparto no necesita lista propia: Chromium ya pide Metal primero y OpenGL después;
basta con dejar pasar lo segundo [V el orden; I que baste].

- **Qué se toca** (sobre el src de la 3.1.1):
  1. `gl_factory_mac.cc`: añadir ANGLE OpenGL a lo admitido, detrás de Metal (una línea de B1c, `9aab06cd1e`). **Sin** la
     otra mitad de ese commit, que dejaba Metal por defecto solo en macOS 11+ y contradice a B1d.
  2. Las texturas rectangulares de IOSurface: cuatro commits de B1c, 11 ficheros en `gpu/`, mojom y `viz`, todo añadido
     y nada revertido [V].
  3. El modo de GPU: hoy el modo GL por hardware no existe en macOS 11+. Para el 11,5 con Monterey hace falta que, si
     ANGLE cae en OpenGL, el compositor vaya también por Ganesh y no por Graphite. **Esto B1c no lo resolvía** (era solo
     para Mojave) y es diseño nuevo [I].
- **Encaje:** de los 15 ficheros de B1c, B1d cambió 3 y el parche `0004` de Catalina toca 2 de esos 3 [V]. No entra con
  `git am` tal cual: es un rebase a mano, pequeño. Los otros 12 están intactos en la base de la 3.0.0; contra el src de
  la 3.1.1 no lo he podido mirar.
- **Coste** [I]: uno o dos días de MOTOR, **una compilación oficial en la 7,1** (~3 h) y la batería de `pruebas-gpu.md`.
  El camino se prueba en la 6,1 con `--use-angle=gl`, sin depender de los Mac de 2012; el paso automático solo se puede
  probar en los cuatro Mac de Titín.
- **Qué gana:** aceleración y WebGL donde hoy hay software. La referencia es la 2.7.0, no Metal. En los Mac Pro no
  cambia nada.
- **Riesgos:**
  - B1c nunca llegó a comprobar que pinta. Puede quedar más trabajo del que se ve (vídeo por hardware, que también llega
    como IOSurface [S]).
  - El compositor en macOS 11+ con ANGLE en OpenGL (punto 3) no lo ha distribuido nadie [I].
  - Los drivers de OpenGL de Apple para esas GPU están congelados. La lista de apaños de Chromium conserva sus 14
    entradas de macOS, las mismas que en la 150 [V: solo el recuento].
- **Seguridad:**
  - El código común del OpenGL de ANGLE está al nivel de la 156 y upstream lo mantiene, porque es el de Linux, Android
    y ChromeOS. La capa de Mac (`renderer/gl/cgl/`, 12 ficheros) ya no la ejercita Chrome: la probaríamos solo
    nosotros [I].
  - Deja de ser código muerto: las tandas tendrían que tratar los arreglos del OpenGL de ANGLE como aplicables. Hoy
    supongo que se descartan en Mac [S].
  - Los 11 ficheros de texturas son código nuestro: regla 17.
  - **Los 34 CVE:** `gl-150-156-seg.md` los contó sobre «una capa copiada tal cual de la 150» (backend GL de ANGLE,
    decodificador *validating*, `ui/gl`, viz). B1c no copia nada de la 150: usa el ANGLE de la 156 y no devuelve el
    decodificador [V: FM.55]. La deuda real puede ser cercana a cero [I]. Ese documento ya preveía cruzarlo con la lista
    de ficheros de LOCAL y no se hizo porque B1c se paró.

### B. Relajar la lista de ANGLE para modelos concretos

Tres líneas de parche y la validación más cara de las tres.

- No es una puerta, son tres. Quitar la del modelo deja a las Intel HD 4000/5000 e Iris Pro ante la de la familia [S: sin
  sonda] y a la GT 650M ante la de NVIDIA. Habría que quitar las tres.
- ANGLE usa la familia 2 para la resolución automática de profundidad y plantilla y para el *swizzle* de texturas
  (`DisplayMtl.mm:1252-1334`) [V]. Sin ella se degrada o se emula, como hizo B1d en Mojave; upstream dice que no lo
  soporta.
- En los portátiles de dos GPU la comprobación mira la GPU por defecto del sistema y el dibujo puede ir por la otra. La
  única candidata razonable es la R9 M370X del 11,5 (ANGLE ya lleva apaños para su driver, el mismo de la D500) [I], y
  obligaría a usar siempre la GPU dedicada: más calor y menos batería.
- Seríamos los únicos con ANGLE Metal en tres familias de GPU con drivers de Metal de 2012–2015 que nadie va a
  arreglar, y cada una solo se puede probar en un Mac de Titín.
- **Riesgo alto y coste sin techo. No la recomiendo.**

### C. No tocar el código y decirlo

- La 3.x funciona en esos Mac sin aceleración: lenta, sin WebGL.
- Coste: una nota en los requisitos de la web y en la ayuda.
- Variante: encender SwiftShader para WebGL en esos modelos. Da WebGL por CPU. Upstream lo dejó tras un permiso
  «unsafe» por seguridad [S: lo recuerdo del aviso de retirada, no lo he abierto]. No lo recomiendo por defecto.
- Sola, deja a FlyWeb peor que la 2.7.0 en casi todos los Mac a los que se dirige.

| | Gana | Coste | Riesgo | Seguridad |
|---|---|---|---|---|
| **A** OpenGL automático | Aceleración y WebGL en todos los que caen | 1–2 días + una oficial + batería | Medio: B1c sin terminar; macOS 11+ es diseño nuevo | Abre el OpenGL de ANGLE (mantenido) y 11 ficheros nuestros |
| **B** Relajar la lista | Metal, si funcionara | Parche mínimo; validación por GPU sin techo | Alto | Drivers de Metal sin soporte de nadie |
| **C** Decirlo | Nada | Una nota | Ninguno | Ninguna |

## 5. Recomendación

**A, y C desde ya como nota mientras tanto.** Decide Titín. La fecha la revisé el 13-11 por la noche con las medidas
de LOCAL-19: ver §5.1.

- **Por qué A:** el código de ANGLE ya está dentro y lo mantiene upstream; lo que falta es poco y está escrito. B gasta
  más en validar y acaba donde nadie más está.
- **Fecha (primera versión de este documento, superada por §5.1):** proponía la 3.2.0 entera, porque cambia el camino
  de dibujo y necesita la regla 17 y máquinas que solo prueba Titín. Sigue valiendo para macOS 11 o posterior.
- **Qué hay que decidir** (Titín): la directiva del 05-11 y `plan-3x.md:181` dejan B1c parada «salvo que la 5,1 falle
  con Metal». Esto es el mismo caso con otras máquinas: reabrirla para los modelos que ANGLE rechaza, y solo para ellos.
  En los Mac Pro, Metal sigue (×2,4 en MotionMark).

### 5.1 ¿Cabe en la 3.1.2? (añadido el 13-11 por la noche, buzón `20261113-2220`)

**Sí, con un recorte y dos condiciones.** Las medidas de LOCAL-19 cambian mi recomendación de fecha: diez veces más
lento en un Mac del objetivo no es para esperar a la 3.2.0.

- **El recorte: solo macOS anterior a 11** (Mojave y Catalina). Ahí el modo «GL por hardware» ya existe y es el que
  usan la 6,1 y la 5,1 [V], así que no hay diseño nuevo. En `gl_factory_mac.cc`, OpenGL se admite solo antes de
  macOS 11; de macOS 11 en adelante **no cambia nada** y el punto 3 de la opción A queda para la 3.2.0.
  - Entran: MacBook Pro y Mac mini de 2012 con Catalina, y el Air de 2013 con Mojave.
  - Se quedan como hoy hasta la 3.2.0: los que lleven Big Sur o Monterey (el 11,5 de pruebas).
- **Tamaño** [V: los cuatro commits de texturas, leídos enteros]: una línea para admitir OpenGL y las texturas
  rectangulares (11 ficheros). Con ANGLE en Metal la función devuelve `GL_TEXTURE_2D`, lo mismo que hoy: en los Mac Pro
  el camino es el de siempre con una comprobación más. Añade un campo al mojom `SharedImageCapabilities`.
- **Condición 1: que pinte, comprobado antes de cerrar el contenido.** Es lo único que B1c dejó sin hacer.
  - **Sin compilar:** se conserva `entregas/b1-local16/chromium-156-b1c.zip` (04-11). Si es la compilación con las
    texturas [S: por la hora], LOCAL puede mirar ya en la 6,1 si pinta y si WebGL crea contexto, y Titín en el Air de
    2013. En Catalina esa compilación no arranca [I: tiene la misma guarda que la 3.0.0].
  - **Con la candidata:** en la 6,1 con `--use-angle=gl` (batería de `pruebas-gpu.md`) y en el MacBook Pro de 2012.
  - El peor caso no es que siga lento: es que la GPU diga que va y la ventana no pinte, que fue el estado intermedio de
    LOCAL-16. Por eso la prueba va antes y no después.
- **Condición 2: regla 17** de los 15 ficheros, y que SEGURIDAD pase a tratar como aplicables los arreglos del OpenGL
  de ANGLE. El destino de textura lo calcula el cliente a partir de lo que anuncia el proceso de GPU: que lo mire.
- **Si no está en verde cuando la tanda de Chrome 158 esté lista, la tanda sale sola** y esto va en una 3.1.3 propia.
  La seguridad no espera por esto.
- **No choca con la puerta de la 3.1** (hilos y varias GPU, `plan-3x.md` §4.3), que es de rendimiento. Con lo que
  choca es con la directiva del 05-11 que deja B1c parada: la reabre Titín, solo para estos modelos.

**Lo que LOCAL-19 iba a mirar y ya está contestado aquí** (para no hacerlo dos veces):

- *Qué backends lleva nuestra 156:* Metal, OpenGL (CGL) y SwiftShader. `angle_enable_gl` vale verdadero por defecto en
  Mac (`third_party/angle/gni/angle.gni:230-233`) y `angle_enable_cgl` con él (`:412`); no hay que tocar los argumentos
  de compilación. Comprobado en el binario de la 3.1.1 (§2.2).
- *Si Chromium 156 soporta ANGLE GL en macOS:* ANGLE sí; Chromium no lo deja pasar (§2.2).

Le quedan las medidas y los pasos 1 a 3 de abajo.

**Antes de compilar nada, cuatro comprobaciones sin compilar FlyWeb:**

1. **LOCAL-19, en el 9,1:** `flyweb://gpu` entero y la salida de error del proceso de GPU con la 3.1.1 sin indicadores.
   Confirma en la máquina lo leído en §2.3.
2. **La sonda de Metal** (`FlyWeb/tools/metal-sonda/sonda.m`; se compila en cualquier Mac con `clang` y es un binario de
   línea de órdenes) en los cuatro Mac ocasionales. Da la familia de la HD 4000, la HD 5000, la GT 650M, la R9 M370X y la
   Iris Pro: cierra el [N] de `metal-mojave.md` y dice si B sería siquiera posible en el 11,5.
3. **El Air de 2013 con Mojave y la 3.1.1:** `flyweb://gpu`. Espero software [I]. Confirma que el alcance no es Catalina.
4. **SEGURIDAD:** recontar los 34 CVE contra los 15 ficheros reales de B1c (`flynk-b1b`, `95a974072b..d1bd098a89`).

Después, MOTOR adapta B1c en papel y resuelve el punto 3 de la opción A; entra en la lista cerrada de la versión que
toque.

**Huella:** en esos Mac la cadena de WebGL diría «OpenGL». No hay Chrome 156 real con el que comparar (no se instala en
Catalina) y la directiva «WebGL sin falsear» manda no igualarla.

## 6. Historia: cuándo y por qué lo quitó Google (150 → 156)

Añadido el 13-11 por la noche por encargo de Titín (buzón `20261113-2235`). Mensajes leídos en el repositorio público
`chromium/chromium`; los enlaces son `https://chromium.googlesource.com/chromium/src/+/<commit>`.

### 6.1 La secuencia [V]

| Fecha | Commit | Qué hizo | Motivo que da el mensaje |
|---|---|---|---|
| 10-07-2026 | [`38acbb5889`](https://chromium.googlesource.com/chromium/src/+/38acbb5889) | Quita de los robots de Mac las pruebas de ANGLE GL y de Ganesh (34 ficheros) | «Since Chrome no longer supports macOS 12, all supported OS versions support ANGLE Metal backend and Graphite» |
| 13-07-2026 | [`75824eea71`](https://chromium.googlesource.com/chromium/src/+/75824eea71) | **«Disallow Angle/CGL backend on mac»**: una línea menos en `gl_factory_mac.cc` | Sin texto; mismo bug |
| 13-07-2026 | ANGLE, «GL: Remove testing on Mac» (en el *roll* [`1da84cd657`](https://chromium.googlesource.com/chromium/src/+/1da84cd657)) | ANGLE deja de probar su backend GL en Mac | — |
| 23-07-2026 | [`1cb133a3ca`](https://chromium.googlesource.com/chromium/src/+/1cb133a3ca) | Quita `GetTextureTargetForIOSurfaces()` (6 ficheros) | «Mac allows only metal and swiftshader GL implementations now… this function always returns TEXTURE_2D» |
| 01-09-2026 | [`bed4ec1b17`](https://chromium.googlesource.com/chromium/src/+/bed4ec1b17) | Quita el indicador `DefaultANGLEMetal` | «Angle GL backend is no longer used» |
| 01-09-2026 | [`25a248a6cb`](https://chromium.googlesource.com/chromium/src/+/25a248a6cb), [`a6e2713267`](https://chromium.googlesource.com/chromium/src/+/a6e2713267), [`ca2f2e0554`](https://chromium.googlesource.com/chromium/src/+/ca2f2e0554) | Quita el aviso de cambio de GPU (`DisplayReconfigCallback`, `OnGpuSwitched`; 30 ficheros) | «Angle/CGL is not allowed anymore… as we stopped supporting hardware where it was needed» |
| 03-09-2026 | [`8b251c3c35`](https://chromium.googlesource.com/chromium/src/+/8b251c3c35) | Quita `texture_target_for_iosurface` del mojom (10 ficheros) | «It's always TEXTURE_2D now» |
| 16-09-2026 | [`c8593069ef`](https://chromium.googlesource.com/chromium/src/+/c8593069ef) | Quita el modo Ganesh/GL en Mac con Intel (revertido una vez en agosto por fallos de pruebas) | «All mac devices are using ANGLE/Metal as of M152 and can run Graphite» |
| 21-09-2026 | [`17a3918979`](https://chromium.googlesource.com/chromium/src/+/17a3918979) | Quita `DidSwitchGpu` (63 líneas de `drawing_buffer.cc`, el búfer de WebGL) | «It always returns false now» |

**Corrección (dato de LOCAL-19, comprobado por mí):** ANGLE no se limitó a dejar de probarlo. Entre la 150 y la 156 su
capa de Mac cambia en 8 ficheros de `renderer/gl/cgl/` (138 líneas): desaparecen `DisplayCGL::prepareForCall`,
`testDeviceLost` y el contexto «volátil» (`EGL_PLATFORM_ANGLE_DEVICE_CONTEXT_VOLATILE_CGL_ANGLE`) [V: `diff` de los
dos árboles]. Uno de esos cambios venía en el *roll* del 09-09 («Remove prepareForCall») y lo pasé por alto. La capa
sigue compilada y arranca (B1c en la 6,1), pero **está a medio desmontar**.

Bugs: [519633318](https://issues.chromium.org/issues/519633318) (la retirada de CGL) y
[40063538](https://issues.chromium.org/issues/40063538) (el lanzamiento de Graphite). No he abierto las fichas: solo
los commits que las citan. Todos están en la 156 [V: en el árbol, `supports_gpu_mode_hardware_gl_(false)` en Mac y
ningún `OnGpuSwitched`].

### 6.2 Por qué

- **Fue limpieza tras retirar hardware.** Chrome dejó de soportar macOS 12 y, según el primer mensaje, todos los
  sistemas que quedan admiten ANGLE Metal. Para Google, OpenGL en Mac se quedó sin usuarios. Ningún mensaje habla de un CVE ni de los
  controladores de Apple.
- **No es un backend abandonado, pero su capa de Mac sí:** el código común de OpenGL de ANGLE sigue en uso en Linux,
  Android y ChromeOS. La capa de Mac (`renderer/gl/cgl/`) ya no la prueba nadie y upstream ha empezado a recortarla.
- **La 150 lo traía todo** [V: árbol `~/proyectos/chromium-150`, 150.0.7871.287]: OpenGL el primero de la lista de
  admitidos, las texturas rectangulares y el aviso de cambio de GPU. Saltar de la 128 a la 156 nos hizo pasar por
  encima de la retirada sin verla.

### 6.3 Qué cuesta de verdad

**No basta ni hace falta un argumento de GN:** el backend ya se compila (`angle_enable_gl` es verdadero por defecto en
Mac). Lo que falta es código de Chromium:

| Pieza | Lo quitó | En B1c | Hace falta para |
|---|---|---|---|
| Admitir ANGLE OpenGL | 1 línea | Sí | Todo: indicador y paso automático |
| Modo GL por hardware | 1 línea | Ya está en la 3.1.1 antes de macOS 11 (B1d) | Componer con la GPU |
| Texturas rectangulares de IOSurface | 16 ficheros en 2 commits | Sí, 11 ficheros | Que pinte |
| Aviso de cambio de GPU | 36 ficheros en 4 commits | **No** | Portátiles con dos GPU, salvo los de NVIDIA (§6.4) |
| Capa de Mac de ANGLE (CGL) | 138 líneas en 8 ficheros | No; se usa la de la 156 | Recuperar un dispositivo perdido [S]. Si G1 o G5 fallan, se devuelve desde la 150 |
| Lista de apaños de controladores | No se tocó: 14 entradas de macOS, como en la 150 | — | — |
| Selección automática | No se tocó: Metal primero, OpenGL después | — | — |

**Hitos:**

| Hito | Qué | Compila |
|---|---|---|
| G1 | Comprobar que la B1c conservada pinta y da WebGL, en la 6,1 y en el Air de 2013 | No |
| G2 | Parche sobre el src de la 3.1.1: admitir OpenGL antes de macOS 11 y las texturas (rebase de B1c; 3 ficheros con retoque a mano) | No |
| G3 | Regla 17 de esos ficheros y recuento de los CVE del OpenGL de ANGLE | No |
| G4 | La candidata de la 3.1.2 con el parche; batería en la 6,1 con `--use-angle=gl` | La de la 3.1.2, que se compila igual |
| G5 | Prueba en el MacBook Pro de 2012 (cada GPU y el cambio automático), el mini de 2012 y el Air de 2013 | No |
| G6 | En la 3.2.0: macOS 11 o posterior y, si G5 lo pide, devolver el aviso de cambio de GPU | La de la 3.2.0 |

Ninguna compilación propia: G4 y G6 van con versiones que se compilan de todos modos. G1 a G3 son de días, no de
semanas [I].

**Cuánto se parece a la 2.7.0.** Lo que dibuja es lo mismo: ANGLE sobre el OpenGL 4.1 de Apple, con los mismos
controladores. Cambia quién lo sostiene. En la 2.7.0 (base 128) todo venía de Google y lo probaban sus robots de Mac;
en la 3.1.2 el backend sería el de la 156, más nuevo, la pieza de texturas sería nuestra, y desde julio de 2026 no lo
prueba nadie más en Mac.

### 6.4 El riesgo que añade esta lectura

- **Cambio automático de GPU. Corrijo lo que escribí antes:** en el MacBook Pro de 2012 el riesgo es menor de lo que
  dije. Chromium fija la GPU integrada en los portátiles Mac con NVIDIA (entrada 326 de la lista de apaños,
  `force_low_power_gpu`, que sigue en la 156 y se sigue aplicando: `gpu/config/gpu_switching.cc:100`) y ANGLE apaga ahí
  su soporte de cambio (`DisplayCGL.mm:177`) [V]. LOCAL-19 lo confirma en la 2.7.0: dibuja con la HD 4000. Queda por
  probar el caso forzado (cambio automático desmarcado, GT 650M siempre) y, para la 3.2.0, los portátiles con AMD
  dedicada como el 11,5, donde el cambio sí existe y el código que avisaba ya no está [S].
- **Cómo se limita a los Mac donde Metal no vale:**
  - el orden es fijo, Metal primero; OpenGL solo se prueba si la pantalla de Metal no arranca [V];
  - solo antes de macOS 11;
  - una web no puede elegir backend. `--use-angle=gl` queda disponible a mano en Mojave y Catalina, que es lo que
    permite probarlo en la 6,1; se puede cerrar después si se quiere.
- **Seguridad:** WebGL vuelve a llegar a los controladores de OpenGL de Apple, congelados desde Mojave y Catalina. Es
  la misma exposición que tenía la 2.7.0 en esos Mac. Los arreglos de ANGLE GL de la 151 a la 156 ya están en el árbol
  [I: por construcción; lo confirma el recuento de G3].

### 6.5 Datos de LOCAL-19 (buzón `20261113-2300`)

MacBookPro9,1, macOS 10.15.8, HD 4000 + GT 650M con cambio automático. Los tomo de su mensaje; los `chrome://gpu`
completos están en su carpeta de entregas y no los he abierto.

| | Dibuja con | WebGL | Aquarium 1 000 / 5 000 / 15 000 (fps) | MotionMark 1.3.2 |
|---|---|---|---|---|
| Safari de Catalina | Apple | sí | 59,7 / 43,0 / 16,1 | — |
| **2.7.0** | ANGLE OpenGL 4.1, HD 4000 | sí | **59,9 / 51,3 / 26,1** | 507 |
| 2.7.0 con Metal forzado | rechazado, SwiftShader | por software | 5,7 / 3,4 / 2,0 | 434 |
| **3.1.1** | nada: GPU apagada | **no** | — | **733** |
| 3.1.1 con SwiftShader | SwiftShader | por software | 5,9 / 3,9 / 2,0 | 742 |

**Lo que cambia en mi lectura:**

- **La ganancia no es «todo diez veces más rápido».** Es WebGL (hoy no existe sin un indicador «unsafe»; con OpenGL,
  ×10–13 en Aquarium) y el canvas (Arcs y Lines, ×3 a favor de la GPU en la 128). En composición, este Mac va mejor por
  CPU que por la HD 4000: la 3.1.1 por software (733) ya supera en MotionMark a la 2.7.0 con OpenGL (507).
- **No sé cuánto dará la 3.1.x con OpenGL en MotionMark.** En la 128, OpenGL ganaba un 17 % al software. Que en la 156
  también gane es una suposición: hay que medirlo (G5), y si la composición pierde, mirar si conviene componer por
  software y dejar la GPU para WebGL y canvas. Eso sería trabajo de la 3.2.0.
- **Con la GPU apagada tampoco hay decodificación de vídeo por hardware** [I: depende del proceso de GPU]. En un
  portátil de 2012 es batería y calor. No está medido.
- **El parche que LOCAL-19 dejó preparado** (`temp/local19/gpu-macs-antiguos/src.patch`, que no he leído) devuelve
  `kOpenGL` a la lista de admitidos. Coincide con la primera pieza, **pero solo con eso no pinta**: fue lo que encontró
  LOCAL-16 («eglBindTexImage requires 2D», miles de «uninitialized SharedImage»). Hacen falta además las texturas de
  B1c (`flynk-b1b`, cuatro commits). La parte de Metal de ese parche no la recomiendo, y Titín tampoco la quiere.

**Las dos preocupaciones de Titín:**

1. **¿Está probado el OpenGL de la 156 con alguna tarjeta?** No. Google quitó sus pruebas de Mac el 10-07-2026, antes
   de la 156. De nuestro lado solo existe el arranque de B1c en la D500 de la 6,1: sin errores, con la pintura y WebGL
   sin comprobar. Con la HD 4000, la HD 5000 y la GT 650M, nada. Es el motivo de que G1 y G5 vayan antes de cerrar el
   contenido, y de que el recorte a Mojave y Catalina no se amplíe hasta tenerlas.
2. **¿Abre agujeros de seguridad?** Menos de lo que parece, y ninguno nuevo respecto a la 2.7.0 en esos Mac:
   - la validación de WebGL es del frontal de ANGLE, común a todos los backends y con *fuzzing* de Google; no cambia;
   - lo que se añade es el controlador de OpenGL de Apple, sin parches en 10.14 y 10.15, igual que su Metal;
   - el proceso de GPU sigue en su sandbox;
   - lo que es nuestro y hay que revisar: los 11 ficheros de texturas (regla 17);
   - lo que nadie más vigila: la capa CGL de ANGLE. Un fallo ahí solo lo encontraríamos nosotros.
   - En los Mac donde Metal funciona no cambia nada: OpenGL solo se prueba si Metal no arranca.

**Coincido con la preferencia de Titín:** OpenGL de reserva y no forzar Metal en la familia 1. Las dos GPU de este Mac
son de familia 1, así que abrir Metal exigiría quitar las tres puertas a la vez.

## 7. Resultado de la compilación preliminar (14-11)

Añadido el 14-11. Datos de LOCAL-19 (buzón `20261114-1140-LOCAL-19-gl-preliminar-resultados.md`), contrastados por mí
con los ficheros de su carpeta de entregas (las tandas de la 6,1 y del MacBook Pro que cita su informe): los
`resultado-*.json`, los `chrome://gpu` guardados, `registro.jsonl`, el muestreo de CPU y las salidas de error. Las
capturas no las he abierto. **[V]** en este apartado quiere decir «visto en esos ficheros».

**Qué se probó:** la 3.1.1 (`seg/3.1.1` `9e0d83137f`) más los parches `0001`–`0005` de
`FlyWeb/parches/3.1.2-gl-reserva/`, rama `local/311-gl-reserva` `ee3814625b`, sin firmar y sin cambiar de versión.
Ninguna pieza más: ni Skia, ni el sandbox de GPU, ni la capa de Mac de ANGLE.

### 7.1 Las medidas [V]

| Mac | Dibuja con | WebGL 1 y 2 | Aquarium (fps) | MotionMark 1.3.2 | Vídeo |
|---|---|---|---|---|---|
| MacPro6,1, sin indicadores | **ANGLE Metal**, D500 | sí | 60,0 / 59,9 (1 000 / 10 000) | — | YouTube, 0 de 242 fotogramas perdidos |
| MacPro6,1, `--use-angle=gl` | ANGLE OpenGL 4.1, D500 | sí | 60,0 / 46,4 | — | YouTube, 0 de 523 |
| MacBookPro9,1, sin indicadores | **ANGLE OpenGL 4.1, HD 4000** (elegido solo) | sí | 59,8 / 59,6 / 27,4 (1 000 / 5 000 / 15 000) | **731** | YouTube durante G-C2, 3 de 2 436; decodificador sin anotar |
| MacBookPro9,1, cambio automático desmarcado | ANGLE OpenGL 4.1, GT 650M | sí | 60,0 / 60,0 / 36,6 | 698 | `VideoToolboxVideoDecoder`; YouTube 8 de 2 152; MP4 1080p 23 de 648 |

Referencias en el mismo MacBook Pro (§6.5): 2.7.0 con OpenGL 59,9 / 51,3 / 26,1 y 507; 3.1.1 publicada sin WebGL y
733; Safari 59,7 / 43,0 / 16,1.

En todas las tandas: Skia por Ganesh sobre GL, «GPU process crash count: 0», ninguna caída y ninguno de los tres
errores de LOCAL-16 («eglBindTexImage requires 2D», «uninitialized SharedImage», `BeginRasterCHROMIUM`). En la 6,1,
cero denegaciones del sandbox con Metal y con GL.

### 7.2 Lo que queda contestado

- **Pinta** (condición 1 de §5.1). La línea de `gl_factory_mac.cc` y las texturas rectangulares bastan.
- **G1 dio negativo por el zip, no por el parche.** El zip conservado de B1c abortaba el proceso de GPU en la 6,1
  (código 6). La preliminar no lo reproduce. La causa de aquel aborto queda sin determinar y ya no importa [I].
- **G2 salió más barato de lo que estimé:** los cuatro commits de texturas entraron sin retoque a mano.
- **Los Mac Pro no cambian** (prueba A): Metal por defecto y las mismas cifras. Con OpenGL forzado la 6,1 pierde un
  22 % en Aquarium con 10 000 peces: Metal sigue siendo el camino bueno donde funciona.
- **MotionMark no pierde** (duda de §6.5): 731 con la HD 4000 frente a 733 por software. La composición por GPU ni
  gana ni pierde en ese Mac; no hace falta el diseño de «componer por software y GPU solo para WebGL».
- **El vídeo por hardware vuelve** (duda de §4 y §6.5): VideoToolbox con la GT 650M y en la 6,1 por los dos caminos.
  Con la HD 4000 reproduce bien, pero nadie anotó el decodificador.
- **El cambio automático** (§6.4): `force_low_power_gpu` figura entre los apaños aplicados en los dos `chrome://gpu`
  del MacBook Pro y FlyWeb arranca en la Intel.
- **La capa de Mac de ANGLE recortada** (§6.1): en estas pruebas no hizo falta devolver `prepareForCall` ni
  `testDeviceLost`. Vale para lo probado, no para lo que falta (§7.4).

### 7.3 Lo que he visto en los ficheros y no está en el informe

1. **Con la GT 650M el canvas 2D va por software.** `chrome://gpu` dice «Canvas: Software only, hardware acceleration
   unavailable» y da el motivo: «Don't use the OOPR Canvas feature on Macs with NVIDIA GPUs» (crbug 1227033). Es la
   entrada 183 de `gpu/config/software_rendering_list.json`, de Chromium, y sigue en la 3.1.1 [V: árbol
   `seg/3.1.1`]. Con la HD 4000 el canvas va por GPU.
   - Explica que MotionMark baje con la tarjeta más rápida (698 frente a 731): Canvas Arcs 642 frente a 1 381 y Canvas
     Lines 2 687 frente a 10 141, mientras Paths y Suits suben (2 165 frente a 769; 319 frente a 146) [I: emparejo
     cifras y nombres por el orden del texto guardado].
   - **No es un fallo del parche y no recomiendo tocar la entrada:** es una decisión de Chromium sobre los
     controladores de NVIDIA en Mac. Supongo que la 2.7.0 hacía lo mismo [S: el bug es de 2021; no he mirado la 128].
   - Alcanza al MacBook Pro solo si el usuario desmarca el cambio automático. Y a las **5,1 de otros usuarios con
     NVIDIA en Mojave**: con el respaldo pasarán de software a OpenGL, con el canvas por software [I]. Nadie lo ha
     probado y no tenemos esa tarjeta.
2. **La prueba de reposo no deja rastro en los registros.** El informe dice «dormir y despertar (11:31, menos de un
   minuto)». En la tanda de G-C2 (`gc2c`):
   - `registro.jsonl` (fps, contextos perdidos, GPU activa) termina a las 11:30:42;
   - el muestreo de CPU, cada 5 s, va de las 11:23:43 a las 11:34:05 con **119 muestras y ningún hueco mayor de 6 s**.
     Un Mac dormido no muestrea: si hubiera dormido medio minuto dentro de esa ventana, habría un hueco [I].
   - **Aclarado por LOCAL-19 el mismo 14-11** (mensaje directo y corrección de las 11:55 en su informe del buzón):
     según `pmset -g log` del portátil, el reposo fue real pero duró **2 segundos** («Software Sleep» a las 11:30:59,
     despierto a las 11:31:01 por actividad del teclado o el ratón). Por eso no hay hueco en un muestreo de 5 s. El
     registro se había colgado antes, a las 11:30:42. FlyWeb seguía bien a las 11:31:48 (60 fps, cero contextos
     perdidos, cero caídas, por CDP). **La prueba queda como «no válida, a repetir»:** 2 segundos no apagan la GPU ni
     ejercitan la pérdida de dispositivo. El mismo registro anota «NVDA driver is slow (SetState) 1701 ms»: la
     NVIDIA estaba encendida, lo que cuadra con el punto 3 [I].
   - **Lo que sí consta** [V]: el proceso de GPU es el mismo (un solo identificador) en las 119 muestras; no se
     reinició.
   - Pedí repetirla con tapa cerrada cinco minutos o más, muestreo en marcha y `pmset -g log` como prueba: es la
     única de las tres pruebas de G-C2 que ejercita lo que ANGLE quitó (`testDeviceLost`), y SEGURIDAD la había dado
     por cerrada con el dato anterior.
   - **Repetida por LOCAL-19 el 14-11 a mediodía, y pasa** [V: `pmset-sleep-wake.txt`, `registro.jsonl` y `cpu.txt`
     de las dos tandas `gc2r-*`], con Aquarium y YouTube abiertos:

     | GPU | Reposo según `pmset` | Hueco en el muestreo | Al despertar |
     |---|---|---|---|
     | GT 650M | Tapa cerrada, 11:49:36 a 11:54:43 (5 min 7 s); el sistema se despertó solo dos veces, tramo dormido más largo 134 s | 76 s y 135 s | 60 fps, 0 contextos perdidos o restaurados, misma GPU, mismo proceso de GPU, «crash count» 0, el vídeo sigue |
     | HD 4000 | Por inactividad, 12:38:30 a 12:47:37 (9 min 7 s seguidos) | 547 s | Lo mismo; el vídeo no se puede valorar (estaba en pausa por un anuncio) |

     Ningún informe de caída en ninguna de las dos. **El reposo queda probado en este Mac** y no hizo falta devolver
     `prepareForCall` ni `testDeviceLost`. Es reposo normal de minutos; el reposo profundo de horas, con volcado a
     disco, no se ha probado, y para la aplicación debería ser lo mismo [I]. El cierre formal de G-C2 es de
     SEGURIDAD.
3. **El cambio de GPU en caliente sí consta, a medias.** En las muestras de las 11:29:10 a las 11:30:18, FlyWeb sigue
   en la Intel a 60 fps y con cero contextos perdidos [V]. Que la pantalla pasara a la NVIDIA lo dice el informe; en
   los ficheros que he abierto no lo veo.

### 7.4 Lo que falta

| Qué | Estado | Mi lectura |
|---|---|---|
| Reposo en el MacBook Pro | **Probado** con las dos GPU, 5 y 9 minutos (§7.3) | Nada pendiente |
| Monitor externo en el MacBook Pro | Sin probar (falta adaptador). SEGURIDAD lo pasa a después de publicar | De acuerdo en que no bloquea. En ese portátil las salidas de vídeo cuelgan de la tarjeta dedicada [S: de memoria], así que conectar un monitor fuerza el mismo cambio ya probado; lo nuevo es la segunda pantalla. Si falla es pantalla en negro, no seguridad |
| Air de 2013 con Mojave (HD 5000) y mini de 2012 | Sin probar | El mini lleva la misma HD 4000 con el mismo sistema [I]. **El Air es el único caso de Mojave con Intel**, y la HD 5000 no se ha probado con nada. Si no se puede antes de publicar, que la nota de la versión lo diga |
| Mac Pro 5,1 | Sin probar con la preliminar | No debería cambiar: Metal, como la 6,1 [I]. Entra en la batería de la candidata |
| Vídeo con la HD 4000 | Reproduce; decodificador sin anotar | Menor. Se mira en la candidata |
| macOS 11 o posterior (el 11,5 con Monterey) | Fuera de la 3.1.2 | G6, en la 3.2.0 |

**Si el monitor fallara,** la salida es la que ya nombró SEGURIDAD: devolver desde la 150 `prepareForCall`
y `testDeviceLost` (138 líneas en 8 ficheros de ANGLE, §6.1) o fijar una GPU. Eso sí sería una pieza más, con su regla
17, y entonces mi recomendación vuelve a ser sacar la 3.1.2 sin el respaldo y llevarlo a una 3.1.3.

### 7.5 ¿Merece la pena que el contexto pase a la NVIDIA?

Pregunta de SEGURIDAD por COORDINACIÓN-42 (14-11): tras el cambio en caliente, FlyWeb sigue dibujando en la Intel con
la pantalla en la NVIDIA. **No lo recomiendo, ni en una 3.1.x ni en la 3.2.x, para los Mac con NVIDIA.**

- **No es por el aviso que quitó la 156: es a propósito, y en la 150 era igual** [V: los dos árboles]. La entrada 326
  de la lista de apaños dice «Migrating OpenGL contexts between low- and high-power GPUs is unreliable on Mac NVIDIA
  laptops» y fija la integrada; ANGLE apaga su soporte de cambio si hay una NVIDIA (`DisplayCGL.mm:177`). Devolver el
  aviso no cambiaría nada en este Mac.
- **La ganancia es dudosa** [V: §7.1]: con la GT 650M, Aquarium con 15 000 peces sube de 27,4 a 36,6 fps, pero el
  canvas pasa a software (§7.3) y MotionMark baja de 731 a 698. Y gasta más batería.
- **Quien quiera la NVIDIA ya la tiene:** desmarcar el cambio automático antes de abrir FlyWeb (probado).
- **Donde sí importa es en los portátiles con AMD dedicada** (el 11,5): ahí ANGLE admite el cambio y el aviso que
  falta es el que lo dispara. Eso ya es G6, en la 3.2.0, con macOS 11 o posterior. No abre trabajo nuevo.

### 7.6 Cómo quedan los hitos de §6.3

| Hito | Estado el 14-11 |
|---|---|
| G1 | Hecho en la 6,1: el zip no servía. Superado por la preliminar. El Air de 2013, sin hacer |
| G2 | Hecho: `FlyWeb/parches/3.1.2-gl-reserva/` `0001`–`0005` |
| G3 | Hecho por SEGURIDAD-PORTES-23 (#985): apto con condiciones G-C1 a G-C3; la deuda de los 34 CVE es cero, como apuntaba la conclusión 6 |
| G4 | Adelantado con la preliminar en la 6,1. Falta la candidata de la 3.1.2 y su batería |
| G5 | MacBook Pro de 2012: hecho con las dos GPU y el cambio en caliente y el reposo; monitor sin probar. Mini y Air: sin hacer |
| G6 | En la 3.2.0, sin cambios |

### 7.7 Veredicto

**Entra en la 3.1.2, como ha decidido Titín.** La condición que puse («si pinta, y sin pieza añadida») se cumple, y lo
que temía de la composición no ha pasado. Lo único que pedí antes de cerrar el contenido, repetir el reposo con
prueba de que durmió, está hecho y pasa. Lo demás (monitor, Air, 5,1 con NVIDIA) no bloquea, pero debe constar en la
nota de la versión lo que no se ha probado.

## 8. Fuentes y límites

- **Código** (`flynk-b1d` `33a1745949`, ANGLE `e3917d6`): `third_party/angle/src/common/apple_platform_utils.mm`,
  `…/renderer/metal/DisplayMtl.mm`, `third_party/angle/gni/angle.gni:230-250,412`, `ui/gl/init/gl_factory_mac.cc`,
  `ui/gl/init/gl_display_initializer.cc`, `ui/gl/gl_display.cc:576-650`,
  `content/browser/gpu/gpu_data_manager_impl_private.cc`. Los números de línea son de ese árbol; en el de la 3.1.1 pueden
  moverse.
- **Historia (§6):** mensajes y listas de ficheros de los commits en el repositorio público `chromium/chromium`
  (API de GitHub, 13-11-2026) y el árbol `~/proyectos/chromium-150/src` (150.0.7871.287). Los dos árboles locales son
  superficiales: la historia no sale de ellos.
- **B1c:** `flynk-b1b`, `95a974072b..d1bd098a89` (8 commits; 15 ficheros, más los punteros de ANGLE y Dawn).
- **Binario:** `FlyWeb Framework` de la 3.1.1 instalada en la 7,1, con `strings` y `nm -u`.
- **Repositorio:** `docs/DIRECTIVAS.md` (04-11, 05-11, 09-11), `docs/TAREAS.md` FM.55, `FlyWeb/docs/b1d/README.md`,
  `gl-150-156-seg.md`, `metal-mojave.md`, `pruebas-gpu.md`, `hardware.md`, `FlyWeb/parches/3.1.1-catalina/`.
- **Preliminar (§7):** buzón `20261114-1140`, la carpeta de entregas de LOCAL-19, el apartado del respaldo GL en el
  PR 985 de SEGURIDAD y `gpu/config/software_rendering_list.json` del árbol de la 3.1.1 (`seg/3.1.1` `9e0d83137f`).
- **Límites:**
  - Hasta el 13-11 no tenía el registro de LOCAL-19 ni el src de la 3.1.1: §1 a §6 se escribieron sobre la base de la
    3.0.0. Los parches se comprobaron después sobre el src de la 3.1.1.
  - Los años de los modelos y hasta qué macOS llega cada uno son de memoria.
  - Costes y riesgos son estimaciones mías.
  - Que el OpenGL pinta en la 3.x está comprobado solo en dos Mac (§7): la 6,1 con la D500 y el MacBook Pro de 2012
    con sus dos GPU. La HD 5000, las AMD de portátil y cualquier NVIDIA en un Mac Pro siguen sin probar.
  - De §7 no he abierto las capturas ni he hablado con quien hizo las pruebas: lo que digo del reposo sale de los
    ficheros, y puede haber una explicación que no esté en ellos.
