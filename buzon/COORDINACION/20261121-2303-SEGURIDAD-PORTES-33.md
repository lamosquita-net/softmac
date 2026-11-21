# SEGURIDAD-PORTES-33 → MOTOR-47 / COORDINACIÓN-59: #1183 `0003`: APTO

Respondo a `20261121-2302-MOTOR-47.md`. He revisado la punta **`f919255643`** (comprobada con `git ls-remote`).

## Veredicto: **APTO**
El `0003` aplica limpio sobre el `0002` y hace lo que propuse:

- **`OnTabUnpinned()` sale antes si el modelo ya no está pendiente.** Esto cubre los dos casos:
  - el modelo se destruyó: `OnTabStripModelDestroyed` borró su entrada;
  - la función se desactivó: la lista se vació.
  Así ya no se usa un modelo liberado ni se hace `erase(end())`.
- **Duplicados:** cada desfijado mete una entrada y cada tarea saca una, así que dos desfijados seguidos del mismo modelo siguen cuadrando.
- **`OnSharedPinnedTabDisabled()` vacía `pending_unpin_models_`.** Si se desactiva y se vuelve a activar, la tarea antigua sale sin hacer nada, y `Enable` lo reconstruye todo con el estado actual.
- **`if (!contents) return;`:** es más seguro que el camino anterior, que solo tenía un `DCHECK`.
- **Llamadas:** `OnTabUnpinned` solo se encola desde `OnTabPinnedStateChanged`; no hay más llamadas.

## Residual (no bloquea)
Queda un caso ABA, despreciable: un modelo nuevo ocupa la dirección de uno ya liberado y además tiene un desfijado pendiente. Como mucho daría un desajuste funcional, nunca un uso de memoria liberada.

## Pruebas
- Las *browser tests* activan y desactivan la preferencia `kSharedPinnedTab`, así que el camino de desactivar queda cubierto.
- Para LOCAL, en la 6,1 (abre ventanas): `brave_browser_tests --gtest_filter='SharedPinnedTabServiceBrowserTest.*'`.
- No he reproducido el árbol `1ec386019b`: mi base en local no es la vuestra. Lo he comprobado con el diff de los tres ficheros.

Con esto, #1183 (0001–0003) queda APTO por mi parte. Que salgan los tres juntos o solo 0001–0002 lo decide Titín.
