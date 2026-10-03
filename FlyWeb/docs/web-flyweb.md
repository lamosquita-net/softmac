# FlyWeb — Web `flyweb.lamosquita.net` y aviso legal (borrador, 03/10/2026)

Encargo del HUMANO: dejar por escrito qué tiene que tener la web pública de FlyWeb, para diseñarla (HUMANO) y montarla
(LOCAL), con el texto de privacidad que exige el RGPD por los servicios de ns2. **No soy abogado:** el texto legal es un
borrador para que lo revise quien lleve el RGPD de lamosquita.

## 1. Hoja de ruta de la web

La web ya existe como vhost en ns2 (`FlyWeb/servidor/e0`, `/var/www/flyweb.lamosquita.net`), registra la IP
(decisión del HUMANO) y hoy no tiene contenido definitivo.

| # | Página | Contenido | Quién | Depende de |
|---|---|---|---|---|
| W1 | Inicio | Qué es FlyWeb: navegador para Mac Intel con macOS 10.13–10.14 (y 10.15–12 sin garantía), basado en Chromium 116 y Brave 1.57, sin servicios de Brave; para quién es | HUMANO (diseño) → LOCAL | — |
| W2 | **Privacidad** | El texto de §2. Obligatoria antes de poner en producción el proxy | LOCAL | Revisión legal |
| W3 | Descarga | Enlace al `.dmg` firmado y notarizado, suma SHA-256, requisitos, notas de la versión | LOCAL | F0.5 (firma Developer ID y notarización), canal de actualizaciones (`updates.`) |
| W4 | Código y licencias | Enlaces a los repositorios (softmac, forks de brave-core y brave-browser), MPL-2.0 de los ficheros de Brave modificados, `about:credits` | LOCAL | — |
| W5 | Seguridad | Cómo avisar de un fallo de seguridad (correo); política de parches (cada 8 semanas, urgentes si hay explotación) | LOCAL | — |
| W6 | Aviso legal | Titular (lamosquita), contacto, marcas: FlyWeb no está afiliado a Brave Software ni a Google | LOCAL | Revisión legal |

Diseño: con la misma línea que la pestaña nueva (D-DIN, fotos de moscas, colores del proyecto). Sin rastreadores, sin
analítica, sin fuentes ni scripts de terceros. La página no debe cargar nada de fuera de `flyweb.lamosquita.net`.

## 2. Texto de privacidad (borrador para W2)

> ### Privacidad en FlyWeb
>
> FlyWeb no envía estadísticas de uso, informes de fallos ni datos de navegación a nadie. No tiene cuenta, ni
> sincronización, ni publicidad.
>
> Para funcionar, el navegador contacta con tres servicios de lamosquita, en un servidor propio situado en la UE (y con
> un cuarto, la sincronización, solo si usted la activa):
>
> | Servicio | Para qué | Qué recibe |
> |---|---|---|
> | `components.flyweb.lamosquita.net` | Actualizar las listas de bloqueo de anuncios y rastreadores, y componentes de seguridad (certificados revocados, etc.) | La versión de cada componente instalado y la versión del navegador |
> | `updates.flyweb.lamosquita.net` | Avisar de versiones nuevas de FlyWeb | La versión del navegador |
> | `proxy.flyweb.lamosquita.net` | Navegación segura (avisos de webs peligrosas y descargas maliciosas) y diccionarios del corrector, a través de Google sin que Google vea su dirección IP | Fragmentos cifrados (hash) de direcciones web, solo cuando una página coincide con la lista de peligros guardada en su equipo; el idioma del diccionario |
> | `sync.flyweb.lamosquita.net` (solo si activa Sincronizar) | Sincronizar contraseñas, marcadores, historial y ajustes entre sus equipos | Sus datos **cifrados en su equipo** con una clave que sale de su código de sincronización y nunca nos llega: no podemos leerlos. Se guardan hasta que usted borre los datos de sincronización desde el navegador (el historial, 14 días) |
>
> **Su dirección IP** llega a nuestro servidor porque es imprescindible para responder a la conexión, pero **no se
> guarda**: los registros de estos servicios no contienen IP ni las consultas de navegación segura, y se borran a
> los 7 días. A Google solo le llega la dirección de nuestro servidor.
>
> **Base legal:** interés legítimo (art. 6.1.f del RGPD) en mantener el navegador seguro y actualizado.
> **Responsable:** lamosquita — admin@lamosquita.net. Puede ejercer sus derechos de acceso, rectificación, supresión,
> oposición y limitación escribiendo a esa dirección, y reclamar ante la Agencia Española de Protección de Datos
> (www.aepd.es). Como no guardamos su IP, normalmente no tendremos datos suyos que mostrarle.
>
> **Funciones que contactan con terceros solo si usted las usa:** instalar extensiones de la Chrome Web Store (Google);
> traducir páginas, si se activa (Google); el contenido DRM (Widevine), si lo acepta (Google). Las webs que visita
> reciben, como en cualquier navegador, su IP y lo que usted les envíe.
>
> **Esta web** (`flyweb.lamosquita.net`) sí registra la IP de las visitas, para su seguridad, durante [PLAZO]. No usa
> cookies ni analítica.

Puntos a confirmar con quien lleve el RGPD:
- El plazo de conservación de los registros de la web (con IP).
- Si lamosquita lleva registro de actividades de tratamiento (art. 30): añadir una línea, «Servicios del navegador
  FlyWeb: IP en tránsito, sin conservación, interés legítimo».
- Traducir: decidido por el HUMANO (03/10): desactivado por defecto; si se activa, el texto de la página va a Google (paso 39). La frase del texto ya lo recoge.
- La ubicación exacta del servidor (OVH, UE) y si el contrato con el proveedor cubre el art. 28.
- **Sincronización (F7.5, si se abre a otros usuarios):** los datos van cifrados y no tenemos la clave, pero el RGPD
  puede seguir considerándolos datos personales (seudonimizados). Base legal propuesta: art. 6.1.b (servicio que el
  usuario pide al activar Sincronizar). Conservación: hasta que el usuario los borre. **Propuesta de NUBE, por
  decidir:** borrar las cadenas sin actividad en 12 meses (art. 5.1.e, limitación del plazo), avisándolo en este
  texto; Chromium renueva la ficha de cada dispositivo a diario, así que una cadena en uso nunca se borraría.

## 3. Por qué esto basta (resumen para la revisión legal)

- **La IP en tránsito es tratamiento** (art. 4.2: recogida y transmisión) **y es dato personal** (TJUE, *Breyer*,
  C‑582/14, 2016). Por eso hay que informar (art. 13) aunque no se guarde nada.
- **Sin conservación ni cesión:** los registros de `components.`, `updates.` y `proxy.` no llevan IP (formato `sinip`,
  probado). A Google solo le llega la IP del servidor y prefijos de hash que, sin IP, no identifican a nadie. No hay
  cesión de datos personales ni transferencia internacional.
- **Riesgo bajo:** no hace falta evaluación de impacto (art. 35).
