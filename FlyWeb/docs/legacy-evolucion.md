# FlyWeb — cómo evolucionó Chromium Legacy, versión a versión (INVESTIGACIÓN-MOTOR, 20-10-2026)

Estudio en papel (fila FM.34, caso 2). Sin código ni ramas. **Propone; decide Titín.** Sigue a `chromium-legacy.md`
(FM.33): allí, el método y el estado de Legacy; aquí, **qué obligó a cambiar en cada versión y cuánto costará cada nivel
futuro**. Fuente: la copia `lamosquita-net/chromium-legacy` (ramas `master.lion` y `stable.lion`, etiquetas) y los tags
de Chromium en el espejo de GitHub.

**Etiquetas:** **[V]** medido en los repos; **[I]** inferido; **[H]** hipótesis. Las horas son **estimación mía**.

> **Corrección tras la decisión de Titín: el mínimo de la base 128 es Mojave 10.14.** En la primera versión de este
> documento avisé de que «cambia una cifra de FM.31/FM.32» (+30–70 h para High Sierra). **Estaba mal agrupado, y con
> Mojave no cambia nada:**
>
> - Una marca `10.N` en el código de Legacy es una **comprobación en esa frontera** (`@available(macOS 10.N)`,
>   `IsAtLeastOS10_N`). Solo hay que mantenerla si el mínimo es **inferior** a 10.N. **Con Mojave hacen falta los ficheros
>   con marca 10.15** (la clase I de `migracion-128.md`): en la 124 son **53**, y contra Chromium 128 aplican 29 tal cual,
>   15 con fusión limpia, 8 con conflicto y 1 que ya no existe (**9 a mano**). Los de 10.14 y 10.13 no hacen falta.
> - **La clase I de FM.32 se queda en 25–55 h y el total de la migración en ≈ 130–330 h.**
> - High Sierra habría añadido **37 ficheros** (marca 10.14 o ramas propias de 10.13/10.14, sin 10.15), **10 a mano** (6
>   conflictos y 4 que desaparecen): ≈ **19–42 h** [H, tasa de FM.32] y una máquina con 10.13 que no tenemos.
> - Lo que dije (69 ficheros, 16 a mano, 31–68 h) **contaba además 32 ficheros con marca 10.13 que son código para 10.12 y
>   anteriores** y no hacen falta ni con High Sierra. La misma agrupación estaba en la clase B de `chromium-legacy.md`
>   (corregida en el mismo PR).

## 1. Resumen

- **El parche de Legacy crece a escalones, no de forma continua** [V]: **+100 ficheros en la 104** (mínimo 10.11/10.12 →
  10.13) y **+90 en la 117** (10.13 → 10.15). Entre escalones, **≈ 6–8 ficheros netos por hito**.
- **Cada escalón es una serie de *reverts*** de los commits «Remove … support from <área>» de Chromium [V]: **20 reverts el
  mismo día** (8-06-2022, y uno más una semana después) para 10.11/10.12, y **30 en dos semanas** (29-06 → 13-07-2023) para
  10.13/10.14, que tocan **147 ficheros** de unas 20 áreas.
- **Regla práctica:** ≈ **45–55 ficheros por cada versión de macOS que se mantiene por debajo del mínimo de Chromium**
  (100 ÷ 2 y 90 ÷ 2) más ≈ 6–8 por hito. En la 124, las marcas de versión están en 46 ficheros (10.13), 52 (10.14) y 53
  (10.15) [V].
- **Chromium subió el mínimo de macOS en la 104 (10.13), la 117 (10.15), la 129 (11.0) y la 139 (12.0)**, y no lo ha
  vuelto a subir hasta la 147 [V, `mac_sdk.gni` de cada tag]. Intervalos: 13, 12 y 10 hitos.
- **Entre escalones se repiten tres problemas** [V]: Chromium **moderniza una API** (portapapeles y UTType, hojas, botones),
  Chromium **usa API o frameworks nuevos sin guarda** al migrar de SDK (24 commits en tres días en la 118, 14 de ellos guardas; 13 guardas en dos semanas en mayo de 2024)
  y **cambian el sandbox y la firma**.
- **Para nuestro fork: los niveles de motor no pagan nada de esto.** Legacy no tiene fork de V8 y en Blink solo toca 15
  ficheros de macOS. Lo que cuesta es **cambiar de base** (§6): ≈ +45–55 ficheros y ≈ 30–60 h por cada versión de macOS que
  quede por debajo del mínimo nuevo.

## 2. Método y límites

