# FlyWeb 3.1.5: propuesta de triaje (medios de Chrome 158 y lo que quedó fuera de la 3.1.4)

SEGURIDAD-PORTES-25, 18-11-2026, por encargo de COORDINACIÓN-46. **Solo propuesta: nada portado ni mirado en el código.**
Los grupos salen del **componente que da la nota** de la 158 estable (17-11), no de leer cada arreglo; algún medio
cambiará de grupo al buscar su commit.

## Qué entra en el triaje

| Fuente | Nº | Nota |
|---|---|---|
| Medios de la nota de la 158 estable | 82 | anexo, por grupos. 573262234 (CVE-2026-130936, Media) **ya va en la 3.1.4** (0018 lo arregla con el mismo commit) |
| Rama 8078 después de la .110 | 6 [M156] + `VERSION` .111 | 859c5bc938 FSA en incógnito, d83ec3c16e FSA UNC (Windows: fuera), c404a3a5ff caché *sparse*, 7f43e52174 Streams, 39e958e23e `SyncLoadContext`, ba15fb1f7a WebCodecs. Congelar en el tag del día, como en la 3.1.4 |
| Medios de la 157 vistos al portar B5 | 2 | 568972975 (CVE-2026-121223, reintentos tras ORB: 8132e3a4c4 + b71ea276fd) y 571058818 (CVE-2026-121105, clave de `UrlIndex` por origen: 7b99dd29ba). **Mirar si las tandas de la 157 trajeron sus medios**; si no, hay más como estos |
| Media, encima de fb2af07952 en la 158 | 1 | `TrySetLength`/`HasCompatibleLength` y no reintentar respuestas de Service Worker (probablemente 573265164, CVE-2026-131026). Encaja sobre 0018 de la 3.1.4 |
| C de la 3.1.4 que hay que volver a mirar | 1 | CVE-2026-131081 (`kDisallowMixedOpaqueMediaResponses`): `main` lo **volvió a encender** el 03-11 (7046eb8893), tras 61b6e5652b y a4a389ea3b. Si la 159 estable sale con él encendido, se porta con esos dos |

## Propuesta

1. **Método:** el del `INVENTARIO.md` de la 3.1.4: para cada bug, su commit en la 158 (y en la 8078), `git apply --check`
   sobre el árbol de la 3.1.4 (`4e87f2898a`) y lectura del código. G1 y G2 se cierran comprobando un fichero o un
   interruptor, sin portar.
2. **Orden:** G3a (V8, ANGLE, WebGL, PDFium, PartitionAlloc, Color y Media: corrupción de memoria o fugas desde una
   web) → la rama 8078 tras la .110 → G3b → G4 → las piezas de Media de arriba.
3. **V8:** los 4 medios de V8 van con su d8/mjsunit (D8-LINUX) y suben la época de caché (regla de `SEGURIDAD.md`), como 659b8bf.
4. **Tamaño:** como la 3.1.4 (dos sesiones de SEGURIDAD-PORTES, una por parte), si G1 y G2 se descartan rápido.
5. **DBSC** (576306917): depende de la decisión pendiente de `brave-propio.md` (¿apagar Device Bound Session Credentials?); si se apaga, sale.

## Anexo: los 82 medios por grupo

**G1. Por el componente, no se compila en Mac (comprobar el fichero y descartar)** (11)

- 575090111 CVE-2026-131046: Improper input validation in ChromeDriver
- 574781794 CVE-2026-130929: Use after free in Chromoting
- 524422213 CVE-2026-131006: Race condition in CredentialProvider
- 568972475 CVE-2026-131015: Missing authorization in Mobile
- 574642315 CVE-2026-130913: Incorrect reference resolution in Mobile
- 575088323 CVE-2026-131071: Confused deputy in Mobile
- 575156577 CVE-2026-130928: Code injection in Mobile
- 574200170 CVE-2026-130930: Use after free in Ozone
- 576132156 CVE-2026-131003: Confused deputy in TabModel
- 513340629 CVE-2026-131020: Use after free in WebView
- 563348727 CVE-2026-131024: Incorrect authorization in iOSWeb

**G2. Apagado en FlyWeb: WebGPU (Dawn, Tint) y WebHID (comprobar el interruptor y descartar)** (3)

- 574211718 CVE-2026-131066: Uninitialized resource in Dawn
- 574199198 CVE-2026-131043: Use after free in HID
- 574310133 CVE-2026-131077: Out of bounds write in Tint

**G3a. Renderer o GPU con corrupción de memoria o fuga, alcanzable desde una web: primero** (14)

