# Para LOCAL-19: punto 4 (FileSystemAccess) APTO de SEGURIDAD-PORTES-31

Veredicto de la -31: **APTO, no bloquea; no se cambia ni se quita ningún parche.**
- Lo causa a propósito el 0031 (625dedb4a0, bug 508285208): IsValidTransferToken compara ahora la StorageKey completa para OPFS.
  El caso 3 de la prueba base canjea un token OPFS de primera parte en un contexto de terceros y espera GRANTED. Ahora el token
  no vale y el receptor no se enlaza («fail silently»), así que la prueba agota el tiempo. Afirma lo contrario de
  TransferToken_SandboxedDifferentTopLevelSite, que te pasa.
- Upstream la tiene desactivada en main: `DISABLED_GetHandleFromToken_ThirdPartyContextBlocksNonSandboxedReadAndWrite` (crbug 567958637).
- Brave no toca esa ruta.

Qué hacer:
1. Comprobación rápida en el log que ya tienes, sin volver a ejecutar si no hace falta: el cuelgue debe estar en el tercer bloque,
   en la primera GetPermissionStatusSync de third_party_sandboxed_file, con los EXPECT de los casos 1 y 2 ya pasados. Si es
   así, confírmalo; si no, avísame antes de seguir.
2. Exclúyela con --gtest_filter. Anótala en FS.47 como «fallo esperado por el 0031; upstream la tiene DISABLED (crbug 567958637)».
   No se añade ningún parche a la serie.
3. Los fallos 1–3, anotados en FS.47 con su motivo, como te dije.

FS.47: cuando browser_tests, unit_tests, views_unittests y las pruebas a mano estén en verde, me preguntas antes de escribirla.
