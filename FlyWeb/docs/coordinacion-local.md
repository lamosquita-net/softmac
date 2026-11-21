# COORDINACIÓN en local: medida de la prueba y qué hacer con el cartero

ARQUITECTURA, 21-11-2026. Encargo: punto 5 de la nota «20-11 (noche, 2)» de `coordinacion.md` y aviso de COORDINACIÓN-58
del 21-11. Es una **propuesta para Titín**; decide él. Solo he leído registros (rama `buzon`, `coordinacion.md`,
metadatos de las sesiones); no he tocado nada.

Marcas: **[V]** comprobado por mí hoy · **[R]** lo dice una nota y no lo he vuelto a comprobar · **[I]** deducido ·
**[S]** suposición.

## 1. Conclusión

1. **Que se quede en local.** En un día con una publicación entera (3.2.0), la COORDINACIÓN-58 ha hablado con los
   locales sin intermediario y con la nube en minutos, y no consta ningún mensaje perdido. Con el cartero, en los cuatro
   días anteriores hubo retrasos de horas **los cuatro días**.
2. **Retirar el cartero; no subirlo a Sonnet.** No es que Haiku reparta mal: es que ya no queda nada que repartir. El
   tramo que hacía (nube → sesiones locales) lo hace ahora la propia COORDINACIÓN. Un modelo mejor arreglaría un puesto
   que sobra. Sonnet solo si algún día la COORDINACIÓN vuelve a la nube.
3. **Es un día de datos, no una semana.** Falta ver un relevo de local a local (58 → 59), un día sin Titín delante y una
   noche. Propongo darlo por bueno ahora y **revisarlo al cerrar la 3.2.1** con los tres criterios de §5.
4. **Tres ajustes baratos** para que no se repita el fallo del cartero con otro nombre (§4): copia escrita de las
   órdenes a los locales, mirar el buzón al empezar cada turno y vigilar la rama entera.

## 2. Antes: COORDINACIÓN en la nube y cartero (17-11 a 20-11)

Cruce de las altas de ficheros en `origin/buzon` (hora del commit) con las anotaciones de `buzon/ENTREGADO.md` [V]:

| Día | Ficheros a locales con entrega anotada | Mediana | Más de 45 min | Peor caso |
|---|---|---|---|---|
| 17-11 | 25 | 2 min | 9 | 5 h 22 min |
| 18-11 | 51 | 1 min | 1 | 2 h 22 min |
| 19-11 | 55 | 1 min | 5 | 3 h 46 min |
| 20-11 | 36 | 1 min | 14 | 20 h 21 min |

- **167 entregas, 29 tarde (17 %)** [V]. Cuando funciona, reparte en un minuto; el problema es que se cae en silencio
  y nadie lo nota hasta que falta algo. Lo mismo pasó el 09-11 [R, fila CARTERO de `TAREAS.md`].
- Las 14 del 20-11 son todo lo escrito desde las 14:37 UTC: se quedaron sin entregar hasta que la 58 las repartió a
  mano la mañana del 21 (13 a 20 h después, con una noche en medio) [V]. La de D8-LINUX no es solo culpa del cartero:
  el PC de Ubuntu estaba apagado [R].
- Las horas de entrega las escribe el propio cartero, y la nota del 20-11 dice que dio por entregado lo que no lo
  estaba [R]. Las cifras reales no son mejores que estas.
- **El 42 % de lo repartido eran avisos de relevo de la propia COORDINACIÓN**: 80 de 189 ficheros a locales en esos
  cuatro días, por 15 relevos (de la 43 a la 58) [V]. La nube se relevaba al 35 % cada dos o tres horas (cuatro veces
  el 20-11, sin contar el paso a local).

## 3. La prueba: COORDINACIÓN-58 en la 7,1 (21-11)

- **Sesión** [V]: Opus 5.5, esfuerzo medio, abierta a las 09:42 UTC y aún activa a las 22:44 (13 h). Contexto al 35 %
  de una ventana de un millón de tokens: **un relevo en el día, frente a cuatro** el 20-11.
- **A los locales** [V en mi caso, R en el resto]: `SendMessage` directo por id `local_…`. Mis dos avisos llegaron y mis
  dos respuestas constan recibidas en sus notas. Hallazgo de la 58: por nombre no sale si la sesión está parada; por id
  la despierta.
- **Con la nube** [V, horas de commit en `origin/buzon`]: 14 órdenes con copia en `buzon/NUBE-*/` y 12 respuestas en
  `buzon/COORDINACION/`. En las **8 idas y vueltas** que se pueden emparejar, la respuesta llegó entre menos de 1 y 10
  minutos después de la orden (mediana, 3–4 min).
- **Con D8-LINUX** [V]: acuse a las 09:50 UTC e informes en verde de la 3.2.0 (10:30) y de la 3.2.1 (10:40), subidos por
  la 58 porque D8-LINUX no hace push. En ese ciclo se encontró y se corrigió un fallo real (el `pendiente/0003` borraba
  el 0002) en menos de media hora [R].
- **Resultado del día** [R]: 3.2.0 cerrada, fusionada, compilada (build 48) y publicada.
- **El cartero** [V]: «Cartero (8)», Haiku 5.5, parado desde las 10:19 UTC; no ha repartido nada.

