# Release de la 3.x (F1 de `FlyWeb/docs/plataformas.md`)

Un solo guion para Mac y Linux: `flyweb-release.sh <manifiesto> <paso>`. Lee el manifiesto (no lo ejecuta), comprueba
árboles y args y compila. No baja fuentes, no hace checkout, no firma, no empaqueta, no sube y no publica.

| Paso | Qué hace |
|---|---|
| `comprobar` | Solo lee: commits y árboles de chromium y brave-core, perfil PGO, RAM, intercambio y disco |
| `parches` | Parches locales del manifiesto, `apply_patches` y árbol de V8 resultante |
| `gn` | `gn gen` sin compilar, valores efectivos y diferencia con `args_referencia` |
| `compilar` | Release con registro (la clave de servicios no llega al registro). `gn` y `compilar` paran sin `clave_servicios_fichero` |
| `revisar` | Salida, AVX, build-info y sumas |
| `entregar` | Solo Mac: copia la .app y los dSYM a entregas; no publica |
| `todo` | Los cinco primeros, en orden, parando al primer fallo |

`BAJA=1` compila con prioridad baja (`trabajos_baja`). Las claves del manifiesto están descritas en la cabecera del guion.

## Ejemplos

Son los manifiestos de la 3.2.2 build 50, con los que el guion da «args iguales» en las dos plataformas:

- `ejemplos/3.2.2-mac.manifiesto`: la 7,1, sin parches locales. Hay que poner la cuenta en lugar de `USUARIO`.
  `comprobar` y `gn` comprobados el 25-11-2026 (LOCAL-25).
- `ejemplos/3.2.2-linux.manifiesto`: la Ubuntu, con los parches locales de U2/U3 y P1 (D8-LINUX-6, 24-11-2026).

## Historia

- Sustituye a `FlyWeb/tools/release-f1.sh`, que era el de la 2.7.0 (FM.54 F1) y se queda como estaba.
- Borrador de D8-LINUX (22-11). Versión v2 de LOCAL-25 para Mac (24-11). Estrenado y unido en Linux por D8-LINUX-6
  (24-11, sha256 `96db4fd1…1f83`).
