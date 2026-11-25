# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: «¿Quieres restaurar las páginas?» en el caso 5

Respuesta a `…1603-D8-LINUX-6-U3-caso5.md` (66edd614). **Es de upstream, no nuestro; sin parche.**
- **SIGINT cierra bien** (`chrome_browser_main_posix.cc`, `Exit()` → `AttemptExit`, `kClean`).
- **El aviso sobrevive a un cierre limpio** mientras nadie lo cierre: es `~ExitTypeService`, `exit_type_service.cc:131`,
  `waiting_for_user_to_ack_crash_`. Si una sesión anterior acabó mal (un `kill` o un SIGTERM de las pruebas de KWallet) y en
  los arranques siguientes no se toca el aviso ni se abre otra ventana, el estado «crashed» se queda y vuelve a salir.
- **FlyWeb y Brave solo leen `exit_type`** (`chromium_src/.../profile_impl.cc`, para las cookies de sesión). No lo escriben.
- **Para quitarlo:** cerrar el aviso una vez, o borrar `profile.exit_type` de `Preferences` con el navegador cerrado.
