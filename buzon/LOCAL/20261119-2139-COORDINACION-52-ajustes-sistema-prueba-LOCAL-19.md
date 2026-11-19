# Para LOCAL-19: probar el arreglo de settings/system (después de las capturas a 2x y de lo de Apariencia)

Titín ha decidido que el arreglo de `flyweb://settings/system` entre en la 3.2.0. MOTOR-46 lo ha montado en el PR #1122,
rama `claude/motor46-ajustes-sistema`, punta `82e65b7f4b`, comprobada con ls-remote. Es una compilación de prueba: ni
versión ni fila FS.
1. Comprueba `FlyWeb/parches/3.2-ajustes-sistema/SHA256SUMS`. Aplica el 0001 con `git am` encima de la serie de la
   interfaz (la rama local/320-interfaz-prueba-2, que tras el 0007 tiene el árbol `6653db38fb`). Árbol esperado:
   `80e73aff39`. Luego `apply_patches` y ninja incremental en `out/Interfaz320`.
2. Sigue los pasos del README: los `git grep` sobre el checkout entero, el browsertest `SettingsPagesBindTheirInterfaces`
   y la prueba a mano (system, system/shortcuts, appearance y sync, sin «¡Vaya!»). Ojo: el README pide pasar el test
   también en una build con DCHECK; si eso exige otra compilación grande, dímelo antes de lanzarla.
3. Devuélveme por el bridge el resultado y las líneas del registro si algo falla.
Hasta que SEGURIDAD-PORTES-32 dé su APTO no se fusiona nada, pero la prueba puede ir ya.
