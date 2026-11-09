# FlyWeb 3.0.2: segunda tanda de seguridad sobre la 3.0.0

SEGURIDAD-PORTES-20, 09-11-2026. Encargo de COORDINACIÓN-35 (`RELEVO-SEGURIDAD.md` §10; decisiones de Titín del 09-11 en
`DIRECTIVAS.md`, «Plan de la 3.x aprobado», puntos 4 y 9). Parches y pasos para LOCAL: [`../seguridad/3.0.2/`](../seguridad/3.0.2/README.md).

Etiquetas: **[V]** comprobado en código o fuente citada; **[I]** inferido.

## 0. Resumen

| # | Pieza | Estado | Dónde |
|---|---|---|---|
| 1 | Serie del parser (CVE-2026-121082, brave-core `seg/3.0.1-parser` bee89ad8a6) | **Pendiente del mjsunit** (no hay resultado al 09-11). Si sale limpio, entra; `seg/3.0.2` se rebasa encima | — |
| 2 | CVE-2026-121112 (Permissions) | **No portable**: no hay arreglo público localizable (§3) | — |
| 3 | V8 15.6.75.51 (156.0.8078.98) | Hecho | chromium `seg/3.0.2` 0001 |
| 4 | 5 arreglos `[M157]` sin gemelo en la 156 + 1 de main | Hecho, limpios | chromium 0002–0007 |
| 5 | **XSLT apagado** (y su reactivación para CAP) | Hecho | brave-core ef5de1b |
| 6 | **`focus-without-user-activation` encendido** + sus 3 arreglos | Hecho | brave-core ef5de1b; chromium 0008–0010 |
| 7 | CORS en Background Fetch | Ya en la 3.0.1 (parches 0041 y 0042); `novedades-motor.md` §6.3 no pide nada más | — |
| 8 | **WebHID apagado** | Hecho, commit aparte | brave-core 0d6a771 |
| 9 | Web Install y Direct Sockets | **No expuestos** en el código: sin cambio; LOCAL lo confirma en ejecución | — |
| 10 | `flyweb_bundle_version_base = "198.63"` | Hecho | brave-core 68ef629 |

Puntas (ls-remote, 09-11): chromium `seg/3.0.2` **502e3c5b85** sobre `seg/3.0.1` c4b1caf806; brave-core `seg/3.0.2`
**0d6a771f23** sobre `seg/3.0.1` 6415661d24. Nada compilado: compila LOCAL (orden fijo: d8 en el Ubuntu antes, por el roll de V8).

## 1. Inventario posterior a la .96 y a la 157.0.8103.39

Fuentes: feed de Chrome Releases hasta el 06-11 (no hay entradas del 07 al 09-11), tags de `chromium/chromium`, rama
15.6 de V8 (espejo de GitHub), `cisagov/kev-data` (2026.11.06). NVD, osv.dev y gitlab.gnome.org dan 403 desde el proxy.

- **No ha salido ninguna Stable ni Extended de escritorio después del 03-11** [V]. La siguiente nota con lista de CVE será la
  **158 estable (17-11)**: ese es el material de la 3.0.3.
- **ChromeOS 156.0.8078.93 (06-11):** 10 arreglos, todos ya en la 3.0.1. El único que no salía en notas de escritorio,
  **CVE-2026-79235** (UAF en WebGL, crbug 534468209), es el `[M156]` 50a2b3f14b, ya portado como d6aff6b797 [V].
- **Rama 8078 tras la .96:** tags .97 y .98 (08-11). Solo traen el roll de V8 6500240d22 → **182f13107b (15.6.75.51)**,
  con un `[M156]`: **34ad010** (crbug 579278668), `DeadValue` autorreferente en `EscapeAnalysisReducer` → acceso fuera de
  límites en el `OperationBuffer` de Turboshaft [V]. Sin CVE todavía. Solo compilador: no cambia bytecode, la época de caché
  sigue en 31 [I: no toca `src/interpreter`]. Entra como 0001; `chrome/VERSION` pasa a .98 (0011).
- **Rama 8103 (.39 → .76):** 389 commits; 24 `[M157]` tienen gemelo `[M156]` (todos ya en la 3.0.1) y el resto son
  perfiles PGO, orderfiles y rolls, salvo estos, sin CVE publicado [V]:

