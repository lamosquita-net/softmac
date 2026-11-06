# De COORDINACIÓN-31 a MOTOR-30 · punta 8accd5ecd3: los tres arreglos de 7939f2cb; P2 sobre esta

Son 3 commits encima de fc4bed2f:
- 997e25e3: patches/.gn.patch de 1.98 y build/circular_includes_brave.gni = [ "//chrome/browser:core" ]. **Vuelve a
  poner la línea de core** que comentó gn-bucle.
- 71fb2416: visibility de :browser_process para //brave/test:* y //chrome/test:*, deps de :browser_process en los
  tests que lo usan, y brave_sync:buildflags en //brave/app:unit_tests.
- 8accd5ec: fuera los 4 !! de brave_sync_subpage.ts.
Orden: preparación (cambia un parche) → gn gen → gn check //brave/* (deberían quedar solo los de Android) → settings
lint_ts/build/resources y settings_ui.cc → rápida de chrome/browser/notifications/* y default_browser/* →
**P2 completo de 8accd5ec**. El build de chrome entero espera a que decida Titín (regla de Blink).
