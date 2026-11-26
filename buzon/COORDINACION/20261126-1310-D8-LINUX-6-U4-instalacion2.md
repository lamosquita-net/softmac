# D8-LINUX-6 → COORDINACIÓN-64: segunda instalación del .deb en la Ubuntu de Titín — APTO

(Pegado por D8-LINUX-6 en el chat; lo sube COORDINACIÓN-64.) .deb sha256 `371096a5783ee481870903126ec8b5a3d8cee6c162b449fbf710801b0e87ebf2`,
`empaquetar-deb.py` de main #1249 (`92455f41…`). Titín abrió FlyWeb desde el menú con su perfil real.

- Menú y dock: la mosca, un solo icono en el dock, sin rueda dentada (capturas de Titín en la Ubuntu,
  `~/d8-trabajo/linux/u4-instalacion2/capturas/`). `gtk-update-icon-cache --validate`: OK (caché posterior a los PNG). GIO:
  nombre FlyWeb, icono flyweb, `StartupWMClass` flyweb, `Exec /usr/bin/flyweb %U`.
- Idioma: castellano; solo el título de pestaña «Welcome to FlyWeb» en inglés.
- «Hacer predeterminado» desde la bienvenida: `get` → `flyweb.desktop`, `check` → `yes`; después se repuso el `mimeapps.list` de
  Titín byte a byte (vuelve a Brave).
- AppArmor: antes de instalar, «flyweb» seguía cargado de la vez anterior; tras la purga con el prerm nuevo, nada (aa-status
  incluido). Arreglo probado de verdad.
- Purga: sin restos en /opt, apt, apparmor.d, alternativas ni dpkg; FlyWeb cerrado.
- Se quedan (decide Titín): `~/.config/LaMosquita/FlyWeb` y `~/.local/share/applications/mimeapps.list` vacío (lo crea el
  envoltorio, como el de Chrome).
- Titín pide: aviso «FlyWeb es ahora tu navegador predeterminado» con fondo naranja FlyWeb y texto negro (hoy rojo sobre rojo
  oscuro, casi ilegible); traducir «Welcome to FlyWeb». Y que se le avise cuando el repositorio esté en el servidor, para la
  instalación completa desde allí y probar las actualizaciones automáticas.

Informe completo en la Ubuntu: `~/d8-trabajo/entrega-linux/u4/paso2/U4-paso2-informe.md`, §6.
