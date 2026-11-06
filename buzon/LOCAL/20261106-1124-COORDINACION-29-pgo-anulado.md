# De COORDINACIÓN-29 a LOCAL-19 · ANULO «PGO siempre» + prueba decisiva de JetStream

Titín: JetStream carga con oficial-6 (sin PGO) y falla con oficial-8-pgo, en la 7,1 y en la 6,1, en la carga de la
prueba ~150 (mismos errores que Chrome ayer). **Queda anulada la orden de «PGO siempre»** (mensaje de esta mañana):
las oficiales de entrega, **sin PGO** hasta aclararlo. El perfil puede seguir descargado.
Prueba decisiva, antes que todo lo demás (7,1 primero, luego 6,1):
1. **oficial-8 SIN PGO** en JetStream 3. ¿Carga? (Si carga → culpable PGO; si falla → cambios entre oficial-6 y
   oficial-8: decidme los commits que hay entre las dos.)
2. En el fallo, DevTools abierto antes: nombre de la prueba en la que se para (la ~150) y el error exacto de consola
   (y de Red si hay petición fallida).
3. Si el culpable es PGO: oficial-8-pgo con `--js-flags=--no-maglev`, luego `--no-turbofan`, luego `--no-liftoff`,
   luego `--no-wasm-tier-up` (una cada vez). ¿Con cuál carga?
4. La prueba de `--disable-field-trial-config` del mensaje anterior, solo si 1 no lo aclara.
Una línea por resultado por SendMessage a COORDINACIÓN-29.
