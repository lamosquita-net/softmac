# La 3.x sin aceleración gráfica fuera de los Mac Pro: las puertas de ANGLE Metal

ARQUITECTURA, 13-11-2026. Encargo de COORDINACIÓN-41 (buzón `20261113-2115`), a partir del hallazgo de LOCAL-19 en el
MacBookPro9,1 con Catalina y la 3.1.1. **Solo papel: nada compilado, nada lanzado, nada medido.** Leído: el árbol
`~/proyectos/chromium-156/src` (rama `flynk-b1d` `33a1745949`, la base de la 3.0.0; ANGLE `e3917d6`), la rama `flynk-b1b`
(B1c), los parches de la 3.1.x del repositorio y el binario de la 3.1.1 instalada en la 7,1 (`strings` y `nm`).
**Ampliado el 13-11 por la noche** (buzón `20261113-2220`, medidas de LOCAL-19): conclusión 2 y 5, §2.3 y §5.1.

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
- **Cuál de las tres puertas corta en cada GPU.** El modelo corta siempre antes. La familia de las Intel HD 4000 y 5000,
  de la GT 650M y de la R9 M370X **no está medida** (`metal-mojave.md` lo dejaba en [N]).

## 3. Qué máquinas caen

### 3.1 Las nuestras (`CLAUDE.md`, «Máquinas»)

| Máquina | GPU · sistema | Modelo | Resultado en la 3.x |
|---|---|---|---|
| MacPro7,1 | 580X / W6600X · Sequoia | pasa | **Metal** [V] |
| MacPro6,1 | 2× FirePro D500 · Mojave | pasa | **Metal**: la sonda dice familia 2 [V: `metal-sonda/MacPro6,1-10.14.6.txt`] |
| MacPro5,1 | RX 580 · Mojave | pasa | **Metal**, familia 2 [V: `pruebas-gpu.md:139`] |
| MacBook Pro 15" 2012 (9,1) | GT 650M + HD 4000 · Catalina | **cae** (< 13,1) | Por software y sin WebGL [V: LOCAL-19]. Además, NVIDIA |
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

## 6. Fuentes y límites

- **Código** (`flynk-b1d` `33a1745949`, ANGLE `e3917d6`): `third_party/angle/src/common/apple_platform_utils.mm`,
  `…/renderer/metal/DisplayMtl.mm`, `third_party/angle/gni/angle.gni:230-250,412`, `ui/gl/init/gl_factory_mac.cc`,
  `ui/gl/init/gl_display_initializer.cc`, `ui/gl/gl_display.cc:576-650`,
  `content/browser/gpu/gpu_data_manager_impl_private.cc`. Los números de línea son de ese árbol; en el de la 3.1.1 pueden
  moverse.
- **B1c:** `flynk-b1b`, `95a974072b..d1bd098a89` (8 commits; 15 ficheros, más los punteros de ANGLE y Dawn).
- **Binario:** `FlyWeb Framework` de la 3.1.1 instalada en la 7,1, con `strings` y `nm -u`.
- **Repositorio:** `docs/DIRECTIVAS.md` (04-11, 05-11, 09-11), `docs/TAREAS.md` FM.55, `FlyWeb/docs/b1d/README.md`,
  `gl-150-156-seg.md`, `metal-mojave.md`, `pruebas-gpu.md`, `hardware.md`, `FlyWeb/parches/3.1.1-catalina/`.
- **Límites:**
  - No tengo el registro de LOCAL-19: el hallazgo lo conozco por el mensaje de COORDINACIÓN.
  - No he visto el src de la 3.1.1; lo deduzco de la base de la 3.0.0 más los parches publicados.
  - Los años de los modelos y hasta qué macOS llega cada uno son de memoria.
  - Costes y riesgos son estimaciones mías.
  - Que el OpenGL pinte bien en la 3.x no lo ha comprobado nadie.
