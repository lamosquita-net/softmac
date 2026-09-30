# FlyWeb — Diseños y servidor (cadena del HUMANO)

Aquí NUBE y LOCAL dejan **todo lo que el HUMANO tiene que diseñar o preparar en sus máquinas**: maquetas, iconos,
fuentes, subdominios, vhosts y servicios. Lo pendiente está en la sección 1; el detalle, en las demás.
Regla (ver `docs/TAREAS.md`, regla 7): si un agente necesita un gráfico o un servicio nuevo, lo añade a la sección 1.

## 1. Pendiente para el HUMANO

| # | Qué | Para cuándo | Detalle |
|---|---|---|---|
| D1 | Maquetas de la nueva pestaña: claro y oscuro, a 1280×800 y 1920×1080 (y cómo queda a 800×600) | Cuando empieces la iconografía | §3 |
| D2 | Estados de la nueva pestaña: perfil nuevo (sin sitios), sitio sin favicon, menú de un acceso, "añadir sitio", panel "Personalizar", selector de buscador | Con D1 | §3 |
| D3 | Fuente D-DIN (la de Datto, **no** "D-DIN PRO"): WOFF2 de los pesos que uses y su `OFL.txt` | Con D1 | §2 |
| D4 | Iconos y logotipos del inventario de LOCAL | Siguiente versión | `FlyWeb/branding/imagenes.md` |
| D5 | Símbolo definitivo del botón de Shields (18 y 36 px, activo y apagado) | Con D4 | `FlyWeb/docs/marca-pendiente.md` (M6) |
| D6 | Diseño de la web pública `flyweb.lamosquita.net` | Antes de la primera versión pública | §4 |
| S1 | Vhost `flyweb.lamosquita.net` (estático) | Antes de la primera versión pública | §4 |
| S2 | Vhost `updates.flyweb.lamosquita.net` (estático, DMG grandes) | Fase 0.5: app firmada | §4 |
| S3 | Vhost y servicio `components.flyweb.lamosquita.net` (listas de Shields) | Fase 2 | §4 y §5 |

## 2. Decisiones del 30/09

| Tema | Decisión | Estado |
|---|---|---|
| Nueva pestaña | **Local** (página interna del navegador), con el diseño del HUMANO | Pendiente de D1 |
| Buscador | Caja de búsqueda en la nueva pestaña, con selector de buscador. Por defecto **DuckDuckGo**; Google, Bing, Qwant, Startpage y Ecosia como opción | Buscador por defecto hecho (brave-core `nube/buscador`, paso 12 de `integracion.md`); la caja, con D1 |
| Contadores de Shields | Se mantienen (son locales) | — |
| Fuente | D-DIN de Datto (no la "PRO"), solo en la nueva pestaña; el resto del navegador, fuente del sistema | Pendiente de D3 |
| Servicios | Migrar a máquinas propias todo lo de Brave que siga en uso | §5 |

**Por qué DuckDuckGo y no Google.** Google perfila al usuario con sus búsquedas; DuckDuckGo dice no guardar IP ni
historial de búsqueda (política pública, no auditada de forma independiente). Además, DuckDuckGo ya viene en la lista
de Brave, con variantes regionales (Alemania; Australia, Nueva Zelanda e Irlanda): no hay que añadir nada. Pega:
sus resultados son peores en búsquedas locales. Brave Search deja de ser el buscador por defecto (era el de España y
EE. UU.) porque es marca Brave; sigue en la lista como opción, igual que los demás.

**Fuente: D-DIN (Datto, 2017), licencia SIL OFL 1.1.** Se puede incluir en el navegador y en la web, también en uso
comercial. Descarga: repositorio de Datto en GitHub, Font Squirrel o Font Library. No se usa "D-DIN PRO" (ampliación de
terceros sin origen claro).
- **Dónde se usa:** solo en la **nueva pestaña** (y en la web pública, si quieres). Barra de direcciones, pestañas,
  menús y diálogos del navegador usan la fuente del sistema (en Mojave, San Francisco), y no se tocan. Las demás páginas
  internas (ajustes, historial, descargas) siguen con las fuentes que ya traen de Brave; cambiarlas sería otra tarea.
- **Entrega:** WOFF2, solo los pesos que uses (2 o 3; cada uno pesa unos 30–60 KB), y el `OFL.txt`. Irá dentro del
  navegador y en `about:credits`.
- **Cobertura:** D-DIN solo tiene alfabeto latino. En ruso, griego, chino, etc. la página usará la fuente del sistema;
  que el diseño no dependa de la fuente para verse bien.

## 3. Nueva pestaña: qué diseñar

Es la página interna `brave://newtab` (React en brave-core). NUBE la reestiliza con tus maquetas; no hace falta
reescribirla.

### Elementos (todos con datos locales, sin servidor)

