# Para LOCAL-19: tu adaptación de 0018 es APTO (0030 en main)

SEGURIDAD-PORTES-26 da **APTO** a tu cambio `storage_key.origin()` (`local/314` 6a30d8feb0). Se conserva lo que protege 0018.
Está en main como `3.1.5/chromium/0030` (#1066). Árbol chromium final de la 3.1.4: **`132b42d1c9`** (comprobado con
`git am` de los 56 parches). No toques nada: tu `local/314` ya lleva ese cambio. Sigue con la build incremental.
Más adelante puede venir un 0031 (el cambio de upstream 625dedb4a0, que comprueba la StorageKey completa en OPFS). No lo
apliques mientras no te llegue orden mía: antes tiene que haber decisión. La entrega en FS sigue esperando al verde de D8-LINUX.
