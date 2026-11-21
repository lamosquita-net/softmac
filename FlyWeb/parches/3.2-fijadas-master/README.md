# Fijadas compartidas: dos arreglos de Brave master

MOTOR-47, 21-11, por encargo de COORDINACIÓN-58. **Sin compilar.** No entran en ninguna versión hasta que lo decida Titín.
SEGURIDAD-PORTES-33: **APTO** para 0001 y 0002 (21-11, `buzon/COORDINACION/20261121-2301-SEGURIDAD-PORTES-33.md`). El 0003
son sus mejoras opcionales; pendiente de su visto.

Son dos arreglos que Brave hizo en `browser/ui/tabs/shared_pinned_tab_service.cc` después de la 1.98 (en master). Están
portados a nuestro fichero, que lleva además los cambios de FlyWeb (restauración de sesión, salida de la app y
`3.2-fijadas`).

| Parche | Qué arregla | Prueba nueva |
|---|---|---|
| `0001` | **Posible cierre.** Al cerrar una fijada compartida, `SynchronizeDeletedPinnedTab()` cierra su relleno en las demás ventanas. Si ese relleno es la última pestaña de una ventana, la ventana se cierra, y `BrowserClosing()` la borra de `browsers_` mientras el bucle lo recorre: comportamiento indefinido. Ahora se recorre una copia y se saltan las ventanas que ya no están | `ClosingSharedTabClosesWindowWithOnlyItsDummy` |
| `0002` | **Fijada fantasma.** Desfijar deja en cola `OnTabUnpinned()`. Si la ventana se sincroniza antes de que corra (por ejemplo, al activarla), tiene una fijada menos que `pinned_tab_data_`, se toma por desincronizada y recibe un relleno de más. Ahora se apuntan los modelos con un desfijado pendiente (`pending_unpin_models_`; se borran en `OnTabUnpinned()` y si el modelo se destruye) y su sincronización se aplaza a una tarea posterior | `SynchronizeRightAfterUnpinAddsNoStrayPinnedTab` |
| `0003` | **Mejoras de SEGURIDAD-PORTES-33** sobre fallos que ya estaban (Brave los tiene igual). `OnSharedPinnedTabDisabled()` vacía `pending_unpin_models_`, como `Shutdown()`. `OnTabUnpinned()` sale si su modelo ya no está pendiente (destruido, o la función desactivada con `pinned_tab_data_` vacío) o si `contents` es nulo. Antes podía usar un modelo liberado o desreferenciar `end()` | — |

Del resto de master no se porta nada. Lo demás no son estos dos arreglos:
- la comprobación de índice por las pestañas en árbol, que FlyWeb no tiene;
- la propagación del estado «bloqueada» (`OnTabBlockedStateChanged`);
- `IsBrowserInTabDragging` mediante `BrowserView`.

Si hiciera falta alguno, se mira aparte.

## Árboles

Sobre la brave-core de la **3.2.1** (`af99cc3984`: 3.2.0 publicada + `siguiente/brave-core` 0001–0003 + #1171):

| Tras | Árbol |
|---|---|
| 0001 | `ff238ab188` |
| 0002 | `b5eb2f74c1` |
| 0003 | **`1ec386019b`** |

## Pasos para LOCAL

`brave_browser_tests --gtest_filter='SharedPinnedTabServiceBrowserTest.*'`: los 10 deben pasar (los 8 de antes y los 2
nuevos). Sin 0002, el test nuevo `SynchronizeRightAfterUnpinAddsNoStrayPinnedTab` debería fallar: deja una fijada en la
primera ventana. Basta con comprobarlo una vez.
