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
| 1 | Base: fork de libfreehand en `FlyHand/`, compilado para x86_64 y 10.14; herramienta de línea de comandos que vuelca el modelo; banco de pruebas privado con los documentos de Titín (de la 3.1 a la 11) y referencia de CS4 y FreeHand 11 en el G5 | en curso: bibliotecas y herramientas compiladas en la 6,1; ejemplo del SDK compilado; 3 documentos probados (09-11) |
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

## Encargo de la fase 1 (FLYHAND-LOCAL, 09-11)

- **Agente:** FLYHAND-LOCAL. Es la sesión local con puente que se abrió como «Compilación design flysuit». Corre en la
  7,1 y **compila en la 6,1 (Mojave, Xcode 11.3.1)** por SSH, con la cuenta `craft`.
- **SDK de Illustrator 2021 v5:** en la 6,1, en `/Users/Shared/SDK/Illustrator-2021-v5/`. Es disco local: no está
  en el Samba ni en el repo, y Titín y `craft` lo pueden leer. El zip original se guarda aparte, como copia de
  seguridad privada.
- **Documentos de prueba:** en la 6,1, en `~craft/flyhand/corpus/`, con permisos 700. Junto a cada documento va el PDF
  de referencia exportado desde CS4 o FreeHand 11 en el G5.

Qué hay que hacer:
1. Compilar libfreehand 0.1.4 (commit `85ac573`), librevenge 0.0.5 y lcms2 como **bibliotecas estáticas** x86_64 con
   `MACOSX_DEPLOYMENT_TARGET=10.14`. El plugin no puede depender de bibliotecas dinámicas externas.
   - De ICU, libfreehand solo usa las macros de `unicode/utf8.h` y `unicode/utf16.h`, que son cabeceras sin
     biblioteca (comprobado en la nube el 09-11). Basta con las cabeceras de ICU: no hay que compilarla ni enlazarla.
2. Compilar `fh2raw` y `fh2svg` y pasarlos por los documentos de prueba. Por cada documento se anota, **sin nombres
   de cliente**:
   - versión de FreeHand y número de páginas;
   - si lo abre o no y qué avisos da;
   - qué usa: tintas planas, texto, mezclas…
3. Compilar un ejemplo del SDK con Xcode 11.3.1 para comprobar que la cadena de compilación sirve, y que Titín
   compruebe que carga en Illustrator 25.1 en la 6,1. Si el SDK de 2021 exige un Xcode más nuevo, se anota y se
   propone compilar en la 7,1 con un SDK de macOS antiguo.
4. Entregar la tabla de resultados en este fichero, por PR.

## Resultados de la fase 1 (FLYHAND-LOCAL, 09-11, en la 6,1)

### Compilación

Guiones en [`scripts/`](../scripts/): `compilar-libs-61.sh` (las tres bibliotecas y las herramientas) y `corpus-61.sh`
(pasada por los documentos de prueba). Se ejecutan en la 6,1 con la cuenta `craft`, en `~/flyhand/`, con `nice`, y
no arrancan si hay un semáforo de LOCAL (`/tmp/local*-61-en-uso`).

| Pieza | Versión | Resultado |
|---|---|---|
| lcms2 | 2.16 | `liblcms2.a`, sin jpeg, tiff ni zlib |
| librevenge | 0.0.5 | `librevenge-0.0.a`, `-stream`, `-generators` |
| libfreehand | 0.1.4 (`85ac573`) | `libfreehand-0.1.a`, `fh2raw`, `fh2svg`, `fh2text` |
| Boost | 1.83.0 | solo cabeceras |
| ICU | 74.2 | solo `common/unicode/*.h`, sin biblioteca |
| zlib | la del sistema | `/usr/lib/libz.1.dylib` |

- Todo sale x86_64 con `minos 10.14`, compilado con el SDK 10.15 de Xcode 11.3.1 y sin instrucciones AVX (`ymm`: 0).
  Las herramientas solo enlazan bibliotecas del sistema (`libSystem`, `libc++` y `libz`).
- En la 6,1 hay Xcode 11.3.1, pero `xcode-select` apunta a las Command Line Tools: se usa
  `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`, sin cambiar la configuración del sistema.
