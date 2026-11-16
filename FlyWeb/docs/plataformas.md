# FlyWeb en otras plataformas: estudio en papel

ARQUITECTURA, 13-11-2026. Encargo de COORDINACIÓN-41 (buzón `20261113-2200`) por la directiva «Plataformas»
(`docs/DIRECTIVAS.md:385-391`). **Solo papel: nada compilado ni medido.** Restricción: coste cero.

Marcas: **[V]** leído por mí en la fuente citada; **[R]** dato del repositorio recogido por un barrido delegado, con su
ruta (he comprobado los que sostienen la conclusión); **[F]** fuente web abierta el 13-11-2026 por un agente de búsqueda,
que yo no he reabierto; **[I]** inferencia mía; **[S]** suposición.

## 1. Conclusión

1. **Lo que limita no son los parches, son tres cosas que no se multiplican:** una sola máquina que compila por
   plataforma, las manos de Titín para probar en aparatos reales, y los pasos de la fábrica que hoy lanza una persona.
   Por eso el paso 0 va primero, y es el único que abarata todos los demás.
2. **Orden que recomiendo: 0 → 1 (Ubuntu) → 2 (Android), y parar ahí.** Con una puerta entre cada uno: la plataforma
   anterior ha pasado dos tandas de seguridad seguidas en plazo y sin pasos a mano nuevos.
3. **iOS con motor propio: no ahora.** Nadie lo ha publicado [F], Chromium llama a su Blink para iOS «experimental
   code [that] should only be used for analysis» [V], y competiría por la 7,1, que ya es la única que compila la 156.
   Se deja en vigilancia con dos condiciones para reabrirlo (§3.4).
4. **Windows a coste cero no existe hoy.** La única vía gratuita es la Microsoft Store, y su política exige un motor
   que no vaya más de dos versiones mayores por detrás [F]; FlyWeb declara 156 en toda la 3.x. Fuera de la Store hace
   falta un certificado de pago (desde 49 EUR al año) y aun así hay semanas de aviso de SmartScreen [F].
5. **32 GB bastan para compilar, no para enlazar la versión oficial sin intercambio.** Chromium calcula 30 GB por
   enlace con ThinLTO en Linux, 45 en Windows y 30–60 en Android con símbolos completos [V]. Solución sin coste:
   fichero de intercambio y menos símbolos. **El disco es el problema antes que la RAM** (§2.2).
6. **Dos avisos que no son técnicos:**
   - publicar en Google Play o en el App Store expone datos personales de Titín (§2.4): lo decide él;
   - la directiva «Nada de `chrome` entero en la Ubuntu» (`DIRECTIVAS.md:172-175`) choca con la nueva: hay que
     conciliarlas (COORDINACIÓN).

## 2. Lo que es común a todas

### 2.1 Qué parte de lo nuestro sirve fuera del Mac

| Parte | Tamaño | ¿Sirve en otra plataforma? |
|---|---|---|
| Capa de Mojave y Catalina (`flynk-b1d`, ANGLE Metal 2.1, Dawn, `3.1.1-catalina`, `3.1-angle`) | 77 ficheros, 8 parches de ANGLE, 1 de Dawn y 8 de la 3.1.x [R: `b1d/README.md:4-10`] | **No.** Va marcada `Flynk-Platform: mac` y «sin tocar código común, para que Linux y Android compilen sin ella» [R: `base-siguiente.md:153-155`] |
| Código de Mac de brave-core (Sparkle, llavero `fw1`, Keystone…) | 50 `.mm` de escritorio [R: `brave-propio.md:543`] | **No.** Cada plataforma necesita su equivalente (§3) |
| Firma, notarización, DMG, appcast | `FlyWeb/tools/publicacion/`, `servidor/actualizaciones/` | **No.** Todo es Developer ID y Sparkle |
| Tandas de seguridad | 61 + 11 + 43 parches de Chromium en tres tandas [R] | **Sí**, y crecen: lo que hoy se descarta por «otra plataforma» pasa a aplicar (§2.3) |
| Privacidad (Shields) | 506 ficheros, 31 parches [R: `brave-propio.md:90-111`] | **Sí** el motor; **no** la interfaz en Android e iOS |
| Sync con cuenta (cliente) | BoringSSL, «nada que dependa de macOS» salvo dónde se guarda la semilla [R: `sync-cuenta.md:744-758`] | **Sí**; el almacén de claves es propio de cada sistema |
| Servicios propios (sync, componentes, listas, proxy) | Go y CRX en ns2 y bak | **Sí**, tal cual. El servidor no cambia |
| Marca e idiomas | 1 572 ficheros de identidad y recursos [R] | **Sí** en escritorio; iconos y tiendas, por plataforma |
| Interfaz de escritorio | la de Brave/Chromium (Views) | **Sí** en Linux y Windows; Android e iOS tienen la suya |

