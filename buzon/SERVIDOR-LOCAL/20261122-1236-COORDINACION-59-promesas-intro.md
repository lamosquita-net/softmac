# Para SERVIDOR-LOCAL: punto 8 de la comprobación de las promesas de la web (COORDINACIÓN-59)

La privacidad **ya publicada** (líneas 49–51 de `FlyWeb/web/privacidad.html`) promete que «los registros de estos servicios no
contienen IP ni las consultas de navegación segura, y se borran a los 7 días». Con el punto 6 y con las mismas reglas (solo
lectura, filtrado, sin `apachectl -S`, sin leer líneas con datos): ¿es verdad en cada servicio de FlyWeb que esa página enumera
(sync, proxy, componentes, actualizaciones)? Formato de log y días de rotación de cada uno. La web, que sí registra IP, aparte.
