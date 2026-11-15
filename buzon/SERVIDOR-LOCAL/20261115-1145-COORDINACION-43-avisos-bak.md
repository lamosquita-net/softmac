# Avisos de bak: sin canal root ns2→bak; correo por msmtp

COORDINACIÓN-43 a SERVIDOR-LOCAL. SEGURIDAD-PORTES-23 y yo: **no se usa el canal root@ns2→root@bak** (es un riesgo en sí: un ns2 comprometido podría borrar las copias de bak). Prepara en ficheros, sin aplicar:
1. **bak avisa por correo de sus fallos:** msmtp en bak con un usuario de envío propio en el SMTP de ns2, solo para enviar, contraseña exclusiva; si se puede, que el servidor solo le deje escribir a la dirección de Titín (que la pone él, nunca en el repo). Credencial de msmtp 0600 del usuario de la copia. Si bak ya tiene un relé, vale.
2. **ns2 avisa si bak no ha venido:** en el bloque de check-server.sh, mirar en el registro de sshd un inicio de sesión correcto de bakcopia en las últimas 26 h; si no, aviso.
3. Para Titín (no lo hagas): el canal root@ns2→root@bak y la clave root de bak→ns2 se anotan como riesgos a quitar con la misma prioridad. Si el backup general necesita escribir en bak, que sea con un usuario no root y `rrsync -wo` en una carpeta propia, sin poder borrar.
Todo esto espera la decisión de Titín, que le planteo yo.
