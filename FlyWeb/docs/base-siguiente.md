# Siguiente base de FlyWeb: ¿a qué Chromium, cuándo y cuánto cuesta?

INVESTIGACIÓN-MOTOR-7, 03-11-2026, encargo de Titín vía COORDINACIÓN-24. **Solo papel**: nada compilado ni medido en
máquina. Marcas: **[V]** verificado en código o fuente citada; **[I]** inferencia mía; **[N]** no comprobado.
Sin horas nuevas: las que aparecen son de documentos anteriores (y esos, según `DIRECTIVAS.md`, salen pesimistas).
Continúa `base-128.md` (el salto 116 → 128) y `fork-propio.md` (aprobado el 03-11, con «la base no sube con el fork»).

## 1. Conclusión

1. **Subir la base de 128 a Chromium 156 (la meta), de una vez, sin portar a mano los niveles 139–155.** Plan B
   explícito: **150**, la última con mínimo de macOS 12 (§5). No conviene ninguna base intermedia (138, 139/140, 144, 151): cuestan
   un salto completo y casi no cierran la deuda (§3.1).
2. **Cuándo:** justo después de la 2.7.0 y de la conversión a git (F0–F1 de `fork-propio.md`), **en lugar de** el 139 a mano.
   La siguiente versión con motor nuevo no es la 2.8.0 = 139, sino un 156 nativo. Antes de comprometerse, dos
   medidas baratas y una **puerta para Titín** (§6). Entre tanto sigue SEGURIDAD-PORTES con los CVE explotados.
3. **Qué cambia de idea rectora.** «La 128 es la última base que tomamos de fuera» (DIRECTIVAS, 20-10) se justificó con
   el suelo de macOS 11 de la 129. Hoy hay dos hechos nuevos: la traducción a Mojave de la 128 funciona (2.0.x), y la
   deuda fuera de Blink y V8 crece más deprisa de lo que se pensaba (§3.1). Pido a Titín que **revoque esa frase y el punto 6
   de `fork-propio.md`** (§8). Sin la revocación, nada de esto vale.
4. **Lo que no se resuelve con la base** (y es lo más caro): adaptar `brave-core` 1.69 a las APIs de Chromium 156 (§5, riesgo 1)
   y mantener Mojave cuando Chromium suba otra vez su mínimo (probablemente a macOS 14 hacia mediados de 2027 [I], §3.2).

## 2. Hechos de partida

### 2.1 Mínimo de macOS, SDK y compilador por hito [V]

Leídos en `build/config/mac/mac_sdk.gni`, `build/mac_toolchain.py` y `tools/clang/scripts/update.py` de cada etiqueta
(`chromium/chromium` en GitHub y `chromium.googlesource.com`).

| Hito | `mac_min_system_version` | SDK oficial | clang (`CLANG_REVISION`) |
|---|---|---|---|
| 128.0.6613.138 (hoy) | **10.15** | 14.0 | llvmorg-19-init-14561 |
| 129.0.6668.0 | **11.0** | 14.0 | — |
| 138.0.7204.0 | 11.0 | 15.4 | llvmorg-21-init-11777 |
| 139.0.7258.0 | **12.0** | 15.4 | llvmorg-21-init-11777 |
| 144.0.7559.0 | 12.0 | 26.1 | — |
| 150.0.7871.0 | 12.0 | 26.5 | llvmorg-23-init-10931 |
| 151.0.7922.0 | **13.0** | 26.5 | — |
| 156.0.8078.0 | 13.0 | 26.5 | llvmorg-24-init-7747 |
| `main` (159.0.8141.0) | 13.0 | 26.5 (Intel: Xcode 26.6) | — |

Los tres saltos de mínimo (129, 139, 151) coinciden con `macos11-niveles.md` §1. El comentario de `main` en `mac_sdk.gni`
dice que Xcode 27+ es solo ARM y que los anfitriones Intel usan Xcode universal 26.x: **la 7,1 puede seguir compilando**, pero
sin margen si Chromium pasara a exigir el SDK 27 (`macos11-niveles.md` §1 lo sitúa en la 158) [I: depende de cómo lo resuelvan].

### 2.2 Gráficos: Skia Graphite

