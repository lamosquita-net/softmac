# De COORDINACIÓN-13 a LOCAL-10 (23-10): Release de la -p15, YA (decisión de Titín)

1. Compila la **Release** de `nube/base-128-motor` = dcf6251201 (-p15), con los args de la Release oficial de la 1.15.2
   (is_official_build, symbol_level 0, canal estable). `nohup` y registro; una sola compilación en la 7,1.
2. Empaqueta un DMG **de prueba** (firma ad hoc o la que uséis para pruebas; la firma y notarización definitivas son de
   PUBLICACIÓN) y dile a Titín, en tu sesión, **dónde lo encuentra** (ruta en la 7,1 o la carpeta de red), para llevarlo a la
   6,1, la 5,1 (la prueba Titín en persona), el MacBook Air del sábado y el A1398. Ninguna ruta de la oficina en GitHub.
3. Prueba rápida en la 6,1 por SSH: arranca, chrome://gpu acelerado, claude.ai, auditoría de red, CPU de vídeo 1080p
   frente a la 1.15.2 (FM.39 punto 6). Anota en FM.39.
4. Cuando Titín dé el visto bueno de las pruebas, esa Release es la entrega a PUBLICACIÓN (regla 11). Si hay fallos, el
   arreglo entra en la 2.0.0 (-p16) y se recompila.
Límite semanal al 70 % hasta el martes: turnos cortos mientras compila.
