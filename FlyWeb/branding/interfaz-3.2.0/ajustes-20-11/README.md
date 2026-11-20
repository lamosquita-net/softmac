# Ajustes de Titín a la interfaz 3.2.0 (20-11)

Tras revisar en la 6,1 (bt-320a/bt-320b). Maquetas: `maqueta-claro.png` y `maqueta-oscuro.png` (ventana entera, a baja
resolución: sirven para ver la idea, no para medir píxeles).

1. **Brillo interior de la URL en oscuro:** al pulsar la URL en modo oscuro no aparece el reflejo interior (en claro sí).
   Tiene que verse también en oscuro.
2. **Caja de la URL:** 2 o 3 px más baja, quitados por arriba, para que quede algo más separada de las pestañas.
3. **Hover de la pestaña inactiva:** #585959 en oscuro y #EBEBEB en claro.
4. **Título y favicon de las pestañas inactivas, más bajos** (también en las fijadas); suben a su sitio cuando la pestaña
   se activa.

Los valores de 2 y 4 van en constantes y se ajustan con Titín viendo capturas, como el radio.

## Maquetas a más resolución (20-11) y medidas

`maqueta-claro-hd.webp` y `maqueta-oscuro-hd.webp` (2000×1418). Medidas sobre ellas (px de la imagen; la caja de la URL
mide ~33 px de alto, que da la escala):

- **Favicon:** en las inactivas (también las fijadas) ocupa y=59–60…71–73; en la activa, y=54…67. Es decir, las inactivas
  van **~5–6 px de imagen más abajo** (≈ 1/6 del alto de la URL). Titín: «pocos píxeles», que no descompense los huecos
  pero que se vea que suben al activarse.
- **Hover de la inactiva:** la primera pestaña inactiva de la maqueta lo muestra: #EAEAEA en claro y #585858 en oscuro
  (Titín pidió #EBEBEB y #585959). Es el **punto medio** entre el marco (#E3E3E2 / #4D4D4C) y la pestaña activa
  (#F4F5F6 / #656666): «a mitad de camino» del fondo a la activa.
- **URL:** en claro, la caja va de y≈87 a 119 y tiene brillo interior gris en arriba y abajo (≈3 px). En oscuro, en esta
  maqueta, solo hay un borde fino más claro arriba y abajo (#AFAFAF / #ECECEC, ≈1 px).

**Aclaración de Titín:** el selector que pedía es el de **interfaz en claro / oscuro / como el sistema**, en «Aspecto»
(arreglado con el 0004). «Personalizar fuentes» se queda en «Contenido», como está.

## URL con foco (maqueta `maqueta-claro-foco-hd.webp`, 20-11)

Titín: «la caja de URL con foco sale con un flou interior oscuro»; y la caja, algo más baja, con más espacio por arriba.
Medidas sobre la maqueta (claro, misma escala que las anteriores):
- **Alto:** la caja empieza en y=90 (antes 87) y acaba igual en 119: **3 px menos, todos por arriba** (≈ 3 dip).
- **Flou interior con foco:** sombra interior gris difuminada de ~3–4 px en los cuatro lados; lo más oscuro, junto al borde,
  ≈ #DD sobre el blanco, y se desvanece hacia dentro (arriba: EF, EB, F1, FB, FF; abajo: E0, EC, F9, FD; lados: DD, EE,
  F7, FD).
- **En oscuro** tiene que verse **el mismo flou** dentro de la caja blanca (petición 1). No es un borde ni un brillo
  más fuerte.

## Desplegable de la URL (Titín, 20-11, tras revisar bt-320e)

- `maqueta-oscuro-desplegable-hd.webp`: URL con foco y el desplegable abierto, en oscuro. El desplegable tiene **el mismo
  ancho que la caja de la URL**, va pegado debajo, **sin sombra exterior**, y la fila seleccionada va en morado.
- `maqueta-claro-url-sutil.png`: la caja de la URL en claro, con una curvatura **muy sutil** en las esquinas (no píldora).
- Respuestas de Titín: también en la ventana privada (sí); el hueco actual entre la URL y la primera sugerencia le parece
  bien, pero manda la maqueta; lo de «la línea bajo el campo», que MOTOR haga una propuesta y él decide.
