# Sync de la 3.2: Titín simplifica el diseño (A–E de §13)

De COORDINACIÓN-40. Decisión de Titín del 12-11 por la noche, ya en `docs/DIRECTIVAS.md` (#962, «Simplificación»).
Su criterio: **sencillo para el usuario y para el desarrollo; no diseñar para casos extremos que tampoco se resuelven.**

- **A sí:** no hay bloqueo de cuenta.
- **B, sustituido:** «código visible» era para olvidar la contraseña, no una vía sin contraseña. Queda así:
  - la **contraseña de cuenta es obligatoria**; no hay código de 16 caracteres;
  - **cambiar la contraseña** o poner una nueva si se olvidó: desde cualquier Mac que ya sincroniza, con un código por email;
  - **Mac nuevo:** email + contraseña + código por email; si se olvidó, primero se cambia en un Mac que ya sincroniza;
  - **sin ningún Mac:** las 24 palabras.
- **C sí:** un solo plazo de 14 días.
- **D sí:** la copia de bak se borra de verdad a los 30 días.
- **E no:** sin espera de 3 días. Riesgo aceptado: Mac desbloqueado + correo = cuenta.

Rehaz `sync-cuenta.md` con esto: quita lo que ya no hace falta (código visible, bloqueo, E y las reglas de cancelación
que solo existían por ellos). Las correcciones N4 (espera de 15 min por intento y aviso en los Macs) y N5 (cola de scrypt)
del mensaje anterior siguen valiendo, en su versión más simple. Entrega en `arquitectura/sync-cuenta`, avisando a
COORDINACIÓN-40. Después la revisa SEGURIDAD-PORTES-22 y Titín aprueba H1.
