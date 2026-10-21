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

## Registro

Columnas: fecha · agente (sesión) · modelo · esfuerzo · tarea · horas de reloj · tokens de salida · `cost_usd` ·
contexto al cerrar · notas.

| Fecha | Agente | Modelo | Esfuerzo | Tarea | Horas | Salida | `cost_usd` | Contexto | Notas |
|---|---|---|---|---|---|---|---|---|---|
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
| 21-10 | MOTOR-14 (`…01PZNSmd`) | Opus 5.5 | extra (`xhigh`) | FM.28: F14 (F13 + `seg/subtree-roots-copy`), aviso a LOCAL por el buzón | ~0,2 | — | — | — | `get_session` no da `cost_usd` ni tokens de salida en esta sesión; solo `used_tokens` del contexto |
