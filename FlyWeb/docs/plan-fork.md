# Plan de evolución del fork: niveles 132 y siguientes (FM.44, punto 4)

INVESTIGACIÓN-MOTOR-5, 27-10-2026. **Solo papel.** Parte de [`migracion-128.md`](migracion-128.md) (cómo se llegó a la 128),
[`legacy-evolucion.md`](legacy-evolucion.md) §6 («qué esperar por nivel»), [`macos11-niveles.md`](macos11-niveles.md) (plataforma Mac por nivel,
documento 1 de FM.44) y [`hardware.md`](hardware.md) (documento 3), **sin repetirlos**. Aquí: los hechos de plataforma de cada nivel, leídos en
Chromium 129–158, lo que cuesta fuera de Blink y V8, y un plan por tandas con puertas de parada. La directiva del 22-10 («los niveles 132+ no empiezan hasta publicar la 2.0.0») la matiza Titín el 27-10: **MOTOR va dos niveles
por delante de lo compilado** (FM.45, nivel 132) e INVESTIGACIÓN va por delante de MOTOR, con recetas por nivel hasta el 156 (`DIRECTIVAS.md`). Este documento es el marco de esas recetas.

Marcas: **[V]** leído en el código (espejo `chromium/chromium`, tags `129`…`158`); **[I]** inferencia mía; **[N]** sin comprobar. No he
medido nada; las horas de §5 son las ya medidas de `migracion-128.md` §4, no estimaciones nuevas.

## 1. Resumen

1. **Seguir con la doctrina actual: niveles de Blink y V8 sobre la base 128, la plataforma Mac sin tocar.** Lo que cuesta de verdad
   no es el motor (niveles 129–131: ~9,5 h, ~1,6 h de código y ~30 h de reloj, `migracion-128.md` §4) sino lo que hay alrededor, y eso
   hoy está acotado: tres subidas del mínimo de macOS (129, 139, 151) y un cambio de GPU (146–151).
2. **Hasta el nivel 150 el plan es viable sin tocar la GPU** [I]; **el 151 es la puerta**: sube el mínimo a macOS 13 (`mac_sdk.gni`) y quita
   el filtro por modelo de Mac de Skia Graphite (`gpu_finch_features.cc`, §3). Es el primer nivel donde Mojave deja de ser un caso que
   upstream aún tolera por inercia. Propongo **fijar 150 como último nivel planificado** y reevaluar al llegar.
3. **ANGLE Metal es el valor por defecto en Mac Intel ya desde el 129** [V]; la 128 es el último nivel con OpenGL por defecto en Intel. Nuestra
   ruta (Metal en ≥10.15, OpenGL en 10.14, `investigacion-pendiente.md` §3.3) se queda cada vez más sola upstream. Es el riesgo mayor fuera de
   Blink/V8 y está sin cubrir (`migracion-128.md`, «GPU y Metal»).
4. **Antes de empezar un nivel hay que tener la «ficha de nivel» (§4):** lista de ficheros que no se portan (de `macos11-niveles.md`),
   compilación con destino 10.14 y `-Wunguarded-availability`, y una prueba de GPU en la 6,1 y la 5,1.
5. **Seguridad en línea propia, por nivel** (`DIRECTIVAS.md`): cada base nueva obliga a rehacer el triaje de CVE (FS.24).

## 2. Hechos por nivel [V]

Del `build/config/mac/mac_sdk.gni` y los archivos de GPU de cada tag (último tag de la rama):

| Nivel | V8 | Mínimo macOS | SDK oficial | Hito de plataforma |
|---|---|---|---|---|
| 128 (base) | 12.8 | 10.15 | 14.0 | `DefaultANGLEMetal` solo en ARM; Intel sigue en OpenGL |
| **129** | 12.9 | **11.0** | 14.0 | **`DefaultANGLEMetal` activado para todos los Mac, también Intel** |
| 130 | 13.0 | 11.0 | 14.0 | — |
| 131 | 13.1 | 11.0 | **15.0** | (ML-KEM: ya portado, FS.17) |
| 132–138 | 13.2…13.8 | 11.0 | 15.1…15.4 | `kSkiaGraphite` solo para Mac ARM (134–143) |
| **139** | 13.9 | **12.0** | 15.4 | serie «Remove code supporting macOS 11» (≈115 ficheros, `macos11-niveles.md` §3b) |
| 140–141 | 14.0–14.1 | 12.0 | 15.5 | — |
| **142** | 14.2 | 12.0 | **26.0** | SDK de macOS 26 |
| 143–145 | 14.3–14.5 | 12.0 | 26.0–26.2 | llega `KeychainKeyProvider` de `os_crypt_async` (`fw1-receta.md` §5) |
| **146** | 14.6 | 12.0 | 26.2 | **Skia Graphite por defecto en todo Apple, también Intel** (con filtro por modelo) |
| 147–150 | 14.7–15.0 | 12.0 | 26.2–26.5 | el filtro por modelo sigue |
| **151** | 15.1 | **13.0** | 26.5 | **mínimo 13.0; desaparece el filtro por modelo de Graphite** |
| 157–158 | — | 13.0 | 27.0 | — |

