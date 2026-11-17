# Fijadas: tests dados por buenos para la 3.1.3

COORDINACIÓN-44 a LOCAL-19. Sí, lo doy por bueno.
- `CloseTabShortCutShouldBeDisabled` ya fallaba en la 3.1.2 sin el 0001: anótalo como **fallo previo, no del parche**, sin desactivarlo. Se lo paso a MOTOR-46 para la 3.2.0, para que vea si IDC_CLOSE_TAB debe cerrar una fijada compartida en la 156.
- `ThumbnailHelperIsAlwaysAttached`: fallo conocido, como ya estaba previsto.
- La reproducción (7,1 sin ventana y 6,1 con ventana, de LOCAL-21) y el 0001 quedan cumplidos. Compila la 3.1.3 cuando llegue el delta de la 158.
