# FlyWeb — criba de los portes propios aplazados de FM.22 (INVESTIGACIÓN-MOTOR, 20-10-2026)

Estudio en papel (fila FM.30). Sin código ni ramas. **Propone; decide Titín.** Parte de las 26 flags que
`FlyWeb/tools/port/fm22-escapes.tsv` deja como «aplazada» o «aplazada (porte propio)» (22 funciones agrupadas). Las
marcas de ese TSV (motivo, cadena de commits, rechazos) son la fuente de la columna de coste.

**Etiquetas:** **[V]** visto en una fuente o en el TSV; **[I]** inferido; **[H]** hipótesis. Las horas son **estimación
mía** (portar, sin contar esperas de compilación; con Static y ASan donde se indica).

## 1. Resumen

- **Recomiendo portar ninguna ahora y dejar las 22 como «diferencia documentada»,** salvo **una medición de 4–8 h** sobre
  `LayoutBlockButton` + `LayoutBaselineFix` (la única con efecto visible en webs corrientes: botones). Si esa medición
  falla pruebas de WPT, portarla en **su propia 1.15.x** (regla 18, con revisión de la regla 17).
- **Motivos:** (1) la regla 2 de `motor.md` fija el objetivo en Baseline y **ninguna** de las 22 lo es hoy [V para 6, I
  para el resto]; (2) 6 de ellas son telemetría o superficie sin beneficio para quien navega (regla 20); (3) el coste de
  portarlas todas es de **~340–700 h** [H] para ganar funciones que las webs usan poco.
- **Brave 1.73 y el master actual no apagan ninguna** (el TSV las filtró contra ellos [V: cabecera del TSV]); la decisión
  de no portarlas es nuestra, no heredada.
- **Lo que no se porta no se expone:** las que están «experimental» (LoAF, NotRestoredReasons, StorageBuckets) siguen apagadas en
  la 1.15 [V: TSV, columna «estado»], así que no hace falta apagar nada.

## 2. Qué no pude comprobar

- **Contadores de chromestatus (uso real):** `chromestatus.com` no resuelve desde la nube. Sustituyo el uso por el
  estado de Baseline y el soporte por motor de `web-features`, que sí leí (ficheros `*.yml.dist` de la rama `main`).
  **Para cerrar la columna de uso, alguien con red debe leer los contadores** (lista en §5).
- **Baseline de las otras 16 funciones:** no he encontrado su identificador en `web-features`; el soporte que anoto es
  de mi conocimiento [I] (en general «solo Chromium»).
- **Qué hace el 116 de cada una en producción:** salvo lo del TSV, no hay prueba en navegador.

## 3. Tabla de decisión

Soporte por motor según `web-features` (rama `main`, 2026): [V] donde se indica el motor y la versión.

