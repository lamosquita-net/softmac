# Agente SERVIDOR — carta y reglas

Agente de Claude (sesión en la nube, como NUBE) para los servicios internos de FlyWeb en **ns2.lamosquita.net**.
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

1. **Producción primero no se toca.** Nada se ejecuta en ns2 sin aprobación explícita del HUMANO para ese cambio
   concreto, mientras dure la supervisión (etapas E0–E2).
2. **Todo pasa por el repo.** Configuración, scripts y documentación viven en `FlyWeb/servidor/`. Un cambio es un PR;
   lo que se ejecuta en ns2 es siempre un commit concreto e identificable.
3. **Sin acceso entrante nuevo.** El agente no entra en ns2 por SSH ni por ningún otro medio (§4).
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

Clases de cambio autorizadas en E3: **ninguna todavía**.

## 4. Cómo se ejecuta en ns2 sin que el agente entre

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
