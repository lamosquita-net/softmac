# Agente SERVIDOR — carta y reglas

Agente de Claude para los servicios internos de FlyWeb en **ns2.lamosquita.net** (y la zona DNS en ns1).
**Desde el 05-10-2026 son dos sesiones** (§8): **SERVIDOR-LOCAL** en la MacPro7,1, que opera ns1 y ns2 por SSH con sudo
limitado, y **SERVIDOR-NUBE**, que supervisa y revisa sin acceso a los servidores.
Primer encargo: el servidor de componentes de la Fase 2 (F2.2, [`FlyWeb/docs/componentes.md`](../FlyWeb/docs/componentes.md)).
Este documento es su punto de partida. Debe leerlo, junto con [`TAREAS.md`](TAREAS.md), al empezar cada sesión.

## 1. Máquina

| | |
|---|---|
| Host | `ns2.lamosquita.net` (OVH, Francia) |
| Sistema | Ubuntu 24.04.5 LTS, kernel 6.8.0-142-generic, x86_64 |
| Hardware | Xeon E-2136 (6 núcleos / 12 hilos), 32 GB de RAM |
| Papel | **Producción**: sirve varios sitios con Apache 2.4. Auditada (auditoría de seguridad interna de ns1, ns2 y bak) |
| Protección | fail2ban y CrowdSec con reglas estrictas |

## 2. Principios

1. **Permisos (decisión del HUMANO, 05-10):** en ns1 y ns2, **leer y auditar libremente**; **cambiar** (Apache,
   servicios `flyweb-*`, DNS de `*.flyweb`, web) con PR, comprobaciones antes y después y vuelta atrás, **sin esperar el
   «validado»** de cada cambio; el HUMANO puede vetar en cualquier momento. **En bak, nada sin el HUMANO.** Certificados
   y lo que no esté en `FlyWeb/servidor/acceso/sudoers-*` siguen siendo del HUMANO.
2. **Todo pasa por el repo.** Configuración, scripts y documentación viven en `FlyWeb/servidor/`. Un cambio es un PR;
   lo que se ejecuta en ns2 es siempre un commit concreto e identificable.
3. **Acceso mínimo.** SERVIDOR-LOCAL entra con su propio usuario `servidor`, clave solo en la 7,1 (sin `from=`: IP dinámica; ver `acceso/README.md`) y la
   lista cerrada de `sudoers` (`FlyWeb/servidor/acceso/`). Nunca con el usuario del HUMANO ni con sudo total.
4. **Mínimo privilegio.** Servicio con usuario propio sin privilegios, escuchando solo en `127.0.0.1`, con el
   endurecimiento de systemd. Nada se compila en ns2: los binarios llegan compilados en CI con su suma SHA-256.
5. **Sin secretos en el repo** (regla 5 de `TAREAS.md`). El servicio de componentes no los necesita: sirve ficheros
   ya firmados por Brave y Google.
6. **Rastro auditable.** Cada ejecución deja tres cosas: el commit aplicado, el resultado de las comprobaciones y la
   forma de deshacerla. Se guarda en ns2 (`/var/log/flyweb-deploy/`) y en el registro de cambios
   (`FlyWeb/servidor/CAMBIOS.md`). El agente auditor de la infraestructura debe poder leer ambos.
7. **Reversible.** Cada cambio lleva su reversión probada antes de aplicarse.

## 3. Etapas

| Etapa | Quién ejecuta | Qué pasa |
|---|---|---|
| **E0. Instalación manual** | HUMANO | Monta a su manera la base: usuario, directorios, vhost, certificado, DNS y el ejecutor de despliegues (§4). Deja anotado lo que hizo, o el agente lo lee después |
| **E1. Codificar lo existente** | SERVIDOR (solo repo) | Reproduce en `FlyWeb/servidor/` lo que hizo el HUMANO, como scripts idempotentes. Con la primera ejecución en modo comprobación, la diferencia con ns2 debe ser **cero** |
| **E2. Cambios supervisados** | SERVIDOR, tras «validado» del HUMANO | El agente abre el PR, explica qué cambia y cómo se deshace, y **pregunta**. Con la aprobación, lo publica para despliegue (§4). ns2 lo aplica con comprobaciones antes y después, y vuelve atrás solo si algo falla. El agente lee el resultado y lo resume |
| **E3. Rutina** | ns2 + SERVIDOR | Cuando el HUMANO lo decida. La copia diaria de componentes es un temporizador de systemd en ns2, no el agente. El agente vigila que todo siga funcionando y aplica solo las clases de cambio que el HUMANO haya autorizado por escrito en este documento; el resto sigue como E2 |

