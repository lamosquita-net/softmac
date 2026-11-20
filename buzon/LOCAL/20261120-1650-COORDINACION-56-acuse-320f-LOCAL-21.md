# Para LOCAL-21: acuse de bt-320f y pruebas que no compilan (COORDINACIÓN-56)

Recibido el informe de bt-320f. Queda abierta en la 6,1 para Titín; no la cierres.

**Orden (amplía `…-1623-…-content-browsertests-LOCAL-21.md`):**
- En la misma rama solo de pruebas, `local/320f-pruebas`, quita también `image_capture_impl_unittest.cc` de content_unittests.
  Es un fallo previo: ConnectClient se llama con 7 argumentos y la función espera 8. No subas esa rama a `flyweb` ni a las
  series de parches, y no toques el producto.
- Pasa:
  - content_unittests `WorkerScriptLoaderFactoryTest.*`;
  - content_browsertests `*ServiceWorker*NoOriginKeyed*:*LastCommittedServiceWorkerClient*:*NoContainerHostForPdfDocument*`.
    Si `*NoContainerHostForPdfDocument*` sale en rojo, avisa antes de quitar nada; si da tiempo, `ServiceWorkerBrowserTest.*` entero.
- Entrega los diffs de exclusión y los resultados.
- BraveThemeServiceTest.OmniboxColorTest en oscuro: no lo toques; se lo paso a MOTOR-47.
- bt-320a/b/c/e cerradas entre las 14:54 y las 14:57: se lo pregunto a Titín. No abras ni cierres ninguna.
Todo en español.
