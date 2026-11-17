# 3.2 — cierre en las pestañas fijadas compartidas (3.1.2)

MOTOR-46, 17-11, por encargo de COORDINACIÓN-44. **Sin compilar.** Pasa por SEGURIDAD-PORTES antes de aplicarse.
Destino: 3.2.0.

Base: brave-core `local/3.1.2` (**ba428ad058**). Con `git am`, el parche entra limpio sobre ba428ad y también sobre
3e2c12fad5 + `3.2-sync-cuenta` 0001–0008. No toca los mismos ficheros que la sync.

| Parche | Qué hace |
|---|---|
| `0001-tabs-don-t-dereference-a-missing-ThumbnailTabHelper-.patch` | `browser/ui/views/tabs/shared_pinned_tab_dummy_view_views.{h,cc}`: si la pestaña no tiene `ThumbnailTabHelper`, la vista de relleno se muestra sin el recuadro de la miniatura |

## El cierre

FlyWeb 3.1.2 en la 7,1 (Sequoia 15.8.3): EXC_BAD_ACCESS / SIGSEGV en 0x68, hilo principal, desde una tarea en cola:

```
0 SharedPinnedTabDummyView::CreateAndInstall(content::WebContents*, content::WebContents*) + 310
1 SharedPinnedTabService::MoveSharedWebContentsToBrowser(BrowserWindowInterface*, int, bool) + 452
2 ThreadControllerWithMessagePumpImpl::DoWork
```

El informe completo de Apple lo tiene Titín y no va al repo, porque lleva identificadores del equipo.

## Causa

Verificado leyendo el código, sin compilar:

1. `CreateAndInstall` construye `SharedPinnedTabDummyViewViews`. Este constructor (inlinado en el marco 0) inicializa
   `thumbnail_` con `ThumbnailTabHelper::From(tabs::TabInterface::GetFromContents(dummy_contents))->thumbnail()` y no
   comprueba si `From()` devuelve nulo. La copia del `scoped_refptr` lee `[helper + 0x68]` y ahí se cae. Coincide con lo
   que COORDINACIÓN-44 vio en las instrucciones: `kDataKey`, luego `mov rdi,[rax+0x68]` y después `lock xadd`.
2. En Chromium 156, `ThumbnailTabHelper` ya no es un `WebContentsUserData` que `tab_helpers.cc` cuelga siempre.
   - Ahora es un dato de la pestaña que crea `TabFeatures::Init`, y solo
     `if (base::FeatureList::IsEnabled(features::kTabHoverCardImages))` (`chrome/browser/ui/tabs/tab_features.cc`,
     tag 156.0.8078.105).
   - Al descartar contenidos, `TabFeatures` solo lo recrea si ya existía.
3. Brave desactiva `kTabHoverCardImages`: `chromium_src/chrome/browser/ui/ui_features.cc` lo pone a
   `FEATURE_DISABLED_BY_DEFAULT`.
   - Brave original lo compensa en `browser/ui/tabs/brave_tab_features.cc` (`BraveTabFeatures::Init`). Allí crea el helper
     siempre, «so we can switch hover modes via settings».
   - Nuestro árbol de la 156 no tiene `brave_tab_features.cc` ni ninguna integración con `TabFeatures`. Ningún parche ni
     `chromium_src` lo crea.
   - Por tanto, en FlyWeb 3.x **ninguna pestaña tiene `ThumbnailTabHelper`**.
4. La vista de relleno se instala desde un solo sitio: `MoveSharedWebContentsToBrowser`. Ocurre cuando la pestaña fijada
   compartida pasa a otra ventana y en la ventana que la tenía era la pestaña activa
   (`contents_owner_model->active_index() == index`).

**No depende** de la restauración de sesión, del contenido descartado ni de la ventana privada. Con el código tal como
está, el fallo es **determinista**: lo da cualquier movimiento de la fijada desde una ventana donde estaba activa.
Las pestañas fijadas compartidas vienen activadas por defecto en FlyWeb (`kBraveSharedPinnedTabs` y la pref
`brave.tabs.shared_pinned_tab`, F7.8), así que le pasa a cualquiera que use fijadas con dos ventanas o más.
Probablemente ocurre desde la 3.0.0, la primera con base 156. Esto último es una suposición: falta que LOCAL lo
reproduzca.

**Antecedentes:**
- 98f869c5b (2.0.3), FM.25 (`restored_browsers_`) y FM.41 trataban la pérdida o duplicación de fijadas con varias
  ventanas y la restauración de sesión.
- Este fallo es otro: no toca esa lógica y este arreglo tampoco.

**De paso:** el modo «Card with preview» (en español, según su traducción) de Ajustes > Apariencia > Pestañas tampoco tiene miniatura en la 3.x,
por la misma causa. El controlador de las tarjetas admite que no haya miniatura, así que ahí no hay cierre: solo falta la
vista previa.

## Arreglo mínimo (0001)

- El constructor pide el helper. Si existe, se suscribe a la miniatura como antes.
- Si no existe, oculta el recuadro de la miniatura y deja el título («This tab is active in another
  window» y su traducción) y la descripción.
- No cambia el servicio, las sesiones ni la creación de pestañas.

**Alternativa más amplia, no propuesta para la 3.2.0:** portar `BraveTabFeatures::Init` para crear el
`ThumbnailTabHelper` en todas las pestañas, como hace Brave. Volverían las vistas previas en la vista de relleno y en
las tarjetas. A cambio:
- hace falta un `chromium_src` nuevo sobre `TabFeatures`;
- cada pestaña tendría su capturador de miniaturas, con más memoria y CPU, que en la 5,1 se nota.

Si Titín quiere las vistas previas, irá aparte.

## Reproducirlo (LOCAL, en la 7,1 o la 6,1, con la 3.1.2)

**A mano:**
1. Ajustes > Apariencia > Pestañas: la opción de compartir las pestañas fijadas entre ventanas activada
   (es lo que viene por defecto).
2. Ventana A: abrir `https://example.com`, fijarla (clic derecho > Fijar) y dejarla seleccionada.
3. ⌘N para abrir la ventana B, que muestra la fijada como pestaña de relleno.
4. En B, hacer clic en la pestaña fijada.
   - **3.1.2:** se cierra al momento, con la misma pila (0x68).
   - **Con 0001:** B muestra la página y A muestra el relleno sin recuadro de miniatura.
5. Con 0001, además: volver a A y hacer clic en la fijada (vuelve); cerrar B con la fijada activa; reabrir con «Continuar
   donde lo dejaste»; poner el modo «Card with preview» y pasar el ratón por las pestañas. Nada debe cerrarse.

**Con pruebas:** `brave_browser_tests --gtest_filter='SharedPinnedTabServiceBrowserTest.*'`.
- `ActivatePinnedTab` recorre este camino: en la 3.1.2 debería caerse y con 0001, pasar.
- `BraveTabHoverTest.ThumbnailHelperIsAlwaysAttached` falla en la 3.x por la misma causa. Es lo esperado con el arreglo
  mínimo: solo pasaría con la alternativa amplia.

**Mientras tanto:** desactivar la opción de compartir las pestañas fijadas entre ventanas evita el cierre.
