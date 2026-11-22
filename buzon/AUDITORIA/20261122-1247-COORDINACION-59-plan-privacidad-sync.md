# Para AUDITORÍA: plan (sin aplicar) para que ns2 cumpla la privacidad de la sync (COORDINACIÓN-59)

Contexto: `buzon/COORDINACION/20261122-1244-SERVIDOR-LOCAL-promesas-web.md`. Según CONTENIDOS-WEB-3, Titín quiere que las promesas
queden como las dijo (sin IP, sin registro de peticiones, correo 7 días, cifrado, 30 días). **Titín todavía no ha aprobado ningún
cambio en el servidor:** esto es solo lectura y preparar el plan que se le enseñará. Nada se escribe, reinicia, recarga, rota,
mueve ni borra. Una sesión SSH por máquina, una detrás de otra, IP comprobada antes; sin secretos ni líneas con datos en la salida.

Para cada cambio: diff exacto, dueño y permisos, cómo se vuelve atrás, qué se reinicia o recarga y qué puede romper.
A. Activar `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365` (decidido el 09-10, no llegó a la unidad): y cuántas cuentas o cadenas
   borraría o avisaría hoy (solo recuento, si puede sacarse sin leer datos; debería ser 0).
B. Registro de correo a 7 días: regla propia sin cambiar el resto del bloque de rsyslog; efecto en fail2ban y en el diagnóstico de
   los demás dominios.
C. Sync sin registro de peticiones: antes, **qué jaulas o guiones leen ese log** (si lo lee alguno, dilo y no lo propongas a ciegas).
D. Registros de error de sync y proxy a 7 días de verdad.
E. Los ficheros que hoy ya pasan del plazo: **lista nominal** (fichero, tamaño, fecha, por qué) y simulación de cuarentena.
F. Solo informar: si `sync.db` o sus copias entran en el backup general o en otro de bak, edad de la copia más antigua y si está
   el aviso de 30 días. El backup general está cerrado: no se propone cambiarlo.
Fuera del plan, no se tocan: fail2ban e `ignoreip`, cortafuegos, sshd, sudoers, usuarios y el journal del sistema.
Si algo no es buena idea para el conjunto de los servidores, dilo: manda tu criterio. Respuesta en `buzon/COORDINACION/` (pública:
sin IP, emails, secretos ni rutas de claves) o por SendMessage a «Coordinación (59)» lo que no pueda ser público.
