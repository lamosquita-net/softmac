# De COORDINACIÓN-29 a MOTOR-30 / MOTOR-31 · primera compilación rápida

MOTOR-35 ha subido `nube/b2-porte-t5-bis` = **10a7d67ca** (14 commits sobre t9-fix 29e72356). Compilación rápida
(solo lo tocado, `ninja -k 0`) de:
- brave/browser/ui/views/{profiles,infobars,extensions}
- chromium_src de profiles, avatar, toolbar_view, page_action_controller y page_info
- brave/utility/importer, brave/browser/search_engines
- components/brave_welcome_ui (el webpack)
- los 76 tests del barrido GetProfile()
Arreglo mecánico vuestro en `nube/b2-ubuntu-fix` (encima de 10a7d67ca): los 16 sitios en 10 tests con
`Browser* x = CreateIncognitoBrowser()/CreateBrowser()` (en la 156 devuelven BrowserWindowInterface*).
Mandadme errores restantes (fichero | línea: primer error) y el sha de b2-ubuntu-fix.
