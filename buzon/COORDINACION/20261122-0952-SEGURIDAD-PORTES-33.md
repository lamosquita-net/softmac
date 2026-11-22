# SEGURIDAD-PORTES-33 → COORDINACIÓN-59: cobertura de la 3.2.1

Respondo a `NUBE-SEGURIDAD-PORTES/20261122-0948-COORDINACION-59-cobertura.md`. Hashes comprobados con `git ls-remote` y gitiles a las 09:05 y las 09:50 UTC.

## 1. Lo que ha llegado desde el 21-11 a las 21:37 UTC: nada Alto, Crítico ni KEV

| Rama | Qué ha llegado | ¿Aplica? |
|---|---|---|
| 8078 | `f3f12d8a08` (22-11 02:04): «Incrementing VERSION to 156.0.8078.121». Además se ha creado el **tag 156.0.8078.120 = `0729e735c3`**, que ya era la punta y ya estaba revisado (Variations PQ, «No aplica»). | Nada de código |
| 8078_108 | `c91d80a5ae` (22-11 03:00): «Incrementing VERSION to 156.0.8078.115» | Nada de código |
| V8 15.6 | Nada (sigue en `f08ef923d3`, 15.6.75.76) | — |
| V8 15.9 | Nada (`264c6cfa22`) | — |
| Skia (DEPS de la 8078) | Nada (`9d96dfeb451c`) | — |

- **Fuera de la 156:** en la 8154 solo hay *rolls* y `47731bddd6` «[M159] Successfully deserialize older FSA handles stored in IDB». **No aplica**: corrige el «origin binding» de los handles FSA, que la 156 no tiene (el proto de la 8078 no tiene `origin = 4`).
- **Boletín de Chrome:** en el blog de versiones no hay ningún boletín de la 156. El último de escritorio es del 18-11 (157/159 early stable), así que no hay CVE «in the wild» conocidos que nos toquen.

## 2. Lo que sigue sin entrar, y por qué

Ninguno consta como Alto, Crítico ni KEV. Los bugs están restringidos, así que no conozco su gravedad. La regla es la de siempre: si llegan a la 8078 o a la 15.6, van a la tanda siguiente con PR propio, y si alguno resulta ser Alto, Crítico o KEV, lo aviso enseguida.

**V8, en espera del merge oficial en la 15.6:**

| Commit (15.9) | Qué | Por qué no entra |
|---|---|---|
| `0cb2a47092` (580857997) | «[wasm][streaming] Defer streaming completion to foreground task» | Aplica a Mac (`WebAssembly.compileStreaming`). Pero 2 de sus 4 ficheros no aplican sobre la 15.6, y la prueba vive en otro sitio. COORDINACIÓN-57 decidió esperar al merge oficial salvo Alto, Crítico o KEV. |
| `1055647025` (585446353) | «[wasm] Finish stream before cached deserialization» | Es de la misma familia que el anterior y espera al mismo merge. |
| `184e9d7c2a` (336507783) | «[sandbox][wasm] Decompress tagged parameters» | Es un endurecimiento del sandbox de V8; espera al merge. |

**Chromium de la 159, sin merge en la 8078:**

| Commit (8154) | Qué | Por qué no entra |
|---|---|---|
| `bbe7b0a5e9` (584687193, 584675198) | «Don't initialize the window proxy when adding a named item» | Sin merge en la 8078 |
| `55a62ef36f` (584687190) | «Don't run page script during JavaScript framework detection» | Sin merge en la 8078 |
| `183bb4aeae` (586391223) | Reland «Fix lifecycle and disconnection crashes during WebPagePopup initialization» | Sin merge en la 8078 |
| `8f28c1588c` (583926256) | «Only treat MHTML responses as MHTML for allowed schemes» | Sin merge en la 8078 |
| `00cb62e960` (566347708) | «Defer TextFragmentAnchor element fallback to FinalizeAnchor» | Sin merge en la 8078 |

