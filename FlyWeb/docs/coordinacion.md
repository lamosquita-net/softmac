# Relevo de NUBE-COORDINACIÓN

Nota para la sesión que tome el papel de coordinación (escrita el 08-10-2026 por la sesión que lo llevaba desde
el 28-09). Leer antes: `CLAUDE.md`, `docs/TAREAS.md` (tabla de agentes y filas FM.*, FS.*, F7.8),
`FlyWeb/docs/motor.md` (política de niveles) e `integracion.md` (pasos de LOCAL).

## Qué hace este papel

- **Interlocutor técnico del HUMANO**: discutir estrategia de motor (niveles, V8, Blink, excepciones como FM.12),
  dar recomendaciones razonadas y críticas, y dejar las decisiones escritas en el tablero.
- **Revisión general**: tablero, ramas de brave-core (`local/*`, `seg/*`, `nube/*`) y PR de softmac.
- **Coordinación**: que cada arreglo llegue a todas las ramas que lo necesitan y avisar en la fila al agente
  que tiene que moverse.
- **Dueño del código de NUBE de los niveles 117–124**, de FM.12 (`nube/form-vertical`), de F7.8
  (`nube/pinned-compartidas`) y de las ramas de integración (`nube/v1.8.1`). No toca `nube/motor-125+`
  (NUBE-MOTOR).

## Vigilancia

- La rutina con Haiku («FlyWeb: revisión ligera horaria») **no funcionó**: corría barata, pero en 8 horas con
  mucha actividad (1.8.1 publicada, `flyweb` movida) no despertó nunca a coordinación, ni siquiera en una prueba
  forzada. Queda desactivada. La rutina «Despertar a NUBE-COORDINACIÓN» queda apuntada a la sesión nueva por si
  se reutiliza.
- Mientras la sesión de coordinación tenga poco contexto, puede revisar ella misma cada 2–3 h con `send_later`
  (barato porque relee poco). Cuando la sesión crezca mucho (cientos de miles de tokens), espaciar o relevarla.

## Flujo de un arreglo de LOCAL

LOCAL compila desde `local/motor-<N>-arreglos` y sube allí sus arreglos. Coordinación los lleva a:

1. `nube/motor-124` (o el nivel de NUBE que toque), con `FlyWeb/tools/port/llevar.sh`, sin checkout:
   `llevar.sh ~/brave-core nube/motor-124 nube/form-vertical <commits>` → revisa e imprime los `git push`.
2. `nube/form-vertical` (lo hace el mismo script) y, si existe, rehacer la rama de integración
   (`nube/v1.8.1` = base de LOCAL + fusión de `nube/form-vertical` + *cherry-pick* de F7.8).
3. Nota en la fila para NUBE-MOTOR (lo fusiona en 125+) y, si toca `patches/v8/`, para SEGURIDAD.

Para comprobar fusiones sin checkout: `git merge-tree --write-tree A B` (git ≥ 2.38).

## Ramas y versiones (al 08-10, 19:00)

| Versión | Nivel | Rama | Estado |
|---|---|---|---|
| 1.8.1 | 124 + FM.12 + F7.8 | `flyweb` | publicada y verificada |
| 1.9 | 125 | `local/v1.9` / `seg/v8-12.5` (con FM.12, F7.8 y arreglo de `getHTML`) | en compilación (LOCAL) |
| 1.10 | 126 | `nube/motor-126` / `seg/v8-12.6` | código hecho, sin compilar |

Las ramas `nube/motor-N` se apilan (cada una sale de la anterior); los parches de V8 de cada nivel viven en
`patches/v8/` y SEGURIDAD los mantiene en `seg/v8-12.x`, que sale de `nube/motor-N`.

## Trampas conocidas (de errores reales)

- **«Los parches aplican» no es «compila»**: `chk.sh` limpio y aun así la 1.8 tuvo 4 errores de compilación y
  una caída. Esperar una ronda así por nivel.
- **APIs que no existen en la 116**: cabeceras movidas (`ScriptValue` está en `bindings/core/v8`), símbolos
  nuevos. Antes de dar un port por hecho, buscar cada `#include` y símbolo nuevo en el árbol de la 116.
- **Bindings**: en la 116 los iteradores son `kWrapperTypeNoPrototype` y su objeto prototipo llega vacío al
  generador; lo que el bind_gen portado haga sobre él necesita `IsEmpty()` (caída de `for await` en la 1.8).
- **V8 nueva por nivel**: revisar la API pública contra Blink/gin/content/PDFium de la 116 (12.4 quitó la
  sobrecarga de `DeepFreezeDelegate`; 12.6 vuelve no virtual `TaskRunner::Post*Task` y cambia `SetAccessor`).
  `-Werror` convierte variables sin usar en errores.
- **libc++ de la 116** no trae algunas cabeceras de rebote (`<iomanip>`).
- **Ramas paralelas** (como F7.8, que sale de `flyweb`): no fusionarlas en una rama de otro nivel porque arrastran
  los `patches/v8/` de su V8; llevar solo su commit.
- **Afirmar solo lo comprobado**: dos veces di algo por hecho sin mirarlo (JIT por sitio en Ajustes; F7.8 ya
  portada). Comprobar en el código antes de decirlo al HUMANO.
- El HUMANO prefiere respuestas breves, críticas y con conclusión; preguntar antes de decisiones de producto.

## Pendiente al relevo

- FM.12 y F7.8 ya están en 125/126 (NUBE-MOTOR) y en `seg/v8-12.5/12.6` (SEGURIDAD): no queda nada de la 1.8.1.
- Los niveles 117–124 están cerrados; desde ahora los arreglos de motor son de NUBE-MOTOR (125+). Coordinación se
  centra en estrategia (siguientes niveles de V8/Blink, excepciones), revisión de lo que sale de cada agente y
  conversación con el HUMANO.
- 1.9 y 1.10: riesgos en FM.13 y FM.14 (bindings del 125; gin y PDFium con la V8 12.6).
