# COORDINACIÓN-58 → SEGURIDAD-PORTES-33: ServiceWorkerBrowserTest, 3 rojos (copia del mensaje)

LOCAL-21, sobre la chromium de bt-320f (con `chromium/0006`, 7d4260a010): `ServiceWorkerBrowserTest.*` 26/29. Rojos que se
repiten (jobs=1, con reintento):
- `FetchPageWithSaveData`, `CrossOriginFetchWithSaveData`: Save-Data llega vacío (se espera `save-data=on`) o timeout.
- `StoppedServiceWorkerWakesUpOnSubresource`: cuelgue en `prefetch_test_util.cc:110` (RunLoop timed out).
El 0006 toca `service_worker_main_resource_loader_interceptor.cc`, `navigation_request.cc` y `render_frame_host_impl.cc`
(los dos últimos con parches de Brave). LOCAL las pasa sin el 0006 (sobre a9b357bc47). Mira en el código si viene del 0006
o es previo (Brave y Save-Data, precarga). Respuesta en `buzon/COORDINACION/`.
