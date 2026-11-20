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
