# FlyWeb 3.1.5: contenido (partes 1 y 2)

> **Esta carpeta es la parte 3 de la 3.1.4: no hay versión 3.1.5** (Titín, 18-11; DIRECTIVAS, #1061; COORDINACIÓN-47).
> Los parches se quedan con estas rutas y nombres (LOCAL-19 ya compila con ellas). **`brave-core/0002`
> (`flyweb_version` 3.1.4 → 3.1.5) NO se aplica**: la versión sigue en 3.1.4. Sí se aplican `chromium/` 0001–0027,
> `webrtc/` 0001–0005 y `brave-core/0001` (V8, época 33). Orden completo y árboles finales, en
> [`../3.1.4/CONTENIDO.md`](../3.1.4/CONTENIDO.md), «Orden de aplicación completo».

SEGURIDAD-PORTES-25, 18-11-2026, por orden de COORDINACIÓN-47 (18-11 ~10:06): primero G3a de
[`PROPUESTA-MEDIOS.md`](PROPUESTA-MEDIOS.md), los [M156] de la 8078 posteriores a la .110, los dos medios de Media de
la 157 y el arreglo de Media de la 158 encima de fb2af07952; luego G3b; G4 al final (solo lo alcanzable sin
interacción del usuario); G1 y G2 fuera. **Nada compilado por mí.** **Parte 1 = todo lo de (1).** G3b y G4 quedan para
el relevo (abajo, «Pendiente»).

## Base y resultado (comprobados)

| Repositorio | Base | Serie | Resultado |
|---|---|---|---|
| chromium | 3.1.4: `local/313` `7ccbc27cf7` + `3.1.4/chromium` 0001–0026 (árbol `4e87f2898a`) | `chromium/` 0001–0013 | árbol **`2248183916`** (comprobado: `git am` de 3.1.4 0001–0026 y 3.1.5 0001–0013 sobre `local/313`) |
| V8 | 15.6.75.66 (`917584bd93`), sin cambio de gitlink | `patches/v8` de brave-core | con todos los `patches/v8`: árbol de V8 `ecf31d79a4` |
| brave-core | 3.1.4: `seg/3.1.4` `d91632790084` + `3.1.4/brave-core` 0003 (árbol `71e60c4558`) | `brave-core/` 0001–0002 (`.patch`: sin push a brave-core) | árbol **`e95338d8c9`** |

ANGLE, Dawn, FFmpeg, Skia y PDFium no cambian.

## G3a: los 14 medios de la 158

| Bug | CVE | Arreglo | Resultado |
|---|---|---|---|
| 568908052 | CVE-2026-130923 (V8) | 1942561 | **no aplica:** solo cambia la pila por defecto en Android |
| 571348848 | CVE-2026-131087 (V8) | 19048d3 | **entra** (brave-core 0001) |
| 576225189 | CVE-2026-131097 (V8) | 33ab43a | **entra** (brave-core 0001) |
| 577305505 | CVE-2026-130988 (V8) | 65afc9f | **entra** (brave-core 0001) |
| 536599243 | CVE-2026-130971 (ANGLE) | ANGLE 7f60c15 | **no aplica:** Vulkan |
| 561073365 | CVE-2026-131019 (ANGLE) | ANGLE 16cbe9b | **no aplica:** D3D11 |
| 551065275 | CVE-2026-131069 (WebGL) | ANGLE b40b594 | **no aplica:** el remedio (`recreateFboOnAttachmentRespecification`) solo se enciende en PowerVR, también en el respaldo GL |
| 571856431 | CVE-2026-131061 (Color) | fceb2ab8ad | **no aplica:** `components/eye_dropper` no existe en la 156 y el cuentagotas de Mac usa `NSColorSampler` (`eye_dropper_view_mac.mm`), no captura de fotogramas |
| 574302978 | CVE-2026-130976 (PDFium) | roll 26de93f124 (`~CFXJSE_FormCalcContext`) | **no aplica:** FormCalc es XFA, apagado en FlyWeb |
| 573262234 | CVE-2026-130936 (Media) | fb2af07952 | ya en la 3.1.4 (0018) |
| 573265164 | CVE-2026-131026 (Media) | daa730f185 | **entra** (0005) |
| 574311093, 574897062 | CVE-2026-130965, -130991 (Media) | 6a24d88908 | **entra** (0006), limpio |
| 581351423 | CVE-2026-131106 (Partition) | 367ca4e725 | **entra** (0007), limpio: el `fill_n` sin comprobar pasa a `base::span` (cierre controlado en vez de desbordamiento) |

## chromium 0001–0013

| Parche | Original | Bug / CVE | Qué | Cómo entra |
|---|---|---|---|---|
| 0001 | b71ea276fd | 40257965 | Media: los bloqueos de ORB cuentan como origen cruzado | limpio |
| 0002 | 8132e3a4c4 | 568972975, CVE-2026-121223 (medio de la 157) | Media: no reintentar peticiones bloqueadas por ORB | limpio (3 vías) |
| 0003 | dbd22daebd | 573253732 (sin CVE en las notas) | Media: no reintentar fallos deterministas (CORP/COEP, CORS, certificados): el ritmo de reintentos delataba si el servidor de otro origen respondía 206 o 416 | limpio |
| 0004 | propio | — | Media: `UrlData::CrossOriginFail()`, la parte de fb2af07952 que la 3.1.4 dejó fuera porque `DidFail()` no tenía aún el bloque de ORB | propio |
| 0005 | daa730f185 | 573265164, CVE-2026-131026 | Media: longitud coherente entre respuestas (`TrySetLength`/`HasCompatibleLength`) y no reintentar fallos de Service Worker | a mano solo `MergeFrom()` (con el 61b6e5652b de la 3.1.4) y la prueba de `TryInsert` (solo el caso de longitud) |
| 0006 | 6a24d88908 | 574311093, 574897062 | Media: píxeles sin inicializar en `ConvertVideoFrameToRGBPixels()` | limpio, con pruebas |
| 0007 | 367ca4e725 | 581351423, CVE-2026-131106 | PartitionAlloc: `PartitionPurgeSlotSpan` con `base::span` | limpio |
| 0008 | ba15fb1f7a [M156] | 576082223, 580866733, 578659916 | WebCodecs: *callbacks* por el *task runner* del contexto | limpio, `patch-id` igual |
| 0009 | 39e958e23e [M156] | 579277904 | `SyncLoadContext`: aplazar el final durante las redirecciones | limpio, `patch-id` igual |
| 0010 | 7f43e52174 [M156] | 582927496 | Streams: caché de las funciones de tamaño | 3 vías; ficheros resultantes **idénticos** a los de upstream (comprobado con gitiles) |
| 0011 | c404a3a5ff [M156] | 584997533 | Caché HTTP: validar entradas *sparse* antes de servir peticiones que necesitan red | limpio, `patch-id` igual |
| 0012 | d83ec3c16e [M156] | — | FSA: rutas UNC de escritorio remoto | limpio; solo Windows, inocuo en Mac (va porque comparte fichero con 0013) |
| 0013 | 859c5bc938 [M156] | 571250973 | FSA: sin resolución de rutas de la plataforma en incógnito | limpio, `patch-id` igual |

**Media, después de 0001–0005:** `resource_multi_buffer_data_provider.{cc,h}` quedan como en **158.0.8127.65** salvo la
clave de `UrlIndex` por origen (7b99dd29ba) y nombres de parámetros; `url_index.{cc,h}`, como la 158 más 61b6e5652b y sin
`kDisallowMixedOpaqueMediaResponses` (apagada en la 158).

**No portado: 7b99dd29ba** (571058818, CVE-2026-121105, medio de la 157, clave de `UrlIndex` por el origen del
documento). Choca con el constructor de `WebMediaPlayerImpl` (`WebLocalFrame*` frente a `FrameScheduler*` + origen +
URL y título del documento), así que habría que tocar también a todos los que lo crean. Upstream lo justifica con WebView
sin aislamiento de sitios; en escritorio, con aislamiento de sitios, solo afecta a documentos del mismo sitio y distinto
origen en un mismo proceso. Riesgo bajo; **lo decide COORDINACIÓN**.

**8078 tras la .110:** congelada en la **punta de la rama al empezar, `859c5bc938` (08:50 UTC del 18-11), sin tag**: la
.111 aún no lo tiene (`ls-remote` 10:14 UTC). Los parches salen de gitiles (`+/<sha>%5E%21/?format=TEXT`), porque el
espejo de GitHub solo tiene los tags. **`chrome/VERSION` se queda en .110**: no se declara una versión que Google no ha
publicado. Cuando salga la .111, cruzarla con 0008–0013 y subir `VERSION`.

## brave-core 0001–0002

| Parche | Qué |
|---|---|
| 0001 | `patches/v8`: 19048d3, 33ab43a y 65afc9f (limpios sobre la .66 con los `patches/v8` existentes) con sus tres pruebas de mjsunit; `kFlyWebCacheEpoch` 32 → **33**; nota en `patches/v8/FLYWEB-SECURITY.md` |
| 0002 | `flyweb_version` 3.1.4 → **3.1.5** |

**d8/mjsunit:** pedido a D8-LINUX por buzón, junto con el 659b8bf de la 3.1.4. **Sin el verde, 0001 no entra.**

## Cruce con brave-core

- `patches/` y `chromium_src/`: ninguno de los 48 ficheros de la serie tiene `.patch` ni `chromium_src` en brave-core.
- Los `#include` nuevos existen en el árbol, salvo los generados (`url_response_head.mojom.h`, `v8_encoded_video_chunk.h`,
  `v8_video_encoder_support.h`).
- **Huella:** 0011 cambia cuándo se sirve una entrada *sparse* de la caché HTTP (validación previa, como Chrome 156
  .111); nada toca TLS, cabeceras ni Client Hints.

## Veredicto (regla 17): **APTO**, parte 1

Revisado el código de cada parche contra la 156. Riesgos para LOCAL:
- **Media (0001–0005):** más fallos sin reintentos y comprobación de longitud. Pruebas:
  `blink_platform_unittests --gtest_filter='UrlIndexTest.*:ResourceMultiBufferDataProviderTest.*:MultiBufferDataSourceTest.*'`;
  y a mano: vídeo con saltos (YouTube 720p, Vimeo), audio de otro origen (radio en línea) y un vídeo servido por un
  Service Worker (p. ej. una PWA sin conexión).
- **0006:** `media_unittests --gtest_filter='PaintCanvasVideoRendererTest.*'`; vídeo en `<canvas>` (`drawImage` de un
  `<video>`) y WebGL con vídeo.
- **0008:** WebCodecs (`VideoEncoder`/`VideoDecoder`) en una demo de codificación.
- **0011:** vídeo largo con saltos y recarga (la caché *sparse* es la de los rangos de media).
- **V8:** el verde de D8-LINUX.

# Parte 2: G3b y G4

SEGURIDAD-PORTES-26, 18-11-2026, por orden de COORDINACIÓN-47: G3b (23 medios de la 158 alcanzables desde una web) y,
al final, G4 solo si es alcanzable sin interacción del usuario. G1 y G2, fuera. **Nada compilado por mí.**

## Base y resultado (comprobados)

| Repositorio | Base | Serie | Resultado |
|---|---|---|---|
| chromium | parte 1, árbol `2248183916` | `chromium/` 0014–0027 | árbol **`2aa2917c76`** (comprobado: `git am` de 3.1.4 0001–0026 y 3.1.5 0001–0027 sobre `local/313` `7ccbc27cf7`) |
| WebRTC | gitlink `third_party/webrtc` = `19576e3787` (`[M156] Fail EncodeFec…`) | `webrtc/` 0001–0005 (nuevo: sin fork, como ANGLE y FFmpeg) | árbol **`8ee111cf22`** (comprobado con `git am`) |
| brave-core | parte 1 (árbol `e95338d8c9`) | ninguno | sin cambios |

V8, ANGLE, Dawn, FFmpeg, Skia y PDFium no cambian. WebRTC no tiene fork: LOCAL aplica `webrtc/` en
`src/third_party/webrtc` de su checkout (`git am -3`) y anota el hash, como con ANGLE.

## G3b: los 23 medios

Commits buscados con `search/commits` en `chromium/chromium`; los dos de WebRTC, en el espejo `chenjim/webrtc-mirror`
(webrtc.googlesource.com no responde desde la nube), con la base de la 156 sacada de `GetStream/webrtc`.

| Bug | CVE | Arreglo | Resultado |
|---|---|---|---|
| 574378401 | CVE-2026-130938 (Accessibility) | a752502d1c | **no aplica:** reentrada por las notificaciones COM síncronas de Windows; en Mac se publican sin volver a entrar |
| 573257409 | CVE-2026-131070 (DOM) | 342a8c8e8d | **no aplica:** HTML-in-canvas (`kCanvasDrawElement` y su *origin trial*, apagados desde la 3.0.1) |
| 574512015 | CVE-2026-130985 (DOMStorage) | ac19329a1d | **entra** (0014), limpio. brave-core no crea espacios de `sessionStorage` propios |
| 574639489 | CVE-2026-131038 (Editing) | dedf2af3b4 | **entra** (0015), limpio |
| 574640036 | CVE-2026-131096 (Editing) | 6778fee622 | **entra** (0016), limpio |
| 574643395 | CVE-2026-131017 (Editing) | 0c67400dae | **entra** (0017), limpio; más 0441415b72 (0027, bug 578051925: lo mismo en `<input>` de fecha y hora, CSS del agente) |
| 574757499 | CVE-2026-130959 (FileSystem) | 71ea1e9367 | **entra** (0018), limpio |
| 514409956 | CVE-2026-131048 (GetUserMedia) | 3f27027303 | **entra** (0019), limpio |
| 574508216 | CVE-2026-131014 (Grid) | e336ff2faf | **no aplica:** Android |
| 568974861 | CVE-2026-131053 (Layout) | b7a77bd3bd | **entra** (0020); a mano solo el contador de uso (6043; la 156 llega a 6032), `enums.xml` y el sitio en el json5 |
| 562227882, 568973728 | CVE-2026-130962, -130937 (Navigation) | f6eec9bc71, ddf55f8740 | **no aplica:** iOS |
| 574759287, 576312229 | CVE-2026-130933, -130989 (Paint) | cb30ba132b, b145a8cd47 | **no aplica:** HTML-in-canvas, apagado |
| 561099685 | CVE-2026-130990 (PersistentCache) | f8cc87d0f3 | **ya estaba en `navigation_request.cc`:** brave-core lleva las mismas dos comprobaciones de `IsPdf()` en `patches/content-browser-renderer_host-navigation_request.cc.patch`. Entra solo el `CHECK` del interceptor y la prueba (0021) |
| 575315727 | CVE-2026-131078 (Proxy) | 6302e4036c | **entra** (0022), limpio: endurecimiento de las cadenas del PAC que se pasan a V8 |
| 574376000 | CVE-2026-130905 (SVG) | bd7c91ecec | **entra** (0023), limpio (`SkOpBuilder::resolve()` con `std::optional` ya está en nuestro Skia) |
| 574858526 | CVE-2026-131030 (Sandbox) | e24ae5afd7 | **entra** (0024); a mano solo el `define` de `common.sb` (sin el de WebNN, que la 156 no tiene) |
| 518239793 | CVE-2026-131062 (ScreenCapture) | 9c3d844f5c | **entra** (0025), limpio. Inerte por defecto: `kUseSCContentSharingPicker` está apagado en la 156 (upstream lo enciende el 17-11) |
| 572721812 | CVE-2026-130960 (Session) | f37c432e41 | **no aplica:** Read Aloud solo se compila en Android |
| 504552032 | CVE-2026-130958 (WebRTC) | WebRTC f30a911f67 | **entra** (webrtc 0005); a mano solo `BUILD.gn` de pruebas |
| 574312303 | CVE-2026-131086 (WebRTC) | WebRTC 3cdeaaaff3, f7126d621e, ad255b4e05 | **entra** (webrtc 0001, 0003, 0004) con bd5625b05c (0002, bug 569701823: vuelve la comprobación de 12 bits en VP9, que 3cdeaaaff3 necesita de contexto); `BUILD.gn` de pruebas a mano |
| 501901218 | CVE-2026-131095 (Workers) | 6da616e5ce | **entra** (0026); a mano `ExecutionContext::DispatchErrorEvent()`, porque la 156 ya vacía la cola con `is_draining_pending_exceptions_`: se conserva y la cola pasa a pares (evento, saneado) |

## chromium 0014–0027

| Parche | Original | Bug / CVE | Qué |
|---|---|---|---|
| 0014 | ac19329a1d | 574512015, CVE-2026-130985 | `sessionStorage`: el navegador valida que los id de espacio que manda el renderer sean UUID |
| 0015 | dedf2af3b4 | 574639489, CVE-2026-131038 | Copiar en un documento de imagen no exporta píxeles de otro origen |
| 0016 | 6778fee622 | 574640036, CVE-2026-131096 | Un `<canvas>` contaminado no se exporta al portapapeles ni como URL de datos |
| 0017 | 0c67400dae | 574643395, CVE-2026-131017 | La vista previa del autorrelleno en `<select>` no se puede seleccionar ni arrastrar |
| 0018 | 71ea1e9367 | 574757499, CVE-2026-130959 | FSA: serializar un *handle* exige su `StorageKey` y guarda el origen |
| 0019 | 3f27027303 | 514409956, CVE-2026-131048 | Captura de vídeo: `StopSession` cierra todos los clientes de la sesión |
| 0020 | b7a77bd3bd | 568974861, CVE-2026-131053 | View Transitions: su contenido no se pinta bajo filtros SVG de referencia (fuga de píxeles de iframes de otro origen) |
| 0021 | f8cc87d0f3 (parte) | 561099685, CVE-2026-130990 | `CHECK(!request_info.is_pdf)` en el interceptor de Service Worker (el resto ya lo pone brave-core) |
| 0022 | 6302e4036c | 575315727, CVE-2026-131078 | PAC: `CHECK` si V8 libera una cadena externa que aún tiene bloqueada |
| 0023 | bd7c91ecec | 574376000, CVE-2026-130905 | SVG: si falla la unión de los trazados de `<clipPath>`, se usa la máscara |
| 0024 | e24ae5afd7 | 574858526, CVE-2026-131030 | *Sandbox* del renderer: `process-info-pidinfo` solo sobre sí mismo (interruptor `MacSandboxAllowRendererPidinfo`, apagado) |
| 0025 | 9c3d844f5c | 518239793, CVE-2026-131062 | Selector de captura de macOS 14+: rechaza un segundo `Open()` mientras hay uno abierto |
| 0026 | 6da616e5ce | 501901218, CVE-2026-131095 | Workers: los errores de scripts de otro origen llegan saneados al documento (`SanitizeWorkerErrorPropagation`, estable) |
| 0027 | 0441415b72 | 578051925 (sin CVE en la nota) | Lo de 0017 para la vista previa en `<input>` de fecha y hora |

## webrtc 0001–0005

| Parche | Original | Bug | Qué |
|---|---|---|---|
| 0001 | ad255b4e05 | 574312303 | Detección de corrupción: tratar el fallo de conversión a I420 |
| 0002 | bd5625b05c | 569701823 | VP9: rechazar los fotogramas de 12 bits (se envolvían como de 10) |
| 0003 | 3cdeaaaff3 | 574312303, CVE-2026-131086 | Límite `kMaxFrameSidePixels` en los descodificadores (dav1d, VP9, H.264) |
| 0004 | f7126d621e | 574312303 | Comprobar lo que devuelve libyuv en las conversiones (`ToI420()` puede devolver `nullptr`) |
| 0005 | f30a911f67 | 504552032, CVE-2026-130958 | Búferes de 10 bits a cero en `VideoFrameBufferPool` |

Los descodificadores por software de WebRTC son los que usa Chromium en una `RTCPeerConnection` cuando no hay
descodificación por hardware: una web los alcanza recibiendo vídeo, sin permisos.

## G4: los 31 medios

**Ninguno entra.** Sin interacción del usuario solo se alcanza DBSC, y no por defecto:

| Grupo | Bugs | Motivo |
|---|---|---|
| Android, iOS, Linux/Ozone | 574587405, 574639084, 574594013, 530046745, 574508556, 574909775, 576859257, 574901760 | no se compila en Mac (574901760: arrastres táctiles) |
| DBSC | 576306917 (5a632f86a4) | DBSC está encendido en Mac (también en brave-core), pero la clave de atestación solo se pide con `DeviceBoundSessionsForSingleSignOn`, apagada. Limpio (9 líneas) si COORDINACIÓN lo quiere como defensa. Sigue abierta la decisión de `brave-propio.md` sobre apagar DBSC |
| Con interacción | 574502257, 574635898, 574801551 (autorrelleno), 569129183 (salir de pantalla completa: entrar exige gesto), 543907563 (DevTools), 497617812 (Guardar página), 553151406 (arrastres con el ratón), 576387815 (promociones de la interfaz), 574922639 (modo lectura) | exigen una acción del usuario |
| Instalar algo | 497744349 (DNR), 574299586 (desempaquetar extensiones), 553159779 (Chrome Apps), 562230299, 573285920, 574231826, 574232164, 574907939 (PWA) | exigen instalar una extensión o una aplicación |
| Apagado en la 156 / FlyWeb | 567673370, 576129731 (Omnibox Everywhere), 574788166, 575318301 (Isolated Web Apps) | no se usa |
| Sync | 556213137 (continuidad de claves Nigori) | el atacante sería el servidor de sync, que es el nuestro; no lo alcanza una web |

## Cruce con brave-core (parte 2)

- `patches/`: se aplican con `git apply --check` sobre `2aa2917c76` los de `clipboard_commands.cc`, `html_canvas_element.cc`,
  `local_dom_window.cc`, `runtime_enabled_features.json5` y `navigation_request.cc` (este, porque 0021 ya no toca ese fichero).
- `chromium_src/` de esos mismos ficheros: no redefinen nada de lo que cambia; el de `html_canvas_element.cc` engancha `ToDataURLInternal()` (farbling), al que 0016 sigue llamando, ahora solo con el canvas limpio.
- Los `#include` nuevos existen en el árbol, salvo los generados (`html_names.h`, `runtime_enabled_features.h` y su ayudante de pruebas).
- Arreglos posteriores de upstream (`search/commits` por las funciones tocadas, después de cada arreglo): solo 0441415b72
  (añadido como 0027) y, para 0025, c76fb7573d, que no hace falta con el selector apagado.
- **Huella:** nada toca TLS, cabeceras ni Client Hints. Visible para las webs, igual que en Chrome 158: el error saneado
  de los *workers* de otro origen (0026) y la falta de filtro SVG en el contenido de una transición (0020, con aviso de
  obsolescencia en la consola).

## Veredicto (regla 17): **APTO**, parte 2

Revisado el código de cada parche contra la 156. Riesgos para LOCAL:
- **0024 (*sandbox*), el único que puede romper algo en Mojave:** upstream lo da por bueno desde macOS 12. En la 5,1 o la
  6,1, abrir páginas normales, vídeo y WebGL con `--enable-sandbox-logging` y buscar en Consola denegaciones de
  `process-info-pidinfo` del renderer (o caídas). Si las hay, el remedio sin recompilar es
  `--enable-features=MacSandboxAllowRendererPidinfo` y avisarme.
- **0018:** los *handles* locales de FSA guardados en IndexedDB antes de la 3.1.5 dejan de recuperarse (no llevan el
  origen); los de OPFS no cambian. Igual que en Chrome 158; en FlyWeb, con el selector de ficheros de FSA apagado, apenas se nota.
- **0026:** cambia una firma virtual en Blink (`ExceptionThrown`, `ReportException`); si falla al compilar, es un
  `override` que no vi (en la 156 están todos los de upstream).
- **0020:** una transición de vista con `filter: url(#…)` en sus pseudoelementos se pinta sin el filtro.
- **WebRTC:** videollamada con VP9 y AV1 (p. ej. Jitsi Meet), incluida una con resolución alta.
- Pruebas: `blink_unit_tests --gtest_filter='ViewTransitionTest.*:*ErrorEvent*:DedicatedWorkerTest.*'`,
  `content_unittests --gtest_filter='VideoCaptureControllerTest.*:FileSystemAccessManagerImplTest.*'`.

## Pendiente (relevo)

1. **Medios de la 157** (`MEDIOS-157.md`): inventario por grupos, sin portar; falta buscar los commits. Solo si COORDINACIÓN lo pide.
2. CVE-2026-131081: vigilar la 159 estable (`kDisallowMixedOpaqueMediaResponses`). A las 10:50 UTC del 18-11, la 159 solo tiene etiquetas de desarrollo (8128–8130).
3. D8-LINUX: verde de 659b8bf (3.1.4) y de brave-core 0001 (3.1.5). Sin respuesta en el buzón a las 10:50 UTC.
4. `chrome/VERSION` .111: sin tag a las 10:50 UTC (la punta de la 8078 sigue en `859c5bc938`). Cuando salga, cruzarla con 0008–0013.
5. 7b99dd29ba: **fuera de la 3.1.5** (COORDINACIÓN-47 con el sí de SEGURIDAD-PORTES-26, 18-11). Se reabre si sale en KEV o en una Extended de la 156.
6. DBSC (576306917): opcional, si COORDINACIÓN lo quiere como defensa.