| Elemento | Datos | Notas |
|---|---|---|
| Reloj | Hora local; 12/24 h según el sistema | Grande |
| Buscador | Caja + selector con los buscadores de la lista | **Nuevo**: en Brave 1.57 no existe (solo había una promoción de Brave Search). Busca con el buscador elegido, directamente, sin pasar por nuestro servidor. Sugerencias mientras se escribe: apagadas por defecto (cada tecla iría al buscador) |
| Sitios más visitados | Hasta **12**: favicon (16–32 px, a veces solo una letra) y título corto | El usuario puede fijar, quitar y añadir. Diseñar el menú de cada acceso y el diálogo "añadir" |
| Contadores de Shields | Rastreadores y anuncios bloqueados; ancho de banda ahorrado; tiempo ahorrado | Tres cifras con su texto; se pueden ocultar |
| Fondo | Color, degradado, SVG o moscas animadas | Sin fotos. Las fotografías de Brave vienen de su servidor y se quitan |
| Botón "Personalizar" | Panel de ajustes de la página | Qué mostrar u ocultar, fondo, 12/24 h |
| Accesos inferiores | Ajustes, marcadores, historial | Iconos pequeños abajo a la derecha |

**Desaparece:** Brave Talk, Rewards y News (quitados en los pasos 6 y 10), fotos de fondo y patrocinadas (paso 8),
"Desplázate hasta Brave News" y los créditos de la foto.

### Requisitos técnicos

- **Tamaños:** de 800×600 a 2560×1440. El contenido se reordena, no se escala.
- **Claro y oscuro:** dos paletas; el navegador sigue al sistema.
- **Fuentes:** solo las que van dentro del navegador (§2). Nada de Google Fonts ni CDN: cada carga sería una conexión
  fuera.
- **Moscas volando:** SVG + animación CSS (`transform`, `opacity`). Nada de vídeo, WebGL ni JavaScript pesado: la
  página se abre con cada pestaña y la 5,1 es lenta. Con `prefers-reduced-motion`, moscas quietas. Objetivo: menos de
  1 % de CPU en reposo.
- **Contraste:** WCAG AA (4,5:1) en claro y en oscuro.
- **Entrega:** SVG o PNG por pantalla y estado, colores en hexadecimal, medidas en px, y las moscas como SVG sueltos
  con su trayectoria (la animación la puede montar NUBE).

## 4. Servidor: subdominios y vhosts

| Subdominio | Para qué | Cuándo | Tipo |
|---|---|---|---|
| `flyweb.lamosquita.net` | Web pública: qué es FlyWeb, descargas, notas de versión, licencias y **enlace al código** (obligación MPL-2.0: basta enlazar a los forks de GitHub) | Primera versión pública | Estático |
| `updates.flyweb.lamosquita.net` | Actualizaciones con Sparkle: `appcast.xml` + `.dmg` firmados | Fase 0.5 | Estático; 150–250 MB por versión |
| `components.flyweb.lamosquita.net` | Actualizador de componentes: **listas de bloqueo de Shields** y demás componentes (§5) | Fase 2 | **Dinámico** (protocolo Omaha) + almacén de paquetes |

**No hacen falta:** sincronización, estadísticas, variations ni cuentas de usuario (en FlyWeb apuntan a una URL
inerte a propósito).

### Requisitos comunes

- **DNS:** registros A/AAAA para cada subdominio.
- **HTTPS con Let's Encrypt:** su raíz (ISRG Root X1) es de confianza en Mojave. TLS 1.2 y 1.3. Certificado comodín
  `*.flyweb.lamosquita.net` (reto DNS-01) o uno por subdominio (HTTP-01).
- **Sin rastreo:** ni analítica, ni cookies, ni recursos de terceros. Registros sin IP, o con retención mínima.
- **Cabeceras:** `Strict-Transport-Security`, `Content-Security-Policy: default-src 'self'` y
  `X-Content-Type-Options: nosniff`.

### Ejemplo de vhost (Apache 2.4)

Probado con Apache 2.4 (`configtest` y peticiones reales): HTTP/2, `206` con `Range`, tipo `.dmg`, cabeceras y registro sin IP.

Módulos: `ssl`, `headers`, `http2` y `mime` (y `proxy_http` para S3). Los certificados, con certbot (`--apache`).

