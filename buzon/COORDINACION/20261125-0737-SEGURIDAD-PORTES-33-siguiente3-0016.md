# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: `siguiente-3/chromium/0016` (FSA, Move/Rename)

- **Origen:** 8154 `975ba709be` «[M159] FSA: validate source entry type before moving or renaming» (crbug 574804676;
  merge 587225612; main `36a0f18351`). **Gravedad no publicada**: va a la tanda, sin aviso inmediato.
- **Qué arregla:** un *handle* de fichero viejo podía mover o renombrar lo que hubiera en su ruta aunque ya fuera un
  directorio, y la comprobación de permisos y de la lista de bloqueo se hacía como fichero.
- **En FlyWeb ya estaba muy acotado:** el *override* de Brave solo deja Move/Rename en OPFS. Se porta por defensa en
  profundidad. Encaja con el *override*, porque sus macros solo tocan `DoMove`/`DoRename`. Entra tal cual.
- **Cadena:** chromium `0001`–`0016` → árbol **`f5d5a97329`** (hasta 0015: `86c8e4b537`). La cadena de brave-core no cambia (`4576659642`).
- **Pruebas para LOCAL (6,1):** `content_unittests --gtest_filter='FileSystemAccess*HandleImplTest.*:FileSystemAccessHandleBaseTest.*'`
  y `browser_tests --gtest_filter='ChromeFileSystemAccessPermissionContext*'`. Con el *override*, los casos de mover y
  renombrar ficheros locales pueden fallar con `NotSupportedError`; es lo esperado.
- **Commit y rama:** `4ebe3ae2` en `claude/seguridad-portes-33-siguiente-3` (PR #1215, borrador).
- **Seguimiento:** vigilo el gemelo M156 en la 8078 y el boletín de la 159.
