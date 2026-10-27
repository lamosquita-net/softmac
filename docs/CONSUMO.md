# Consumo por agente y tarea

Decisión de Titín (21-10-2026; desarrolla OR.2 de `TAREAS.md`): cada agente anota aquí lo que gasta, para elegir modelo
y esfuerzo con datos. El límite del plan es semanal y por uso: un modelo más barato que gaste el doble de tokens agota
antes la semana.

## Cómo se anota

- **Quién:** cada agente, una línea por **tarea entregada** (no por turno) y otra al relevarse (total de la sesión).
- **Datos:** `get_session` al empezar y al terminar la tarea; se anota la diferencia. `cost_usd` es el precio de la API:
  sirve para comparar dentro de un mismo modelo, no tiene por qué pesar igual en el límite del plan entre modelos.
- **Nube:** añade su línea en el PR que ya abre para la entrega (sin PR aparte).
- **Locales** (LOCAL, PUBLICACIÓN, SERVIDOR-LOCAL, ARQUITECTURA): `get_session` no da `cost_usd`; mandan a COORDINACIÓN
  los tokens (salida, lectura y escritura de caché) y COORDINACIÓN los sube por tandas con el coste calculado.
- Si `get_session` no da un dato, «—», nunca estimado sin decirlo.
- **Unidad comparable:** el coste solo se compara entre tareas parecidas (un nivel portado, una compilación, un estudio,
  un PR de tablero). Con una tarea por configuración el dato es ruidoso: no se cambia de modelo por una sola medida.

## Pruebas en los relevos (Titín, 21-10: plan prudente)

Una variable por papel y por relevo. La otra palanca, que pesa más, es el arranque mínimo (OR.1) y relevar al 50 %.

| Papel | Antes | Relevo | Qué se prueba |
|---|---|---|---|
| INVESTIGACIÓN-MOTOR-2 | Sonnet alto | **Opus medio** | Modelo, en estudios en papel |
| SERVIDOR-LOCAL-3 | Sonnet medio | **Sonnet bajo** | Esfuerzo, en tareas con receta |
| SEGURIDAD-PORTES-4 | Opus medio | Opus medio | Sin prueba (un fallo es un agujero) |
| LOCAL-6 | Opus alto | Opus alto | Sin prueba (un fallo cuesta horas de compilación) |
| CONOCIMIENTO-1 | — | Opus medio | Referencia para OR.1 |
| CONTENIDOS-WEB-3 (cuando toque) | Sonnet medio | Opus bajo | Modelo (ya en OR.2) |

## Análisis del 23-10 (COORDINACIÓN-12 con Titín)

**Datos (22-10, sesiones de la nube cerradas; `cost_usd` = precio de API, el plan lo cubre):** 9 sesiones, ~185 $.
COORDINACIÓN-11 41,7 · IDENTIDAD-1 38,1 · MOTOR-16 28,8 · MOTOR-17 24,5 · SEGURIDAD-PORTES-5 18,5 ·
INVESTIGACIÓN-MOTOR-2 14,2 · CONTENIDOS-WEB-2 12,8 · IDENTIDAD-3 3,6 · IDENTIDAD-2 2,4. Semanal de la cuenta: 56 % → 66 %
entre 13:45 y 17:50 (todas las sesiones).

**Conclusiones:**
1. **Lo caro es el contexto releído, no el modelo ni el esfuerzo.** IDENTIDAD-1 (esfuerzo medio): ~30 de 38 $ en lectura
   de caché (148 M). Las sesiones largas cuestan 15–40 $; las cortas con arranque mínimo, 2–4 $ (IDENTIDAD-2 y -3: el
   mismo tipo de trabajo, 7–9 min).
2. **Abrir por tarea y archivar al entregar** funciona (DIRECTIVAS); una sesión quieta solo cuesta si se despierta, pero
   cada despertar relee todo su contexto (y los avisos `send_later` las despiertan).