| # | Función (flags) | Soporte | Privacidad (regla 20) | Coste | Riesgo | Recomendación |
|---|---|---|---|---|---|---|
| 1 | **StorageBuckets** | Solo Chrome 122 [V] | Medio: cuotas y durabilidad por «cubo» dan una huella más; sobreviven a más cosas que `localStorage` [I] | 3–5 h [V: TSV] | Medio (almacenamiento) | **Dejar** |
| 2 | **BackForwardCacheNotRestoredReasons** | Solo Chromium [I] | Medio: dice a la web por qué no se guardó la página (extensiones, procesos) → huella y telemetría [I] | 6–12 h [H] | Medio | **Dejar** (telemetría) |
| 3 | **LongAnimationFrameTiming** (LoAF) | Solo Chrome 123 [V] | **Alto:** URL, función y posición de cada script que bloquea un fotograma; sirve a la analítica, no al usuario [I] | **80–150 h** (~60 commits, 1 223 hunks en 353 ficheros [V: TSV]) | Alto | **Dejar** (la más cara y la menos útil) |
| 4 | **CSSScrollSnapEvents/Change/Changing** | Solo Chrome 129 [V] | Bajo | 25–50 h (la cadena toca `cc`) [H] | Alto (compositor) | **Dejar**; revisar si Firefox y Safari la publican |
| 5 | **CSSTextSpacingTrim** | Solo Chrome 123 [V] | Bajo | **60–120 h** (65 commits sobre el *shaper*) [V: TSV] | Alto (todo el texto) | **Dejar** (tipografía CJK) |
| 6 | **CSSPhraseLineBreak** (`auto-phrase`) | Solo Chromium [I] | Bajo | 25–40 h (15 commits + subir ICU, que no tiene mecanismo en `DEPS`) [V: TSV] | Medio | **Dejar** (japonés) |
| 7 | **DocumentPictureInPictureUserActivation** (y `DisplayMode` PiP) | Chrome 130, Firefox 151 [V]; Safari no | Medio: ventana siempre visible con contenido de la web (suplantación) [I] | 10–20 h, lado navegador [H] | Medio | **Dejar y comprobar** qué hace la 116 con `requestWindow` (¿exige gesto?) |
| 8 | **CSSDisplayModePictureInPicture** | Solo Chromium [I] | Bajo | 2–4 h, pero «sin compilar no se encuentran todos los `switch`» [V: TSV] | Medio (PWA) | **Dejar** (va con la 7) |
| 9 | **DocumentRenderBlocking** (`rel=expect`) | Solo Chrome [I] | Ninguno | 6–12 h (8 commits) [V: TSV] | Bajo | **Dejar** (sin ella solo no se bloquea el pintado) |
| 10 | **LayoutBlockButton + LayoutBaselineFix** | Todos los motores tienen el comportamiento correcto; es una refactorización de Chrome [I] | Ninguno | **30–60 h** con Static y ASan (19 rechazos [V: TSV]) | **Alto** (LayoutNG, toda web con botones) | **Medir con WPT; si falla, portar en su propia 1.15.x** |
| 11 | LayoutFlexUnderInvalidationFix | — | Ninguno | — | — | **Cerrar** («no aplica» probable: depende de la caché de layout de la 123, que la 116 no tiene) [I] |
| 12 | LayoutNewContainingBlock | — | Ninguno | 15–30 h (cadena de RemoveLegacy) [H] | Alto (saltan `DCHECK`) | **Dejar** |
| 13 | EmptyCaretInVertical | — | Ninguno | 8–16 h (necesita M117) [H] | Medio | **Dejar** (texto vertical) |
| 14 | MaskingGraphemeClusters | — | Ninguno | 10–20 h | Medio | **Dejar** |
| 15 | NoIntrinsicSizeOverride | — | Ninguno | 10–25 h | Medio (`<img>`, `<video>`) | **Dejar** |
| 16 | ReferenceBoxNoPixelSnapping | — | Ninguno | 10–20 h | Bajo (subpíxel) | **Dejar** |
| 17 | RewindFloats | — | Ninguno | 6–12 h | Medio (`NGLineBreaker`) | **Dejar** (caso raro) |
| 18 | WebExposedScrollOffset | — | Ninguno | 6–12 h | Bajo (1 px con zoom) | **Dejar** |
| 19 | AudioContextOnError | Solo Chromium [I] | Bajo | 10–20 h (9 commits en el hilo de audio, 28 rechazos [V: TSV]) | Medio (seguridad: audio) | **Dejar** |
| 20 | **PaymentRequest/SPC AllowOneActivationlessShow** (2 flags) | Solo Chromium [I] | **Negativo:** permite abrir la hoja de pago **sin gesto** del usuario | 8–15 h (cadena de 5, lado navegador) [V: TSV] | Medio | **No portar nunca** (debilita una protección) |
| 21 | **SecurePaymentConfirmationExtensions** | Solo Chrome 139 [V] | Medio: cambia la conversión de extensiones de **toda** respuesta de `credentials.get()` | 15–30 h con SEGURIDAD-PORTES [H] | **Alto** (WebAuthn) | **Dejar** |
| 22 | **RTCRtpEncodingParametersCodec** | Solo Chromium [I] | Bajo | 15–30 h; **la WebRTC de la 116 (44bc8e96) no es accesible desde la nube** [V: TSV] | Medio | **Dejar**; revisar si Meet o Zoom lo exigen |

