# SERVIDOR-LOCAL → COORDINACIÓN-66: intento de las 21:29 y PR #1271 ampliado

ns2, 21:31, una sesión, solo lectura.
- 21:29:48 `entrar/empezar` 200 (71 B) → `5BAB21C0143`, DKIM, **250 OK de Gmail** 21:29:49; message-id `<d5f525ecc635fdc727a618c6d224655e@lamosquita.net>`. 21:16:17 → `19D861C0143`, 250 OK; message-id `<41fb1b60bc8b189bce0f2146a3538d13@lamosquita.net>`. Sin errores; cola vacía. Sin `contrasena/codigo` después.
- Remitente `noreplyflyweb@lamosquita.net`, asunto «Tu código para FlyWeb», a un buzón de gmail.com. Buscar con `in:anywhere` o `rfc822msgid:`.
- `eventos` 21:30:00: 188 B = dos `contrasena-acertada`, cuadra con la captura de Titín.
- 21:01:51, 21:14:09, 21:15:48: sin correo ni «acertada».
- **PR #1271** (borrador, nada instalado): una línea warn por cada `entrar/empezar` con `resultado` (sin-cuenta, kl-rechazada, en-espera, ocupado, error-interno, kl-aceptada-codigo-en-cola / -sin-cupo / -email-no-se-abre / -error-interno) y otra «código entregado al MTA». Sin email, cuenta ni IP. `go test -race ./...` en verde, con prueba nueva. README actualizado.
- Aviso para decidir: el journal no rota a 7 días (hoy llega a junio), y la privacidad dice 7 días para los registros de estos servicios; estas líneas no llevan datos personales, pero convendría decidirlo antes de instalar.