- **Tamaño del parche por hito [V].** Para cada etiqueta `*-stable.lion` (23 hitos, 100 → 124; no hay 122, 123 ni 125–127 en
  `stable.lion`), `git diff --name-status` contra el tag de Chromium de la misma versión (`124.0.6367.207.1-stable.lion`
  contra `124.0.6367.207`). Excluyo Android, iOS, pruebas, documentación e infraestructura: **solo código de escritorio**.
- **Qué forzó cada paso [V].** Los 235 commits propios de `master.lion` desde 06-2022 (sin fusiones), cada uno con la
  versión de `chrome/VERSION` en su momento, su asunto y sus ficheros. **Clasificación por palabras del asunto:
  aproximada.**
- **Qué aplica a la 128 [V].** Fusión de tres vías (`git merge-file`) de cada fichero con marca 10.13/10.14/10.15 de la 124:
  base = Chromium 124, nuestro = Legacy 124, suyo = Chromium 128. **Una marca `10.N` es una comprobación en esa frontera:
  solo hace falta mantenerla si el mínimo es inferior a 10.N** (Mojave: las de 10.15; High Sierra: también las de 10.14).
- **Límites.**
  - Los commits de las versiones 100–103 no están en la ventana (empieza en 06-2022); sus ficheros sí.
  - `stable.lion` no tiene etiquetas 122–123 ni 125–127: la 124 es el último dato de código, y la 127 de `master.lion` se
    midió en FM.33.
  - Legacy mantiene **forks aparte** de Skia, ANGLE, Dawn, SwiftShader, WebRTC, libc++ y BoringSSL (FM.33). **Sus cambios no
    entran en estas cifras.**
  - Los ficheros no son horas: un fichero puede ser una línea o cien. Las horas salen de la calibración de FM.32.

## 3. Serie por hito

«Ficheros» = parche de Legacy sobre Chromium, solo código de escritorio. «Nuevos» y «salen» = respecto al hito anterior.

| Hito | Ficheros | Nuevos | Salen | Mínimo de macOS en Chromium | Qué pasó (commits propios, cuando los hay) |
|---|---|---|---|---|---|
| 100 | 110 | | | 10.11 | Base de partida |
| 101–103 | 117 → 130 | +20 | 0 | 10.11 | Guardas por SO antiguo (10.7–10.12) |
| **104** | **230** | **100** | 0 | **10.13** | **20 reverts el 8-06-2022** (y 1 más el 15-06): «Remove OS X 10.11 and macOS 10.12 code from <área>» (base, PartitionAlloc, kqueue, WaitableEvent, Blink, media, net, gpu, services, device, chrome, components…) |
| 105–109 | 237 → 267 | +43 | 6 | 10.13 | Guardas por API (10.7–10.12), renombres del asignador, *fix merge miss* |
| 110 | 304 | 42 | 5 | 10.13 | **Portapapeles y UTType:** 10 reverts («Move all UTType definitions…», «Migrate off of deprecated TIFF type», «Change the find pasteboard…») y la política de sandbox |
| 111 | 317 | 14 | 1 | 10.13 | 6 reverts más (NSFilenamesPboardType, diálogo de abrir, «Remove macOS sandbox policies specific to … versions that are no longer supported») |
| 112 | 285 | 5 | 37 | 10.13 | Salen 37 (Legacy reduce alcance o Chromium absorbe; no lo he separado [H]) |
| 113–116 | 292 → 315 | +59 | 29 | 10.13 | Sobre todo *fix merge miss* y guardas (AuthenticationServices débil, LocalAuthentication) |
| **117** | **398** | **90** | 7 | **10.15** | **30 reverts en dos semanas**: «Revert Bump the macOS deployment target to 10.15» y 27 «Remove 10.13, 10.14 support from <área>» |
| 118 | 407 | 18 | 9 | 10.15 | **24 commits en tres días** (23-08, 2-09 y 3-09-2023; 14 guardas): migración de SDK (AVFAudio, CFNetwork, LocalAuthentication, NSSharingService…) |
| 119 | 446 | 46 | 7 | 10.15 | Terceros (cpuinfo, pthreadpool, libaom, re2, webgl…) |
| 120 | 416 | 19 | 49 | 10.15 | Salen los terceros de la 119; reverts de hojas (sheets) y `clock_gettime` |
| 121–124 | 436 → 445 | +57 | 28 | 10.15 | 3 *fix*, 2 reverts de listas negras de GPU (123), fuentes (`FontMatchingCTMigration`), descarga en segundo plano |
| (127) | | | | 10.15 | 13 guardas en dos semanas (mayo 2024): AuthenticationServices, CryptoTokenKit, VideoToolbox, `change_fdguard_np`, `audit_token_to_pid` |

