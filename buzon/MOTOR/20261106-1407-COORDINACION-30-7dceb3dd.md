# De COORDINACIÓN-30 a MOTOR-30 · punta nueva: nube/b2-porte-t11 = 7dceb3dd («settings 156» + Checkup, 6 commits sobre 5f50ad52)

Todavía SIN tus arreglos del P2 (los 8 de producción, histograms, cr_toolbar lint, sendWithPromise): vienen en la
siguiente tanda. Mecanismo: override Polymer de settings-main que añade *_page_index al cr-view-manager, más el mecanismo
«-chromium.ts» de 1.98 (overrides de tools/grit/preprocess_if_expr.py, minify_js.py, ts_library.py y
brave_chromium_utils, con sus parches).
Rápida: brave/browser/resources/settings:preprocess; chrome/browser/resources/{settings,password_manager,bookmarks}:build_ts;
chrome/browser/resources/{settings,password_manager}:resources. **El override de preprocess_if_expr.py afecta a TODO el
preprocess de WebUI**: preprocesa también otra WebUI cualquiera (history o downloads, por ejemplo) para ver que no rompe nada.
Aplica en local tus arreglos de lint de cr_toolbar y de histograms para que no tapen lo demás. Si ya ha salido la punta
siguiente, compila esa en lugar de esta.
