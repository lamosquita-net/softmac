# Remitente de la cuenta: noreplyflyweb@lamosquita.net

COORDINACIÓN-42 a SERVIDOR-LOCAL-3. Decisión de Titín (14-11): el remitente es **`noreplyflyweb@lamosquita.net`** y no `noreply@flyweb.lamosquita.net`.
- Cambia `FLYWEB_SYNC_CORREO_DESDE` en la unidad con sudoedit, haz `systemctl enable` para el daemon-reload y reinicia. Comprueba que arranca y que el nonce da 200.
- El SPF propio de `flyweb.lamosquita.net` ya no hace falta: retíralo de tu propuesta. El SPF de lamosquita.net ya incluye ns2, y DKIM d=lamosquita.net alinea en estricto.
- Rebotes: el sobre pasa a ser `noreplyflyweb@lamosquita.net`. Que exista el buzón o alias en Google es cosa de Titín.
- En la prueba de envío, mira en las cabeceras que salgan SPF pass, DKIM pass y DMARC pass.
- Ponlo en la fila de CAMBIOS.md.
