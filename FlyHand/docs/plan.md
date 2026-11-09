# FlyHand: plan y estado

Decidido por Titín (09-11-2026): plugin libre (MPL-2.0) que abre documentos de FreeHand en Illustrator 25.1, **con
todo**: tintas, colores, páginas, texto editable… Se hará poco a poco. Contexto en
[`docs/investigacion/craft-apps.md`](../../docs/investigacion/craft-apps.md) (sección «Filtro de FreeHand»).

## Arquitectura

```
.fh3 … .fh11 / MX ──► lector de libfreehand (fork propio, MPL-2.0)
                          │  modelo con CMYK, tintas planas, páginas, capas y texto
                          ▼
                     colector de FlyHand ──► API del SDK de Illustrator 2021
                                              (trazados, muestras, mesas de trabajo, capas, marcos de texto)
```

- **No se pasa por SVG.** SVG solo trabaja en RGB y perdería CMYK y tintas planas. El plugin crea los objetos
  directamente con la API del SDK de Illustrator.
- **Formato de plugin:** se registra como formato de fichero, de modo que FreeHand 3–11 aparece en Archivo → Abrir.
- **Compilación:** x86_64, `MACOSX_DEPLOYMENT_TARGET=10.14`. Para distribuirlo, binario universal con arm64 y firmado
  y notarizado con el Team ID de lamosquita.
- **SDK de Illustrator 2021 (v5, julio):** está en la Mac de Titín, fuera del repo. El plugin debería cargar también
  en versiones posteriores, pero Adobe no lo garantiza y hay que probarlo en cada una.

## Hallazgos sobre libfreehand (0.1.4, 15-09-2026)

- Lee de FreeHand 3 a la 11/MX (cabeceras `FH3` y `AGD`): capas, mezclas, envolventes, símbolos, páginas maestras,
  texto en trazado, flechas y patrones. Tiene unas 7.500 líneas de C++.
- **Pierde el color de imprenta.**
  - `FHParser::readProcessColor` lee CMYK pero lo guarda como `FHRGBColor`.
  - `readSpotColor` no guarda el nombre de la tinta.
  - Todo sale como `draw:fill-color` en hexadecimal RGB.
  - **Hay que ampliar el lector** para conservar CMYK, nombre de tinta, tipo de tinta y tintes.
- **Todo el documento sale en una sola página** (`FHCollector.cpp`, una sola `startPage`). Los datos de las páginas
  están en el fichero; hay que recogerlos para crear las mesas de trabajo.
- Algunos rellenos y recortes salen como SVG incrustado: en FlyHand se convertirán en objetos de Illustrator.
- Compila en Linux sin problemas (probado el 09-11 en la nube, sin red y con un usuario aislado), con librevenge 0.0.5,
  lcms2, ICU, zlib y Boost.
- **No hay ficheros de prueba públicos**: la carpeta de libfreehand en los tests de LibreOffice está vacía. Las pruebas
  se hacen con los documentos de Titín, en local.

## Referencia para comparar

- **Illustrator CS4 abre documentos de FreeHand**: de la 10 y la MX con todas las opciones, y de la 7 y la 8 con
  menos. Cada página la convierte en una mesa de trabajo
  ([guía de migración de Adobe](https://www.manualowl.com/m/Adobe/65010248/Manual/338117?page=9)). Titín tiene CS4 en el
  G5 (PPC).
- El resultado de CS4 y el de FreeHand 11 en el G5 sirven de «verdad» para comparar con FlyHand, documento a documento.
- Existe un plugin comercial (Tensai) que conecta el antiguo módulo de Adobe con versiones posteriores a CS6. FlyHand
  es libre y no depende de código de Adobe.

## Fases

| Fase | Qué | Estado |
|---|---|---|
| 1 | Base: fork de libfreehand en `FlyHand/`, compilado para x86_64 y 10.14; herramienta de línea de comandos que vuelca el modelo; banco de pruebas privado con los documentos de Titín (de la 3.1 a la 11) y referencia de CS4 y FreeHand 11 en el G5 | en curso: libfreehand compila (nube, 09-11) |
| 2 | Plugin mínimo: Archivo → Abrir con trazados, rellenos y trazos en CMYK | — |
| 3 | Color: proceso, tintas planas como muestras globales, tintes y RGB | — |
| 4 | Páginas como mesas de trabajo, y capas | — |
| 5 | Texto editable: marcos, enlaces entre marcos, estilos de carácter y párrafo, texto en trazado | — |
| 6 | El resto: mezclas, envolventes, símbolos, efectos, imágenes incrustadas y enlazadas | — |

Cada mejora genérica del lector se ofrece también a libfreehand (LibreOffice).

## Banco de pruebas (privado)

Los documentos de Titín, de FreeHand 3.1 a la 11, **no se suben a GitHub**. En el repo solo se anota una tabla por
documento, sin nombres que identifiquen al cliente: versión de FreeHand, número de páginas, qué usa (tintas planas,
texto, mezclas…) y el resultado de cada fase.
