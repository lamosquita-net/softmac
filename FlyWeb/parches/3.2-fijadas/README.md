# 3.2: favicon y título de las fijadas compartidas en las otras ventanas

MOTOR-47, 20-11, por encargo de COORDINACIÓN-53. **Sin compilar** (la nube no tiene el checkout de Chromium). Versión de
destino: la decide Titín.

## Fallo

Con las fijadas compartidas entre ventanas (`SharedPinnedTabService` de Brave), las fijadas de las otras ventanas se
quedan con el favicon y el título que tenían al crearse la pestaña: en blanco si la página estaba cargando entonces, o
con el título viejo. Titín lo ve en la 3.1.4 instalada.

## Causa

- Cada fijada tiene un único WebContents real, que vive en una ventana. En las demás hay un *dummy* sin renderer, cuyo
  título y favicon salen de una copia (`pinned_tab_data_[i].renderer_data`), mediante el gancho de
  `chromium_src/chrome/browser/ui/tabs/tab_data.cc`.
- Brave avisa de los cambios del real con `TabStripModel::UpdateWebContentsState(dummy)`, que solo llega a los
  `TabStripModelObserver::OnTabChangedAt`.
- En Chromium 156, la vista `Tab` toma sus datos de su `TabDataObserver` (`tab.cc`), que solo los recalcula cuando
  avisa el `TabUIHelper` de la pestaña. Además, `BrowserTabStripController` ya no tiene `OnTabChangedAt`. El aviso de
  Brave no llega a la vista.
- Es de Brave, no un porte nuestro: Brave 1.98.63 (Chromium 156.0.8078.80) y Brave master (1.102, Chromium 159) tienen
  el mismo código.

## Arreglo (0001)

`SharedPinnedTabService::OnTabChangedAt` llama a `BrowserUiController::NotifyTabUIChanged()` (público en la 156) en
vez de a `UpdateWebContentsState()`. Ese método avisa a los observadores, como antes, y también al `TabUIHelper`, así
que `TabData::FromTabInterface()` vuelve a ejecutarse y devuelve la copia del dummy. La reentrada ya la corta
`LOCK_REENTRANCE`. Si una ventana no tiene `BrowserUiController`, se usa la llamada de antes. Test de navegador nuevo:
`SharedPinnedTabServiceBrowserTest.DummyTabViewFollowsSharedContents`.

No toca privacidad ni seguridad.

## Árboles

| Base | Árbol tras el 0001 |
|---|---|
| `local/3.1.4` `e660929ac9` | `a1f68089e6` |
| Serie de la 3.2: interfaz 0001–0011 + ajustes-sistema 0001–0004 (árbol `f6222babef`) | `db1cde3061` |

Aplica limpio con `git am` en los dos casos (comprobado).

## Pasos para LOCAL

1. Compilar sobre una de las dos bases. Ojo: es la primera vez que brave-core incluye
   `chrome/browser/ui/browser_ui_controller/browser_ui_controller.h`. Si falla el enlazado o `gn check`, avisar a MOTOR.
2. `brave_browser_tests --gtest_filter='SharedPinnedTabServiceBrowserTest.*'`. El test nuevo debe pasar y los demás,
   seguir pasando. Para confirmar la causa, el test nuevo debería **fallar sin el parche** (se queda esperando hasta el
   tiempo límite). Basta con probarlo una vez.
3. A ojo (Titín): dos ventanas, una fijada compartida. Navegar en A a otra página: en B cambian el favicon y el
   título. Abrir una ventana nueva mientras la fijada carga: el favicon aparece al terminar la carga.

## Lo que este parche no cubre

«Pasar a la fijada en B y que se quede en blanco, aunque se recargue» está sin explicar. Es una hipótesis, sin
confirmar: recargar sobre un dummy, que solo tiene about:blank, o un descarte de memoria del real, que Brave no
gestiona (`OnTabStripModelChanged` ignora `kReplaced`). Están pendientes los datos de Titín: build, capturas,
`flyweb://discards` y en qué ventana recarga.
