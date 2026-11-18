# FlyWeb 3.1.4, parte 6: los bajos de Chrome 158 que aplican a Mac

SEGURIDAD-PORTES-28, 18-11-2026, por orden de COORDINACIÓN-49 (decisión de Titín, 18-11: en la 3.1.4 entra toda la
seguridad que aplica a Mac). Inventario de los 54 y motivos de lo que queda fuera: [`INVENTARIO.md`](INVENTARIO.md).
**Nada compilado: compila LOCAL-19 al final.**

**De 54 bajos: entran 35** (aquí), **2 ya estaban en la parte 4** y **17 quedan fuera** (8 no se compilan en Mac,
9 tocan código apagado o quitado en FlyWeb).

## Orden de aplicación y árboles (comprobados)

La parte 6 va **después de la parte 4** (que ya está en `main`): dos de los bajos (6c67a1fe y c06e1d94) son los
`parte4/chromium/0007` y `0018`, así que aquí no se repiten, y la época de caché de V8 sigue a la de la parte 4.
La parte 5 no estaba publicada al cerrar esta: la -26 la integra entre medias (orden 4 → 5 → 6).

| Repositorio | Base | Serie | Resultado |
|---|---|---|---|
| chromium | árbol `986d591616` + `parte4/chromium/` 0001–0018 = **`ef5cec7033`** | `chromium/` 0001–0032 | árbol **`e926f928cf`** (comprobado con `git am` de los 57 + 18 + 32 sobre `local/313` `7ccbc27cf7`) |
| brave-core | `15c050d35a` + `parte4/brave-core/0001` = **`d328e2f909`** | `brave-core/` 0001 (V8) | árbol **`6df05c3756`** (`git am`); V8 .66 con todos los `patches/v8`: **`d2c624130c`** (antes `a2d562e4b8`) |
| devtools-frontend | gitlink `904b77f9fc` + `parte4/devtools-frontend/0001` = `c70d811144` | `devtools-frontend/` 0001–0002 | árbol **`721e590a41`** |
| WebRTC | gitlink `19576e3787` + `3.1.5/webrtc/` 0001–0005 = `8ee111cf22` | `webrtc/` 0001 | árbol **`9b251c7cc7`** |
| libaom | gitlink `third_party/libaom/source/libaom` `016144ea8b` | `libaom/` 0001 | árbol **`26cdf2fc0d`** |
| libvpx | gitlink `third_party/libvpx/source/libvpx` `de61454cf8` | `libvpx/` 0001 | árbol **`fe13a1c827`** |

V8 sigue en el gitlink .66; ANGLE, Dawn, Skia, FFmpeg y PDFium no
cambian en esta parte. WebRTC, libaom, libvpx y devtools-frontend no tienen fork: LOCAL aplica sus carpetas con
`git am -3` en `src/third_party/...` y anota los hashes, como con ANGLE y WebRTC en las partes anteriores.

## chromium 0001–0032

«Limpio»: `git am` sin tocar nada, con sus pruebas. «Sin pruebas»: el código entra limpio y las pruebas chocan.

