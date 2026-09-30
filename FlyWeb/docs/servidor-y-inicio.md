# FlyWeb — Página de nueva pestaña y servidor `flyweb.lamosquita.net`

Especificación para que el HUMANO diseñe la página y prepare el servidor por su cuenta, sin esperar a NUBE ni a LOCAL.

## 1. Decisión previa: la nueva pestaña tiene que ser local, no una web

La página de nueva pestaña de Brave (la de la captura: reloj, sitios más visitados, contadores, fondo) **no es una web**:
es una página interna (`brave://newtab`) que va dentro del navegador. Tiene que seguir siéndolo por cuatro razones:

| Si fuera `https://flyweb.lamosquita.net` | Si es local (propuesta) |
|---|---|
| **No puede mostrar los sitios más visitados ni el historial**: una web no tiene acceso a ellos, por seguridad | Los lee del perfil, como ahora |
| Cada pestaña nueva hace una petición a tu servidor: sabrías cuándo abre pestañas cada usuario | Ninguna conexión |
| Sin red o con el servidor caído, pestaña en blanco | Siempre funciona |
| Tarda lo que tarde la red (en la 5,1, notable) | Inmediata |

**Propuesta:** tú diseñas el aspecto; NUBE lo mete en la página local de brave-core (la de Brave es React y se puede
reestilizar sin reescribirla). `flyweb.lamosquita.net` queda para la web pública y los servicios (sección 3).

Si aun así quieres una web como página de inicio (el botón "Inicio" o al arrancar), puede existir **además**: una
página estática y minimalista (la mosca, un buscador), sin sitios visitados.

## 2. Página de nueva pestaña: qué puedes diseñar

### Elementos disponibles (datos locales, sin servidor)

| Elemento | Datos | Notas |
|---|---|---|
| Reloj | Hora local; formato 12/24 h según el sistema | Grande, como en la captura |
| Sitios más visitados | Hasta **12** accesos: favicon (16–32 px, a veces solo una letra) y título corto | Rejilla o fila. El usuario puede fijar, quitar y añadir |
| Contadores de Shields | Rastreadores y anuncios bloqueados; ancho de banda ahorrado; tiempo ahorrado | Tres cifras con su texto. Se pueden ocultar |
| Fondo | Color, degradado, SVG o animación CSS | **Sin fotos** (tu decisión). Las fotos de Brave vienen de su servidor; se quitan |
| Botón "Personalizar" | Abre el panel de ajustes de la página | Se mantiene; lo reestilizamos |
| Accesos inferiores | Ajustes, marcadores, historial | Iconos pequeños abajo a la derecha |
| Buscador (opcional) | Caja de búsqueda con el buscador elegido | En Brave 1.57 solo existe como promoción de Brave Search (`searchPromotion`); una caja propia hay que añadirla |

### Lo que desaparece

Tarjetas de Brave Talk, Rewards y News (ya quitadas en código: pasos 6 y 10), fotos de fondo y patrocinadas (paso 8),
"Desplázate hasta Brave News" y los créditos de la foto.

### Requisitos técnicos del diseño

- **Tamaños:** de 800×600 (mínimo) a 2560×1440; el contenido se reordena, no se escala. Probar a 1280×800 y 1920×1080.
- **Claro y oscuro:** dos paletas; el navegador elige según el sistema.
- **Fuentes:** con licencia libre (OFL o similar), que irán **dentro** del navegador. Nada de Google Fonts ni de CDN:
  cada carga sería una conexión fuera. Ya van incluidas **Poppins** y **Manrope** (OFL, en `ui/webui/resources/fonts/`); otra fuente libre se puede añadir.
- **Moscas volando:** en SVG más animación CSS (`transform` y `opacity`), **nada de vídeo, WebGL ni JavaScript
  pesado**. La 5,1 no tiene AVX y la página se abre con cada pestaña. Respetar `prefers-reduced-motion`
  (moscas quietas). Como referencia: menos de 1 % de CPU en reposo.
- **Contraste:** el texto sobre el fondo debe leerse (WCAG AA, 4,5:1), en claro y en oscuro.
- **Entrega:** SVG o PNG por pantalla (claro y oscuro), colores en hexadecimal, tamaños en px, y las moscas como SVG
  sueltos con la trayectoria que quieras (la animación la montamos nosotros si prefieres).

## 3. Servidor `flyweb.lamosquita.net`

### Subdominios

| Subdominio | Para qué | Cuándo | Qué necesita |
|---|---|---|---|
| `flyweb.lamosquita.net` | Web pública: qué es FlyWeb, descargas, notas de versión, licencias y enlace al código (obligación MPL-2.0: publicar los ficheros de Brave modificados; basta enlazar a los forks de GitHub) | Cuando haya primera versión para repartir | Estático (HTML) |
| `updates.flyweb.lamosquita.net` | Actualizaciones automáticas con **Sparkle**: un `appcast.xml` y los `.dmg` firmados | Fase 0.5 (con la app firmada y notarizada) y Fase 2 | Estático. Los `.dmg` rondan 150–250 MB por versión |
| `components.flyweb.lamosquita.net` | Actualizador de componentes propio: listas de bloqueo de Shields, CRLSet y certificados. Sustituiría a `go-updater.brave.com` | Fase 2, **solo si Brave deja de servirlos** (hoy la decisión es seguir con el suyo) | **Dinámico**: habla el protocolo Omaha (peticiones POST con JSON). Brave publica el suyo, `brave/go-update` (Go); habría que desplegarlo y firmar los paquetes con una clave nuestra |

No hacen falta: sincronización, estadísticas ni variations (en FlyWeb apuntan a una URL inerte a propósito), ni
cuentas de usuario.

### Requisitos del servidor

- **HTTPS con Let's Encrypt:** su raíz (ISRG Root X1) es de confianza en Mojave desde 10.12.1. TLS 1.2 o 1.3.
  El certificado puede ser comodín `*.flyweb.lamosquita.net` o uno por subdominio.
- **Sin rastreo:** ni analítica, ni cookies, ni recursos de terceros (fuentes, scripts, iconos). Registros del servidor
  sin IP o con retención mínima. FlyWeb se anuncia como navegador privado.
- **Cabeceras:** `Strict-Transport-Security`, `Content-Security-Policy` restrictiva (`default-src 'self'`) y
  `X-Content-Type-Options: nosniff`.
- **Para `updates`:** servir `.dmg` con `Content-Type: application/x-apple-diskimage` y permitir peticiones con `Range`
  (descargas reanudables). Espacio: unos 250 MB por versión que se mantenga publicada.
- **Para `components`** (más adelante): un servicio en Go detrás del proxy inverso, más el almacén de los CRX firmados.

### Qué hacemos NUBE y LOCAL cuando esté

- NUBE: cambiar en `build.sh` las URL (`updater_prod_endpoint`, appcast de Sparkle) y generar el `appcast.xml`.
- LOCAL: firmar y notarizar los `.dmg` (F0.5, necesita el certificado Developer ID) y subirlos.

## 4. Preguntas abiertas para el HUMANO

1. ¿Nueva pestaña local con tu diseño (propuesta) o una web? Afecta a si puede mostrar los sitios visitados.
2. ¿Buscador en la nueva pestaña: sí o no? ¿Cuál por defecto?
3. ¿Mantener los contadores de Shields? Son la única "estadística" que queda y es local.
