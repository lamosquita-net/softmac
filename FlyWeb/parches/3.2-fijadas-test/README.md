# 3.2 — test de las fijadas compartidas que ya fallaba en la 3.1.2

MOTOR-46, 17-11, por encargo de COORDINACIÓN-44. Es solo un cambio de test, fuera de la serie de la sync.
**Sin compilar.** Destino: 3.2.0.

Base: brave-core `local/3.1.2` (ba428ad058). No toca los mismos ficheros que `3.2-fijadas-miniatura` ni la sync.

| Parche | Qué hace |
|---|---|
| `0001-tabs-shared-pinned-tab-Mac-test-confirms-the-pinned-.patch` | `browser/ui/tabs/test/shared_pinned_tab_service_browsertest_mac.mm`: `IDC_CLOSE_TAB` se ejecuta dos veces |

## Por qué fallaba

`SharedPinnedTabServiceBrowserTest.CloseTabShortCutShouldBeDisabled` esperaba 1 pestaña tras un solo
`chrome::ExecuteCommand(browser, IDC_CLOSE_TAB)` y quedaban 2. Lo vio LOCAL-19 en la 3.1.2 sin el 0001 de las fijadas.

En Chromium 156, `chrome::CloseTab()` (`chrome/browser/ui/browser_commands.cc`) pide confirmación cuando todas las
pestañas seleccionadas están fijadas:
- La primera orden solo muestra el aviso `ToastId::kClosePinnedTab` («pulsa otra vez para cerrar»).
- La segunda, con el aviso ya en pantalla, cierra la pestaña.

No es un fallo de FlyWeb: el servicio de fijadas compartidas no interviene. La parte de ⌘W del test, que es la guarda de
Brave en `brave_browser_native_widget_mac.mm`, ya pasaba. El aviso de confirmación se queda como en Chrome 156; solo se
quitaría si Titín lo pide.

## Prueba (LOCAL)

`brave_browser_tests --gtest_filter='SharedPinnedTabServiceBrowserTest.CloseTabShortCutShouldBeDisabled'`: debe pasar.