**Dónde cae el parche de la 124** [V] (todos los ficheros, antes de quitar pruebas): `chrome/browser` 70, `ui/base` 53,
`base` 45, `device` 23, `components/remote_cocoa` 20, `media` 16, `services` 16, `content/browser` 15, `gpu` 15,
`third_party/blink` 15, `third_party/mozilla` 15, `remoting` 13, `sandbox` 10, `ui/views` 10.

## 4. Qué cambios de Chromium forzaron qué, por áreas

Commits propios por tema, en 190 (sin fusiones, sin *fix merge miss* ni infraestructura). Temas por palabras clave:
**aproximado** [V para los totales, I para el reparto].

| Tema | Commits | Ventanas donde aparece | Ejemplos |
|---|---|---|---|
| Mínimo de SO (serie «Remove 10.x support») | 47 | 104 (19), 117 (28) | 20 reverts el 8-06-2022; 30 en 29-06 → 13-07-2023 |
| Ventanas y AppKit | 27 | 118–121 (10) | `NSWindow` débil (`__weak`), hojas, botones, `convertPointFromScreen`, `NSDictionary dictionaryWithContentsOfURL:error:` |
| Firma y compilación | 21 | 110–111 (7), 118–121 (5) | `codesign` ad hoc, `get-task-allow`, avisos de clang |
| Procesos y sistema | 13 | 118–121 (5) | `task_policy_set`, `pthread_set_qos_class_self_np`, `audit_token_to_pid`, `change_fdguard_np`, `clock_gettime` |
| Portapapeles, arrastrar y UTType | 11 | **110–111 (10)** | NSFilenamesPboardType, TIFF, promesas de ficheros, diálogo de abrir |
| Autenticación y llavero | 10 | 122–127 (4) | LAPolicy (biometría), AuthenticationServices, CryptoTokenKit, `kSecGuestAttribute…` |
| Multimedia, GPU, color y fuentes | 10 | 122–127 (4) | VideoToolbox, AudioUnit, AVFAudio, `FontMatchingCTMigration`, constantes de espacio de color |
| Sandbox (Seatbelt) | 9 | 110–111 (5) | Políticas por versión, `sysctl-read`, `cfsprefsd` |
| Asignador y sincronización | 8 | 107–111 (5) | PartitionAlloc (desactivado, `PA_CONFIG_HAS_FAST_MUTEX`), `WaitableEvent`, `ChannelMac` |
| Otros (cambios de producto de Legacy) | 34 | | `kAEGetURL`, botones de ventana, `IsObsoleteNowOrSoon()` |

Además, **39 commits «fix merge miss/errors/build»** (17 % de los 235): es el coste del método de rama larga (FM.33),
no de macOS.

## 5. Patrones que se repiten

1. **Los escalones son series de reverts por área, y se hacen mejor justo al aterrizar** [V]. En la 104 se revirtieron 20
   commits el mismo día (8-06-2022), cuando los de Chromium acababan de entrar. En la 117 costó dos semanas con más conflictos. **Quien hace el
   revert tarde, paga las divergencias.**
2. **El mínimo de SO no es el único empujón** [V]: la modernización de APIs (portapapeles y UTType en la 110–111, hojas en la
   120) obliga a revertir o a poner guardas aunque no suba el mínimo.
3. **Las guardas llegan en rachas** [V], no repartidas: 24 commits en tres días (118), 13 guardas en dos semanas (mayo de 2024). Cada racha
   coincide con una migración de SDK de Chromium.
4. **Siempre las mismas zonas**: sandbox, portapapeles/UTType, autenticación (LocalAuthentication, AuthenticationServices),
   ventanas AppKit, asignador y firma de código. Si hay que vigilar algo en una base nueva, es esto.
5. **El coste de seguir a Chromium cada día** (fusiones y *fix merge miss*) es del método y no lo pagamos: nuestra base es
   fija.
6. **Lo que aplica a la 128.** De los 122 ficheros con marca 10.13/10.14/10.15 en la 124 [V]:

   | Resultado contra Chromium 128 | Ficheros | **10.15 (Mojave: lo que hace falta)** (53) | Solo 10.14 y ramas de 10.13/10.14 (High Sierra: **no**) (37) | Solo 10.13 (código para 10.12 y anteriores: **no**) (32) |
   |---|---|---|---|---|
   | Idéntico: aplica tal cual | 55 | 29 | 14 | 12 |
   | Fusión limpia (tres vías) | 42 | 15 | 13 | 14 |
   | **Conflictos** | **18** | 8 | 6 | 4 |
   | **Ya no existe en la 128** | **7** | 1 | 4 | 2 |

   **El 80 % (97 de 122) aplica sin mano**; para Mojave, el 83 % (44 de 53).

