# FlyWeb 2.0.0 — base nueva: Chromium 128 (Brave 1.69.168), motor de nivel 131 (FM.31, FM.38, FM.39)

**Estado (26-10-2026):** DMG definitivo `-p17` (build 28 = 169.168.28, 174 786 565 bytes) firmado; sin fecha de publicación.
La web de este PR lleva su tamaño y SHA-256, y `FlyWeb/web/VERSION` apunta a él; no se fusiona hasta el visto bueno de
Titín en la 5,1 y el appcast. Sin `releaseNotesLink` (decisión de PUBLICACIÓN): las novedades van en la web.

| Dato | Valor |
|---|---|
| Base | Brave 1.69.168 = Chromium 128.0.6613.138 (la 1.15.2: Brave 1.57.64, Chromium 116) |
| Versión visible / `CFBundleVersion` | 2.0.0 (`flyweb://version`: «FlyWeb 2.0.0 (motor 131) · Brave 1.69.168») / 169.168.N |
| Nivel declarado a las webs | Chrome 131 (131.0.6778.265), como la 1.15.2 |
| Requisitos | macOS 10.14 Mojave o superior, Intel x86_64, sin AVX. La 1.15.2 sigue para High Sierra (HUMANO, 20-10) |
| Actualizaciones | Sparkle, appcast `updates.` por canal, `minimumSystemVersion` 10.14.0 (FM.39 punto 2) |
| Perfil | mismo sitio, mismo llavero, mismo bundle id. **Copia automática** `LaMosquita/FlyWeb antes de 2.0 (AAAA-MM-DD)` en el primer arranque; el perfil 116 → 128 es de ida |
| Probado | 6,1 (Mojave) y 7,1; migración con copia de un perfil real de la 1.15.2: marcadores 906 = 906, extensiones 2 = 2. **Sin comprobar:** contraseñas migradas (el perfil de prueba no tenía), sync y una actualización real 1.15.2 → 2.0. Pendientes a mano: A1398, MacBook Air, 5,1 |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12 del tablero.)*

- **Base nueva.** FlyWeb pasa de Chromium 116 a Chromium 128 (Brave 1.69). Las webs lo siguen viendo como Chrome 131.
- **Tarjeta gráfica acelerada en Mojave.** Dibujo, WebGL, WebGL2 y vídeo van acelerados por hardware, como en la 1.15; 10
  minutos de WebGL sin una sola caída. WebGPU sigue apagado por seguridad.
- **Shields nuevo.** Motor de bloqueo actualizado y recursos propios (scriptlets) servidos desde nuestro servidor.
- **Actualizaciones.** Sparkle, desde nuestro servidor, firmadas por nosotros, como en la 1.15.
- **Copia automática del perfil.** Al abrir la 2.0 por primera vez, copia tu perfil junto al original. Es de ida.
- **Más privado.** Sin peticiones a servicios de Brave (comprobado en reposo, 10 min); Media Router apagado.
- **Nueva pestaña** con «Personalizar» y los cinco sitios más visitados.
- **Quitado:** Wallet, Rewards, News, Talk, VPN y Leo.
- **Requisitos:** Mojave 10.14 o superior. High Sierra se queda en la 1.15.2.
- **Ayuda nueva:** contraseñas que no se ofrecen (extensión «Contraseñas en iCloud») e importar contraseñas.
- **Conocido:** el texto blanco de las estadísticas de la nueva pestaña se lee mal sobre fotos claras (2.0.x).
