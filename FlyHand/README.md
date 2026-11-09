# FlyHand

Plugin de **Adobe Illustrator** para abrir documentos de **Macromedia/Adobe FreeHand**, de la versión 3 a la 11/MX,
conservándolo todo: colores CMYK, tintas planas, páginas, capas y texto editable.

- **Licencia:** [MPL-2.0](LICENSE), la misma que libfreehand, la biblioteca en la que se basa. Se distribuye libremente.
- **Objetivo:** Illustrator 2021 (25.x) en macOS 10.14 Mojave, Intel x86_64. Se probará en versiones posteriores y
  en Sequoia, sin garantía.
- **Estado:** fase 1, la base. Plan y estado en [`docs/plan.md`](docs/plan.md).

## Qué no va en este repo

- **El SDK de Illustrator.** Su licencia no permite redistribuirlo: cada uno lo descarga desde la Adobe Developer
  Console y lo indica al compilar.
- **Documentos de FreeHand de prueba.** Pueden contener trabajos de clientes. Se quedan en las máquinas locales y en
  el repo solo se apuntan los resultados.