| Parche | Original | Bug | Qué | Cómo entra |
|---|---|---|---|---|
| 0001 | 87deb2e2 | 571722742 | Sanitizer: el atributo `is=` del elemento raíz también se sanea (`parseHTML`) | limpio |
| 0002 | 5cd7a5cb | 553259600 | DevTools: las cabeceras extra del lado del navegador solo si el cliente puede acceder a la URL (`MayAttachToURL`) | limpio |
| 0003 | e0b66956 | 553259600 | DevTools: sin cabeceras extra ni `Referer` falso del renderer para clientes no fiables (`chrome.debugger`) | limpio |
| 0004 | 07df9ad1 | 553136985 | DevTools: `scriptToEvaluateOnLoad` de `Page.reload` no corre en una página de error | limpio |
| 0005 | fceca5d3 | 562971921 | `chrome.csi()` y `chrome.loadTimes()` dan los valores redondeados de `Performance` | limpio |
| 0006 | 5095ebef | 506142100 | Extensiones: las rutas generadas (`_favicon`, página de fondo) exigen declararse en `web_accessible_resources` | sin pruebas |
| 0007 | 44be2964 | 474737096 | LNA: se bloquean las peticiones a la red local de `<link rel="prerender">` (NoStatePrefetch) | a mano: solo cambiaba el contexto final de `content_browser_client.{h,cc}` y `chrome_content_browser_client.{h,cc}`; con pruebas |
| 0008 | fad4d6c9 | 506142100 | Extensiones: lo anterior, encendido por defecto | limpio |
| 0009 | 7811f3b4 | 566504721 | Extensiones: los *popups* solo con URL `chrome-extension:` (no `blob:` ni `filesystem:`) | limpio |
| 0010 | fd5816cb | 511803678 | Descargas interceptadas: se conserva la `StoragePartition` del iniciador aunque se cierre el marco | limpio |
| 0011 | 66b8eb89 | 568979550 | DevTools: los orígenes prohibidos a sus extensiones se actualizan al cambiar el buscador (*reland* de 18077609) | sin pruebas |
| 0012 | 4cbb0608 | 562909022 | Elementos de capacidad (`<geolocation>`, *stable*): poda de motivos de bloqueo de clics caducados | limpio |
| 0013 | bdfe61c9 | 568576341 | DevTools: `StorageHandler` comprueba el acceso al origen antes de borrar o tocar la cuota | limpio |
| 0014 | b2f73173 | 502803648 | DevTools: las políticas de lista blanca/negra se aplican por marco y tras navegaciones del mismo documento | a mano: la 156 no tiene `DevToolsBlockReason`; la sobrecarga nueva queda como `IsInspectionAllowed(Profile*, RenderFrameHost*)` con la misma lógica; fuera el *unittest* (usa `GetDevToolsBlockReason`) |
| 0015 | f2d0bee9 | 506142100 | Extensiones: funciones comunes para reconocer las rutas generadas | limpio |
| 0016 | e1278b78 | 562957022 | Sensores: la inmunidad de los sensores virtuales (DevTools) se decide en el servicio de dispositivos | limpio |
| 0017 | cbc0babb | 513841847 | `chrome.debugger`: no se puede adjuntar al marco interno del PDF | a mano: solo el contexto inicial (la 156 declara `page_url` antes del bucle); con pruebas |
| 0018 | 62e6a3a7 | 573244957 | Copiar: sin marcado de intercambio ni `<span style>` dentro de MathML/SVG | a mano: solo el sitio de `SkipHtmlInterchangeInForeignContent` en el json5 (orden alfabético); con pruebas |
| 0019 | 75c0c828 | 553259600 | DevTools: se deshacen las cabeceras extra al redirigir a una URL restringida | a mano: un `#include` de contexto |
| 0020 | d6cb7844 | 553259600 | DevTools: User-Agent, `Accept-Language` y Client Hints emulados solo donde el cliente puede adjuntarse | limpio |
| 0021 | 8397133b | 562910021 | Política `HttpHeaderInjection`: aviso de seguridad en su descripción | limpio (solo texto) |
| 0022 | 190a65e0 | 392139161 | CSS en línea: las peticiones usan la política de *referrer* del documento | limpio |
| 0023 | b5776ae9 | 502048148 | Portapapeles: el marcado saneado pierde `<base>`, `<link>` y `<meta>` | limpio |
| 0024 | 850273ef | 575506658 | Menús de Views: guardas contra la reentrada de accesibilidad | a mano: la 156 no tiene mnemónicos de botón en menús (`match.button`); se quedan las guardas que aplican y la de `SelectByChar()`; con pruebas |
| 0025 | 473844a0 | 392139161 | CSS: la hoja de estilos del elemento se rehace si `<meta name="referrer">` cambia la política | limpio |
| 0026 | d59f8fb6 | 554558674 | DevTools «Abrir en pestaña nueva»: la navegación se atribuye a la página inspeccionada (no parece tecleada) | a mano: solo contexto (`#if` de Android) |
| 0027 | 9e42f026 | 575048405 | PiP automático solo desde el marco principal | limpio |
| 0028 | 2a144f74 | 521476204 | Contraseñas: `UserModifiedNonPasswordField` comprueba que el marco puede acceder | limpio |
| 0029 | 71b45ec0 | 514008162 | Contraseñas: usuario y nombre guardados por la web, en una sola línea en la interfaz | limpio |
| 0030 | 2665b0b2 | 550780268 | `tabCapture.getMediaStreamId()` respeta el acceso a incógnito | limpio |
| 0031 | c50c2dd3 | 564769937 | `image_annotation`: `AnnotateImage` privado, solo por Mojo | limpio |
| 0032 | a156403f | 513329281 | Red: una respuesta 1xx seguida de cierre del *socket* es un error, no un éxito | limpio |

Los parches hechos a mano llevan `(cherry picked from commit …)` y una línea `FlyWeb:` con lo que cambia.