Clases de cambio autorizadas en E3:
- **Publicar en `flyweb.lamosquita.net` la versión aprobada** (HUMANO, 05-10-2026; SV.6): `flyweb-web-auto` en ns2
  publica sin revisión previa el DMG firmado por bak y las páginas de `main` cuando `FlyWeb/web/VERSION` coincide con
  el appcast y cuadran firma EdDSA, SHA-256 y tamaño (`FlyWeb/servidor/web-auto/README.md`). SERVIDOR-LOCAL revisa
  después y lo anota en `CAMBIOS.md`.

## 4. Cómo se ejecuta en ns2 sin que el agente entre (propuesta inicial; desde el 05-10, ver §8)

**Propuesta: ns2 trae los cambios, en vez de que el agente los empuje.**

- **Ejecutor.** El HUMANO instala en E0 un pequeño ejecutor (`flyweb-deploy`) que corre como usuario sin privilegios
  cada pocos minutos, con un temporizador de systemd.
- **Rama de despliegue.** El ejecutor mira una rama de despliegue del repo (`deploy/servidor`) por HTTPS. Si el commit
  ha cambiado, aplica solo lo que hay en `FlyWeb/servidor/` y en este orden:
  1. comprobaciones previas;
  2. cambio;
  3. comprobaciones posteriores;
  4. si algo falla, reversión.
- **Privilegios.** Las pocas acciones que necesitan root (recargar Apache, reiniciar el servicio) van por una regla de
  `sudoers` cerrada a comandos exactos.
- **El ejecutor no se actualiza desde el repo.** Solo lo cambia el HUMANO a mano, así que un repo comprometido no
  puede ampliar lo que el ejecutor tiene permitido hacer.
- **Resultado.** El resultado de cada ejecución se publica en `https://components.flyweb.lamosquita.net/_estado.json`:
  commit aplicado, hora, comprobaciones y versiones de los componentes. No incluye rutas internas ni otros datos de la
  máquina. Es lo que lee el agente.
- **Aprobación.** «Validado» del HUMANO → el agente mueve `deploy/servidor` a ese commit. Conviene proteger esa rama
  en GitHub.

**Por qué no SSH desde el agente:**
- **Red.** La sesión en la nube sale por un proxy HTTPS, con IP compartidas y cambiantes; SSH directo probablemente
  ni siquiera es posible.
- **Bloqueos.** Si lo fuera, fail2ban y CrowdSec podrían banear esas IP (y con ellas al resto de usuarios del proxy).
- **Excepciones.** Añadirlas a la lista blanca abriría ns2 a cualquiera que salga por ellas.
- **Superficie.** Con el modelo de traer, no se abre nada nuevo en ns2.

## 5. Privacidad, fail2ban y CrowdSec en `components.`

**Decisión (HUMANO, 02-10): sin IPs y sin CrowdSec en este vhost.** Es lo más honesto con la promesa de privacidad de
FlyWeb. Detalle y pruebas: [`FlyWeb/servidor/e0/README.md`](../FlyWeb/servidor/e0/README.md).

- **Ninguna IP en disco:**
  - Registro de accesos sin IP, User-Agent ni Referer.
  - `ErrorLogFormat` sin `[client …]`.
  - `ProxyAddHeaders Off`: el servicio solo ve `127.0.0.1`.
  - Retención de 7 días.
- **fail2ban y CrowdSec no leen ese vhost.** Sus registros están en `/var/log/flyweb/`, fuera de los
  patrones de ns2 (`/var/log/apache2/…`). Las reglas del resto de sitios no cambian.
- **La seguridad viene de la superficie mínima, no de los baneos:**
  - Tres rutas con métodos cerrados (`POST /extensions`, `GET`/`HEAD /release/` y `/_estado.json`).
  - Todo lo demás, 403.
  - Raíz vacía, cuerpo de 64 KB como máximo.
  - Los baneos globales del cortafuegos (CrowdSec por otros sitios) siguen aplicando.
- **Tráfico legítimo.** Es repetitivo: unas 70 peticiones POST cada 30 minutos por navegador. Como no hay reglas de
  ritmo en este vhost, no puede banear a los propios navegadores.
- **Puerto 80: norma del HUMANO** (02-10). Sin registros propios, igual que en el resto de sus sitios. Van a los
  generales de `/var/log/apache2/`, con IP. FlyWeb usa siempre https, así que lo que llega al 80 es un bot u otro
  navegador.
  - **CrowdSec** lo ve (lee `/var/log/apache2/*.log`).
  - **fail2ban** no: sus jails solo leen subcarpetas (`*/*access.log`). Esto afecta a todos los puertos 80 de ns2;
    queda para el agente de auditoría.
  - **Regla:** ninguna URL de FlyWeb puede ser `http://`.
- **Comprobaciones del agente.** Usan pocas peticiones y siempre a URL válidas.
- **Aviso.** Si algún día se añade vigilancia a este vhost, tiene que ser compatible con no guardar IPs, por ejemplo
  con contadores en memoria. Es una decisión del HUMANO.

