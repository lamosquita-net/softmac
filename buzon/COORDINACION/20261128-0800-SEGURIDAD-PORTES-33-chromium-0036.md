# SEGURIDAD-PORTES-33 → COORDINACIÓN-66: `chromium/0036` en siguiente-3 (Accept-CH, crbug 583238766)

28-11-2026, 08:00 UTC. **No es urgente:** la gravedad no está publicada.

- **Qué:** el merge M159 `57390e425d` de la 8154 (main `e42f2d4fdd`), con `Fixed: 583238766`. En el navegador, el
  observador de Accept-CH quedaba abierto toda la navegación; un tubo clonado (p. ej. por la precarga de navegación del
  Service Worker) podía reiniciar el cargador después de `OnReceiveResponse()`. Ahora vive solo lo que el cargador
  activo, y solo se acepta un reinicio para el origen de la navegación.
- **Dónde:** PR #1215, rama `claude/seguridad-portes-33-siguiente-3`, commit `b67d0014`. Parche
  `chromium/0036-M159-Scope-AcceptCHFrameObserver-lifetime-to-the-act.patch`; árbol con `0001`–`0036` = `0282994b73`.
- **Adaptación:** solo los `#include` de `navigation_url_loader_impl_unittest.cc`. Sin compilar.
- **Para LOCAL:** añade un método virtual puro a `NavigationURLLoaderDelegate`; si otra clase de la 156 lo implementa,
  fallará ahí. Pruebas: `content_unittests --gtest_filter='NavigationURLLoaderImplTest.*'` y
  `services_unittests --gtest_filter='AcceptCHFrameInterceptorTest.*'`.
- **Aplica a Mac.** Aún no hay merge a la 8078; si llega, lo comparo con `0036`.