```apache
<VirtualHost *:443>
    # Igual para flyweb.lamosquita.net, con su DocumentRoot.
    # Apache no admite comentarios al final de una directiva: siempre en su propia línea.
    ServerName updates.flyweb.lamosquita.net
    DocumentRoot /srv/flyweb/updates
    Protocols h2 http/1.1
    SSLEngine on
    SSLProtocol -all +TLSv1.2 +TLSv1.3
    SSLCertificateFile    /etc/letsencrypt/live/flyweb.lamosquita.net/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/flyweb.lamosquita.net/privkey.pem

    Header always set Strict-Transport-Security "max-age=31536000"
    Header always set Content-Security-Policy "default-src 'self'"
    Header always set X-Content-Type-Options "nosniff"

    # Registro sin IP (o CustomLog /dev/null)
    LogFormat "%t \"%r\" %>s %b" sinip
    CustomLog ${APACHE_LOG_DIR}/flyweb-updates.log sinip
    ErrorLog  ${APACHE_LOG_DIR}/flyweb-updates-error.log

    <Directory /srv/flyweb/updates>
        Options -Indexes
        AllowOverride None
        Require all granted
    </Directory>

    # Apache sirve Range (descargas reanudables) por defecto
    AddType application/x-apple-diskimage .dmg
    <FilesMatch "\.dmg$">
        Header set Cache-Control "public, max-age=31536000, immutable"
    </FilesMatch>
    <Files "appcast.xml">
        Header set Cache-Control "no-cache"
    </Files>
</VirtualHost>

<VirtualHost *:80>
    ServerName updates.flyweb.lamosquita.net
    Redirect permanent / https://updates.flyweb.lamosquita.net/
</VirtualHost>
```

Para S3 (fase 2), el servicio en Go escucha en local y Apache hace de proxy inverso:
`ProxyPass / http://127.0.0.1:8192/` y `ProxyPassReverse / http://127.0.0.1:8192/`.

## 5. Servicios de Brave que usa FlyWeb y su sustituto

Lista sacada del código de brave-core 1.57. **La auditoría de red de LOCAL (F1.6) dirá cuáles se usan de verdad**; esta
tabla se actualizará entonces.

| Servicio de Brave | Para qué | Propuesta |
|---|---|---|
| `go-updater.brave.com` | Componentes: listas de Shields, catálogo de listas regionales, recursos de adblock, datos locales (rastreadores, debounce), CRLSet, Widevine | `components.flyweb.lamosquita.net` (fase 2). Mientras, el de Brave (decisión vigente) |
| `extensionupdater.brave.com`, `crxdownload.brave.com` | Instalar y actualizar extensiones de la Chrome Web Store sin ir directo a Google | Por decidir tras F1.6: proxy propio o ir directo a Google |
| `static1.brave.com`, `redirector.brave.com`, `clients4.brave.com` | Proxies de Brave hacia recursos de Google, para que Google no vea la IP | Por decidir tras F1.6 |
| `translate.brave.com` | Traducción de páginas | Apagarla o proxy propio (por decidir) |
| `safebrowsing2.brave.com`, `sb-ssl.brave.com` | Proxy de Safe Browsing | Apagado por política (`flyweb-policies.mobileconfig`) |
| `laptop-updates.brave.com` | Estadísticas y referrals | Quitado (paso 10) |

### Qué hace falta para servir nosotros las listas de Shields

No basta con guardar ficheros: el navegador las pide como **componentes firmados**, igual que Chrome.
1. **Servicio Omaha** en `components.`: responde a POST con JSON diciendo qué versión hay de cada componente. Brave
   publica el suyo, `brave/go-update` (Go, MPL-2.0); se despliega detrás de Apache (proxy inverso).
2. **Paquetes CRX3** firmados con **una clave nuestra** (la privada, fuera del repo; regla 5 de `TAREAS.md`).
3. **Tarea diaria** que descarga las listas originales (EasyList, EasyPrivacy, uBlock Origin, regionales), las empaqueta
   y las publica.
4. **Cambio en el navegador** (NUBE): los ID y las claves públicas de los componentes de adblock
   (`ad_block_component_installer.cc`) y del catálogo de listas pasan a ser los nuestros.
5. **Licencias:** EasyList y EasyPrivacy son GPLv3 o CC BY-SA 3.0; los filtros de uBlock Origin, GPLv3. Se pueden
   redistribuir sin cambios, con su licencia y su atribución.

Requisitos del servidor para S3: Go (o el binario compilado), unos pocos GB de disco y salida a Internet para la
tarea diaria. Poco tráfico: cada navegador pregunta cada pocas horas y solo descarga lo que cambia.

## 6. Qué hacen NUBE y LOCAL con lo que entregues

- **D1–D3:** NUBE mete el diseño y la fuente en la nueva pestaña de brave-core (rama `nube/ntp`); LOCAL compila y prueba
  en la 7,1 y el HUMANO en la 5,1.
- **D4–D5:** LOCAL o NUBE generan los tamaños (`FlyWeb/branding/scripts/`).
- **S2:** NUBE cambia en `build.sh` la URL del appcast y genera `appcast.xml`; LOCAL firma, notariza y sube los `.dmg`.
- **S3:** lo llevará un **agente nuevo (SERVIDOR)**, dedicado a los servicios internos de FlyWeb en tus máquinas: rastreo y
  empaquetado de las listas, servicio Omaha y proxies. NUBE hace el cambio de claves en el navegador.
- **§5:** LOCAL la completa con los resultados de la auditoría de red (F1.6).
