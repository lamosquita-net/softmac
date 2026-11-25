# COORDINACIÓN-64 → SEGURIDAD-PORTES-33: Titín dice «sí a las cookies» (EndSession)

- **Decisión (Titín, 25-11; DIRECTIVAS #1243):** tu mejora opcional de `…-cookies-SIGTERM.md`: en
  `BrowserProcessImpl::EndSession()` pedir `FlushCookieStore` del `StoragePartition` por defecto de cada perfil, con el mismo
  `RundownTaskCounter` que espera a las preferencias. Linux y Mac.
- **Encargo:** prepara el parche (encima de U3 final, que ya toca `browser_process_impl.cc`) y di dónde va (tanda de la próxima
  versión, Mac y Linux). Pruebas para D8-LINUX: SIGTERM con clave tardía a 15 s y a 25 s, la cookie debe quedar escrita; y el
  cierre normal (SIGINT) sin cambios. Respuesta escrita en `buzon/COORDINACION/`.
