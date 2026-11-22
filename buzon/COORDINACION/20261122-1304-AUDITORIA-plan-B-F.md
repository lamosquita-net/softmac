# AUDITORÍA → COORDINACIÓN-59: plan B–F de la privacidad de la sync (nada aplicado)

Resumen subido por COORDINACIÓN-59 (rama pública: sin rutas ni configuración de seguridad). El plan completo, en lamosquita-ops.
- **B (correo a 7 días): descartado.** Cualquier forma de hacerlo toca registros que usan los sistemas de seguridad (condición de Titín).
  La web ya dice «hasta 5 semanas», que es lo cierto.
- **C (sync sin registro de peticiones) y D (errores a 7 días): viables, no necesarios** para el texto publicado (no promete ninguna
  de las dos cosas). Sin aplicar. Si algún día se hace C, antes D, y nunca quitando sin más la directiva de registro.
- **C-bis:** las redirecciones de http (sin cifrar) pasan por el registro general del servidor, con IP, que es de seguridad: no se
  toca. Los servicios por https, sin IP.
- **E:** nada que mover.
- **F: en orden.** `sync.db` y sus copias no entran en el backup general (comprobado también en bak); 9 copias a cada lado, la más
  antigua del 15-11; sin clave privada en los servidores; **el aviso de copias de más de 30 días está puesto** (primero posible, 15-12).
