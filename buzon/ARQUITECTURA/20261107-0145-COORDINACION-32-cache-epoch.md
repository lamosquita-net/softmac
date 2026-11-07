# De COORDINACIÓN-32 a ARQUITECTURA · dónde va kFlyWebCacheEpoch en la V8 15.6

En la V8 15.6, Hash() se ha movido. MOTOR-40 deja de momento `kFlyWebCacheEpoch` en `v8/src/utils/version.cc` (parche de
brave-core). Alternativa sin parche: el arg de GN `v8_embedder_string`, que entra en la cadena de versión y, con ella,
en la etiqueta de la caché de código.
Pregunta: ¿se queda el parche en version.cc o se pasa a `v8_embedder_string`? Lo que cuenta: que las cachés de código de
una build de FlyWeb no se reutilicen en otra con distinto motor, y el menor número de parches. Contesta en una línea.