Lo que **no está medido** y decide el coste de Ubuntu: cuántos ficheros de brave-core 3.1 no compilan en Linux. La
única medida (P2, MOTOR-30) es anterior al porte: 936 ficheros rotos con la base de la 2.7.0 [V: `brave-propio.md`
§12.2]. Al portar a la 156 se dejaron caer 22 parches y 34 envoltorios de otras plataformas (Android 12, Windows 5,
Linux 5) [R: `brave-propio.md:304,317`]. Las carpetas `android/` (1 665 ficheros) e `ios/` (3 702) siguen en `local/3.1.1`
[V: `git ls-tree`], pero la poda «las cuenta, no las toca» [V: `b2-poda.md:928`]: nadie las ha compilado contra la 156.

### 2.2 La máquina de Linux y Android

- **Qué es** [V]: el PC de Titín, i9 de 13.ª generación, 32 hilos, **30 GB útiles** (`docs/TAREAS.md:17`), con arranque
  dual: **solo trabaja cuando Titín está en Ubuntu** (`DIRECTIVAS.md:218`). No es una fábrica desatendida.
- **Compilar** [V]: Chromium pide 8 GB como mínimo y más de 16 recomendados, en Linux y en Android
  (`docs/linux/build_instructions.md:15`, `docs/android_build_instructions.md:16`). MOTOR-30 ya compiló la 156 con
  brave-core ahí con `-j 12` y un tope de 24 GB: «32 GB bastan con -j 12; no comprar» (`coordinacion.md:446,469`).
- **Enlazar la oficial** [V: `build/toolchain/concurrent_links.gni:24-42`]: con ThinLTO Chromium reserva 10 GB y calcula
  por enlace 30 GB en Linux, 45 en Windows, 50 en Android oficial con `symbol_level=2` («30–60 GB») y 20 en el resto.
  Con 30 GB no cabe sin intercambio. Sin coste: fichero de intercambio de 32–64 GB en el SSD y `symbol_level` 0 o 1.
  Quitar ThinLTO lo arregla, pero en Linux se lleva por delante CFI [S: no lo he comprobado en el árbol]; no lo propongo.
- **Disco** [V]: Chromium pide 100 GB libres por plataforma; en esa máquina quedaban **38 GB** el 05-11
  (`coordinacion.md:651`). Linux y Android juntos necesitan del orden de 150–200 GB [I]. Sin comprar nada, hay que
  liberar sitio: es lo primero que hay que mirar.
- **Tiempo:** sin medir. La 7,1 tarda 3 h 20 min en la oficial de la 3.1.1 [R: `TAREAS.md:254`]. En el i9 con `-j 12`
  espero entre 3 y 5 h por plataforma [S]; es el primer dato que tiene que dar el hito U1.

### 2.3 Una tanda de seguridad en una plataforma más

- **Los parches son comunes**, pero no todos se llevan hoy. La clase N del triaje descarta lo de otras plataformas y lo
  de GL, Vulkan y Dawn [R: `seguridad-3.0.1.md:35-44`]. En la 3.0.1 fueron 10 de 53 CVE del segundo grupo (4 por sistema
  y 6 por backend gráfico); en la 3.1.1, 5 más el *roll* de ANGLE [R].
- **Con Linux o Android** pasan a aplicar los de GL y Vulkan de ANGLE y los propios del sistema: del orden de un 10–20 %
  más de parches por tanda que triar y portar [I, sobre esos recuentos].
- **Lo que de verdad se multiplica** es lo que dice la directiva: una compilación de 3–5 h, la batería y la publicación,
  por plataforma y por tanda, cada 2–4 semanas. Y en móvil, la revisión de la tienda.
