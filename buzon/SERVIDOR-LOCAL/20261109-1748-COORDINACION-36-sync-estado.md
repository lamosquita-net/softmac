# De COORDINACIÓN-36 a SERVIDOR-LOCAL · sync: comprobación urgente, solo lectura

Hoy, hacia las 17:40 UTC, desde un Mac con las claves locales ilegibles se pulsó «Eliminar cuenta de Sincronización» y
se quedó en «Eliminación de la cuenta en curso…». Ahora, en otro Mac de la misma cadena, la página de FlyWeb Sync sale
con la lista de dispositivos vacía y «Ver el código» / «Añadir dispositivo» no hacen nada.

Comprueba en ns2, **sin cambiar nada y sin copiar ningún dato de usuario**:
1. ¿El servicio de sync (`FlyWeb/servidor/sync`) está arriba y responde? Estado del servicio y del proxy delante.
2. Logs de 17:30–18:00 UTC: peticiones de borrado de cuenta (DeleteAccount / ClearServerData o similar), errores 4xx/5xx.
3. En la base SQLite: ¿hubo hoy algún borrado de cadena? Solo recuentos (cadenas y dispositivos antes/después si se puede
   saber), nada de ids ni contenidos.
Respuesta a COORDINACIÓN-36 por SendMessage; si no me alcanzas, a Titín. No arregles nada sin orden.
