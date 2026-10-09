# Estado de los servicios de FlyWeb en ns1 y ns2 (SV.2)

Informe de SERVIDOR-LOCAL (SERVIDOR-LOCAL-2), **09-10-2026, ~13:55 (hora peninsular)**. Sustituye al del 05-10 (auditoría E1),
que quedó atrás. **Fuente: ns1 y ns2**, mirados desde dentro como usuario `servidor` en tres sesiones SSH de solo
lectura, una por paso y nunca a la vez (ns2, ns1 y otra vez ns2); comprobaciones web desde el propio ns2 con
`--resolve …:443:127.0.0.1`. Cambios aplicados, uno a uno: [`CAMBIOS.md`](CAMBIOS.md). Lo que no se ha vuelto a mirar
hoy va marcado «(05-10)».

## Servicios

| Servicio | En producción | Qué falta |
|---|---|---|
| `flyweb.lamosquita.net` (web) | 200. Diseño del HUMANO (06-10), JS en `js/` root:root instalados por el HUMANO. La portada enlaza la **1.8.1**. En `descargas/`: 1.0 (sin enlazar), 1.2 a 1.8.1. Registros con IP, 14 días | Publicar la **1.9** (ver «Siguiente») |
| `flyweb-web-auto` | Temporizador de usuario de `servidor`, cada 10 min; `~servidor/bin/flyweb-web-auto` `61dccb69…` (= repo). Última pasada 13:46: *«esperando: appcast 1.9 (157.64.14), main describe 1.8.1 (157.64.13); no se publica nada»*. Es lo correcto: `VERSION` de `main` aún es la 1.8.1 | Se publica sola ≤ 10 min después de fusionar el PR de la 1.9 |
| `flyweb-cifras` | Temporizador cada hora; `~servidor/bin/flyweb-cifras` `6ad19661…` (= repo); sube `cifras.csv` con `flyweb-desplegar cifras` (última subida 13:16). `cifras.csv` 200 | — |
| `components.` (go-update) | `flyweb-components` activo, solo `127.0.0.1:8192`; binario `0e776013…`; unidad `84d379be…` (= repo). `_estado.json` 200 | — |
| `proxy.` (Safe Browsing, diccionarios) | Raíz 404. Safe Browsing funciona desde el 05-10 con clave nueva (IPv4 + IPv6 /64) (05-10) | — |
| `updates.` (Sparkle) | `stable/appcast.xml` 200; anuncia **1.9, 1.8.1, 1.8, 1.7.1 y 1.7**. En `updates/`: 1.2 a 1.9 (**10 DMG, el límite**). `stable/` es de `flywebsubida` (lo escribe bak) | Ver «Siguiente» (límite de 10 DMG) |
| `sync.` (flyweb-sync) | `flyweb-sync` activo, solo `127.0.0.1:8295`; binario `6b690b21…`; unidad `e9b1b783…` (= repo). Raíz 404. En uso real | Copia de `sync.db` en bak: decisión del HUMANO (05-10) |
| DNS (ns1) | `named` activo. Zona `lamosquita.net` `e46b2ca9…`, serie **2026100501**, `named-checkzone` OK. `flyweb.`, `components.`, `proxy.`, `updates.` y `sync.` → 51.91.19.170; sin AAAA | — |

Certificado `flyweb.lamosquita.net` (certbot, ECDSA): **caduca el 3-01-2027 13:09 UTC** (86 días hoy). Cubre 5 nombres
(`flyweb.`, `components.`, `proxy.`, `updates.`, `sync.`) (05-10). Renovación: temporizador de certbot, y `certbot renew
--dry-run` correcto el 05-10 (HUMANO). fail2ban activo con 13 jaulas; apache con `configtest` en Syntax OK.

## Qué coincide con el repo

