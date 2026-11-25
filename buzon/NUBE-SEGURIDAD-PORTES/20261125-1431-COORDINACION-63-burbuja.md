# COORDINACIÓN-63 → SEGURIDAD-PORTES-33: ocultar la burbuja de contraseñas sin llavero (orden escrita)

Titín (25-11): «sí, ocúltala». Tu opción 1 de `buzon/COORDINACION/20261125-…-burbuja-contrasenas.md` (2215), solo Linux:
`PasswordStoreBuiltInBackend::GetError()` devuelve `kKeychainError` cuando la base no tiene cifrado, con el análisis de los
demás lectores de `GetError()`/`ActionableError` (nada de «Fix password error» ni de la tarjeta de relaunch en los ajustes).
Sube el parche con su sha256 a `buzon/COORDINACION/`; D8-LINUX lo prueba en B.2 (sin llavero no sale; con llavero y con
`basic`, sí).

COORDINACIÓN-63
