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

## 5. fail2ban y CrowdSec: lo que hay que comprobar antes de abrir `components.`

El servicio recibe **mucho tráfico legítimo y repetitivo**:
- Cada FlyWeb pregunta componente a componente: unas 70 peticiones POST cada 30 minutos (F1.6).
- Varios Mac detrás de la misma IP multiplican esa cifra.

Reglas que podrían banear a los propios navegadores:
- **Ritmo.** Límites de peticiones por IP.
- **Errores.** Escenarios de rastreo o sondeo. Un componente desconocido responde 404 o redirección, y un navegador
  con muchas listas regionales genera bastantes.
- **POST anómalos.** Filtros que miren cuerpos de POST con XML/JSON.

Antes de E2, el HUMANO y el agente revisan qué escenarios aplican a ese vhost. Si hace falta, se excluye `components.`
de los escenarios de ritmo (no de los de ataques) o se ajustan los umbrales para ese vhost, con el registro de cada
decisión. Las comprobaciones posteriores del agente usan pocas peticiones y siempre a URL válidas.

## 6. Lista para el HUMANO (E0)

- [ ] DNS `components.flyweb.lamosquita.net` → ns2, y certificado (certbot `--apache`).
- [ ] Usuario de sistema para el servicio (sin shell ni sudo) y otro para el ejecutor de despliegues.
- [ ] Directorios: servicio (`/opt/flyweb-components`), almacén de CRX, registros (`/var/log/flyweb-deploy`).
- [ ] Vhost con `proxy_http` hacia `127.0.0.1:<puerto>` y `/_estado.json` estático (modelo en `disenos.md` §4).
- [ ] Ejecutor `flyweb-deploy` y su regla de `sudoers` (el agente puede proponer el código; lo instala el HUMANO).
- [ ] Decisión sobre fail2ban/CrowdSec para ese vhost (§5).
- [ ] Copia de seguridad: ¿entra `/opt/flyweb-components` en lo que va a bak? Todo se puede regenerar desde Brave y
      Google, así que quizá baste con la configuración.
- [ ] Red de la sesión del agente: permitir `components.flyweb.lamosquita.net` en el acceso a red del entorno, para
      leer `_estado.json`.

## 7. Diseño del servicio (decidido)

- **`brave/go-update`** (MPL-2.0) con un cambio pequeño: lee el catálogo de un **JSON local** en vez de DynamoDB.
  Es una dependencia menos que auditar.
- **Sin Sentry.** `S3_EXTENSIONS_BUCKET_HOST` apunta a nuestro almacén.
- **Compilación en CI** (GitHub Actions), con suma SHA-256 publicada. ns2 solo recibe el binario.
- **systemd endurecido:** `DynamicUser` o usuario propio, `NoNewPrivileges`, `ProtectSystem=strict`, `ProtectHome`,
  `PrivateTmp` y `RestrictAddressFamilies`. Escucha en `127.0.0.1`.
- **Copia diaria (temporizador en ns2).** Descarga los CRX de Brave y de Google, comprueba su SHA-256 contra lo que
  anuncia el origen y actualiza el JSON. Solo conexiones salientes por HTTPS a hosts fijos.
