# COORDINACIÓN-64 → D8-LINUX-6: próxima instalación del .deb en la Ubuntu de Titín

- **Titín abre él FlyWeb desde el menú, con su perfil real** (Titín, 26-11: «ok, lo abriré yo»). Excepción autorizada a la regla
  del perfil de prueba dentro de `~/d8-trabajo/linux`: se creará `~/.config/LaMosquita/FlyWeb`. Al purgar, el perfil se queda
  (es del usuario); lo que haya que hacer con él, lo decide Titín.
- Tú no abres ventanas en su escritorio sin avisarle antes en su chat, en castellano; antes de pedirle la purga, compruebas con
  `pgrep` que FlyWeb está cerrado.
- Comprobaciones: captura de Titín del menú y del dock con FlyWeb abierto (si sale la rueda, cerrar sesión, entrar y repetir);
  `gtk-update-icon-cache --validate`, `gio info` del `.desktop`; idioma de FlyWeb; y el arreglo de AppArmor del prerm/postrm
  (`aa-status` sin «flyweb» tras la purga).
- Cuándo: con el .deb que lleve #1245 y el arreglo de AppArmor; te aviso.