## brave-core 0001 (V8)

Cuatro `patches/v8` nuevos sobre la .66, todos limpios (ninguno está en la 15.6): **0b3bd2b** (553263303),
**336a6b3** (568986689), **fb3bcc3** (572312093) y **0ac2b27** (574412712); detalle en
`patches/v8/FLYWEB-SECURITY.md`. **`kFlyWebCacheEpoch` 35 → 36** (0ac2b27 cambia el código de Maglev; la 35 es la de la
parte 4). Revisado contra la 15.6: `CppHeapExternal`, `UnwrapIdentities()`, `TryGetConstant(broker)`, los
*opcodes* `*ToString` y `UnparkedScopeIfNeeded(LocalIsolate*)` existen; las etiquetas de `cppheap-pointer-tag.h` son
internas de V8. **Necesita la d8/mjsunit de D8-LINUX** (la -26 junta el encargo): con y sin Maglev, sobre todo
`maglev/regress-574412712.js` y `maglev/*`; si corre la batería del inspector, `inspector/runtime/get-heap-usage.js`,
`get-isolate-id.js` y `regress/regress-crbug-568986689.js`.

## Terceros

| Parche | Original | Bug | Qué | Cómo entra |
|---|---|---|---|---|
| devtools-frontend 0001 | 42c22bbeaa | 553152636 | Una recarga aplazada no se repite si la página ya navegó a otro documento | limpio |
| devtools-frontend 0002 | 852dcde1bd | 569017013 | Los recursos (mapas de código) de un *service/shared worker* no se piden con el origen del marco principal | a mano: la 156 no tiene `#resolveFrameTarget`; la misma regla en `loadResource()` (un iniciador sin marco carga por su propio *target*); fuera la prueba (fija el comportamiento de la 157+) |
| webrtc 0001 | 326fd06bb4 | 513198336 | Al activar RTCP mux no se reinician las sesiones SRTP con las mismas claves (reutilización de *nonce*) | el código limpio (una línea en `ActivateRtcpMux()`); fuera la prueba y su `BUILD.gn` |
| libaom 0001 | e161f898a0 | 567944558 | Codificador AV1 en tiempo real: campos `mi` sin inicializar en `setup_planes` | el código limpio; fuera la prueba (`encode_api_test.cc` choca) |
| libvpx 0001 | 0a6d123f0c | 573760540 | VP9: los *buffers* del *denoiser* se rehacen al cambiar de resolución (desbordamiento) | el código y `svc_datarate_test.cc` limpios; fuera la prueba nueva de `encode_api_test.cc` |

En Mac se compilan los dos codificadores: libaom con `CONFIG_AV1_ENCODER` y `CONFIG_REALTIME_ONLY` (configuración
`linux`, que es la de Mac), y libvpx con `CONFIG_VP9_TEMPORAL_DENOISING` (`config/mac/x64`). Los usa WebRTC.

## Cruce con brave-core

- **`patches/`** (`git apply --check` sobre `e926f928cf`): siguen aplicando los de `navigation_request.cc`,
  `web_local_frame.h`, `web_local_frame_impl.h`, `document.cc` y `runtime_enabled_features.json5`. Ningún arreglo venía
  ya en un `.patch`.
- **`chromium_src/`** de los ficheros de la serie: `chrome_content_browser_client.cc` (macros de `HandleNewTabURL*`),
  `content_browser_client.h` (macro para sus virtuales), `navigation_request.cc`, `extension_features.cc`,
  `extension_urls.cc` (renombra `IsWebstoreUpdateUrl`), `document.cc`, `web_local_frame_impl.cc` y
  `html_meta_element.cc` (`ScriptEnabled()`, que 0025 no usa): ninguno redefine lo que cambia. El de
  `detect_javascript_frameworks.cc` deja vacía la detección: por eso 18c85439 queda fuera.
- brave-core no llama a ninguna función cuya firma cambia (NoStatePrefetch, DevTools, extensiones…) ni las sobrescribe.
- Los `#include` nuevos existen en el árbol, salvo los generados (`runtime_enabled_features.h`, `svg_names.h`,
  `mathml_names.h`, `performance_entry_names.h`). Las llamadas nuevas a APIs de fuera de cada parche (por ejemplo
  `cors::IsForbiddenRequestHeader` de Blink, `NavigationRequest::DidEncounterError()`,
  `base::i18n::EnsureTerminatedDirectionalFormatting`, `NavigateParams::FillNavigateParamsFromOpenURLParams`,
  `NavigationData::SetNavigationCapturingForceOff`, `InitiatorNavigationState`) existen en la 156 con esa firma.
