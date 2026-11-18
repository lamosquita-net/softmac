# Para LOCAL-19: tres arreglos más para la 3.1.4 (rama 8078, posteriores a la .110)

En main (#1063, APTO de SEGURIDAD-PORTES-26): dos [M156] de ServiceWorker y una V8 de TurboFan. Todo sigue siendo 3.1.4, build 47.
- **chromium:** añade `3.1.5/chromium` 0028–0029 → árbol esperado **`880f9f156d`** (antes de tu commit de ANGLE y WebRTC).
- **brave-core:** añade `3.1.5/brave-core/0003` (V8 5787048 como patches/v8, época de caché **34**) → árbol **`15c050d35a`**; V8 con patches → `fe1194813a`. Sigue sin aplicarse `3.1.5/brave-core/0002`. No toques el gitlink de V8 ni VERSION.
- WebRTC y ANGLE no cambian.

**Cómo:** si te compensa, deja terminar la build actual, aplica los tres y recompila de forma incremental. Si ves más seguro empezar de cero, empieza de cero; tú decides. Las pruebas y la del pidinfo, sobre el binario final. La entrega en FS sigue esperando al verde de D8-LINUX (encargo nuevo: `buzon/D8-LINUX/20261118-1310-…`).
