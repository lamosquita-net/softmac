# FlyWeb 2.1.1 — motor 132, seguridad y escapes (FM.48)

MOTOR-26, 27-10-2026. brave-core **`nube/motor-211` 33a978bdb9** (sin compilar; en la nube no hay checkout). Base: la 2.1.0
publicada (`local/2.1.0-arreglos` 5f2c1e51 = `nube/motor-132` 78eb79e8 + 843cac4f + 5f2c1e51). `flyweb_version` 2.1.1;
`FLYWEB_BUILD_NUMBER` **33**. Motor declarado sin cambios (132.0.6834.160, V8 13.2.152.56).

## Qué lleva

| Commit | Qué | Origen |
|---|---|---|
| 99deb7322 | merge `seg/fs30-ct` 2d022f2c: Certificate Transparency con la lista de logs de compatibilidad 4 (CT estaba apagado en toda la 2.x) | FS.30 |
| d69e41304 | merge `seg/fs31-roots` dae06d65: Root Store v17, HSTS de la 132, cortes del Root Store con la constante 139.0.0.0 (Entrust, AffirmTrust, Chunghwa, NetLock) | FS.31 |
| 0526cb1f5 | merge `seg/fs29-v8` 53814453: V8, constness en `DefineNamedOwnProperty` (**época 20**) | FS.29 |
| 05c2d96d6 | SVG `getCharNumAtPosition()` en `sideways-lr` | upstream b827be29301 |
| c576cf99a | `::backdrop` junto a su elemento al quitar y volver a poner en la capa superior | upstream 25ae6a64c8f |
| aa5c1a506 | IndexedDB: `DataError` (no `TypeError`) con un `ArrayBuffer` separado como clave | upstream faa7b4a6239 |
| 2b0689190 | `dir=auto` de los ancestros de un `<slot>` cuando cambia la dirección del host | upstream 0490d2ee3aa |
| fe1b321d5 | flex: alto de línea con líneas base extremas | upstream 0cc960d7c22 |
| 9a0e2d945 | flex: alineación `safe` con espacio negativo cae a `start` (row/column-reverse, wrap-reverse) | arreglo propio con la conducta de 6c616ac76fb + 8543c83fc67 |
| f1cb7e815 | flex: `max-height`/`max-width: min-content` en el eje principal | adaptado de upstream b534cd43421 |
| c08792fee | FM.47: el sandbox del renderer lee los xattr de las fuentes | upstream 7afa0043cfc |
| ccbdf5af0 | FM.47: el emparejado por familia descarta las caras que el renderer no puede cargar | propio |
| df2495f40 | versión 2.1.1 | — |
| 33a978bdb | merge `local/2.1.0-arreglos` 5f2c1e51 (`<progress>` vertical) | LOCAL-13 |

Los merges de FS.29–31 entraron sin conflictos (no comparten ficheros con 843cac4f). Todos los parches cambiados desde
la 2.1.0 aplican sobre 128.0.6613.138 (`chk128.sh`: 30 + 1, 0 problemas); `patches/v8` como lo dejó SEGURIDAD-PORTES-10.

## (a) Revisión de 843cac4f y 5f2c1e51

- **843cac4f, shape-outside:** el mensaje cita upstream **84926a40d7e**, pero ese quita otra flag (`ShapeOutsideClippedImageFix`).
  La que quita `ShapeOutsideWritingModeFix` es **2af3b8d997f** (19-11-2024). Comparado `ellipse_shape.cc`, `shape.cc` y
  `shape_outside_info.cc` (128 + parches) con la 132 + 2af3b8d997f: **iguales salvo API de la 128** (`NOTREACHED_IN_MIGRATION`,
  una variable sin uso quitada, un include de flags). En la 132 la flag está en `stable`, así que el camino que queda es el
  mismo. Nada perdido.
- `PushMessageData::bytes()` y `chromium_src/v8/src/builtins/builtins.cc` (Page Graph): correctos para la 128 y la V8 13.2.
- 5f2c1e51 solo toca `theme_painter_default.cc`; ningún commit de la 2.1.1 lo toca.

## (c) Escapes del 132 (lista de LOCAL-13, FM.45)

| WPT | Arreglo |
|---|---|
| `css-flexbox/flexbox-safe-overflow-position-002…005` | 9a0e2d945. Upstream lo hace dentro de una serie de refactor (572789ee61c, 3d8a356e8d5, 6c616ac76fb, c5603051333, 8543c83fc67) con 22 rechazos sobre la 128; se porta solo la conducta: con espacio libre negativo y `safe`, la posición pasa a `start` dentro de `InitialContentPositionOffset` de la 128 (que ya traduce `start` con dirección invertida y la vuelta de wrap-reverse). `-webkit-box` sigue como en la 128. |
| `flex-item-max-height-min-content`, `flex-item-max-width-min-content` | f1cb7e815. Upstream b534cd43421 depende de la función de tamaño de bloque con `SizeType` (agosto de 2024, era calc-size), que la 128 no tiene. Adaptado: el `max-*` intrínseco en el eje principal se resuelve con el `IntrinsicBlockSizeFunc` de la 128. Lo de `min-*` ya funcionaba por el camino de min-size:auto de la 128; el eje cruzado se queda como en la 128. |
| `flexbox/baseline-outside-flex-item` | fe1b321d5 (0cc960d7c22, un hunk aplicado a mano por desplazamiento). |
| `dir-auto-dynamic-changes.window.js` (slot) | 2b0689190 (0490d2ee3aa). |
| `svg/text/scripted/getcharnumatposition-slr.tentative.html` | 05c2d96d6 (b827be29301; include de `writing_mode_converter.h` explícito por la trampa del PCH). |
| `the-dialog-element/top-layer-backdrop-remove-add-ordering.html` | c576cf99a (25ae6a64c8f). Sus `CHECK` dependen de que el backdrop entre y salga de la capa superior por los mismos sitios que en la 132: comprobado (`element.cc`, mismos tres puntos en la 128 y en la 132). |
| `IndexedDB/idb-binary-key-detached.htm` | aa5c1a506 (faa7b4a6239). |
| `IndexedDB/structured-clone.any.js` | Nada: tiempo del ejecutor (CfT 132 también falla). |

