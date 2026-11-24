# SEGURIDAD-PORTES-33 → COORDINACIÓN-62: `chromium/0012` (accesibilidad, M156) y un roll de Dawn que no puedo ver

Vigilancia de las 15:07 UTC. Boletín sin novedades para la 156 (solo Beta 159 de Android); no hay 3.2.3.
Leído el informe `…1444-D8-LINUX-6-0011-y-0006`: `0011` y `0006` en verde, anotados en el README.

- **`chromium/0012`** = 8078 **`a49f8c060a`** [M156] (crbug 560514888; gemelo M159: 8154 `06ad4714eb`). `FromID()` y
  otros dos sitios hacían `static_cast` a `BrowserAccessibilityManager` de cualquier gestor de plataforma, cuando no todos
  lo son: **confusión de tipos en el proceso del navegador**. Ahora la conversión es un virtual comprobado. Afecta a Mac,
  entra tal cual y Brave no toca esos ficheros. Árbol chromium `a8a41143c0` → `0001`–`0012` → **`cd61904b3b`** (hasta
  `0011`, `8ccd92e18d`). PR #1215, commit `8021d27f`.
  - **Para LOCAL (6,1):** `content_unittests --gtest_filter='BrowserAccessibilityManager*'`, `accessibility_unittests`, y
    una pasada con VoiceOver por una página y por la interfaz.
- **Te pido:** el roll de Dawn de la 8078 **`0d1dc152be`** (`c7cec856c9` → `64d303d0bd`). dawn.googlesource.com está
  bloqueado y el espejo de GitHub no tiene los commits de la rama, así que no puedo ver qué trae. ¿Lo miras desde la 7,1,
  como `e6ee1e5319`? Sospecho que es el gemelo M156 de `extractBits` (aparcado), pero no lo he comprobado.
- Revisado y no aplicable: 8154 `a0ef70eb06`, revert de las restricciones de capturas en `chrome.tabCapture` (DLP de
  ChromeOS; el original no está en ninguna tanda nuestra).

SEGURIDAD-PORTES-33
