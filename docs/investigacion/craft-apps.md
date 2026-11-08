# Apps «Craft» de ArtCraft (storytold) como base para forks propios

Investigación del 08-11-2026, encargada por Titín. Está hecha leyendo el código de los repos clonados y las fuentes
publicadas. **No se ha compilado ni ejecutado nada.** Lo que falta verificar está marcado como pendiente.

## Qué son

- La organización [`storytold`](https://github.com/storytold) es de ArtCraft, de Brandon Thomas
  ([`echelon`](https://github.com/echelon), fundador de Storyteller.ai y FakeYou). Las apps «Craft» son gratuitas.
  El negocio está en el estudio ArtCraft, con créditos para modelos de IA en la nube.
- Interesan cinco apps. Todas están escritas en Rust, con interfaz egui y gráficos con wgpu (Metal en macOS):

| Repo | Imita a | Etapa (según ellos) | Líneas de Rust | Última versión (08-11) |
|---|---|---|---|---|
| [photocraft](https://github.com/storytold/photocraft) | Photoshop (PSD) | alpha | ~950.000 | v0.21.0 |
| [vectorcraft](https://github.com/storytold/vectorcraft) | Illustrator (.ai) | alpha | ~900.000 | v0.22.0 |
| [pdfcraft](https://github.com/storytold/pdfcraft) | Acrobat Pro | alpha | ~640.000 | v0.19.0 |
| [filmcraft](https://github.com/storytold/filmcraft) | Premiere Pro | alpha | ~470.000 | v0.18.0 |
| [designcraft](https://github.com/storytold/designcraft) | InDesign (.indd vía IDML) | pre-alpha | ~310.000 | v0.18.0 |

- **Casi todo el código lo ha escrito IA.** Los primeros commits son del 30-09/01-10-2026 y en cinco semanas suman
  unos 3,3 millones de líneas y miles de PR. Sus reglas comunes (`AGENTS.md`, regla 15) prohíben indicar que una PR
  la ha escrito un agente.
- **A favor:** usan Rust sin `unsafe` y con reglas de «no crash», hacen fuzzing de los parsers y dicen trabajar en
  sala limpia, sin copiar código de Adobe (esto lo afirman ellos y nadie lo ha comprobado). En una búsqueda de
  clientes HTTP y URLs no se ha encontrado telemetría. Solo filmcraft descarga modelos de Hugging Face (Whisper y
  Kokoro).
- Los porcentajes de «listo para trabajo real» y las horas que dicen que faltan los estiman ellos mismos.

## Planteamiento decidido por Titín (08-11)

Hacer un fork con **marca propia**, partiendo de una versión concreta y **sin seguir su ritmo**. Si el proyecto
original se para o cambia de rumbo, seguimos nosotros.

### Requisitos legales del fork
- Licencia MIT **o** Apache-2.0, a elegir. Hay que conservar `LICENSE-*` y `NOTICE`, y avisar de los ficheros
  modificados (Apache-2.0 §4b).
- **Quitar su marca**: «ArtCraft», «*Craft», los iconos, `getartcraft.com`, Discord y el bundle id `ai.storyteller.*`.
  Apache no da derecho a usar sus marcas (§6). En nuestras apps no deben aparecer las marcas de Adobe.
- Leer formatos ajenos es legal en la UE. Según el TJUE (SAS Institute v WPL, C-406/12), ni las funciones de un
  programa ni sus formatos de fichero están protegidos por derechos de autor. La Directiva 2009/24/CE (art. 6)
  permite descompilar para lograr interoperabilidad.
- El código generado por IA sin aportación humana tiene poca protección de derechos de autor (Thaler v. Perlmutter,
  D.C. Cir. 2025; informe de la US Copyright Office de 2025, parte 2; en la UE, la originalidad exige creación
  intelectual humana, Infopaq C-5/08). **Para usarlo no nos afecta.** Pero lo que no aportemos nosotros a mano
  tampoco quedará bien protegido frente a quien lo copie.

### Requisitos técnicos del fork
- **Hay que congelar también sus dependencias.** Las cinco apps dependen por git, con un `rev` fijado, de repos de
  `storytold`: `craft-libs`, **sus forks de `egui` y `winit`** e `indd-utils` (designcraft). Al hacer el fork hay que
  hacer también el de estos repos y apuntar `Cargo.toml` a nuestras copias. Si no, un repo borrado o un
  `push --force` nos deja sin poder compilar.
- Los arreglos que hagan ellos después ya no nos llegan solos: hay que traerlos uno a uno, cogiendo commits sueltos.
- **Cuándo hacer el fork:** cuando lleguen a beta y el ritmo de commits baje. Mientras tanto, solo seguimiento y
  pruebas de compilación.

## Mojave (10.14, Intel)

- El mínimo de macOS 11.0 lo fija el empaquetado (`packaging/macos/package.sh:38` y `Info.plist.in`), seguramente
  por el binario universal (arm64 exige 11). Rust 1.95, que es su `rust-version`, sigue generando código para
  macOS 10.12 o superior en x86_64.
- En vectorcraft hay **una API de 10.15**: `NSColorSampler` (`apps/vectorcraft/src/mac_screen_color.rs`, «tomar
  color de la pantalla»). Solo se usa al llamar a esa función, así que basta con un parche pequeño. La búsqueda
  estática no ha encontrado más, pero es limitada.
- **Pendiente:** saber si wgpu 30 y su fork de winit funcionan en 10.14 y con las GPU de la 5,1. Solo se sabrá
  compilando y arrancando en la máquina. Es la primera tarea de LOCAL-CRAFT (abajo).
- Rust se ejecuta en Mojave, así que **la 6,1 también podría compilar** (más despacio, con Xcode 11.3.1). La primera
  prueba se hace en la 7,1 por velocidad y la segunda, compilando en la propia 6,1.

## Filtro de FreeHand

- Hay ingeniería inversa ya hecha: **libfreehand** (Document Liberation Project; la usan LibreOffice e Inkscape).
  Tiene licencia MPL-2.0, unas 7.500 líneas de C++ y sigue mantenida: la versión 0.1.4, del 15-09-2026, trae
  arreglos de seguridad de memoria. Lee de **FreeHand 3 a la 11/MX** (cabeceras `FH3` y `AGD`), con capas, mezclas,
  envolventes, símbolos, páginas maestras, texto en trazado, flechas y patrones.
- Limitaciones vistas en el código:
  - **Todo el documento sale en una sola página** (`src/lib/FHCollector.cpp:1315`).
  - Algunos rellenos y recortes salen como SVG incrustado (`FHCollector.cpp:985–993`).
  - Es un importador de solo lectura (librevenge → SVG/ODG).
- **Plan:** portarla a Rust como crate propio (los ficheros portados siguen bajo MPL-2.0, en su propio crate) y
  recuperar la separación de páginas. **No se porta FreeHand en sí**: su código es de Adobe y el art. 6 de la
  directiva solo cubre la interoperabilidad.
- **Banco de pruebas:** Titín tiene ficheros de FreeHand 3.1 a 11 y FreeHand 11 en el G5 (PPC) como referencia
  visual. **Los ficheros no van al repo**, que es público y puede contener trabajos de clientes o datos personales:
  se quedan en la red local y en el repo solo se apuntan sus resultados (versión, número de páginas, «correcto o no»).

## Siguientes pasos

1. **LOCAL-CRAFT** (nuevo agente local de la 7,1; texto de arranque en `docs/ARRANQUE.md`): compilar vectorcraft solo
   para x86_64 con `MACOSX_DEPLOYMENT_TARGET=10.14`, arrancarla en la 6,1 y la 5,1 y anotar qué falla.
2. Después, probar a compilar en la propia 6,1.
3. Crate `freehand` en Rust a partir de libfreehand, probado contra el banco de pruebas privado.
