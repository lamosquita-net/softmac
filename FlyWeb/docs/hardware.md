# Optimizaciones por máquina, sin AVX (FM.44, punto 3)

INVESTIGACIÓN-MOTOR-5, 27-10-2026. **Solo papel: nada medido ni compilado.** Parte de
[`investigacion-pendiente.md`](investigacion-pendiente.md) (§3: `x86_64h`, descarte de pestañas, ruta de GPU, W6600X) y de
[`vision-motor.md`](vision-motor.md) (V14–V19) **sin repetirlos**. Aquí: lo que se encontró leyendo el código de Chromium 128,
de Brave 1.69.172 y de LLVM, y qué palancas quedan por máquina. Marcas: **[V]** leído en la fuente citada; **[F]** fuente
publicada, no abierta aquí; **[I]** inferencia mía; **[N]** sin comprobar. Regla fija: nada que exija AVX (`CLAUDE.md`).

## 1. Resumen

1. **La Release de FlyWeb muy probablemente se compila sin PGO** [V el código, I el entorno de LOCAL]: Brave fuerza
   `chrome_pgo_phase = 0` salvo que la variable de entorno `is_brave_release_build=1` esté puesta
   (`build/commands/lib/config.js:439-440` de brave-core 1.69.172), y esa misma variable activa la descarga de los perfiles
   (`syncUtils.js:47`). Ni `build.sh` ni `setup-build.sh` la ponen. El perfil de Mac de la 128 **existe y se puede bajar hoy**
   (64,8 MB). Es la palanca de mayor retorno esperado, para **todas** las Mac, sin instrucciones nuevas (§3).
2. **Corrección a `base-128.md` y `investigacion-pendiente.md`:** «la base sigue en `-msse3`» no vale para Mac. En Chromium 128
   `-msse3` está bajo `(is_posix && !is_apple)` (`build/config/compiler/BUILD.gn:1160-1177`) [V]. En macOS manda el valor por
   defecto de clang para el destino, y para `macosx ≥ 10.12` es **`penryn`** (SSSE3 y SSE4.1; `clang/lib/Driver/ToolChains/Arch/X86.cpp`,
   LLVM 19.1.0) [V]. La base real es Penryn (2008), no SSE3 (§2).
3. **Subir el mínimo a SSE4.2/POPCNT no merece la pena** [I]: sobre Penryn solo añade `crc32`, `pcmpestr*` y `popcnt`. Cuesta las
   Mac parcheadas con Penryn y casi no gana. Se retira esa alternativa de `investigacion-pendiente.md` §3.1.4.
4. **V8 ya se adapta a la CPU en ejecución:** su JIT activa AVX, AVX2, FMA, BMI1/2, LZCNT, POPCNT y SSE4 por CPUID
   (`src/codegen/x64/assembler-x64.cc:87-128`, V8 13.0) [V]. No hay nada que optimizar en V8 por máquina compilando distinto.
5. **Las palancas por máquina son de configuración, no de compilación:** PGO (todas), memoria según RAM, ruta de GPU y energía en
   portátiles (§5). El binario doble `x86_64h` sigue siendo el último recurso (ya estudiado).

## 2. Qué compilamos hoy y cómo comprobarlo

- **Destino por defecto de clang en Mac** [V]: `penryn` si el destino es `macosx ≥ 10.12`; `core2` en versiones anteriores;
  `core-avx2` solo para el subtipo `x86_64h`. Con `mac_deployment_target=10.14` (`build.sh`) sale Penryn.
- **Chromium no añade `-march` ni `-mtune` para x86-64 en Mac** [V: `compiler_cpu_abi`, `BUILD.gn:1160-1200`; la 140 solo conserva
  `-msse3` en la rama no Apple, l. 1291]. El ajuste de planificación (`tune`) es también Penryn: un núcleo de 2008.
- **Comprobación que falta (LOCAL, 5 min)** [N]: con el clang de Chromium, `clang -### -target x86_64-apple-macos10.14 -c x.c 2>&1 | grep -E
  "target-cpu|tune-cpu"`, y buscar `-march=`/`-mtune=` en `ninja -t commands brave`. Ampliar `check-no-avx.sh` con eso.
