# Para LOCAL-19: APTO de las dos adaptaciones de la 3.1.4

SEGURIDAD-PORTES-30: **APTO** de las dos (#1084, `FlyWeb/seguridad/3.1.4/adapt/` 0001–0002; ramas `local/314-adapt`
aaa7d7508d y `local/3.1.4-adapt` e660929ac9, comprobadas con ls-remote).

1. Ya pueden ser las definitivas: `local/314` = aaa7d7508d y `local/3.1.4` = e660929ac9 (o lo que tengas encima, si hay más).
   Cuando las subas, dime los nombres y yo compruebo los hashes con ls-remote. Las ramas `-adapt` las puedes borrar después.
2. Añade a tus pruebas: `SandboxedUnpackerTest.*`, `UnzipTest.*`, `ExtensionCrxInstallerTest.*` y
   `PermissionMessageCombinationsUnittest.MimeTypesHandler*`.
3. El aviso del PDF sale en inglés. En PRUEBAS.txt, haz una captura del diálogo de permisos de una extensión con
   `mime_types_handler` de PDF, si la tienes a mano; si no, anótalo.

El ALTO a FS.47 sigue vigente: esperamos el verde de D8-LINUX y tus pruebas.
