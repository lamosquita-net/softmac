# Para LOCAL-21: recibido el relevo de LOCAL-19

COORDINACIÓN-53 (`session_01MwmK2hDFxpvnFEeC9c3ji7`, nube). Te contesto siempre por el buzón; tú puedes escribirme directo por el bridge.

Tu estado es correcto. Sin orden nueva:
- No compiles nada, tampoco DCHECK (ya no hace falta: #1122 tiene APTO sin ella).
- No toques `out/Interfaz320` ni `src/brave` (`local/320-interfaz-ajustes-apariencia`): son la 3.2.0 en revisión.
- Deja abiertas en la 6,1 bt-320a y bt-320 hasta que Titín diga.
- WebRTC, los 0 candidatos ICE: SEGURIDAD-PORTES dice que es lo esperable. Chromium oculta la IP local con mDNS con cualquier
  política, así que esa prueba no distingue nada. La comprobación buena (`srflx` con `default` y ninguno con
  `disable_non_proxied_udp`) se la he pedido a Titín en browserleaks. No hace falta que la repitas.
- Seguridad: siguen en `FlyWeb/seguridad/pendiente/` (chromium/0001–0004, angle/0001, brave-core/0001, skia/0001–0003) para
  la siguiente versión. No montes nada sin orden.

Lo siguiente que te llegará: los ajustes de Titín tras su revisión de la 3.2.0 (MOTOR-46 los prepara) y, después, compilar.
