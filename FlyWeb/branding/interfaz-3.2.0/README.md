# Interfaz de la 3.2.0: diseño de Titín (19-11-2026)

Maquetas de Titín en Illustrator, para la 3.2.0. Las implementa MOTOR. Las dudas de diseño van a Titín a través de
COORDINACIÓN.

## Maquetas
- `maqueta-claro.png`: modo claro.
- `maqueta-claro-url-pulsada.png`: modo claro con la barra de URL activa (brillo interior en lugar del anillo de color).
  Es la única diferencia con la anterior.
- `maqueta-oscuro.png`: modo oscuro.

## Colores

| Elemento | Claro | Oscuro |
|---|---|---|
| Pestaña activa **y** barra de iconos y URL (el mismo color exacto) | `#F4F5F6` | `#656666` |
| Barra superior, donde van las pestañas inactivas | `#E3E3E2` | `#4D4D4C` |
| Fondo de la URL | `#FFFFFF` | `#FFFFFF` |

## Pestañas
- **El mismo tamaño que ahora** (alto y ancho de Chromium sin tocar).
- **Esquinas superiores redondeadas, con un radio menor que el actual.** La unión con la barra de iconos es **recta**,
  sin las curvas hacia fuera que tiene Chromium en la base. La pestaña activa y la barra forman una sola pieza del mismo
  color.
- **Pestañas inactivas:** sin fondo (el color de la barra superior), separadas por una línea fina, como ahora.
- El radio se saca de la maqueta en proporción al alto de la pestaña. Titín no puede dar píxeles porque la pantalla
  Retina interpola. Chromium trabaja en puntos (dip), no en píxeles de pantalla. Se ajusta en pruebas con Titín.

## Barra de URL al pulsarla
- Sin el anillo de color de foco. En su lugar, un **sombreado interior iluminado, gris y muy suave**, de unos 2 puntos.
- El valor final (color, opacidad, difuminado) se ajusta viéndolo en pruebas con Titín.

## Iconos (`iconos/`)
SVG de Titín, de un solo color (`#1d1d1b`), en contornos. Hay que pasarlos al formato vectorial de Chromium
(`.icon`) y adaptarlos a la rejilla de 20 dip (16 dip donde corresponda). El color lo pone el tema; el de los SVG no
cuenta.

| Fichero | Uso |
|---|---|
| `ico-atras.svg` | Atrás (adelante = el mismo, en espejo, salvo que Titín mande otro) |
| `ico-apps.svg` | Aplicaciones (barra de marcadores) |
| `ico-carpeta-marcadores.svg` | Carpeta de marcadores |
| `ico-buscar-pestanas.svg` | Buscar pestañas (⌄ de la barra de pestañas) |
| `ico-cerrar-pestana.svg` | Cerrar pestaña (×) |

**Faltan** (Titín los está exportando; ver el estado en la fila de MOTOR de `docs/TAREAS.md`): recargar, detener,
estrella vacía y llena, extensiones, descargas, menú (⋮), nueva pestaña (+), «»» de marcadores, «Personalizar» de la
nueva pestaña y la mosca del logo de la nueva pestaña. **El escudo de Shields se queda como está**, si ni Brave ni
Google lo han cambiado.
