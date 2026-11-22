# SERVIDOR-LOCAL → COORDINACIÓN-59: comprobación de las promesas de la web (solo lectura, 22-11, ns2 + código de main)

Hecho con tres sesiones SSH seguidas a ns2 (IP = DuckDNS antes de cada una), solo lectura, sin imprimir líneas de log ni emails ni IP, sin `apachectl -S`. **bak no lo he mirado**: mis accesos son los de ns1/ns2; `cc-bak` es otra cuenta y no la uso. Los puntos que dependen de bak van marcados «no comprobable» y los puede mirar la Auditoría. El código es el de `origin/main` de hoy; el binario desplegado se construyó desde main (#1024), no he leído su esquema ni filas.

Resumen: **cumple** la ausencia de IP en los registros de sync, proxy, componentes y actualizaciones. **No cumple tal cual**: «7 días» en los registros de error (quedan ficheros más viejos), el correo del sistema (≈5 semanas con destinatarios), el borrado de inactivas (desactivado en lo desplegado) y «no se guarda el registro de peticiones» (la sync guarda método, ruta, código y bytes durante 7-8 días).

## 1. Correos enviados, 7 días — NO
- `/var/log/mail.log` (Postfix) **guarda destinatarios** (`to=<…>`). Rotación semanal, `rotate 4`, `delaycompress`: hoy hay ficheros desde el 26-10 (≈27 días) y llegará a ≈5 semanas. Líneas con destinatario por fichero, del actual al más viejo: 2, 25, 40, 17, 31.
- Postfix no escribe en el journal (0 líneas con destinatario).
- La sync por sí misma no guarda destinatarios: solo contadores por hora (`correos_altas`, `correos_codigos`, `correos_avisos`), vistos en el código.
- Cómo lo he visto: `ls`, `logrotate.d/rsyslog` y `logrotate.conf`, recuento de `to=<` con `grep -c`.

## 2. Borrado de inactivas a 365 con aviso a 335 — NO (desactivado en lo desplegado)
- La unidad desplegada `/etc/systemd/system/flyweb-sync.service` tiene la línea **comentada** (`#Environment=FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365`, línea 22; `systemctl cat` incluye drop-ins y no hay otra). El valor por defecto es 0 = no borra. El fichero del repositorio (`FlyWeb/servidor/systemd/flyweb-sync.service`, línea 14) sí la tiene activa: hay desajuste repo/servidor.
- `FLYWEB_SYNC_AVISO_DIAS` no está en la unidad; por defecto 30, es decir aviso a los 335 si se activara.
- Quién lo ejecuta: el propio proceso `flyweb-sync`, en una tarea cada hora (`time.Tick(time.Hour)` en `main.go`, más `inactivas()` de la cuenta). No hay cron ni timer aparte. Activarlo exige cambiar la unidad (lo haría la Auditoría) y reiniciar.

## 3. Copias de sync.db — parcial
- **Hecho, visto:** la copia diaria de las 03:30 terminó bien el 20, 21 y 22-11 (journal de `flyweb-sync-copia.service`); el timer está activo (próximo, 23-11). La carpeta `/var/backups/flyweb-sync` es `root:flyweb-copia` 0750 y `/etc/flyweb-copia` es root 0700.
- **No comprobable por mí:** el contenido de esa carpeta y el llavero (sin permiso), así que no he visto edad de la más antigua en ns2 ni que no haya clave privada. Por diseño el script solo usa la huella pública y la privada está solo en el Mac de Titín; lo comprobó la Auditoría al aplicar la v6.
- Edad: la primera copia v6 es del 16-11 (la v5 manual, del 15-11): la más antigua ronda 6-7 días y ninguna llega a 30 antes de mediados de diciembre.
- Purga: manual, con `flyweb-copia-purgar.sh` (palabra BORRAR, solo a 30 días o más, solo si hay copia reciente). Lo dejé en los paquetes.
- Aviso de más de 30 días de `check-server.sh`: **no lo encuentro** en ns2 (solo vi `check-fail2ban-ip.sh`); no comprobable por mí.
- bak: no comprobable (edad, ausencia de clave privada, purga). Los scripts de traída que preparé escriben en `/home/ubuntu/flyweb-sync-copias`.

## 4. ¿sync.db o una copia entra en otro backup? — probablemente no, no verificado
- El backup general (cron de root a las 05:30, rsync a bak, instantáneas por hardlinks semestrales, GFS 14/8/24) cubre, según el borrador de la Auditoría, `/etc`, `/var/www` y `/home`. `sync.db` está en `/var/lib/private/flyweb-sync` y las copias en `/var/backups/flyweb-sync`: fuera de esas rutas. **No lo he verificado leyendo el script** (`/root/scripts/backup_hacia_ns3.sh` no es legible para mí).
- Para que el texto sea cierto: `/etc` sí entra con `cuenta-hmac`, `cuenta-aes`, la clave DKIM y el llavero público de la copia, con el plazo de ese backup (años por las instantáneas semestrales). Son las claves con las que se descifran email y nombres de los Mac; la base no va ahí. Solo se dice, no se propone nada.

## 5. Registros que guardan IP o email (ns2, plazos reales)
| Registro | Qué guarda | Plazo real |
|---|---|---|
| `/var/log/flyweb/flyweb.lamosquita.net/` (web pública) | formato `combined`: IP, agente, referer | diario, `rotate 14` |
| `/var/log/apache2/access.log` (vhost por defecto) | `vhost_combined`/`combined`: IP | diario, `rotate 14` |
| `/var/log/fail2ban.log` | IP de los baneos | semanal, `rotate 4` (≈4-5 semanas) |
| `/var/log/mail.log` | destinatarios (email) y remitentes | semanal, `rotate 4` (≈5 semanas) |
| journal del sistema | de todo el sistema (SSH, etc.) | sin límite propio; hoy 1,2 GB y llega hasta el 14-06 |
| journal de `flyweb-sync` | avisos y errores; 0 líneas con IP que no sea 127.0.0.1 | sin límite de 7 días; desde el 05-10 |
| `auth.log` y registros de ufw | no mirados | — |

## 6. Vhost de la sync — IP no, pero sí registro de peticiones
- `CustomLog /var/log/flyweb/sync/apache_access.log sinip_sinconsulta`; `ErrorLog` en `apache_error.log` con `ErrorLogFormat "[%{cu}t] [%-m:%l] %F: %E: %M"` (sin cliente). Lo veo en `sites-available/lamosquita.conf`, líneas 367-372.
- Resultado: 0 líneas con IPv4 en el acceso y en el error de la sync. Formato observado en la última línea, ya filtrada: `[fecha] "MÉTODO /ruta/" código bytes`, sin cadena de consulta (0 `?`). **Sí guarda el registro de peticiones**: hora, método, ruta, código y bytes. Si la web promete «ni el registro de peticiones», hay que cambiar el texto o quitar el CustomLog.
- Delante no hay proxy ni cortafuegos que registre aparte, que yo haya visto. Fuera de la sync: fail2ban.log guarda IP (arriba). Los registros de ufw no los he mirado.
- Aviso: mi primer recuento marcó «IPv6» en todas las líneas; era un falso positivo de las marcas de hora (`22/Nov/2026:13:38:52`). Con las líneas vistas y el formato, no hay IP.

## 7. `cuenta_eventos` — cifrado sí (en el código); purga 30 días sí
- El campo `datos` se sella con AES-256-GCM con la clave de la credencial (`s.cfg.AES.sellar`, `aes_v` guarda la versión; cuando no hay datos se guarda vacío). En claro quedan `cuenta` (id), `n`, `tipo` y `fecha`. Dentro del cifrado van el aparato, el Mac, el modelo, etc.
- Se purgan con `DELETE FROM cuenta_eventos WHERE fecha < ahora − vidaEvento`, `vidaEvento = 30 días` (`servicio.go`, en `caducar`, marcado «provisional» en el código). No he leído la frecuencia de `caducar` ni el esquema desplegado ni filas.

## 8. Privacidad ya publicada (líneas 49-51): «sin IP ni consultas de navegación segura, borrado a los 7 días»
Rotación común: `/etc/logrotate.d/flyweb`, `daily`, `rotate 7` (hasta 8 ficheros, es decir 7-8 días de datos) para `components`, `updates`, `proxy` y `sync`.

| Servicio | CustomLog | ErrorLogFormat | IP / consultas | Resultado |
|---|---|---|---|---|
| sync | `sinip_sinconsulta` | sin cliente | 0 IPv4, 0 `?` | IP no; 7-8 días en acceso |
| proxy (navegación segura) | `sinip_sinconsulta` | sin cliente | 0 IPv4, 0 `?` (82 líneas hoy) | IP y consulta no; 7-8 días en acceso |
| componentes | `sinip` | sin cliente | 0 IPv4, 0 `?`; error: 9 líneas sin cliente | IP no; 7-8 días |
| actualizaciones | `sinip` | sin cliente | 0 IPv4, 0 `?`; error: 11 líneas «client denied…» sin IP | IP no; 7-8 días |

- **Fallo de los «7 días» en los logs de error:** quedan ficheros de error pequeños con fecha muy anterior. En sync, `apache_error.log.3` es del 30-10 y `.2` del 09-11; en proxy, `apache_error.log.1` es del 03-10 (≈50 días). Son errores sin IP, pero pasan de 7 días. La causa probable es que logrotate solo rota si no están vacíos (`notifempty`, no verificado en la configuración leída). El acceso sí cumple.
- Los journals de las unidades no están acotados a 7 días (ver punto 5).
- La web pública (`flyweb.lamosquita.net`) sí guarda IP, 14 días, y el vhost por defecto de Apache también (14 días): aparte, como pedías.

## Lo que no he hecho
No he cambiado, reiniciado, purgado ni lanzado nada. Los scripts de lectura están en mi carpeta de trabajo y no se han copiado a ningún servidor (se enviaron por stdin).

---

# Precisiones pedidas por COORDINACIÓN-59 (sin SSH nuevo; sale de lo ya leído y del repo)

## (a) «Registro de correos» de la aplicación frente al mail.log del sistema
- **Aplicación (`flyweb-sync`):** no tiene registro de correos enviados. Solo cuenta (`correos_altas`, `correos_codigos`, `correos_avisos`) y lo vuelca cada hora al journal como totales, sin destinatario; y el aviso «tope de correos alcanzado» cuando salta el cupo. El destinatario no queda en la aplicación (en la base solo están cifrados el email y un HMAC para buscar).
- **Sistema (`/var/log/mail.log`, Postfix):** es el único sitio donde queda el destinatario de cada correo (`to=<…>`), junto con el estado de la entrega. Postfix no escribe en el journal (0 líneas con destinatario).
- **Rotación del mail.log:** la define el bloque de rsyslog (`/etc/logrotate.d/rsyslog`, con `weekly` y `rotate 4`); es la misma de syslog y del resto de registros de ese grupo en ns2 (y coincide con el valor por defecto de `logrotate.conf`: `weekly`, `rotate 4`). No es específica de FlyWeb: no hay una regla distinta para el correo de la sync. Estado hoy: ficheros desde el 26-10, unas 4-5 semanas con destinatarios. (No he leído el bloque entero de rsyslog más allá de las líneas `rotate`, `weekly`, `compress` y `delaycompress`.)

## (b) La línea de inactivas, comentada: desde cuándo y por qué
- Está comentada **desde la instalación**. Historial del repositorio: el 03-10 (`98271e1b`) se añadió la opción «apagada por defecto» con la línea comentada en `systemd/flyweb-sync.service`; el 05-10 16:09 se instaló `flyweb-sync` en producción con esa unidad (`e9b1b783…`, fila de CAMBIOS del 05-10 16:09, SV.1).
- El 09-10 el HUMANO decidió activarla («HUMANO's decision (09-10): enable … =365», commit `1d2fe962`, que descomenta la línea en el repo y cambia `privacidad.html`: «nada se borra antes de octubre de 2027»).
- **En CAMBIOS.md no consta ninguna fila que reinstale la unidad tras esa decisión.** La unidad del servidor sigue con la línea comentada (visto hoy). Los motivos escritos para dejarla comentada son solo «apagada por defecto» (03-10). No hay constancia de un motivo posterior: parece que la decisión del 09-10 no llegó al servidor, no que se decidiera lo contrario.
- Consecuencia a tener en cuenta con la web: `privacidad.html` (desde el 09-10) ya dice que se borran las cadenas sin escrituras en un año; el servidor hoy no lo hace.

## (c) ¿Entra sync.db en otro backup?
- **Backup general de ns2 (cron de root, rsync a bak):** **no comprobable** por mí (el script no es legible para `servidor`). Según el borrador de la Auditoría cubre `/etc`, `/var/www` y `/home`; la base está en `/var/lib/private/flyweb-sync` y las copias en `/var/backups/flyweb-sync`, fuera de esas rutas. Entraría solo lo de `/etc` ya dicho (claves de cuenta, DKIM, llavero público de la copia), nunca la base.
- **Copia propia (v6):** cifrada con gpg asimétrico; bak la trae por pull a una carpeta propia. Lo que haga bak con esa carpeta (otro backup de bak, instantáneas) no lo he visto: **no comprobable**.
- Instantáneas semestrales con hardlinks del backup general en bak: ver arriba; no tocan sync.db.

## (d) Días de cada registro, por servicio (de `/etc/logrotate.d/flyweb`, bloque `daily`, `rotate 7`, común a `sync`, `proxy`, `components` y `updates`; la web pública tiene su propio bloque de 14 días)
| Servicio | Acceso | Error |
|---|---|---|
| sync | diario, hasta 8 ficheros ≈ 7-8 días (de 15-11 a hoy) | misma regla, pero con ficheros más viejos: 30-10 y 09-11 (ver abajo) |
| proxy | igual, 7-8 días (de 15-11 a hoy) | misma regla, fichero de 03-10 (≈50 días) |
| components | igual, 7-8 días (de 15-11 a hoy) | misma regla; hoy 8 ficheros desde el 15-11 (cumple) |
| updates | igual, 7-8 días | misma regla; 8 ficheros desde el 14-11 (cumple) |
| web pública (con IP) | `rotate 14`, 14-15 días | 14-15 días |
| Apache por defecto (con IP) | `rotate 14` | `rotate 14` |

- Los ficheros de error de `sync` y `proxy` más viejos que 7 días (30-10, 09-11 en sync; 03-10 en proxy) son pequeños: no rota porque están casi vacíos/estables; la causa probable es una opción `notifempty` o similar, **no verificada**. Sin IP en ninguno (formato sin cliente).
