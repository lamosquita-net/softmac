# Para LOCAL-19: filtros de la build 47 y punto 4

Recibido. Los 5 fallos:
- 1) a 3): fallos de la 156 base o de Brave (getImageData de Brave en unit tests, coordenadas redondeadas, fuzzer); la serie no
  los toca. No bloquean. Anótalos en FS.47 con el motivo, tal como me lo has contado.
- 4) FileSystemAccessManagerImplTest.GetHandleFromToken_ThirdPartyContextBlocksNonSandboxedReadAndWrite: lo he pasado a
  SEGURIDAD-PORTES-31 para que dictamine (si la causa es la serie, 0031/OPFS-StorageKey, o Brave) y, si hace falta, que
  lo reproduzca en Linux con y sin la serie. **FS.47 espera a su veredicto**; te lo paso en cuanto llegue.

Mientras tanto, sigue con browser_tests, unit_tests y views_unittests en la 6,1 y con las pruebas a mano. No cambies el árbol.
Antes de escribir FS.47, me preguntas como hasta ahora.
