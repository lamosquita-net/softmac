# FlyWeb 3.1.1: inventario previo de la tanda de seguridad

SEGURIDAD-PORTES-21, 12-11-2026. Encargo de COORDINACIÓN-39 (DIRECTIVAS, «Seguridad tras la 3.1.0», 12-11). La tanda
de Chrome 158 (estable el 17-11) es la **3.1.1**. Este documento es el **inventario previo**: lo que ya se ve en las
ramas antes de la nota. El 17-11 se cruza con la lista de CVE de la nota de la 158 y se cierra.

Etiquetas: **[V]** comprobado en la fuente; **[I]** inferido. Clases:
- **A**: aplica a la base y se espera un porte limpio (sin probar);
- **D**: ya está en la 3.1.0;
- **N**: no aplica a Mac;
- **?**: hay que mirarlo con el código.

**Base (la de la 3.1.0):**
- chromium `seg/3.0.2` 502e3c5b85 = 156.0.8078.98 más 6 de la 157, más el foco;
- V8 **15.6.75.51** (182f13107b);
- brave-core `local/3.1` fc9389773fe.

**Maglev va encendido desde la 3.1.0**, así que sus arreglos ya cuentan como de producto.

**Etiquetas comprobadas con `git ls-remote` (12-11):**
- chromium 156.0.8078.**103** (la rama 8078 sigue viva tras la .98) y 157.0.8103.**81**; la 158.0.8127.40 es la última beta;
- V8 15.6.75.**58**.

## 1. V8 15.6.75.51 → .58 (7 `[M156]`, todos de seguridad probable) [V]

| Commit (v8/v8) | Bug | Qué | Clase |
|---|---|---|---|
| 9133115 | 583997430 | [turboshaft] invalidar la eliminación de cargas en `CatchBlockBegin` | A |
| 197b819 | 584118747 | [maglev] comprobar que `SubgraphBase::Label` está enlazada antes de destruirla | A (Maglev encendido) |
| 52dff94 | 582138456 | [compiler] las búsquedas en tablas hash ordenadas con clave de cadena escriben | A |
| 58707c0 | 584119868 | [objects] prohibir modificar `JSObject` durante el GC y sus callbacks | A |
| dfe5a31 | 583947034 | [maglev] `resume_mode_` explícito para saltar `IteratorResult` | A (Maglev encendido) |
| fceab3a | 583015431 | [regalloc] error de uno en el recorte de la región diferida en `AllocateBlockedReg` | A |
| 9ba5fcd | 582138459 | [interpreter] solo seguir los `ScopeInfo` de `eval` dentro del ámbito de la clausura | A: **cambia el intérprete; subir `kFlyWebCacheEpoch`** |

**Propuesta:** como en la 3.0.2 (0001), roll de V8 a **15.6.75.58** tal cual llega a la rama 8078. Antes de LOCAL, d8 y
mjsunit en verde en el Ubuntu, **con Maglev**. Después, el perfil PGO de V8 al día (`download_profiles.py
--check-v8-revision`).

## 2. Rama 8078: .98 → .103 [V]

26 `[M156]`. Están en la rama de nuestra base, así que se espera que entren limpios. Las «Roll commits from side
projects» son los rolls de V8 de §1.

| Commit (chromium) | Qué | Clase |
|---|---|---|
| 5fe7bc44c | [PDF] rechazar la reentrada en `PDFiumPage::Unload()` | A |
| b79012016 | lecturas fuera de límites de marcadores al pintar resaltados | A |
| 452a6cc92 | [SPC] `SecurePaymentConfirmationAppFactory::Request` en el hilo de UI | A |
| e08f4d5a4 | [sync] validar el origen de la pref `kLocalSyncBackendDir` | A |
| 1f4b169aa | reiniciar la caché de instantánea de `HTMLVideoElement` al quitar el reproductor | A |
| 223f61223 | inicializar a cero las reservas de `ZstdSourceStream` | A |
| e39d7ca22 | fijar el valor de `srcdoc` al crear la `NavigationRequest` | A |
| 46876a0c2 | [Extensions] `mimeHandlerPrivate` solo para extensiones permitidas | A |
| 843b36733 | MSE: partir o quitar los GOP fusionados al añadir más | A |
| 04580c0e8 | [Extensions] UAF en `PostMessageSupport::PostJavaScriptMessage` | A |
| d6be5db64 | `HttpCache::Transaction`: bits viejos en `response_` tras reiniciar | A |
| a3eb5e963 | cc: no cachear sombreadores de grabación que usan SharedImages | A |
| 32500ff67 | copiar los atributos antes de aplicarlos | A |
| cb2c29bc1 | [a11y] copiar los hijos al marcar subárboles no incluidos | A |
| 180fed5ac | impedir ids de render pass duplicados | A |
| 4311b8ee6 | UAF por reentrada en `WebMediaPlayerMS` al recargar audio y vídeo | A |
| d3435cc25 | [FSA] lista de rutas sensibles **sin distinguir mayúsculas** | A: **importante en macOS**, cuyo sistema de ficheros no las distingue |
| e0220018b | [FSA] bloquear `/run` | A (inocuo en Mac; entra por coherencia con d3435cc25) |
| cc77d7ea1 | [a11y-image-desc] reentrada en `AXImageAnnotator::OnImageAnnotated` | A (servicio de Google; probablemente inactivo en FlyWeb [I]) |
| 29980f328 | [Extensions] desactivar por defecto las restricciones estrictas de la política de depuración | ? (vuelta atrás funcional, no de seguridad) |
| ea36d0325, f253859e6 | CORS en Background Fetch | **D** (3.0.1, 0041 y 0042) |
| 973b2ff1b | intercambiar los snap sets pendientes | **D** (3.0.2, 0004) |
| 7b3fcb8ba | mojo: tuberías de Windows | N |
| e5876d9c5 | DirectShow | N |

