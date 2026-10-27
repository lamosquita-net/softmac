# FlyWeb 1.2 — plan (NUBE, 05-10-2026)

**Qué es:** el nivel de motor 118. **Base:** la 1.1 publicada + brave-core `nube/motor-118` 86a2c9da (pasos 53–55 de
`integracion.md`; la rama va encima de `nube/motor-117`, así que trae también el paso 52 si aún no estaba).

## Qué trae respecto a la 1.1

| Paso | Cambio | Para el usuario |
|---|---|---|
| 52 | Unidades `cap` y `rcap` (altura de mayúsculas), `<search>` | Tipografía ajustada a la altura de mayúsculas; formularios de búsqueda con su elemento propio |
| 53 | `transform-box: content-box | border-box | stroke-box` (con la refactorización de SVG que necesita) | Animaciones y giros de iconos SVG/CSS que usan esos valores, en su sitio |
| 54 | Declara **Chrome 118** a todas las webs | — |

## Orden de trabajo (LOCAL)

1. Integrar `nube/motor-118` en `flyweb` (merge «pasos 53–55»). **Primero Static**: el paso 54 es el porte más grande
   (70 ficheros de Blink); si no compila, pasar el error a NUBE con el fichero y la línea.
2. Pruebas en Static (7,1 y 6,1):
   1. `motor-nivel.sh <app> 118` → 15/15; `motor-nivel.sh <app> 117` → 14/14 (que el 117 no se haya roto).
   2. WPT: `git fetch … refs/tags/118.0.5993.159` en la copia de Chromium, `git archive` de
      `web_tests/external/wpt/{resources,common,css/css-values,css/css-transforms,css/css-contain,css/css-typed-om}`,
      servirlo en 8117 y `wpt-app.sh <app> FlyWeb/tools/wpt-118-lista.txt salida.json`. Anotar «X de Y» frente a la
      1.1 y frente a los `-expected.txt` de Chrome 118.
   3. **SVG** (riesgo del paso 54): GitHub, YouTube, Wikipedia (gráficos), Google Maps o OpenStreetMap, una web con
      iconos animados. Nada descolocado, sin volcados del renderer. Vista previa de impresión de una página con SVG.
   4. claude.ai completo (criterio de aceptación).
3. Release: `FLYWEB_BUILD_NUMBER=3 FlyWeb/scripts/build.sh Release` → `CFBundleShortVersionString` 1.2,
   `CFBundleVersion` 157.64.3. Firmar, notarizar, DMG `FlyWeb-1.2.dmg`.
4. **HUMANO, en bak:** `<sha256>  157.64.3  # FlyWeb 1.2`, firmar con `--version 157.64.3 --visible 1.2`.
5. Desde la 1.1 instalada en la 6,1: la 1.2 llega sola (segunda prueba real del actualizador).

Si el nivel no pasa: revertir solo 86a2c9da (vuelve a declarar 117 y a llamarse 1.1.x) y avisar a NUBE.
