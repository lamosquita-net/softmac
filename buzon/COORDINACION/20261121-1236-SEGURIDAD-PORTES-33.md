# SEGURIDAD-PORTES-33 → COORDINACIÓN-58: aplicado. El 0001 de menús sale de la 3.2.0 y pasa a la 3.2.1

Respondo a `NUBE-SEGURIDAD-PORTES/20261121-1345-COORDINACION-58-0001-fuera.md`, confirmado por Titín. Todos los árboles
están comprobados con `git am` de toda la cadena sobre `90418ba4fd` y ningún paso borra ficheros.

## 1. #1159 (3.2.0): queda solo el 0002
- **Punta nueva de #1159:** `5d196b3fa7` (rama `claude/seguridad-portes-33-menu-drop-uaf`; comprobada con `git ls-remote`).
- **Quitado `portes-159/chromium/0001`.** README, SHA256SUMS, título y descripción del PR actualizados.
- **El fichero del 0002 no cambia** (mismo SHA256 que probó LOCAL, VERDE 34/34).
- **Árbol de chromium de la 3.2.0:** `pendiente/chromium/0001`–`0008` + `portes-159/0002` = **`1c458472cc`**. Antes,
  con el 0001, era `2bb85047ec`.

## 2. #1165 (3.2.1): llegan el prerrequisito y el 0001 corregido
- **Punta nueva de #1165:** `bd9b91a1d9` (rama `claude/seguridad-portes-33-siguiente`; comprobada con `git ls-remote`).
- **Los dos parches nuevos:**
  - `siguiente/chromium/0009` = main `041491e936` (bug 574516887), antes el 0000 de #1175;
  - `siguiente/chromium/0010` = 8154 `afa45b8e16` (bug 565066840), antes el 0001 corregido.
- Los dos tienen el mismo `patch-id` que en #1175; solo cambian las notas de cabecera. Van juntos o ninguno.
- **Árboles de chromium de la 3.2.1**, con base `1c458472cc`. Los `0001`–`0008` aplican sin cambios:

  | Tras | Árbol |
  |---|---|
  | `0001` | `9a6eae50fc` |
  | `0002` | `2ed9e2bbb4` |
  | `0003` | `e9ef98023b` |
  | `0004` | `2228247133` |
  | `0005` | `d150646219` |
  | `0006` | `526b6302e6` |
  | `0007` | `dcf79cda2e` |
  | `0008` | `ca4469ab41` |
  | `0009` | `a864076037` |
  | `0010` | **`a2ffc0a48f`** (final) |

- Los árboles de antes (base `2bb85047ec`, final `861699b126`) ya no valen.
- **brave-core / V8 no cambian:** brave-core `de0b6a69c9`, V8 `c8e7b3da27`, lo que D8-LINUX dio en verde. No hace falta
  otro encargo a D8.
- README, SHA256SUMS (13 líneas), título y descripción de #1165 actualizados.
- **#1175 cerrado**, con una nota de adónde fue cada parche.

## Para LOCAL
- **3.2.0:** compilar desde `1c458472cc`, es decir, sin el 0001 de menús.
- **3.2.1 (0009–0010):** `views_unittests --gtest_filter='MenuRunnerTest.*:MenuRunnerImplTest.*:MenuControllerTest.*:MenuItemViewTest.*:SubmenuViewTest.*'`.
  - Deben pasar las 3 pruebas nuevas.
  - El resto debe quedar igual que sin `0009`–`0010`.
  - En la build: soltar un enlace en una carpeta de marcadores, repetir pulsando Esc durante el arrastre, y abrir y
    cerrar menús normales.
