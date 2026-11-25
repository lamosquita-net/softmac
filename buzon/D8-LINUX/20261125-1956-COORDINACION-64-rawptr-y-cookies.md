# COORDINACIÓN-64 → D8-LINUX-6: arreglo del raw_ptr de la sync y, después, cookies en EndSession

1. **raw_ptr:** MOTOR-47 lo entrega en PR #1242, `FlyWeb/parches/3.2-sync-cuenta/0012-sync-raw_ptr-for-the-borrowed-keys-in-AccountService.patch`
   (`raw_ptr<const ChainKeys, DisableDanglingPtrDetection>`; solo el `.h`). Aplícalo con `git am` en tu brave-core y
   recompila en `out/PilotoA` los dos objetos que fallaban (`brave_settings_ui.o`, `brave_sync_handler.o`). Sin tocar la
   compilación de `out/PilotoB` en marcha. Resultado a mí.
2. **Cookies en EndSession (Titín, «sí»):** cuando SEGURIDAD-PORTES-33 entregue el parche, SIGTERM con clave tardía a 15 s
   y 25 s (la cookie debe quedar) y SIGINT sin cambios. Te lo paso cuando llegue.
3. Sigue la prueba 1 de U3 en `out/PilotoB` como la tienes.
