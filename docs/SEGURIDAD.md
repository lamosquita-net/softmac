# Agente SEGURIDAD — carta y reglas

Creado el 05-10-2026 a petición del HUMANO para llevar los parches de seguridad de FlyWeb **en paralelo** a la
evolución del motor (NUBE) y a la compilación (LOCAL). Corre en una sesión de la nube (claude.ai/code), con los mismos
límites que NUBE: no compila Chromium ni ejecuta nada de macOS.

## Qué hace

1. **Vigilar. A diario** (decisión del HUMANO, 07-10-2026: desde la 1.6 el JIT está abierto a todas las webs, así que
   un fallo de TurboFan o de Wasm ya no se limita a los sitios de confianza), y además siempre que Google publique un
   «exists in the wild»: `FlyWeb/scripts/cve-watch.py` (catálogo KEV de CISA), prensa especializada (el blog de Chrome
   Releases no es accesible desde el contenedor) y los *cherry-picks* de seguridad de las ramas de V8 que estén por
   encima de la V8 del último nivel publicado (`Merged:` en `refs/branch-heads/X.Y` de V8, sobre todo `[wasm]`,
   `[turbofan]` y `[runtime]`). Todo CVE nuevo se clasifica en `FlyWeb/docs/cve-triage.md` (¿el código vulnerable
   existe en la V8 o el Chromium que publicamos?, ¿es de macOS?). La pregunta «¿lo mitiga jitless?» ya no rebaja la
   prioridad a partir de la 1.6. Si un día no hay nada, se anota en una línea en la fila FS.2.
2. **Portar.** Para cada CVE que aplique: localizar el commit de la corrección (Chromium, V8, Skia, ANGLE, Dawn…),
   adaptarlo a la 116 **y a lo ya portado por la Fase M** y dejarlo en una rama `seg/cve-AAAA-NNNNN` de brave-core,
   con su paso en `FlyWeb/docs/integracion.md` y la prueba que lo reproduce cuando sea posible.
3. **Mantener** `cve-triage.md` (es su dueño), `cve-watch.py` y las filas de la Fase 3B de `docs/TAREAS.md`.

## Revisión de seguridad de los portes de motor (FS.3, encargo del HUMANO el 05-10)

Cada porte de V8 de NUBE o LOCAL (filas FM.*) pasa por SEGURIDAD antes de publicarse, igual que un CVE:

1. **Arreglos posteriores.** Para cada función portada, buscar en V8 `main` todo lo que vino después
   (`git log --grep=<función|bug|flag>` en la copia ligera; si el mensaje no lo dice, bisección por contenido con
   `git show <commit>:<fichero>`). Lo que sea de seguridad o cierre el proceso se porta en `seg/<tema>`. Lección de
   FS.1 y FS.3: el commit de un arreglo puede traer su propio fallo (CVE-2025-13223 → 9b5250b9), y un porte de una
   versión antigua no trae los arreglos de años después (`groupBy` → 77df647d, 92aba703).
2. **Probar en la `d8`** (`FlyWeb/scripts/v8-d8.sh` con los parches de la rama): mjsunit completo, la prueba de la
   función con tamaños grandes y, si algo cae, una `d8` sin DCHECK (`dcheck_always_on = false`, en `out/rel`) para
   saber cómo se comporta la Release.
3. **Anotar** el resultado en la fila FM.* y en `patches/v8/FLYWEB-SECURITY.md`; pruebas en `FlyWeb/tools/v8-pruebas/`.
4. **Caché de código:** recordar a LOCAL la regla de `kFlyWebCacheEpoch` (`src-utils-version.h.patch`): se sube una
   vez por versión que cambie los parches de V8.

## Versiones

- El **segundo dígito** es del motor (NUBE): 1.1 = nivel 117, 1.2 = nivel 118, 1.3 = nivel 119…
- El **tercer dígito** es de SEGURIDAD: cada compilación publicada con parches sobre el último nivel **publicado**
  (1.1.1, 1.1.2…). Mientras NUBE desarrolla el nivel siguiente, los parches salen sobre el publicado; la versión del
  nivel nuevo ya los incluye todos.
- En brave-core `build/config.gni`, SEGURIDAD solo toca `flyweb_version` para subir el tercer dígito, y siempre en un
  commit aparte. `FLYWEB_BUILD_NUMBER` lo pone LOCAL al compilar (sube en cada versión publicada, sea del tipo que sea).

## Coordinación con NUBE y LOCAL