| Commit | Bug | Qué | Clase | Entra |
|---|---|---|---|---|
| 01ed020f973 | 577610454 | Barrera de marcado al pasar un `CSSSelector` a RareData (GC) | A | 0002 |
| 256ea3bdbcb | 579236824 | Copiar timelines antes de servir animaciones (iterador invalidado) | A | 0003 |
| 43c5081d0f5 | 581670042 | Intercambiar los snap sets pendientes antes de iterar | A | 0004 |
| 1ec13001377 | 582853411 | a11y: no crear wrappers de AXAuraObjCache para widgets que mueren (UAF) | A | 0005 |
| 9abee540049 | 577337624 | MIME de MHTML sin distinguir mayúsculas en el navegador (comprobación de descarga) | A | 0006 |
| c00b47ee691 | — | Kill switch del anterior | — | no (solo Finch) |
| 460ab884005 | 577336844 | GC: diferir los decrementos de `CalculationValue` en `~Length()` («Reapply») | **X** (`length.cc`) | no: a la 3.0.3, junto con lo que diga la nota de la 158 |

  Además, de `main`: **e49055113b** (crbug 577411929, null deref en el desmontaje del overlay de validación tras adoptar el
  nodo), limpio (0007).
- **KEV:** ninguna entrada nueva de Chromium desde la 3.0.1 (las de septiembre y octubre, CVE-2026-85046, -87491 y -111497,
  ya estaban cubiertas) [V].

## 2. Serie del parser (CVE-2026-121082)

Sin cambios respecto a `seguridad-3.0.1.md` §6: entra tal cual (`seg/3.0.1-parser` bee89ad8a6) si el mjsunit con las tres V8
no da caídas propias. Al 09-11 no hay resultado en el tablero ni en el buzón. Si entra, LOCAL rebasa `seg/3.0.2` (4 commits)
encima: solo comparten `patches/v8/FLYWEB-SECURITY.md`, que crece por arriba. Nota: el roll a 15.6.75.51 cambia la V8 sobre
la que se probó el parser; el mjsunit de la 3.0.2 debe hacerse con la V8 .51 + parser [I].

## 3. CVE-2026-121112 (Permissions, crbug 40063728)

- Nota de la 157 (03-11): «High, Out of bounds read in Permissions», merge «N/A», **reportado el 22-03-2023** [V].
- Ningún commit de `main` (desde 01-03-2026) ni de las ramas 8078/8103 cita 40063728 en `Bug:`/`Fixed:`. La única cita es
  be036d6d4a (29-09), que **desactiva por inestable** `permission_chip_browsertest.cc` con ese bug [V]. Los cambios de
  `chrome/browser/ui/views/permissions/chip` y `permission_request_manager.cc` en el rango de la 157 no son el arreglo [V].
- Lectura [I]: el arreglo es antiguo o se publicó con otro id, y el bug sigue restringido. **No se puede portar a ciegas.**
  Se revisa cuando el crbug se abra (unas 14 semanas tras el arreglo) o si aparece en otra nota.

## 4. XSLT

### 4.1 Cuenta de CVE (24 meses, 09-11-2024 → 09-11-2026)

- **libxslt: 6 CVE** [V: registros de cvelistV5, sin NVD]: CVE-2024-55549 (UAF, 7.8), CVE-2025-24855 (UAF, 7.8),
  CVE-2025-7424 (confusión de tipos, 7.5), CVE-2025-7425 (corrupción de memoria, 7.8), CVE-2025-10911 (UAF, 5.5),
  CVE-2025-11731 (confusión de tipos, 3.1). Puede faltar alguno de 2026 aún no indexado [I].
- **Chrome Releases:** ninguna nota de 24 meses dice «XSLT» ni «libxslt» [V]; hay 9 arreglos del componente «XML» (mayo,
  junio, 20-10 y 03-11), sin saber cuáles tocan XSLT [I].
- **Lo nuestro:** en la 3.0.1 ya entró un UAF de libxslt sin CVE (61cab3f772 → b63c9a973f, crbugs 582442907 y 572578603),
  y en `main` hay otra caída de XSLT del 02-11 (e429e35e0a, `xsl:import` sin `href`) [V].

Conclusión: unos 3 fallos de memoria al año en una librería con poco uso y mantenimiento escaso [I]. Apagar compensa.

### 4.2 Cómo se apaga

- En la 156, XSLT es la bandera Blink `XSLT` (`status: "stable"`, con origin trial de deprecación y base::Feature generada
  `kXSLT`) [V: `runtime_enabled_features.json5`]. Upstream la apaga en la 158 quitando el `status` (61634354c2) [V].
- Nosotros: `kXSLT` apagada en `OVERRIDE_FEATURE_DEFAULT_STATES` (brave-core `chromium_src/third_party/blink/common/features.cc`).
  Funciona porque el `GetStateIfOverridden` de Brave cuenta su valor por defecto como «sobrescrito», y
  `content/child/runtime_features.cc` copia entonces el estado a la bandera Blink [V: los dos ficheros].
- **Trampa encontrada:** `EnableXSLTForCAPAlerts` (stable en la 156) **reactiva XSLT** para cualquier documento XML cuyo
  elemento raíz esté en el espacio de nombres CAP [V: `xslt_processor.cc:103`, `xml_document_parser.cc:1148`]. Cualquier web
  puede servir uno, así que se apaga también (`kEnableXSLTForCAPAlerts`).
