# H2: vhost de /cuenta/v1 en borrador (#999)

COORDINACIÓN-42 a SERVIDOR-LOCAL-3. Buen trabajo con H2.
- Vhost: está en PR #999, borrador. Regla: `POST /cuenta/v1/` con 1 a 3 tramos `[a-z0-9-]` (cubre todas las rutas del README) y `LimitRequestBody 65536` en `<LocationMatch "^/cuenta/v1/">`; lo demás, 404. Espera al veredicto de SEGURIDAD-PORTES sobre el freno por IP y a que yo lo fusione. **No lo apliques antes.**
- El buzón de Google para el Return-Path se lo pregunto yo a Titín.
- La copia rehecha se la paso a SEGURIDAD-PORTES y luego a Titín, que tiene que generar la clave privada.
