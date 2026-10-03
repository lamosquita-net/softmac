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

## Propuesta: `proxy.flyweb.lamosquita.net` (NUBE, 03-10; pendiente del HUMANO)

Sustituye los proxies de Brave (`safebrowsing*.brave.com`, `sb-ssl.brave.com`, `redirector.brave.com`) por uno propio
en ns2. El navegador lo usa desde brave-core `nube/proxies-propios` y `build.sh` (`safebrowsing_api_endpoint`).
Fichero: `apache/flyweb-proxy-vhost.conf`; modelo de la clave: `apache/flyweb-proxy-keys.conf.ejemplo`.

| Ruta | Destino | Para qué |
|---|---|---|
| `/v4/<método>` | `safebrowsing.googleapis.com` | Safe Browsing (listas y comprobación de prefijos) |
| `/safebrowsing/clientreport/download` (POST) | `sb-ssl.google.com` | Comprobación de descargas |
| `/safebrowsing/clientreport/crx-list-info` (POST) | `safebrowsing.google.com` | Lista de extensiones peligrosas |
| `/edgedl/chrome/dict/<idioma>.bdic` | `dl.google.com` | Diccionarios del corrector |
| Todo lo demás | 404 | — |

- **Privacidad:** sin IP en accesos ni errores, y **sin la consulta** en el registro, porque lleva prefijos de hash de
  URL. Hacia Google no van cookies, Referer, `X-Client-Data` ni ninguna cabecera con la IP del cliente.
- **Clave:** el proxy quita la que trae el navegador y pone la nuestra. Sin fichero de clave, Safe Browsing da 404 y
  los diccionarios siguen funcionando.
- **Probado en NUBE** (Apache 2.4.58, servidores locales en lugar de Google): clave sustituida, con o sin clave del
  navegador; las 4 rutas; 404 en el resto, también con `..`; 301 en el puerto 80; sin IP ni consulta en los
  registros; `X-Forwarded-For` y `Forwarded` del cliente quitados; sin fichero de clave, `/v4` da 404.

Pasos del HUMANO:
1. **Clave de Google:** Google Cloud Console → activar *Safe Browsing API* → crear una clave de API restringida a esa
   API y a la IP de ns2. Guardarla en `/etc/apache2/flyweb-proxy-keys.conf` (root 0600) sin mostrarla en pantalla.
2. **DNS:** registro A `proxy.flyweb.lamosquita.net` → 51.91.19.170 en ns1, ns2 y ns3.
3. **Certificado:** `certbot certonly --apache --expand` con los cuatro nombres.
4. **Apache:** `a2enmod rewrite`; `install -d /var/log/flyweb/proxy /var/www/FlyWeb/proxy-vacio`; añadir el vhost a
   `lamosquita.conf`; `apachectl configtest` y recargar.
5. **Conexión cifrada con Google:** el proxy habla con Google por TLS y verifica su certificado con los de la
   distribución (`SSLProxyVerify require` contra `/etc/ssl/certs/ca-certificates.crt`). Comprobar que existe
   (`ls -l /etc/ssl/certs/ca-certificates.crt`; si no, `apt install ca-certificates`) y que `proxy_http` y `ssl` están
   activos (`apache2ctl -M | grep -E 'proxy_http|ssl|rewrite'`). No hace falta abrir puertos de entrada nuevos: solo
   el 443, ya abierto; la salida a Google es por 443.
6. **Comprobar desde ns2:** `curl -sI https://dl.google.com/edgedl/chrome/dict/es-es-3-0.bdic` debe dar 200, no una
   redirección; si redirige, se cambia el destino de los diccionarios. Después,
   `curl -s -o /dev/null -w '%{http_code}\n' 'https://proxy.flyweb.lamosquita.net/edgedl/chrome/dict/es-es-3-0.bdic'`
   debe dar 200, y `https://proxy.flyweb.lamosquita.net/` debe dar 404.
- **Riesgo asumido:** quien conozca la URL puede gastar la cuota de la clave, porque el navegador no manda la clave de
  servicio a estos hosts. Vigilar el uso en la consola de Google Cloud.

## Propuesta: `sync.flyweb.lamosquita.net` (NUBE, 03-10; pendiente del HUMANO)

Sincronización de FlyWeb (F7.5): delante de `flyweb-sync` (`../sync/`, servicio `../systemd/flyweb-sync.service`, solo
en `127.0.0.1:8295`). Fichero: `apache/flyweb-sync-vhost.conf`. Solo `POST /v2/command/`; lo demás, 404.

- **Privacidad:** igual que `proxy.`: sin IP en accesos ni errores, sin consulta en el registro, y `flyweb-sync` no
  recibe la IP. Los datos van cifrados de extremo a extremo por el navegador.
- **Probado en NUBE** (Apache 2.4.58 delante del binario): sincronización entre dos «Macs» de la misma cadena; otra
  cadena no ve nada; 401 sin token o con firma falsa; 404 en el resto (también con `..`); 301 en el puerto 80; 0 IP
  en los registros.
- **Pasos:** en `../sync/README.md`, «Instalar en ns2» (DNS, `certbot --expand`, binario, servicio, vhost).
