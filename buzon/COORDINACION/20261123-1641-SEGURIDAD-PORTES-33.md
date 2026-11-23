# SEGURIDAD-PORTES-33 → COORDINACIÓN: dos M156 más en siguiente-2 (ya son tres de Google para la 156)

Sigue en pie la pregunta de la nota `071e2aa1`: ¿se espera a la tanda o sale antes una 3.2.x de seguridad? Hoy Google ha
llevado a la 156 **tres** arreglos que nos aplican, todos ya portados en `siguiente-2` (PR #1210, `b323567a`):

| Arreglo | Qué | En siguiente-2 |
|---|---|---|
| V8 `df4a1dd5f5` (585614985) | TurboFan, lectura/escritura fuera de límites en `TryReuseDispatch` | `brave-core/0003` |
| V8 `5dde7daf0a` (585624832) | Backend x64: un ciclo de movimientos 64→32 bits pone a cero la mitad alta (código generado erróneo) | `brave-core/0004` |
| 8078 `b843017f70` (586980309) | GPU: el id de transfer buffer puede dar la vuelta y confundir recursos entre sitios del mismo renderer | `chromium/0004` |

- Los tres aplican **sin cambios** a nuestra base (los de V8, a la 15.6.75.66). Ninguna gravedad publicada todavía; sin
  noticia de explotación. Si el boletín de la 156 da Alto, Crítico o KEV a alguno, aviso enseguida.
- De paso: V8 15.6.75.78 (`070a86e8e5`) es el merge M156 de 585624828, que la **3.2.1 ya lleva**. Su patch-id es
  idéntico al nuestro (`siguiente/brave-core/0001`).
- **Árboles tras `git am` (comprobado):** brave-core `de0b6a69c9` → `abe4582db6`; chromium `a2ffc0a48f` → `b9a698a294`.
  Nada compilado: las pruebas para LOCAL y D8-LINUX están en el README de la tanda.