`kSkiaGraphite` (`gpu/config/gpu_finch_features.cc`): apagada por defecto en la 128; en la 138 y la 139 solo en Mac ARM64;
**activada por defecto en todo Apple (también Mac Intel) desde la 144** [V]. `macos11-niveles.md` §8.4 la sitúa en 146–151: el
código dice 144. En `main` además Windows. `skia_output_device_gl.cc` (la ruta Ganesh/GL que usa Mojave) sigue en 150, 156 y `main` [V].
Graphite pasa por Dawn/Metal, que en Mojave necesita traducción de más de 20 h con riesgo alto (`macos11-niveles.md`); la
recomendación de entonces, apagarla, sigue en pie. **Es el riesgo técnico nº 1 de cualquier base ≥ 144**: si upstream borra la
ruta Ganesh/GL en Mac, la base deja de ser viable para Mojave (§5).

### 2.3 AVX

En `build/config/compiler/BUILD.gn` de 128, 138, 150 y 156 no aparece ningún `-mavx` ni `-march=` para x86 [V]. No prueba que
no haya despacho en ejecución con AVX (V8, ANGLE, Skia, ffmpeg, Rust): eso es lo que ya está pendiente para la 5,1 (`base-128.md` §4). [N]

### 2.4 Fechas

El calendario oficial (Chromium Dash, Chrome Releases, chromestatus) **no es accesible desde esta sesión**. Las etiquetas del
repositorio confirman que existen 150, 151, 156 y 157; las fechas salen de prensa: 150 el 30-06-2026, 156 el 20-10-2026 y
**ciclo de dos semanas desde la 153** (TechCrunch y 9to5Google, 03-03-2026); Chrome 151 sin soporte de macOS 12 (9to5Mac, 12-01-2026).
Las fuentes se contradicen en la fecha de la 151 (28-07 frente a 30-06). **[N] — COORDINACIÓN debería verificarlas en Chrome Releases.**

## 3. Criterios

### 3.1 Deuda que crece por la base

**Seguridad fuera de Blink y V8** (`cve-128-no-explotados.md/.csv`, 26-10; 750 CVE altos o críticos sin portar, 611 alcanzables,
99 críticos). Acumulado por hito de arreglo (calculado sobre el CSV):

| La base llega a… | CVE que ya trae | de ellos «fuga» | críticos |
|---|---|---|---|
| 138 | 12 (2 %) | 6 | 0 |
| 144 | 28 (4 %) | 13 | 2 |
| 147 | 120 (16 %) | 70 | 11 |
| **150** | **468 (62 %)** | 373 | 75 |
| 151 | 544 (73 %) | 444 | 81 |
| **156** | **750 (100 %)** | 611 | 99 |

Lectura crítica:
- **Subir a una base ≤ 147 no compra seguridad**: el grueso (348 CVE) se arregla en 148–150. Por eso descarto 138/139/140/144.
- La cifra es sospechosa y debe verificarse: el propio documento avisa de 3 599 registros de Chrome con ID de 2026 frente a
  190 de 2025. A ritmo de 2025 (~3 por hito, 2025 en el CSV) portar a mano sería asumible; a ritmo de 2026 (25–140 por hito
  desde el 146) no. **La decisión depende de cuál sea el ritmo real**; SEGURIDAD-PORTES debe contrastarlo con Chrome Releases antes de la puerta (§6). [N]
- Portar a mano sale más barato de lo que sugiere el recuento: el documento da ~0,2 h por CVE si el arreglo aplica tal cual y
  ~15–25 h para los críticos «desde HTML». Pero el código se aleja de la 128 cada hito, y **el coste de cada backport crece con
  la distancia** (precedente: rechazos de parches V8 del 9,8 % en el 137 al 17,5 % en el 138, `fork-propio.md` §3). Una base
  cercana a la punta (156 frente a `main` 159) mantiene baratos los backports futuros; la 128 está a 31 hitos.

**Infraestructura de Blink aplazada** (`version-2.*.md`, `motor-niveles.md`; recuento del subagente, no hay cuenta oficial):

| Nivel | Aplazados por infraestructura que la 128 no tiene |
|---|---|
| 132 | 1 (`SkipTemporaryDocumentFragment`: refactors de `Node::ConvertNodeUnionsIntoNode` 129–131) |
| 135 | 2 (`text-box-trim` con spanners → `BoxFragmentBuilder`; `feImage` → `FEImage::GetImage()`) |
| 136 | ≥ 4 (`HTMLImageElementActualNaturalSize`, `GetValueIfKnown`, `HashTrie`, `SplitCache…`) |
| 138 | 5 (`sibling-index()` 64 commits; `stretch`; textarea; `SchedulerYieldCrossOriginFix`; `LayoutJustifySelfForBlocks`) |

