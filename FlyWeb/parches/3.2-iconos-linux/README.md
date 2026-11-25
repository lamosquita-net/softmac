# FlyWeb: iconos de Linux (ventana, lanzador e instalador)

MOTOR-47, 25-11-2026, por encargo de COORDINACIÓN-64 (D8-LINUX-6 vio que seguía el león de Brave). **Sin compilar.**
No toca nada de Mac.

## Qué cambia

16 ficheros de brave-core, todos binarios:

| Fichero | Uso en Linux | Ahora |
|---|---|---|
| `app/theme/brave/linux/product_logo_{24,48,64,128,256}.png` | Iconos del lanzador; el instalador los copia a `installer/theme`. El 128 es el icono de ventana (`IDR_PRODUCT_LOGO_128`) | La mosca, M1-01 |
| `app/theme/brave/linux/product_logo_128_{beta,dev,nightly}.png` | Igual, por canal (`brave_unscaled_resources.grd`, `BUILD.gn`) | M1-01 |
| `app/theme/brave/linux/product_logo_128_development.png` | Builds no Release | O1-01 (la morada), como en Mac |
| `app/theme/brave/linux/product_logo_32.xpm` | Menú del instalador | Hecho del PNG de 32 con `png2xpm.py`: transparencia binaria y bordes compuestos sobre blanco |
| `app/theme/default_100_percent/brave/linux/product_logo_{16,32,32_beta,32_dev,32_development,32_nightly}.png` | `IDR_PRODUCT_LOGO_32_*` (`brave_theme_resources.grd`) y el icono pequeño de ventana | M2, como las pestañas de las páginas internas |

**Fuente:** son los mismos ficheros que ya estaban en brave-core para Mac y para lo común (`app/theme/brave/product_logo_*`
y `default_100_percent/brave/product_logo_*`), y tienen el mismo tamaño. Esos se generaron con
`FlyWeb/branding/scripts/generar-marca.sh` desde los maestros de `imagenes.md`. Copiarlos es lo mismo que rasterizarlos
otra vez; esta sesión no tiene `swiftc`. `generar-marca.sh` ya incluye las líneas de Linux, para la próxima vez que se
regenere la marca.

**Fuera, a propósito:** `app/theme/brave/linux/app_list_*.png` (la cuadrícula genérica de Chromium, sin marca) y `win/`.

## Base y árboles

brave-core `local/322-final` = **060015a802** (ls-remote del 25-11), árbol `fbdf05a0d3`. Con `git am`, el árbol queda en
**`58a50c3c0e`** (comprobado). No hay ficheros en común con `3.2-sync-cuenta/0012` (#1242): el orden da igual.

## Qué debe ver D8-LINUX

- **Barra de tareas o dock con FlyWeb abierto:** la mosca naranja, no el león. Es el icono de ventana (`IDR_PRODUCT_LOGO_128`, o el
  de 32 en paneles pequeños).
- **Lanzador:** la mosca tras instalar el `.deb`/`.rpm` o con el `.desktop`, en `/usr/share/icons/hicolor/*/apps/` o
  donde lo deje el instalador. En la compilación de desarrollo (no Release), la mosca morada.
- **`flyweb://version` y las pestañas de las páginas internas:** ya eran la mosca. No deben cambiar.
- Si algún icono sigue siendo el león, decir cuál y en qué tamaño. Puede salir de un recurso que no está en esta lista.

## Ficheros

- `0001-branding-FlyWeb-icons-for-Linux-window-launcher-inst.patch` (`git format-patch --full-index --binary`).
- `SHA256SUMS`.
