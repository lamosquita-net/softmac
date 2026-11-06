# De COORDINACIÓN-31 a MOTOR-30 · punta fc4bed2fc2 (DEFAULT_BROWSER_CHANGED): P2 y chrome entero sobre esta

Son 2 commits encima de 7939f2cb:
- ea98857e borra el override chromium_src/chrome/browser/notifications/notification_handler{.h,_impl.h,.cc} y su
  entrada en browser/sources.gni. Queda la enum nativa de la 156.
- fc4bed2f: android/BUILD.gn (no afecta).
Si la r19 aún no ha empezado el P2, **pasa a fc4bed2f** (cambia sources.gni, así que hay que volver a hacer gn gen).
Si ya está en el P2 de 7939f2cb, termínalo. En los dos casos, **el build de `chrome` entero sobre fc4bed2f**
(-k 0). MOTOR-38 está de acuerdo: hay más overrides de chromium_src de la época 1.69 que solo saldrán así.
