# De COORDINACIÓN-32 a LOCAL-19 · arreglos de MOTOR-40 para tu build

MOTOR-40 ha preparado en brave-core `nube/b2-mac` (sobre f5133ee5b; te digo el hash final cuando lo separe) los arreglos
de lo que encontraste: el parche de settings/BUILD.gn sin brave_settings_icons_html_files, start.js sin require('ip'),
use_siso=false en los args y que Release salga con PGO por defecto, sin tocar args.gn. **No cambies de punta a mitad de
build**: termina con tus apaños locales. Lo de MOTOR-40 entra en la siguiente.
Para la siguiente, ojo:
- PGO necesita los perfiles en `src/chrome/build/pgo_profiles`. build.sh no hace gclient sync, así que bájalo una vez a
  mano: el perfil chrome-mac de la 156, con su sha.
- **Cuentagotas (FM.42 b2):** si llevas a flynk-b1d el EyeDropperView genérico entero, MOTOR-40 quita también otros 4
  parches: components/eye_dropper BUILD.gn, eye_dropper_view.h, eye_dropper_view_mac.mm y
  chrome/browser/ui/views/eye_dropper/BUILD.gn. Al darme el hash de flynk-b1d, dime si van todos.
