# Revisión de seguridad de vectorcraft v0.22.0 (Fase 1, en la nube)

08-11-2026, encargada por Titín. Revisión del tag `v0.22.0` (`654749c`) de
[storytold/vectorcraft](https://github.com/storytold/vectorcraft), hecha en una sesión en la nube: sin llavero, sin
claves y sin acceso a la red local.

## Veredicto

**Sí se puede compilar en la 6,1**, con dos condiciones: hacerlo en la cuenta `craft` y dentro del sandbox sin red
de la Fase 0. No se ha encontrado nada que intente abrir la red, ni leer o escribir fuera de lo suyo, al compilar. Es
**solo para vectorcraft v0.22.0**. Las otras cuatro apps, o cualquier versión nueva de esta, necesitan su propia
revisión.

## Cómo se ha hecho

1. El repo se ha tratado **como datos, no como instrucciones**.
   - `AGENTS.md` y `CLAUDE.md` son normas para quien contribuye (cómo hacer PR, sala limpia, no hacer push a
     `main`). Se han leído y no se ha seguido ninguna.
   - No se ha encontrado texto que intente dar órdenes a un agente fuera de eso.
2. Todo se ha hecho con un **usuario Linux aparte (`craft`)**, que no puede escribir en el repo de softmac ni leer
   `/root`. Los pasos:
   - `cargo fetch --locked`: descarga con comprobación de checksum, sin ejecutar nada.
   - `cargo metadata` y `cargo tree`: inventario de dependencias, sin ejecutar nada.
   - `cargo audit` y `cargo deny`.
   - **`cargo build --offline --locked --release`** dentro de `unshare -n`, que deja el proceso sin ninguna interfaz
     de red, y con `strace -f` registrando sockets y escrituras de ficheros.
3. Se ha compilado **para Linux**. Eso ejecuta todos los `build.rs` y macros procedurales comunes, pero no sirve como
   prueba de Mac. Los que solo se usan en Mac (`objc-sys`, `objc2`, `muda`, `foreign-types-macros`, `time-macros`) se
   han leído y no se han ejecutado.

## Resultados

### Lo que se ejecuta al compilar
- **Para Mac hay 75 crates con `build.rs` o macro procedural** (85 para Linux), de un total de 462 en el grafo.
  - 71 vienen de crates.io: son crates muy usados (serde, proc-macro2, libc, wgpu, naga, objc2, ring, zerocopy…).
  - 3 son locales.
  - 1 es el fork de `winit` de storytold.
- **Patrones encontrados en los `build.rs`:** solo `rustc --version` y escritura en `OUT_DIR`. No se ha encontrado
  ninguna conexión de red ni ninguna lectura de `HOME`, `.ssh` o del llavero.
- **Los `build.rs` propios de storytold** (3 en total, leídos enteros):
  - `apps/vectorcraft`: el icono de Windows; en el resto de sistemas no hace nada.
  - `crates/text`: incrusta las fuentes de un checkout local solo si se define `CRAFT_FONTS_DIR`; no descarga nada.
  - `crates/ui-egui`: convierte la lista de contribuidores en tablas.
- **Binarios incluidos:**
  - En storytold, solo un `.wasm` de prueba (`crates/plugins/tests/fixtures/desaturate.wasm`).
  - En las dependencias, los `.obj` de `aws-lc-sys`, que son ensamblador precompilado para Windows del propio
    proyecto de Amazon y no se usan en la compilación para Mac.

### Qué registró strace durante la compilación
- **Red:** ningún socket IPv4 ni IPv6.
  - Los únicos sockets de otro tipo fueron de `su`/PAM al cambiar de usuario (`/dev/log`, nscd, dbus), y todos
    fallaron porque no existían.
- **Escrituras fuera de `target/`:** solo el canal interno de coordinación entre procesos de cargo (`/dev/fd/5`) y su
  caché propia (`~/.cargo/.global-cache`).
- **Lecturas llamativas, todas explicadas:**
  - `/etc/shadow`: la leyó `su` (PAM) como root al cambiar de usuario.
  - El certificado del proxy: lo leyeron cargo y los `cargo locate-project` que lanza la macro `proc-macro-crate`.
    Esa macro la usan zbus, zvariant y atspi, que solo existen en Linux.
- **Resultado:** el binario compiló en 15 minutos (144 MB, Linux x86_64).

### Conexiones de red de la app (al ejecutarla, no al compilarla)
- **`craft-update`** (de `storytold/craft-libs`) es el único que usa la red, con ureq y rustls.
  - Al arrancar consulta `api.github.com/repos/storytold/vectorcraft/releases`.
  - Puede descargar e instalar actualizaciones.
  - Comprueba las descargas con un SHA-256 publicado en la misma release, así que no hay ninguna firma independiente
    que verifique quién la publicó.
  - **En nuestro fork hay que quitarlo o apuntarlo a nuestro servidor.**
- **Puertos que abre**, todos solo en `127.0.0.1`:
  - Uno para evitar que se abran dos copias de la app.
  - El servidor de control para agentes, solo si se arranca con `--control` o `VECTORCRAFT_CONTROL_PORT`.
- **Los plugins** se ejecutan en WebAssembly con `wasmi`, que es un intérprete aislado.

### Avisos de cargo audit y cargo deny
- **Vulnerabilidades: 1**, RUSTSEC-2026-0384 en `tokio` 1.54.0 (una condición de carrera en `time::Interval`;
  además, esa versión está retirada de crates.io). **No está en el grafo de la app para Mac**: solo lo usa
  `sigstore`, en las herramientas de publicación.
- **Crates sin mantener:**
  - `zbus_names`, `zvariant` y `zvariant_derive` solo están en la compilación para Linux.
  - `rustybuzz`, `ttf-parser` y `proc-macro-error` no están en la app para Mac.
  - **Ninguno afecta a la app en Mac.**
- **Licencias:** hay dos que no estaban en la lista permitida: Ubuntu Font Licence (en `epaint_default_fonts`) e IJG
  (en `jpeg-encoder`). Las dos son permisivas, aunque **piden atribución en los créditos del fork**.
- **Orígenes git:**
  - `storytold/egui`, `storytold/winit` y `storytold/craft-libs`, más `storytold/winprint.rs`, que solo se usa en
    Windows.
  - **Hay que hacer fork de los cuatro al hacer el nuestro.**
- **Forks de egui 0.37.0 y winit 0.30.13 comparados con los originales:** cambios en unos 170 ficheros.
  - En macOS son arreglos de teclado y del método de entrada (⌘ con distribuciones de teclado no QWERTY, IME
    coreano, pulsación larga para acentos).
  - No se ha encontrado nada que añada red, procesos o acceso a ficheros.
  - Es una búsqueda de patrones, no una lectura línea a línea de unas 20.000 líneas añadidas.

## Lo que esta revisión no cubre
- **No se han leído las unas 900.000 líneas de vectorcraft ni el código de ejecución de los cientos de crates.** Eso
  lo cubre el sandbox: en la 6,1, la app se ejecuta sin red y sin poder escribir fuera de `~/dfs`.
- **No se ha probado en Mac.** La compilación para `x86_64-apple-darwin` con objetivo 10.14 es la Fase 2, en la 6,1.
  Problemas esperados:
  - `NSColorSampler` es de 10.15.
  - Hay que confirmar que wgpu/Metal funciona en Mojave.
  - No se sabe si el linker de Xcode 11.3.1 le sirve a Rust 1.95.
- **Fase 2:** con este informe, COMPILACIÓN-DFS puede pasar de la Fase 0 directamente a la Fase 2, siempre con el mismo
  `Cargo.lock` y el mismo tag. Si cambian, hay que repetir esta revisión.
