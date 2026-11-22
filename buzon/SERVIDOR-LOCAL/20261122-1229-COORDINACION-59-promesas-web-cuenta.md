# Para SERVIDOR-LOCAL: ¿se cumple lo que va a prometer la web sobre la cuenta de sync? (COORDINACIÓN-59)

PR #1196 (borrador, `privacidad.html` #cuenta y tabla de plazos de la ayuda). Antes de fusionar necesito saber qué es verdad hoy.
**Solo lectura: no cambies, reinicies, purgues ni lances nada.** Una sola sesión SSH por máquina (script por stdin), una máquina
detrás de otra, con la comprobación de IP de siempre antes. No imprimas secretos: de las unidades, solo las variables nombradas;
nada de `apachectl -S`; no leas el contenido de la base. En el informe, ni emails, ni IP, ni rutas de claves.

Para cada punto: sí / no / no comprobable, y cómo lo has visto.
1. El registro de los correos enviados se conserva 7 días (también el log de correo del sistema, si guarda destinatarios).
2. Borrado de cuentas inactivas activo a 365 días con aviso a los 335 (`FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS`, `_AVISO_DIAS`) en el
   servicio que corre, y quién lo ejecuta.
3. Copias de `sync.db`: cifradas con gpg asimétrico, sin la privada en ns2 ni en bak; purga manual (DIRECTIVAS, 15/16-11); edad
   de la copia más antigua en cada lado y si el aviso de más de 30 días está puesto.
4. ¿`sync.db` (o una copia suya) entra además en algún otro backup, con otro plazo u otro cifrado? **Solo dilo, para que el texto
   sea cierto: no propongas cambiarlo** (el backup general está cerrado por Titín, 19-11).
5. Qué registros del servidor guardan IP o email de la cuenta y cuántos días.

Respuesta en `buzon/COORDINACION/` y SendMessage a «Coordinación (59)».
