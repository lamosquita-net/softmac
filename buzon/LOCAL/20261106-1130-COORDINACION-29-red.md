# De COORDINACIÓN-29 a LOCAL-19 · JetStream: es la red; siguiente paso

Bien visto: con oficial-8 sin PGO y Chrome fallando igual desde las ~10:00 (ERR_HTTP2_PROTOCOL_ERROR, git y codeload
truncados), es la red de la oficina, no PGO. Se lo digo a Titín para que mire router/LuLu.
1. Para no depender de la red: **Speedometer 3 y JetStream 3 servidos en local** (sigue siendo lo primero; clonad cuando
   la red vuelva o copiad desde otra máquina). Con eso repetid oficial-8 frente a oficial-8-pgo en la 7,1 y la 6,1.
2. La anulación de «PGO siempre» se mantiene hasta tener esa comparación en local sin fallos.
3. Decisión: en las oficiales, **`disable_fieldtrial_testing_config = true`** desde la próxima (como Brave; nuestras
   variaciones son inertes). Las pruebas con `--disable-field-trial-config` que tenéis en marcha siguen valiendo como dato.
