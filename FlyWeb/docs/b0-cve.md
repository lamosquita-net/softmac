# B0 de FM.55: fechas, ritmo de CVE y muestra de backports a la 128

SEGURIDAD-PORTES-17, 03-11-2026 (encargo de COORDINACIÓN-25, `base-siguiente.md` §6 y §3.1). Marcas como en
`base-siguiente.md`: **[V]** verificado en la fuente citada; **[I]** inferencia; **[N]** no comprobado.

## Conclusión

1. **Las fechas están verificadas en Chrome Releases [V]** (accesible desde esta sesión, al contrario que en la de
   `base-siguiente.md`). Corrección: **la 151 llegó a estable el 29-07-2026**, no el 28-07 ni el 30-06. El ciclo de dos
   semanas empieza en la **152 → 153** (25-08 → 08-09).
2. **El ritmo de 2026 es real [V]**, no un fallo del registro del que salió el CSV: las notas oficiales de Chrome listan
   **240 CVE críticos o altos en la 148 y 262 en la 149**, frente a **~8 por hito en 2025** (132–145). Desde la 152 baja
   a 72–137 por hito, pero los hitos duran la mitad: por semana, el ritmo sigue en **36–68 críticos o altos** (2025: ~2).
3. **Solo el 15 % de los arreglos de la muestra aplica limpio a la 128** (3 de 20) y uno de esos tres no es alcanzable en
   Mac. Con `patch` tolerante a contexto se llega al **35 %** (7 de 20), pero esos 4 hay que revisarlos a mano.
   **El 50 % tiene conflicto real** (10 de 20) y el 10 % no aplica en Mac. **El supuesto de «~0,2 h por CVE porque el arreglo
   aplica tal cual» (`cve-128-no-explotados.md`) no se sostiene para 146–150**: la mitad exige adaptar.
4. Lectura para la puerta [I]: al ritmo medido no se pueden portar a mano los críticos y altos «fuga» de la 128 (611
   pendientes, `cve-128-no-explotados.md`, y crecen a unos 40–70 por semana entre todos los componentes). Esto **refuerza
   subir de base**. No distingue entre 150 y 156: los dos dejan atrás la ola de la 148–149.

## (a) Fechas de estable y ritmo de CVE por hito [V]

Fuente: el canal Atom de `chromereleases.googleblog.com` (1 479 entradas, del 05-2024 al 30-10-2026), solo las notas de
escritorio («Stable/Early Stable Channel Update for Desktop», sin Extended). Para cada hito se cuenta cada CVE una sola
vez, en la primera nota en que aparece. Las cifras incluyen todos los componentes: Blink y V8 también.

| Hito | Estable (escritorio) | Semanas | Críticos | Altos | Crít.+altos | por semana | En el CSV de la 128 (sin Blink/V8) |
|---|---|---|---|---|---|---|---|
| 132–145 (2025) | 14-01-2025 … 10-02-2026 | 4–6 | 7 | 104 | **111 en 14 hitos (~8)** | ~2 | 37 |
| 146 | 10-03-2026 | 4 | 4 | 62 | 66 | 17 | 40 |
| 147 | 07-04-2026 | 4 | 11 | 61 | 72 | 18 | 43 |
| 148 | 05-05-2026 | 4 | 41 | 199 | **240** | 60 | 137 |
| 149 | 02-06-2026 | 4 | 55 | 207 | **262** | 66 | 140 |
| 150 | 30-06-2026 | 4 | 27 | 143 | 170 | 42 | 71 |
| 151 | **29-07-2026** (early 15-07) | 4 | 16 | 130 | 146 | 37 | 76 |
| 152 | 25-08-2026 | 2 | 12 | 80 | 92 | 46 | 46 |
| 153 | 08-09-2026 | 2 | 10 | 76 | 86 | 43 | 48 |
| 154 | 22-09-2026 | 2 | 13 | 59 | 72 | 36 | 36 |
| 155 | 06-10-2026 (early 23-09) | 2 | 12 | 88 | 100 | 50 | 51 |
| 156 | 20-10-2026 | 2 (en curso) | 11 | 126 | 137 | 68 | 25 |

Notas:
- La 128 salió a estable el 21-08-2024 [V].
- **CISA KEV** (catálogo 2026.10.30, espejo `cisagov/kev-data`): los últimos de Chromium son CVE-2026-85046 (04-09),
  CVE-2026-87491 (09-09) y Brotli CVE-2026-111497 (27-10). No hay ninguno nuevo. Las notas de Chrome posteriores al 15-10
  no dicen «exists in the wild» [V].
- **No accesibles desde esta sesión:** NVD, la web de CISA (sí el espejo de GitHub), Chromium Dash y los fallos de
  crbug, que están restringidos. **No se ha verificado por qué crece tanto en 2026**: las notas no lo explican, y no
  hay fuente publicada que lo haga [N]. Una hipótesis plausible, pero sin verificar, es la búsqueda automática de fallos
  con IA. Lo que sí está medido [V]: en las notas de escritorio de 2026, el **94 %** de las entradas lleva la recompensa «TBD» o «N/A» (3 461 de 3 667), frente al 36 % de 2025 (71 de 197). Eso encaja con informes masivos, pero no los demuestra.

## (b) Muestra: ¿aplica el arreglo upstream a la 128?

**Método.** Muestra aleatoria (semilla 55) de **20 de los 65 CVE críticos «fuga» de 146–150** que hay en
`cve-128-no-explotados.csv` [V]. Para cada uno:
1. Se toma el número de crbug de la nota de Chrome Releases.
2. Se buscan los commits con ese número en `chromium/chromium`, `google/skia`, `google/angle` y `libyuv`.
3. Se baja el diff de cada commit.
4. Se ejecuta `git apply --check` contra los mismos ficheros en **Chromium 128.0.6613.138**. Para las dependencias se usa
   la revisión de su DEPS: Skia 938144dd79, ANGLE 7131027744 y libyuv a6a2ec654b. Skia y ANGLE se prueban en un árbol git
   real.
