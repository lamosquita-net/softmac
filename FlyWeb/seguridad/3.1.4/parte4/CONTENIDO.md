# FlyWeb 3.1.4, parte 4: los medios de G4 que aplican a Mac

SEGURIDAD-PORTES-26, 18-11-2026, por orden de COORDINACIÓN-49 (decisión de Titín, ~15:15 UTC: en la 3.1.4 entra toda la
seguridad que aplica a Mac). Lista de partida: G4 de `../../3.1.5/CONTENIDO.md` (con interacción, instalar algo, Nigori,
DBSC) más 7b99dd29ba (571058818). 0001–0014, SEGURIDAD-PORTES-26; 0015, 0016 y devtools-frontend 0001,
SEGURIDAD-PORTES-29 (18-11). **Nada compilado: compila LOCAL-19 una vez al final (build 47).**

## Base y resultado (comprobados)

| Repositorio | Base | Serie | Resultado |
|---|---|---|---|
| chromium | árbol `986d591616` (3.1.4 0001–0026 + 3.1.5 0001–0031 sobre `local/313`) | `chromium/` 0001–0016 | árbol **`ff1325f5c1`** (comprobado con `git am` de los 16; 0001–0014 solos: `031ab4cda4`) |
| devtools-frontend | gitlink `third_party/devtools-frontend/src` `904b77f9fc` (el de `local/313`, sin cambios en las series) | `devtools-frontend/` 0001 | árbol **`c70d811144`** (comprobado con `git apply --cached` sobre el gitlink) |

## Hecho

| Parche | Original | Bug | Qué | Cómo entra |
|---|---|---|---|---|
| 0001 | 8434c55c70 | 574502257 | Autofill: la caja del popup se recorta contra la vista del marco y la de todos sus antecesores | a mano: en la 156 `Lift()` solo hacía `InclusiveIntersect`; se toma la función de upstream; sin la prueba de navegador nueva. 79c3a525e8 (refactor) y dcccf638e0 (pruebas) no hacen falta |
| 0002 | 677776cf3a | 574635898 | Autofill: se oculta el popup de `datalist` si cambia el campo o la sesión | limpio |
| 0003 | 565e091ce6 | 574801551 | Autofill: `BatchDataListOptionChange()` solo refresca con el popup visible y el campo enfocado | limpio |
| 0004 | 947c1f25f5 | 497617812 | Descargas («Guardar página»): se ignoran mensajes del serializador que llegan tarde | limpio |
| 0005 | 936e490a13 | 574922639 | Modo lectura: más comprobaciones de `IsErrorDocument` | limpio |
| 0006 | 9f3a5953b4 | 553159779 | Chrome Apps: `AppWindow` destruida durante `Show()` | limpio |
| 0007 | 6c67a1fe34 | 562230299 | WebApp: `DidFinishLoad` exige una navegación confirmada | limpio |
| 0008 | 5a632f86a4 | 576306917 | DBSC: salir si generar la clave de atestación borra el *fetcher* | limpio |
| 0009 | a70846b451 | 569129183 | Pantalla completa: `CHECK` de que el `WebContents` sigue vivo al salir | prueba fuera (choque solo en el *unittest*) |
| 0010 | 90109b3ca4 | 556213137 | Sync: continuidad de claves de Nigori también al descifrar el *keybag* en línea | pruebas nuevas del *bridge* fuera (choque en el *unittest*) |
| 0011 | f24ed89b65 | 576387815 | User Education: `ShowPromoInPage` reestructurado para no usar memoria liberada | `show_promo_in_page.cc` entero de upstream (la 156 solo difería en `DCHECK` frente a `CHECK`) |
| 0012 | 7a0c3eee10 | 574299586 | Extensiones: revocar la capacidad de directorio tras descomprimir y verificar el manifiesto recargado | a mano solo `extension_features.cc` (sin la *feature* de DNR) y `enums.xml` |
| 0013 | fe08d53551 | 573285920, 574907939 | PWA: reutilizar una ventana de app en redirecciones capturadas solo si se puede | a mano el `CHECK` (la 156 tiene `DCHECK` en vez de `CHECK(NotFatalUntil)`) |
| 0014 | e41efb6d0e | 574231826, 574232164 | PWA: no entregar `LaunchParams` a un documento de origen opaco ni a otra app | prueba de `launch_queue` fuera |
| 0015 | 7b99dd29ba | 571058818 (CVE-2026-121105) | Medios: la clave de `UrlIndex` lleva el `SecurityOrigin` del documento que pide; `MergeFrom()` exige el mismo origen; las redirecciones conservan origen y `encoding_mode` | a mano: el constructor de `WebMediaPlayerImpl` sigue con `WebLocalFrame*` (upstream: `FrameScheduler*` + origen) y el miembro nuevo `security_origin_` sale de `frame->GetSecurityOrigin()` (el objeto del documento: la clave por puntero se mantiene entre reproductores del mismo documento); el `CHECK` de origen va delante de las comprobaciones de nuestro 0018 y de 61b6e5652b; en la prueba nueva de `url_index`, `SetDataOrigin()` en vez de `set_is_cors_cross_origin()` (privado en la 156) |
| 0016 | 22a2af917b | 497744349, 549603220 | DNR: las reglas que miran el valor de cabeceras de respuesta (salvo las *CORS-safelisted* y `Content-Encoding`) exigen permiso de host; sin él se saltan al casar. *Feature* `kDeclarativeNetRequestRestrictResponseHeaderValueMatching` (activa; la que se dejó fuera de 0012). Sube `kIndexedRulesetFormatVersion` (se reindexan las reglas) | a mano: `DoEmbedderConditionsMatch()` de la 156 no recibe la URL (llegó con b878de30c0), así que solo se añade `has_host_access`; `OnDidFinishNavigation()` de la 156 no tiene la rama de documentos de error (c06e1d94a2): `has_host_access` se pone en sus dos `RequestParams`. Fuera las 2 pruebas que chocaban en `ruleset_matcher_unittest.cc` (junto a las de esos dos commits) |

