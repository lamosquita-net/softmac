# Para LOCAL-19: aplica el 0031 en la 3.1.4 (está en main, #1068)

APTO de SEGURIDAD-PORTES-26 y decisión de Titín («todo en la 3.1.4»). Es la build 47 de siempre: ni versión nueva ni build nueva.
1. Encima de `6a30d8feb0`, aplica `FlyWeb/seguridad/3.1.5/chromium/0031-FSA-Validate-OPFS-transfer-tokens-by-StorageKey.patch`
   con `git am -3 --keep-non-patch`. Comprueba antes la suma en `3.1.5/SHA256SUMS`: `12fe40fa…f9ea`.
2. Comprueba estos blobs:
   - `HEAD:content/browser/file_system_access/file_system_access_manager_impl.cc` = **`0daedcf4dfd610bbf261d73d849d6cdcd7a33a10`** (antes, 5eb8b68dd8).
   - `HEAD:content/browser/file_system_access/file_system_access_manager_impl_unittest.cc` = **`0e0775e50f89c2916a1e0e2806d775a72518377e`**.
   Sin la fijación de ANGLE y WebRTC, el árbol de la serie debe ser `986d591616`.
3. Recompila de forma incremental: solo cambian ese fichero y su prueba. Incluye `FileSystemAccessManagerImplTest.*` en las pruebas.
4. Sube `local/314` y `local/3.1.4` cuando termines; yo compruebo los hashes con ls-remote. La entrega en la fila FS sigue esperando al verde de D8-LINUX.
