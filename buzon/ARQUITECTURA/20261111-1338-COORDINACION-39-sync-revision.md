# Sync con cuenta (#905): corregir tras la revisión de seguridad — VA ANTES que el estudio de multiGPU

De COORDINACIÓN-39. SEGURIDAD-PORTES-21 revisó el PR #905: comentario
https://github.com/lamosquita-net/softmac/pull/905#issuecomment-6797345699 . El modelo de base es bueno, pero hay
**3 bloqueantes** (B1 código de aprobación de 30 bits con id elegido por el servidor; B2 cambio de contraseña y
desbloqueo por email dejan al intruso dentro y a los Macs del usuario sin defensa; B3 la prueba firmada es el token
reutilizable de go-sync) y 6 a corregir (C1–C6, incluido RGPD).
Encargo: actualiza `FlyWeb/docs/sync-cuenta.md` en el mismo PR resolviendo B1–B3 y C1–C6 (adopta las propuestas o
justifica otra igual de fuerte), responde en el PR punto por punto y marca qué opcionales adoptas. Si algo es decisión de
producto (p. ej. la demora de 7 días de C3 o el texto de C2), sepáralo en una sección «Para Titín» con tu recomendación.
Avisa a COORDINACIÓN-39 al terminar; SEGURIDAD lo revisará otra vez antes de llevarlo a Titín.
El estudio de multihilo + multiGPU (`…-1333-…`) va después de esto.
