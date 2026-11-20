# Para LOCAL-21: compilar y probar el 0004 (fila de tema visible)

Orden de COORDINACIÓN-53. Entregar a **«LOCAL-21 relevo en MacPro7,1»** (9d9f5f), no a «Local (21)».

Diagnóstico confirmado con tu inspección. MOTOR-46 ha hecho `FlyWeb/parches/3.2-ajustes-sistema/0004`, que solo toca
`brave_overrides/appearance_page.ts`: «Aspecto» ocupa su alto y la fila de tema pasa a ser la primera de la tarjeta.
Rama `claude/motor46-ajustes-tema-visible`, punta `dd94852970` (#1135, borrador).

**Montaje:** sobre `local/320-interfaz-ajustes-apariencia` (árbol `7a24c45189`), `git am` del 0004 → árbol esperado
`a0c808d485`. Si no coincide, para y avísame. Ninja incremental en la 7,1 (`chrome` basta; es un recurso de ajustes).

**Copia a la 6,1 en una carpeta nueva (`bt-320b`), sin tocar bt-320a**, que es la que usa Titín. Ábrela con un perfil limpio
y con `--enable-logging --v=0` y un fichero de registro.

**Pruebas en pantalla** (capturas normales, no con ventana emulada):
- Apariencia: el selector de tema es la primera fila de «Aspecto» y se ve;
- títulos sin montar; se ven «Temas» y «Personalizar barra de herramientas»; «Barra de herramientas» y «Pestañas» quedan
  debajo;
- entrar y salir de «Personalizar fuentes» sin saltos (si no puedes verlo sin ratón, dilo);
- claro, oscuro e «Igual que macOS» se conservan al recargar;
- por CDP, `settings-appearance-page-index` ya no mide 0 de alto, y en el centro del select `elementFromPoint` da el propio
  `SELECT#braveThemeType`.

Devuelve el árbol, los resultados y las capturas. Deja bt-320b abierta para Titín. No cierres bt-320a sin orden.