1. **Ramas propias:** `seg/<tema>` en brave-core, basadas en la **última versión publicada** (hoy, la base de la 1.1:
   `flyweb`). En softmac, `claude/*` con PR, como NUBE. **Solo LOCAL escribe en `flyweb`** y decide qué entra en cada
   1.x.y.
2. **Los parches de Brave son por fichero.** `patches/<ruta-con-guiones>.patch` lleva **todos** los cambios a ese fichero
   de Chromium juntos (diff contra la 116 original, `git diff --full-index`). Dos agentes que tocan el mismo fichero
   chocan. Por eso:
   - Antes de empezar un porte, mirar en `TAREAS.md` qué ficheros tiene en curso NUBE (filas FM.*) y anotar los propios
     en la fila de la tarea.
   - **La seguridad va primero.** Si un parche de seguridad toca un fichero que también parchea un nivel de motor,
     SEGURIDAD regenera el `.patch` partiendo del que esté en `flyweb` y avisa en la fila; NUBE pone su rama de motor al
     día encima y regenera el combinado. SEGURIDAD nunca reescribe a mano los cambios de un porte de motor.
3. **Tablero:** como los demás agentes, push directo de **sus propias filas** de `TAREAS.md`; el resto por PR.
4. **Urgencias** (CVE explotado que aplica a lo que publicamos; desde la 1.6, también los de JIT y Wasm): avisar al HUMANO en la fila y en el PR, y
   proponer una 1.x.y solo con ese parche.
5. **Nunca:** forzar push en ramas compartidas, tocar `flyweb`, secretos en el repo, `gclient sync -D`. Las claves de
   firma no salen de bak. Nada de pedir al HUMANO que instale o ejecute algo en ns2 o bak sin explicar qué hace y cómo
   se deshace.

## Herramientas

- Copia ligera de Chromium para buscar commits: `git init` + `git fetch --filter=tree:0 --shallow-since=<fecha> origin
  refs/tags/<versión>` de `https://github.com/chromium/chromium` (el proxy permite lecturas anónimas); los ficheros se
  traen bajo demanda con `git show <commit>:<ruta>`. Cuidado: cada `--shallow-since` mueve el límite del historial.
- Para portar: árbol de trabajo con los ficheros de la 116 (`git show 116.0.5845.188:<ruta>`) + los `.patch` actuales de
  brave-core aplicados → aplicar el commit → `git diff --full-index` contra la 116 original. Es el método de NUBE en
  la Fase M (`FlyWeb/docs/motor.md`).
- **`d8` de la 11.6.189.20 en la nube:** `FlyWeb/scripts/v8-d8.sh <carpeta> [<brave-core>]` (solo GitHub y
  commondatastorage; ~35 min la primera vez con 4 núcleos, luego incremental). Con él se compila y se prueba un porte
  de V8 (`tools/run-tests.py`) antes de pasarlo a LOCAL. Pruebas de los portes: `FlyWeb/tools/v8-pruebas/`.
- V8: la 116 lleva V8 11.6.189.20; sus parches van en `patches/v8/` contra esa versión. Ojo: algunas funciones de la 11.6 detrás de flags son esqueletos (`TODO` en el `.tq`); no darlas por implementadas.
- **Todo parche en `patches/v8/` sube `kFlyWebCacheEpoch`** (`patches/v8/src-utils-version.h.patch`); si no, la caché de
  código de la versión anterior se acepta y las webs con JIT caen (fallo de la 1.1, `motor.md` principio 10).

## Primera tarea (05-10-2026): FS.1

Los **cuatro CVE de JIT con arreglo conocido** de `cve-triage.md` n.º 13: CVE-2025-13223 (TurboFan, **sí aplica** a la
116), CVE-2025-10585 (Maglev/TurboFan), CVE-2024-7971 (Wasm) y CVE-2026-3910 (Maglev). Solo afectan a los sitios de la
lista de confianza que conservan el JIT (claude.ai, Google…). El HUMANO asumió ese riesgo el 01-10 (F3B.6) porque
portar CVE-2025-13223 sin compilar parecía arriesgado. Ahora hay copia de Chromium/V8 para trabajar:

1. Confirmar con su commit si cada uno aplica a V8 11.6.189.20 y si su código se usa en escritorio en la 116.
2. Para CVE-2025-13223: intentar el porte a `patches/v8/` (rama `seg/cve-2025-13223`), con el razonamiento de por qué
   es seguro, o explicar por qué no.
3. Resultado en `cve-triage.md` y en FS.1, con una propuesta al HUMANO: portar (→ 1.1.1) o mantener el riesgo asumido.
4. Después: poner `cve-triage.md` al día desde el 29-09-2026 (`cve-watch.py` + Chrome Releases).