**devtools-frontend 0001** = fb515cf1b1 (543907563, CVE-2026-131075; llega a Chromium en el *roll* 404327b549): `openInNewTab`
solo abre esquemas web salvo `allowPrivileged`; los `href` de `<a>` del árbol DOM con esquema privilegiado
(`devtools:`, `chrome:`, `file:`…) dejan de ser enlaces. Limpio; el cambio de `DOMTreeElementWidget.ts` cae en
`ElementsTreeElement.ts` (nombre de la 156). El resto del *roll* (4 de compilación de cadenas, 576211357) no es seguridad.
Se aplica en `src/third_party/devtools-frontend/src` como ANGLE: `git am` sobre el gitlink.

**No aplican en Mac:** 553151406 (39597dfb3d, a9ee282a53, f2e3cb42e0): son de Aura y de Linux (`web_contents_view_aura`,
`desktop_window_tree_host_linux`); en Mac el arrastre del contenido va por `WebContentsViewMac`.

Cruce con brave-core: `patches/components-sync-protocol-proto_visitors.h.patch` aplica sobre `031ab4cda4`; los
`chromium_src` de `proto_visitors.h` y `extension_features.cc` no redefinen lo que cambia. Los `#include` nuevos existen
(salvo el generado `directory.mojom.h`, cuyo `.mojom` sí está).

Cruce con brave-core (`seg/3.1.4`, `ls-remote` `d916327900`; nada de la 3.1.4 0003 ni de la 3.1.5 toca estas rutas):
ni `patches/` ni `chromium_src/` tocan `platform/media`, `declarative_net_request` ni los ficheros de devtools-frontend
de 0001 (el único parche de devtools-frontend es `ApplicationPanelSidebar.ts`). `chromium_src/.../extension_features.cc`
solo sobrescribe `kApiDesktopAndroidNativeMessaging` y `kApiGlicPrivate`.

Firmas comprobadas (trampa de §16): `WebRequestPermissions::CanExtensionAccessURL` (0016, `ruleset_manager.cc`) igual en la
156 y en el padre del commit salvo un comentario; el `.fbs`, `ruleset_manager.cc`, `composite_matcher.*`, los *matchers*,
`utils.*` y `request_params.h` de la 156 son idénticos a los del padre; `wtf/hash_traits.h` y `hash_functions.h` (clave
con `scoped_refptr` en 0015) también; `WebSecurityOrigin` → `scoped_refptr<const SecurityOrigin>` existe con
`INSIDE_BLINK`, que `platform` define. En devtools-frontend, `hasWebSafeScheme`, `Link.allowPrivileged` y el segundo
parámetro de `openInNewTab` ya están en el gitlink de la 156.

## Veredicto (regla 17): **APTO**, parte 4

Revisado el código de 0015, 0016 y devtools-frontend 0001 contra la 156; 0001–0014, revisados por SEGURIDAD-PORTES-26
(tabla de arriba). Riesgos que LOCAL debe mirar al compilar:
- 0015: el `CHECK(security_origin_)` del constructor de `UrlData` y el de mismo origen en `MergeFrom()` son de upstream
  (cierre controlado en lugar de mezclar datos de dos orígenes). Si compilan las pruebas: `url_index_unittest`,
  `multi_buffer_data_source_unittest` y `resource_multi_buffer_data_provider_unittest` cambian de firma.
- 0016: reindexado de las reglas DNR de las extensiones al primer arranque (cambia `kIndexedRulesetFormatVersion`).
  uBlock Origin Lite y similares deben seguir bloqueando. `indexed_ruleset_format_version_unittest` lleva la suma nueva.
- devtools-frontend: los enlaces `chrome://` de la barra de precarga siguen abriéndose (`allow-privileged`).

**Posibles huecos vistos al portar 0016 (no son de G4; consultados a COORDINACIÓN, sin decidir aquí):** b878de30c0
(573367660, DNR ignora cabeceras ocultas al casar condiciones de respuesta), c06e1d94a2 (519999855, DNR: un documento
de error no puede quedar en la lista de `allowAllRequests`). Ninguno está en `3.1.4/` ni en `3.1.5/`. (ca8d989763,
502040109, es del main #1698510, anterior al punto de rama de la 156, #1706539: ya está.)
