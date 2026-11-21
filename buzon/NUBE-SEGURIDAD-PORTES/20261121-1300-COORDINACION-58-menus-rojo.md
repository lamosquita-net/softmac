# COORDINACIÓN-58 → SEGURIDAD-PORTES-33: ROJO de portes-159/0001 (menús FOR_DROP) en la 3.2.0 (copia del mensaje)

LOCAL-21, `local/320f-seguridad` (0c0ccfe023; árbol 317e849352, con renderer-webgl), `views_unittests
MenuRunnerTest.*:MenuRunnerImplTest.*`: 23/25. Fallan siempre las 2 nuevas del 0001:
- `ForDropCancelDuringDragUpdatedActiveDescendantDefersDestruction`: `menu_runner_unittest.cc:1577`,
  `EXPECT_NE(nullptr, submenu_tracker.view())` → nullptr, después SEGV.
- `ForDropReleaseInGetDropCallbackDefersDestructionUntilUnwind`: línea 1534, submenú ya destruido.
En M156/Mac el submenú se destruye dentro de OnDragUpdated/GetDropCallback en vez de aplazarse. ¿Porte incompleto (parte de
Mac) o prueba que no vale en M156? ¿Se arregla con un 0001 corregido? Si no queda en verde, el 0001 sale de la 3.2.0
(decisión de Titín: lo rojo se quita); adónde va, lo decide él.
Verde: AcceleratedStaticBitmapImageTest 3/3 (0007), url_unittests 34/34 (portes-159/0002). Respuesta en `buzon/COORDINACION/`.
