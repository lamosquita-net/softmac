# Nueva pestaña sin «más visitados» (21-11)

MOTOR-47, por encargo de COORDINACIÓN-58. **Sin compilar.** La versión la decide Titín.

## Fallo

En la 3.1.4 instalada, con el perfil de siempre de Titín, la nueva pestaña ya no enseña los sitios más visitados. El
perfil está bien: `Top Sites` tiene 12 filas, hay historial y ninguna pref apaga los accesos (COORDINACIÓN-58, en
lectura).

## Causa

- Brave pone por defecto el modo «más visitados»: `ntp.custom_links_visible` = false (`browser/brave_profile_prefs.cc:339`).
- En Chromium 156, `MostVisitedSites::EnableTileTypesOptions` tiene `enable_top_sites` **apagado por defecto**
  (`components/ntp_tiles/most_visited_sites.h:239`). `MostVisitedSites` solo consulta `TopSites` si está encendido o si
  hay enlaces propios sin inicializar (`ShouldQueryTopSites()`, `most_visited_sites.cc:1075`).
- `TopSitesMessageHandler` (`browser/ui/webui/new_tab_page/top_sites_message_handler.cc:35`, y lo mismo en 254, 286 y
  325) solo llama a `with_custom_links(IsCustomLinksEnabled())`. En modo «más visitados» no queda **ningún** tipo de
  acceso encendido, y la página recibe una lista vacía.
- Antes de la 156 la API era otra (`EnableCustomLinks(bool)`) y los más visitados iban encendidos de serie. Por eso sí
  salían.
- Es de Brave: el mismo código está en 1.98.63 y en master.

## Arreglo (0001)

Un método `GetEnabledTileTypes()` enciende un tipo u otro, como la NTP de escritorio de Chromium (que no los mezcla):
`with_top_sites(!custom_links).with_custom_links(custom_links)`. Se usa en los cuatro sitios.

## Árboles

| Base | Árbol tras el 0001 |
|---|---|
| `local/3.1.4` `e660929ac9` | `d020385022` |
| 3.2.0 final `8c31284eda` | `3c014f9688` |

Aplica limpio en las dos: ningún parche de la 3.2 toca este fichero.

## Prueba (LOCAL, 6,1, perfil de prueba)

1. Perfil nuevo. Visitar 4–5 webs varias veces cada una. Abrir una pestaña nueva: salen como accesos.
2. En «Personalizar» → accesos: cambiar a «favoritos» (enlaces propios) y volver a «más visitados». En los dos modos
   sale algo; en favoritos, la primera vez, los más visitados convertidos en enlaces propios (comportamiento de Chromium).
3. Con el perfil de Titín (copia), la nueva pestaña vuelve a enseñar los más visitados.