La tendencia es lineal, ~0,7 por nivel [I: 4 puntos y de peso desigual]; proyectada al 156 darían unos 15–17 bloques, cada
uno con una cadena de refactor que hay que traer antes. Con el fork, traerla es `git cherry-pick A..B`
(`fork-propio.md` §3): más barata, **no inexistente**. Con base 156 la deuda de los niveles ≤ 156 desaparece del todo.

**Coste de seguir a mano 139 → 156** (extrapolado de la tabla de `fork-propio.md` §3): Blink real estable en 21–27 h por nivel
desde el 136; 18 niveles ≈ 380–490 h solo de Blink, sin V8 (rechazos al alza), SEGURIDAD, macOS (~2 h por nivel según
`macos11-niveles.md` §8.3) ni reloj de LOCAL. [I]

### 3.2 Lo que cada candidata exige de Mojave

Traducción 10.14 que hay que **añadir** sobre lo que la base asume (`macos11-niveles.md` §3, §3b, §4, §8):

| Salto de mínimo | Qué borra upstream (y hay que conservar o reponer) | Volumen conocido |
|---|---|---|
| 10.15 → 11 (129) | las ramas `else` que ya son la traducción a 10.14 | serie de ~10 commits; `coreaudio_dispatch_override` sigue haciendo falta |
| 11 → 12 (139) | `kIOMainPortDefault` (15 ficheros), `SecTrustCopyCertificateChain`, `minimumRefreshInterval` (cae en el arranque) | ~115 ficheros, ~900 líneas, la mitad pruebas |
| 12 → 13 (151) | 16 commits «Remove code supporting macOS 12» y un chequeo de «requiere macOS 13» en el arranque que no se porta | ~65 ficheros (42 de producción), +400 −870 |

Costes de papel por nivel de `macos11-niveles.md` §8.3: 132–150 ≈ 35–40 h; 151 ≈ 6 h; 152–156 ≈ 5 h. **Pasar de 150 a 156 añade solo unas 11 h
de papel de traducción** y 282 CVE cerrados (38 % del total): no hay razón técnica de peso para pararse en 150.
Salvedad: es un inventario por símbolos, no por compilación. En la 128 el inventario de papel no vio tres causas de no arrancar
(`base-128.md` §4; `FM.31`), que salieron al compilar con `-Wunguarded-availability` y destino 10.14.

Monterey («debería funcionar», CLAUDE.md): si la traducción se escribe con guardas de **disponibilidad en ejecución**
(no «versión == 10.14»), lo que sirve en Mojave sirve en Monterey, porque Monterey tiene todas las APIs de 12. La base 151+ no
perjudica a Monterey [I].

**Horizonte.** El mínimo de macOS de Chromium sube cada ~11–12 meses: 11 en la 129, 12 en la 139, 13 en la 151 [V]. El
siguiente (14) caería hacia mediados de 2027 [I, tres puntos]. Cada subida añade traducción, así que **la capa Mojave crece con
cada rebase**. Consecuencia: conviene subir una sola vez, alto, y quedarse (como un ESR) hasta que la capa Mojave de la base
siguiente cueste más de lo que vale la garantía de 10.14. Para eso conviene fijar un criterio ahora (§8, decisión 5).

### 3.3 Distancia entre el fork y Google

Con base 156 y sin capa de nivel, el fork queda a 3 hitos de `main` (159) en lugar de a 31. La capa permanente de
`fork-propio.md` (la que sobrevive al rebase) se estima por analogía con Chromium Legacy en 470–650 ficheros
(`legacy-evolucion.md` §6), frente a 1 957 parches hoy; los 26 parches Mojave (~620 líneas) son solo una parte. **No hay medida
propia**: la da el ensayo de rebase (§6, F1). La capa de nivel (los portes 117–138, ~1 300 parches) se tira; ese trabajo no se pierde
porque los niveles pasan a ser el propio Chromium.

### 3.4 WebKit y Gecko sin alejarse de Chromium (`vision-motor.md`, `g5-viabilidad.md`)

- **WebKit:** suelo macOS 11 (bugs.webkit.org 252783, citado por `vision-motor.md` §3 [N, no releído]) → no es adoptable en Mojave. Sirve
  de referencia de arquitectura y para iOS.
- **Gecko:** ESR 115 (macOS 10.12–10.14, fechas discordantes) como referencia de medida en Mojave; no es motor de repuesto.
- **Lo que sí se toma sin alejarse** (distancia 0–1): V1 aislar la capa Mojave (es la capa `compat` del fork), V3 y V7 (C++ más
  seguro, Rust en código nuevo), V13 (**política de rama de soporte largo**: fijar la base y portar selectivamente, justo lo que
  propongo en §3.2) y V14 (línea base medida). Ninguna idea de WebKit ni de Gecko cambia la elección de base.

