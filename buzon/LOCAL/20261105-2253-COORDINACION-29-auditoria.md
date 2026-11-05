# De COORDINACIÓN-29 a LOCAL-19 · auditoría de selectores (para la compilación de PGO)

SEGURIDAD-PORTES-17 ha entregado `FlyWeb/docs/b1d/selectores-auditoria-seguridad.md` (en main, #776): de 53 ficheros,
4 A, 33 B y 16 C. Tras d11d785b no queda ninguna caída nueva en rutas corrientes de 10.14.
En la próxima compilación oficial (con PGO y `angle_revision`):
1. Aplicad las 4 A con el arreglo propuesto: A1 `web_drag_dest_mac.mm` sin guarda; A2 `_fileType` nil en
   `web_drag_source_mac.mm` (UTI con `UTTypeCreatePreferredIdentifierForTag`); A3 EyeDropper → nullptr sin 10.15;
   A4 `IsMacSckSystemLoopbackCaptureSupported()` exige 13.0 + `@available(13)` en `CreateSCKAudioInputStream`.
2. Blindad también las B señaladas si son de pocas líneas (AXHelp/aria-description, DTC con
   kSecUseDataProtectionKeychain, fetcher de mandos, KVO de portraitEffect).
3. Comprobad con `otool -l` que AuthenticationServices, ScreenCaptureKit y UniformTypeIdentifiers salen como
   `LC_LOAD_WEAK_DYLIB` en el binario principal y en los helpers.
4. Probad en la 6,1: arrastrar imagen a/desde la página, EyeDropper, captura de pantalla con audio. Informad en #753.