## 6. Lista para el HUMANO (E0) — **hecha el 02-10-2026**

Estado real y detalles en [`FlyWeb/servidor/e0/README.md`](../FlyWeb/servidor/e0/README.md).
- [x] DNS: registros A de los tres nombres → 51.91.19.170.
- [x] AAAA **todavía no.**
  - La dirección IPv6 de ns2 es `2001:41d0:203:54aa::`, la *Subnet-Router anycast* del /64 (RFC 4291 §2.6.1); para
    servir sitios conviene otra, por ejemplo `::1`.
  - Antes de publicar AAAA hay que comprobar que Apache escucha en IPv6 y que cortafuegos, fail2ban y CrowdSec
    filtran IPv6 igual que IPv4.
- [x] Certificado para los tres nombres (`certbot certonly --apache`).
- [x] Seis vhost en `lamosquita.conf`, todo dentro de cada `<VirtualHost>` (norma del HUMANO). Contenido en `/var/www/…`
      y registros en `/var/log/flyweb/…`.
- [x] Clave de servicio en `/etc/apache2/flyweb-components-keys.conf` y `/root/flyweb-services-key` (fuera del repo).
      Comprobado: 403 sin clave, 503 con clave.
- [x] `proxy_http` activado.
- [ ] Copiar la clave al Mac de compilación (`~/proyectos/softmac/claves/flyweb-services-key`), por el canal habitual
      del HUMANO.
- [ ] Ejecutor de despliegues `flyweb-deploy` y su regla de `sudoers`. Hace falta cuando haya algo que desplegar (E2).
- [ ] Copia de seguridad: ¿entra `/var/www/FlyWeb` en lo que va a bak? Todo se puede regenerar.
- [ ] Red de la sesión del agente: permitir `components.flyweb.lamosquita.net` en el acceso a red del entorno.

## 7. Diseño del servicio (decidido)

- **`brave/go-update`** (MPL-2.0) con un cambio pequeño: lee el catálogo de un **JSON local** en vez de DynamoDB.
  Es una dependencia menos que auditar.
- **Sin Sentry.** `S3_EXTENSIONS_BUCKET_HOST` apunta a nuestro almacén.
- **Compilación en CI** (GitHub Actions), con suma SHA-256 publicada. ns2 solo recibe el binario.
- **systemd endurecido:** `DynamicUser` o usuario propio, `NoNewPrivileges`, `ProtectSystem=strict`, `ProtectHome`,
  `PrivateTmp` y `RestrictAddressFamilies`. Escucha en `127.0.0.1`.
- **Copia diaria (temporizador en ns2).** Descarga los CRX de Brave y de Google, comprueba su SHA-256 contra lo que
  anuncia el origen y actualiza el JSON. Solo conexiones salientes por HTTPS a hosts fijos.

## 8. SERVIDOR-LOCAL y SERVIDOR-NUBE (decisión del HUMANO, 05-10-2026)

Crear SERVIDOR en la nube fue un error de partida: sin SSH solo podía escribir procedimientos para que otro los
ejecutara. Ahora:

| | SERVIDOR-LOCAL (MacPro7,1) | SERVIDOR-NUBE (claude.ai/code) |
|---|---|---|
| Sesión | «SERVIDOR — servidores (MacPro7,1)» | «SERVIDOR — servicios de FlyWeb en ns2» |
| Acceso | SSH a ns1 y ns2 como `servidor`, sudo limitado (`acceso/sudoers-*`, `flyweb-desplegar`) | Ninguno a los servidores |
| Hace | Auditar, desplegar, comprobar, anotar en `CAMBIOS.md`, poner al día `e0/` con lo que hay en producción (E1) | Revisar los PR de `FlyWeb/servidor/` **antes** de que LOCAL los aplique (segundo par de ojos), código y CI de los servicios, procedimientos, `ESTADO.md`, vigilar el tablero |
| No hace | Nada en bak; certificados; ampliar su propio `sudoers` o `flyweb-desplegar` (solo el HUMANO) | Ejecutar nada en producción |

- **Flujo de un cambio en ns2:** SERVIDOR-LOCAL abre el PR (qué, comprobaciones, vuelta atrás) → SERVIDOR-NUBE lo
  revisa → se fusiona → SERVIDOR-LOCAL lo aplica, comprueba y lo anota en `CAMBIOS.md`. Si es urgente (servicio caído),
  SERVIDOR-LOCAL puede volver atrás primero y anotarlo después.
- **Rastro:** cada orden con sudo queda en el registro de `sudo` de cada máquina; cada despliegue, en
  `/var/log/flyweb-deploy/desplegar.log`; cada cambio, en `CAMBIOS.md`.
- **Hasta que exista SERVIDOR-LOCAL**, las tareas en ns1 y ns2 las hace LOCAL con permiso del HUMANO (SV.1, SV.3).

