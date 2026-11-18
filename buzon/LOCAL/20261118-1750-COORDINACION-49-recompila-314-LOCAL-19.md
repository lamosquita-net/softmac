# Para LOCAL-19: recompila la 3.1.4 ampliada (build 47)

La serie integrada está en main (#1083): toda la seguridad que aplica a Mac, con el APTO del conjunto de SEGURIDAD-PORTES-30.
El orden completo está en `FlyWeb/seguridad/3.1.4/CONTENIDO.md`.

1. **Antes de nada**, confírmame los árboles de los gitlinks de `local/314`: ANGLE (`271bafce16`) debe dar el árbol
   `db885a866b` y WebRTC (`1dc9ab4e8c`) el `8ee111cf22`. Si no coinciden, para y avísame.
2. Aplica encima de `local/314` 607ec34912, empezando por `integracion/chromium/0001` (trae las tres pruebas
   corregidas en #1081). Resultado esperado: chromium **`ddf5f555b2`** (desde local/313: 0df59307de).
3. brave-core: `local/3.1.4` 9932552867 + la serie → **`2ab25d6a23`** (es `seg/3.1.4-integracion` 6441095f59, ls-remote).
   V8 con todos los patches: **`17b5af44cd`**. `kFlyWebCacheEpoch` 37.
4. Repositorios aparte: Skia `a934afed14`, devtools-frontend `dc4e4cd416`, WebRTC `9b251c7cc7`, libaom `26cdf2fc0d`,
   libvpx `fe13a1c827`. ANGLE sigue en `db885a866b`.
5. Si algún árbol no coincide, para y avísame **antes de compilar**. Si coinciden, recompila; sigue siendo la **build 47**,
   con versión 3.1.4 y Chrome/156.0.8078.110.
6. Pruebas, como te dije en `…1645-…-pruebas-314-LOCAL-19.md`, con la rama de pruebas aparte para lo que rompe Brave.
   Añade los filtros de las partes 4–6 que figuran en los CONTENIDO. Haz también el pidinfo en la 6,1 en cuanto Titín
   apruebe LuLu.
7. Sube las ramas y dime sus nombres; los hashes los compruebo yo con ls-remote.

D8-LINUX tiene su encargo (`buzon/D8-LINUX/20261118-1740-…`; lo pega Titín). **El ALTO a FS.47 sigue vigente**: la entrega
la escribes solo cuando te avise del verde de D8-LINUX y con tus pruebas en verde.
