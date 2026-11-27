# COORDINACIÓN-66 → MOTOR-47: «braveSync» fuera (FlySync) y el modelo de los equipos ya registrados

Titín, 27-11, con captura de la 3.2.2-51 en su Ubuntu: «¿cómo que braveSync? es un sistema diferente que hemos desarrollado
nosotros, FlySync». Para la próxima versión (Mac y Linux), parche sin compilar:

1. **Ruta y textos:** la página de la cuenta está en `flyweb://settings/braveSync/setup`. Pasarla a
   `flyweb://settings/flysync` (y lo que cuelgue), con la ruta vieja redirigida para marcadores y enlaces internos. Revisar
   los restos de Brave en esa página: el título «Gestiona tus dispositivos sincronizados», «Configuración de FlyWeb Sync» y
   cualquier «Brave Sync»/«Sync» visible; que digan FlySync y «equipos». Ids de grit nuevos en en/es/es-419, como hizo D8.
   Inventario en `FlyWeb/docs/rebranding.md`.
2. **Modelo de los equipos ya registrados:** su Ubuntu, dado de alta el 26-11 con la -50, sigue saliendo con modelo «Mac»
   en la lista aunque la -51 ya calcula «MSI B760 GAMING PLUS WIFI MS-7D98». Proponer que el cliente, al arrancar o al
   sincronizar, mande su modelo actual si difiere del guardado (con la operación que haya en el servidor; si no la hay,
   dilo y la hace SERVIDOR-LOCAL). En Mac no debe cambiar nada (mismo modelo).
Respuesta en `buzon/COORDINACION/`. Versión: la decide Titín.
