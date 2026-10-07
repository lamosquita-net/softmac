# FlyWeb — Compatibilidad web (Fase 4)

Objetivo (hito de la Fase 4): claude.ai, Gmail, Drive y Workspace funcionan por completo, con una lista priorizada de
huecos. Este documento dice cómo diagnosticar cada fallo y qué hay ya hecho.

## 1. Por qué falla un sitio en FlyWeb

| Causa | Síntoma típico | Remedio |
|---|---|---|
| **Versión declarada** (User-Agent y Client Hints dicen Chrome 116) | Aviso de "navegador no compatible" o "actualiza Chrome", o una versión reducida del sitio, aunque todo funcionaría | Declarar una versión más nueva solo en ese sitio (pendiente: §4) |
| **JavaScript que falta** | La página se queda en blanco o a medias; en la consola: `... is not a function`, `... is not defined` | Polyfill (§3) |
| **CSS que falta** | Todo funciona, pero se ve mal: elementos solapados, sin estilo o descolocados | No tiene polyfill razonable. Se anota como deuda (Fase 6) |
| **JIT desactivado** (jitless; por defecto hasta la 1.5) | Lento, o falla WebAssembly (`WebAssembly is not defined`) | Desde la 1.6 el JIT va activado por defecto. Si aun así un sitio va sin JIT, revisar que no esté en `JavaScriptJitBlockedForSites` ni con el JIT bloqueado en la configuración del sitio |

## 2. Cómo diagnosticar un sitio (LOCAL o HUMANO)

Por cada sitio de la lista, probar en este orden y anotar el resultado en §5:

1. **FlyWeb normal.** ¿Funciona? Si no, abrir la consola (⌥⌘J) y copiar los errores rojos.
2. **Sin polyfills:** arrancar con `--disable-features=FlyWebPolyfills`. Si va peor que en el paso 1, los polyfills están ayudando
   (bien). Si va igual de mal, el problema es otro.
3. **Declarando una versión nueva:** cerrar FlyWeb y arrancarlo así:
   ```sh
   open -na "FlyWeb Development.app" --args \
     --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36"
   ```
   Si así desaparece el aviso, es un **bloqueo por versión declarada**. Ojo: esta opción solo cambia el User-Agent; los Client
   Hints (`navigator.userAgentData`, `Sec-CH-UA`) siguen diciendo 116, así que un "no" aquí no descarta del todo la versión.
4. **Con JIT** (solo hasta la 1.5; desde la 1.6 va por defecto): si el sitio no está en la lista de JIT de
   `flyweb-policies.mobileconfig`, añadirlo, reinstalar el perfil y repetir. Si mejora, se queda en la lista.
5. **Control:** el mismo sitio en un Chrome o Brave actual en la 7,1. Si allí también falla, no es cosa de FlyWeb.

## 3. Polyfills (hecho: brave-core `nube/polyfills`, paso 15 de `integracion.md`)

FlyWeb inyecta en cada página, antes que sus propios scripts, los polyfills de core-js para el JavaScript Baseline que le
falta: `Object.groupBy`/`Map.groupBy`, `Promise.withResolvers`, `Array.fromAsync`, `URL.canParse`/`URL.parse`, métodos de
`Set`, ayudantes de iteradores, `Promise.try`, `RegExp.escape`, base64/hex de `Uint8Array` y `URLSearchParams.has/delete` con
dos argumentos. Detalle, coste y cómo regenerarlo: `FlyWeb/polyfills/README.md`.

Lo que falta y **no** tiene polyfill está en [`baseline-gap.md`](baseline-gap.md) (85 funciones, generado de web-features).
Las más peligrosas, porque la web ya las da por supuestas y son de CSS:
- **Anidamiento de CSS** con la sintaxis relajada (Chrome 120): Chromium 116 entiende el anidamiento solo si el selector
  empieza por símbolo (`&`, `.`, `:`…). Una hoja escrita con `div { p { … } }` pierde esas reglas.
- **Subgrid** (117), `:user-valid`/`:user-invalid` (119), máscaras CSS sin prefijo (120), `light-dark()` (123),
  `@starting-style` y `transition-behavior` (117).

## 4. Versión declarada por sitio — **retirada en la 1.1** (decisión del HUMANO, 04-10-2026)

> **Desde la 1.1 no hay excepciones por sitio:** todas las webs, Google incluido, ven el nivel de motor real (117 en la
> 1.1; `motor.md`, principio 4). El código de la anulación **se ha quitado** (brave-core e428d8b4, integrado por LOCAL en
> el paso 48). Si Gmail, Drive o Docs avisan de navegador antiguo, se anota en §5 como dato: indica qué nivel de motor
> necesitan. Lo de abajo describe la 1.0 y la 1.0.1.


