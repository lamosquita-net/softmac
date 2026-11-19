# Para LOCAL-19: compilar la interfaz 3.2.0 de prueba y sacar capturas para Titín

Orden de COORDINACIÓN-52. MOTOR-46 ha entregado H1–H4 en el PR #1110 (borrador; no se fusiona todavía).

**Es una compilación de prueba, no una versión:** sin número de versión nuevo, sin fila FS, sin firmar, sin entregar a
PUBLICACIÓN. Directorio de salida propio (p. ej. `out/Interfaz320`); no toques `out/Release` de la 3.1.4.

## Fuente
- softmac, rama `claude/motor46-interfaz-3.2.0`, punta `15114ae597` (comprobada con ls-remote).
- Parches 0001–0006 de `FlyWeb/parches/3.2-interfaz/`, en orden, con `git am` sobre brave-core `local/3.1.4`
  `e660929ac9`. Comprueba antes `SHA256SUMS`. Árbol final esperado: `a970509442`.
- Chromium: `local/314` `e9b670773e` (no hay rama de Chromium; lo de Chromium va en `patches/` y `chromium_src` de
  brave-core).
- Pasos de prueba de cada hito: `FlyWeb/parches/3.2-interfaz/README.md`.

## Tests
- `brave_unit_tests --gtest_filter='BraveColorMixersTest.*'`
- `brave_browser_tests --gtest_filter='BraveThemeServiceTest.*:BraveLocationBarViewColorOverridesTest.*'`

## Capturas (perfil de prueba limpio: sin cuentas, marcadores ni historial de Titín)
En la 6,1 a 1x y en una pantalla Retina, cada una en claro y en oscuro:
1. Ventana normal con foco: varias pestañas (una activa) y algún marcador y carpeta en la barra.
2. La misma ventana sin foco.
3. URL pulsada (con el brillo) y con el desplegable de sugerencias abierto.
4. Escudo de Shields en sus tres estados: activo (verde), bajado (rojo) y página interna (neutro, p. ej. la nueva
   pestaña); y con un contador de dos cifras.
5. Un primer plano de la barra de herramientas a tamaño real para comparar los iconos.

Déjalas fuera del repo, en `entregas/local19/interfaz-3.2.0/` del disco de red, con nombres que digan máquina, modo y
caso. Avísame por el bridge con la lista de ficheros, el resultado de los tests y cualquier fallo de `git am` o de
compilación. Si algo no aplica limpio, para y avísame; no lo arregles a mano.