- 536599243 CVE-2026-130971: Out of bounds write in ANGLE
- 561073365 CVE-2026-131019: Information leak in ANGLE
- 571856431 CVE-2026-131061: Buffer overflow in Color
- 573262234 CVE-2026-130936: Information leak in Media
- 573265164 CVE-2026-131026: Information leak in Media
- 574311093 CVE-2026-130965: Uninitialized resource in Media
- 574897062 CVE-2026-130991: Uninitialized resource in Media
- 574302978 CVE-2026-130976: Use after free in PDFium
- 581351423 CVE-2026-131106: Buffer overflow in Partition
- 568908052 CVE-2026-130923: Out of bounds write in V8
- 571348848 CVE-2026-131087: Type confusion in V8
- 576225189 CVE-2026-131097: Missing authorization in V8
- 577305505 CVE-2026-130988: Out of bounds read in V8
- 551065275 CVE-2026-131069: Information leak in WebGL

**G3b. Resto de Blink, red y procesos de servicio alcanzables desde una web** (23)

- 574378401 CVE-2026-130938: Use after free in Accessibility
- 573257409 CVE-2026-131070: Information leak in DOM
- 574512015 CVE-2026-130985: Improper input validation in DOMStorage
- 574639489 CVE-2026-131038: Missing authorization in Editing
- 574640036 CVE-2026-131096: Missing authorization in Editing
- 574643395 CVE-2026-131017: Information leak in Editing
- 574757499 CVE-2026-130959: Missing authorization in FileSystem
- 514409956 CVE-2026-131048: Incorrect authorization in GetUserMedia
- 574508216 CVE-2026-131014: Confused deputy in Grid
- 568974861 CVE-2026-131053: Missing authorization in Layout
- 562227882 CVE-2026-130962: Incomplete cleanup in Navigation
- 568973728 CVE-2026-130937: Incorrect authorization in Navigation
- 574759287 CVE-2026-130933: Information leak in Paint
- 576312229 CVE-2026-130989: Missing authorization in Paint
- 561099685 CVE-2026-130990: Missing authorization in PersistentCache
- 575315727 CVE-2026-131078: Use after free in Proxy
- 574376000 CVE-2026-130905: UI misrepresentation in SVG
- 574858526 CVE-2026-131030: Privilege elevation in Sandbox
- 518239793 CVE-2026-131062: Improper synchronization in ScreenCapture
- 572721812 CVE-2026-130960: Use after free in Session
- 504552032 CVE-2026-130958: Uninitialized resource in WebRTC
- 574312303 CVE-2026-131086: Uninitialized resource in WebRTC
- 501901218 CVE-2026-131095: Information leak in Workers

**G4. Navegador (PWA, Autofill, Omnibox, extensiones, sync, interfaz, DBSC…): caso por caso** (31)

- 574502257 CVE-2026-131036: UI misrepresentation in Autofill
- 574587405 CVE-2026-130947: Integer overflow in Autofill
- 574594013 CVE-2026-130995: UI misrepresentation in Autofill
- 574635898 CVE-2026-131091: Missing authorization in Autofill
- 574639084 CVE-2026-130997: Incomplete cleanup in Autofill
- 574801551 CVE-2026-131067: Missing authorization in Autofill
- 569129183 CVE-2026-130917: Use after free in Browser
- 530046745 CVE-2026-131080: UI misrepresentation in Chromium
- 543907563 CVE-2026-131075: Improper input validation in DevTools
- 576306917 CVE-2026-131074: Use after free in DeviceBoundSessionCredentials
- 497617812 CVE-2026-130987: Race condition in Downloads
- 497744349 CVE-2026-130942: Observable discrepancy in Extensions
- 553159779 CVE-2026-131010: Use after free in Extensions
- 567673370 CVE-2026-130948: Use after free in Omnibox
- 576129731 CVE-2026-130969: Incorrect authorization in Omnibox
- 574299586 CVE-2026-131047: Race condition in ServiceManager
- 576859257 CVE-2026-131011: Use of uninitialized variable in Speech
- 556213137 CVE-2026-130986: Incorrect authorization in Sync
- 574508556 CVE-2026-131052: Race condition in UI
- 574901760 CVE-2026-131051: Incorrect authorization in UI
- 574909775 CVE-2026-131032: Confused deputy in UI
- 576387815 CVE-2026-130974: Use after free in UserEducation
- 553151406 CVE-2026-130992: Incorrect authorization in Views
- 562230299 CVE-2026-131000: Improper input validation in WebAppInstalls
- 573285920 CVE-2026-131056: Use after free in WebAppInstalls
- 574231826 CVE-2026-131028: Incorrect authorization in WebAppInstalls
- 574232164 CVE-2026-131064: Incorrect authorization in WebAppInstalls
- 574788166 CVE-2026-130956: Improper input validation in WebAppInstalls
- 574907939 CVE-2026-131058: UI misrepresentation in WebAppInstalls
- 575318301 CVE-2026-130924: Incorrect authorization in WebAppInstalls
- 574922639 CVE-2026-131094: Incorrect authorization in WebUI
