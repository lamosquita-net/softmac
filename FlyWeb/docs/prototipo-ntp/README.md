# Pestaña nueva y primer inicio — prototipo y decisiones (03/10/2026)

Diseño del HUMANO (maquetas en `maquetas/`); prototipo de LOCAL, revisado con el HUMANO en la MacPro6,1.
**Encargo para NUBE (F7.2):** montarlo en brave-core `nube/ntp`, partiendo de la rama `local/ntp-recursos`
(8f822f87), que trae los recursos en `components/flyweb_ntp/resources/` (fondos, D-DIN + `OFL.txt`, moscas).

Para ver el prototipo: copiar `fondos/` y `fuentes/` de esa carpeta de brave-core junto a los dos HTML y abrirlos
en FlyWeb. En la pestaña nueva, abajo en el centro hay controles **solo del prototipo** (fondo 1–7, «sin paradas»,
«sin aleteo», «px enteros», «ruta»; teclas ← → 1–7 V R): no van al navegador.

## Pestaña nueva (`newtab.html`)

- **Elementos** (maquetas `newtab-1` … `newtab-7`): contadores de Escudos arriba a la izquierda, accesos debajo, reloj
  arriba a la derecha, crédito "© fotografía @lamosquita" abajo a la izquierda y abajo a la derecha "personalizar" más
  los iconos que ya tiene la pestaña de Brave: **ajustes, marcadores e historial. Talk fuera.**
- **Tipografía D-DIN** (solo regular y bold; son ligeramente condensadas): **bold** para el reloj, los números de los
  contadores y "personalizar"; **regular** para el resto.
- **Colores del proyecto, sin cambiar** (decisión del HUMANO): naranja del icono `rgb(255,153,0)`, rojo de lamosquita
  `rgb(210,10,17)`, morado de desarrollo `rgb(149,27,129)`, uno por contador.
- **Un fondo por modelo** (7) y, por fondo, el color de los textos que lo pisan (`FONDOS` en el script):
  etiquetas blancas en 3 y 6, negras en el resto; crédito blanco en 3, 4 y 6. El reloj y "personalizar", siempre negros.
  (En la maqueta 7 las etiquetas salían blancas por error: van en negro.)
- **La mosca vuela con JavaScript**, como en www.lamosquita.net (`assets/js/moscas.js` del HUMANO): un bucle
  `requestAnimationFrame` que solo cambia `transform` (`translate` + `rotate`); mira un poco por delante para
  orientarse; descuenta el tiempo con la pestaña oculta (no salta).
  - **Ruta:** un **ocho tumbado y desigual** (maqueta del HUMANO), en proporciones de la ventana (`RUTA`).
    **Tres posaderos:** arriba a la izquierda, a la derecha bajando y en el cruce, pero **solo en una de las dos
    pasadas** por él.
  - **Vuelos largos:** 105 px/s a 1280 de ancho (escala con la ventana), ±18 % por tramo, arranca y frena suave;
    ondulación de 10 px y tembleque de 2,5 px; un 20 % de las veces se salta un posadero.
  - **Posada:** 2,5–7 s al azar; al posarse **gira al azar 35–150° a un lado o al otro** (0,6 s, frenando) y luego se
    balancea un poco; al despegar se endereza hacia su rumbo en 0,4 s por el camino corto.
  - **Alas:** mientras vuela, el relleno de las alas parpadea (opacidad 0,4 ↔ 0,12, ~11 Hz). El contorno de las alas es
    el mismo trazado que el cuerpo, así que no se pueden mover por separado.
  - **Puede pasar por encima de los iconos** (decisión del HUMANO: "las moscas son molestas"), con
    `pointer-events: none`: el clic llega igualmente al icono.
  - **«Reducir movimiento»:** no se para, se calma (velocidad × 0,35, amplitudes × 0,3), como en la web.
  - **⚠ Nada de `will-change` en la mosca.** En la 6,1 (FirePro D500, Mojave) con la pantalla en modo escalado, la
    capa propia de la mosca provoca una línea intermitente en toda la pantalla (no sale en las capturas). Sin
    `will-change` desaparece. Investigación aparte en F5.3 de `docs/TAREAS.md`.

## Primer inicio (`firstboot.html`)

- Maqueta `first-boot`: fondo propio (`fondo-boot.jpg`), tarjeta blanca translúcida (62 %, `backdrop-filter: blur(6px)`)
  con el texto en D-DIN regular negro, y la mosca asomando por el borde superior de la tarjeta.
- **Animación solo con CSS, "un zumbido ligero" sin cambiar de sitio:** el cuerpo tiembla medio píxel (0,11 s) y se
  balancea ±1,2° (2,9 s); las alas parpadean (0,07 s); los 7 arcos aparecen y desaparecen escalonados (1,1 s).
  Ritmos que no coinciden para que no parezca un bucle. Con «reducir movimiento», solo el balanceo lento.
- Piezas de la mosca: ver `maquetas/piezas-de-las-moscas.jpg` (alas `.cls-1`, arcos = trazados negros 5.º–11.º;
  el `<rect class="cls-3">` sobra).

## Rendimiento (Mojave, 5,1 sin AVX)

Solo `transform` y `opacity`; nada de `filter` animado ni `will-change`; una sola mosca. Con la pestaña oculta,
Chromium para `requestAnimationFrame` y las animaciones CSS.
