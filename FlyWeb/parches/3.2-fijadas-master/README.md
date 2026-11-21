# Fijadas compartidas: dos arreglos de Brave master

MOTOR-47, 21-11, por encargo de COORDINACIÓN-58. **Sin compilar.** No entran en ninguna versión hasta que lo decida Titín.
Pasan por SEGURIDAD-PORTES (regla de portes).

Son dos arreglos que Brave hizo en `browser/ui/tabs/shared_pinned_tab_service.cc` después de la 1.98 (en master). Están
portados a nuestro fichero, que lleva además los cambios de FlyWeb (restauración de sesión, salida de la app y
`3.2-fijadas`).

| Parche | Qué arregla | Prueba nueva |
|---|---|---|
| `0001` | **Posible cierre.** Al cerrar una fijada compartida, `SynchronizeDeletedPinnedTab()` cierra su relleno en las demás ventanas. Si ese relleno es la última pestaña de una ventana, la ventana se cierra, y `BrowserClosing()` la borra de `browsers_` mientras el bucle lo recorre: comportamiento indefinido. Ahora se recorre una copia y se saltan las ventanas que ya no están | `ClosingSharedTabClosesWindowWithOnlyItsDummy` |
| `0002` | **Fijada fantasma.** Desfijar deja en cola `OnTabUnpinned()`. Si la ventana se sincroniza antes de que corra (por ejemplo, al activarla), tiene una fijada menos que `pinned_tab_data_`, se toma por desincronizada y recibe un relleno de más. Ahora se apuntan los modelos con un desfijado pendiente (`pending_unpin_models_`; se borran en `OnTabUnpinned()` y si el modelo se destruye) y su sincronización se aplaza a una tarea posterior | `SynchronizeRightAfterUnpinAddsNoStrayPinnedTab` |

Del resto de master no se porta nada:
- las pestañas en árbol no existen en FlyWeb;
- `OnTabBlockedStateChanged` necesita una API de observador que la 156 no tiene igual;
- `IsBrowserInTabDragging` mediante `BrowserView` es un cambio de master por la WebUI de ventanas.

## Árboles

Sobre la brave-core de la **3.2.1** (`af99cc3984`: 3.2.0 publicada + `siguiente/brave-core` 0001–0003 + #1171):

| Tras | Árbol |
|---|---|
| 0001 | `ff238ab188` |
| 0002 | **`b5eb2f74c1`** |

## Pasos para LOCAL

`brave_browser_tests --gtest_filter='SharedPinnedTabServiceBrowserTest.*'`: los 10 deben pasar (los 8 de antes y los 2
nuevos). Sin 0002, el test nuevo `SynchronizeRightAfterUnpinAddsNoStrayPinnedTab` debería fallar: deja una fijada en la
primera ventana. Basta con comprobarlo una vez.