### 3.5 Linux, Android, iOS y Leopard/PowerPC

La base 156 es Chromium completo (`chrome/android`, Linux, etc.) con DEPS multiplataforma: no se cierra nada. La regla es la de
`fork-propio.md` §5.2: la traducción a Mojave va en commits `Flynk-Class: compat` y `Flynk-Platform: mac`, **sin tocar código común**,
para que Linux y Android compilen sin ella. iOS no cambia: WKWebView obligado (`vision-motor.md` V9). El G5/Leopard no impone
requisito de base (`g5-viabilidad.md`: «no portar ningún motor moderno»); lo único a no cerrar es FlyWeb como servidor de
renderizado remoto en la 7,1 con salida escalable. La base nueva lo mantiene.

## 4. Alternativas descartadas

| Alternativa | Por qué no |
|---|---|
| Quedarse en la 128 con fork propio | Todo el atractivo del fork (rebase por git) se queda sin usar; la distancia a Google crece a diario; 750 CVE sin portar (a verificar) y ~15–17 bloques de infraestructura de Blink en el 156 |
| Base 138 (la de la 2.7.0) | Cuesta un salto completo y trae 12 de 750 CVE; mínimo 11. Solo evita la cadena de refactor hasta el 138 |
| Base 139/140 | Primer nivel con mínimo 12 y nada más: 18–28 de 750 CVE. Es el plan de `fork-propio.md` F2, válido como método, no como destino |
| Base 144 | Graphite pasa a defecto en Mac Intel, 28 CVE. Todo el riesgo, ninguna ganancia |
| Base 151 | Primera con mínimo 13: carga la serie de macOS 13 (L) sin acabar de llegar a la meta |
| Base 157–159 / seguir el tronco | Sin inventario de APIs más allá del 156; la 158 trae SDK 27 (Intel: Xcode 26 aparte); Legacy muestra que seguir el tronco consume el 17 % de los commits en arreglar fusiones |
| Solo backport de CVE críticos sobre la 128 (opción (a)+(b) de `cve-128-no-explotados.md`) | Barata hoy (~15–25 h), pero con coste creciente por la distancia; válida **como puente** mientras dura la transición |
| Cambiar de motor (WebKit, Gecko) | §3.4 |
| Dos saltos (150, luego 156) | Duplica el ciclo de validación en 5,1/6,1/7,1/A1398; el coste extra de traducción 150→156 es ~11 h de papel. El 150 solo como retirada |

## 5. Coste y riesgo

El único precedente medido es el salto 116 → 128: **330–710 h de papel, revisadas a 130–330 h (central ~230)** tras compilar
(`base-128.md` §1.4, FM.32); Chromium limpio con destino 10.14 dio 63–70 avisos distintos y 14 rondas de parches hasta
arrancar en la 6,1 (`-p4` … `-p14`). El salto a 156 se parece (dos subidas de mínimo frente a una, sin Brave que rebasar a mano)
pero no hay cifra propia; el ensayo de F1 la da. **Lo que pesa, por orden:**

