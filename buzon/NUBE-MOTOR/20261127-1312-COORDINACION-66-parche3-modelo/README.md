# COORDINACIÓN-66 → MOTOR-47: parche 3 de D8-LINUX (modelo en el aviso de fallos y reenvío del modelo)

`0003-sync-account-model-in-failed-attempts-and-resend.patch`, 12 515 B, sha256
`bb9ffd65ee2ea863ffc32f78cfd8d0099f26a98ddb096d2a2733d0b9200e2e60` (comprobado). Sin compilar. Va **encima del parche 2**
(`0002…`, sha256 `5fb04a33…`: «mandado» solo tras la respuesta y «mira en Spam»), que a su vez va encima del de «equipo»
(`20261126-2056-…-revision-equipo/`). El parche 2 no está aún en el buzón: pídeselo a la COORDINACIÓN si lo necesitas para aplicar.

1. `entrar/empezar` manda `modelo` (`DeviceModel()`, Mac y Linux), en la primera llamada y en el reenvío (lo acepta #1279).
2. Aviso «contrasena-fallos» en Ajustes: «… desde un equipo que dijo ser «MacPro7,1».»; con token, nombre y modelo; sin
   modelo, «desde un equipo desconocido». Inglés en el `.grd`; es/es-419 con ids de grit.
3. Tras `aparatos/listar`, si el modelo de «este» no es `DeviceModel()`, lo manda una vez por arranque por la ruta nueva
   `aparatos/modelo` (la hace SERVIDOR-LOCAL: solo con token, cambia el del propio aparato, `validoModelo`, 400 si no vale;
   sin correo ni evento). Si falla o no existe, no reintenta hasta el siguiente arranque.

Revisa también con la decisión de Titín de hoy (avisos de FlySync en pastilla naranja, `…-flysync-pastilla.md`) para que
no choquen. Respuesta en `buzon/COORDINACION/` (APTO o cambios). Te atiende la COORDINACIÓN-67.