- **Consecuencia:** el binario ya exige SSE4.1 en todo el código sin despacho. Es compatible con la 5,1 (Nehalem/Westmere) y con
  cualquier Mac con Mojave oficial; **no** con un Core 2 anterior a Penryn (Merom). Para el objetivo («solo x86_64, sin AVX») es
  suficiente, pero conviene que `CLAUDE.md` y la web digan «SSE4.1» y no «SSE3» [I].

## 3. PGO: la palanca grande

**Estado** [V salvo marca]:
- Chromium 128: `chrome_pgo_phase = 2` por defecto en `is_official_build` para Mac (`build/config/compiler/pgo/pgo.gni`); el
  perfil se baja con `tools/update_pgo_profiles.py` si la variable de gclient `checkout_pgo_profiles` es `True`
  (`DEPS:152`, hooks 5764-5800). Para x64 usa `chrome/build/mac.pgo.txt`.
- El perfil de la 128: `chrome-mac-main-1714331010-b3f798…profdata`, **64 802 059 bytes**, `storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/…`
  (HTTP 200 comprobado el 27-10-2026). Los de la 116 (58,8 MB) y la 131 (68,0 MB) también siguen publicados.
- Brave 1.69.172: `args.chrome_pgo_phase = 0` si `!isBraveReleaseBuild()` (`config.js:439-440`), **después** de expandir `extraGnArgs`
  (l. 436): un `--gn chrome_pgo_phase:2` de `build.sh` se pisa [I: que `--gn` de `build.sh` vaya a `extraGnArgs`]. `isBraveReleaseBuild()` solo es cierto con `is_brave_release_build=1` (l. 265-272)
  y también activa `checkout_pgo_profiles` (`syncUtils.js:47`).
- Esa variable gobierna además: parche de versión ignorado (l. 208), `mojom message id scrambling` y dSYMs (l. 439-453), icono de logo
  y `enable_brave_page_graph_webapi_probes` (l. 553-565). **Con la variable a 0, ese último es `true`** [V]: sondas de Page Graph de Brave
  compiladas. `motor-niveles.md:323` dice que la bandera está apagada; **comprobar `enable_brave_page_graph` en el `args.gn` real** [N].