| # | Riesgo / coste | Probabilidad / impacto | Cómo se acota |
|---|---|---|---|
| 1 | **`brave-core` 1.69 contra Chromium 156.** `chromium_src` tiene 1 555 ficheros que envuelven los de Chromium, y el código de Brave llama a APIs que cambian en 28 hitos. En el salto 116 → 128 el rebase de Brave fue la partida mayor (150–300 h de 330–710). `fork-propio.md` no lo cubre: asume Brave 1.69 fijo | Alta / muy alto | F0: compilar `brave-core` 1.69 contra el árbol 156 y contar ficheros rotos. **Decisión de Titín**: seguir con `brave-core` como capa o absorber lo que se use en el fork (§8, 3) |
| 2 | Graphite por defecto y ruta Ganesh/GL en Mac (§2.2): crashes del proceso GPU en Mojave (precedente: Dawn en la 128) | Media / alto | F0: arrancar Chromium 156 limpio con `kSkiaGraphite` apagada en la 6,1. Señal de retirada: upstream borra `skia_output_device_gl` o ANGLE-GL en Mac |
| 3 | Rebase de la capa permanente: no hay cifra; la conversión a git (F0 de `fork-propio.md`) puede no reproducir el árbol | Media / alto | `diff -r` vacío de F0 y ensayo F1 |
| 4 | Toolchain: SDK 26.5 y clang 23/24 con destino 10.14 (en la 128 hicieron falta 2 parches de cabeceras con SDK 14); Xcode 26.5+ en la 7,1 (hoy Xcode 26.3, Sequoia): puede exigir macOS 26 en el anfitrión [N] | Media / medio | F0 |
| 5 | Mojave sin arrancar (símbolos fuertes, SPI, sandbox: `Cryptexes`); AVX en la 5,1 | Media / alto | Compilar con `-Wunguarded-availability` y `dlsym` en la 6,1, como en FM.31 |
| 6 | Un solo salto de 18 niveles concentra regresiones web | Media / medio | `motor-117…138.html` como regresión y WPT de la 156 iguales a un Chrome 156 de referencia (el criterio de nivel de CLAUDE.md, aplicado de golpe) |
| 7 | Dato de CVE sobrevalorado (§3.1) | Media / medio | Verificación en Chrome Releases antes de la puerta |
| 8 | El mínimo de macOS vuelve a subir y la capa Mojave se encarece (§3.2) | Alta a ~12 meses / medio | Criterio de «hasta cuándo» (decisión 5) |

Efectos colaterales a decir: la declaración de versión a las webs pasa de 138 a 156 de golpe (el user agent ya se alinea con el
último nivel completo); se pierde el ritmo de «un nivel por versión» durante la transición; los 590 parches de Brave
(1.69) siguen siendo el primer commit del fork.

## 6. Fases e hitos (sin horas)

Los hitos de `fork-propio.md` F0–F1 se mantienen tal cual; esto se añade.

| Fase | Qué | Hito (se cumple cuando) | Quién |
|---|---|---|---|
| **B0 Medidas de papel** | Verificar fechas y ritmo de CVE en Chrome Releases (acceso fuera de esta sesión). Muestra de 20 CVE críticos «fuga» de 146–150: ¿aplica el arreglo a la 128 sin conflictos? | Tabla con el % de arreglos que aplican limpios y el ritmo real por hito | SEGURIDAD-PORTES |
| **B1 Chromium limpio** | Compilar Chromium 156 (y 150) sin parches nuestros, destino 10.14, `-Wunguarded-availability`, Graphite apagada, en la 7,1; arrancar en la 6,1 | Lista de avisos distintos frente a los 63–70 de la 128; arranca en la 6,1 con GPU estable (Ganesh/GL) | LOCAL con MOTOR |
| **B2 Brave contra 156** | Compilar `brave-core` 1.69 con el árbol 156 y contar ficheros rotos. **Actualizado (`brave-propio.md`):** se mide el `brave-core` podado de código muerto (P1) y se compara con el sin podar | Número de ficheros de `chromium_src`/`browser`/`components` que fallan. **Receta exacta y guion de recuento: `brave-propio.md` §11.7** | MOTOR |
| **B3 Ensayo de rebase** (= F5 de `fork-propio.md`, adelantado) | `git rebase --onto 156 128` de la capa permanente sobre el árbol convertido (tras F0–F1) | Conflictos por `Flynk-Class` y por directorio; tamaño real de la capa permanente | MOTOR |
| **Puerta (Titín)** | Con B0–B3 decide: **156**, **150** o **seguir en 128 a mano** | Decisión anotada en `DIRECTIVAS.md` | Titín, ARQUITECTURA |
| **B4 Rebase real** | Capa permanente sobre 156 (o 150); capa Mojave `compat`; Graphite fuera; parches de SDK/toolchain | Arranca en 6,1, 5,1 y 7,1; sin caídas de GPU en A1398 (dos GPU), MBP 2012 (dos GPU) y Air 2013 | LOCAL, MOTOR |
| **B5 Brave/identidad** | `chromium_src` y código de Brave contra la 156; rebranding, privacidad (regla 20), servicios apagados verificados con `network-audit.py` | Cero destinos de Brave; identidad intacta; `about:credits` | MOTOR, SEGURIDAD-PORTES |
| **B6 Validación** | `motor-117…138.html` en verde; WPT de la 156 iguales a las del Chrome 156 de referencia; d8 compilada desde el fork pasa mjsunit | Criterio de nivel (CLAUDE.md) cumplido para el 156 | MOTOR, D8-LINUX |
| **B7 Publicación** | Orden de siempre: d8 en verde → LOCAL → PUBLICACIÓN → web | Versión con `flyweb_engine_level` = 156 | COORDINACIÓN |
| **B8 Después** | Política de rama de soporte largo: backports mensuales de CVE sobre la base fija; nueva base solo por decisión de Titín con el criterio de la decisión 5 | Directiva escrita | ARQUITECTURA |

