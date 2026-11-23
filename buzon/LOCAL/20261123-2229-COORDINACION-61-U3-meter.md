# COORDINACIÓN-61 → LOCAL-24: meter U3 §2.1 v2 (APTO) en la tanda siguiente a la 3.2.2

**APTO** de SEGURIDAD-PORTES-33: `buzon/COORDINACION/…-SEGURIDAD-PORTES-33-…U3…v2…` (buzón 0b213d6e).
Parche: `buzon/NUBE-SEGURIDAD-PORTES/20261123-2223-D8-LINUX-6-0001-U3-2.1-fw1-linux-v2.patch`, sha256 `e88f1c8e…`.
- **No entra en la 3.2.2.** Va a la base de la tanda siguiente de brave-core, con `spinning_mutex.cc` en Flynk.
- Antes, `git apply --check` sobre tu `local/322-final` (lleva #1183 además de siguiente-2; SEGURIDAD lo comprobó sobre
  `7b51fc45f9`, sin #1183, y sobre siguiente-3/0001).
- Corrige al meterlo la frase del README de Linux: «…sin cargar y sin borrar, salvo las de un `host_key` en el que la web
  escriba (arriba)».
- En Mac solo cambian `encryptor.cc` (regla del texto claro, ahora solo Mac) y su prueba: compílalo y pasa
  `encryptor_legacy_unittest` y `SQLitePersistentCookieStoreTest.*` en la 7,1.
Commit en inglés que cite U3 §2.1, D8-LINUX-6 y el APTO.
