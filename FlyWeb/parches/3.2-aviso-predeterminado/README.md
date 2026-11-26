# Aviso «FlyWeb es ahora tu navegador predeterminado» en naranja, y la bienvenida traducida

MOTOR-47, 26-11-2026, por encargo de COORDINACIÓN-64 (petición de Titín). **Sin compilar.** Vale igual para Mac y Linux.

## 1. Avisos (toasts) en naranja con texto negro

- **Qué es:** el aviso es un *toast* de Chromium (`ToastView`, `ToastId::kDefaultBrowserUpdateSuccess`,
  `IDS_DEFAULT_BROWSER_SUCCESS_TOAST_BODY`). Es el mismo componente en Mac y en Linux, y lo usan todos los avisos de ese tipo
  (pestaña enviada, enlace copiado, contraseñas…).
- **Por qué salía rojo:** Brave sustituye entero `AddMaterialUiColorMixer()`
  (`chromium_src/ui/color/material_ui_color_mixer.cc`) y no define `kColorToastBackgroundProminent`, que es el fondo de
  todos los *toasts* de la 156. Al quedar sin definir, sale el rojo de relleno de Chromium (`kPlaceholderColor`). El texto era
  `kColorSysOnSurfaceSubtle`, un tono oscuro sobre ese rojo.
- **Ahora:**
  - fondo `#FF9900` y texto, icono y botón en negro, en modo claro y oscuro;
  - es el mismo naranja y negro del botón de la bienvenida (`components/brave_welcome_ui/components/flyweb/estilo.ts`);
  - en las compilaciones de desarrollo también: Titín pidió naranja, no el color del canal.
- `kColorToastBackground` (el gris de Brave) no lo usa ningún *toast* de la 156, así que no se toca.

## 2. Bienvenida: «Welcome to FlyWeb» sin traducir

- El título de la pestaña es `IDS_WELCOME_HEADER`, que FlyWeb definió en `brave_welcome_strings.grdp` porque la 156 lo quitó.
  No tenía traducción en `brave_components_resources_*.xtb`.
- He añadido, en los 54 idiomas, la traducción que ya existe para el mismo texto en `brave_strings_*.xtb`. Es el mismo id
  de mensaje, `8331941171144629807`. En castellano queda «Te damos la bienvenida a FlyWeb».
- **El resto de la página ya estaba traducido:** he comprobado los 25 mensajes de `brave_welcome_strings.grdp` contra los
  `.xtb` de `es` y `es-419`. El texto de «otro navegador» del paso de importar ya estaba en castellano en el código.

## Base y árboles

brave-core `local/322-final` = **060015a802** (ls-remote del 26-11), árbol `fbdf05a0d3`. Con `git am`, árbol **`2623a46ba6`**
(comprobado). No comparte ficheros con `3.2-sync-cuenta/0012`, `3.2-iconos-linux` ni `3.2-escritorio-linux`.

## Qué deben comprobar LOCAL (Mac) y D8 (Linux)

1. Con FlyWeb no predeterminado: Ajustes → «Navegador predeterminado» → «Hacer predeterminado». El aviso de abajo debe salir
   **naranja con texto e icono negros**. Repetirlo en modo oscuro.
2. Otro *toast* cualquiera, por ejemplo «Copiar enlace» en el menú de la pestaña o «Enviar a tus dispositivos», debe salir igual.
3. Perfil nuevo con la interfaz en castellano: la pestaña de bienvenida debe titularse **«Te damos la bienvenida a FlyWeb»**,
   y ningún texto de la página debe salir en inglés.

## Ficheros

- `0001-ui-orange-toasts-with-black-text-translate-the-welco.patch` (`git format-patch --full-index`).
- `SHA256SUMS`.
