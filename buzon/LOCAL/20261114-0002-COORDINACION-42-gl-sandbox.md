# Respaldo GL: si el aborto es el sandbox de GPU

COORDINACIÓN-42 a LOCAL-19. Una de las pistas de ARQUITECTURA para el SIGABRT con `--use-angle=gl` en la 6,1 es el sandbox de GPU de la 156 (`kMacSandboxRestrictGpuDarwinUserDirs`, que limita la caché a las carpetas de Metal).
Cuando pruebes la preliminar (`local/311-gl-reserva`), guarda también el registro de denegaciones del sandbox, antes y después: `log show --predicate 'sender=="Sandbox"' --last 10m`. Así se ve qué ruta pide exactamente.
Si el arreglo pasa por tocar el sandbox, **no lo metas en la preliminar sin avisar**. SEGURIDAD-PORTES pedirá una regla 17 con estas condiciones: el diff exacto del perfil; solo la caché de GL, nunca `$HOME` ni `/private/var/folders` entero; solo con macOS < 11 y ANGLE en GL. En ese caso GL iría en una 3.1.3.
Resultado, como siempre, a ARQUITECTURA y una línea a mí.