- La 6,1 no tiene autoconf, automake ni pkg-config:
  - El `configure` de libfreehand (que viene de git) se genera en la 7,1 con `autoreconf -fi` y se copia. Tras copiarlo,
    hay que ordenar las fechas (`aclocal.m4` → `configure` → `Makefile.in`) para que make no intente regenerarlo.
  - Las dependencias se pasan con las variables `*_CFLAGS`/`*_LIBS` de `PKG_CHECK_MODULES`, sin pkg-config.
- Las fuentes se descargan en la 7,1 de sus sitios oficiales y van a la 6,1 por SSH.

### SDK de Illustrator 2021 (Build 492)

- **Compila con Xcode 11.3.1 en Mojave**: no hace falta pasar a la 7,1. El ejemplo `TextFileFormat` (un plugin de
  formato de fichero, como será FlyHand) sale con `BUILD SUCCEEDED` y un solo aviso (`auto_ptr` obsoleto, del propio
  ejemplo).
- Los proyectos del SDK piden el SDK 10.15 y `MACOSX_DEPLOYMENT_TARGET = 10.15`. Con
  `MACOSX_DEPLOYMENT_TARGET=10.14` el `.aip` sale con `minos 10.14`, x86_64 y sin AVX.
- Las configuraciones se llaman `debug` y `release`, en minúscula: con `-configuration Release`, xcodebuild compila
  la de depuración sin avisar.
- **El SDK «2021 v5» es el de Illustrator 25.4** (`kPluginInterfaceVersion25041`) y en la 6,1 hay la **25.1**.
  Compilado tal cual, el ejemplo da «Error al cargar plugin». La causa son las versiones de las suites, no Xcode ni
  macOS: el binario carga con `dlopen` en Mojave.
- Con una variante de diagnóstico, que apunta cada suite y, si falta, usa la versión que tenga la 25.1, el ejemplo
  **carga en Illustrator 25.1** (lo ha comprobado Titín el 09-11). De las 105 suites que pide, solo cambian dos:

  | Suite | SDK 25.4 | Illustrator 25.1 |
  |---|---|---|
  | AI User Suite | 1019 | 1018 |
  | ATE GlyphRun Suite | 2 | 1 |

- Para FlyHand: cada suite se pide en la versión de la 25.1, con un fichero de versiones propio en vez de las
  constantes del SDK, y así carga en la 25.1 y en las posteriores. Antes de la fase 2, la misma variante de
  diagnóstico debe probar también las suites que FlyHand usará: muestras, colores personalizados, mesas de trabajo,
  capas, estilos de trazado y texto.

### Banco de pruebas

Tres documentos de momento; Titín añadirá más cuando compruebe que están sanos (algunos de la red perdieron la
extensión y el resource fork). Todavía no hay PDF de referencia del G5.

| Doc | FreeHand | Páginas (PDF ref.) | fh2raw | fh2svg | Avisos | Páginas que saca | Trazados | Textos | Tipos de registro del diccionario |
|---|---|---|---|---|---|---|---|---|---|
| doc01 | 11/MX | — | abre | abre (43 KB) | 0 | 1 | 57 | 0 | tintas planas, tintes, proceso, mezclas, símbolos, degradados, lentes, patrones, efectos |
| doc02 | 11/MX | — | abre | abre (31 KB) | 0 | 1 | 38 | 0 | tintas planas, tintes, proceso, mezclas, símbolos, degradados, lentes, patrones, efectos |
| doc03 | 6 | — | abre | abre (88 KB) | 0 | 1 | 128 | 101 | tintas planas, tintes, proceso, texto, imágenes |

- La versión sale de la cabecera (`AGD` + versión, o `FH3`).
- La última columna son los tipos de registro que el documento declara en su diccionario. Indica qué puede contener,
  no cuánto usa. En los dos de la 11 hay que confirmar con el PDF de referencia si de verdad llevan lentes y efectos.
- Los tres abren sin avisos, pero todos salen en **una sola página**, y el color queda en RGB, como ya se sabía. Es lo
  que hay que ampliar en las fases 3 y 4.