**Qué se espera ganar** [F, no medido en Intel Mac]: Chromium atribuyó a PGO hasta un 15 % en Windows en 2016 (arranque 16,8 %, nueva
pestaña 14,8 %) ([blog de Chromium](https://blog.chromium.org/2016/10/making-chrome-on-windows-faster-with-pgo.html)); para Chrome 85 se habló
de cargas de página hasta un 10 % más rápidas ([repost](https://developers-jp.googleblog.com/2020/09/chrome.html), Windows y Mac, por confirmar); Opera midió un 5 %
en Speedometer ([Opera](https://blogs.opera.com/desktop/2016/12/even-faster-opera-for-windows-with-pgo/)). **No he encontrado una cifra de PGO para Mac
Intel**: tomar 5–10 % como hipótesis a medir [I]. Es el mismo tipo de ganancia que `vision-motor.md` V19 dejaba pendiente de confirmar.

**Receta** (2–4 h de trabajo y una compilación Release) [I]:
1. En el entorno de `build.sh` de la Release: `is_brave_release_build=1` (o parche de una línea en `config.js` del fork para que el perfil
   dependa de otra variable, y así no arrastrar logo/Page Graph). Ejecutar de nuevo la sincronización para que el hook baje el perfil
   (`syncUtils.js:47`); comprobar que `src/chrome/build/pgo_profiles/*.profdata` existe.
2. Verificar con `ninja -t commands` que los comandos llevan `-fprofile-use=` y que el avisador `-Wprofile-instr-missing` no inunda el registro.
3. Medir con la herramienta que ya existe (`temp/local5/medir-51.sh`, `bench.py`): Speedometer 3, JetStream 2, MotionMark, arranque en frío y
   memoria, 5 pasadas, 5,1 / 6,1 / 7,1 / Air 2013 / A1398. Criterio mío: ≥ 3 % en JetStream o Speedometer, o ≥ 8 % en arranque, para quedarse con ello.
4. **Perfil y parches:** el perfil se generó sobre el Chromium sin los parches de Brave ni de FlyWeb. Donde el código cambió, el compilador
   descarta el perfil de esa función; la ganancia baja, no se rompe [I; comportamiento de Clang con perfiles desactualizados, sin abrir su documentación].
   Ojo con `dcheck_always_on = true`: el comentario de `pgo.gni` dice que mezclarlo con estos perfiles genera mala planificación.
5. **Por nivel (MOTOR):** al portar un nivel, el `mac.pgo.txt` del nivel N tiene su propio perfil; no se mezcla el de la 131 con una base 128.

**Riesgos:** la compilación Release tarda más y usa más RAM con el perfil (el comentario de `build.sh` ya avisa del enlazado); si el perfil no
se descarga, `gn gen` falla (`assert(pgo_data_path != "")`, `BUILD.gn:~120`), lo cual es una alarma limpia.

## 4. Las máquinas

| Máquina | CPU (ISA relevante) | GPU / ruta | Sistema | Lo que le falta / ojo |
|---|---|---|---|---|
| **MacPro5,1** (peor caso) | Nehalem/Westmere; SSE4.2; AES-NI/PCLMUL solo si Westmere (E5620/X5650, falta `sysctl`, `cifrado.md`) [F]; **sin AVX** | Metal-capable por tarjeta (depende de la GPU instalada) | Mojave | Sin AVX; más lenta por hilo; PCIe 2.0 |
| **MacPro6,1** | Ivy Bridge-EP; AVX, AES-NI; sin AVX2/BMI [F] | D500/D700 (GCN 1.0) vía ANGLE | Mojave | Sin MOVBE: GCM va por la ruta PCLMUL (`mojave-128.md`) |
| **MacPro7,1** | Cascade Lake (Xeon W): AVX-512; AVX2, BMI, FMA [F] | Radeon Pro 580X (Polaris), Metal | Sequoia | Es el equipo que **más** ganaría con `x86_64h`, y el menos representativo |
| **MacBook Air 2013** | Haswell; AVX2, BMI1/2, FMA [F] | Intel HD 5000, 4–8 GB | Mojave (desde 24-10) | Memoria; ahorro de energía; no vale como peor caso |
| **Mac mini 2012** | Ivy Bridge; AVX [F] | HD 4000 | Catalina | Memoria |
| **MBP 15" 2012** | Ivy Bridge [F] | HD 4000 + **GT 650M** (Kepler) | Catalina | Dos GPU: el cambio de GPU y la ruta |
| **MBP Retina A1398 (2015)** | Haswell [F] | Iris Pro 5200 + **R9 M370X** | Monterey | `--use-angle=metal` no arranca (`investigacion-pendiente.md` §3.3) |

Todas las CPU anteriores a Haswell **no** pueden usar la copia `x86_64h`; cualquier mejora que dependa de ella solo alcanza a 3 de 7.

## 5. Palancas, ordenadas

| # | Palanca | Máquinas | Ganancia esperada | Coste | Riesgo | Se mide con |
|---|---|---|---|---|---|---|
| 1 | **PGO en la Release** (§3) | todas | 5–10 % en JS y arranque [I, hipótesis] | 2–4 h + 1 Release | Bajo (cae limpio si no hay perfil) | Speedometer 3, JetStream 2, arranque |
| 2 | **Auditar el `args.gn` de la Release**: `chrome_pgo_phase`, `enable_brave_page_graph*`, `is_official_build`, `symbol_level`, `use_thin_lto`, `dcheck_always_on` | todas | Quita instrumentación y sondas que no deberían estar [I] | 30 min (LOCAL) | Ninguno | Leer el fichero |
| 3 | **`-mtune` más moderno sin cambiar el juego de instrucciones** (`-mtune=generic` o un tipo Sandy/Ivy Bridge) en `compiler_cpu_abi` | todas | 0–3 % [I; sin medida publicada que haya encontrado → [N]] | 1 Release + medida | Bajo: no cambia el ISA | JetStream en 5,1 y 7,1 |
| 4 | **Memoria según RAM** (`investigacion-pendiente.md` §3.2) | Air 2013, mini 2012, MBP 2012 | menos intercambio a disco | solo configuración | Recargas | 20 pestañas reales |
| 5 | **Energía en portátiles** (modo de ahorro de energía de Chromium con `base/power_monitor` + `battery_level_provider_mac.mm`) | Air 2013, MBP 2012, A1398 | autonomía [I] | solo configuración, **más una traducción de Mojave si se porta el nivel 139** (`macos11-niveles.md`: `kIOMainPortDefault`) | Bajo | Duración de batería con vídeo |
| 6 | **Ruta de GPU por máquina** (§3.3 de `investigacion-pendiente.md`) | HD 4000, GT 650M, R9 M370X… | según matriz | matriz de pruebas | Medio | MotionMark + desplazamiento real |
| 7 | **Compilar para Haswell** (`x86_64h`) | Air 2013, A1398, 7,1 | por medir | alto | Medio-alto | ya descrito |
| ✗ | Subir a SSE4.2/POPCNT | — | ~0 | bajo | Pierde Macs parcheadas con Penryn | — |
| ✗ | Compilar V8 distinto por CPU | — | 0: el JIT ya despacha por CPUID (§1.4) | — | — | — |

## 6. Orden propuesto

1. **LOCAL, esta semana:** palanca 2 (leer `args.gn`) y la comprobación de §2. Ni compila ni cambia nada; decide lo demás.
2. **Una Release de prueba con PGO** (palanca 1) junto a la siguiente compilación que ya se vaya a hacer, para medir en las mismas 5 Mac.
3. **Si la ganancia de PGO ≥ criterio:** dejar `is_brave_release_build` (o su sustituto) fijo en `build.sh` y documentarlo; si no, anotar la cifra en `docs/CONSUMO.md`.
4. La palanca 3 (`-mtune`) solo si se compila otra Release por otro motivo.
5. Las palancas 4–6 siguen su fila; este documento no las reabre.

## 7. Lo que no he podido comprobar

- Ninguna cifra de rendimiento: no hay Mac aquí. Las ganancias son hipótesis [I] hasta que LOCAL mida.
- Que Chromium use el clang con el destino por defecto que describo: leí el código de LLVM 19.1.0; el clang de Chromium es una revisión
  de LLVM 19 sin tag, pero la rama `isOSDarwin` es antigua. Falta la comprobación de §2.
- El ISA de las CPU de §4 viene de las especificaciones públicas de Apple e Intel que conozco; no abrí las páginas de ARK.
- Si FlyWeb ya pone `is_brave_release_build` en el entorno de LOCAL (no consta en los guiones del repo), el hallazgo 1 cambia de «falta PGO» a «ya la hay».

## Fuentes

- Código: `chromium/chromium` 128.0.6613.138 (`build/config/compiler/BUILD.gn`, `build/config/compiler/pgo/{pgo.gni,BUILD.gn}`, `chrome/build/mac.pgo.txt`,
  `DEPS`), 140.0.7339.264; `v8/v8` 13.0.98 (`src/codegen/x64/assembler-x64.cc`); `brave/brave-core` v1.69.172 (`build/commands/lib/{config.js,syncUtils.js}`);
  `llvm/llvm-project` llvmorg-19.1.0 (`clang/lib/Driver/ToolChains/Arch/X86.cpp`, `getX86TargetCPU`).
- Perfil PGO: `https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/` (HTTP HEAD, 27-10-2026).
- [Chromium Blog, «Making Chrome on Windows faster with PGO»](https://blog.chromium.org/2016/10/making-chrome-on-windows-faster-with-pgo.html) (2016);
  [repost del anuncio de Chrome 85](https://developers-jp.googleblog.com/2020/09/chrome.html); [Opera, «Even faster Opera for Windows with PGO»](https://blogs.opera.com/desktop/2016/12/even-faster-opera-for-windows-with-pgo/) (2016).
- Dentro del repo: `investigacion-pendiente.md`, `vision-motor.md` (V19), `base-128.md`, `mojave-128.md`, `cifrado.md`, `macos11-niveles.md`, `FlyWeb/scripts/{build.sh,check-no-avx.sh}`, `CLAUDE.md`.
