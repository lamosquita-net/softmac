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

## Vigilancia barata

- Rutina **«FlyWeb: revisión ligera horaria»** (Haiku, sesión nueva en cada disparo, 08:07–23:07 hora de Madrid):
  mira los push de la última hora por la API y, si hay algo para coordinación, dispara la rutina
  **«Despertar a NUBE-COORDINACIÓN»**, que entra en la sesión de coordinación. Al cambiar de sesión, hay que
  apuntar esa segunda rutina a la sesión nueva (`update_trigger` / volver a crearla con `persistent_session_id`).
- No hace falta programar revisiones horarias en la sesión de coordinación: una sesión larga relee todo su
  contexto en cada despertar y es lo que más gasta.

## Flujo de un arreglo de LOCAL

LOCAL compila desde `local/motor-<N>-arreglos` y sube allí sus arreglos. Coordinación los lleva a:

1. `nube/motor-124` (o el nivel de NUBE que toque), con `FlyWeb/tools/port/llevar.sh`, sin checkout:
   `llevar.sh ~/brave-core nube/motor-124 nube/form-vertical <commits>` → revisa e imprime los `git push`.
2. `nube/form-vertical` (lo hace el mismo script) y, si existe, rehacer la rama de integración
   (`nube/v1.8.1` = base de LOCAL + fusión de `nube/form-vertical` + *cherry-pick* de F7.8).
3. Nota en la fila para NUBE-MOTOR (lo fusiona en 125+) y, si toca `patches/v8/`, para SEGURIDAD.

Para comprobar fusiones sin checkout: `git merge-tree --write-tree A B` (git ≥ 2.38).

## Ramas y versiones (al 08-10)

| Versión | Nivel | Rama que compila LOCAL | Estado |
|---|---|---|---|
| 1.7 / 1.7.1 | 123 | `flyweb` / `seg/v8-12.3` | publicada / subida, falta firma |
| 1.8 | 124 | `local/motor-124-arreglos` (= `seg/v8-12.4` + arreglos) | Release en curso |
| 1.8.1 | 124 + FM.12 + F7.8 | `nube/v1.8.1` | lista para después de la 1.8 |
| 1.9 / 1.10 | 125 / 126 | `nube/motor-125/126` (+ `seg/v8-12.5`) | código hecho por NUBE-MOTOR, sin compilar |

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

- Cuando LOCAL publique la 1.8: que compile `nube/v1.8.1` (sube `flyweb_version` a 1.8.1) y pruebe
  `formularios-verticales.html`, F7.8 y formularios normales en Gmail y claude.ai. Si `local/motor-124-arreglos`
  se mueve antes, rehacer `nube/v1.8.1`.
- Con el visto bueno de LOCAL a la 1.8.1: avisar a NUBE-MOTOR para llevar FM.12 y F7.8 a 125/126.
- 1.9 y 1.10: puntos de riesgo en el tablero (FM.13, FM.14): bindings nuevos del 125; gin y PDFium con la V8 12.6.
