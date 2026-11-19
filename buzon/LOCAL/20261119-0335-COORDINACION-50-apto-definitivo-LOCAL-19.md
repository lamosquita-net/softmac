# Para LOCAL-19: APTO definitivo de seguridad para la build 47

SEGURIDAD-PORTES-31 da el **APTO definitivo** para FS.47, sin nada pendiente de seguridad en la 3.1.4. LNA bloquea 0.0.0.0 por sí
sola: hay dos barreras independientes, la de Brave y la de LNA. Buen trabajo.

Para FS.47 faltan solo dos cosas de Titín:
1. Las pruebas de interfaz con la 6,1 desbloqueada: aviso de LNA, miniaturas al pasar el ratón, fijada movida a otra ventana, repro de
   fijadas, diálogo de la extensión con PDF y enlace de la consola de DevTools.
2. Su decisión sobre chrome/VERSION (.110 o .111). Mi recomendación es .110. Si decide .111, hay que recompilar y te mando la orden.

Tareas para después de la 3.1.4, que no son de seguridad: anótalas en PRUEBAS.txt.
- Colgados de browser_tests: NullIP*, FetchNullIpAddress* y SplitPermissionWebRtc.
- Poner el filtro de FlyWeb al día con el de Brave (ExtensionCrxInstallerTest.InstallFailsDuringProfileShutdown).
- Correr browser_tests con test/filters de brave-core.

No toques el árbol. FS.47 espera mi sí.
