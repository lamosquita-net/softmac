# Registro de cambios en ns2 (y bak) de los servicios de FlyWeb

Exigido por `docs/SERVIDOR.md` §2.6: cada ejecución deja el commit aplicado, las comprobaciones y cómo se deshace.
Lo lleva SERVIDOR; lo lee el agente de auditoría. Empieza el 05-10-2026: lo anterior se ha **reconstruido** de las
notas del repo (`e0/README.md`, `docs/TAREAS.md`, README de cada servicio), no de registros de ns2.
`/var/log/flyweb-deploy/` (la otra mitad del rastro) no existe todavía: llega con el ejecutor `flyweb-deploy`.

| Fecha | Máquina | Quién (permiso) | Cambio | Commit / suma | Comprobado | Deshacer |
|---|---|---|---|---|---|---|
| 02-10 | ns1-ns3, ns2 | HUMANO | E0: A de `flyweb.`, `updates.`, `components.`; certificado; seis vhost en `lamosquita.conf`; clave de servicio de `components.`; `proxy_http` | `e0/apache/flyweb-vhosts.conf` | `configtest` sin avisos; `/extensions` 403 sin clave, 503 con ella | No anotado |
| 03-10 | ns2 | HUMANO | `flyweb-components` (go-update) en `/opt/flyweb-components` | release `go-update`; suma no anotada en el repo | `README.md`: catálogo con 9 elementos, solo `127.0.0.1:8192`, 403 sin clave | `systemctl disable --now`, borrar unidad y `/opt/flyweb-components` |
| 03-10 | ns1, ns2 | LOCAL (HUMANO) | `proxy.`: A (serie 2026100301), carpetas, vhost al final de `lamosquita.conf`, `certbot --expand` (4 nombres), `SSLProxyVerifyDepth 5` | `e0/apache/flyweb-proxy-vhost.conf` | `.bdic` 200, raíz 404, `/v4` sin clave 404, sin IP | Copias `lamosquita.conf.bak-20261003-proxy{,2}`, `lamosquita.net.hosts.bak-20261003-proxy` |
| 03-10 | ns2 | HUMANO | Clave de Safe Browsing en `/etc/apache2/flyweb-proxy-keys.conf` | — (fuera del repo) | Google responde 403: ns2 sale por IPv6 y la clave solo admite la IPv4 | Borrar el fichero y recargar |
| 03-10 | ns2 | LOCAL (HUMANO) | Rotación diaria, 7 días, de `/var/log/flyweb` | No anotado | No anotado | No anotado |
| 03-10 | bak → ns2 | LOCAL (HUMANO) | Firmador de componentes con espejo de Google (`firmar.mjs --google`) | `0f49ac71` | `_estado.json` 0 fallos; go-update recarga 15 elementos | Copia de los anteriores en `~claude/flyweb-firma-src/f22-20261003-1620/anterior` (bak) |
| 04-10 | ns2 | LOCAL (HUMANO) | Web: FlyWeb 1.0 en `flyweb.lamosquita.net` (descarga y privacidad provisionales) | `FlyWeb/web/` | 200, tipos correctos | No anotado |
| 04-10 | ns2 | LOCAL (HUMANO) | `/etc/logrotate.d/flyweb`: la web (con IP) pasa a 14 días | No en el repo (`e0/logrotate/flyweb` dice 7) | — | Copia en `/var/backups/` |
| 04-10 | bak, ns2 | LOCAL (HUMANO) | Actualizaciones: firmador EdDSA en bak, usuario `flywebsubida` en ns2 con `rrsync -wo /var/www/FlyWeb/updates`, solo desde la IP de bak | `ff67f5e` | Escribe en `stable/` y no sale de su carpeta | No anotado |
| 04/05-10 | bak → ns2 | HUMANO | Actualizaciones: publicada la 1.1 (`157.64.2`); tenía fallos por la caché de la versión anterior y se corrigió publicando la 1.1.1 (`157.64.3`), sin retirar la 1.1 | DMG aprobados en `/etc/flyweb-firma/actualizaciones-aprobadas` (bak); sumas no anotadas en el repo | 05-10, HUMANO: un Mac con la 1.1 ve el aviso, reinicia y queda en 1.1.1 (`157.64.3`) con los fallos corregidos. **Primera actualización completa por Sparkle** | Publicar una versión posterior (Sparkle no baja de versión); para pausar, el appcast anterior (`actualizaciones/README.md`) |
| 05-10 | ns2 | LOCAL (HUMANO) | Actualizaciones: la 1.1 retirada del appcast (02:28) y, tras sustituir LOCAL por error el DMG de la 1.1.1 ya firmado, appcast de nuevo solo con la 1.0.1 (12:00); el HUMANO firma la **1.1.2** (`157.64.4`) | `FlyWeb/servidor/actualizaciones/README.md` | Firma EdDSA comprobada contra el DMG; una 1.0.1 la detecta | Appcasts anteriores en `/var/backups/flyweb-appcast-*-20261005.xml` |
| 05-10 | ns2 | LOCAL (HUMANO, SV.3) | Web: FlyWeb **1.1.2** en `flyweb.lamosquita.net` (`descargas/FlyWeb-1.1.2.dmg` copiado de `updates/`, supermosquita:lamosquita 0644; portada nueva). La 1.0 se queda en `descargas/` sin enlazar | PR #73 (`FlyWeb/web/index.html`) | Desde ns2: portada enlaza la 1.1.2 con su SHA-256; DMG 200, `application/x-apple-diskimage`, SHA-256 igual | Portada anterior en `/var/backups/flyweb-web-index-1.0-20261005.html` |
| (pendiente) | ns1-ns3, ns2 | HUMANO | SV.1: `sync.` (DNS, certificado, `flyweb-sync`, vhost) | `sync/instalar-ns2.md` | — | En `instalar-ns2.md` |
