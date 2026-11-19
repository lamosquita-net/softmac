# Para LOCAL-19: compilar y probar la 3.2.0 con settings/system y Apariencia

Orden de COORDINACIÓN-53. Titín decidió (19-11) que **Apariencia entra en la 3.2.0**. SEGURIDAD-PORTES-32 da APTO a #1122
(ya en main) y a #1128 (borrador; lo fusiono tras tu prueba).

**Qué montar** (brave-core sobre `local/3.1.4` `e660929ac9`, con `git am`, en este orden):
1. Serie de la interfaz `FlyWeb/parches/3.2-interfaz/` 0001–0006 (rama `claude/motor46-interfaz-3.2.0`, #1110), como en
   tu build anterior (árbol tras el 0007: `6653db38fb`; usa la misma serie que compilaste).
2. `FlyWeb/parches/3.2-ajustes-sistema/0001` (main, #1122; lleva ya el `static_assert`).
3. `0002` (fila de tema) y `0003` (pref-key en 6 desplegables) de la rama `claude/motor46-ajustes-apariencia`, punta
   `5f507225c2` (#1128).
Árboles esperados de MOTOR-46 sobre interfaz+0001 (`d58ba8b96d`): tras 0002 `d3cded8ef3`, tras 0003 `7a24c45189`.
Si tu serie de interfaz no da esos árboles, dímelo antes de compilar. **No hace falta build con DCHECK.**

**Pruebas** (pasos completos en el README de `3.2-ajustes-sistema/`):
- `BraveContentBrowserClientTest.SettingsPagesBindTheirInterfaces` y los de la interfaz que ya pasabas.
- flyweb://settings/system abre; atajos cargan.
- Apariencia: selector de tema en claro, oscuro e «Igual que macOS», recargando.
- Cada desplegable (hover de pestañas con sus 3 opciones, tamaño de letra, nueva pestaña, política de IP de WebRTC,
  Request OTR, buscador de las ventanas privadas): cambiar, recargar, comprobar que se conserva. En WebRTC, que deja de
  salir la IP local.
- **Prueba de SEGURIDAD:** con un perfil de la 3.1.4 que tenga `webrtc.ip_handling_policy` = `disable_non_proxied_udp`,
  abrir Privacidad y Apariencia sin tocar nada y comprobar en flyweb://prefs-internals que la pref no cambia.
- Capturas de Apariencia (1x en la 6,1) y, si puedes, las que faltaban de la interfaz: ventana sin foco y desplegable
  de la URL.

Entrega por el buzón (o el bridge): árbol, resultado de cada prueba y capturas. Deja después la FlyWeb abierta en la 6,1
para que Titín revise y ajuste. Nada de esto se publica: es la 3.2.0 en curso.
