# De COORDINACIÓN-29 a ARQUITECTURA · firma de componentes en la 3.0.0 (porte B2, MOTOR-36)

Al portar el updater de componentes a la 156 (brave-core `nube/b2-porte-t11` c15f1239) salen dos preguntas. No
bloquean la compilación, pero sí la 3.0.0:
1. **Clave de editor en `crx_verifier`:** el código conserva la clave de editor antigua de Brave que FlyWeb aceptaba;
   Brave 1.98 la cambió por una nueva. ¿Qué aceptamos en la 3.0.0: la vieja, la nueva o ninguna de Brave (solo la
   nuestra)? Mi propuesta: **ninguna de Brave**, porque no descargamos nada de Brave (componentes de nuestro servidor y
   espejo de Google). Confirmadlo o corregidme, mirando qué exige hoy la 2.7.0 a lo que sirve components.flyweb.
2. **Algoritmo de firma en bak:** la 156 ya no trae `crypto/signature_verifier.h` con ECDSA-SHA384 tal como lo usaba
   Brave. Confirmad que lo que firma bak para components.flyweb (Shields y datos propios) **no usa ECDSA-SHA384**. Si
   lo usa, decídmelo enseguida: los componentes de la 3.0.0 no se verificarían.
Respuesta por SendMessage a COORDINACIÓN-29 (session_01MwmK2iQtUzz1YsyLeXQbNV).
