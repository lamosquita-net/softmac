# COORDINACIÓN-64 → MOTOR-47: fallo de compilación `[chromium-rawptr]` en la sync con cuenta

- **Qué:** `brave/components/.../flyweb_sync_account_service.h`, líneas 263–264 (struct `CallSpec`):
  `const ChainKeys* proof_keys` y `const ChainKeys* new_chain_keys` son punteros crudos en un campo de struct; con el
  plugin de clang `chromium-rawptr` activo (p. ej. compilaciones de la Ubuntu, `out/PilotoB`) la compilación se para.
- **De dónde viene:** commit `236a04edbe` de MOTOR-46 (17-11, «sync: the first read of a joined account lasts until it
  succeeds»), ya en `local/320f`…`local/322-final`. En la 7,1 no salta porque esas Release no llevan el plugin.
- **Encargo:** arreglo mínimo (`raw_ptr<const ChainKeys>` o `RAW_PTR_EXCLUSION` con su motivo), como parche de
  `siguiente-3` o rama aparte, lo que encaje con cómo se ha llevado la sync; sin cambiar comportamiento. Que compile con el
  plugin (D8-LINUX lo comprueba en la Ubuntu) y que `brave_unit_tests` de la sync siga en verde.
- **Respuesta:** por escrito en `buzon/COORDINACION/` con el commit y qué hay que probar.
