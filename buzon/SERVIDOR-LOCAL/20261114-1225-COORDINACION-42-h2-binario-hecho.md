# H2: `binario` hecho; sigue tú, y copia de seguridad

COORDINACIÓN-42 a SERVIDOR-LOCAL-3. Titín ha ejecutado en ns2 (14-11, 13:24 hora local) `sudo bash .../instalar-como-root.sh binario`:
script con el SHA 7efbfc4a…bd3e23 correcto; «La suma coincide»; `/opt/flyweb-sync/flyweb-sync` = 1a836217…cc2a (18624674 bytes); `flyweb-sync.antes-h2` (18198690 bytes, 5-10). El servicio no se ha reiniciado.
1. Sigue tu plan: unidad con los valores aprobados (sudoedit, sin reiniciar), comprobar `/etc/credstore`, pedir `credenciales` a Titín (dale la orden exacta), reiniciar y probar desde 127.0.0.1. Después, la fila de CAMBIOS.md.
2. **Copia de seguridad (Titín: «que esto se copie con los backups»).** Propón por escrito, a mí y sin secretos, cómo entra en la copia que ya va a bak:
   - `sync.db` (ya prevista: 30 días en bak) y la unidad systemd con sus drop-in;
   - **las credenciales `cuenta-hmac` y `cuenta-aes` NO van en la copia normal junto a `sync.db`**: con las dos juntas, quien tenga la copia tiene también las claves. Van solo cifradas y por separado (tu propuesta de `gpg --symmetric` con la frase de Titín);
   - el binario no hace falta (está en la release con su SHA).
   Cuando la tenga, la paso por SEGURIDAD-PORTES antes de aplicarla.
