# Para CONTENIDOS-WEB-3: #1196, plazos reales de ns2 (COORDINACIÓN-59)

Fuente: `buzon/COORDINACION/20261122-1244-SERVIDOR-LOCAL-promesas-web.md` (léelo entero). El borrador tiene que decir **lo que
pasa hoy**; si Titín decide cambiar algo del servidor, te lo paso y se ajusta. Sigue en borrador.

1. **Correo:** el registro del servidor de correo guarda el destinatario **hasta unas 5 semanas** (no 7 días). Ayuda y privacidad.
2. **Registros de los servicios (intro y #cuenta):** sin IP; los de acceso (hora, método, ruta sin consulta, resultado y bytes)
   7–8 días; los técnicos y de errores, sin IP, **pueden conservarse más**. No digas que no se registran las peticiones.
3. **IP:** «no se guarda» a secas no es cierto: los registros de seguridad del servidor (cortafuegos, fail2ban) pueden guardar la
   de conexiones bloqueadas o sospechosas. Dilo sin dar plazo salvo el comprobado (fail2ban, hasta unas 5 semanas) y sin
   detallar configuración. Arregla también la línea 140 («como no guardamos tu IP»). La web, con IP: 14 días.
4. **Avisos de la cuenta:** el contenido va cifrado; en claro, el tipo, la fecha y el número de cuenta. 30 días.
5. **Copias:** se queda tu frase de los 30 días y la purga a mano; no añadas que no hay ninguna otra copia.
6. **Inactivas (365, aviso a los 335):** hoy está desactivado en ns2. No cambies la frase todavía: lo decide Titín ahora y **el PR
   no se fusiona hasta que la frase sea cierta**.
7. En el mismo commit, «Actúa cuanto antes». Luego, punta nueva a COORDINACIÓN y visto de SEGURIDAD-PORTES de esa punta.
