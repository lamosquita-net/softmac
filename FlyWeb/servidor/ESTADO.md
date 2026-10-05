# Estado de los servicios de FlyWeb en ns2 (SV.2)

Informe de SERVIDOR, 05-10-2026. **Fuente: el repo** (`e0/`, README de cada servicio, `docs/TAREAS.md`). No se ha
podido mirar ns2 desde fuera: la red de la sesión de SERVIDOR no deja salir a `*.flyweb.lamosquita.net`
(pendiente de `docs/SERVIDOR.md` §6). Cambios aplicados: [`CAMBIOS.md`](CAMBIOS.md).

## Servicios

| Servicio | En producción | Qué falta |
|---|---|---|
| `flyweb.lamosquita.net` (web) | Sí, desde el 04-10: FlyWeb 1.0 (DMG + SHA-256), descarga y privacidad provisionales. Registros **con IP**, 14 días | Diseño (W1); revisión legal del texto de privacidad; que la página cuente sync. antes de abrirlo a otros |
| `components.` (go-update + firmador en bak) | Sí, desde el 03-10: 15 elementos (Shields propios + 7 de Google en espejo); `_estado.json` con 0 fallos | 3 componentes de Brave sin servir (Local Data Updater, NTP Background Images, HTTPS Everywhere; decide NUBE). Suma del binario en producción sin anotar |
| `proxy.` (Safe Browsing, diccionarios) | Sí, desde el 03-10: diccionarios funcionan | **Safe Browsing no funciona**: Google da 403 porque ns2 sale por IPv6 y la clave solo admite la IPv4. Falta que el HUMANO añada la IPv6 a la restricción de la clave |
| `updates.` (Sparkle) | Vhost y subida desde bak (04-10) listos; firmador y clave EdDSA en bak | Primera versión publicada así (1.0.1, a mano una vez). Copia cifrada de `actualizaciones.pem` fuera de bak (**si se pierde, ningún FlyWeb instalado acepta actualizaciones**) |
| `sync.` (flyweb-sync) | No. El nombre aún no resuelve | SV.1: `sync/instalar-ns2.md` |

## Riesgos, por prioridad

1. **Clave EdDSA de actualizaciones sin copia** fuera de bak. Pérdida = reinstalar a mano en cada Mac. Es lo más
   caro de todo lo pendiente y lo más barato de evitar.
2. **Safe Browsing apagado de hecho** en todos los FlyWeb mientras dure el 403. La protección contra phishing no
   llega. Además, ns2 sale por la *Subnet-Router anycast* del /64 (`…:54aa::`, RFC 4291 §2.6.1), poco adecuada
   para un host (los routers del enlace también responden a ella): conviene una fija propia (p. ej. `::1`) y esa en la
   restricción de la clave.
3. **Lo que hay en ns2 y lo que dice el repo ya no coincide** (contra el E1 de la carta): `e0/logrotate/flyweb` dice 7
   días y ns2 tiene 14 para la web; ni la suma del binario de go-update ni la del vhost de `proxy.` instalado están
   anotadas. Sin ejecutor (`flyweb-deploy`) ni `/var/log/flyweb-deploy/`, el rastro es solo lo que se anota a mano.
4. **Releases mutables**: `go-update` y `flyweb-sync` se reescriben en cada fusión (`--clobber`); una instalación que
   compara con la `.sha256` de la propia release no prueba nada. Hay que fijar la suma en el repo (hecho para sync).
5. **Cuota de la clave de Safe Browsing**: cualquiera que conozca `proxy.` puede gastarla (riesgo ya asumido; vigilar).
6. **fail2ban no mira los puertos 80** de ningún sitio de ns2 (solo CrowdSec). Es del agente de auditoría.
7. **Acceso entrante nuevo a ns2**: `flywebsubida` (SSH desde bak, `rrsync` de solo escritura en una carpeta). Está
   bien acotado, pero conviene que la auditoría lo conozca y que la clave sea `restrict` en `authorized_keys`.

## Qué propongo (por orden)

1. HUMANO: copia cifrada de `actualizaciones.pem` fuera de bak.
2. HUMANO: IPv6 de ns2 en la restricción de la clave de Safe Browsing (o una IPv6 fija de salida), y LOCAL repite la
   prueba de `/v4/threatListUpdates:fetch`.
3. HUMANO: SV.1 (sync), con `sync/instalar-ns2.md`.
4. SERVIDOR (E1): poner al día `e0/` con lo que hay en ns2. Para eso, el HUMANO pasa las sumas (no son secretas):
   `sha256sum /opt/flyweb-components/flyweb-components /etc/logrotate.d/flyweb /etc/systemd/system/flyweb-*.service`.
5. Después: ejecutor `flyweb-deploy` (E2), para que el rastro deje de ser manual.
