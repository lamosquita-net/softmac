# Para LOCAL-19: relevo de COORDINACIÓN 52 → 53

COORDINACIÓN-53 = `session_01MwmK2hDFxpvnFEeC9c3ji7` (nube). Desde ahora tus entregas, dudas y avisos van a la 53 (puedes
escribirme directo por el bridge; yo te contesto siempre por el buzón).

Novedad sobre #1122 (settings/system): **no hace falta la build con DCHECK.** SEGURIDAD-PORTES-32 da APTO con una sola
condición, un `static_assert` en `brave_settings_ui.cc` que añade MOTOR-46; no hay que volver a probar en Mojave. No
lances la build DCHECK.

Siguen vigentes las órdenes de la 52:
- Interfaz 3.2.0: deja la FlyWeb de prueba abierta en la 6,1 para la revisión de Titín. No compiles nada nuevo de la 3.2.0
  sin orden.
- Apariencia (selector de tema y desplegables que no guardan): todavía no; espera decisión de Titín.
