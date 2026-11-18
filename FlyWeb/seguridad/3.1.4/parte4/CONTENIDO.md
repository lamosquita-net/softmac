# FlyWeb 3.1.4, parte 4: los medios de G4 que aplican a Mac (EN CURSO)

SEGURIDAD-PORTES-26, 18-11-2026, por orden de COORDINACIÓN-49 (decisión de Titín, ~15:15 UTC: en la 3.1.4 entra toda la
seguridad que aplica a Mac). Lista de partida: G4 de `../../3.1.5/CONTENIDO.md` (con interacción, instalar algo, Nigori,
DBSC) más 7b99dd29ba (571058818). **Nada compilado por mí. Parte sin terminar: faltan 3 piezas (abajo, «Pendiente»).**

## Base y resultado (comprobados)

| Repositorio | Base | Serie | Resultado |
|---|---|---|---|
| chromium | árbol `986d591616` (3.1.4 0001–0026 + 3.1.5 0001–0031 sobre `local/313`) | `chromium/` 0001–0014 | árbol **`031ab4cda4`** (comprobado con `git am`) |

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

**No aplican en Mac:** 553151406 (39597dfb3d, a9ee282a53, f2e3cb42e0): son de Aura y de Linux (`web_contents_view_aura`,
`desktop_window_tree_host_linux`); en Mac el arrastre del contenido va por `WebContentsViewMac`.

Cruce con brave-core: `patches/components-sync-protocol-proto_visitors.h.patch` aplica sobre `031ab4cda4`; los
`chromium_src` de `proto_visitors.h` y `extension_features.cc` no redefinen lo que cambia. Los `#include` nuevos existen
(salvo el generado `directory.mojom.h`, cuyo `.mojom` sí está).

## Pendiente (para el relevo; ver `docs/RELEVO-SEGURIDAD.md` §17)

1. **7b99dd29ba** (571058818, clave de `UrlIndex` por origen): choca en `url_index.cc` (`MergeFrom`, con nuestro 0018 de la
   3.1.4 y 61b6e5652b) y en el constructor de `WebMediaPlayerImpl` (la 156 recibe `WebLocalFrame*`; upstream, ya
   refactorizado, `FrameScheduler*` + origen). Porte propio: miembro `security_origin_` sacado de
   `frame->GetSecurityOrigin()` y pasarlo a `UrlIndex::GetByUrl()` y `UrlData`.
2. **22a2af917b** (497744349, DNR: permisos de host para reglas por valor de cabeceras de respuesta): 22 ficheros, 7 choques
   (`request_params.cc` ×4, `ruleset_matcher_base.cc`, prueba). Incluye la *feature*
   `kDeclarativeNetRequestRestrictResponseHeaderValueMatching` que se dejó fuera de 0012.
3. **543907563** (DevTools): es el *roll* 404327b549 de devtools-frontend; hay que buscar el commit del *frontend* y
   llevarlo como `devtools-frontend/` 000x sobre el gitlink de la 156.
4. Veredicto de la regla 17 de la parte entera, cuando estén 1–3.
