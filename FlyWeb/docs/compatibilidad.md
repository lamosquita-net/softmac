# FlyWeb — Compatibilidad web (Fase 4)

Objetivo (hito de la Fase 4): claude.ai, Gmail, Drive y Workspace funcionan por completo, con una lista priorizada de
huecos. Este documento dice cómo diagnosticar cada fallo y qué hay ya hecho.

## 1. Por qué falla un sitio en FlyWeb

| Causa | Síntoma típico | Remedio |
|---|---|---|
| **Versión declarada** (User-Agent y Client Hints dicen Chrome 116) | Aviso de "navegador no compatible" o "actualiza Chrome", o una versión reducida del sitio, aunque todo funcionaría | Declarar una versión más nueva solo en ese sitio (pendiente: §4) |
| **JavaScript que falta** | La página se queda en blanco o a medias; en la consola: `... is not a function`, `... is not defined` | Polyfill (§3) |
| **CSS que falta** | Todo funciona, pero se ve mal: elementos solapados, sin estilo o descolocados | No tiene polyfill razonable. Se anota como deuda (Fase 6) |
| **JIT desactivado** (jitless) | Lento, o falla WebAssembly (`WebAssembly is not defined`) | Añadir el sitio a la lista de JIT (`flyweb-policies.mobileconfig`) |

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
4. **Con JIT:** si el sitio no está en la lista de JIT de `flyweb-policies.mobileconfig`, añadirlo, reinstalar el perfil y
   repetir. Si mejora, se queda en la lista.
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

## 4. Versión declarada por sitio (pendiente)

Se hará solo si el diagnóstico (§2, paso 3) muestra bloqueos. Diseño previsto: una lista de sitios en la que FlyWeb declara
una versión más nueva de Chrome **en el User-Agent y en los Client Hints a la vez** (si solo cambia uno, Google lo detecta
como incoherente), usando el mecanismo de Chromium para sustituir el User-Agent por pestaña. Riesgo: el sitio, creyendo que
es un Chrome nuevo, puede usar funciones que FlyWeb no tiene; por eso por sitio y no global.

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
