# E0 — base de los tres subdominios de FlyWeb en ns2 (HECHO, 02-10-2026)

Configuración **tal como está en producción**, montada a mano por el HUMANO (etapa E0 de
[`docs/SERVIDOR.md`](../../../docs/SERVIDOR.md)). Este directorio la refleja para que el agente SERVIDOR parta de ella
(E1). Cualquier cambio en ns2 pasa primero por aquí.

| Fichero | En ns2 |
|---|---|
| `apache/flyweb-vhosts.conf` | Fragmento de `/etc/apache2/sites-enabled/lamosquita.conf` (compartido con otros sitios del HUMANO): los seis vhost de FlyWeb |
| `apache/flyweb-components-keys.conf.ejemplo` | Modelo de `/etc/apache2/flyweb-components-keys.conf`. El real (root, 0600) y `/root/flyweb-services-key` **nunca van al repo** |
| `logrotate/flyweb` | Solo si el logrotate de Apache del HUMANO no cubre ya `/var/log/flyweb/*/*.log` |

## Lo que hay en ns2

| | |
|---|---|
| DNS | Registros A de los tres nombres → 51.91.19.170 en ns1, ns2 y ns3. Sin AAAA (ver `docs/SERVIDOR.md` §6) |
| Certificado | Uno para los tres nombres, `/etc/letsencrypt/live/flyweb.lamosquita.net/`, obtenido con `certbot certonly --apache` (método habitual del HUMANO) |
| Contenido | `/var/www/flyweb.lamosquita.net`, `/var/www/FlyWeb/updates` y `/var/www/FlyWeb/components` (aquí irán `release/<id>/extension_<versión>.crx` y el catálogo) |
| Módulos | `ssl`, `headers`, `http2`, `proxy` y `proxy_http` (activado el 02-10) |
| Norma del HUMANO | Todo dentro de cada `<VirtualHost>`: nada a nivel de servidor, porque el fichero se comparte con otros sitios |

## Privacidad

| Vhost | Registro |
|---|---|
| Puerto 80 (los tres) | Solo redirige a https. Sin registros propios: van a los generales de `/var/log/apache2/`, con IP, como el resto de sitios. FlyWeb usa siempre https, así que lo que llega aquí no es FlyWeb. **Regla: ninguna URL de FlyWeb puede ser `http://`** |
| `flyweb.lamosquita.net` (página) | **Con IP** (`combined`), decisión del HUMANO. Hay que decirlo en la página de privacidad, con el plazo de conservación |
| `updates.` y `components.` (los contacta el navegador sin que el usuario haga nada) | **Sin IP**: formato `sinip` en accesos, `ErrorLogFormat` sin `[client …]` en errores, y `ProxyAddHeaders Off` para que el servicio tampoco reciba la IP. Están en `/var/log/flyweb/`, fuera de fail2ban y CrowdSec |

## Clave de servicio de `components.`

- **Qué exige Apache.** En `/extensions` pide la cabecera `BraveServiceKey` con 64 caracteres hexadecimales que
  coincidan con la clave actual o la anterior.
- **Falla cerrado.** Si falta el fichero, si se deja la clave de ejemplo o si llega cualquier otra clave, responde 403.
  Si falta el fichero, Apache arranca igual para el resto de sitios.
- **Dónde está la clave.** En `/root/flyweb-services-key`; se generó sin mostrarla en pantalla. Al Mac de compilación
  se copia a `~/proyectos/softmac/claves/flyweb-services-key` por el canal habitual del HUMANO, nunca pegada en un chat.
  `build.sh` la lee de ahí.
- **Rotación.** La nueva va en `ACTUAL` y la vieja en `ANTERIOR`, hasta que no quede ningún FlyWeb antiguo.

## Comprobado

- **En ns2 (HUMANO, 02-10):**
  - `configtest` sin avisos;
  - `/extensions` sin clave → 403; con la clave → 503 (llega al proxy, `go-update` aún no está; E2).
- **En NUBE (contenedor, Apache 2.4.58), este mismo fragmento:**
  - el 80 da 301;
  - página, `appcast.xml` y `.crx` dan 200;
  - `/extensions` 403 sin clave y 503 con ella;
  - la IP del cliente aparece 0 veces en los registros de `updates.` y `components.`, y sí en los de la página.

## Incidencias del 02-10 (para el agente de auditoría)

- **fail2ban tenía baneada la IP de la propia ns2** en `apache-exploit` desde antes del 30-09. Se restauraba con cada
  reinicio.
  - **Causa:** `51.91.19.170` estaba en `ignoreip` de `jail.local`, pero fail2ban no se había recargado. Resuelto
    con `unbanip` y `reload`.
  - **Pendiente:** averiguar qué hace que ns2 se pida páginas a sí misma (¿`wp-cron` u otra petición en bucle?):
    `sudo zgrep -h "client 51.91.19.170" /var/log/apache2/*/*error.log*`.
- **fail2ban no lee la raíz de `/var/log/apache2/`.** Sus jails solo miran subcarpetas (`*/*access.log`), así que los
  puertos 80 de todos los sitios, que van a los registros generales, solo los ve CrowdSec.