Activado por el aviso de Google Drive en la 6,1 ("Ya no se admite esta versión del navegador"). En los sitios de la lista,
FlyWeb declara una versión más nueva de Chrome **en el User-Agent y en los Client Hints a la vez** (si solo cambiara uno,
Google lo detectaría como incoherente), con el mecanismo de Chromium para sustituir el User-Agent por pestaña. En el resto
de sitios sigue diciendo 116.

- Lista por defecto: `drive.google.com`, `docs.google.com` y `mail.google.com` (cada una incluye sus subdominios). Gmail
  se añadió el 01/10 (HUMANO, en la 6,1: con la 153 el aviso desaparece). **No se pone `google.com` entero:** cubriría
  también el buscador, `accounts`, Meet, Calendar, Maps…, donde no hay aviso y sí más riesgo de que Google sirva código
  para un Chrome nuevo. Se añade sitio a sitio cuando se vea el aviso. claude.ai no la necesita.
- Versión declarada: 153 (Chrome estable a 01-10-2026). **Subirla en cada ciclo de mantenimiento**, o Google volverá a
  mostrar el aviso cuando la 153 quede atrás.
- Se ajusta sin compilar: `--enable-features=FlyWebUserAgentOverride:chrome_major/154/sites/drive.google.com%2Cdocs.google.com`.
  Las comas dentro de `sites` se escriben **`%2C`**: `--enable-features` ya separa con comas.
- En esos sitios, los Client Hints declaran además `fullVersionList` y `fullVersion` reducidos (`153.0.0.0`, como hace
  Brave con los normales; antes salía `153.1.57.64`, la versión de Brave) y `platformVersion` `14.7.0` (parámetro
  `platform_version`), porque Chrome 153 no existe para macOS 10.14 y la pareja delataría la mentira. El User-Agent ya dice
  `Mac OS X 10_15_7` en todos los Chrome (está congelado).
- **Primera carga de la pestaña del arranque:** recibe el UA de la 116 (HUMANO, 01/10); al recargar, bien. El código pone
  el UA antes de que salga la petición también en esa pestaña (revisado en Chromium 116: los ayudantes de pestaña se
  instalan antes de cargar, también al restaurar la sesión), así que la causa probable es que esa carga no sale a la red:
  la sirve el **service worker** de Gmail (los workers no tienen UA por pestaña) o la caché al restaurar la sesión.
  Comprobar en DevTools → Network, en esa primera carga: columna "Size" del documento (`(ServiceWorker)` / `(disk cache)`)
  y la cabecera `User-Agent` de la petición. Con eso se decide el arreglo; hasta entonces, recargar una vez.
- Riesgo: el sitio puede usar funciones que la 116 no tiene, creyendo hablar con un Chrome nuevo. Por eso es por sitio. Si
  Drive o Docs fallan con el cambio, quitar el sitio de la lista.

## 5. Resultados del diagnóstico

| Sitio | FlyWeb | Sin polyfills | Con UA nuevo | Con JIT | Causa | Notas |
|---|---|---|---|---|---|---|
| claude.ai | | | | | | |
| Gmail (mail.google.com) | | | | | | |
| Google Drive | | | | | | |
| Docs | | | | | | |
| Sheets | | | | | | |
| Calendar | | | | | | |
| YouTube | | | | | | |
| GitHub | | | | | | |
| SwissTransfer (envío de ficheros grandes) | | | | | | Prueba específica abajo |
| WeTransfer (uso ocasional) | | | | | | Misma prueba; JIT: `[*.]wetransfer.com` |

### Prueba específica: envío de ficheros grandes (SwissTransfer, y WeTransfer de forma ocasional)

**Desde la 1.6 (JIT por defecto) este riesgo desaparece**: la prueba solo hace falta en la 1.5 o anteriores.
Riesgo: el sitio va **sin JIT** (no está en la lista). Si usa WebAssembly para trocear o calcular sumas de los ficheros, sin
JIT no funciona (`WebAssembly is not defined` en la consola); si lo hace en JavaScript, funcionará pero puede ir muy lento
con ficheros de varios GB. El envío en sí depende de la red, no del JIT. No se ha podido mirar desde la nube: el código
web de SwissTransfer no es público y el sitio está bloqueado en el entorno de NUBE.

1. En FlyWeb (sin JIT), subir un fichero de ~2–5 GB a https://www.swisstransfer.com. Anotar si arranca, la velocidad
   que muestra, el uso de CPU del proceso de la pestaña (Monitor de Actividad) y si la consola da errores.
2. Descargarlo desde el enlace recibido y comprobar que el tamaño coincide.
3. Si falla o la CPU va al 100 % con la red ociosa: añadir `[*.]swisstransfer.com` (y el dominio de subida que se vea en
   la pestaña Red, probablemente de `infomaniak.com`) a `JavaScriptJitAllowedForSites` en `flyweb-policies.mobileconfig`
   y repetir. El riesgo de dar JIT a un sitio concreto es el mismo que se ha asumido para Google (F3B.6).
4. Control: el mismo envío en un navegador actual de la 7,1.
