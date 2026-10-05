# Estado de los servicios de FlyWeb en ns2 (SV.2, auditoría E1)

Informe de SERVIDOR-LOCAL, **05-10-2026, 14:30** (puesto al día a las 14:50, tras E2-01). **Fuente: ns1 y ns2**, mirados desde dentro como usuario `servidor` (solo
lectura; comprobaciones web desde el propio ns2 con `--resolve …:443:127.0.0.1`). Cambios aplicados: [`CAMBIOS.md`](CAMBIOS.md).

## Servicios

| Servicio | En producción | Qué falta |
|---|---|---|
| `flyweb.lamosquita.net` (web) | 200. Ofrece **FlyWeb 1.1.2** (LOCAL, SV.3, 05-10 14:01; `descargas/FlyWeb-1.1.2.dmg`; la 1.0 sigue en `descargas/` sin enlazar). Registros con IP, 14 días | — |
| `components.` (go-update) | `flyweb-components` activo y habilitado, solo `127.0.0.1:8192`; binario `0e776013…` (= release `go-update` anotada); unidad = `systemd/flyweb-components.service` (`84d379be…`). `/extensions` sin clave → 403; `_estado.json` 200, firma de bak de las 05:27 | Nada urgente; ver hallazgos 1 y 3 |
| `proxy.` (Safe Browsing, diccionarios) | **Safe Browsing funciona desde el 05-10, 14:12** (clave nueva con IPv4 e IPv6 de ns2; `threatListUpdates:fetch` → 200). Raíz 404 | — |
| `updates.` (Sparkle) | appcast 200. DMG en `updates/`: 1.0.1, 1.1, 1.1.1, 1.1.2 | Ver hallazgo 2 |
| `sync.` (flyweb-sync) | **No**: sin DNS, sin unidad ni binario | SV.1 |

Certificado `flyweb.lamosquita.net`: 4 nombres (`flyweb.`, `components.`, `proxy.`, `updates.`), ECDSA, caduca el **1-01-2027**
(88 días). Para `sync.` habrá que ampliarlo (HUMANO). DNS en ns1 (`/etc/bind/zones/lamosquita.net.hosts`, `7a9fc590…`): A de
los cuatro nombres → 51.91.19.170, TTL 3600; sin AAAA; sin `sync.`.

## Qué coincide con el repo (E1)

| | Producción | Repo |
|---|---|---|
| Vhost de FlyWeb en `lamosquita.conf` (`c2dfcefd…`) | 8 vhost (80 y 443 de web, `updates.`, `components.`; `proxy.`) | `e0/apache/flyweb-vhosts.conf` + `flyweb-proxy-vhost.conf`: **iguales** salvo comentarios (tras este PR) |
| `/etc/systemd/system/flyweb-components.service` | `84d379be…` | `systemd/flyweb-components.service`: **igual** |
| `/etc/logrotate.d/flyweb` | `2d7266ee…` | `e0/logrotate/flyweb`: **igual** (tras este PR) |
| `/opt/flyweb-components/flyweb-components` | `0e776013…` | `CAMBIOS.md`: igual |
| Módulos | `ssl`, `headers`, `http2`, `proxy`, `proxy_http`, `rewrite` | `e0/README.md` |
| Ficheros de claves | `/etc/apache2/flyweb-{components,proxy}-keys.conf`, root 0600 | Fuera del repo (modelos `.ejemplo`) |

## Hallazgos, por prioridad

1. **[Aplicado E2-01, 14:45; falta borrar la línea antigua]** **Una IP de cliente en un registro «sin IP».** `components/apache_error.log` tiene una línea `AH01095` (mod_proxy:
   «prefetch request body failed … from <IP>») con una **IP pública** de un cliente (05-10, 02:06). `ErrorLogFormat` quita
   `[client …]`, pero mod_proxy mete la IP **dentro del mensaje**. Rompe la promesa de privacidad, aunque sea raro (cliente
   que corta la conexión) y se borre a los 7 días. **Propuesta E2:** `LogLevel proxy:crit proxy_http:crit` en los vhost de
   `components.`, `proxy.` y `sync.` (o filtrar el mensaje), y borrar esa línea.
2. **El appcast lista versiones malas.** bak vuelve a escribir la 1.1 (retirada: rompía perfiles) y la 1.1.1 con la firma de
   un DMG que ya no existe (`length` 163576123; el DMG actual mide 163573570). Sparkle coge la 1.1.2, así que hoy no afecta;
   pero si alguna vez se retirara la 1.1.2, los Mac recibirían la 1.1.1 con firma mala (fallo) o la 1.1. **HUMANO, en bak:**
   quitar 157.64.2 y 157.64.3 del estado de `firmar-actualizacion.mjs`.
3. **[Aplicado E2-01]** **Sobrante en el vhost de `components.`:** un bloque de `updates.` (tipo `.dmg`, caché de DMG y `appcast.xml`). No tiene
   efecto. Reproducido en `e0/` con un comentario; **propuesta E2:** quitarlo.
4. **[Aplicado E2-01 para los ficheros nuevos; los actuales siguen 0644 hasta rotar o el `chmod` del HUMANO]** **Registros de FlyWeb legibles por cualquier usuario de ns2** (`/var/log/flyweb/*/*.log`, root 0644; los de la web
   llevan IP). ns2 aloja más sitios y usuarios (`sftp_users`). **Propuesta E2:** `create 0640 root adm` en
   `logrotate/flyweb` y `chmod 0640` de los actuales.
5. **IPv6 de ns2:** la única global es `2001:41d0:203:54aa::/64` (la *Subnet-Router anycast*, RFC 4291 §2.6.1). Funciona,
   pero conviene una propia (p. ej. `::1`) antes de publicar AAAA. HUMANO, sin prisa.
6. **Sin rastro de despliegue:** `/var/log/flyweb-deploy/` no existe hasta el primer uso de `flyweb-desplegar`.
7. **Incidente del 05-10:** `apachectl -S` imprimió las claves (`CAMBIOS.md`). Resuelto con una clave de Safe Browsing nueva;
   `apachectl -S` quitado de `sudoers-ns2` en el repo; **en ns2 sigue instalado el antiguo** (14:50): lo instala el HUMANO. La clave de servicio de `components.`: decisión del
   HUMANO.

## Siguiente

- HUMANO: instalar el `sudoers-ns2` de este PR; bak (hallazgo 2); decidir la clave de servicio.
- SERVIDOR-LOCAL, tras la revisión de SERVIDOR-NUBE: PR E2 con los hallazgos 1, 3 y 4; SV.1 y SV.3 cuando el tablero los pase.