## 6. Qué esperar por nivel en nuestro fork

| Qué se hace | Qué dice Legacy | Coste esperado |
|---|---|---|
| **Nivel de motor N (129…) portado a Blink o V8 con la base 128** | Legacy no tiene fork de V8 [V, FM.33] y en Blink solo toca 15 ficheros de macOS (`layout_theme_mac.mm`, `memory_usage_monitor_mac.cc`, `substring_util.mm`, `file_system_access_regular_file_delegate.*`…) [V] | **Sin coste de plataforma por nivel.** Comprobación previa: el nivel no debe tocar esos 15 |
| **Un commit del nivel que toque `*_mac*`, `ui/`, `base/mac`, `content/browser` o `sandbox`** | Chromium ≥ 129 puede usar API de macOS 11+ sin guarda (su mínimo es 11.0). Legacy tuvo 69 commits de guarda o evitar API en 24 meses (≈ 3 al mes), en rachas [V] | 1–3 h por commit afectado [H]. **Mejor filtrarlos del porte** (regla 2 de `motor.md`) |
| **Cambiar la base 128 → 129** (mínimo 11.0, con Mojave como objetivo) | Una versión más por debajo del mínimo: **+45–55 ficheros** y una serie de ≈ 15–30 reverts «Remove 10.15 support» (las dos anteriores: 20 y 30) | **30–60 h** [H]: ≈ 50 ficheros × 0,6–1,25 h (tasa de la clase I de FM.32) |
| **Cambiar a la base 139** (mínimo 12.0) | Otra versión más: +45–55 ficheros y otra serie | **30–60 h más**, y la base empieza a diferir de Brave en unos 100 ficheros más |
| **Quedarse en la 128** | Los 445 ficheros de la 124 aplican en un 80 % a la 128 (§5.6). El crecimiento neto sin cambio de base es cero | 0 h de plataforma; **seguridad por parches** (regla 17) |
| **Mínimo Mojave (decidido) en lugar de High Sierra** | High Sierra habría añadido 37 ficheros (10 a mano, §5.6) | 0 h con Mojave; ≈ 19–42 h y una máquina con 10.13 con High Sierra |

**Proyección del tamaño del parche si se persigue a Chromium** [H, regla de §1]: 128 ≈ 470 ficheros; 129 ≈ 520–530;
139 ≈ 650. Quedándose en la 128, **se queda en ≈ 470**.

### Un riesgo que Legacy hace visible

1. **Las series se hacen tarde.** Si el plan es 128, los *reverts* de la 117 llevan años de divergencia. Por eso conviene
   **aplicar el diff de la 124 (no los commits de revert)** sobre la 128: el diff ya tiene los conflictos resueltos por
   Legacy, y su reaplicación mide el 80 % de la tabla de §5.6.

## 7. Qué no pude comprobar

- **El parche de la 128 de Legacy no existe**; la 124 es el último dato de código de `stable.lion` y la 127 de `master.lion`
  (FM.33). Los números de §5.6 son 124 → 128.
- **Los forks de terceros** de Legacy (Skia, ANGLE, Dawn…) y las **issues** no están en la copia; sus costes no entran.
- **La clasificación de §4 es por palabras del asunto.** Los totales (235 y 190) son exactos; el reparto por tema, no.
- **Por qué salen 37 ficheros en la 112 y 49 en la 120** [H]: no he separado «Chromium lo absorbe» de «Legacy lo quita».
- **Horas = estimación mía.** Las de §6 usan la tasa de la clase I de FM.32 (≈ 0,6–1,25 h por fichero), no medida aquí.
- **Funcionamiento.** Los 77 % «limpio» son de texto, no de compilación.

## 8. Fuentes

- Copia `lamosquita-net/chromium-legacy`: etiquetas `*-stable.lion` (100 → 124), `master.lion` (235 commits propios desde
  06-2022 y sus fechas).
- Chromium (espejo de GitHub): tags `100.0.4896.127` … `124.0.6367.207`, `128.0.6613.138` y `build/config/mac/mac_sdk.gni`
  de las 104, 117, 129, 138, 139, 142 y 147.
- Proyecto: `chromium-legacy.md` (FM.33), `migracion-128.md` (clase I, FM.32), `base-128.md`, `motor.md`, `CLAUDE.md`.
