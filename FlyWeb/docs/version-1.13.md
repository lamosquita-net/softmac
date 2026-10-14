# FlyWeb 1.13 — nivel de motor 129 (MOTOR-8, 14-10-2026)

**Cabeza final:** brave-core `nube/motor-129` **325686916c** (43ef04cf64 + fuente monoespaciada Menlo, orden de COORDINACIÓN-5).

**Estado:** en código en brave-core `nube/motor-129` **325686916c** (Static de 43ef04cf64 probado: WPT del 129 iguales a Chrome 129; falta el ASan del
nivel completo), con FS.13 fundida (`seg/v8-12.9` y `seg/blink-129`;
selección de instrucciones de Turboshaft y *wrapper* genérico wasm→JS encendidos, como en Chrome 129: regla 19). Encima de la 1.12.2 (bb6c7146) lleva
la V8 de Chrome 129 (paso b589e86dc7), la Baseline y las flags de interoperabilidad del 129, y declara 129 / 1.13. Un
solo nivel en una sola versión (regla 18). **No se publica sin FS.13** (`seg/v8-12.9`: los 6 parches de seguridad de V8
que el paso de V8 dejó fuera y la época de caché 13). LOCAL-3 compila primero el paso de V8 (Static y ASan con YouTube
y las webs con JIT) y después todo el nivel. Detalle técnico: `motor.md`, «Nivel 129»; commits:
`FlyWeb/tools/port/nivel129-commits.tsv`.

| Dato | Valor |
|---|---|
| Cabeza final | brave-core `nube/motor-129` **325686916c** (paso de V8 + FS.13 en `nube/motor-129-v8` fdac7ed13b) |
| Fuente monoespaciada | Menlo por defecto en Mac, como Chrome desde la 118 (antes Courier; se escapó en el nivel 118 por estar fuera de Blink). La lista japonesa de la 129 no, por necesitar código de preferencias posterior a la 116 |
| Versión visible | 1.13 (`CFBundleVersion` la pone LOCAL en la entrega) |
| Nivel declarado | Chrome 129 (`flyweb_engine_full_version` 129.0.6668.101; `platformVersion` mínimo **11.7.10**: Chrome 129 ya no funciona en 10.15) |
| Motor JavaScript | V8 12.9.202.28 (la de Chrome 129) con los arreglos de seguridad de FlyWeb (FS.13; época de caché 13) |
| Portes del 129 | `Intl.DurationFormat`, WebAuthn en JSON, Blob en `RTCDataChannel`, `container-type` sin contención de *layout*, 10 flags de interoperabilidad y el arreglo de `aria-*indextext` de la rama 129 |
| Fuera, con motivo | 3 flags que dependen de código posterior a la 116; lo que no es Baseline (`scheduler.yield()`, `calc-size()`, eventos de *scroll snap*); *anchor positioning* |
| Comprobación | `FlyWeb/tools/motor-129.html`, `fastapi-129.html` y `wpt-129-lista.txt` |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12 del tablero.)*

- **Motor al nivel de Chrome 129**, con el motor de JavaScript de Chrome 129. Las webs ven FlyWeb como Chrome 129, y lo
  es en lo que usan.
- **Duraciones bien escritas.** Las webs pueden mostrar duraciones en el idioma del usuario («1 hora y 2 minutos»,
  «1:02:03») con la función estándar (`Intl.DurationFormat`) que ya tenían Safari y Firefox.
- **Llaves de seguridad con las webs modernas.** Las webs que usan llaves de seguridad USB (y, en general, WebAuthn)
  pueden preparar el inicio de sesión con el formato JSON estándar, como hacen las librerías actuales de *passkeys*.
- **Archivos por conexiones directas.** Las webs de videollamada, juegos o transferencia de archivos entre usuarios
  (WebRTC) pueden enviar y recibir archivos directamente, sin convertirlos antes.
- **Menús y ventanas emergentes mejor colocados.** Las partes de una página que se adaptan a su propio tamaño
  (*container queries*) ya no atrapan dentro a los menús y avisos flotantes, como en Chrome, Safari y Firefox.
- **Texto monoespaciado como en Chrome.** El código y el texto de ancho fijo de las webs que no eligen fuente se ven
  con Menlo, como en Chrome y Firefox, en vez de con Courier. Si se eligió otra fuente en los ajustes, se respeta.
- **Pequeños arreglos de compatibilidad:**
  - Los editores de las webs avisan una sola vez de cada cambio de selección, como Safari y Firefox.
  - Al pegar en un área de texto, la web recibe el texto pegado.
  - Deshacer después de borrar entre párrafos funciona como en Chrome 129.
  - Al copiar texto, los párrafos que terminan en un elemento oculto ya no se pegan unidos.
  - Las casillas y botones se ven pulsados también en el segundo clic sobre su etiqueta.
  - Los controles deslizantes verticales se mueven con las flechas en el sentido esperado.
  - WebGL y los gráficos de las webs siguen igual de rápidos con el motor de JavaScript nuevo.
- **Nada cambia** en los ajustes ni en los datos del usuario. La primera vez que se abra una web pesada puede tardar un
  poco más (el motor de JavaScript nuevo vuelve a preparar su caché).

## WPT del nivel 129

Static de 43ef04cf64 (LOCAL-3, 14-10), lista `FlyWeb/tools/wpt-129-lista.txt` (27), comparada con Chrome for Testing
129.0.6668.100 en el mismo Mac y con las `TestExpectations` de la 129.0.6668.112: **iguales a Chrome 129**.

- Dos diferencias reales encontradas y cerradas: `RTCDataChannel-binaryType.window` (el porte dejaba el IDL en
  `DOMString` y lanzaba con valores no válidos; arreglado en 43ef04cf64: 10/10) y las 4
  `container-queries/no-layout-containment-{abspos,fixedpos}[-dynamic]` (los 200 px eran de la captura con
  `Emulation.setDeviceMetricsOverride`; con una pestaña por página y sin emulación, 0 px en 25/25, como Chrome 129).
- No comparables: `webauthn/public-key-credential-to-json.https.window` (crea un autenticador virtual con WebDriver; falla
  igual en Chrome sin él) y `webrtc/RTCDataChannel-send-close` (igual que la 1.12.2; en la 129 es `Skip Timeout` en
  Mac 15).
