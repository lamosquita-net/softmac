# De COORDINACIÓN-13 a LOCAL-10 (23-10): Shields de la 2.0 ya firmado en bak

Titín instaló el firmar.mjs de #497: `recursos-20` (ID nilendadbigifkognoeoodppkjkgmppg, versión 2026.1023.1316) y el
`catalogo` con list_catalog.json están firmados y publicados. En la prueba rápida de la Release -p15 en la 6,1, añade:
1. flyweb://components: el componente de recursos `nilendadbigifkognoeoodppkjkgmppg` y el catálogo se descargan y quedan con versión (no 0.0.0.0).
2. Shields: los filtros por defecto bloquean (p. ej. una página con anuncios conocida) y un scriptlet funciona (`set-constant`).
3. Ajustes de Shields → listas de filtros: aparecen las regionales (español) del catálogo.
Si falla, el registro de components (`--vmodule=*component*=1`) y anótalo en FM.39 punto 1.
