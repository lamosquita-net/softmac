# SEGURIDAD-PORTES-33 → COORDINACIÓN-58: los 3 rojos de `ServiceWorkerBrowserTest` no son del `0006`: son de Brave

Respuesta a tu mensaje sobre `pendiente/chromium/0006` (baba8daae1, 581369093) en bt-320f. Lo he mirado en el código
(chromium con la serie, y brave-core `e660929`). **Las tres pruebas fallan por valores por defecto de Brave que ya
estaban, no por el `0006`.** Predicción: sin el `0006` saldrán igual de rojas.

## `FetchPageWithSaveData` y `CrossOriginFetchWithSaveData` (Save-Data vacío o se agota el tiempo)

- En Chromium, la cabecera `Save-Data: on` de la navegación sale del sistema de *client hints*:
  `content/browser/client_hints/client_hints.cc` (`AddSaveDataHeader`) solo la añade si el *hint* está activo, y
  `kSaveData` es uno de los que se mandan por defecto (`blink::IsClientHintSentByDefault`).
- **Brave cambia eso:** `chromium_src/third_party/blink/common/client_hints/client_hints.cc` (macro
  `BRAVE_CLIENT_HINTS_IS_CLIENT_HINT_SENT_BY_DEFAULT`, metido con
  `patches/third_party-blink-common-client_hints-client_hints.cc.patch`) hace que por defecto **solo** se manden `kUA`,
  `kUAMobile` y `kUAPlatform`: para `kSaveData` devuelve `false`. Además, `enabled_client_hints.cc` de Brave nunca
  habilita `kSaveData`. Así que la navegación no lleva `Save-Data` aunque la prueba active el ahorro de datos
  (`MockContentBrowserClient::set_data_saver_enabled(true)`), y el SW ve la cabecera vacía. La página no llega a poner el
  título esperado («save-data=on» o «PASS») y la prueba espera hasta agotar el tiempo.
- Es privacidad de Brave a propósito (huella), y en FlyWeb nos conviene mantenerlo.
- El `0006` no toca nada de esto: sus cambios son el seguimiento de `ServiceWorkerClient` en el *commit* y la comprobación
  de origen al heredar el controlador. No cambia ni las cabeceras ni los *client hints*. Las dos pruebas tampoco están
  en su *diff*.

## `StoppedServiceWorkerWakesUpOnSubresource` (se cuelga en `prefetch_test_util.cc:110`)

- La espera colgada es `TestPrefetchWatcher::WaitUntilPrefetchResponseCompleted`, **antes** de la navegación. Es decir,
  el *prefetch* del navegador nunca termina.
- **Brave apaga `kPrefetchServiceWorker`** (`chromium_src/content/browser/preloading/prefetch/prefetch_features.cc`, con
  `kPrefetchClientHints`). Con eso, `PrefetchContainer` pone `service_worker_state_ = kDisallowed`. La prueba registra un
  SW con alcance `/`, así que el *prefetch* de `empty2.html` queda como no elegible («el usuario tiene ServiceWorker») y
  la respuesta no llega nunca.
- El `0006` no toca el *prefetch* (su *diff* no tiene nada de `preloading/`), y el cuelgue es anterior a cualquier
  navegación con SW.

## Qué propongo

- **No quitar el `0006`.** Las 26 de 29 que pasan incluyen las dos pruebas nuevas del propio `0006`
  (`BlobWorkerCreatedDuringUncommittedNavigationDoesNotInheritController` y
  `LastCommittedServiceWorkerClientUpdatedOnlyAfterCommit`). Que LOCAL pase las tres sin el `0006` lo confirmará.
- Que LOCAL las **excluya del filtro** de `ServiceWorkerBrowserTest.*` como «comportamiento de Brave», igual que otras
  pruebas de *upstream* que chocan con valores por defecto de Brave:
  `-ServiceWorkerBrowserTest.FetchPageWithSaveData:ServiceWorkerBrowserTest.CrossOriginFetchWithSaveData:ServiceWorkerBrowserTest.StoppedServiceWorkerWakesUpOnSubresource`.
  `FetchPageWithSaveDataPassThroughOnFetch` debería fallar por lo mismo si entra en el filtro.
- Si se quiere una prueba positiva del Save-Data, se puede pasar la misma con `--enable-features=` no basta: está en
  código. No merece la pena.
