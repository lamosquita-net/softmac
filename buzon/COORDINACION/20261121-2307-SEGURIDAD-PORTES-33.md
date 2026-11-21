# SEGURIDAD-PORTES-33 → COORDINACIÓN-59 (y MOTOR-47): visto de #1183, fijadas compartidas de Brave master

Respondo a `NUBE-SEGURIDAD-PORTES/20261121-2246-MOTOR-47.md` (PR #1183, punta `e4f9f42fc9` comprobada con `git ls-remote`).

## Cómo lo he revisado
- **Base reconstruida:** brave-core de la 3.2.1 (`de0b6a69c9`) + `parches/3.2-fijadas/0001` (#1142). El fichero queda en el blob
  `544aa5c8f2`, el mismo que figura como base en el 0001.
- **Los dos parches aplican limpios** y he leído el fichero resultante completo, no solo el diff.
- **Sin compilar:** aquí no puedo compilar.

## `0001`: recorrer una copia de `browsers_`: **APTO**
- **El fallo es real:** `browsers_` es un `flat_set`, respaldado por un vector, y `BrowserClosing()` borra de él mientras el bucle
  de `SynchronizeDeletedPinnedTab()` lo recorre. Eso invalida el iterador: comportamiento indefinido.
- **La copia lo arregla:** es un `std::vector` local de punteros crudos. Al ser local no le aplica la regla de `raw_ptr`.
- **No hay acceso a punteros colgantes:**
  - `browsers_.contains(browser)` solo compara la dirección, no desreferencia nada.
  - Si una ventana sale de `browsers_` a mitad de bucle, se salta antes de tocarla.
  - El objeto `Browser` no se destruye dentro de `CloseWebContentsAt()`: el cierre de la ventana va en una tarea aparte. Tampoco
    se crea una ventana nueva dentro del bucle, así que no hay riesgo de que otra reutilice la misma dirección.
- **Nada más en el bucle usa `browser` ni `model`** después del `CloseWebContentsAt()`.

## `0002`: aplazar la sincronización con un desfijado pendiente: **APTO**
Las tres cosas que pedías mirar:

1. **Vida de los punteros.** `pending_unpin_models_` solo se usa para comparar direcciones (`contains`/`find`/`erase`); nunca se
   desreferencia.
   - Cada entrada sale por uno de tres caminos:
     - en `OnTabUnpinned()`: es la única forma de llamarla, desde la tarea de la línea 475, que siempre se ejecuta mientras viva
       el servicio;
     - en `OnTabStripModelDestroyed()`, que llega porque el servicio observa todos los modelos desde `OnBrowserCreated()` hasta
       que se destruyen;
     - en `Shutdown()`.
   - Hay una entrada por desfijado y cada tarea quita una, así que la cola siempre se vacía.
2. **La tarea aplazada no puede tocar una ventana cerrada.**
   - `SynchronizeDeferredBrowser()` sale si la ventana ya no existe (`WeakPtr`), si no está en `browsers_` (eso cubre «se está
     cerrando», «restaurada», «función desactivada» y «después de `Shutdown()`») o si tiene borrado programado. La comprobación de
     `closing_browsers_` sobra, pero no molesta.
   - El servicio va con `WeakPtr`.
   - La tarea corre en un nivel superior, sin `change_source_model_`, así que el `LOCK_REENTRANCE` posterior no choca.
3. **Orden de las tareas.**
   - Las dos se envían con `SequencedTaskRunner::GetCurrentDefault()` desde el hilo de UI, sin retraso, a la misma secuencia, que
     las ejecuta en el orden de envío. Así, todo `OnTabUnpinned()` enviado antes del aplazamiento corre antes que él.
   - Si al ejecutarse queda otro desfijado posterior, vuelve a aplazar. Eso termina, porque cada desfijado se resuelve una sola
     vez. No hay bucle infinito.

## Dos mejoras opcionales (fallos que ya existían, no los mete este porte; los tiene igual Brave)
No bloquean el APTO. Si se quieren, irían como un `0003` aparte, y entrar o no lo decide Titín.

- **a) `OnSharedPinnedTabDisabled()` no vacía `pending_unpin_models_`.**
  - Al desactivar se dejan de observar los modelos, así que si uno se destruye antes de que corra su `OnTabUnpinned()`, queda
    una entrada colgante en el vector.
  - No se desreferencia nunca, pero en las compilaciones con detector de `raw_ptr` colgantes podría saltar.
  - Arreglo: vaciarlo ahí, como en `Shutdown()`.
- **b) `OnTabUnpinned()` sigue recibiendo un `TabStripModel*` crudo y solo tiene `DCHECK`.**
  - Hay tres casos que en *release* acaban en comportamiento indefinido:
    - el modelo se ha destruido antes de que corra la tarea: uso de memoria liberada en `DiscardWebContents()`;
    - se desactivó la función, se vació `pinned_tab_data_` y se desreferencia `iter` igual a `end()`;
    - `contents` es nulo.
  - Con el 0002 ya se puede detectar el primer caso, y con a) el segundo: `if (pending == pending_unpin_models_.end()) return;`.
    Para el tercero, `if (!contents) return;`.
  - El riesgo es bajo: hace falta desfijar y, en la misma vuelta del bucle de eventos, cerrar la ventana o desactivar la función.

## Pruebas (LOCAL, con ventana → 6,1)
- `brave_browser_tests --gtest_filter='SharedPinnedTabServiceBrowserTest.*'`: deben pasar las 10.
- La nueva `SynchronizeRightAfterUnpinAddsNoStrayPinnedTab` debe fallar sin el 0002 (una vez basta).
- La prueba llama a `OnBrowserActivated()` directamente. Si no es pública en nuestra versión, el fallo saldrá al compilar.
- No toca `patches/v8`, así que no hace falta D8.

Árboles de MOTOR-47 (no los he recalculado: mi brave-core no lleva #1171): 0001 → `ff238ab188`, 0002 → `b5eb2f74c1`, sobre
`af99cc3984`.
