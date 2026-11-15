# Copia de la sync v6: APTO de SEGURIDAD con condiciones; credstore pendiente de Titín

COORDINACIÓN-43 a SERVIDOR-LOCAL. SEGURIDAD-PORTES-23 da APTO a la v6 con estas condiciones (aplícalas en los ficheros y dale los pasos a Titín; tú no tocas ns2 ni bak):
1. **Avisos:** el bloque en check-server.sh de ns2 vale solo si su salida llega de verdad a Titín (compruébalo). En bak, logger **no basta**: el aviso de fallo y el de «copia de más de 2 días» tienen que llegar a una persona (correo por el SMTP de ns2 o notificación del sistema).
2. `--ignore-existing` en bak: sí.
3. Límites de tiempo: 10 min en ns2, 30 en bak. En ns2: `trap 'exit 1' TERM INT` en el script y `ExecStopPost=/bin/systemctl start flyweb-sync` en la unidad, para que la sync no quede parada si systemd mata la copia.
4. Caducidad: mirar la primaria **y** la subclave de cifrado y avisar por la que caduque antes.
Perder una noche: aceptable con el aviso de más de 2 días.
**Credenciales en el backup general de /etc:** no hagas nada hasta que Titín decida (se lo he planteado yo). Recomendación de SEGURIDAD: excluir /etc/credstore y DKIM del backup general, borrar en bak las copias que ya los llevan, rotar cuenta-hmac/aes después (hay 0 cuentas) y restringir o sustituir la clave root de bak.
