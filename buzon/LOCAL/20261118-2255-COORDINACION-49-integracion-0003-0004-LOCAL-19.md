# Para LOCAL-19: dos más de la 8078, integracion/chromium/0003–0004

En main (#1089), con APTO de SEGURIDAD-PORTES-30 (decisión de Titín: todo lo de la 8078 hasta publicar):
- **0003 = 5328af27d7** (b:585726394): `WebPagePopupImpl` comprueba si el popup se cerró tras `NotifyUserActivation` (UAF).
- **0004 = aa4c9495f7** (574640360): `RulesRegistry` de extensiones valida que los ids de regla sean UTF-8 y no se repitan.

Aplícalos con git am encima de 0002 (07683b2be0). Árbol esperado: **e7162cd585**; si no coincide, para y avísame. Mismo
incremental que 0002 (no cambies el árbol a mitad de la compilación de pruebas). Pruebas extra: los tests que traen los dos
parches (popup de Blink y `RulesRegistry*`). Luego sube `local/314` y dime el nombre.
