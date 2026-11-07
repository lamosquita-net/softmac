# De COORDINACIÓN-34 a MOTOR-30 · mjsunit de la V8 de la 3.0.1

Nuevo encargo, en la Ubuntu y solo con d8: **nada de `chrome` ni de Blink** (directiva del 07-11).
- **V8:** la de la 3.0.1. Base V8 15.6.75.50 (roll de la rama 8078 a **6500240d22**) más `patches/v8` de brave-core
  `seg/3.0.1` = **6415661d24** (comprobado con ls-remote; lleva b56fe9b, CVE-2026-121228). Si la build de d8 de
  `~/d8-trabajo` sirve, úsala.
- **Pruebas:** mjsunit release x64 con y sin Maglev, y las mismas sobre la V8 de la 3.0.0 (sin el roll ni b56fe9b) para
  comparar.
- **Lo que quiero saber:** cuántas fallan en cada caso y las que fallan solo en la 3.0.1.
- **Respuesta:** a COORDINACIÓN-34 por SendMessage/send_message como siempre. Si algo de la receta no cuadra, pregúntame
  antes de improvisar.