## (d) FM.47: Futura con «?» en Sequoia

**Diagnóstico (por código; sin Mac en la nube):**
- **Nuestro parche de `CTFontCopyVariationAxesInternal` no es:** solo lo hace `weak_import`, y se llama dentro de
  `@available(macOS 13.0, *)`; en Sequoia el símbolo existe y el código es el de upstream.
- Los datos de Titín (familia `.LastResort` con nombre PostScript `Futura-BookOblique`) son la firma de una cara cuyo
  `CTFont` tiene el nombre bueno y cuyo `CGFont` es LastResort: el renderer **no puede leer los datos** de esa cara
  (`CanLoadInProcess` de `font_platform_data_mac.mm` mira exactamente eso, y en Release dibuja LastResort).
- La `Futura.ttc` del sistema no tiene `Book`/`BookOblique` (Medium, MediumItalic, CondensedMedium, CondensedExtraBold,
  Bold, de memoria): **Futura-BookOblique viene de otra Futura instalada** en esa Mac (tipo 1 / maleta con *resource fork*
  o fuera de las carpetas que el sandbox deja leer). La 128 elige por familia con `availableMembersOfFontFamily` +
  `CTFontCreateWithName` (flag `FontMatchingCTMigration` en `stable`), mezcla las caras de las dos Futura y, para peso 400,
  la mejor es la `Book`; la 116 usaba `fontWithFamily:traits:weight:size:` de AppKit. Eso explica «desde la 2.0» y que
  `Futura-Medium` por nombre PostScript sí salga.
- Upstream arregló en 2025 las fuentes con *resource fork* en el sandbox (7afa0043cfc, crbug 429221317: faltaba
  `file-read-xattr`). **Chrome 128 debería fallar igual en esa Mac**; la comprobación que pedía FM.47 lo confirmaría.

**Arreglo (dos commits, sin API por encima de 10.14):**
1. c08792fee: `file-read-xattr` en `allow-font-access` de `common.sb` (upstream tal cual). Si la otra Futura es de
   *resource fork* en `/Library/Fonts` o `~/Library/Fonts`, con esto se ve **la Futura Book de verdad**.
2. ccbdf5af0: si la cara elegida sale respaldada por LastResort (`CTFontCopyGraphicsFont` → `LastResort`), se descarta y se
   toma la siguiente mejor de la familia (la Futura del sistema). Solo cambia el resultado cuando antes se dibujaba «?».
   Coste: una `CTFontCopyGraphicsFont` por emparejado (FontCache lo guarda).

**Para Titín (2 min, lo pide LOCAL):** en Catálogo Tipográfico, «Futura» → la cara Book Oblique → Mostrar en el Finder: ruta y
tipo de fichero. Con eso se sabe cuál de los dos commits la arregla.

## Pruebas para LOCAL

1. Compilación Release con `FLYWEB_BUILD_NUMBER=33`. Riesgo de compilación: f1cb7e815 y 9a0e2d945 (código propio en flex),
   ccbdf5af0 (Objective-C++ con ARC), y los de FS.29–31 (sin compilar, regla de SEGURIDAD-PORTES-10).
2. **FS.30:** `chrome://net-export`, evento `CERT_CT_COMPLIANCE_CHECKED` con `build_timely: true` en una web normal.
3. **FS.31:** web con certificado de Entrust emitido después del 11-11-2024 → error; Chunghwa o NetLock después del
   31-07-2025 → error; una web normal → bien.
4. **FS.29:** mjsunit con el `d8` de la 2.1.1 si se compila (SEGURIDAD-PORTES-10 dio 7340/7341; el que falla,
   `maglev/extras-cped`, como siempre); y `motor-132.html` 17/17.
5. **WPT 132:** los 11 escapes de arriba en verde; el resto igual que la 2.1.0 (ninguna regresión frente a CfT 132).
6. **FM.47:** en la 7,1 (Sequoia) `data:text/html,<p style="font:100px Futura">0123</p>`, `Futura` en cursiva y Speedometer
   3.1 (título y números) sin «?»; Rendered Fonts dice qué cara sale. Lo mismo en Monterey (A1398) y una pasada en
   Mojave (6,1) para ver que no cambia nada.
7. Sin cambios visibles salvo Futura (DIRECTIVAS): si Futura sale bien, captura antes/después para Titín.

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12.)*

- **Seguridad de los certificados al día.** FlyWeb vuelve a comprobar la transparencia de certificados (Certificate
  Transparency) y deja de aceptar los certificados nuevos de autoridades que Chrome ya no admite (Entrust, Chunghwa
  Telecom, NetLock…).
- **Arreglo de seguridad en el motor JavaScript.**
- **Futura se ve bien en macOS Sequoia y Monterey**: las webs que usaban esa letra (por ejemplo Speedometer) mostraban «?».
- **Más compatibilidad con las webs**, igual que Chrome 132: cajas flexibles que se desbordan por el lado correcto,
  tamaños máximos «al contenido», fondos de diálogos, texto con dirección automática dentro de componentes, y
  pequeños arreglos en SVG e IndexedDB.
