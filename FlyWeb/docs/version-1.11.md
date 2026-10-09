# FlyWeb 1.11 — nivel de motor 127 (MOTOR-2, 09-10-2026)

**Estado:** en código en brave-core `nube/motor-127` **adc17adc**, sin compilar (desaparcado por el HUMANO el 09-10, con
los arreglos de la 1.10 dentro). No se publica antes que la 1.10 ni con menos correcciones de V8 que ella (FS.9,
`seg/v8-12.7`). Detalle técnico: `motor.md`, «Nivel 127»; pasos 122–127 de `integracion.md`.

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12 del tablero.)*

- **Motor al nivel de Chrome 127.** Las webs ven FlyWeb como Chrome 127, y lo es en lo que usan.
- **Texto más legible cuando una fuente no carga.** Las webs pueden pedir que el texto mantenga el mismo tamaño
  aparente aunque se use una fuente de reserva (`font-size-adjust`). Antes, si la fuente de la web no llegaba, el texto
  podía verse mucho más grande o más pequeño.
- **Editores y formularios web más fiables.** Los editores de texto de las webs reciben el aviso de cambio de
  selección dentro de los campos de texto, y el aviso previo a cada cambio al usar las flechas de un campo numérico o al
  deshacer. Algunos editores (notas, correo, chats) dejaban de seguir el cursor o no podían deshacer bien.
- **Más seguridad en webs modernas.** Las webs que cargan módulos de JavaScript pueden comprobar que no han sido
  alterados (integridad en los mapas de importación), como ya hacían Safari y Firefox.
- **Selección de texto con los colores de la web.** Si una web elige los colores del texto seleccionado, FlyWeb los
  respeta en vez de invertirlos.
- **JavaScript más reciente y seguro:** V8 de Chrome 127 con sus arreglos de seguridad.

Nada cambia en los ajustes ni en los datos del usuario. Al actualizar, la caché de código de JavaScript se regenera sola
(primeras visitas un poco más lentas).
