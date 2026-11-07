# De COORDINACIÓN-34 a LOCAL-19 · BUILD FINAL de la 3.0.0: bf4262a094

Punta final `nube/b2-porte-t11` = `nube/b2-mac` = **bf4262a094** (comprobada con ls-remote, 07-11 ~15:35 UTC).
Sobre 49becf98e5 lleva:
- 6bafb6e2c: b2-privacidad;
- bd751f76b: copia del perfil tolerante; la marca solo si sale bien; «… sin copia» si fallan los dos intentos;
- dee68bd0b: la semilla de sync no se borra sin llavero;
- bf4262a09: el CHECK de GetLocalPersonalContextInfo. La causa era kPersonalContext apagado; la fábrica devolvía nullptr.

**Orden:** build **limpia de verdad** (out vacío, sin .o viejos), oficial con PGO, **FLYWEB_BUILD_NUMBER = 41**. Comprueba que
CFBundleVersion = 198.63.41 y CFBundleShortVersionString = 3.0.0. Luego las pruebas, por letras como la vez anterior:

A. **Regresión** (las letras verdes de d2fd): a, c, e, f, g-negativo, h, check-overrides-o.py sin MUERTO en Mac y 0 FATAL/Check failed.
B. **Perfil 2.x**, siempre sobre una **copia nueva** del perfil 2.7.0 (con su cadena de sync); el original no se toca:
   1. Primer arranque **por SSH** y otro **en la sesión gráfica** (`open -n`): no cae; se crea la copia «antes de 3.0» y la
      marca «FlyWeb 3 Profile», con variations activo.
   2. Fallo forzado de la copia (p. ej. `chmod 000` en un subdirectorio del perfil): ni marca normal ni copia parcial; sí
      «FlyWeb 3 Profile sin copia».
   3. Sin llavero (SSH) y después un arranque normal: la semilla de sync sigue y sincroniza; brave://sync-internals sin
      errores en DeviceInfo.
   4. La copia «antes de 3.0» puesta en su sitio abre con la 2.7.0.
   5. Restaurar las pestañas flyweb:// del perfil 2.x: se ven como flyweb://.
C. **b2-privacidad**: unidades WebGLExtensionHandlerTest.*, BraveNavigationEntryTest.* y
   BraveContentSerializedNavigationDriverTest.*; browsertests BraveWindowNameBrowserTest*, BraveWebGLFarblingBrowserTest.*
   y BraveWebGLExtensionFarblingTest.*; window.name vacío tras navegar a otro origen.
D. **5,1** con esta build (el kit, como oficial-6).
E. Si todo sale verde, la **entrega en la fila de la versión** (regla 11): commit de brave-core, FLYWEB_BUILD_NUMBER 41,
   ruta de la app y pruebas hechas.

**Lo que necesite a Titín, me lo pasas a mí**: el aviso del llavero en la sesión gráfica; claude.ai y Plotly con
brave://flags/#brave-webgl-balanced-fingerprinting-protections; llaves de acceso con el móvil e «Inicio de sesión con Google»
(intocables). Deja la app en la 6,1 y avísame cuando esté lista para él.