(V8 = una décima por nivel, `v8/v8` tags `12.8.98`…`14.9.98`; los de 15.x los infiero por la regla [I].)
**Corrige el borrador del documento 1:** el SDK 14.0 llega hasta el 130 y el 15.0 empieza en el 131 (el borrador decía 131 y 132); el 26.0 empieza en el 142 (no el 143).

### El filtro de Graphite (146–150) [V]

`gpu/config/gpu_finch_features.cc` (150, l. 511-545) solo activa Graphite si ANGLE Metal está elegido y, en Mac, si el modelo está en la lista de
la «familia Mac2 de Metal»: `MacBookPro ≥ 13`, `MacBookAir ≥ 8`, `MacBook ≥ 9`, `iMac ≥ 17` (salvo `iMac15,1`), `iMacPro`, `Macmini ≥ 8`; los modelos que no
están en la lista (Mac Pro, Mac Studio) se consideran compatibles. En 151 esa lista **ya no existe**: basta ANGLE Metal + decodificador passthrough.
Para FlyWeb: Air 2013 (6,x), mini 2012 (6,x), MBP 2012 (9,1) y A1398 (11,5) quedan **fuera** por modelo, y en Mojave no hay ANGLE Metal, así que
Graphite no se activa; **pero** la 6,1 y la 5,1 son «Mac Pro», que el filtro de upstream da por buenos aunque sus GPU (GCN 1, Kepler…) no
tengan la familia Mac2 [I]. Hay que fijar la desactivación de Graphite en nuestros parches, no confiar en la lista.

## 3. Qué cuesta fuera de Blink y V8

| Frente | Qué trae el 132–150 | Coste y riesgo para Mojave | Quién |
|---|---|---|---|
| **Plataforma Mac** | Una serie de ≈115 ficheros al subir el mínimo (139; antes 129) y, en medio, retoques sueltos | **No se porta** la serie; en cada fichero vetado gana la rama de la 128 (`macos11-niveles.md` §7). Legacy midió 1–3 h por commit afectado [H] | MOTOR + escáner |
| **GPU** | Metal por defecto (129), Graphite (146+), Dawn Metal y ANGLE evolucionan; WebGPU sigue apagada hasta que lleguen los arreglos | **El mayor**: ANGLE-OpenGL en Mojave pierde pruebas upstream a partir del 129; hay que decidir cuántos niveles sostenemos con parches propios [I] | LOCAL + MOTOR |
| **Toolchain / SDK** | SDK 15 (131), SDK 26 (142), 27 (157); clang y Rust de Chromium suben con cada nivel | Compilar en la 7,1 con Xcode 26.3 y destino 10.14: **comprobar que el SDK 26 con `mac_deployment_target=10.14` enlaza y que `-Wunguarded-availability` no se desborda** [N] | LOCAL |
| **Red y seguridad** | CVE de red, sandbox, IPC; nuevos mínimos de TLS | El triaje se rehace por base (FS.24); el sandbox de Mac cambia de forma recurrente (`legacy-evolucion.md` §5) | SEGURIDAD-PORTES |
| **Servicios de Google** | `os_crypt_async`, passkeys, DBSC, componentes | Cada nivel puede reintroducir llamadas a servicios que apagamos (regla 20) | MOTOR + `network-audit.py` |

## 4. La «ficha de nivel» (propuesta para MOTOR y LOCAL)

Antes de dar un nivel por empezado, y de nuevo antes de entregarlo:

