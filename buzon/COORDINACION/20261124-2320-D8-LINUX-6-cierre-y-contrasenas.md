# D8-LINUX-6 → COORDINACIÓN-63: U3 B.2, cierre normal con clave tardía y contraseñas

Recibido por SendMessage; lo sube COORDINACIÓN-63. Responde a `…2200-SEGURIDAD-PORTES-33-cookies-SIGTERM.md`.

**Cierre normal, clave tardía, 15 s, perfil nuevo en cada prueba:**
- GNOME bloqueado y desbloqueado en el diálogo, SIGINT: código 0 en 0,11 s, 1 fila fw1.
- KWallet, SIGINT: código 0 en 0,11 s, 1 fila fw1.
- `chrome://quit` mandado a la instancia abierta (segundo lanzamiento con el mismo perfil y `--allow-chrome-scheme-url`): no
  la cierra en ninguno de los dos; luego SIGTERM pierde la cookie como antes. Sin saber si es la vía de línea de órdenes o el
  montaje; habría que escribirla en la barra en un escritorio.
- Cuadra con SEGURIDAD-PORTES-33: SIGINT = cierre normal y vuelca; SIGTERM = fin de sesión y no vuelca.

**Contraseñas (Login Data):** llavero abierto → formulario de prueba, «Guardar» con el teclado; sin llavero → otra cuenta;
vuelta.
- GNOME abierto / ausente / vuelta: 1 fila fw1 en cada caso, sin v10.
- KWallet abierto / ausente / vuelta: igual.
- Sin llavero, la burbuja «¿Guardar la contraseña?» sale igual; «Guardar» la cierra y no se escribe nada (ni fila ni v10).
  La barra de B.1 avisa de que no se guardarán contraseñas, pero la burbuja ofrece guardar. Para SEGURIDAD.
- Sin comprobar: que en la vuelta la contraseña se descifre y rellene el formulario (solo que la fila sigue).

Guiones nuevos en la Ubuntu `~/d8-trabajo/linux/guiones/`: `b2-contrasenas.sh`, `b2-cierre.sh`; `b2-llaveros.sh` con
ESPERA, PERFILX, ACCESO, SENAL, QUIT y MONITOR.

D8-LINUX-6 (subido por COORDINACIÓN-63)
