# De COORDINACIÓN-36 a LOCAL-19 · PARA la 3.0.1 tal como va: se junta con la 3.0.2 en una sola versión

Decisión de Titín (09-11 ~18:20 UTC): no se publica una 3.0.1 sin lo que ya está preparado para la 3.0.2. Una sola
versión, **3.0.1, build 42**, con todo. Orden:

1. **Para la compilación en curso** (sin borrar `out/`; sirve para el incremental). No entregues nada en FS.42 todavía.
2. **Contenido** (hashes con ls-remote, 09-11 ~18:15 UTC):
   - chromium fork `seg/3.0.2` = **502e3c5b85** (encima de `seg/3.0.1` c4b1caf806: roll de V8 a 182f13107b = 15.6.75.51,
     5 `[M157]`, e49055113b, 3 arreglos de foco, VERSION .98). ANGLE, ffmpeg y PDFium, los de la 3.0.1.
   - brave-core: lo de la 3.0.1 (marca d3fae32d5b + b2-tests 148a5939c8 + b2-depfile bbfb565048 + tus aee46c5da15 y
     f4f92db833e) **+ `seg/3.0.1-parser` bee89ad8a6 + `seg/3.0.2` 0d6a771f23**. `seg/3.0.2` va sobre `seg/3.0.1`; júntalos
     (solo choca `patches/v8/FLYWEB-SECURITY.md`, que crece por arriba: quédate con los dos bloques). mjsunit de las
     tres V8 en la Ubuntu: sin caídas; 2 fallos conocidos de texto del SyntaxError en tests nuevos del parser.
   - **Cambia V8: corre `download_profiles.py --check-v8-revision`** antes de compilar.
   - **Icono «como siempre»** (Titín): el AppIcon de `Assets.car` (macOS 11–15) debe verse **idéntico al de la 2.7.0**.
     Saca las imágenes del `app.icns` de la 2.7.0 (`iconutil -c iconset`) y úsalas en `AppIcon.appiconset` en lugar de
     M1-01 con margen (`generar-assets-car.sh`, línea del `0.0977`); sube el cambio del script a softmac por PR
     `[local]`. En macOS 26 el sistema impone su forma: déjalo como está. Comprobación: Dock y Finder de la 7,1 y la 6,1,
     lado a lado con la 2.7.0.
   - **Página de sync (Ajustes → FlyWeb Sync):** la arregla MOTOR-43 (lista de dispositivos vacía, botones muertos,
     «Passwords» sin traducir). Te llegará como `git format-patch` en softmac `FlyWeb/parches/3.0.2-sync-ajustes/`.
     **No lances la compilación final hasta que te diga que el contenido está cerrado** (cuando llegue ese parche, o la
     orden de salir sin él). Mientras, puedes preparar el árbol y el incremental con lo demás.
3. **Pruebas añadidas a la lista de siempre:** las de `FlyWeb/seguridad/3.0.2/README.md` (XSLT, CAP, `navigator.hid`,
   foco, `CFBundleVersion` 198.63.42, claude.ai), las de la 3.0.1 (`navigator.install`, `TCPSocket`) y, **desde ahora
   en todas las versiones**, la página de sync: lista de dispositivos, ver código, añadir uno, abandonar la cadena (sobre
   una copia de perfil; nunca el perfil real de Titín).

Dudas, a COORDINACIÓN-36 (`session_01MwmK2gmWuLtoTHjfCXLggq`).
