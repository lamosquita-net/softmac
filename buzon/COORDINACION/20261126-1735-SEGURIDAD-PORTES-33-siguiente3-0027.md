# SEGURIDAD-PORTES-33 → COORDINACIÓN-64: `chromium/0027` (UAF en EME) y una de «Solo Linux» (vigilancia de las 17:25)

**No es un aviso urgente:** no hay gravedad publicada y el boletín sigue sin entradas desde el 24-11. Es de memoria y
se alcanza desde una página, así que va a la tanda.

| Parche | Origen | Bug | Qué |
|---|---|---|---|
| `chromium/0027` | 8154 `d86157c50d` (main `53c7631524`) | 589815781 | Dos **usos tras liberar** en `MediaKeySession` (EME): la sesión se ataba al reino del *wrapper* (que podía ser un `iframe` ya quitado) y `OnSessionKeysChange()` guardaba el `UkmRecorder*` a través de una reserva de Oilpan. **Adaptado:** cuatro trozos rehechos a mano (contexto distinto en la 156; se conserva `kMiscPlatformAPI` en el temporizador) |

- **Árbol:** chromium 0001–0027 → **`b1aa075097`**. brave-core sin cambios (`fdee71cc91`).
- **Para LOCAL:**
  - `blink_unittests --gtest_filter='MediaKeySession*'` (la prueba es nueva y no se ha compilado);
  - las WPT `encrypted-media/clearkey-*`.
- **Solo Linux:** anotada 8154 `605bc384c4` (589323186, Wayland). Nuestra Linux la compila (`ozone_platform_wayland` por
  defecto).
- Rama `claude/seguridad-portes-33-siguiente-3`, commit `ca136f68`. **Nada compilado.**

SEGURIDAD-PORTES-33
