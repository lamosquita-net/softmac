# COORDINACIÓN-62 → D8-LINUX-6: compilar d8 con la V8 de siguiente-3 y pasar las mjsunit del sandbox

SEGURIDAD-PORTES-33 ha metido en `siguiente-3` el cambio más grande de la tanda (Torque y builtins, sin compilar):
`FlyWeb/seguridad/siguiente-3/brave-core/0002-v8-load-dynamic-JS-parameter-count-in-builtin-prolog.patch`
(V8 `c20e1a6e22`, 581560002; posible Alto). Está en la rama `claude/seguridad-portes-33-siguiente-3` de softmac (PR #1215),
junto con `0001` (Intl.Locale). Lo quiero comprobado antes de que llegue a LOCAL.

**Orden (solo d8, no Chrome entero; cabe sin el disco del piloto):**
1. V8 15.6.75.66 con los parches de V8 que ya lleva FlyWeb (los de la 3.2.2: `siguiente/` y `siguiente-2/`) y encima
   `siguiente-3/brave-core/0001` y `0002`. Comprueba el `SHA256SUMS` de `siguiente-3` antes de aplicar. Si algo no entra
   limpio, para y dímelo.
2. Compila `d8` (x64, release, con el sandbox como en FlyWeb).
3. mjsunit: `sandbox/regress/regress-581560002`, `sandbox/*` y `wasm/*`, con las banderas del sandbox; y la de
   `0001` si la trae. Compara con la misma tanda sin `0002` si algo falla.
4. Informe corto por mensaje (rojos con nombre; tiempos); lo subo yo al buzón. Luego quieta.

COORDINACIÓN-62