**Coste de portarlas todas:** suma de los rangos ≈ 340–700 h [H]. **Coste de lo recomendado:** 4–8 h de medición (§4) y, si
falla, 30–60 h para la fila 10.

## 4. La excepción: botones (fila 10)

- **Por qué es la única:** Chrome 126 pasó los botones a *layout* de bloque y arregló las líneas base de botón, rango y
  casilla. Afecta a **todas** las páginas con `<button>`, `<input type=button>` y casillas, aunque la diferencia sea de
  un píxel [I]. Las otras 21 afectan a funciones que casi ninguna web usa.
- **Medición (LOCAL, 4–8 h):** las WPT de `html/rendering/widgets/` y `css/css-forms/` y `css/css-align/baseline-*`
  contra la 1.15 y contra el Chrome 131 de referencia (método de `motor.md` principio 7). **Criterio:** si la 1.15 falla
  menos de ~5 pruebas más que Chrome 131, dejarla como diferencia; si falla más, portar.
- **Si se porta:** su propia 1.15.x (regla 18: lo grande y de riesgo va aparte), con Static **y** ASan y revisión de
  la regla 17 (LayoutNG); 30–60 h.

## 5. Contadores de uso que faltan (para quien tenga red)

Leer en chromestatus el porcentaje de páginas (*page loads*) de los contadores de: `StorageBuckets`,
`LongAnimationFrame`, `BackForwardCacheNotRestoredReasons` (`PerformanceNavigationTiming.notRestoredReasons`),
`ScrollSnapChange`/`ScrollSnapChanging`, `text-spacing-trim`, `word-break: auto-phrase`, `documentPictureInPicture`,
`link rel=expect`, `PaymentRequest.show` sin gesto, `AudioContext.onerror`, y `RTCRtpEncodingParameters.codec`. **Criterio
para reabrir una fila:** más de ~0,1 % de las cargas y soporte de al menos dos motores.

## 6. Cuándo revisar cada una (disparadores)

| Función | Disparador |
|---|---|
| Document PiP | Safari la publica (Firefox 151 ya la tiene [V]) → pasa a Baseline |
| Scroll snap events, text-spacing-trim | Firefox y Safari las publican (hoy solo Chrome [V]) |
| LoAF, StorageBuckets, NotRestoredReasons | **Nunca** por privacidad, salvo cambio de criterio de Titín |
| Payments sin gesto | **Nunca** |
| WebRTC por codificación | Una web importante de videollamadas deja de funcionar y se demuestra que es esta API |
| Botones (fila 10) | Resultado de la medición de §4 |

## 7. Fuentes

- Proyecto: `FlyWeb/tools/port/fm22-escapes.tsv` (cabecera: filtro contra Brave 1.73 y master; columnas «motivo» y «estado»),
  `motor.md` (principios 2, 7 y 11), `docs/TAREAS.md` (reglas 17, 18 y 20; FM.22, FM.30).
- web-features (estado de Baseline y soporte por motor, rama `main`): `features/long-animation-frames.yml.dist`,
  `storage-buckets.yml.dist`, `scroll-snap-events.yml.dist`, `text-spacing-trim.yml.dist`,
  `document-picture-in-picture.yml.dist`, `secure-payment-confirmation.yml.dist`
  (por ejemplo [LoAF](https://raw.githubusercontent.com/web-platform-dx/web-features/main/features/long-animation-frames.yml.dist),
  [Document PiP](https://raw.githubusercontent.com/web-platform-dx/web-features/main/features/document-picture-in-picture.yml.dist)).
- Rechazos y cadenas de commits: los del TSV de FM.22 (MOTOR-11 y MOTOR-12).

## 8. Pendiente

- Contadores de chromestatus (§5) y las WPT de §4: de LOCAL o de quien tenga red.
- Identificadores de `web-features` de las 16 funciones sin dato de Baseline.
- Qué hace la 116 con `documentPictureInPicture.requestWindow` sin gesto (fila 7).