Durante B0–B6 siguen SEGURIDAD-PORTES con los CVE explotados (CISA KEV) y un paquete 2.7.x si hace falta.

## 7. Qué cambia en la hoja de ruta si se acepta

- 2.8.0 deja de ser el nivel 139: el primer nivel nativo es el 156 (o 150). Los niveles 139–155 no llevan versión propia.
- «Flynk N» pasa a ser el propio Chromium N; la capa de nivel se reduce a lo que haya entre la base y la meta (si 156: nada).
- El número de versión visible 1.N.x/2.N.x lo decide COORDINACIÓN con Titín; esto rompe la regla «un nivel por versión» (regla 18)
  para esta transición y hay que decirlo en `DIRECTIVAS.md`.

## 8. Qué decide Titín

1. **Revocar** la frase «la 128 es la última base que tomamos de fuera» y el punto 6 de `fork-propio.md` (§9 «la base no sube con el fork»).
2. **Meta:** 156 de golpe (recomendado) / 150 (retirada) / seguir a mano. Y la renuncia a versiones por nivel entre 139 y 155.
3. **`brave-core`:** ¿seguir como capa pegada a Chromium 156, o absorber en el fork lo que se use? (riesgo 1; B2 da las cifras).
4. **Riesgo de GPU aceptado:** Mojave y Monterey en Ganesh/GL con Graphite apagada, con la señal de retirada del §5 (riesgo 2).
5. **Criterio de permanencia:** hasta cuándo se mantiene Mojave en la base 156 (propuesta: hasta que Chromium suba a macOS 14 y la capa Mojave de la base siguiente exceda lo que la garantía de 10.14 justifica; el umbral lo pone Titín).
6. **Umbrales de la puerta** tras B0–B3 (los pongo yo como propuesta cuando haya datos; no invento cifras ahora).

## 9. Fuentes y límites

**Código [V]:** `chromium/chromium` en GitHub y `chromium.googlesource.com`, etiquetas 128.0.6613.138, 129.0.6668.0, 138.0.7204.0,
139.0.7258.0, 140.0.7339.0, 144.0.7559.0, 150.0.7871.0, 151.0.7922.0, 156.0.8078.0 y `main` (159.0.8141.0, 03-11-2026): `build/config/mac/mac_sdk.gni`,
`build/mac_toolchain.py`, `tools/clang/scripts/update.py`, `gpu/config/gpu_finch_features.cc`, `build/config/compiler/BUILD.gn`,
`components/viz/service/display_embedder/skia_output_device_gl.cc`. Las etiquetas `.0` son la primera compilación del hito; los valores pueden diferir
unos commits de la rama estable.
**Prensa [N]:** [TechCrunch 03-03-2026](https://techcrunch.com/2026/03/03/amid-new-competition-chrome-speeds-up-its-release-schedule/),
[9to5Google](https://9to5google.com/2026/03/03/chrome-two-week-updates/) (ciclo de dos semanas desde la 153),
[9to5Mac 12-01-2026](https://9to5mac.com/2026/01/12/google-chrome-151-to-drop-support-for-macos-12-monterey/) (la 151 sin macOS 12; el código lo confirma),
calendarios de terceros para fechas (contradictorios).
**Documentos internos:** `fork-propio.md`, `base-128.md`, `mojave-128.md`, `macos11-niveles.md`, `cve-128-no-explotados.md/.csv`,
`version-2.1.0/2.4.0/2.5.0/2.6.0/2.7.0.md`, `motor-niveles.md`, `vision-motor.md`, `g5-viabilidad.md`, `legacy-evolucion.md`.
**No accesibles desde esta sesión:** Chromium Dash, Chrome Releases, chromestatus, developer.chrome.com. No hay publicaciones académicas
sobre este tipo de decisión; la evidencia es de ingeniería (código y registros públicos), y por eso lleva marcas.
**Debilidades:** (i) el recuento de CVE depende de una fuente con una anomalía sin explicar; (ii) el coste real de B1–B3 no se ha medido;
(iii) el inventario de APIs 129–156 es por símbolos; (iv) la proyección de aplazados es lineal sobre 4 puntos; (v) no se ha visto el
código de `brave-core`, solo su descripción en los documentos.