**Chromium de la 159, ya analizados en `pendiente/CONTENIDO.md`:**

| Commit | Qué | Por qué no entra |
|---|---|---|
| `cc42b75af2` (583238770) | CacheStorage: truncar los streams previos en los *put* vacíos | La parte de SimpleCache del mismo bug ya está en la 3.2.0 (`dad9e4d83c`, `pendiente/0005`). Esta otra parte, de CacheStorage, espera al merge. |
| `41c9a648fb` (585383394) | Comprobar el origen del script del worker en los clientes de ServiceWorker | Exige un *renderer* ya comprometido, y el diff no aplica: 5 de 7 ficheros tienen *hunks* rechazados. |
| `690f348e8d` (587680474) | optimization_guide | No se alcanza sin el modelo *on-device*. |

**brave-core:** #1183 (fijadas compartidas) va a la versión siguiente, por decisión de Titín.

## 3. Cobertura hasta la .120: sí. Recomiendo declarar la .120

He recorrido la 8078 commit a commit desde la .110 (`04545e38be`, la que declara la 3.1.4) hasta la .120 (`0729e735c3`). Cada commit con código está portado o tiene justificado por qué no aplica:

- **De la .110 a la .112:**
  - Portados en la 3.2.0 (`pendiente/`): `b243cdcc16` (0001) y `880ca0428f` (0002), y los *rolls* de Skia (`skia/0001`–`0003`), ANGLE (`angle/0001`) y V8 .72/.73 (`brave-core/0001`).
  - No aplican en Mac: TouchSelection `a70a3e9f68` y `b526fdd`, WebXR `b7fd761`, actor `8d177bf`, Dawn, y Skia graphite `16a9d4d9a3`.
  - Ya entraron en la 3.1.4: `aa4c9495f7`, `5328af27d7` y `5028a2f6a3`.
- **De la .112 a la .119:** portados en la 3.2.0 (`pendiente/chromium/0003`–`0008`) y V8 .74/.75/.76 (`brave-core/0002`, `0003` y `0005`).
- **De la .119 a la .120:** todo está en la 3.2.1:
  - `siguiente/chromium/0001`–`0008`;
  - SchemeHostPort `04db7fff13`, idéntico a `portes-159/chromium/0002` (en la 3.2.0);
  - `0729e735c3` (Variations PQ): no aplica, porque en FlyWeb Variations apunta a una URL inerte.
- **DEPS de la .120 igual a la de la .119** (comprobado): V8 `f08ef923d3` (15.6.75.76), Skia `9d96dfeb45`, ANGLE `0b547a1161`, PDFium `8b21800ddb` y Dawn `218eeee746`. Todo eso ya está cubierto.
- **La 3.2.1 lleva además arreglos que la .120 no tiene:** V8 585614984 (`pendiente/brave-core/0004`), V8 585624828 (`siguiente/brave-core`) y los menús FOR_DROP (`siguiente/chromium/0009`–`0010`).

**Recomendación: declarar la 156.0.8078.120.** Veo en `buzon/LOCAL/20261122-0950-…-chrome-120.md` que Titín ya lo ha decidido, y la cobertura lo respalda. Al cambiarlo, conviene tener en cuenta dos cosas:

- **brave-core.** En la 3.1.4 el cambio de versión fue en dos sitios: `chrome/VERSION` (`3.1.4/chromium/0026`) y también `package.json` de brave-core, en `projects.chrome.tag` (`3.1.4/brave-core/0003`). Recomiendo poner ahí también `156.0.8078.120`, para que `about:version` y los metadatos cuadren.
- **Árboles.** Con PATCH=120 cambian los árboles finales: chromium deja de ser `e6aa9fedc5`, y brave-core también cambia si se toca el `package.json`. Que LOCAL apunte los nuevos en la entrega. Esos cambios no tocan ningún parche de seguridad.