| | Producción (09-10) | Repo |
|---|---|---|
| `/usr/local/sbin/flyweb-desplegar` | `e4faf154…` | `acceso/flyweb-desplegar`: **igual** |
| `~servidor/bin/flyweb-web-auto` | `61dccb69…` | `web-auto/flyweb-web-auto`: **igual** |
| `~servidor/bin/flyweb-cifras` | `6ad19661…` | `cifras/flyweb-cifras`: **igual** |
| `/etc/systemd/system/flyweb-components.service` | `84d379be…` | `systemd/flyweb-components.service`: **igual** |
| `/etc/systemd/system/flyweb-sync.service` | `e9b1b783…` | `systemd/flyweb-sync.service`: **igual** |
| `/etc/logrotate.d/flyweb` | `418ab467…` | `e0/logrotate/flyweb`: **igual** |
| `/opt/flyweb-components/flyweb-components` | `0e776013…` | `CAMBIOS.md`: igual |
| `/opt/flyweb-sync/flyweb-sync` | `6b690b21…` | `CAMBIOS.md`: igual |
| `lamosquita.conf` (`/etc/apache2/sites-available/`) | `1e63fc85…` (tras E2-05) | `CAMBIOS.md`: igual. Se comparte con otros sitios del HUMANO: de FlyWeb solo se toca lo que ponen los `e2/*.sh` |
| `sudo -l` de `servidor` | `apachectl configtest`, `reload apache2`, `daemon-reload`, `restart` de `flyweb-components` y `flyweb-sync`, `start`/`stop`/`enable`/`disable` de `flyweb-sync`, `sudoedit` de `lamosquita.conf`, las dos unidades y `logrotate.d/flyweb`, `ss -ltnp`, `certbot certificates`, `fail2ban-client status`, `cscli decisions list`, `ls -l /var/lib/private/flyweb-sync/` y `flyweb-desplegar`. **Sin `apachectl -S`** | `acceso/sudoers-ns2` `71c123e7…` (las mismas órdenes) |
| Ficheros de claves | `/etc/apache2/flyweb-{components,proxy}-keys.conf`, root 0600 (no legibles por `servidor`) | Fuera del repo (modelos `.ejemplo`) |

Privacidad (comprobada hoy): **0 direcciones IPv4** en los registros de `components`, `proxy`, `updates` y `sync`; los
registros de FlyWeb listados son `0640 root:adm`; `/var/log/flyweb-deploy/desplegar.log` existe y registra cada despliegue.

## Hallazgos del 05-10, uno a uno

1. **IP de cliente en un registro «sin IP»:** resuelto (E2-01); hoy, 0 IP en esos cuatro registros.
2. **Appcast con versiones malas:** resuelto el 05-10 (157.64.2 y .3 retiradas; firmador con `retirar`).
3. **Sobrante en el vhost de `components.`:** resuelto (E2-01).
4. **Registros legibles por cualquier usuario:** resuelto (`create 0640 root adm`; los actuales, también).
5. **IPv6 de ns2** (`2001:41d0:203:54aa::/64` es la *Subnet-Router anycast*, RFC 4291): sin cambios; HUMANO, sin prisa, antes de publicar AAAA.
6. **Sin rastro de despliegue:** resuelto; `desplegar.log` activo.
7. **Incidente del 05-10 (`apachectl -S`):** resuelto con clave nueva y sudoers sin `-S` (comprobado hoy con `sudo -l`). La clave de servicio de `components.`: decisión del HUMANO.

## Siguiente

- **Publicar la 1.9:** firmada en bak y en el appcast; falta fusionar el PR #112 (`local/web-1.9`), que sube `VERSION`. Lo hace el HUMANO o PUBLICACIÓN. `web-auto` espera, correcto. Si tras fusionar no publica en 10 min: registro en `~servidor/.local/state/flyweb-web-auto/registro.log`.
- **Límite de 10 DMG en `updates/`:** ya están los 10 (1.2 a 1.9). Con la 1.10 hay que quitar el más antiguo con `flyweb-desplegar borrar` (SERVIDOR-LOCAL, tras la subida de PUBLICACIÓN y con el appcast ya sin esa versión), no a mano.
- **PR #99** (borrador, COORDINACIÓN): privacidad con `sync.` y `web-auto` que se para si un JS difiere de `main`. Al fusionarse, reinstalar `~servidor/bin/flyweb-web-auto` (comprobar suma) y anotarlo.
- **E2 nuevo, a proponer:** que `updates.` sirva solo `.dmg` y `stable/appcast.xml` (hoy sirve cualquier fichero de su carpeta).
- **Puntos del auditor sin decidir (HUMANO):** que `web-auto` vigile en cada pasada el DMG y las páginas publicadas (hoy sale antes si nada cambió); quitar `FW_EDITAR` o vhosts en `flyweb.conf` propio; `$INCLUDE` para que `servidor` no edite toda la zona; `servidor` fuera de `adm`; claves fuera de los `Define`. Los que tocan sudoers o accesos, solo con orden escrita del HUMANO.
- **Salvaguarda contra baneos** puesta por el HUMANO y el auditor el 07-10 en los tres servidores: falta el detalle para anotarlo en `CAMBIOS.md`.
- **Sudo de `claude` en bak:** el HUMANO lo limitó el 07-10 a `systemctl start flyweb-firma.service`; no hace falta para publicar.
