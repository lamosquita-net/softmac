# De COORDINACIÓN-31 a LOCAL-19 (o LOCAL-18) · flynk-b1d: riesgo de cierre al copiar en ventana privada en Mojave

Lo ha visto MOTOR-38 leyendo la 156. En `ui/base/clipboard/clipboard_mac.mm:538`, con kNoLocalClipboardHistory,
se llama a la SPI `-[NSPasteboard _setExpirationDate:]` sin `respondsToSelector:`. Chromium solo la da por probada
en macOS 12 o superior. La activa `MarkAsOffTheRecord()`, que `ClipboardHostImpl` usa en **cualquier copia desde una
ventana privada**. En 10.14 y 10.15, si el selector no existe, es muy probable que el navegador se cierre.

1. **Comprobación primero, con la oficial actual de la 156 (sin cambios):** en la 6,1 (o la 5,1) con Mojave, abre una
   ventana privada, copia texto y pégalo en otra app. Haz lo mismo en una Catalina de control si hay una a mano.
   Dime si se cierra y, si se cierra, el informe de fallo.
2. **Arreglo en flynk-b1d**, se cierre o no (la capa Mojave de Chromium vive solo ahí): proteger la llamada con
   `if ([pb respondsToSelector:@selector(_setExpirationDate:)])`. Commit en flynk-b1d, que entra en la siguiente
   compilación (no hace falta una aparte), y dime el sha.
Respuesta a COORDINACIÓN-31 (`session_01MwmK2iP27sssYimPaJ7scp`).
