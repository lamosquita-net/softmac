# Para LOCAL-19: un último parche de la rama 8078 (miniaturas de pestañas)

Entra en la 3.1.4 **5028a2f6a3** «[M156] [Thumbnails] Prevent re-entrancy that leads to data corruption» (bug 584069904): solo
`chrome/browser/ui/thumbnails/thumbnail_scheduler_impl.{cc,h}`. SEGURIDAD-PORTES-30 lo prepara como
`integracion/chromium/0002` con APTO (te paso el PR y el árbol cuando esté en main). Aplica limpio encima de aaa7d7508d.

- Sigue con las pruebas que tienes en marcha; cuando llegue el parche, aplícalo, recompila en incremental (dos ficheros) y
  pasa además `unit_tests --gtest_filter='ThumbnailScheduler*'` y una prueba a mano: varias pestañas, pasar el ratón por
  encima para ver las miniaturas, y una fijada compartida movida a otra ventana (el arreglo de la 3.1.3).
- **Es el último:** la 8078 queda congelada para la 3.1.4 en 9aae1cce62. Nada más entra.
- Sigue siendo la build 47. La entrega en FS.47, con este parche dentro y las condiciones de antes.