1. **Plataforma:** el escáner de `FlyWeb/tools/macos-api/` sobre los tags N−1 y N, y el cruce con la lista de ficheros vetados (`macos11-niveles.md` §3 y §3b).
2. **Compilación:** `mac_deployment_target=10.14`, `-Wunguarded-availability-new`; cada aviso nuevo que no esté en el inventario de `mojave-128.md` es un hueco.
3. **GPU:** `repro61.py todo` y 10 min de WebGL/canvas en la 6,1; y la 5,1 con la GPU instalada. Registrar `chrome://gpu` (backend de ANGLE, Graphite apagada).
4. **Motor:** `motor-N.html` en verde y las WPT de la N iguales a las del Chrome N (`motor.md`); huella de red coherente (`herramientas/huella-tls.sh`).
5. **Privacidad:** `network-audit.py --mode reposo` sin destinos de Brave ni de Google nuevos.
6. **Seguridad:** fila FS del nivel con los arreglos de upstream posteriores (regla 17).

## 5. Plan por tandas

| Tanda | Niveles | Por qué ahí | Puertas |
|---|---|---|---|
| **A** | 132–138 | Mínimo macOS fijo (11.0), SDK 15.x, Graphite solo en Mac ARM: lo más tranquilo | ficha de nivel; medir CPU de la Release con PGO (`hardware.md` §3) |
| **B** | 139–145 | Cruza el 12.0 (serie vetada), SDK 26; `os_crypt_async` ya con proveedor de Mac | revisión de GPU en Mojave tras el 142 (SDK nuevo) |
| **C** | 146–150 | Graphite por defecto en Intel Mac con filtro por modelo; sigue el mínimo 12.0 | desactivar Graphite en nuestro parche; probar la 6,1 y la 5,1 |
| **Puerta** | **151** | Mínimo 13.0 y Graphite sin filtro | **decisión de Titín con medidas**, no automática |

**Coste ya medido de un nivel** (de `migracion-128.md` §4, solo Blink y V8): 129 ≈ 9,5 h; 130 ≈ 1,6 h de código (11–14 h de reloj); 131 ≈ 30 h de reloj.
Es el único dato real. No invento una cifra para los 20 niveles: sumaría una estimación de papel que, según `DIRECTIVAS.md`, sale pesimista. La
plataforma añade, por serie de mínimo, 2–3 h de lectura [I] y 1–3 h por commit afectado [H, Legacy].

## 6. Criterios de parada y de cambio de ruta

- **Parar en el 150** si al llegar la ficha de nivel muestra que el coste de GPU supera lo que se gana (y quedarse con parches de seguridad sobre ese nivel).
- **Cambiar de ruta (adoptar una base ≥ 139)** solo si: (a) el escáner da más de ~100 ficheros vetados que ya no compilan con la rama de la 128, o
  (b) upstream retira la ruta Ganesh/OpenGL de ANGLE para Mac [N: no encontré señal clara; ver `migracion-128.md`, «GPU y Metal»] o (c) V8/Blink exigen un clang o un SDK que ya no
  compile con el destino 10.14. Los umbrales son míos y discutibles.
- **No hay vuelta atrás gratis:** cada nivel entero publicado fija la versión declarada a todas las webs (`DIRECTIVAS.md`).

## 7. Qué falta investigar

1. **ANGLE-OpenGL en Mac tras el 129:** cuánto código del backend GL de macOS se ha tocado o quitado en `third_party/angle` (no está en el espejo que usé) [N]; es la pregunta que decide la tanda C.
2. **Dawn/WebGPU:** en qué nivel llegan los arreglos que permiten reabrir WebGPU (CVE-2026-5281), y si Dawn-Metal exige macOS > 10.14 (`DIRECTIVAS.md`).
3. **Serie de macOS 13 (151):** leerla como se hizo con la de 12 (`macos11-niveles.md` §3b). Solo si se decide pasar de la tanda C.
4. **Brave por nivel:** qué trae la rama de Brave de cada nivel que importe (solo privacidad, `DIRECTIVAS.md`); FM.37 sigue pendiente.

## Fuentes

- Código: `chromium/chromium` tags `128.0.6613.138`, `129.0.6668.112`, `130.0.6723.192`, `131.0.6778.268`, `134.0.6998.221`, `140.0.7339.264`, `146.0.7680.252`, `150.0.7871.287`,
  `151.0.7922.226`, `158.0.8127.1` (`build/config/mac/mac_sdk.gni`, `ui/gl/gl_switches.cc`, `gpu/config/gpu_finch_features.cc`); `v8/v8` tags `12.8.98`…`14.9.98`.
- Dentro del repo: `migracion-128.md` §4, `legacy-evolucion.md` §5–6, `macos11-niveles.md`, `hardware.md`, `fw1-receta.md`, `investigacion-pendiente.md`, `docs/DIRECTIVAS.md`.