- **Solape con la parte 4:** además de los dos duplicados, comparten fichero `extension_features.{cc,h}`,
  `ruleset_matcher_*` (DNR) y `web_app_url_loader*`; la serie se aplicó encima de la parte 4 sin conflictos. Con la
  parte 5 no se ha podido cruzar (no estaba publicada).
- **Huella:** igual que en Chrome 158. Visible para las webs: los valores de `chrome.csi()`/`chrome.loadTimes()` (0005,
  ahora redondeados como `performance`), la política de *referrer* en las peticiones del CSS en línea (0022, 0025) y el
  fallo de las respuestas 1xx sin respuesta final (0032). Nada toca TLS ni las cabeceras normales; las Client Hints
  solo en la emulación de DevTools (0020).

## Veredicto (regla 17): **APTO**

Revisado el código de cada parche contra la 156; los hechos a mano conservan lo que protege el original. Riesgos y
pruebas para LOCAL:
- **0006/0008/0015:** una extensión que exponía `_favicon` con un comodín `*` en `web_accessible_resources` deja de
  poder hacerlo sin declararlo (igual que en Chrome 158).
- **0007:** con la precarga de páginas activada, `<link rel="prerender">` ya no llega a la red local.
- **0009:** un *popup* de extensión con URL `blob:` o `filesystem:` deja de abrirse.
- **0014 (a mano):** con `DeveloperToolsAvailabilityBlocklist` en una política, abrir DevTools en una página permitida
  con un iframe bloqueado y probar `history.pushState` hacia una URL bloqueada.
- **0024 (a mano):** menú de la aplicación y menús contextuales de Views con VoiceOver.
- **0032:** red normal; un servidor que manda `103 Early Hints` y cierra sin respuesta final da error.
- **WebRTC, libaom, libvpx:** videollamada (p. ej. Jitsi Meet) con VP9 y AV1, cambiando de resolución (ventana o
  calidad) a mitad de llamada.
- **devtools-frontend 0002:** los mapas de código de un *service worker* se cargan con el origen del *worker*.
- **V8:** el verde de D8-LINUX (arriba).
- **0021:** cambia el texto inglés de la descripción de `HttpHeaderInjection`; su traducción en las plantillas de
  políticas queda en inglés hasta la siguiente actualización. No afecta a la interfaz del navegador.
- Pruebas: `browser_tests --gtest_filter='*DebuggerApiTest*:*DevToolsTest*:*LocalNetworkAccess*:*NoStatePrefetch*'`,
  `content_unittests --gtest_filter='*LocalNetworkAccess*:*SensorProvider*:*HttpNetworkTransaction*'`,
  `views_unittests --gtest_filter='MenuControllerTest.*'`, `extensions_unittests --gtest_filter='*WebAccessible*'`.

## Decisiones de COORDINACIÓN-49 (18-11, tras fusionar #1078)

1. **564769937 (image_annotation): 0777cdb316 fuera, porque la función está apagada en FlyWeb.** c50c2dd3, que es lo que
   lleva la 158, no cierra el fallo: la caché de anotaciones sigue sin partición por origen. Pero en FlyWeb no hay ninguna
   forma de activar las descripciones de imágenes de Google (pref `settings.a11y.enable_accessibility_image_labels`):
   - brave-core vacía `RenderViewContextMenu::AddAccessibilityLabelsServiceItem()`
     (`chromium_src/chrome/browser/renderer_context_menu/render_view_context_menu.cc`), así que el menú contextual no
     ofrece la opción;
   - la página de Accesibilidad de los ajustes no existe: `pageVisibility.a11y` = false en
     `browser/resources/settings/brave_overrides/page_visibility.ts`, y sin ella `route.ts` no crea `/accessibility`,
     que es donde está el otro interruptor;
   - brave-core no la enciende por ninguna otra vía; solo podría hacerlo un administrador con la política
     `AccessibilityImageLabelsEnabled`.
   Si algún día se enciende, 0777cdb316 entra con la 159.
2. **554558674 (DevTools «Abrir en pestaña nueva»): d59f8fb6 cierra el fallo reportado** (la navegación ya no parece
   tecleada). **2643f6e87f** y su *roll* de devtools-frontend arreglan otro bug, el 576204004 (la atribución a un iframe
   de otro sitio), que no está en la nota de la 158: **van a la tanda de la 159.**
