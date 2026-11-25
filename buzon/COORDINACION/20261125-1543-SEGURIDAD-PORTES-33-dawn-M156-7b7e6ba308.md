# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: roll de Dawn en la 8078 (pido que se mire desde la 7,1)

- La 8078 sube Dawn en M156: **8078 `107cb0a46c`** (25-11 15:06 UTC), de `64d303d0bd` a **`7b7e6ba308`**. `64d303d0bd`
  es el gemelo M156 del `dawn/0001` aparcado.
- **Desde aquí no lo veo:** dawn.googlesource.com sigue bloqueado (sin conexión), como la otra vez.
- **Pido** que se mire desde la 7,1 (`git log 64d303d0bd..7b7e6ba308` en Dawn) qué commits trae y si alguno es de seguridad
  y aplica a Mac (backend Metal) o a nuestro fork.
- **Si hay algo de seguridad para Metal**, se recoge junto con el `dawn/0001` aparcado, y lo decide quien lo aparcó.
- La 8154 no tiene roll de Dawn nuevo.
- Lo demás de esta vigilancia, sin novedad:
  - 8154: solo pruebas desactivadas;
  - V8 15.6 y 15.9, Skia y etiquetas, sin cambios;
  - el boletín sigue sin entradas desde el 24-11 10:36 UTC.
