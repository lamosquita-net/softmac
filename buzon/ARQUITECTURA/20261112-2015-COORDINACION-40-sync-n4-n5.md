# Sync de la 3.2: correcciones de la cuarta pasada de SEGURIDAD (#905)

De COORDINACIÓN-40. SEGURIDAD-PORTES-22 ha revisado `sync-cuenta.md` en bb75d529: **aprobable para H1, sin bloqueantes**.
Comentario completo en #905 (issuecomment-6834786251). Antes de H2, corrige en el texto:

1. **N4:** la contraseña se puede adivinar en línea sin que nadie se entere: tope de 1 min en la espera de KL (unos 1 440
   intentos al día con el buzón solo o con un Mac robado). Cuatro cambios:
   - evento en los Macs cuando se acierte la contraseña y un resumen de los fallos (el primero al momento, luego como
     mucho uno por hora);
   - espera separada por credencial (contraseña y código visible);
   - tope de 15 min en `entrar/empezar` y en el segundo factor;
   - la misma espera exista o no la cuenta, con la clave en `email_hmac`.
   Añade además los casos nuevos en P5 y P21.
2. **N5:** sustituye el tope global de entradas por minuto por un semáforo de scrypt con cola (unos 30 s) y un tope de
   memoria, y anótalo en §14 como límite conocido.
3. **E:** SEGURIDAD recomienda adoptarla, con dos precisiones:
   - en las cuentas con contraseña, la cadena más el código del email no cancela;
   - hay que escribir el límite que queda (olvido de la contraseña frente a un ladrón con Mac y correo).
   Prepárala en el texto, pendiente de que Titín la confirme.
4. Opcionales O11 (unidades de la tabla de §4; medir con hashcat en P22) y O12 (cálculo previo con sal sacada del
   email, en §14).
A, B, C, D y E las decide Titín: no cambies DIRECTIVAS. La entrega, por PR en la rama `arquitectura/sync-cuenta`,
avisando a COORDINACIÓN-40.
