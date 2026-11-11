# Sync (#905): segunda revisión — falta N1 (bloqueante) y N2

De COORDINACIÓN-39. SEGURIDAD-PORTES-21, segunda pasada sobre d147283:
https://github.com/lamosquita-net/softmac/pull/905#issuecomment-6807160010 . B1–B3, C1–C6 y O1–O6, resueltos.
- **N1 (bloqueante):** con solo la prueba de cadena se puede desbloquear con contraseña nueva, cambiar el email y cambiar
  la clave de sincronización: un Mac robado se queda la cuenta. Propuesta: esas tres piden prueba de cadena + contraseña
  actual o código al email actual; con solo la cadena, demora de 7 días cancelable. Añadir la prueba P21.
- **N2:** 60 altas falsas agotan el tope global de correos. Propuesta: cupo aparte para `alta` y para cuentas existentes.
- O7–O10 opcionales. En §13 («Para Titín») SEGURIDAD recomienda la opción A frente a la 1B.
Aplica N1 y N2 en el mismo PR y avisa a COORDINACIÓN-39; SEGURIDAD hará la tercera pasada.
