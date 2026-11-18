# FlyWeb 3.1.5: medios de Chrome 157 que faltan (inventario, sin portar)

SEGURIDAD-PORTES-25, 18-11-2026, por encargo de COORDINACIÓN-47 («comprueba si las tandas de la 157 trajeron sus
medios; si faltan, inventario, sin portarlos»).

**Resultado:** las tandas de la 157 (3.0.1 a 3.1.4) se hicieron con los críticos y altos. De los **76 medios** de las
notas de la 157 (03-11: 74; 09-11: 2), **ninguno** sale en las notas de la Extended Stable de la 156 (03-11, 09-11, 11-11
y 17-11), así que no han llegado por la rama 8078, salvo los que Google hubiera fusionado sin anotarlos. Dos se miraron
en la 3.1.5 parte 1: 568972975 (CVE-2026-121223, `chromium/0002`, portado) y 571058818 (CVE-2026-121105, **no portado**: 7b99dd29ba
cambia el constructor de `WebMediaPlayerImpl`; está pensado para WebView sin aislamiento de sitios).

Los grupos salen del componente de la nota, igual que en `PROPUESTA-MEDIOS.md`. Falta, para cada uno, buscar su commit
(`search/commits` por número de bug en `chromium/chromium`, `v8/v8` y `google/angle`), comprobar si ya está en la 8078
y si entra en el árbol de la 3.1.5. Orden propuesto: G3a → G3b → G4.

**G1. No se compila en Mac** (4)

- 502023614 CVE-2026-121199: Missing authorization in Chromoting
- 505177525 CVE-2026-121196: Privilege elevation in Mobile
- 570026368 CVE-2026-121077: Use after free in Mobile
- 562656015 CVE-2026-121116: Missing authorization in WebView

**G2. Función apagada o quitada en FlyWeb (comprobar)** (6)

- 540020706 CVE-2026-121255: Incorrect authorization in Autofill AI
- 565902952 CVE-2026-121215: UI misrepresentation in Bluetooth
- 513767200 CVE-2026-121234: Privilege elevation in Contacts
- 502385220 CVE-2026-121099: Information leak in PrivateTokens
- 513426189 CVE-2026-121115: Improper input validation in Shopping
- 569006789 CVE-2026-121110: UI misrepresentation in Shopping

**G3a. Renderer o GPU, memoria o fugas** (19)

- 511768565 CVE-2026-121256: Use of released resource in GPU
- 536516239 CVE-2026-121219: Integer overflow in GPU
- 536663516 CVE-2026-125349: Uninitialized resource in GPU
- 562221093 CVE-2026-121033: Uninitialized resource in GPU
- 566384898 CVE-2026-125342: Uninitialized resource in GPU
- 565681451 CVE-2026-121184: Out of bounds read in Media
- 568972975 CVE-2026-121223: Observable discrepancy in Media
- 568986882 CVE-2026-121176: Uninitialized resource in Media
- 497950736 CVE-2026-121031: Missing authorization in PDF
- 563359033 CVE-2026-121187: Observable discrepancy in Paint
- 569005114 CVE-2026-121158: Information leak in Paint
- 553130328 CVE-2026-121072: Uninitialized resource in Skia
- 564190098 CVE-2026-121132: Information leak in V8
- 565490229 CVE-2026-121096: Incomplete cleanup in V8
- 567169222 CVE-2026-121048: Race condition in V8
- 568010379 CVE-2026-121218: Type confusion in V8
- 570104009 CVE-2026-121049: Out of bounds read in V8
- 567611695 CVE-2026-121070: Use after free in WTF
- 553309390 CVE-2026-121170: Improper resource control in WebCodecs

**G3b. Resto alcanzable desde una web** (24)

- 496187630 CVE-2026-121062: Incorrect authorization in API
- 517435285 CVE-2026-121248: Incorrect authorization in API
- 495903812 CVE-2026-121161: Information leak in BackgroundFetch
- 500171457 CVE-2026-121108: Confused deputy in BackgroundFetch
- 499181801 CVE-2026-121063: Incorrect authorization in CacheStorage
- 553148542 CVE-2026-121040: Incorrect authorization in Core
- 553158297 CVE-2026-121220: Incorrect authorization in Core
- 553652456 CVE-2026-121059: Information leak in Core
- 563355450 CVE-2026-121239: Information leak in Core
- 566660676 CVE-2026-121212: Incorrect authorization in Core
- 479258455 CVE-2026-121244: UI misrepresentation in FileAPI
- 503201581 CVE-2026-121237: Improper state validation in FileSystem
- 571058818 CVE-2026-121105: Information leak in Network
- 562158081 CVE-2026-121088: Missing authorization in PerformanceAPIs
- 565092623 CVE-2026-121067: UI misrepresentation in PermissionElement
- 569012366 CVE-2026-121042: Incorrect authorization in Permissions
- 571195939 CVE-2026-121091: Incorrect authorization in Permissions
- 571960472 CVE-2026-121167: Incorrect authorization in Permissions
- 578671521 CVE-2026-121135: Security issue in Platform
- 492163889 CVE-2026-121120: Improper input validation in Prerender
- 568988525 CVE-2026-121128: Use after free in Scheduling
- 562225118 CVE-2026-121254: Information leak in Select
- 566683019 CVE-2026-121194: Missing authorization in SiteIsolation
- 566857543 CVE-2026-121242: Improper input validation in WebPackaging

**G4. Navegador (DevTools, extensiones, Autofill, permisos, interfaz…): caso por caso** (23)

- 566935544 CVE-2026-121202: Use after free in Autofill
- 570029913 CVE-2026-121245: Race condition in Autofill
- 556221528 CVE-2026-121163: Improper input validation in Browser
- 528485835 CVE-2026-121200: Incorrect reference resolution in DevTools
- 548943621 CVE-2026-121231: Incorrect authorization in DevTools
- 553145250 CVE-2026-121136: Missing authorization in DevTools
- 553152519 CVE-2026-121030: Incorrect authorization in DevTools
- 553154932 CVE-2026-121075: Missing authorization in DevTools
- 562233597 CVE-2026-121065: Incorrect authorization in DevTools
- 562238690 CVE-2026-121171: Confused deputy in DevTools
- 507351304 CVE-2026-121066: Incorrect authorization in Extensions
- 514542988 CVE-2026-121193: Incorrect authorization in Extensions
- 550245671 CVE-2026-121183: Incorrect authorization in Extensions
- 553138801 CVE-2026-121103: Incorrect authorization in Extensions
- 517448378 CVE-2026-121106: Information leak in Omnibox
- 514077956 CVE-2026-121177: UI misrepresentation in PageInfo
- 568978733 CVE-2026-121186: UI misrepresentation in Passwords
- 536163128 CVE-2026-121122: UI misrepresentation in Prompts
- 533454968 CVE-2026-121039: Incorrect authorization in Proxy Auth
- 569659190 CVE-2026-121238: Use after free in Source
- 567672825 CVE-2026-121257: Use after free in TabStrip
- 568999538 CVE-2026-121216: UI misrepresentation in UI
- 568972388 CVE-2026-121164: Incorrect authorization in Views
