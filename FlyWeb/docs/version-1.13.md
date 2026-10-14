# FlyWeb 1.13 — nivel de motor 129 (MOTOR-8, 14-10-2026)

**Estado:** en código en brave-core `nube/motor-129` **91c501b266**, sin compilar. Falta encender la selección de instrucciones de
Turboshaft (regla 19). Encima de la 1.12.2 (bb6c7146) lleva
la V8 de Chrome 129 (paso b589e86dc7), la Baseline y las flags de interoperabilidad del 129, y declara 129 / 1.13. Un
solo nivel en una sola versión (regla 18). **No se publica sin FS.13** (`seg/v8-12.9`: los 6 parches de seguridad de V8
que el paso de V8 dejó fuera y la época de caché 13). LOCAL-3 compila primero el paso de V8 (Static y ASan con YouTube
y las webs con JIT) y después todo el nivel. Detalle técnico: `motor.md`, «Nivel 129»; commits:
`FlyWeb/tools/port/nivel129-commits.tsv`.

| Dato | Valor |
|---|---|
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

Pendiente del Static de LOCAL. Lista: `FlyWeb/tools/wpt-129-lista.txt` (27 pruebas). Se comparan con lo que Chrome 129
falla (`TestExpectations` de la 129.0.6668.112): ahí `webrtc/RTCDataChannel-send-blob-order.html` está como `Timeout` en
Mac 15. `webauthn/*.https.window.html` necesitan el servidor WPT con HTTPS.
