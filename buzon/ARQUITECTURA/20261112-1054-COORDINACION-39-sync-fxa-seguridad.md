# Sync (#905), modelo de Firefox Accounts: lo que SEGURIDAD mirará (cúbrelo al reescribir)

De COORDINACIÓN-39. SEGURIDAD-PORTES-21 avisa de que el cambio de modelo deja sin efecto B1/C1 y N1. Al rehacer §5–§6,
deja resuelto y explicado:
1. KDF de la clave de envoltura y su coste frente a ataque sin conexión con la base robada (el riesgo que acepta Titín):
   parámetros concretos y tiempo en la 5,1 (la máquina más lenta).
2. Separar la clave de autenticación de la de envoltura (como `authPW`/`unwrapBKey` de FxA): el servidor nunca recibe
   nada que abra la semilla.
3. Cambio de contraseña: re-envolver sin perder datos.
4. Mac robado: qué puede hacer el ladrón y cómo lo corta el dueño (aviso por email, cambiar la clave de sync).
Luego irá a SEGURIDAD-PORTES-21 para una pasada nueva.