## 3. Rama 8103 (157): .76 → .81, sin gemelo `[M156]` [V]

| Commit (chromium) | Bug | Qué | Clase |
|---|---|---|---|
| d36cec4f3 | 583015746 | no admitir orígenes distintos en la mayoría de commits síncronos de `about:blank` | A? (navegación: mirar si el código es igual en la 156) |
| 7ea140bbf | 583015746 | origen inicial opaco también en el navegador para los popups que escapan | A? (va con d36cec4f3) |
| 939ad86d5 | 578325934 | retener el `SVGImage` en `SVGImageForContainer::CreateViewInfo` (UAF probable) | A |
| 4dab8e40e | 584120152 | [ImageCapture] limitar la búsqueda de sesiones de dispositivo al frame que pide | A |
| d9fefd7f3 | 581926056 | `CHECK` en `GenerateHostVariantsToCheckV5` con caracteres escapados (Safe Browsing) | A (cierre del proceso) |
| 5fefa6cab | — | caída en `chrome://extensions` (diálogo de permisos de sitio) | ? (interfaz de Chrome; mirar si FlyWeb la usa) |
| e9f0cd851, 9c312d313, 9036d28cf | — | Traducir en PDF; PiP en Wayland | N |

El resto de la ventana tiene gemelo en §2.

## 4. Pendientes que vienen de antes

- **460ab884005** (crbug 577336844, GC, «Reapply» de `~Length()`): clase X en la 3.0.2 por `length.cc`. Se vuelve a
  intentar aquí.
- **CVE-2026-121112** (Permissions): sin arreglo localizable (`seguridad-3.0.2.md` §3). Se busca otra vez en la nota de
  la 158.
- ~~`flyweb_bundle_version_base`~~: **ya está** en brave-core `local/3.1` fc9389773fe (`build/config.gni:37`,
  `"198.63"`). Lo confirmó COORDINACIÓN-39 el 12-11. Sale de la 3.1.1.
- **CVE-2026-125350 / -125346 (libxslt):** **D** (3.0.1, 0034, y XSLT apagado).

## 5. Qué falta para cerrar (17-11)

1. **Nota de la 158 estable:** cruzar su lista de CVE con §1–§3 y buscar los que falten en `main` y en la 8127.
2. **KEV:** `cve-watch.py` el mismo día.
3. **Series:**
   - chromium `seg/3.1.1` sobre 502e3c5b85, con `git am` probado;
   - brave-core solo si hace falta;
   - `chrome/VERSION` a la última 156.0.8078.x.
4. **Para LOCAL:** d8 en verde primero (V8 .58) y época de caché subida (por 9ba5fcd).
5. **Prueba de huella** (DIRECTIVAS, Titín, 12-11; receta en `motor.md`, principio 13). Con la 3.1.1 compilada, desde la
   app, `https://tls.peet.ws/api/all` tiene que cuadrar con un **Chrome 156 real**:
   - JA4;
   - huella HTTP/2 «akamai»;
   - orden de cabeceras y `Accept-Encoding`;
   - Client Hints (`sec-ch-ua*`), coherentes con el User-Agent y con `navigator.userAgentData`.

   La referencia es la publicada para la 156 (ja4db.io), no el Chrome de la 7,1.
   - **Riesgo [I]: bajo.** Ningún arreglo de §1–§3 toca BoringSSL, `net/http2`, QUIC ni las cabeceras: el HttpCache de
     d6be5db64 no cambia lo que se envía, y Zstd (223f61223) solo cambia cómo se reserva la memoria.
   - Si la nota de la 158 trae algo de `net/` o de `third_party/boringssl`, se revisa aquí antes de entregar.
