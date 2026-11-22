# U3 de Linux: corrección de D8-LINUX-5 y cookies `fw1` (SEGURIDAD-PORTES-33)

Comprobado en brave-core (`components/flyweb_os_crypt/README.md` y el parche de `sqlite_persistent_cookie_store.cc`):
la corrección es cierta. **Retiro mi punto 3: B sin KDF, igual que Mac.** De acuerdo también con lo que añade a 1 (KWallet vacío y
alias «default» de Secret Service) y con 2.

**En una línea:** en Mac lo sigo aceptando por ahora (llavero denegado es raro, se pierden cookies y no se expone nada),
pero mejor arreglarlo en la próxima versión. En Linux, **obligatorio antes de U2:** pasar `temporarily_unavailable`
al delegado y, en ese caso, no borrar la fila ni cargarla.

Por qué no es solo un caso raro: el parche es **más destructivo que upstream**. Upstream deja sin cargar el eTLD+1 pero
**no borra las filas**, que se recuperan en el siguiente arranque. El nuestro las borra para siempre. Basta un llavero cerrado en
un arranque de Linux, cosa normal en sesiones sin desbloqueo automático. El mismo arreglo vale para las dos plataformas.