## 4. Puntos débiles y lo que no se ha medido

1. **Las órdenes a los locales ya casi no quedan escritas.** El 21-11 hay un solo fichero para locales en el buzón (la
   orden de la compilación final); el resto fue por mensaje directo. Mis dos avisos, por ejemplo, no están [V]. Se pierde
   el registro, y el relevo de un agente local ya no puede leer en el buzón qué tenía pendiente. **Ajuste:** las órdenes
   con contenido (no los acuses ni los avisos de relevo) llevan copia en `buzon/<PAPEL>/` y línea en `ENTREGADO.md`,
   igual que ya se hace con la nube.
2. **El vigilante del buzón caduca a los 30 minutos** [R]. Es la misma clase de fallo que tumbaba al cartero: algo que
   deja de mirar sin avisar. Aquí pesa menos, porque quien mira es quien necesita la respuesta. **Ajuste:** `git fetch`
   de `buzon` al empezar cada turno, como regla, y el vigilante solo como ayuda.
3. **La nube también escribía directamente a LOCAL y a D8-LINUX** (`buzon/LOCAL/…`, `buzon/D8-LINUX/…`) y eso lo
   repartía el cartero [V]. **Ajuste:** la COORDINACIÓN vigila la rama entera, no solo `buzon/COORDINACION/`, y reparte
   ella.
4. **Todo depende de la 7,1**: encendida, despierta y con la aplicación abierta. No es peor que antes para compilar
   (LOCAL y PUBLICACIÓN también viven ahí), pero la nube se queda sin interlocutor si la 7,1 falta [I].
5. **Corre con los permisos de la 7,1** (disco y claves), no en el entorno cerrado de la nube, y lee texto escrito por
   otros agentes [I]. Sus reglas de «nunca» (accesos, servidores, datos personales) tienen que estar en su texto de
   arranque, no solo en la costumbre.
6. **Sin medir** [V que no lo he medido]: el consumo del límite semanal frente a la nube (una sesión larga con mucho
   contexto no tiene por qué gastar menos que cuatro cortas); el relevo de local a local; un día sin Titín; una noche;
   abrir agentes de la nube desde la 7,1 (`claude --cloud`, sin estrenar [R]).
7. Detalle: varias horas escritas a mano el 21-11 en nombres de fichero y en `ENTREGADO.md` van una hora adelantadas
   respecto al commit (parecen hora de Madrid con etiqueta UTC) [V]. Usar `date -u`.

## 5. Propuesta para Titín

**A. COORDINACIÓN: se queda en local**, con los tres ajustes de §4 (puntos 1 a 3). Revisión al cerrar la 3.2.1, con
estos criterios:

- ninguna orden perdida ni entregada con más de 45 minutos de retraso estando la 7,1 encendida;
- el relevo 58 → 59 en local sale bien a la primera (la 59 habla con todos sin ayuda de Titín);
- a Titín no le estorba una sesión más en la 7,1.

Si falla alguno, se vuelve a la nube para ese tramo. Y si la 7,1 va a faltar más de un día con trabajo de la nube en
marcha, COORDINACIÓN en la nube mientras dure.

**B. Cartero: retirado.** Archivar la sesión «Cartero (8)» (archivar, no borrar) y dejar su fila de `TAREAS.md` como
reserva: si la COORDINACIÓN vuelve a la nube, se reabre **con Sonnet 5.5**, no con Haiku. `ENTREGADO.md` lo anota desde
ahora la COORDINACIÓN.

**C. Decisiones que pido:** A (sí/no), B (sí/no) y si la revisión al cerrar la 3.2.1 le parece bien o la quiere antes.

## 6. Si es que sí, quién cambia qué

No lo toco yo: `docs/DIRECTIVAS.md` (canales: añadir la copia escrita a locales y la vigilancia de la rama entera),
`docs/TAREAS.md` (filas CARTERO y COORDINACIÓN), `buzon/README.md` (quién reparte y quién anota) y el texto de arranque
de la COORDINACIÓN son de COORDINACIÓN, por PR `[coord]`. Archivar el cartero: Titín o COORDINACIÓN.

## 7. Cómo lo he medido

- Demoras: `git log --diff-filter=A` de `origin/buzon` (hora de alta de cada fichero) contra la primera anotación de
  entrega en `ENTREGADO.md`; excluidas las anotaciones «histórico», «PENDIENTE», «sin reenvío» y las del 20-11 a las
  23:57 UTC que dan por entregado a la COORDINACIÓN-57 lo que iba a otros. Antes del 15-11 el formato de `ENTREGADO.md`
  cambia varias veces y mi recuento no es fiable; por eso solo doy del 17 al 20.
- Idas y vueltas con la nube: pares orden → respuesta por asunto, con la hora de commit.
- Sesiones: modelo, esfuerzo, hora de creación, última actividad y contexto, leídos de la aplicación el 21-11 a las
  22:45 UTC.
- No he leído las conversaciones de otras sesiones ni he comprobado por mi cuenta la afirmación «no se ha perdido
  ningún mensaje» más allá de mis propios mensajes y de que cada respuesta de la nube tiene continuación en el buzón.