- **Plazos que pasan a ser contrato:** Apple exige mitigar lo explotado «in a timely manner (e.g., 30 days…)» y una
  página pública con qué vulnerabilidad se arregló en qué versión [F]. Hoy lo cumplimos de hecho; allí sería condición.
- **Con arranque dual**, cada tanda de Ubuntu y Android espera a que Titín arranque Ubuntu. Un KEV tiene 48 h
  (`docs/SEGURIDAD.md:21` [R]): ese plazo no se puede prometer en una máquina que no está siempre encendida.

### 2.4 Tiendas y datos personales

- **Google Play** muestra de toda cuenta personal el nombre legal, el país y el correo. La declaración de comerciante
  de la UE es obligatoria antes del 1-02-2027; como comerciante se publican además teléfono y dirección [F:
  [Google, 13628312](https://support.google.com/googleplay/android-developer/answer/13628312) y
  [17594752](https://support.google.com/googleplay/android-developer/answer/17594752)].
- **App Store:** como comerciante se publican dirección o apartado de correos, teléfono y correo en los 27 países; como
  no comerciante, nada [F: [Apple, DSA](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/)].
- Qué declarar es una decisión legal de Titín, no técnica. La regla del proyecto es que sus datos no salen a sitios
  públicos; aquí saldrían por la tienda.

## 3. Plataforma por plataforma

### 3.0 Paso 0: la fábrica de Mac

**Qué hay** [R, del barrido]: no hay integración continua del navegador. Compilar, firmar y publicar están en guiones que
lanzan agentes de uno en uno. El guion de la Release de la 3.x **no está en el repositorio** (vive en `temp/`;
`relevo-local.md:42,55`), y `build.sh` no sirve para la 3.x. La web ya es automática (`flyweb-web-auto`, cada 10 min).

**Qué se automatiza primero, por este orden:**

| Hito | Qué | Por qué primero |
|---|---|---|
| F1 | El guion de la Release de la 3.x, versionado y único | Sin él nada es repetible, y las demás plataformas lo copian |
| F2 | Una orden que encadena compilar → batería automática → empaquetar → firmar y notarizar → subir → PR de la web, y deja un informe | Quita los relevos entre agentes; lo automático ya existe por piezas (`funcional.js`, WPT, Speedometer, importes) |
| F3 | `VERSION`, `web-auto` y la página de descargas, para más de un sistema | Hoy el formato es «DMG + appcast de Sparkle» [R: `web-auto/README.md:13-20,41-42`]. Hay que hacerlo **antes** de Ubuntu |
| F4 | Página pública de vulnerabilidades corregidas por versión, y la fila mensual de «arreglos que entran limpios» (prevista en `plan-3x.md:71`, no existe [R]) | Lo exige Apple, lo mira cualquier tienda y hoy está repartido por PR |

**Lo que no propongo automatizar:** la firma EdDSA en bak, los permisos de las sesiones y las aprobaciones de LuLu. Son
las barreras que impiden que una máquina o un agente comprometidos publiquen una actualización a todos los usuarios.
Se puede reducir a un solo gesto por versión; quitarlo es decisión de Titín y yo no lo recomiendo.

**Lo que seguirá siendo manual:** la prueba de claude.ai, la 5,1, Catalina y la actualización real por Sparkle.

Coste: cuatro hitos, sin compilaciones propias (se prueban con las versiones que ya tocan).

### 3.1 Ubuntu

| Hito | Qué | Puerta |
|---|---|---|
| U1 | Medir: `chrome` oficial de la 156 **sin** nuestros parches, con intercambio. Tiempo, RAM, disco | Si no enlaza o no cabe en disco, se para aquí |
| U2 | brave-core 3.1 para Linux: compilar con `-k 0` y contar lo roto (método P2) | Da el tamaño real del porte |
| U3 | Decisiones propias: dónde vive la clave `fw1` (libsecret o KWallet), actualizaciones por `apt` en vez de Sparkle, perfil de AppArmor | Papel, antes de programar |
| U4 | Paquete `.deb`, repositorio `apt` propio firmado en bak, web | — |
| U5 | Batería en Linux (WPT, `funcional.js`, GPU) y regla 17 de lo nuevo | — |
| U6 | Primera versión pública, como beta | Dos tandas en plazo antes de pasar a Android |

- **Propio de Linux:** almacén de claves; empaquetado; ANGLE sobre GL o Vulkan (drivers distintos por tarjeta);
  X11 y Wayland; el sandbox. Desde Ubuntu 24.04 un navegador fuera del archivo oficial necesita su perfil de AppArmor
  en el paquete, o el sandbox no arranca [F: [notas de 24.04](https://documentation.ubuntu.com/release-notes/24.04/#unprivileged-user-namespace-restrictions)].
- **Distribución, sin cuota en ninguna vía** [F]:
  - **repositorio `apt` propio** (clave OpenPGP, `InRelease` firmado): es lo que recomiendo. Se aloja en ns2, la clave
    vive en bak como las demás, y `apt` hace de actualizador: no hay que escribir un sustituto de Sparkle
    ([Debian, formato](https://wiki.debian.org/DebianRepository/Format), [uso por terceros](https://wiki.debian.org/DebianRepository/UseThirdParty));
  - Snap Store: gratis, pero el sandbox de un navegador exige una autorización de la tienda
    ([interfaz `browser-support`](https://snapcraft.io/docs/reference/interfaces/browser-support-interface/));
  - Flathub: exige compilar entero desde el código en su infraestructura y sin red
    ([requisitos](https://docs.flathub.org/docs/for-app-authors/requirements));
  - AppImage: no instala el perfil de AppArmor; para un navegador en 24.04 obliga a `--no-sandbox`.
- **Ventaja añadida:** la compilación de Linux caza los errores de C++ genérico antes de gastar la 7,1
  (`estudio-compilar-ubuntu.md` [R]: los ~24 errores de los niveles 132–135 eran todos de ese tipo).
- **Tanda:** una compilación más, batería y `apt`. Es la más barata de mantener.

### 3.2 Android

| Hito | Qué |
|---|---|
| A1 | Medir la compilación oficial para arm64 (`symbol_level=1`) en la misma máquina |
| A2 | **Decidir la interfaz:** la de Chromium para Android con nuestra marca, o la capa Java de Brave (1 665 ficheros sin portar a la 156). Es el hito grande |
| A3 | Shields y sync en Android (motor común; panel y ajustes, propios) |
| A4 | Requisitos de Play (abajo) |
| A5 | Pruebas en teléfonos reales |
| A6 | Prueba cerrada y paso a producción |

- **Solo se compila en Linux** [V: `android_build_instructions.md:24`]. Misma máquina, otra carpeta de salida: más disco.
- **Propio de Android:** toda la interfaz (Java), el almacén de claves, permisos, y que **no hay actualizador propio**:
  Play prohíbe descargar código ejecutable fuera de la tienda [F: [política](https://support.google.com/googleplay/android-developer/answer/9888379)].
  Es menos trabajo, y también menos control: una retirada depende de Google.
- **Google Play** [F]:
  - cuota única de 25 USD, ya pagada ([registro](https://support.google.com/googleplay/android-developer/answer/6112435));
  - si la cuenta personal se creó después del 13-11-2023, **12 probadores durante 14 días seguidos** antes de producción
    ([14151465](https://support.google.com/googleplay/android-developer/answer/14151465)). No sé de cuándo es la cuenta [S];
  - nivel de API 36 para apps nuevas ([target-sdk](https://developer.android.com/google/play/requirements/target-sdk)),
    AAB, 64 bits, páginas de 16 KB desde el 1-02-2027 ([page-sizes](https://developer.android.com/guide/practices/page-sizes));
  - desde febrero de 2027, requisito de optimización de DEX para apps con más de 10 MB de DEX
    ([17492799](https://support.google.com/googleplay/android-developer/answer/17492799)); un navegador puede superarlo [I];
  - no hay política específica para navegadores.
- **Tanda:** compilación (una por arquitectura), prueba en aparato, y revisión de Play, que no controlamos.

### 3.3 Windows

| Hito | Qué |
|---|---|
| W1 | Empaquetar el SDK una vez en un Windows con Visual Studio 2026 y cruzar desde Linux |
| W2 | brave-core para Windows: instalador y actualizador (no hay Sparkle; `installer/win` está vacío [V]) |
| W3 | Firma y distribución |
| W4 | Pruebas en un Windows real |

- **Compilar** [V: `docs/win_cross.md`]: se puede desde Linux, pero el paquete del SDK hay que generarlo en una máquina
  con Windows. Visual Studio Community es gratis para un desarrollador individual [F]. En el cruce, Crashpad no informa
  de caídas. El enlace oficial pide 45 GB [V]: es el que peor cabe en 30.
- **Firma, a coste cero no hay** [F]:
  - **Microsoft Store:** cuenta gratuita y firma ella el MSIX
    ([cuenta](https://learn.microsoft.com/en-us/windows/apps/publish/partner-center/open-a-developer-account),
    [MSIX](https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/msix/app-package-requirements)).
    Pero la política 10.2.1 pide un motor Chromium o Gecko «no older than within 2 major versions»
    ([políticas v7.20, en vigor desde el 22-10-2026](https://learn.microsoft.com/en-us/windows/apps/publish/store-policies)).
    Con la 156 declarada y Chrome en la 158 el 17-11, FlyWeb queda fuera en una versión más [I];
  - **Artifact Signing** (antes Trusted Signing), 9,99 USD al mes: en la UE solo organizaciones; los particulares, solo
    en EE. UU. y Canadá ([quickstart](https://learn.microsoft.com/en-us/azure/trusted-signing/quickstart));
  - **certificado clásico:** OV entre 130 y 700 USD al año; EV solo para organizaciones; validez máxima de 460 días
    desde marzo de 2026 ([CA/B Forum, CSC-31](https://cabforum.org/2025/11/17/ballot-csc-31-maximum-validity-reduction)).
    Lo más barato para un particular en la UE es un certificado «Open Source» de 49–69 EUR al año
    ([Certum](https://shop.certum.eu/open-source-code-signing.html));
  - **ninguno da reputación inmediata:** SmartScreen avisa hasta acumular «several weeks and hundreds of clean installs»,
    y EV ya no lo evita ([Microsoft](https://learn.microsoft.com/en-us/windows/apps/package-and-deploy/smartscreen-reputation)).
    Sin firma, además, Smart App Control lo bloquea.
- **Tanda:** la más cara: compilación al límite de memoria, pruebas en una máquina que hoy no está en la lista [S], y
  los arreglos de D3D y de Windows que hoy se descartan.

### 3.4 iOS con motor propio en la UE

- **Qué pide Apple** [F: [página](https://developer.apple.com/support/alternative-browser-engines/) y su anexo]:
  - app distribuida solo en la UE, con el permiso de navegador predeterminado;
  - **90 % de Web Platform Tests y 80 % de Test262, también sin JIT**;
  - parches «in a timely manner (e.g., 30 days…)», política pública de divulgación de vulnerabilidades y página pública
    de qué se arregló en cada versión;
  - cookies de terceros bloqueadas por defecto y almacenamiento particionado;
  - primero un perfil solo de desarrollo; el de distribución se pide después y Apple puede negarlo o revocarlo.
- **Cuotas** [F]: los 99 USD anuales ya pagados. La antigua *Core Technology Fee* desapareció el 1-10-2026; lo que hay
  son comisiones sobre ventas, que un navegador gratuito no tiene (deducción del agente; Apple no lo dice así)
  ([condiciones en la UE](https://developer.apple.com/support/dma-and-apps-in-the-eu/)). No sé si Apple concede el
  permiso a una cuenta de particular.
- **Estado real:**
  - nadie ha publicado un navegador con Blink o Gecko en iOS [F: [MacRumors, 17-06-2026](https://www.macrumors.com/2026/06/17/webkit-rule-costs-ios-users-browser-performance/)];
  - el árbol 156 trae `use_blink = !is_ios` por defecto y avisa: «the blink web platform is experimental code and
    should only be used for analysis» [V: `build/config/features.gni:41`, `docs/ios/build_instructions.md:311-316`];
  - Igalia, que lleva el porte, lo seguía llamando experimental en mayo de 2026 [F: [blog](https://blogs.igalia.com/gyuyoung/2026/05/)].
- **Máquina:** se compila en un Mac con Xcode 26 o posterior [V]; la 7,1 vale (Xcode 26.3), **pero es la única que
  compila la 156** [R: `plan-3x.md:366-367`]. Test262 hay que medirlo en un aparato o en un Mac con Apple silicon [F]:
  hace falta un iPhone.
- **Lo que hay en brave-core** (`ios/`, 3 702 ficheros) es un navegador sobre WebKit, no sobre Blink. Para un motor
  propio no sirve la interfaz tal cual [I].
- **Hitos:** no los puedo contar con honradez. Sería el primer navegador que lo hace, sobre un porte que su autor no da
  por terminado. `vision-motor.md` §4 ya lo llamaba «trabajo de años y de riesgo ajeno».
- **Condiciones para reabrirlo:** que Chromium deje de marcar su Blink de iOS como experimental, **o** que un navegador
  lo publique en la UE. Mientras tanto, una revisión cada trimestre (INVESTIGACIÓN-MOTOR).

## 4. Resumen

| | Hitos a la primera versión | ¿30 GB? | Compilación | Cuota nueva | Tanda de más |
|---|---|---|---|---|---|
| 0 Fábrica de Mac | 4 | — | la de siempre | 0 | la abarata |
| 1 Ubuntu | 6 | Sí, con intercambio; falta disco | 3–5 h [S] | 0 | Baja |
| 2 Android | 6, con A2 y A3 grandes | Sí, con `symbol_level=1`; más disco | 3–5 h por arquitectura [S] | 0 | Media, más la revisión de Play |
| 3 iOS, motor propio | sin contar | no aplica (7,1) | ocupa la 7,1 | 0 | Alta, con plazo por contrato |
| 4 Windows | 4 | Al límite (45 GB por enlace) | sin medir | **≥ 49 EUR/año** | Alta |

## 5. Qué no hacer

1. **No abrir dos plataformas a la vez.** Cada una añade una compilación por tanda en una máquina que no está siempre
   encendida.
2. **No empezar Ubuntu sin F3.** Publicar a mano una segunda plataforma es la deuda más cara de quitar después.
3. **No iOS con motor propio** hasta que se cumpla una de las dos condiciones de §3.4.
4. **No Windows por la Store** mientras se declare la 156, **ni sin firma**.
5. **No Flathub, Snap ni AppImage como primera vía en Linux.** Repositorio `apt` propio.
6. **No compilar la oficial con símbolos completos** en esa máquina, ni quitar ThinLTO para que quepa.
7. **No automatizar la firma de bak.**
8. **No declarar nada en las tiendas** sin que Titín decida antes qué datos suyos acepta publicar.
9. **No comprar nada todavía:** U1 dice en una tarde si la máquina basta.

## 6. Fuentes y límites

- **Leído por mí:** el árbol `~/proyectos/chromium-156/src` (documentos de compilación de Linux, Android, iOS y Windows,
  `win_cross.md`, `concurrent_links.gni`, `features.gni`), `local/3.1.1` de brave-core (`git ls-tree`), y en este
  repositorio `DIRECTIVAS.md`, `TAREAS.md:17`, `brave-propio.md` §12, `coordinacion.md`, `vision-motor.md` §4,
  `b2-poda.md`.
- **Barrido delegado del repositorio [R]:** fábrica, pruebas, inventario de parches y tandas. He comprobado a mano los
  datos de D8-LINUX, la medida P2, la directiva de la Ubuntu y `vision-motor.md`; el resto lo cito con su ruta sin
  reabrirlo.
- **Fuentes web [F]:** las abrieron dos agentes de búsqueda el 13-11-2026; yo no las he reabierto. Varias páginas de
  Apple y de Google no muestran fecha de actualización. Los precios de certificados son de lista, sin impuestos.
- **Sin verificar:**
  - si Apple concede el permiso de motor a una cuenta de particular;
  - si un autónomo español cuenta como «organización» para Artifact Signing;
  - de cuándo es la cuenta de Google Play de Titín;
  - que quitar ThinLTO desactive CFI en Linux;
  - cuánto disco libre hay hoy en la máquina de Ubuntu (el dato es del 05-11).
- **Mías y sin medir:** los tiempos de compilación, el 10–20 % de parches de más por tanda, el número de hitos y la
  lectura de la política 10.2.1 de la Store aplicada a FlyWeb.
- **Corrige a `base-siguiente.md` §3.5,** que daba WebKit por obligado en iOS: en la UE ya no lo es. La conclusión
  práctica, por ahora, es la misma.
