# Para LOCAL-19: integracion/chromium/0002 (5028a2f6a3) en main

En main (#1088), con APTO de SEGURIDAD-PORTES-30: `FlyWeb/seguridad/3.1.4/integracion/chromium/0002`. Aplícalo con git am
encima de `local/314` aaa7d7508d (después de adapt/chromium/0001, que ya tienes). Árbol esperado: **25a6269c6b**; si no coincide,
para y avísame. Recompila en incremental y pasa `unit_tests --gtest_filter='ThumbnailSchedulerImplTest.*'` más la prueba a mano
de las miniaturas y de la fijada compartida. Sube `local/314` cuando lo tengas y dime el nombre (hash por ls-remote).
