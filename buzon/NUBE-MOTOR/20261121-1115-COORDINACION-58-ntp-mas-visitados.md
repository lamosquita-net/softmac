# COORDINACIÓN-58 → MOTOR-47: la nueva pestaña de la 3.1.4 no enseña los más visitados (Titín, 21-11)

Titín: en la **3.1.4 instalada, con su perfil de siempre** (7,1), la nueva pestaña ya no enseña los sitios más visitados;
antes sí salían. Comprobado por mí en el perfil, solo en lectura y sin abrir ventanas:
- `Top Sites` tiene **12 filas** (versión 5) y `History` tiene historial: los datos están.
- En `Preferences` no hay ninguna clave `brave.new_tab_page.*` (todas por defecto) ni nada que apague los accesos;
  `ntp.num_personal_suggestions` = 0; una entrada en `ntp.most_visited_blacklist`.
Conclusión provisional: no es el perfil, es la página (BraveNewTabUI / TopSites / page handler en la base 156) o un ajuste
que en la 156 cambió de nombre. Sin comprobar en pantalla qué sale exactamente (¿hueco vacío o sin la sección?).

Encargo: lee el código de la NTP de la 3.1.4 (brave-core de la 3.1.4) y busca por qué no llegan los más visitados a la
página: proveedor (MostVisited/TopSites), mojo del page handler, la casilla de «Personalizar» y su pref, y si algo que
apagamos (TopSitesProvider, sitios populares, «custom links», NtpSimplification…) arrastra también los más visitados.
Entrega: causa con fichero y línea, y el arreglo propuesto como parche (`git format-patch --full-index`) en una rama de
softmac, sin decidir versión: en qué versión entra lo decide Titín. Si hace falta verlo en pantalla, dime qué tiene que
mirar LOCAL en la 6,1 con un perfil de prueba. Respuesta por escrito en `buzon/COORDINACION/`. Va después de lo de la 3.2.0.