- Sigue disponible la política `XSLTEnabled` (empresas; upstream la retira en la M164/M176). El origin trial no puede
  validar en FlyWeb (la clave pública es la de Brave) [V: commit de la 3.0.1].
- `XMLRustForNonXslt` sigue `stable` en la 156 (parser XML en Rust para `DOMParser` y XHR): upstream la bajó a experimental el
  29-10 **por rendimiento**, no por seguridad (2b00348df1). Se queda.
- Efecto visible: feeds RSS/Atom con hoja XSLT se ven como árbol XML. Huella: `XSLTProcessor` desaparece, como en Chrome 158
  y no como en el Chrome 156 que declaramos (decisión 8 del 09-11); Titín aprobó apagarlo igualmente (punto 9).

## 5. Bloqueo del foco sin interacción (`focus-without-user-activation`)

- En la 156: bandera `BlockingFocusWithoutUserActivation` experimental; política con `feature_default: "EnableForAll"` [V].
  Upstream la enciende en la 158 (459923263d).
- Se enciende con `OVERRIDE_FEATURE_DEFAULT_STATES` y se traen sus arreglos posteriores, limpios: e9d7b23413 (reenvío de
  `<label>`, 157), d8f2d78eb2 (informes de violación, 158) y 2d8fb5ddf9 (quita el aviso de consola, 158).
- **claude.ai:** con la lista por defecto `*`, solo se bloquea `focus()` en marcos cuyo padre ponga
  `focus-without-user-activation 'none'`; claude.ai no lo usa hoy [I]. LOCAL lo prueba (README, paso 4).
- Huella: añade una entrada a `document.featurePolicy.features()` que el Chrome 156 no tiene [I]; mismo caso que XSLT.

## 6. WebHID, Web Install, Direct Sockets

LOCAL-19 aún no ha informado de la comprobación en ejecución (orden del buzón b5949cb). Lectura del código de la 156 + brave-core:

| API | Estado en el código | Brave | Expuesta | Acción |
|---|---|---|---|---|
| WebHID (`navigator.hid`) | `status: {Android: experimental, default: stable}` | no la toca | **sí** [V código; I ejecución] | **apagada** (`kWebHID`), commit aparte 0d6a771 para poder quitarlo si LOCAL ve otra cosa |
| Web Install (`navigator.install`, `<install>`) | `WebAppInstallation` e `InstallElement`: `status: test`; `runtime_features.cc` las apaga sin la feature del navegador | `kWebAppInstallation` solo en el patch de tipos de permiso | **no** | ninguna |
| Direct Sockets | sin `status` (solo Isolated Web Apps); se copia de la base::Feature solo si se sobrescribe | — | **no** | ninguna |

Fuera del encargo, misma familia: **WebUSB y Web Serial** están `stable` y Brave los deja; son superficie y huella como
WebHID. Propuesta para Titín (no hecha): apagarlos en la 3.0.3 si no se usan.

## 7. `flyweb_bundle_version_base = "198.63"`

brave-core 68ef629: argumento de GN nuevo, congelado; `tweak_info_plist.py` lo usa para el `CFBundleVersion`
(`198.63.N`) en vez de derivarlo de la versión de Brave. Vacío → camino anterior. Probado el script: 1.98.63/43 → `198.63.43`;
con la base y una versión de Brave distinta → `198.63.43`; N = 0 → `198.63`. Pendiente de `plan-3x.md` §6.2, fuera de esta
tanda: que `build.sh` pare si `FLYWEB_BUILD_NUMBER` no supera al último publicado.

## 8. Medida de limpios y medida de diciembre

- **Esta tanda (Chromium):** 9 de 10 arreglos intentados entran limpios con 3 vías (90 %); 1 X (460ab884005). Sin contar el
  roll de V8 (1/1 limpio) ni el kill switch c00b47ee691, que no es un arreglo.
- **Medida de diciembre:** se toma con la nota de la **158 estable (17-11)** y la Extended que la acompañe, contra
  `seg/3.0.2`, con el mismo método de `seguridad-3.0.1.md` §5 (A/F/X/N, grupo 1 y grupo 2). Es la primera a un hito de
  distancia de verdad (156 → 158) y el primer dato para el umbral S1 50/35 % (decisión 3 del 09-11). Se hace como inventario de
  la 3.0.3.

## 9. Recomendación

Compilar la 3.0.2 ya (lleva las decisiones de Titín y no espera a nada salvo el mjsunit, que solo decide si entra el parser).
La 3.0.3, con la nota de la 158 del 17-11, a ~2 semanas, dentro del ritmo de 2–4 semanas.
