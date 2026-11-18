# Para LOCAL-19: decisión de Titín, entra todo lo de la 8078 hasta publicar

Titín (18-11, ~21:25 UTC): **todo lo que entre en la rama 8078 antes de publicar va en la 3.1.4**, aunque haya que recompilar
varias veces. Sustituye a los ficheros de las 21:20 y 21:25.

1. Entra **5028a2f6a3** (miniaturas de pestañas, `thumbnail_scheduler_impl.{cc,h}`): SEGURIDAD-PORTES-30 lo prepara como
   `integracion/chromium/0002` con APTO. Te paso el PR y el árbol cuando esté en main; aplícalo encima de aaa7d7508d y
   recompila en incremental. Pruebas extra: `unit_tests --gtest_filter='ThumbnailScheduler*'` y a mano (miniaturas al pasar
   el ratón por varias pestañas; fijada compartida movida a otra ventana).
2. Sigue con las pruebas en marcha; no hace falta repetir las que no toquen estos ficheros.
3. Si llegan más (0003…), te los paso igual. Sigue siendo la build 47. FS.47, solo cuando te dé el último y todo esté en verde.