3. **COORDINACIÓN también engorda:** cada PR que abre o fusiona le trae dos avisos de GitHub largos (~5 k tokens cada uno)
   que se quedan en su contexto; ~35 PR el 22-10. Propuesta: juntar los cambios `[coord]` en menos PR (uno por tanda) y
   relevar COORDINACIÓN hacia el 40 %.
4. **Esfuerzo:** medio bastó en IDENTIDAD y LOCAL-9; MOTOR pasa a alto desde MOTOR-18. Sin datos para bajar más.
5. **Crédito de 100 $:** no vale para Claude Code; solo Agent SDK/API/Agentes gestionados (caduca 06-11).

## Registro

Columnas: fecha · agente (sesión) · modelo · esfuerzo · tarea · horas de reloj · tokens de salida · `cost_usd` ·
contexto al cerrar · notas.

| Fecha | Agente | Modelo | Esfuerzo | Tarea | Horas | Salida | `cost_usd` | Contexto | Notas |
|---|---|---|---|---|---|---|---|---|---|
| 26-10 | BACKUPDRIVE-1 (`…01MMur1T`) | Sonnet 5.5 | medio | B.5: sincronización «nunca perder nada» de BackupDrive (primero dos `rclone copy`, rehecha sobre `bisync` por el ajuste de COORDINACIÓN; versiones con caducidad, conflictos, pruebas con remoto local) | ~0,4 | — | — | — | `get_session` no da `cost_usd` ni tokens (`used_tokens` 0) en esta sesión |
| 22-10 | IDENTIDAD-1 (`…01DiRy6z`) | Opus 5.5 | medio | FM.38 i3: funciones de la 1.15 sobre la 128 (NTP, bienvenida, pestañas fijadas, buscador, extensiones; `nube/base-128-identidad-i3`) | ~0,4 | — | — | — | Total FM.38 i1–i3: ~1,1 h de reloj; `get_session` sin `cost_usd` ni tokens |
| 22-10 | IDENTIDAD-1 (`…01DiRy6z`) | Opus 5.5 | medio | FM.38 i2: servicios de Brave apagados o propios sobre la 128 (53 ficheros, `nube/base-128-identidad-i2`) | ~0,3 | — | — | — | `get_session` sigue sin `cost_usd` ni tokens; su `context_usage` no se ha movido desde i1 (dato no fiable) |
| 22-10 | IDENTIDAD-1 (`…01DiRy6z`) | Opus 5.5 | medio (alto al abrir) | FM.38 i1: marca, iconos, identidad fija y `flyweb://` sobre la 128 (896 ficheros, `nube/base-128-identidad-i1`), arranque incluido | ~0,4 | — | — | 12 % | `get_session` no da `cost_usd` ni tokens de salida; contexto 123 k de 1 M |
| 21-10 | SEGURIDAD-PORTES-5 (`…01H7fz6r`) | Opus 5.5 | medio | FS.23: regla 17 de la base 128 p2 (`seg/128-r17`, 9 `.patch`) | ~0,4 | — | — | — | `get_session` sigue sin dar `cost_usd` ni tokens |
| 21-10 | SEGURIDAD-PORTES-5 (`…01H7fz6r`) | Opus 5.5 | medio | FM.31 clase D, S4 (1 `.patch`, brave-core #4) | ~0,05 | — | — | — | `get_session` no da `cost_usd`, tokens ni contexto (`used_tokens` 0) en esta sesión |
| 21-10 | SEGURIDAD-PORTES-5 (`…01H7fz6r`) | Opus 5.5 | medio | FM.31 clase D, S3 (13 `.patch`, 4 a mano, brave-core #3) | ~0,2 | — | — | — | Ídem |
| 21-10 | SEGURIDAD-PORTES-5 (`…01H7fz6r`) | Opus 5.5 | medio | FM.31 clase D, S2 (11 `.patch` + `util.js`, brave-core #2) | ~0,1 | — | — | — | Ídem |
| 21-10 | SEGURIDAD-PORTES-5 (`…01H7fz6r`) | Opus 5.5 | medio | `nube/base-128` y S1 (17 `.patch`, brave-core #1), arranque incluido | ~0,2 | — | — | — | Ídem |
| 21-10 | SEGURIDAD-PORTES-4 (`…011AG2q3`) | Opus 5.5 | medio | **Cierre de sesión** (relevo a -5): FS.22 (F9–F16, 1.15.2), 2 ramas `seg/*`, inventario de clase D | ~11 (con esperas) | 98 807 | 24,66 | 45 % | Total de la sesión; 59,8 M de lectura y 1,3 M de escritura de caché |
| 21-10 | SEGURIDAD-PORTES-4 (`…011AG2q3`) | Opus 5.5 | medio | FM.31 clase D: inventario de seguridad sobre la 128 (paso 1) | ~0,3 | 6 140 | 9,51 | 39 % | Desde la línea anterior; 1,0 M de escritura de caché (la sesión se recargó al despertar); sesión 21,69 $ |
| 21-10 | SEGURIDAD-PORTES-4 (`…011AG2q3`) | Opus 5.5 | medio | FS.22: F15 de FM.28 | ~0,1 | 2 518 | 1,24 | 35 % | Desde la línea anterior; sesión acumulada 12,18 $ |
| 21-10 | SEGURIDAD-PORTES-4 (`…011AG2q3`) | Opus 5.5 | medio | FS.22: F13/F14 de FM.28, cierre de la 1.15.2 | ~0,1 | 16 145 | 3,10 | 34 % | Desde la línea anterior; sesión acumulada 10,94 $, 68 340 de salida, 36,7 M de lectura de caché |
| 21-10 | SEGURIDAD-PORTES-4 (`…011AG2q3`) | Opus 5.5 | medio | FS.22: arreglos posteriores de la F11 (0e454ce616), 01c7c1b09a, F12 y c215f8e6f0 | ~0,4 | 33 742 | 5,07 | 29 % | Desde la línea anterior (2,76 $ acumulados); 17,8 M de lectura de caché |
| 21-10 | SEGURIDAD-PORTES-4 (`…011AG2q3`) | Opus 5.5 | medio | FS.22: regla 17 de la F11 de FM.28 | ~0,4 | 16 101 | 2,12 | 18 % | Diferencia desde la entrega anterior hasta el primer visto bueno (sin la búsqueda de arreglos posteriores ni seg/top-layer-box, que get_session aún no contaba); 6,2 M de lectura de caché |
| 21-10 | SEGURIDAD-PORTES-4 (`…011AG2q3`) | Opus 5.5 | medio | FS.22: revisión f8→f9 de FM.28 (arranque incluido) | ~0,3 | 2 352 | 0,64 | 11 % | Desde el inicio de la sesión; 0,80 M de lectura de caché |
| 15→21-10 | SEGURIDAD-PORTES-3 (`…01LKiaD9`) | Opus 5.5 | medio | Sesión: FS.14–FS.22 y F9 | — | 446 987 | 129,94 | 78 % | Total de la sesión, al archivarla (21-10) |
| 19→21-10 | INVESTIGACIÓN-MOTOR-1 (`…01KEXwPP`) | Sonnet 5.5 | alto | Sesión: FM.27, FM.30–35 | — | 894 569 | 42,25 | 78 % | Total de la sesión; el doble de salida que SEGURIDAD-PORTES-3 |
| 14→21-10 | CONTENIDOS-WEB-2 (`…015tHV7u`) | Sonnet 5.5 | medio | Sesión: webs 1.13–1.15.1 | — | 32 504 | 8,57 | 32 % | Total de la sesión |
| 20→21-10 | MOTOR-13 (`…01EqxadojD`) | Opus 5.5 | xhigh | Sesión: FM.28 hasta f7 | ~6,5 | 118 634 | 15,14 | 36 % | La vuelta F5 sola: 2,87 $ |
| 20-10 | COORDINACIÓN-8 (`…0133Pd3p`) | Opus 5.5 | alto | Sesión: un día de coordinación | — | 210 762 | 49,09 | 13 % tras compactar | Total de la sesión; la mayor parte, lectura de caché |
| 16→21-10 | LOCAL-5 (`…01DCZDzG`) | Opus 5.5 | alto | Sesión: F5, f7, checkout 128 | — | 49 534 | — | 68 % | Local: sin `cost_usd`; 53,4 M tokens de lectura de caché |
| 21-10 | CONOCIMIENTO-1 (`…01TRKSg5`) | Opus 5.5 | medio | OR.1 entera (9 PR: archivo del tablero, DIRECTIVAS, ARRANQUE, TRAMPAS, manuales) | ~1,1 | ≥12 503 | ≥2,93 | 37 % | **Parcial:** el contador de `get_session` se pone a cero en cada reinicio del proceso de la sesión (5 hoy) y al principio no daba `cost_usd`; solo cuenta desde el último reinicio |
| 20→21-10 | MOTOR-13 (`…01Eqxado`) | Opus 5.5 | extra (`xhigh`) | FM.28: 1.15.2 anchor positioning (medida, porte F1–F4, 5 compilaciones de prueba, arreglos y versión) | ~9 | 151 000 | 23,56 | 46 % | Lectura de `get_session` al poner la versión (21-10 ~10:35). No consta desde cuándo cuenta: el 20-10 a las 23:45 daba 2,87 y 30 213 tras varios reinicios, así que el total de la tarea es mayor; horas de reloj, estimadas por los registros |
| 20→21-10 | MOTOR-13 (`…01Eqxado`) | Opus 5.5 | extra (`xhigh`) | Sesión entera, al relevarse: FM.28 (1.15.2) de la medida a la F13 | ~10,5 | 254 759 | 43,47 | 68 % | `get_session` al relevarse (21-10 ~09:30); como en la línea de la entrega, no consta desde cuándo cuenta tras los reinicios, así que es un mínimo |
| 21-10 | MOTOR-14 (`…01PZNSmd`) | Opus 5.5 | extra (`xhigh`) | FM.28: F14 (F13 + `seg/subtree-roots-copy`), aviso a LOCAL por el buzón | ~0,4 | — | — | — | `get_session` no da `cost_usd` ni tokens de salida en esta sesión; solo `used_tokens` del contexto |
| 21-10 | LOCAL-6 (`local_20642d1a`) | Opus 5.5 | alto | F9→F16 (WPT, crashtests, tandas), 128 Fase 0 (7 pasadas), Release 1.15.2 | ~8 | — | — | 52 % | Local: sin `cost_usd`; 5 h nunca >37 %; semanal 32→40 % (cuenta compartida) |
| 21-10 | COORDINACIÓN-10 (`…01U31mzo`) | Opus 5.5 | alto | Día de coordinación: relevos, buzón/cartero, 1.15.2 (F9→F16), 128 Fase 0 | ~8 | 112 275 | 28,01 | 45 % | Al dejar la nota de relevo |
| 21-10 | COORDINACIÓN-10 (`…01U31mzo`) | Opus 5.5 | alto | Sesión entera, al archivarla | ~8 | 121 471 | 30,23 | 47 % | Total de `get_session` al archivar (21-10 ~18:10 Madrid); 93,8 M de lectura de caché |
| 21-10 | INVESTIGACIÓN-MOTOR-2 (`…014AE1uL`) | Opus 5.5 | medio | FM.31: APIs de macOS > 10.14 en brave-core 1.69.168 (`brave-169-macos.md`) | ~0,25 | 41 499 | 3,70 | 22 % | Diferencia de `get_session` del principio al final del estudio (dentro del turno no se refresca); 9,9 M de lectura de caché; sesión 4,71 $ |
| 21-10 | MOTOR-14 (`…01PZNSmd`) | Opus 5.5 | extra (`xhigh`) | FM.28 F14–F16 (regresión de la capa superior, includes sin PCH), FM.29 en papel (cancelada) y medida de la clase D (FM.31) | ~10 | — | — | ~40 % | `get_session` no da `cost_usd` ni tokens de salida en esta sesión |
| 21-10 | MOTOR-14 (`…01PZNSmd`) | Opus 5.5 | extra (`xhigh`) | Sesión entera: FM.28 F14–F16, FM.29 en papel, medida de la clase D y paso (1) de la base 128 (V8 13.1) | ~11 | ≥72 626 | ≥14,44 | 35 % | `get_session` de las 19:00; el contador va por detrás del último turno. 36,2 M tokens de lectura de caché |
| 21-10 | MOTOR-15 (`…01FdmrW2`) | Opus 5.5 | extra (`xhigh`) | FM.31 clase D: niveles 129–131, anchor y flags sobre la base 128 (pasos 2, 3 y parte del 4) | ~2,5 | — | — | ~50 % | `get_session` no da `cost_usd`, tokens ni uso de contexto en esta sesión; contexto estimado |
| 21-10 | MOTOR-15 (`…01FdmrW2`) | Opus 5.5 | extra (`xhigh`) | Sesión entera, al archivarla: clase D pasos (2)–(4) (129–131, anchor, flags) y fusión de S1–S4 | ~1 | 161 919 | 31,00 | 59 % | `get_session` al archivar; 117,5 M de lectura de caché: el contexto largo releído es casi todo el coste |
| 21-10 | MOTOR-16 (`…01R24qB8`) | Opus 5.5 | extra (`xhigh`) | FM.31 clase D: ML-KEM sobre la base 128 (FS.17), rama `-p2` f1a72ca8de y repaso de includes sin PCH | ~2 | — | — | ~15 % | `get_session` no da `cost_usd` ni tokens en esta sesión; contexto estimado |
| 21-10 | MOTOR-16 (`…01R24qB8`) | Opus 5.5 | extra (`xhigh`) | FM.31: merge de FS.23 (`seg/128-r17`) y rama fija `-p3` de4d1b24b1 | ~0,2 | — | — | ~17 % | Sin datos de `get_session` |
| 21-10 | INVESTIGACIÓN-MOTOR-2 (`…014AE1uL`) | Opus 5.5 | medio | FM.31 Fase 1: hipótesis del cuelgue navegador↔GPU de la 128 (`cuelgue-gpu-128.md`) | ~0,15 | — | — | — | `usage` no se refresca dentro del turno; cifra real por mensaje a COORDINACIÓN |
| 21→22-10 | LOCAL-7 (`local_f2edb095`) | Opus 5.5 | alto | 128 Fase 1: GPU en la 6,1 (Dawn, color_space_util, HDR; cuelgue = LuLu/DIAL), vídeo 1080p, Brave -p3 diagnóstico (2 errores) | ~6 | — | — | 49 % | Local: sin `cost_usd`; límite semanal de todos los modelos 42 → 50 % |
| 22-10 | MOTOR-16 (`…01R24qB8`) | Opus 5.5 | extra (`xhigh`) | FM.31: arreglos de la Static de `-p3` y rama fija `-p4` 70ebebd097 (compila) | ~0,4 | — | — | ~20 % | Sin datos de `get_session` |
| 22-10 | MOTOR-16 (`…01R24qB8`) | Opus 5.5 | extra (`xhigh`) | FM.31: versión declarada 131 sobre la 128, rama fija `-p5` 93332ce63a | ~0,4 | — | — | ~23 % | Sin datos de `get_session` |
| 21→22-10 | COORDINACIÓN-11 (`…016LAphU`) | Opus 5.5 | alto | Relevos (MOTOR-14→16, SEG-PORTES-4→5, LOCAL-6→8), 1.15.2 publicada, 2.0.0 hasta -p6 | ~20 | 135 266 | 40,33 | 54 % | Al dejar la nota de relevo; 105,5 M de lectura de caché |
| 22-10 | MOTOR-16 (`…01R24qB8`) | Opus 5.5 | extra (`xhigh`) | FM.31: `-p7` (regresiones), `-p8` (parches de Mojave), medida de `blink_unittests` y relevo | ~2 | — | — | ~50 % | Sin datos de `get_session` |
| 22-10 | COORDINACIÓN-11 (`…016LAphU`) | Opus 5.5 | alto | Cierre al archivar (cifra final; la de arriba era al dejar la nota) | — | 141 782 | 41,68 | 55 % | `get_session` al archivar; 110,9 M de lectura de caché |
| 22-10 | MOTOR-16 (`…01R24qB8`) | Opus 5.5 | extra (`xhigh`) | Cierre al archivar (total de la sesión: `-p2`…`-p9` y relevo) | — | 142 404 | 28,81 | 49 % | `get_session` al archivar; 79,1 M de lectura de caché |
| 22-10 | MOTOR-17 (`…019jWves`) | Opus 5.5 | extra (`xhigh`) | FM.31: `blink_unittests` de la base 128, rama fija `-p10` 4799b94fc8 (52 parches de tests) y diagnóstico de las 2 WPT (medida pedida a LOCAL-8) | ~1,2 | — | — | ~25 % (estimado) | `get_session` no da `cost_usd` ni tokens; `rate_limit_info` semanal en `allowed_warning` |
| 22-10 | IDENTIDAD-1 (`…01DiRy6z`) | Opus 5.5 | medio (prueba) | FM.38 entera: -i1…-i5 (marca, servicios, funciones, dominio inerte, ID de Shields 2.0), 52 min de reloj | ~0,9 | 169 623 | 38,11 | 70 % | `get_session` al archivar; **147,9 M de lectura de caché (~30 $ del total)**: el contexto creció leyendo brave-core; esfuerzo medio no lo abarata si el contexto se dispara |
| 22-10 | MOTOR-17 (`…019jWves`) | Opus 5.5 | extra (`xhigh`) | FM.31: 2 WPT (ANGLE OpenGL, no motor), `-p11` cd9c85656b (ANGLE Metal ≥ 10.15, `flyweb_metal_bin_path`) y `-p12` ae5626ab1a (merge con identidad `-i5`) | ~0,6 | — | — | 52 % | Cifras de la sesión en la línea de cierre |
| 22-10 | MOTOR-17 (`…019jWves`) | Opus 5.5 | extra (`xhigh`) | Cierre al relevar (total de la sesión: `-p10`…`-p12`, 2 WPT, relevo) | ~2 | 141 374 | 21,83 | 52 % | `get_session` al relevar; 76,1 M de lectura de caché, 0,47 M de escritura |
| 22-10 | MOTOR-17 (`…019jWves`) | Opus 5.5 | extra (`xhigh`) | Cifra final al archivar (sustituye la de cierre de arriba) | ~1,6 | 156 167 | 24,51 | 55 % | `get_session` al archivar; 86,7 M de lectura de caché |
| 22-10 | SEGURIDAD-PORTES-5 (`…01H7fz6r`) | Opus 5.5 | alto | Total al archivar (S1–S4, FS.23) | — | 96 924 | 18,52 | 41 % | `get_session` al archivar; 46,0 M de lectura de caché |
| 22-10 | INVESTIGACIÓN-MOTOR-2 (`…014AE1uL`) | Opus 5.5 | medio | Total al archivar (hipótesis del cuelgue de GPU, #451) | — | 83 083 | 14,24 | 35 % | `get_session` al archivar; 29,9 M de lectura de caché |
| 22-10 | CONTENIDOS-WEB-2 (`…015tHV7u`) | Sonnet 5.5 | medio | Total al archivar (web de la 1.15.x, desde el 14-10) | — | 44 642 | 12,79 | 38 % | `get_session` al archivar; 32,9 M de lectura de caché |
| 22-10 | LOCAL-8 (`local_5c6ba9f8`) | Opus 5.5 | alto | 128: -p9 sin diffs (fiel), -p10 blink_unittests (26 143 bien), 2 WPT = ANGLE OpenGL, -p12 lanzada; relevo | ~4 | 156 673 | — (plan) | 45 % | `get_session` al archivar; 62,6 M de lectura de caché; semanal de la cuenta 56 → 66 % en su turno (13:45–17:50, no solo suyo) |
| 22-10 | IDENTIDAD-2 (`…01LDQZYw`) | Opus 5.5 | medio | FM.38: `-p13` (9 arreglos de LOCAL-9 sobre -p12) | ~0,3 | — | — | ~10 % | `get_session` no da cifras todavía; COORDINACIÓN las toma al archivar |
| 22-10 | IDENTIDAD-2 (`…01LDQZYw`) | Opus 5.5 | medio | -p13 8f3bcc24aa (9 arreglos de -p12), 7 min; **primera prueba de la directiva de ahorro** (arranque mínimo, subagentes, archivar al entregar) | 0,1 | 23 372 | 2,39 | 15 % | `get_session` al archivar; 5,6 M de lectura de caché |
| 22-10 | IDENTIDAD-3 (`…01GrPfLP`) | Opus 5.5 | medio | FM.39 (2): -p14 806e8caa96 (Sparkle, copia del perfil antes de 2.0, «Personalizar»), ~1 h | — | — | — | ~10 % | `get_session` no da cifras todavía; COORDINACIÓN las toma al archivar |
| 23-10 | LOCAL-9 (`local_ad0f5131`) | Opus 5.5 | medio | 128: -p12 (3 arreglos de identidad), -p13, -p14 (migración del perfil, NTP), -p15 (insignia + EGL; MotionMark 6,1 562 → 570), identidad, fijadas, GPU 10 min y `network-audit` en la 6,1; relevo | ~20 (22-10 18:10 – 23-10 14:30, con esperas) | — | — (plan Max) | 31 % | `get_session` no da `cost_usd` ni tokens; `get_usage`: 310 k de contexto, semanal de la cuenta 70 % el 23-10 ~12:00 (no solo suyo); esfuerzo medio (el texto decía alto) |
| 22→23-10 | COORDINACIÓN-12 (`…01NjpdW4`) | Opus 5.5 | medio | -p13/-p14, FM.38–FM.39, análisis de gasto del 23-10; relevo a COORDINACIÓN-13 | ~21 | 155 995 | 35,14 | 70 % | `get_session` al archivar; 113,3 M de lectura de caché (el contexto releído es casi todo el coste) |
| 26-10 | CONTENIDOS-WEB-3 (`…01QqPWLp`) | Sonnet 5.5 | medio | Web de la 2.0.0: `version-2.0.0.md`, portada, novedades y ayuda (copia del perfil, volver a la 1.15.2, contraseñas) | — | — | — | — | Sin datos de `get_session`; 1 subagente Explore (~86 k tokens) para FM.31/38/39 |
| 26-10 | MOTOR-18 (`…01LsgphgH`) | Opus 5.5 | alto | FM.39: -p16 a66f0e3b1f (DuckDuckGo sin `t=`, mojom de `ai_chat` con `enable_ai_chat=false`, sombra de las estadísticas de la NTP), claves inertes 2.x en `build.sh`, triaje de `blink_unittests` (2 subagentes, ~165 k tokens suyos), ~20 min | 0,3 | — | — | — | `get_session` no da cifras; sin push a brave-core (bundle en la rama `nube/motor18-p16-parches`) |
| 26-10 | INVESTIGACIÓN-MOTOR-3 | Sonnet 5.5 | alto | Inventario y prioridades tras la 2.0.0 (`investigacion-pendiente.md`; 2 subagentes de lectura) | ~0,3 | — | — | — | Sin cifras de `get_session` al entregar; COORDINACIÓN las toma al archivar |
| 23→26-10 | COORDINACIÓN-13 (`…01L7rpeb`) | Opus 5.5 | medio | Shields 2.0 revisado y en bak, -p15→-p17, Release y firma, web 2.0, MOTOR-18, INVESTIGACIÓN-MOTOR-3, BackupDrive modo seguro; relevo | ~75 (con fin de semana) | 133 346 | 29,76 | 40 % | `get_session` al dejar la nota; 58 M de lectura de caché |
| 26-10 | MOTOR-19 (`…017Tq5AV`) | Opus 5.5 | alto | FM.40 (2.0.1): -p19 4b4bb3cc68 (aviso falso de actualización, `apply_patches` con ficheros nuevos, «FlyWeb Sync», 2.0.1), `build.sh` 2.x, estudio de fijadas y barrido de marca (1 subagente Explore, ~71 k tokens), ~25 min | ~0,4 | — | — | — | `get_session` no da cifras; bundle en `nube/motor19-p19` |
| 26-10 | SEGURIDAD-PORTES-6 (`…01P1MxRG`) | Opus 5.5 | medio | FS.24: re-triaje de los 16 explotados contra la 128 (2 aplicaban: CVE-2026-11645 y CVE-2025-14174), -p20 8528639ead con d8 13.1 y mjsunit, inventario de 750 no explotados (1 subagente, ~137 k tokens suyos) | ~1,2 | 100 438 | 9,20 | 28 % | `get_session` al entregar; 24,2 M de lectura de caché; compilar la d8 13.1 fue la mayor parte del tiempo |
| 27-10 | MOTOR-20 (`…01MwmK2i`) | Opus 5.5 | alto | FM.41 (2.0.2): -p21 3cc4ce116c (fijadas compartidas, versión visible, xHE-AAC en 10.14; navigator.brave ya quitado; inventario 10.15 y diagnóstico de JetStream/Speedometer con 3 subagentes, ~330 k tokens), ~55 min | 9,36 | 1 364 | 112 141 | 19,9 M lect. / 0,51 M escr. caché | contexto ~24 % al entregar |
| 27-10 | SEGURIDAD-PORTES-7 (`…01MwmK2k`) | Opus 5.5 | alto | FS.25: estudio del cifrado por software (`cifrado.md`; 2 subagentes, ~197 k tokens suyos; datos de -p21 de MOTOR-21), ~15 min | ~0,25 | 54 988 | 2,93 | 11 % | `get_session` al entregar (desde 0 al abrir) |
| 27-10 | MOTOR-21 (`…01MwmK2iH7`) | Opus 5.5 | alto | FM.42: punto 0 (no se alcanza, sin -p22) e inventario Mojave 128 `mojave-128.md` (a–d, cifrado en reposo, BoringSSL; 4 subagentes, ~620 k tokens suyos), ~40 min | ~14 | 3 315 | ~155 000 | 19 % | `get_session` antes del PR: 13,78 $; checkout parcial de la 116 y la 128 |
| 27-10 | MOTOR-23 (`…01MwmK2i3z`) | Opus 5.5 | alto | FM.43 (2.0.2 = -p23 17e7858669): mosca de la NTP visible y en el compositor, `version-2.0.3.md` dentro de `version-2.0.2.md`; sin subagentes (lectura acotada a 3 ficheros), prueba con Playwright, ~35 min | ~0,6 | — | — | ~20 % | `get_session` no da `cost_usd` |
| 27-10 | MOTOR-24 (`…01MwmK2jH`) | Opus 5.5 | ¿? (el entorno no lo da; avisado a COORDINACIÓN) | FM.42 tandas 2 y 3 (2.0.3 = -p24 23f2d547d9, 9 puntos, un commit cada uno; c3 con FS.26), `version-2.0.3.md`, `mojave-203.html`; sin subagentes (lectura acotada a los ficheros de cada punto), ~30 min | — | — | — | ~12 % | `get_session` no da `cost_usd`; primera rama de brave-core subida desde la nube |
| 27-10 | SEGURIDAD-PORTES-8 (`…01MwmK2kz`) | Opus 5.5 | medio | FS.26: regla 17 de c3 (SetLength en 10.14), `seg/fs26-c3` con endurecimiento + df5e15732d/9dfaebca71/8965c323db; sin subagentes (copia ligera de Chromium por git), ~30 min | — | — | — | — | `get_session` no da `cost_usd` ni tokens |