5. Si `git apply` falla, se reintenta con `patch -F3`, que tolera desplazamientos y diferencias de contexto.

Las pruebas (`*_unittest`, `tests/`, expectativas) se separan del código. El guion y la lista de commits están en
`FlyWeb/tools/b0/`.

| CVE | Componente (hito) | Arreglo upstream | Resultado contra la 128 |
|---|---|---|---|
| CVE-2026-10881 | ANGLE (149) | angle 1c82f3a0bd (GL `StateManagerGL`) | **Limpio** en código (solo la expectativa de prueba, con fuzz) |
| CVE-2026-10897 | GPU (149) | 048900b233 | **Limpio** en código (el conflicto es la lista de pruebas de `gpu/BUILD.gn`) |
| CVE-2026-9893 | Skia (148) | skia 3471ebf5af (Vulkan) | **Limpio**, pero **no alcanzable en Mac** (Chrome Mac no usa Vulkan) [I] |
| CVE-2026-9885 | UI Mac (148) | 44241f7763 | Con fuzz (`patch -F3`); un fichero con contexto distinto |
| CVE-2026-11642 | Web Apps (149) | c303de53a6 | Con fuzz (−33 líneas, contexto distinto) |
| CVE-2026-11638 | Printing (149) | 87143bb60c | Con fuzz |
| CVE-2026-13778 | WebUSB Mac (150) | a74fd42d1a | Con fuzz; toca `device_features.cc`, que Brave sobrescribe en `chromium_src` |
| CVE-2026-9883 | Base (148) | 4ee829d343 | **Conflicto** (1 de 4 bloques) |
| CVE-2026-9880 | WebGL (148) | 013d0c860b + angle 557d67e3f6 | **Conflicto** en `gles2_cmd_decoder.cc`; la parte de ANGLE, limpia |
| CVE-2026-11640 | libyuv (149) | libyuv c98edcc8dc | **Conflicto** en `planar_functions.cc` (5 bloques) |
| CVE-2026-10886 | FileSystem (149) | 01cf5ac834 + 0a20265192 | **Conflicto** en 11 de 22 ficheros de código |
| CVE-2026-15899 | CameraCapture Mac (150) | b2c70fcd2e | **Conflicto** en los 2 ficheros |
| CVE-2026-14427 | Skia (150) | skia a145861ad1 + 9d94f46e7f | **Conflicto** (`AtlasTextOp`, `SubRunContainer`; FlyWeb ya parchea el segundo por CVE-2026-3909) |
| CVE-2026-14419 | Skia (150) | skia e7bff78bf5 (Graphite) | **Conflicto**; Graphite está apagada en la 128 de Mac: **no alcanzable** [I] |
| CVE-2026-4440 | WebGL (146) | c1433740f3 | **Conflicto**; usa 2 ficheros que la 128 no tiene (refactor previo) y toca un `.h` que Brave cambia en `chromium_src` |
| CVE-2026-8516 | DataTransfer (148) | 988ac5cb88 | **Conflicto** en 18 de 36 ficheros; 3 de ellos con `.patch` de Brave |
| CVE-2026-13780 | ANGLE/GPU (150) | 7cc1fc67ea (quita comandos de mapeo de búferes de GLES2) | **Conflicto** en 16 de 29 ficheros; es un cambio de diseño, no un parche |
| CVE-2026-8515 | HID (148) | 907bec0593 | **No aplica en Mac**: el arreglo está en `hid_connection_win.cc` |
| CVE-2026-12439 | DigitalCredentials (149) | 4059bc49eb | **No aplica**: el diálogo no existe en la 128 |
| CVE-2026-8522 | Downloads Mac (148) | solo aparece 31a488274d, que es de **iOS** | **Indeterminado**: el arreglo de Mac no es público o no cita el crbug |

**Recuento (20):**

| Resultado | N | % |
|---|---|---|
| Limpio con `git apply --check` (código) | 3 | **15 %** (10 % alcanzable en Mac) |
| Aplica con `patch -F3` (revisar a mano) | 4 | 20 % |
| Conflicto (adaptar a mano) | 10 | **50 %** |
| No aplica (código ausente u otra plataforma) | 2 | 10 % |
| Indeterminado | 1 | 5 % |

Intervalo [I]: con n = 20, el 15 % limpio tiene un intervalo de Wilson al 95 % del **5–36 %**. La conclusión (la mayoría
no aplica tal cual) se mantiene en todo el intervalo.

## Límites

- Se ha comprobado contra Chromium 128.0.6613.138 **sin** los parches de Brave ni los portes de motor de FlyWeb (Blink
  129–138). Solo se han marcado los solapes con `patches/` y `chromium_src/` de brave-core `local/270-arreglos`. Contra el
  árbol real de la 2.7.0 el resultado sería igual o peor.
- La muestra tiene solo críticos. Los altos suelen ser arreglos más pequeños: el % limpio podría ser algo mayor [N].
- «Conflicto» no mide el coste. Va desde un bloque (9883) hasta un rediseño (13780, 8516). No se ha medido en horas.
- Los commits se han localizado por el número de crbug en los mensajes. Si un arreglo no lo cita, falta (el caso de 8522).
- No hay literatura académica sobre la tasa de backport de Chromium. La evidencia es de ingeniería: las notas oficiales
  y los commits públicos.
