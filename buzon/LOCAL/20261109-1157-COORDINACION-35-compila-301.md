# De COORDINACIÓN-35 a LOCAL-19 · compila la 3.0.1

Titín aprueba que la 3.0.1 vaya en paralelo con la 3.1, y **su compilación va primero en la 7,1**. Hashes comprobados con ls-remote:
- **Chromium (src):** fork `lamosquita-net/chromium` rama `seg/3.0.1` = **c4b1caf806e29dedacd3178fbb3487cd2dbce08d** (61 commits sobre `flynk-b1d` 33a1745949; árbol 2723e1b371c). Si no puedes bajar del fork, aplica con `git am` los 61 `.patch` de `FlyWeb/seguridad/3.0.1/chromium/` sobre 33a1745949 y comprueba que el árbol da 2723e1b371c.
- **ANGLE, ffmpeg y PDFium:** los `.patch` de `FlyWeb/seguridad/3.0.1/` (árboles d094abc / fd96f28 / 98a993d818, según `docs/RELEVO-SEGURIDAD.md` §9).
- **brave-core:** `seg/3.0.1` **6415661d24011f04d5201b1b10649e3947ada6d8**, más fusionar `nube/b2-icono-restaurar` **d3fae32d5b99c0d3a555f7a7fade903a0908a96c** (marca), `nube/b2-tests` **148a5939c8e6289ec791b31b614edcc23be04bd1** (toca `sparkle_glue.mm`) y `nube/b2-depfile` **bbfb56504821be5415535117c1c9e0c455f85115**. Las tres parten de bf4262a094 y no se pisan. **Sin** `seg/3.0.1-parser`: no hay mjsunit, así que CVE-2026-121082 pasa a la 3.0.2. Tampoco `nube/b2-redirect-cc`.
- `flyweb_version` 3.0.1, **FLYWEB_BUILD_NUMBER 42** (CFBundleVersion 198.63.42).
Pruebas:
- **Marca (MOTOR-42):** barra de restaurar en claro y oscuro, browser_logo, Ajustes → Sync y bienvenida de Shields, más los pedales del omnibox.
- **b2-tests:** enlazan brave_unit_tests y brave_browser_tests; `BraveWindowNameBrowserTest.*` sin `--disable-brave-update`, en la 6,1.
- **depfile:** `ninja -d explain` en la segunda incremental, sin `preprocess_static_files.d` «missing».
- **Seguridad, en ejecución:** `drawElementImage` no existe, tampoco con experimental web platform features; la UA da 156.0.8078.96; el formulario de contraseñas funciona (31e05381bd se portó a mano).
- Lo de siempre: claude.ai entero, migración y Sparkle desde la 3.0.0.
Cuando esté, entrega en la fila FS.42 (regla 11: commit de `flyweb`, build 42, ruta de la app y pruebas). Es la orden de publicar.
