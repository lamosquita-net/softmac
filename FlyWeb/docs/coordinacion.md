# Relevo de COORDINACIÓN

Nota para la sesión que tome el papel de COORDINACIÓN. Puesta al día el **20-10-2026, ~22:45 (Madrid)** por COORDINACIÓN-8
(`session_0133Pd3pUk1DtKWpYpE53qB4`, «Coordinación (8)», 20-10, Opus 5.5 alto; relevada al 66 % de contexto),
que relevó a COORDINACIÓN-7 (archivada).
Leer antes: `CLAUDE.md` (**primera regla fija: datos personales del HUMANO nunca en GitHub**; al HUMANO se le llama
**Titín**), `docs/TAREAS.md` (tabla de agentes, **reglas 1–20**, filas FM.28, FM.29, FM.31 y FS.20–FS.22),
`FlyWeb/docs/migracion-128.md` (plan de la base 128, recalibrado) y los estudios de hoy (abajo).

## 06-11 (noche): COORDINACIÓN-31 → COORDINACIÓN-32 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-31 (`session_01MwmK2iP27sssYimPaJ7scp`, 06-11 15:45 → ~22:55 UTC; Opus 5.5 medio; abierta por la 30,
linaje 6; relevo al 42 %). La 32 la abre la 31 (linaje 7 de 8: **la 33 tiene que abrirla Titín desde la app**).
**Nunca llamar a confirm_repository_trust.**

**Decisiones de Titín de hoy (además de las de la nota de la 30):**
- **LuLu** (DIRECTIVAS, Organización, #807): un aviso de LuLu no es «máquina ocupada»; si una build nueva no tiene red,
  LOCAL da la ruta y COORDINACIÓN avisa a Titín.
- **LOCAL-20 abierta para F1** (LOCAL-18 la archivó Titín el 05-11; nada de F1 hecho). No recuperar la 18.
- **Fork de chromium:** `lamosquita-net/chromium` (antes chromium-legacy) YA está en la red de chromium/chromium y
  guarda `flynk-b1d`: **no se borra ni se crea otro**. Pendiente de Titín: poner `flynk` como rama por defecto tras el
  push (recordárselo) y **autorizar en la sesión de LOCAL-20** las etiquetas base y el push (lo bloquea su clasificador,
  «Create Public Surface»). Texto propuesto en la conversación: etiqueta 128.0.6613.138 en chromium, 10 etiquetas base
  de V8, push de flynk y flynk-v8, sin tocar master.lion, stable.lion ni flynk-b1d.
- **RAM:** 32 GB bastan con -j 12; no comprar.
- **Pendiente de Titín:** compilar `chrome` entero en la Ubuntu una vez (su regla allí: «nunca compilar Blink»). Le
  llegó cortado un mensaje suyo a MOTOR-30; la excepción tiene que ser explícita y de Titín (el clasificador de la nube
  bloquea con razón que COORDINACIÓN escriba «autorizado por Titín»). Recomendación: sí, una vez.

**Decisiones mías:** «PGO siempre» RESTABLECIDO (A/B limpio en la 6,1: Speedometer +42 %, JetStream +9 %, MotionMark
+21 %, 0 fallos; 7,1 igual). Lint de settings se arregla, no se apaga. Brave Search y buscadores prepoblados sin
`source=` ni códigos de socio de Brave (versión de datos 31). kQuietNotificationPrompts se queda (espejo sirve Crowd
Deny, comprobado en ns2). OFAC, kdf, brave_mobile_subscription, overrides de Windows, P3A tests: borrados.
kThirdPartyAiChatSettings: **pendiente de Titín** con la primera build Mac que pueda ver.

**FM.55 B2 (porte):** punta `nube/b2-porte-t11` **89e14c56e** (MOTOR-39). Recorrido de los P2: 99 (b1a25a49) → 12
(30f94067) → **6 (ab0be296)**; 0 símbolos sin definir; gn check limpio; lint de settings cerrado. Quedan 3 para
MOTOR-39 (mandado 22:47): view_shadow.cc (ui::Layer::Create), location_bar_view.cc:404 (OmniboxPopupViewViews con
BraveOmniboxViewViews*) y el mock del autoplay browsertest. Después: rápida de MOTOR-30 sobre la punta que haya
(cubre 307f566c en adelante y las unidades de Chromium de mis mensajes del buzón de d7457458, c1d9d8ae, 307f566c y 2125)
→ P2 → si da 0, **build Mac del porte con LOCAL-19 (con PGO y con e67de82a de flynk-b1d)** y lista de comprobaciones
en ejecución de `relevo-motor.md` (#811/#812: Google sign-in, UA Chrome/156, GCM apagado, Safe Browsing por el proxy,
iconos de Leo y spinners, buscadores sin source, portapapeles en incógnito).
**Lección:** el P2 solo cuenta objetivos de Brave; los overrides de chromium_src rompen ficheros de Chromium que no ve
(NotificationHandler::Type, PermissionType). Por eso chrome entero, si Titín lo autoriza.

**Equipo vivo:** MOTOR-39 (`session_01MwmK2goNHDRcfxEXELHuXM`, con brave-core; MOTOR-38 archivada, 100 $),
MOTOR-30 (Ubuntu, solo buzón; -j 12 en scope de systemd con MemoryHigh=24G; el servicio b2-cadena ya está borrado;
**si calla, puede estar esperando una pregunta: preguntarle por el buzón antes de alarmar a Titín**), LOCAL-19 (6,1:
canvas Metal/GL/2.7.0 hasta ~23:20; Ganesh cae ~15× en Canvas Arcs/Paths/Lines en la 7,1), LOCAL-20 (F1: H1–H3 hechos,
H4 Release desde flynk-r2 f11fbc9866 al 79 % sin errores; espejo Samba hecho, flynk-chromium.git 2,6 GB y
flynk-v8.git 1,1 GB), SEGURIDAD-PORTES-18 (espera build), SERVIDOR-LOCAL, PUBLICACIÓN, ARQUITECTURA, CARTERO-LOCAL.
**Tareas programadas mías:** vigilancia horaria `trig_01L8upyXCDpiBPkbGwYMoife` (la borro al pasar el relevo; la 32 la
crea en su sesión si sigue haciendo falta).

## 06-11 (tarde): COORDINACIÓN-30 → COORDINACIÓN-31 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-30 (`session_01MwmK2mDgcmCYXZUo9KnJZU`, 06-11 12:45 → ~15:45 UTC; Opus 5.5 medio; abierta por la 29, linaje 5;
relevo al 35 %). La 31 la abre la 30 (linaje 6 de 8). **Nunca llamar a confirm_repository_trust.**

**Decisiones de Titín de hoy (no se tocan):**
- **Intocables del porte:** el permiso «Inicio de sesión con Google» de Brave entero (lo pidió él; se anuló por escrito
  mi orden de quitarlo) y las llaves de acceso con el móvil (WebAuthn híbrido: QR + Bluetooth; MOTOR-38 comprobó que nada
  las apaga, #799).
- **F7.7 (sync con cuenta):** flujo elegido y escrito en TAREAS (#797, #798, #800, #801): email + contraseña + código por
  email; recuperación por email; aviso en todos los navegadores; un navegador nuevo recibe la clave solo con la aprobación
  de otro ya sincronizado, **en espera sin caducar** (sin móvil no es inmediata); clave de recuperación como salida; todo con
  una sola clave y texto explícito de pérdida; borrado de cuentas inactivas a los 365 días con aviso 30 días antes
  (desactivado hoy: 7 usuarios). Es para estudiar, sin prioridad todavía.

**Decisiones mías del porte (en brave-propio.md §12.16, #794/#795/#799):** lista de lectura de Chromium se queda (go-sync
la admite; falta el viaje real); settings 156 obligatoria antes de cualquier build para Titín (hecha); history, extensions
y downloads sin tocar (compilan); Checkup oculto y detección de filtraciones apagada; subpáginas autoplay y estado de
Shields porteadas; Storage Access visible; AUTO_VERIFY/ANTI_ABUSE fuera como 1.98 (PST apagado); localhost → LNA
nativo (SERVIDOR-LOCAL avisado: `localhost-permission-allow-list.txt` se retira cuando no queden 1.x/2.x con soporte);
histograms solo `.ShieldsPanel`; webpack con `externalsPresets {web:false}` en vez de subir a 5.105; **GPC como 1.98**
(se excluye el IDL nativo; una sola fuente, el pref de Brave, para JS y Sec-GPC; contrario a «nativo primero», justificado).

**FM.55 B2:** punta `nube/b2-porte-t11` **901f0a1eb5** (MOTOR-38). Último P2 (MOTOR-30, b1a25a49): **99 rotos = producción 5
(2 reales) + tests 94**; 0 símbolos sin definir. Recorrido de hoy: 177 → 163 → 106 → 99. Ojo: el P2 no veía unidades gen/
con override; MOTOR-30 lo ha corregido y el próximo P2 suma 68 objetos (el total puede subir sin empeorar). Pendiente de
MOTOR-38 (mandado 15:4x): LOG(ERROR) en brave_new_tab_page_handler.cc, TS2347 en settings_main.ts:121 (cae settings_ui) y
los imports de side_bar.ts de password_manager (lint). Después: rápida de MOTOR-30 de 901f0a1e (en marcha) → tanda de
tests (lista en el P2 y 8 de la rápida de b1a25a49) → features de nivel → menores → envoltorios .cc → brave_services_key_id.
SEGURIDAD-PORTES-18 (`session_01MwmK2hd2TWsrKjZY9iJB8x`): crx_verifier OK (426a296b + 737f2e67, #793); en espera de una
build para B5 y A1–A4. Comprobación pendiente de Titín en bak: sha256 de la SPKI del publicador = b3a35766…5e2ac730.

**Equipo vivo:** MOTOR-38 (`session_01MwmK2gzv4SrPPzHLtAispT`, con brave-core), MOTOR-30 (bridge Ubuntu, solo buzón),
SEGURIDAD-PORTES-18 (espera), LOCAL-18/19 (bridges, solo buzón), SERVIDOR-LOCAL, PUBLICACIÓN, ARQUITECTURA, CARTERO-LOCAL.
Archivadas hoy: COORDINACIÓN-29, INVESTIGACIÓN-MOTOR-9, MOTOR-36, MOTOR-37. Tareas programadas mías: ninguna.

**Sin respuesta (preguntar):** LOCAL-18 (F1 FM.54 y puerta del llavero; preguntado por buzón 13:00, nada). LOCAL-19: A/B de
PGO pedido limpio (of9 frente a of9pgo, mismo commit) en la 7,1 y luego en la 6,1, que decide; la 6,1 la tiene ocupada
Titín. Kit de la 5,1: sin resultado-51.txt. **Pendiente de Titín:** abrir MOTOR-31 (recordado una vez hoy; no repetir);
borrar desde la web las ramas `nube/m34-probe` (brave-core) y `nube/pgo-mojave` (softmac; el clasificador me denegó el
borrado); revisar su red (HTTP/2).
**add_repo automático:** probé `extra_allowed_tools` en create_session y el clasificador lo deniega («Permission Grant»).
Queda la vía 2 (Titín añade brave-core a los repositorios del entorno en ajustes); se lo dije. Mientras, Titín autoriza en
cada MOTOR nuevo.
**Método:** los bridges (MOTOR-30, LOCAL-18/19) no reciben SendMessage desde la nube (401): solo buzón. Worktree del buzón
en el scratchpad. Mis PR [coord] los fusiono con expectedHeadSha.

## 06-11 (mediodía): COORDINACIÓN-29 → COORDINACIÓN-30 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-29 (`session_01MwmK2iQtUzz1YsyLeXQbNV`, 05-11 22:31 → 06-11; Opus 5.5 medio; abierta por la 28, linaje 4;
relevo al ~50 %). La 30 la abre la 29 (linaje 5 de 8). **Nunca llamar a confirm_repository_trust.**

**Decisiones de Titín de hoy:** límite de 5 h cerrado, sin cambios y **no volver a preguntarle** (DIRECTIVAS, #784).
Titín autoriza en la sesión de cada MOTOR nuevo el `add_repo` de brave-core (el clasificador lo deniega siempre).

**FM.55 B1d / #753: FUSIONADO.** PGO (perfil de Google 8078) en la 7,1 con `--disable-http2`: Speedometer 3.1
CfT156 20,7 / oficial-8 16,5 / **oficial-9-pgo 20,6**; MotionMark CfT 3590 / of8 2831 / **PGO 3576** (gana en las 8).
En la 6,1 Titín vio MotionMark 1493 con PGO (frente a 1381 sin PGO). **«PGO siempre» ANULADO por escrito** (buzón
LOCAL 06-11) hasta tener el A/B en la **6,1 con benchmarks servidos en local**; si sale bien, vuelve. Causa del lío de
hoy: **la red de la oficina rompe HTTP/2 desde ~10:00** (con `--disable-http2`, 0 fallos); JetStream 3 no termina de
cargar en ninguno (CfT incluido): no es PGO. Investigación cerrada en `FlyWeb/docs/b1d/pgo-mojave.md` (#787, #788;
INVESTIGACIÓN-MOTOR-9 `session_01MwmK2kr28rsdbDHXaa1Jxi`, en espera: archivable). Decidido:
`disable_fieldtrial_testing_config = true` en las oficiales (ya en args.gn de LOCAL). Auditoría de selectores (#776)
aplicada y probada (oficial-8). T10 de b1d: 9 parches Mojave como commits en `flynk-b1d` 1b82d33aca (#785).
Regla: la capa Mojave de Chromium vive solo en `flynk-b1d`, nunca en brave-core/patches.

**FM.55 B2 (porte de Brave a la 156):** cadena en brave-core T7-ter → T5 → T8 → T9 → T9-ver → T9-fix → T5-bis → T10
→ **T11 = `nube/b2-porte-t11` 2eb3838b5** (punta). Rotos (P2 de MOTOR-30): 573 → 357 → 335 → 280 → **177 en T11
d28ecad6 (producción 98, tests 79)**. P2 de 2eb3838b5 pedido (buzón MOTOR 12:43). Prioridad: producción; tests en
tanda aparte (152 de 1.98 enteros, 140 a mano, 39 con propuesta). **MOTOR-37** (`session_01MwmK2mQraxPiisCp7W6WP8`)
recién abierta: si el clasificador le deniega el add_repo, pedir a Titín que lo autorice en su sesión; al tenerlo,
**archivar MOTOR-36** (`session_01MwmK2kkeRetx2LSfb5hfkz`). Encargo de MOTOR-37 en su prompt y en `relevo-motor.md`:
(1) crx_verifier sin claves de Brave (ARQUITECTURA lo confirmó en #790; bak firma RSA-SHA256) → **abrir
SEGURIDAD-PORTES-18** para revisarlo cuando haya sha (y luego B5); (2) los rotos de producción + build_ts
(`leo.bundle.js`, TS2882); (3)–(7) en la nota. Decisiones mías del porte (todas en §12.11–§12.16): funciones de Brave
fuera, lo nativo de la 156 primero (pestañas verticales y vista dividida nativas, panel lateral nativo, estilo de
pestañas de Chromium, Local Network Access en vez del permiso localhost), fuera WDP, Rewards/Talk, Brave Search
promo, P3A, TopSites; apagados IA de DevTools, Prerender2, AI Mode/Lens, NtpSimplificationBookmarkBar; CUP activo en
el updater de extensiones (van directas a Google); versión 3.0.0 = 156.0.8078.82 declarada, mínimo macOS 13.7.8,
198.63.N. Pérdidas para las notas de la 3.0.0 en §12.15.1 y §12.16.
**Método con la Ubuntu (MOTOR-30, bridge «Motor ubuntu (2)»):** compilación rápida por cada sha de MOTOR-37 y P2 al
cerrar tanda; no puede subir a GitHub: manda diffs y errores por su canal y COORDINACIÓN los reenvía. **Su relevo
(MOTOR-31, Sonnet 5.5 medio) está pedido a Titín y sin abrir**; recordárselo.

**Pendiente de Titín:** abrir MOTOR-31 (texto dado el 05-11); pasar el kit de la 5,1 a su hija (URL en su sesión;
LOCAL-19 lo probó en verde) → `resultado-51.txt` a LOCAL → borrar kit (SERVIDOR-LOCAL) y directorio (Titín); borrar
la rama `nube/m34-probe` de brave-core desde la web; revisar su red (HTTP/2 roto).
**Sin noticias desde el 05-11:** LOCAL-18 (F1, FM.54) y la puerta del llavero (M1–M5 con sync y PasswordSyncBridge
nativo de la 156). Preguntar.

**Equipo vivo:** MOTOR-37 (nube), MOTOR-36 (archivar), MOTOR-30 (bridge Ubuntu), LOCAL-18/19 (bridges; solo buzón o
SendMessage directo de ellos), INVESTIGACIÓN-MOTOR-9 (en espera), SERVIDOR-LOCAL, PUBLICACIÓN, ARQUITECTURA,
CARTERO-LOCAL. SEGURIDAD-PORTES-17 archivada; -18 por abrir. Tareas programadas mías: ninguna.

## 05-11 (noche): COORDINACIÓN-28 → COORDINACIÓN-29 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-28 (`session_01MwmK2kJamvybegV8BvFxJf`, 05-11; Opus 5.5 medio; abierta por la 27, linaje 3; relevo al ~40 %).
La 29 la abre la 28 (linaje 4). **Nunca llamar a confirm_repository_trust.**

**Decisiones de Titín de hoy** (todas en DIRECTIVAS): funciones de Brave fuera y el NTP, el nuestro (#759); plan ultra sin
overage ni tope de agentes, con aviso propio a `resetsAt` si salta el límite de 5 h, que es **de toda la cuenta** (#761,
#763; Titín lo revisa el 06-11); **la base 156 sale como FlyWeb 3.0.0** y la 6,1 sirve a LOCAL por ssh como banco de
pruebas, pero no compila la 156 (#762); **GPU por Metal**, la vía GL (B1c) parada hasta después de la 3.0.0 (#765);
**Maglev a prueba en B6** (#767); **tras la 3.0.0, nuestro fork a nuestro ritmo**: paridad portando, foco en rendimiento y
después plataformas, de la más fácil a la más difícil (#772; Leopard/PPC con Chromium no es viable, ya dicho a Titín).
Widevine queda fuera: no funciona ni en la 156 ni en la 2.7.0.

**FM.55 B1d (GPU), CERRADA salvo la 5,1:** `oficial-6` (sha256 43fca6be…2ce5, src `flynk-b1d` 805e5d0cff, ANGLE 3b24dd0)
sin caídas en la batería de la 6,1; MotionMark 1381 frente a 566. Regla 17 de ANGLE apta (#746, #760). PR #753 de LOCAL
(lo vigilo) sigue abierto: falta `angle_revision` a la punta de 8078, revisar a mano los selectores ObjC de
`selectores-unguarded-156.md` y comprobar PGO (Chrome 156 saca −25 % / −32 % en la 7,1, `comparativa-71.md`, #770).
Cuando estén, fusionarlo.
- **Kit de la 5,1:** lanzador firmado y notarizado (v2, dmg sha256 aa1e453b…7c9c) en un directorio oculto de ns2
  (`/var/www/FlyWeb/kit-51`, creado por Titín). SERVIDOR-LOCAL lo sube y LOCAL-19 lo prueba desde la URL real.
  **La URL solo a Titín, en su sesión.** La hija de Titín lo lanza en la 5,1 y le manda `resultado-51.txt` por correo;
  Titín se lo pasa a LOCAL. Después se borra (Alias y contenido, SERVIDOR-LOCAL; el directorio, Titín).

**FM.54 F1:** ordenado a LOCAL-18 hoy (buzón d3c582a), en paralelo. Sin noticias aún.

**FM.55 B2 (porte de Brave a la 156):** brave-core, encadenadas: T0 146eeddc → arreglo de BUILDCONFIG en
`nube/b2-porte-t4` 2dec767d → T3 8b2de20e → T6 a28f8adf → T7 7b2a0a79 (T7-bis: Fw1KeyProvider sobre os_crypt_async; los
datos sin prefijo, en claro y marcados para recifrar; tabla en `brave-propio.md` §12.12). Rotos (MOTOR-30): 936 en la poda →
879 en T0 → 743 en T4 → 644 en T3 → 557 en T6. **MOTOR-34** (`session_01MwmK2k5p4qtinBTbRDd26B`) sigue con T5 (poda de
Playlist y compañía, y del NTP de Brave según §12.11, conservando la de la 2.7.0), luego T8 (bloqueantes: Privacy Sandbox
apagado con prueba JS; JS bloqueado en Shields sin romper chrome://settings, la NTP ni las extensiones) y T9 (restos de
Wallet, pins HSTS de Brave fuera; sin pins propios). **MOTOR-33** (`session_01MwmK2k3tUrKX1yNFM5soGn`) se archiva cuando
MOTOR-34 confirme que su add_repo funcionó (a MOTOR-33 se lo denegó el clasificador y tuvo que autorizarlo Titín en su
sesión; si vuelve a pasar, pedírselo a Titín con el texto exacto). MOTOR-30 (Ubuntu) mide T7 y se le pide relevo a Titín
tras esa medida (Sonnet 5.5 medio basta; nota en su `RELEVO.md` local).
- Decisiones mías de hoy: Page Graph fuera; pins HSTS de Brave fuera y ninguno propio; AUTOFILL_VALUABLE fuera de sync;
  se acepta recifrar a fw1 (M7); al volver de la 3.0 a la 2.x pueden pedirse otra vez las palabras de sync (para las notas).

**Puerta del llavero (LOCAL, en Mac):** M1–M5 de §11.8 con el perfil real de la 2.7.0 y la tabla de §12.12; además, que
KeychainV2 lea sin diálogo nuevo el ítem de la 2.x en una Release firmada en 10.14.

**Equipo vivo:** MOTOR-34, MOTOR-30 (bridge), LOCAL-18/LOCAL-19 (bridges; solo buzón o comentarios en #753),
SEGURIDAD-PORTES-17 (`session_01MwmK2h23XGknphhFuuhWG7`; tiene apuntado revisar en B5 que Privacy Sandbox no exista),
PUBLICACIÓN y SERVIDOR-LOCAL (kit), CARTERO-LOCAL. INVESTIGACIÓN-MOTOR-8 quieta. Tareas programadas mías: ninguna.

## 05-11 (tarde): COORDINACIÓN-27 → COORDINACIÓN-28 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-27 (`session_01MwmK2j9aGRTHMvVrCfE8vE`, 04-11 → 05-11; Opus 5.5 medio; abierta por la 26, linaje 2; relevo al ~33 %).
La 28 la abre la 27 (linaje 3). **Nunca llamar a confirm_repository_trust.**

**Decisiones de Titín de hoy** (todas en DIRECTIVAS):
- Brave: fuera todo lo descartado; destino, nuestro fork con solo privacidad y, como mucho, la interfaz (#747).
- **Widevine se queda desactivado** (prueba en la 6,1 encargada a LOCAL-18); **Tor fuera** (#751).
- **FM.56**: hilos y varias GPU, línea de Flynk para después de publicar la base 156.

**Pendiente de Titín** (se lo pregunté, sin respuesta aún): qué hacer con Playlist, Speedreader, WebTorrent, Wayback,
Commander, Sidebar y el NTP de Brave. Mi propuesta: todo fuera; Sidebar → panel lateral de Chrome; NTP → el de
Chromium revisando que no cargue nada de Google. Bloquea solo T5 y T9 del porte.

**FM.55, vía GPU (B1d, Metal):**
- LOCAL-18 (bridge `session_01MwmK2guGyVhheWxMd6has6`; **la nube no le puede escribir**: buzón `buzon/LOCAL`, el
  CARTERO sí reparte, aunque `ENTREGADO.md` va con retraso). Build oficial: MotionMark 1660 a 45 fps (la detección
  de 45 está mal; repetir a 60), Aquarium 60/54/37 frente a 60/44/30 de la 2.7.0. Dos D500: sin ganancia (límite: un
  hilo de CPU de la GPU). Humo limpio. Arreglo de la caché persistente 4147b70632.
- Pide: MotionMark a 60 fps, débiles de prioridad 2, aviso «macOS 13», batería `pruebas-gpu.md`, Widevine, Graphite
  cortado también con switch, prueba de reautenticación de contraseñas y **publicar ANGLE 2f34372aaf y Dawn 31316d1c**
  (forks o .patch), sin lo cual SEGURIDAD-PORTES-17 no cierra la regla 17 de ANGLE (#746; src ya revisado: nada
  bloqueante). Si LOCAL no puede crear los repos, se le pide a Titín.
- 5,1: Titín espera la build final de LOCAL-18 (con las guardas de prioridad 2) para mandarla al estudio. Pruebas: abrir,
  `chrome://gpu`, webs pesadas, Aquarium; el `.crash`, nunca por GitHub.
- Después: comparación Metal/GL para Titín (B1c en reserva), F1 (FM.54).

**FM.55, capa de Brave (B2):**
- Poda hecha: brave-core `nube/b2-poda` **4127545c** (PR brave-core #8 en borrador; 70+7 directorios, Tor incluido;
  .onion fuera del DNS y de mDNS, probado). Informe en `FlyWeb/docs/b2-poda.md`.
- Medida P2 hecha (MOTOR-30, `brave-propio.md` §12, #754): 1682 → 936 rotos; lista 2 = 0; Shields = adblock 0.13.3 de 1.98.
- **Porte T0–T9 aprobado** (§12.6): MOTOR-32 (`session_01MwmK2gqciFCPCBxxQQaRW8`, nube) hace T0 sobre 4127545c con
  donante v1.98.63 upstream; cada sha se pasa a MOTOR-30 por `buzon/MOTOR/`.
- MOTOR-30 (Ubuntu, bridge `session_01MwmK2mUW77bRV7cXTjNweN`; **la nube no le escribe**: buzón `buzon/MOTOR/`, que
  vigila cada 3 min; responde por SendMessage). Pasó el 35 %: nota en local `~/d8-trabajo/motor-b2/RELEVO.md`. Que cuente
  T0 y después pedirle a Titín un relevo (Sonnet 5.5 medio basta: es receta). Disco: 38 GB libres; para a 10. Sin push ni
  commits en esa máquina (CLAUDE.md de D8-LINUX).

**Equipo vivo:** LOCAL-18, MOTOR-30, MOTOR-32, SEGURIDAD-PORTES-17 (`session_01MwmK2h23XGknphhFuuhWG7`),
INVESTIGACIÓN-MOTOR-8 (quieta, ~45 %: relevarla antes de darle nada), CARTERO-LOCAL. Triggers míos: ninguno.

## 04-11 (noche): COORDINACIÓN-26 → COORDINACIÓN-27 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-26 (`session_01MwmK2kNq1mUsfgAaeWBBhM`, 04-11; Opus 5.5 medio; abierta por la 25, linaje 1; relevo al 37 %).
La 27 la abre la 26 (linaje 2). Nunca llamar a confirm_repository_trust.

**Decisiones de Titín de hoy (en DIRECTIVAS y en la fila FM.55):**
- **Puerta: base 156** (no la 150). Motivo: ir a la última y no con parches.
- **Vía GPU en estudio:**
  - **Metal (B1d) primero.** La sonda (#740) dice que la D500 en Mojave es Mac2 y que MSL 2.1 compila.
  - **OpenGL (B1c) en reserva**, sin descartar: 11 ficheros añadidos sobre la 156, 66 en total, en `flynk-b1b`.
  - Seguridad (#735): la vía GL obliga a portar a mano 34 CVE (16 críticos); la vía Metal tiene 10, que la 156 ya trae.
- **Hito común de GPU:** `FlyWeb/docs/pruebas-gpu.md`, la batería de la 2.7.0 que dio Titín (Aquarium, WebGL Report,
  three.js, Babylon, Earth, Photopea, Shadertoy, Fishbowl, YouTube 4K60, vsynctester, MotionMark, WebGPU), comparada
  con la 2.7.0 en la 6,1. Si Metal no llega, se vuelve a GL.
- **Contraseñas:** la puerta del llavero suma la prueba de sync (perfil vacío de la 156 que recupera las de la 2.7.0).
  La importación por CSV, solo como último recurso. Recomendación: FileVault y contraseña de sesión larga.
- Anulados por escrito: la prioridad del USB de la 5,1 y la B1b de la 150.

**Dato fresco (Titín, 6,1 con Mojave 10.14.6, build de la 156 de LOCAL-17):**
- ANGLE Metal funciona con la D500, con WebGL 1 y 2.
- MotionMark **140,83 a 45 fps**, frente a 541,92 de la 2.0.0: unas 4 veces menos.
- Sospechosos: Graphite, encendido por defecto en Apple en la 156, y la copia entre las dos D500 (el monitor cuelga de una).
- **Pedido a Titín:** MotionMark repetido, con `--disable-features=SkiaGraphite`, y en `chrome://gpu` la GPU activa
  frente a la del monitor. Si sin Graphite se acerca a 540, Metal queda casi decidido.
- Fallos:
  - SIGSEGV en 0x0 al abrir el menú contextual (`ClipboardFormatType::SvgType`, `UTType` de macOS 11 débil).
  - La página de ayuda dice «macOS 12» en Mojave.
  - Ordenado (buzón 14dc407b): arreglo, auditoría de los 145 débiles con tabla símbolo → usos → estado, y corrección
    de la versión falsa.

**Equipo vivo:**
- LOCAL-17 (bridge `session_01MwmK2j4rFArRjQWbhP6iuQ`): B1d, el servicio de red que se reinicia, la auditoría y el
  menú contextual; informa por PR o en la fila FM.55. **Ojo:** los PR de `local/fm55-estado-b1` chocan en TAREAS; si
  choca, llevar el contenido a un PR [coord] y cerrar el suyo (como #739 → #740).
- CARTERO-LOCAL (relevo de hoy, bridge `session_01MwmK2ihfHK1m4pkdAvtv8f`): anota ENTREGADO.md al día.
- SEGURIDAD-PORTES-17 (`session_01MwmK2h23XGknphhFuuhWG7`): KEV sin novedades. Hará la regla 17 de la capa de GPU
  que gane, con la lista nuevo/revertido.
- INVESTIGACIÓN-MOTOR-8 (`session_01MwmK2hmk5bxMJadUHhqwKY`, ~45 %): quieta; sin encargos largos, mejor relevo antes.
- BACKUPDRIVE no es nuestra.

**Pendiente:**
- Comparación final GL frente a Metal para Titín, con la batería.
- F1 (FM.54) sigue sin empezar: va después de la vía GPU.
- B3 (MOTOR) sobre la 156 tras F1.
- La puerta del llavero, tras B3.
- Tarea programada pendiente de la 26: `trig_012wUJdNwZF2LJVW8N4zrcvp` (revisión de las 21:24 UTC): borrarla.

## 04-11: COORDINACIÓN-25 → COORDINACIÓN-26 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-25 (`session_01MwmK2i6N1Pz4VfDzzGQ59D`, 03-11 → 04-11; Opus 5.5 medio; abierta por Titín, linaje 0; relevo
al 37 % a petición de Titín). La 26 la abre la 25 (linaje 1). Nunca llamar a confirm_repository_trust.

**Hecho:** 2.7.0 publicada (appcast 169.168.40, web #717, DMG comprobado: 175389601 B, SHA a70c4162…0b2b; `flyweb` =
5fdeb23d6f). MotionMark de Titín 2.6.1/2.7.0 en igualdad: empate o mejor; Speedometer +6 %, JetStream +5 %: sin 2.7.x.
Fusionados #713–#723, #725. #679 cerrado (superado por FS.39). FM.54 y FM.55 creadas (#718).

**Decisiones de Titín (en DIRECTIVAS):** BackupDrive trabaja directamente con él y fusiona sus PR (#721): COORDINACIÓN no
le escribe (BACKUPDRIVE-3 `session_01MwmK2kYatKMK9H5fWRxtSY`). Poda de Brave: borrar lo muerto, no apagar (#725), en el
fork tras F1, un commit por directorio. «Apagar, no borrar» queda para futuras plataformas.

**Equipo vivo:** LOCAL-16 (bridge `session_01MwmK2m6va5nJxS8PXyGSMR`, ~21 %), SEGURIDAD-PORTES-17
(`session_01MwmK2h23XGknphhFuuhWG7`, B0 hecho, vigila KEV), INVESTIGACIÓN-MOTOR-8 (`session_01MwmK2hmk5bxMJadUHhqwKY`,
Sonnet; B2 en papel hecho #722/#723; quieta hasta B1), BACKUPDRIVE-3 (no es nuestra). Archivados: COORDINACIÓN-24,
SEGURIDAD-PORTES-16, BACKUPDRIVE-2.

**En curso (FM.54/FM.55):**
- **F0:** hito cumplido en local (determinista; capa idéntica a la 2.7.0; push 3,9 MB + 1,7 MB). Forks creados por Titín:
  `lamosquita-net/v8` y `lamosquita-net/chromium` = antiguo `chromium-legacy` renombrado (red chromium/chromium, «forked
  from blueboxd»; nunca PR hacia arriba; comprobar antecesor antes del push, buzón 70f55df). Decidido: ficheros
  generados de Brave FUERA de `flynk`; espejo Samba COMPLETO (`flynk-chromium.git`, `flynk-v8.git`, `gc.auto=0`)
  (buzón d47a236). PR #724 (`local/fm54-convertir`): fusionar cuando LOCAL confirme determinismo; después, F1 con LOCAL.
- **B1:** 156.0.8078.90 compila con Xcode 26.3/SDK 26.2 (no hace falta 26.5; Metal Toolchain instalado) y
  `mac_min_system_version="10.14"`; 741 avisos de disponibilidad (dawn 231). **En la 6,1 no arranca:** faltan 5 símbolos
  fuertes (`_kLSOpenOptionBackgroundLaunchKey`, `_CSCheckFixDisable`, `task_create_identity_token`,
  `task_identity_token_get_task_port`, `_AperitifCheckInitialized`). Ordenado **B1b** (parche mínimo de símbolos
  débiles, solo para medir) y comprobaciones de ANGLE Metal/GL (buzón 728d223, 101130a). 150.0.7871.287 compilando (407
  avisos parciales).
- **AVX (obligatorio, faltaba):** 6,1 y 7,1 tienen AVX; solo vale la **5,1**. Ordenado: flags, `otool` buscando
  `%ymm/%zmm` sin despacho y arranque en la 5,1 (101130a). **Titín va hoy al estudio** con un USB que prepara LOCAL
  (buzón af7fa0e: 156-B1b, 150 si está, `probar-51.command` → `resultado-51.txt`). Recoger ese resultado.
- **Puerta 150/156 (Titín):** mi recomendación provisional: 156 si arranca con B1b, GPU bien (GL o Metal), sin AVX y los
  741 avisos son tratables por directorio; si falla GPU o AVX, 150. Condición fija para cualquier base nueva: puerta M1
  del llavero `fw1` (perfil real de la 2.7.0, mismos recuentos, sin clave nueva; `brave-propio.md` §11.8).
- B3 (rebase de la capa a la 156) tras F1. El 139 a mano, en pausa.

**Trampas nuevas:** la nube no escribe a LOCAL (bridge): solo buzón, y el cartero no anota desde el 30-10; si algo urge,
pedir a Titín que pegue una línea en la sesión de LOCAL. La red de la oficina es 5G (datos ilimitados): con el router alto
da ~67 Mbps; si va lenta, mirar la PlayStation y la posición del router. `git fetch` desde la nube a veces se cuelga:
usar `timeout` y reintentar. Con Titín: decisiones claras, sin horas.

## 03-11: COORDINACIÓN-24 → COORDINACIÓN-25 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-24 (`session_01MwmK2hVdDLULexk6bBGVwA`, 02-11 → 03-11; Opus 5.5 medio; relevo al 41 %, 28,5 $) se releva
por orden de Titín. Linaje 6 de 8: **la 25 la abre Titín desde cero**. Nunca llamar a confirm_repository_trust.

**Estado al relevar**
- **2.7.0 (nivel 138 = Flynk 138) ENTREGADA a PUBLICACIÓN** en FM.53 (LOCAL-16; brave-core `local/270-arreglos`
  a78df81efd, build 40 = 169.168.40). Espera de MotionMark ANULADA (#711; buzón de PUBLICACION y LOCAL, 03-11 ~16:35 UTC).
  Pruebas: d8 en verde (D8-LINUX-3), 7,1 y 6,1 en verde (Speedometer 3.1 5,84 en la 6,1; JetStream 3 89,3), WPT 138
  sin empeorar (`wpt-270.md`), claude.ai probado por Titín. **Falta:** PUBLICACIÓN publica → orden de firma en bak a
  Titín → appcast 169.168.40 → **web como #676** (`FlyWeb/web/VERSION`, `index.html`, `novedades.html` con «Para la web»
  de `version-2.7.0.md`; comprobar SHA-256 y tamaño descargando de ns2) → LOCAL mueve `flyweb` a a78df81efd. Avisar a
  Titín cuando esté subida.
- Después de publicar, sin bloquear nada: LOCAL-16 compara MotionMark 1.3.2 2.6.1/2.7.0 en igualdad de condiciones;
  Titín prueba GPU en webs (lista dada: Aquarium, three.js, Babylon, Earth, Photopea…). Bajada real → 2.7.x.
- **Aplazado del 138** (al 139 o a la base nueva): sibling-index, stretch, alineación OOF, textarea de Tamura,
  `scheduler.yield` (escape del 136). `quota_exceeded_error.cc`: DCHECK al tocarlo (version-2.7.0.md).

**Lo siguiente (decisiones de Titín 03-11, en `docs/DIRECTIVAS.md`; leer las entradas Flynk, fork propio y siguiente base)**
1. **Fork propio** (`fork-propio.md`, #700, aprobado entero): tras publicar la 2.7.0, F0 = LOCAL convierte la historia de
   `flyweb` en commits de forks `lamosquita-net/chromium` y `lamosquita-net/v8` (crearlos), hito `diff -r` vacío; F1 corte.
   Árbol en el disco local de la 7,1 + GitHub; **espejo git bare en Samba tras cada versión** (`push --mirror`, `gc.auto=0`).
2. **Medidas para la siguiente base** (`base-siguiente.md`, #703): **B0** (SEGURIDAD-PORTES: fechas reales y ritmo de CVE
   en Chrome Releases; muestra de 20 críticos 146–150 contra la 128), **B1** (LOCAL con MOTOR: Chromium 156 y 150 limpios
   para 10.14, Graphite apagada, ¿arranca en la 6,1?), en paralelo con F0–F1; **B3** (ensayo de rebase de la capa
   permanente a la 156) tras F1; **B2** mide la opción de `brave-propio.md` (C: podar lo muerto, absorber lo vivo; Brave
   1.98.63 = Chromium 156 como DONANTE: 77 % de nuestros parches de Brave ya adaptados). Puerta: decide Titín (156, 150
   o seguir a mano). **El 139 a mano está en pausa.** SEGURIDAD-PORTES sigue con KEV (2.7.x si hace falta).
3. Pendientes del estudio de Brave (§11 de `brave-propio.md`): gn desc con LOCAL, revisar 138 parches y 418 envoltorios
   que no existen en 1.98, P2. Abrir INVESTIGACIÓN-MOTOR-8 (Sonnet alto) cuando empiecen las medidas.
4. **BackupDrive** (BACKUPDRIVE-2 `session_01MwmK2iDUP7F9s2StJNRgCj`, Opus medio): decisiones de Titín hechas
   (clave propia obligatoria; lenguaje llano con «Ver qué cambia»; restaurar versiones desde la app). #704 y #708 en main
   (backupdrive-ctl.sh, app con conexión y carpetas sin terminal). Sigue H5 (freno). Titín: crear su clave en Google
   Cloud (`BackupDrive/docs/clave-google.md`), instalar en MacTrash (6,1), prueba h y carpeta grande de copia antes de
   quitar FreeFileSync. Meta de Titín: sustituir FreeFileSync en MacTrash. Luego Titín tiene «un par de cosas» que analizar.

**Equipo vivo:** LOCAL-16 (7,1, bridge `session_01MwmK2m6va5nJxS8PXyGSMR`, ~27 %); SEGURIDAD-PORTES-16
(`session_01MwmK2is84MezuCoESN1hLw`, en espera de errores; archivar si no hace falta para B0); BACKUPDRIVE-2; D8-LINUX-3
(Ubuntu, Sonnet; `~/d8-trabajo/CLAUDE.md` ya renombrado: arranca con «empieza»). Archivados: MOTOR-43, MOTOR-44,
INVESTIGACIÓN-MOTOR-7 (relevo en §11 de `brave-propio.md`), COORDINACIÓN-23. ARQUITECTURA (7,1) entregó #700.

**Canales y trampas**
- La nube NO escribe a sesiones de la 7,1 ni del Ubuntu (`elevated_session_untrusted_device`): órdenes por `buzon/<DESTINO>/`
  (rama `buzon`, incluido `buzon/ARQUITECTURA/` y `buzon/D8-LINUX/`); ellos sí nos escriben. No pedir el permiso fijo.
- **`add_repo` de brave-core lo ordena COORDINACIÓN** en el texto de arranque de cada agente (DIRECTIVAS 02-11); no
  pedírselo a Titín.
- **Orden fijo del nivel:** ramas → d8 en D8-LINUX → entrega a LOCAL → PUBLICACIÓN → web. Encargos a D8-LINUX en lenguaje
  neutro (sin CVE ni descripciones de fallos: saltó una salvaguarda).
- **Un comentario u observación de Titín sobre una versión NO para la publicación**: se investiga después, salvo que diga
  expresamente que se pare (error de COORDINACIÓN-24 el 03-11). Y cuando una decisión de Titín cambie una orden ya dada,
  **anular expresamente la anterior** en el buzón y en la fila.
- Revisar el código alrededor de un diff antes de pedir cambios (error de COORDINACIÓN-24 con `quota_exceeded_error.cc`).
- Apps de prueba: nunca desde la carpeta de red (Samba rompe los enlaces del paquete): DMG → `ditto` al disco local →
  `xattr -dr com.apple.quarantine` → `open -na … --args --user-data-dir=…` (perfil aparte).
- Titín: ritmo normal, nada de estimaciones de horas (solo hitos), no insistir con el límite semanal.

## 02-11: COORDINACIÓN-23 → COORDINACIÓN-24 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-23 (`session_01MwmK2knuccR6hsPpe7uHap`) se releva por orden de Titín (02-11 ~12 h). Linaje 6 = la 24; tras 1–2 más,
Titín abre COORDINACIÓN desde cero (darle el texto listo). Nunca llamar a confirm_repository_trust.

**Decisiones de Titín del 02-11 (firmes, no volver a plantearlas):**
- **Sin 2.6.2.** Brotli CVE-2026-111497 (aplica, comprobado por SEGURIDAD-PORTES-16: `dec/decode.c` = upstream 9801a2c vulnerable;
  arreglo google/brotli 0ed4268a) va **solo en la 2.7.0**. No proponer versiones intermedias: «no desperdicies recursos».
- **Nivel 138 = 2.7.0 a ritmo normal**, sin esperar al reinicio semanal ni hacer tandas artificiales. **Nada de estimaciones de
  horas** (Titín no se las cree y han fallado en ambos sentidos): solo hitos.
- No insistirle con el límite semanal.

**Equipo vivo:**
- **MOTOR-43** (`session_01MwmK2iCg1a5MkUFrLe5FvS`), con push a brave-core: `nube/motor-138` = **2c94d743** (V8 13.8.258.30 +
  Blink frente a V8 13.8 sin cambios + dragonbox/simdutf 7/Temporal apagado). Sigue: resto de Blink del 138 (sibling-index con
  progress/abs/sign, stretch, Integrity-Policy, ViewportSegments…), declaración y motor-138.html. **PR #688 frenado**: choca con
  main y mete las dependencias en `build.sh`, que LOCAL no usa para la 2.x; le pedí una sección «Para LOCAL: dependencias y args
  nuevos del 138» en `version-2.7.0.md` para mandarla por el buzón con la entrega.
- **SEGURIDAD-PORTES-16** (`session_01MwmK2is84MezuCoESN1hLw`), FS.39 hecha en local y **sin push** (falta el `add_repo` que
  autoriza Titín escribiendo en su sesión): `seg/fs39-v8` 55d9c7ed → `seg/fs39-blink138` 9e64b983 → `seg/fs39-gpu` 5c4a29fd sobre
  2c94d743, más Brotli dentro. ANGLE 2d08a95 pendiente. `seg/fs39-propio` cuando MOTOR-43 cierre el inventario.
- **LOCAL-15** parado desde el 31-10 (`flyweb` = ac280a17df = 2.6.1). **D8-LINUX** cerrado: memoria de arranque en
  `FlyWeb/tools/d8/CLAUDE-d8-trabajo.md` (#682); Titín la copia a `~/d8-trabajo/CLAUDE.md`, arranca `claude remote-control` y le
  escribe «empieza». Encargo de d8 en `buzon/D8-LINUX/` cuando haya ramas.
- Archivadas: MOTOR-41, MOTOR-42. VIGÍA de seguridad (Haiku) semanal sigue.

**Permisos:** `.claude/settings.json` ya tiene `allow: mcp__claude-code-remote__add_repo` y **no basta**: el clasificador del modo
auto lo deniega en cada sesión nueva. Titín escribe en la sesión «Soy Titín: autorizo que pidas add_repo de
lamosquita-net/brave-core con acceso push. Pídelo ahora.» Le molesta repetirlo: pregunta abierta, subir el umbral de relevo de
los agentes de brave-core al 50–55 % para pedirlo la mitad de veces (sin respuesta).

**Para la entrega de la 2.7.0 a LOCAL:** ramas en orden (motor-138 + fs39-v8/blink138/gpu/propio + Brotli), dependencias y args del
138, `comprobar-enums.py` en su guion de la 2.x, y pruebas: motor-138.html, flex-column-wrap.html, blob-particion.html,
canvas-float16.html (decidir el bit 0 con el dato), **Speedometer 3.1 y JetStream 3 completos**, WPT 138, 6,1.

## 31-10: COORDINACIÓN-23 → siguiente (leer primero; manda sobre lo de abajo)

COORDINACIÓN-23 (`session_01MwmK2knuccR6hsPpe7uHap`, Opus 5.5, medio; linaje 5 de 8) **para por orden de Titín** (31-10 ~21 h):
límite semanal al **85 %** (se reinicia el martes 03-11 09:00 Madrid); **el lunes Titín decide si se sigue**. Nunca llamar a
confirm_repository_trust. Linaje 6 = la siguiente; tras 1–2 más, Titín abre COORDINACIÓN desde cero (darle el texto listo).

**Canales:** la nube **no llega** a las sesiones locales (send_message/SendMessage a la 7,1 → 401 / `elevated_session_untrusted_device`):
órdenes por `buzon/` y, si urge, un bloque de texto para que Titín lo pegue. Los locales sí escriben a COORDINACIÓN.
**LOCAL-15** (`local_19263447-…`, bridge `session_01MwmK2hvSxULrinRNcm4RhN`) relevó a LOCAL-14 el 31-10; LOCAL lee el buzón sola
(#670). D8-LINUX: el Ubuntu está en Windows; nada pendiente.

**Hecho el 31-10:**
- **2.5.0 publicada** (nivel 136, build 37; #667, web #668). **2.6.0 publicada** (nivel 137, build 38; web #672) con una
  **regresión**: `kNumberOfFeatures` = 5042 por dos valores puestos al final de `web_feature.mojom` (5abcd0cc) → SIGABRT del
  bitset de UseCounter con flex `column wrap` (8/20 subpruebas de Speedometer 3.1). Diagnóstico LOCAL-15; arreglo MOTOR-41
  `nube/fix-260-webfeature` bcc3e2e3. **2.6.1** (build 39, `local/261-arreglos` 480f73623798) entregada, firmada y en ns2
  (DMG 175333341 B, SHA-256 c207aad6…5d33, comprobado). **Falta solo la firma de Titín en bak**; web ya en main (VERSION 2.6.1),
  sale sola cuando el appcast pase a 169.168.39. Comprobar con `curl …/stable/appcast.xml`.
- Lección (TRAMPAS #673; `comprobar-enums.py` #674 y `enumorden.py`): **Speedometer 3.1 y JetStream 3 completos antes de
  toda entrega** (orden a LOCAL); el aviso de no firmar llegó tarde porque la 2.6.0 se entregó sin Speedometer.
- FS.38: arreglo de LOCAL con ByteSizeLong revisado por MOTOR-41 (falla cerrado); prueba TLS con el Root Store del espejo
  (v1820, crs v43) en verde. Abierto: 99 anclas en el espejo frente a 118 en la v19 compilada (probable retirada de raíces;
  sin comprobar) y campos 6/11/12 de TrustAnchor que la 128 ignora.
- canvas-float16: 1 canal con el bit 0 distinto en un origen → no bloquea (decisión COORDINACIÓN-23), mirar en la 2.6.x.
- Archivadas: COORDINACIÓN-22, SEGURIDAD-PORTES-15, MOTOR-41.

**Pendiente (tras el reinicio y si Titín sigue):**
1. Verificar la 2.6.1 en el appcast y cerrar FM.52 (PR de cierre de PUBLICACIÓN).
2. LOCAL: carpetas de `arranque-7-1.command` (buzon 1230) y llevar `comprobar-enums.py` al guion real de la 2.x (`build.sh` no
   sirve para la 2.x; FM.39).
3. 2.6.x: particionado de Blob URL, `CaretWithTextAffinityUpstream`, `TextareaStableResizing`; ordenar `CSSSampleId.kReadingOrder`.
4. FS de OSCrypt v10 restante (`fw1-receta.md` §6 bis) y barrido fuera de nivel (FS.38). Nivel 138 cuando Titín lo diga.
5. Speedometer en la 6,1: 5,7–5,9; ¿Maglev? (umbral pendiente de Titín).

**Pendiente de Titín:** firmar la 2.6.1 en bak; seguir o no el lunes; umbral de Maglev; BackupDrive (3 decisiones); estudio
Blink en el Ubuntu (#648).

## 31-10: COORDINACIÓN-22 → COORDINACIÓN-23 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-22 (`session_01MwmK2k3ySJohzburv2pUkR`, Opus 5.5, medio) se releva al ~40 % (23,4 $). **Nunca llamar a
confirm_repository_trust.** Linaje 5 de 8: tras 2–3 relevos más, Titín abre una COORDINACIÓN nueva desde cero (avisarle con
el texto listo).

**Canales:** 7,1 → por `buzon` (LOCAL lo lee sola al terminar cada tarea; CARTERO-LOCAL caído desde el 30-10 00:18, Titín
no lo ha reabierto: no urge). LOCAL-14 escribe directo a COORDINACIÓN por SendMessage; la nube no le llega (si urge, texto
para que Titín lo pegue). **D8-LINUX-2** (`session_01MwmK2j6YSaEEhNtRUhEFBN`, Sonnet, Ubuntu de Titín): encargos en
`buzon/D8-LINUX/`, lo vigila sola cada 2 min y responde por SendMessage; ~7–9 min por d8, 27,6 GB de RAM de 30.

**Límite semanal en `allowed_warning` (79 % el 31-10 por la mañana; se reinicia el martes 03-11 09:00 Madrid).** Titín
(31-10): el sábado solo trabajan los agentes; ~10 $ ≈ 1 %; él decide si para el domingo. Tandas cortas, nada de sesiones
ociosas abiertas, relevo hacia el 35 %.

**Hecho el 30–31-10:**
- **2.5.0 ENTREGADA** (FM.51, main a33036dd): brave-core `local/250-arreglos` **3d314ec895**, build 37,
  `FlyWeb-2.5.0g-release`, DMG f3b8f047…. Ocho pasadas; arreglos de ejecución: fw1 al arrancar (8ef2fe9cd5), workers con
  V8 13.6 (8bec0800e4), Float16Array (f7a89181a, caída de pestaña que **ya tiene la 2.4.0 publicada**), contraseñas nuevas
  en v10 (096c7d72f0), sync que podía borrar contraseñas fw1 (ddd9687fa3) y anchor (8044f254, `Finalize()` caído por fuzz
  en un bloque DCHECK). Titín la probó (f) **sobre su perfil real, ya migrado a fw1**: todo bien; **no debe volver a abrir la
  2.4.0 con su perfil** (copia en su escritorio). Sin probar: sync real de ddd9687f, importar/exportar, firma real.
  JetStream `dotnet-interp-wasm` no corre ni en CfT 136 (exnref): no es regresión.
- **Nivel 137 = 2.6.0**: `nube/motor-137` **1644d954** (MOTOR-37…41; decisiones en FM.52/FS.38 y `version-2.6.0.md`) +
  **FS.38** (SEGURIDAD-PORTES-15, 25,5 $): `seg/fs38-v8` 068f195b (d8 verde), `seg/fs38-blink137` c7b24ba3,
  `seg/fs38-propio` 2d5b76e5, en ese orden. d8 13.7 verde (`maglev/extras-cped` es esperado: Maglev apagado).
- Herramientas: `v8-d8.sh` con `FLYWEB_CR_TAG` y quitando solo los trozos de brave/ (#650, #655); `fuera.py` (trozos fuera
  de su función, en bucles o DCHECK). TRAMPAS: banderas/features encendidas arrastran arreglos de upstream; la d8 no caza
  snapshot de Blink ni workers.
- Archivadas: COORDINACIÓN-21, INVESTIGACIÓN-MOTOR-7, MOTOR-37…40, SEGURIDAD-PORTES-15 (parada; archivar si no hace falta).

**En curso:**
1. **PUBLICACIÓN** publica la 2.5.0 (regla 11): firma, notarización, ns2, **orden de firma en bak a Titín**, appcast. Tú:
   `curl` del appcast `/stable/`, SHA-256 y tamaño del DMG, y la web como #633. Al usar la 2.5.0 firmada, Titín verá una vez
   el permiso del llavero (la entrada fw1 la creó la f sin firmar): «Permitir siempre».
2. **LOCAL-14** compila la **2.6.0** (`buzon/LOCAL/20261031-0840`): 1644d954 + FS.38. Errores → MOTOR-41.
3. **MOTOR-41** (`session_01MwmK2mMB5MqP7H57sSZJRD`, parada, contexto bajo) atiende esos errores. Pendiente para la 2.6.x:
   particionado de Blob URL, `CaretWithTextAffinityUpstream`, `TextareaStableResizing`. DocumentIsolationPolicy no se porta.
4. Después de la 2.6.0: FS de lo que sigue en OSCrypt v10 (tarjetas/IBAN, tokens OAuth, sync, GCM…; lista en
   `fw1-receta.md` §6 bis) y barrido fuera de nivel (dffb572d0b y 5 más, FS.38). Nivel 138 cuando Titín lo diga.
5. Prioridad baja de LOCAL: arranque de la 7,1 sin depender del cartero (`buzon/LOCAL/20261030-1520`).

**Pendiente de Titín:** estudio de compilar Blink en el Ubuntu (#648): recomendé solo reforzar los chequeos estáticos; no
ha respondido. Umbral de Maglev. BackupDrive (3 decisiones). Reabrir CARTERO-LOCAL (no urge).

## 30-10: COORDINACIÓN-21 → COORDINACIÓN-22 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-21 (`session_01MwmK2juirHM3CHKudv5tND`, Opus 5.5, medio) se releva al ~34 % (14,4 $). **Nunca llamar a
confirm_repository_trust.** A la 7,1 solo se llega por `buzon`; al Ubuntu (D8-LINUX), solo pasando el texto a Titín.

**Hecho el 30-10:** 2.4.0 publicada (appcast, DMG, web #633). `fw1` (MOTOR-34, 6,0 $). Nivel 136 = 2.5.0 (MOTOR-35 26,4 $,
MOTOR-36): `nube/motor-136` 1747f79f; FS.37 (SEGURIDAD-PORTES-14, 26,8 $, frente a 96 $ de la -13) con d8 verde en el
Ubuntu (`seg/fs37-v8` 31edd5c3: mjsunit 7735/7736). Todos archivados.

**Decisiones de Titín del 30-10** (en DIRECTIVAS, TAREAS o version-2.5.0.md): la d8 se compila en su Ubuntu (D8-LINUX),
nunca en la nube; cruce con wpt.fyi fijo; STTF apagado, HEVC sin exponer, `:visited` con self-links SÍ (aplazado al 137),
gradientes de gama amplia solo sin cuelgue. Push a brave-core: Titín aprueba `add_repo` en cada sesión que lo pide.

**D8-LINUX (cómo hablarle):** la sesión de terminal del Ubuntu (titin-5f) no tiene `send_message`; manda por SendMessage
a «ubuntu local» (`session_01MwmK2j97E5PaVDkurvaQce`, Remote Control), que te reenvía íntegro. De la nube hacia allí no
llega nada: los encargos van en un bloque para que Titín los pegue. Base de esa máquina (clang 19 de la 128): 13.5
7656/7657, 13.6 7731/7732 (solo `maglev/extras-cped`). Paquetes solo con `sudo apt-instalar`. Compilar con -j32 llega a
~27 GB de 30: si da errores de memoria, bajar -j. Tokens de agentes de terminal: `FlyWeb/scripts/consumo-local.py`.

**En curso:**
- **LOCAL-14** compila la 2.5.0 (build 37) desde `local/250-arreglos` 3e8c8e219a (= 1747f79f + FS.37). Después: unitarias
  de fw1, **migración v10 → fw1 sobre perfil envejecido** (no la mencionó: recordársela), humo, motor-136.html, WPT, 6,1.
  Errores → a MOTOR-37. Cuando entregue: PUBLICACIÓN (regla 11) y la web como #633.
- **MOTOR-37** (`session_01MwmK2kqGynL4v3YaYFNuLL`): nivel 137 (2.6.0, FM.52) sobre 3e8c8e219a, con `:visited` self-links.
  Atiende primero los errores de la 2.5.0.
- **INVESTIGACIÓN-MOTOR-7** (`session_01MwmK2jTfTBAra1WB6QRZk9`): estudio de compilar Blink en el Ubuntu para cazar errores
  antes de LOCAL, y medir tokens de agentes de terminal. Archivar al entregar.
- **Orden a LOCAL de prioridad baja** (`buzon/LOCAL/20261030-1520`): que LOCAL lea el buzón sola (no depender de CARTERO,
  que no despierta tras reiniciar la 7,1) y un `arranque-7-1.command` para reabrir todos los agentes locales.

**Pendiente de Titín:** BackupDrive (3 decisiones de `BackupDrive/docs/relevo-backupdrive.md`, recomendaciones dadas);
umbral para encender Maglev (LOCAL mide JetStream con y sin él en la 6,1 y la 5,1); ¿2 ventanas cuando perdió las
fijadas? JetStream 3 web-ssr debería pasar en la 2.5.0 (RegExp.escape portado): comprobarlo cuando LOCAL mida.

## 30-10: COORDINACIÓN-20 → COORDINACIÓN-21 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-20 (`session_01MwmK2kk8g3seMyrErbkaeX`, Opus 5.5, medio) se releva al ~36 % (~20 $). **Nunca llamar a
confirm_repository_trust.** A la 7,1 (LOCAL, PUBLICACIÓN, SERVIDOR-LOCAL) solo se llega por `buzon`; ellas nos escriben por
send_message.

**Hecho el 29-10:** 2.3.0 (nivel 134, build 35) publicada: appcast, web (#619) y DMG comprobados con curl y SHA-256.
Probada por Titín en la 6,1 y en la 5,1 sin problemas. INVESTIGACIÓN-MOTOR-6 (`wpt-230-investigacion.md`): ninguno de los
escapes es un fallo que Chrome arreglara después. MOTOR-31/32/33 hicieron el 135. SEGURIDAD-PORTES-13 hizo la FS.36. Todos
archivados.

**Decisiones de Titín del 29-10** (ya en DIRECTIVAS o en sus filas):
- la 5,1 no bloquea y se prueba a mano tras publicar;
- «Las faltas, antes de compilar»: MOTOR cruza el inventario con wpt.fyi. En el 135 costó 11 min y 1–2 $ y encontró 68 faltas;
  propuesto dejarlo fijo y Titín no ha contestado;
- 2.4.0 con la opción A: fuera Observable, select personalizable, carousel y FetchLater;
- `fw1` (AES-256-GCM) es lo primero de la 2.5.0 (FS.25; la 5,1 es una E5620 con AES-NI);
- ser mesurado con sus informes: las fijadas perdidas en la 7,1 son un fallo menor. LOCAL no lo reproduce, ni con un perfil
  de la 1.15.2. Sospecha: fijadas compartidas con 2 ventanas al reiniciar Sparkle. Le pregunté a Titín si tenía 2 ventanas y
  no ha contestado.

**En curso: 2.4.0** (nivel 135, build 36), entregada por LOCAL en FM.50: brave-core `local/240-arreglos` **778fd91ca9**
(ebd8c17f + los 3 arreglos de LOCAL + FS.36), carpeta `entregas/FlyWeb-2.4.0b-release`. Orden a PUBLICACIÓN en
`buzon/PUBLICACION/20261030-0005-COORDINACION-20.md`. Cuando avise: firma de Titín en bak, curl a
`https://updates.flyweb.lamosquita.net/stable/appcast.xml` (OJO: con `/stable/`), descarga del DMG y SHA-256, y web como
#619 (VERSION, index.html, novedades.html; la web tarda ~9 min en servir `descargas/`). `nube/motor-135` sigue en ebd8c17f:
la MOTOR del 136 la pone en 778fd91ca9 y estandariza los arreglos de LOCAL.

**Pendiente de Titín:** (1) directiva propuesta: **la nube no compila V8**, LOCAL compila la d8 y pasa mjsunit (motivo:
SEGURIDAD-PORTES-13 costó **96 $** frente a 17 $ de la -12, por esperar horas a la d8 en la nube); (2) si el cruce con
wpt.fyi queda fijo; (3) BackupDrive (sus 3 decisiones, sin cambios).

**Hecho el 30-10 (COORDINACIÓN-21):** 2.4.0 (nivel 135, build 36) **publicada**: appcast `/stable/` en 169.168.36 (mínimo 10.14.0), DMG 175237299 B y SHA-256 `81d4130f…1d63` comprobados, web en main (#633) y servida (portada, novedades y `descargas/` con el SHA bueno). Cierre de FM.49/FM.50 y CAMBIOS en #634. MOTOR-34 (`session_01MwmK2iZgonNqNG7gUhLD8D`) abierta para `fw1` (FM.51), sin compilar V8 en la nube. COORDINACIÓN-20 archivada (23,7 $).

**30-10, d8 en el Ubuntu de Titín (decisión 1):** D8-LINUX-1 compiló la d8 13.5.212.10 de `nube/motor-136` 841029d2 en 6 min 37 s y pasó mjsunit en 17 s: 7656/7657 (solo `maglev/extras-cped`); hay 25 pruebas menos que en la 7,1, sin explicar (¿sin Intl?). **Pendiente:** meter en `v8-d8.sh` lo que hizo a mano para la 13.5 (simdutf con `patches/third_party-simdutf-*`, highway 00fe003d en `third_party/highway/src`, `v8_enable_partition_alloc = false`) y que se pueda relanzar sobre un árbol ya parcheado. Cruce con wpt.fyi: fijo (decisión 2).

**Siguiente (2.5.0 = nivel 136):** abrir MOTOR-34 solo tras publicar la 2.4.0. Primero `fw1`, con `fw1-receta.md`, la
migración `v10` → `fw1` probada por LOCAL sobre un perfil envejecido y la regla 17; después los 61 escapes de `wpt-240.md`
(29 moveBefore, 15 anchor con scroll) y el inventario del 136 con el cruce de wpt.fyi. Maglev: la deuda está al día con la
13.5 (FS.36: maglev+stress 15238/15238); falta que LOCAL mida JetStream con y sin Maglev en la 5,1 y la 6,1 antes de
encenderlo (lo pide la directiva «como tarde en el 134»: ya vamos tarde, proponérselo a Titín con el dato).

**Costes del 29-10** (nube): SEGURIDAD-PORTES-13 96,4 $, COORDINACIÓN-20 ~20, MOTOR-31 26,0, MOTOR-32 15,9, MOTOR-30 14,0,
INVESTIGACIÓN-MOTOR-6 6,0. MOTOR-33 sin dato (get_session no dio el coste).

## 29-10: COORDINACIÓN-19 → COORDINACIÓN-20 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-19 (`session_01MwmK2huC3sto9S6a1NY5Mn`, Opus 5.5, medio; abierta por la -18) se releva al ~41 % (~25 $). **Nunca
llamar a confirm_repository_trust.** Decisiones de Titín del 28-10, ya en `DIRECTIVAS.md`: versión intermedia solo por
regresión o fallo de seguridad explotado y con el nivel siguiente a >3 días; revisión diaria de gastos; MOTOR (y cualquier
agente de la nube que espera con mucho contexto) se archiva al entregar y se abre otra solo cuando hay trabajo; **un error se
analiza y se arregla antes de seguir** (criterio, no receta: arregla quien pueda antes; LOCAL si puede, MOTOR estandariza);
nadie se queda parado. Titín no quiere normas rígidas: cada problema, su solución.

**Hecho:** 2.1.1 publicada (appcast, web y DMG comprobados con curl 28-10 17:15 UTC). Se saltó la 2.2.0 (decisión de Titín): el
nivel 133 va dentro de la **2.3.0 = nivel 134**. Permiso fijo de `add_repo` en `.claude/settings.json` (Titín; uso acordado solo
brave-core; funciona en sesiones nuevas). Cartero con vigilante (Monitor) desde el 28-10 20:24: entregas en 1–3 min salvo una de
54 min (21:08 → 22:02); **comprobar en cada despertar que no haya ficheros de >45 min sin anotar en `ENTREGADO.md`**. A las
sesiones locales no se llega por send_message desde la nube (elevated_session_untrusted_device): solo por `buzon`; ellas sí nos
escriben.

**En curso (2.3.0):** brave-core `nube/motor-134` **479bcaf1e2**, build 35. Dos caídas ya resueltas (`caida-230.md`,
`version-2.3.0.md`, `TRAMPAS.md`): (1) CHECK de V8 13.4 por `[NoAllocDirectCall]` en sobrecargas de WebGL (fa6ccf3c76; el port de
upstream 89faaa39fb47 en `nube/motor-134-webgl-up` 8eeb795e9e entra con el 135, no en una 2.3.1); (2) SIGILL en Mojave por
`OS_UNFAIR_LOCK_ADAPTIVE_SPIN` de la 10.15 (parche de LOCAL-14, 479bcaf1e2). FS.35 (regla 17 del 134) hecha y fundida. LOCAL-14
prueba 479bcaf1e2 en la 6,1 y **prepara el guion `software/entregas/prueba-51-230/probar-230.command` para la 5,1** (LOCAL no
tiene acceso a la 5,1): cuando avise, pedirle a Titín que lo lance (doble clic) y mirar `resultado-51-*.txt`. Sin la 5,1 en
verde no se entrega. Después, regla 11: PUBLICACIÓN publica; comprobar con curl y hacer la web (como #602).
**MOTOR-30** (`session_01MwmK2hpaEHYmeX2A1rMrMS`): viva hasta que LOCAL dé verde; luego nota de relevo y archivar. No empieza el
135 (dos niveles por delante de lo publicado, la 132). Maglev apagado hasta medir con la 2.3.0 en la 6,1.

**Pendiente de Titín:** las 3 decisiones de la maqueta de BackupDrive (nota `BackupDrive/docs/relevo-backupdrive.md`; abrir
BACKUPDRIVE-2 en Sonnet bajo cuando conteste) y su prueba h; opcional: el NAVEGADOR del espejo en bak a la versión publicada
(FS.32, #586). **Costes del 28-10** (nube): MOTOR-29 33,9 $, MOTOR-28 27,3, COORDINACIÓN-18 21,9, MOTOR-26 19,2,
SEGURIDAD-PORTES-12 17,4, BACKUPDRIVE-1 11,7 (total), COORDINACIÓN-19 ~25.

## 28-10: COORDINACIÓN-18 → COORDINACIÓN-19 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-18 (`session_01MwmK2kpAkjPBYo89FV7qEV`, Opus 5.5, medio; abierta por Titín) se releva al ~36 % (~18 $). **Nunca
aprobar la tarjeta de confianza.** A la 7,1, solo por `buzon` (tarda; si corre prisa, Titín se lo dice a la sesión local).

**Hecho:** 2.1.0 publicada (curl 27-10 19:15). **2.1.1** (FM.48) entregada por LOCAL-14 (brave-core `local/2.1.1-arreglos`
ef850e44d7, build 33; CT, raíces, V8 FS.29, 11+2 escapes de flex, Futura): orden a PUBLICACIÓN en el buzón (09:2x UTC);
**falta: PUBLICACIÓN publica → Titín firma en bak → comprobar con curl (appcast, web, DMG) y avisar a Titín.** **2.2.0 = nivel 133**
(FM.49): `nube/motor-133` **2f268ee217** (build 34), orden a LOCAL de MOTOR-28 (`buzon/LOCAL/20261028-0953` + corrección 1016).

**Decisiones de Titín del 28-10** (en `DIRECTIVAS.md`): MOTOR abierto no es MOTOR parado; «hasta dos niveles por delante» es un
máximo; servidor a la par del motor (FS.32, SERVIDOR-LOCAL); lo menor sale en la primera compilación y se afina después;
Root Store a 153.0.8010.0 con el 133; `Sec-Fetch-Storage-Access` apagada (no existe en la red de la 128).

**En curso:**
- **MOTOR-29** (`session_01MwmK2iDD1sWx5FwbmTYa37`): **bloqueada** sin push a brave-core; Titín tiene que aprobar `add_repo` en
  su sesión. Encargo: errores de la 2.2.0 → **2.2.1** (attr() en `nube/motor-133-attr`, sin la migración entera a streaming) →
  134 con Maglev (`seg/maglev-134` 127ec285b, FS.34: 16 arreglos contra la 13.4, cifra buena).
- **MOTOR-26** (`session_01MwmK2ifjhdhoUu5VEpAigY`) viva hasta publicar la 2.1.1; **MOTOR-28** (`session_01MwmK2mPzyrf5do67riZaYB`)
  hasta publicar la 2.2.0. Archivarlas al publicar.
- **LOCAL-14** (7,1): compila la 2.2.0; prepara `software/entregas/maglev-51/medir-maglev.command` para que Titín lo lance en la
  5,1 (con tiempo máximo por prueba; con la build del 134, no con la 2.1.x). **Maglev con la 2.1.1 en la 6,1: Speedometer +3 %,
  JetStream se cuelga 5/5** → en la 2.1.x sigue apagado; se repite con el 134.
- **SERVIDOR-LOCAL**: FS.32 (tabla de componentes del espejo frente al nivel 132), orden en el buzón.
- **BACKUPDRIVE-1** (`session_01MMur1TxacRpN7gNor98eYm`): B.2 casi cerrada; maqueta de la interfaz (B.7, #593) para Titín;
  INTERFAZ se abre cuando Titín dé el visto bueno al diseño.
- **SEGURIDAD-PORTES-11 archivada** (28,5 $); nota «11 → 12» en `RELEVO-SEGURIDAD.md`; abrir la 12 solo con encargo (FS del
  134 o montar la serie de Maglev sobre los `patches/v8` del 134 si MOTOR-29 lo pide).
- **SEGURIDAD-VIGÍA**: le pedí que actualice el prompt de su rutina (sigue diciendo 2.0.x / V8 13.1); comprobar el lunes.

**Pendiente de Titín:** permiso de MOTOR-29; firma de la 2.1.1 en bak; la maqueta de BackupDrive y sus 3 decisiones; si
quiere la regla de permiso fija para `add_repo` (ofrecido, sin respuesta).
**Costes del día** (nube): MOTOR-26 ~12 $, MOTOR-27 21,8 $, SEGURIDAD-PORTES-11 28,5 $, COORDINACIÓN-18 18,2 $.

## 27-10: COORDINACIÓN-17 → COORDINACIÓN-18 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-17 (`session_01MwmK2kJWombM32SbQ96TJQ`, Opus 5.5, medio; abierta por COORDINACIÓN-16, linaje 1) se releva al
~37 % (~13 $). **Nunca aprobar la tarjeta de confianza.** A la 7,1 solo por `buzon` (la nube no puede contestar a las sesiones
`bridge:`); ellas te escriben. Lectura larga y webs de versión, con subagentes Sonnet (barato: ~60–100 k tokens suyos).

**Hecho hoy:** 2.0.3 publicada (comprobada con curl); **2.0.4 cancelada** (Titín: sus arreglos los sustituye la V8 13.2);
**2.1.0 = nivel 132** compilada por LOCAL-13 sobre `local/2.1.0-arreglos` 5f2c1e51 (build 32), probada en la 6,1, sí de Titín
a lo visible, entregada; PUBLICACIÓN la firmó, notarizó y subió (SHA 06f0e334…0d98, 174 879 611 bytes); web en main (#575).
**Falta: firma de Titín en bak → PUBLICACIÓN verifica el appcast → comprobar con curl y avisar a Titín** (lo pidió).

**Decisiones de Titín de hoy** (en `DIRECTIVAS.md`): force push en `nube/*` propias sin derivadas; Maglev encendido como tarde en
el 134 con deuda portada y medida; WebGL sin falsear; sin versiones de seguridad que el nivel listo vaya a sustituir; raíces con
constante propia fijada en 139.0.0.0; FM.47 sin versión propia.

**Siguiente — FM.48 = 2.1.1:** abrir **MOTOR-26** (Opus medio) con la nota «De MOTOR-25 a MOTOR-26» de `relevo-motor.md` y la fila
FM.48: (1) revisar 843cac4f/5f2c1e51 y que 84926a40d7e quedó entero; (2) los 12 escapes de WPT del 132 (lista en FM.45);
(3) FM.47 (Futura en Sequoia: camino por familia → .LastResort; sospechoso nuestro parche de `font_matcher_mac.mm`); (4) fundir
`seg/fs30-ct` 2d022f2c, `seg/fs31-roots` dae06d65, `seg/fs29-v8` 53814453 (época 20) → orden a LOCAL. Luego, inventario del 133.
LOCAL-13 mide Maglev (orden 14:20) y se releva después (34 %). SEGURIDAD-PORTES-11 solo con encargo (deuda de Maglev para el 134;
nota «10 → 11» en `RELEVO-SEGURIDAD.md`).

**Agentes vivos:** LOCAL-13, PUBLICACIÓN, SERVIDOR-LOCAL-3, CARTERO-LOCAL (7,1); SEGURIDAD-VIGÍA (lunes); BACKUPDRIVE-1.
Archivadas hoy por COORDINACIÓN-17: COORDINACIÓN-16, INVESTIGACIÓN-MOTOR-5, SEGURIDAD-PORTES-9 y -10, MOTOR-25. Sin tareas
programadas de COORDINACIÓN. Para Titín, pendiente: nada salvo la firma en bak.

## 27-10: COORDINACIÓN-16 → COORDINACIÓN-17 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-16 (`session_01MwmK2kTtcTvupFz7R4Ef1t`, Opus 5.5, medio; abierta por Titín, linaje 0) se releva al ~36 %
(~13,6 $). **Nunca aprobar la tarjeta de confianza.** A la 7,1 solo por la rama `buzon`; las locales te escriben.
Las sesiones que abre COORDINACIÓN salen con el esfuerzo por defecto (medio en Opus 5.5) y `get_session` no lo muestra:
no te fíes de lo que diga la sesión sobre su esfuerzo (MOTOR-24 dijo «bajo» y era medio).

**Decisiones de Titín de hoy** (todas en `DIRECTIVAS.md`): decidir con los datos de `CONSUMO.md`, no con suposiciones
(INVESTIGACIÓN va en Sonnet; MOTOR en Opus medio); el límite semanal lo gestiona él, no lo saques; MOTOR vivo hasta
publicar su versión (archivar al publicar o al 35 %); LOCAL compila la siguiente mientras prueba en la 6,1; MOTOR dos
niveles por delante de lo compilado; INVESTIGACIÓN por delante hasta el 156, traduciendo a 10.14 lo de macOS 11/12/13;
**capa de compatibilidad propia** aprobada; **Graphite fuera** mientras exista el camino actual. Un comentario suyo es
para debatir: opciones con datos y recomendación.

**2.0.3 (se salta la 2.0.2, opción A de Titín):** brave-core `nube/motor25-p25` **fbe2394fed** = -p24 23f2d547d9 +
`seg/fs26-c3` b7fdffb7 + include de c3 (LOCAL) + b2 con los colores del cuentagotas en Mac + arreglo de las fijadas en
blanco (`pinned_tab_codec.cc`). Build 31. Órdenes a LOCAL en `buzon/LOCAL/` de las 12:15 (MOTOR-25) y de COORDINACIÓN-16
de la ~12:12. **Falta:** Release, pruebas en la 6,1 (fijadas con 2+ ventanas y perfil sucio; GPU global en reposo; F5.3
con Titín delante; b4 con un Mac que deje Titín; si b2 falla, se revierte solo), `chrome_pgo_phase` (solo lectura),
DMG y capturas → **sí de Titín** → PUBLICACIÓN (ya avisada de que se salta la 2.0.2) → bak → web, comprobada con curl.
Datos de la -p23 en la 6,1: proceso GPU con la NTP ~5,0 % (1.15.2 ~5,3 %), renderer 2,2 % (6,4 %), pausa al 0 %.

**Agentes vivos:**
- **MOTOR-25** `session_01MwmK2jUhhNQpTHEbCSHDPC` (Opus, medio): lo que traiga LOCAL de la 2.0.3, antes que nada; luego
  el **nivel 132** (FM.45, inventario aprobado: V8 13.2.152.56, Maglev encendido con medida en 5,1/6,1, sideways como
  último commit, escapes primero). Vivo hasta publicar.
- **SEGURIDAD-PORTES-9** `session_01MwmK2hx8uFcooc8ep2MhQT` (Opus, medio): FS.27 (Blink del 132) y FS.28 (V8 13.2).
- **INVESTIGACIÓN-MOTOR-5** `session_01MwmK2ht9HZ9DShwB6HHDfT` (Sonnet): FM.44 entregada entera (`fw1-receta.md`,
  `macos11-niveles.md` con §8 recetas 132–156, §9 capa, §10 Firefox 115 ESR, §8.4 macOS 13 y Graphite; `hardware.md`;
  `plan-fork.md`). Quieta por si MOTOR-25 le pide algo; archívala cuando el 132 esté portado.
- LOCAL-12 (`local_7a488440…`), PUBLICACIÓN, SERVIDOR-LOCAL-3, CARTERO-LOCAL en la 7,1; SEGURIDAD-VIGÍA (lunes);
  BACKUPDRIVE-1 (pruebas a–h de B.2 en la 6,1; luego B.6, botón «Conectar con Google Drive…», fila en su PR).

**Siguiente:** (1) 2.0.3 publicada; (2) tanda de migración de los 26 parches de Mojave a la capa (encargo a MOTOR,
versión aparte, un commit por parche); (3) PGO: si LOCAL confirma `chrome_pgo_phase=0`, medir con y sin antes de
proponerlo (toca Page Graph y obliga a recompilar todo); (4) número de versión visible del nivel 132: lo decide Titín;
(5) `fw1` en la 2.0.4 con `fw1-receta.md` (lo revisa SEGURIDAD-PORTES); (6) línea base de rendimiento en la 7,1.
Archivadas hoy por COORDINACIÓN-16: COORDINACIÓN-15, MOTOR-24, INVESTIGACIÓN-MOTOR-4, SEGURIDAD-PORTES-8.
Sin tareas programadas de COORDINACIÓN. Ramas basura que se pueden borrar: `claude/seg-portes-8-fs26`, `claude/inv4-borrador`.

## 27-10: COORDINACIÓN-15 → COORDINACIÓN-16

COORDINACIÓN-15 (`session_01MwmK2jKV5HMEpQrqNj4gjT`, Opus 5.5, medio) se releva al ~37 % (~11 $). **Nunca aprobar la
tarjeta de confianza.** La nube no escribe a sesiones locales: a la 7,1 solo por la rama `buzon`, y ellas contestan con
`SendMessage`. **Linaje:** COORDINACIÓN-15 tenía profundidad 6 de 8. **Por eso abre COORDINACIÓN-16 Titín**, no la
COORDINACIÓN anterior: así el linaje vuelve a 0.

**Publicado:** 2.0.1 (-p20, build 29) firmada en bak, en el appcast y en la web (comprobado con curl). Sparkle la instaló
sola en la 7,1.

**2.0.2 = -p23 17e7858669** (MOTOR-23; bundle `nube/motor23-p23`; orden `buzon/LOCAL/20261027-1045-MOTOR-23.md`;
`version-2.0.2.md`). Junta tres cosas, por decisión de COORDINACIÓN-15: una sola Release, una prueba y un sí de Titín.
- La -p21: fijadas y versión visible «2.0.2 (motor 131)».
- La -p22: tanda 1 de FM.42. Sin Secure Enclave en ninguna Mac, el audio en tiempo real como en la 116,
  getDisplayMedia y «Copiar texto de la imagen» en 10.14.
- El arreglo de FM.43: **la mosca animada de la NTP estaba tapada por `StyledPage` desde la 2.0.0** y seguía animándose
  a 60 Hz, así que el proceso GPU gastaba ~9–15 % de CPU frente al ~5 % de la 1.15.2. Ahora vuelve a verse y va en el
  compositor.

La -p21 ya está compilada en `out/Release` (base incremental; no se entrega). **Falta:**
1. LOCAL-12 compila la -p23 y prueba en la 6,1 con el fondo comprobado en reposo; antes, control al 0–1 %.
2. Capturas o vídeo de la mosca, 1.15.2 frente a -p23, y DMG de prueba.
3. **Sí de Titín:** regla nueva, lo visible no se publica sin él.
4. PUBLICACIÓN, luego bak, luego la web.

**Decisión pendiente de Titín:** con «Reducir movimiento», la mosca queda quieta (lo que pide `disenos.md` §3); en la
1.15 volaba más despacio. **Riesgo:** F5.3 (línea en la 6,1 en modo escalado). Si vuelve, se revierte solo `mosca.tsx`.
La rama `nube/motor23-p23` lleva un commit basura de MOTOR-23 (una copia del árbol de main, sin datos personales).
Limpiarla necesita force push, así que solo con el sí de Titín; no corre prisa.

**Lecciones de hoy:**
- Cerré FM.43 tras una sola prueba (FreeFileSync coincidía en el tiempo) y tuve que reabrirlo: confirmar con un control
  limpio antes de cerrar.
- Los mensajes del buzón llegan con horas de retraso y en desorden: uno posterior puede anular a uno anterior.
- En cada Release de la 6,1 y la 5,1 se mide la GPU en reposo, con la NTP y con about:blank.

**Decisiones de Titín de hoy** (en `DIRECTIVAS.md`):
- Mojave al 100 %: se traduce, no basta con que no se caiga (FM.42; inventario en `mojave-128.md`).
- Nada del T2 ni del Secure Enclave.
- Cifrado por software, estándar y modular: `fw1` va en la **2.0.4** (FS.25, `cifrado.md`; ML-KEM ya estaba portado).
- Lo visible, con su sí antes de publicar.
- Pestañas planas y unidas a la barra: D8 en `disenos.md`, sin prioridad; él manda los bocetos.

**Siguiente:**
- FM.42, tandas 2 y siguientes para la 2.0.3: c3 (OPFS truncate, regla 17), las fotos de cámara, el nombre de pantalla y
  el cuentagotas.
- Línea base de rendimiento en la 7,1 con la 2.0.1: JetStream sin web-ssr con `JetStream.benchmarks.filter`, porque la
  URL con la lista de pruebas da 403 (relevo-local.md).
- Repetir MotionMark en la 6,1 en reposo: el 603,74 a 45 fps no vale; la referencia es la 2.0.0, 541,92 a 60 fps.
- Falta el `sysctl machdep.cpu.brand_string machdep.cpu.features` de la 5,1: probablemente E5620 Westmere, con AES-NI.
- JetStream web-ssr: `RegExp.escape` es del nivel 136 y no se porta.

**Agentes vivos:**
- LOCAL-12: lo abre Titín (LOCAL-11 se releva; nota en `relevo-local.md`).
- PUBLICACIÓN, SERVIDOR-LOCAL-3 y CARTERO-LOCAL, en la 7,1.
- SEGURIDAD-VIGÍA, con su rutina de los lunes.
- BACKUPDRIVE-1.

Archivadas hoy: COORDINACIÓN-14, MOTOR-21, MOTOR-22, MOTOR-23 y SEGURIDAD-PORTES-7. No queda ninguna tarea programada
de COORDINACIÓN.

## 27-10: COORDINACIÓN-14 → COORDINACIÓN-15

COORDINACIÓN-14 (`session_017J2kfSt5BR2UuYSr8fYzvw`, Opus 5.5, medio) se releva al 38 % (17,4 $). **Nunca aprobar la
tarjeta de confianza.** A la 7,1, solo por la rama `buzon` (tarda horas a veces; si corre prisa, Titín se lo dice al
agente); las sesiones locales sí te escriben. La nube no escribe en brave-core: bundles en ramas de softmac, LOCAL sube.

**Publicado:** 2.0.0 (-p17, build 28) el 26-10, appcast y web. **2.0.1 (-p20 8528639ead, build 29)**: firmada,
notarizada, en ns2 (`FlyWeb-2.0.1.dmg`, 174 780 539 B, SHA-256 `1d7d6b0f…7b15`), web fusionada (#519; web-auto publica sola
cuando el appcast la anuncie). **Falta solo la firma de Titín en bak** (orden en FM.40; PUBLICACIÓN se la pasa). Lleva
el aviso falso «No se puede actualizar FlyWeb» quitado (`enable_update_notifications=false`), NTP sin halo (-p18),
«FlyWeb Sync», y **dos CVE explotados**: CVE-2026-11645 (V8, runtime) y CVE-2025-14174 (ANGLE Metal, 10.15+; no
reproducible por WebGL en la 7,1, arreglo aplicado). Cuando esté el appcast: comprobar la web con curl.

**2.0.2 (FM.41):** -p21 3cc4ce116c de MOTOR-20 (archivada; bundle `nube/motor20-p21`, orden en el buzón de LOCAL del
27-10 08:10): fijadas compartidas con 2+ ventanas (se perdían; fallo de la 2.0), versión visible «2.0.2 (motor 131)»
(capturas para Titín; la cadena traducible «FlyWeb 2.0.2…» la decide él), xHE-AAC solo en 10.15+, diagnóstico de JetStream
web-ssr (`RegExp.escape`, Chrome 136) y Speedometer «?» en Sequoia (Futura/CoreText). `navigator.brave` ya no se expone.
Flujo: LOCAL-11 compila y prueba → PUBLICACIÓN → orden de bak → web (VERSION, portada, novedades: la de la 2.0.1 es el
modelo, #519; quita el «problema conocido» de las fijadas). MOTOR-21 solo si LOCAL trae fallos.

**Seguridad:** triaje rehecho contra la 128 (FS.24, #514): con la -p20 no queda ningún explotado abierto. **Decisión
pendiente de Titín:** tanda de críticos que salen del sandbox (~15–25 h sin medir) + revisión de ANGLE por backend; la
cifra de 750 críticos/altos está sin verificar (3599 ID de 2026, anómalo). SEGURIDAD-VIGÍA = sesión de Titín
`session_019wTc3m4aVuvkKTEGMXdEHS` (Haiku, medio), despertada por la tarea «Seguridad-Vigía FlyWeb (Haiku)»
`trig_01RAtyyXH6fPZ9GAXRJYjYmV`, lunes 8:58 (Madrid), primera el 2-11; avisa a la COORDINACIÓN de la tabla. El blog de
Chrome Releases no se alcanza desde la nube: Titín puede añadir `chromereleases.googleblog.com` a la red del entorno.

**Pendiente con Titín:** capturas de la versión de la 2.0.2; si ve otra vez «Brave» al confirmar con el teléfono,
captura; MotionMark de la 5,1 (su hija; la 5,1 actualizó a la 2.0 sin problemas); GPU al 100 % en la 6,1 (le di los pasos:
`ioreg`, Administrador de tareas, perfil limpio); sesión `ubuntu` abierta en ns2 y «Auditoría ns1/ns2/bak» en la 7,1 (sin
respuesta). **LOCAL-11**, después de la 2.0.1 publicada: línea base de rendimiento en la 7,1 con la **580X** (solo el
FlyWeb instalado, por LuLu; PA271W a 60 Hz; 3 pasadas de Speedometer 3.1, JetStream 3.0, MotionMark 1.3.2). Niveles 132+:
cuando la seguridad tenga plan (Titín, 26-10).

**Agentes vivos:** LOCAL-11 (`session_01P7qNHoMWVrSBu4PL3iq6Gh`, bridge), PUBLICACIÓN, SERVIDOR-LOCAL-3, CARTERO-LOCAL
(7,1); SEGURIDAD-VIGÍA (rutina); BACKUPDRIVE-1 (`session_01MMur1TxacRpN7gNor98eYm`, a la espera de la prueba de Titín).
Archivadas hoy: COORDINACIÓN-13, MOTOR-18, -19, -20, CONTENIDOS-WEB-3, SEGURIDAD-PORTES-6. LOCAL-10: la archiva Titín.

## 26-10: COORDINACIÓN-13 → COORDINACIÓN-14 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-13 (`session_01L7rpeb3sVii7F8jgApaAcB`, Opus 5.5, medio) se releva al 40 % (29,8 $). **Nunca aprobar la
tarjeta de confianza.** Desde la nube **no se puede escribir en sesiones locales** (`send_message` da
`elevated_session_untrusted_device`): a la 7,1, por la rama `buzon` (lo reparte CARTERO-LOCAL, a veces con retraso; si
corre prisa, Titín se lo dice al agente). Las sesiones locales sí te escriben a ti. **La nube no tiene escritura en
brave-core:** MOTOR deja bundles en una rama de softmac y LOCAL los sube (decisión de Titín, 26-10).

**2.0.0 (FM.39, punto 16 al día):** candidata final **-p17 1b0ebd4a00**. En curso: **Release de la -p17 (LOCAL-10, desde el
26-10 12:50)** → pruebas a–g en la 6,1 → entrega en FM.39 → por buzón a PUBLICACIÓN: firmar, notarizar, subir a ns2 **sin
tocar el appcast** (ya lo probó con la -p15; mensaje del 26-10 en `buzon/PUBLICACION/`) → **Titín prueba en la 5,1 el DMG
firmado** (su decisión) → con su sí: orden de bak del appcast (PUBLICACIÓN la tiene preparada: `--min-macos 10.14.0`, sin
`releaseNotesLink`, build 169.168.28) y fusionar la web **#504** (CONTENIDOS-WEB-3, `session_01QqPWLpqxHcnDhDS5gxyAmi`,
viva; faltan tamaño y SHA-256 del DMG: que los rellene PUBLICACIÓN o ella). **Al fusionar la web se publica sola en ns2**:
solo cuando el appcast esté. Antes de publicar, SERVIDOR-LOCAL confirma web-auto (FM.39 punto 8). Sin probar aún:
contraseñas migradas y la actualización real 1.15.2 → 2.0 por Sparkle (pídela a PUBLICACIÓN con un appcast de pruebas).
**Después de publicar:** reactivar el VIGÍA (tarea «⚡ Vigía FlyWeb (Haiku)», `trig_01YbVYXhSWE1L5nFiuvpRXug`, pausada por
Titín) solo si sigue haciendo falta; **2.0.1** = -p18 16b6e01b57 (NTP sin halo, ya preparada) + `build.sh` para la 2.x.

**Hecho (23–26-10):** Shields 2.0 (#497) revisado, firmado e instalado en bak por Titín (`recursos-20` 2026.1023.1316); -p15
(insignia, EGL) → -p16/-p17 (MOTOR-18); web 2.0 (#504, sin fusionar); inventario de lo pendiente y optimizaciones
(`FlyWeb/docs/investigacion-pendiente.md`, #507; prioridades: línea base medida en Release —**la 7,1 con su 580X antes de
cambiarla por la W6600X**—, niveles 132+, descarte de pestañas por RAM, experimento `-march=haswell` solo si gana ≥5 %, matriz
GPU + F5.6); BackupDrive en modo seguro (#508: bisync con comparación por hash, borrado blando a versiones con caducidad,
frenos de borrados y de modificaciones masivas; **Titín lo prueba en la 6,1 con una carpeta de prueba, en paralelo a su
FreeFileSync**). Decisiones de Titín: DuckDuckGo sin `t=`; Flickr 429 resuelto en la 2.0 (huella de red, regla en TRAMPAS);
VIGÍA pausado; regla de diseño visual (DIRECTIVAS).

**Agentes vivos:** LOCAL-10 (`local_71a093c7-…`, bridge `session_01R4rHSMbvvgjWeEedxJ39jG`); MOTOR-18
(`session_01LsgphgHrVXECyE51FhS4Av`, <40 %, viva por si la Release de la -p17 falla; archívala cuando compile);
CONTENIDOS-WEB-3 (viva hasta fusionar la web); BACKUPDRIVE-1 (`session_01MMur1TxacRpN7gNor98eYm`, viva hasta la prueba de
Titín); en la 7,1 PUBLICACIÓN (~45 %), SERVIDOR-LOCAL-3 y CARTERO-LOCAL. Archivadas: COORDINACIÓN-12, LOCAL-9,
INVESTIGACIÓN-MOTOR-3.

## 23-10: COORDINACIÓN-12 → COORDINACIÓN-13 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-12 (`session_01NjpdW4mhQMcN2EuNN8MivC`, Opus 5.5, medio) se releva al ~68 %. **Nunca aprobar la tarjeta de
confianza.** Lo nuevo y decidido está en DIRECTIVAS (22–23-10) y en las filas **FM.38** (identidad, hecha) y **FM.39** (lo
que falta para publicar la 2.0.0); el análisis de gasto, en `docs/CONSUMO.md` («Análisis del 23-10»).

**Cómo trabajar ahora (Titín, 22–23-10):** una sesión por tarea con arranque mínimo, subagentes para leer, relevo hacia
el 35–40 %, archivar al entregar (antes, `list_triggers` y borrar sus avisos) y abrir el relevo solo cuando haya trabajo.
**Junta los cambios `[coord]` en pocos PR:** cada PR trae dos avisos largos que engordan tu contexto. Los agentes empujan
a veces a un PR ya cerrado: reaplica sus commits en uno nuevo. La 7,1 no recibe `send_message` de la nube: buzón.

**Estado de la 2.0.0:** candidata **-p14 806e8caa96** (motor 131 + Mojave + identidad + Sparkle + copia del perfil),
probada por LOCAL-9 en la 6,1 (sin caídas, auditoría de red limpia, migración con el perfil real de Titín: marcadores y
extensiones bien; contraseñas sin probar: su perfil no tenía) y por Titín en el A1398 (claude.ai bien; GPU OpenGL, Metal
no admitido por esas GPU). `nube/base-128-motor` sigue en -p9: muévela a la candidata final (MOTOR o LOCAL).
**En curso:** LOCAL-9 hace la **-p15** (león de la insignia de la barra; buzón del 23-10).
**Falta (FM.39):** servidor de Shields (**SERVIDOR-LOCAL-2**, ordenado por Titín; Titín ya generó la clave `recursos-20`,
ID `nilendadbigifkognoeoodppkjkgmppg`, #477/#479); pruebas a mano de Titín en la 6,1 (ventana cerrada con fijadas,
llavero, menús, barra lateral, descargas) y contraseña de prueba para la migración; MacBook con Mojave el sábado 24-10
(LOCAL-9 por SSH; la 5,1 no está accesible); Release firmada (llavero sin aviso, CPU de vídeo); web de la 2.0 con la
ayuda de contraseñas (CONTENIDOS-WEB) y comprobar web-auto (SERVIDOR-LOCAL); appcast con `--min-macos 10.14.0` y sin
`releaseNotesLink` (PUBLICACIÓN, respondido). **Después:** FM.37 (privacidad de Brave posterior a la 1.69), clase E
(servicios nuevos), MOTOR-18 (8 fallos sueltos de `blink_unittests` y la caída de V8; esfuerzo alto), F5.6 (códec por
capacidad en 2.0.x), widget de búsqueda de la NTP (¿DuckDuckGo o fuera?), registro de la AMD.

**Agentes vivos:** LOCAL-9 (`local_ad0f5131-…`, bridge `session_01NqrwCVpYFvVS6m6fGZgAed`, medio, por el plan); VIGÍA
(rutina horaria; cámbiale el destino a ti); CARTERO-LOCAL, PUBLICACIÓN y SERVIDOR-LOCAL en la 7,1. Todas las demás de la
nube, archivadas (sus notas: `identidad-128.md`, `relevo-motor.md`, `RELEVO-SEGURIDAD.md`).

## 22-10: COORDINACIÓN-11 → COORDINACIÓN-12 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-11 (`session_016LAphUszobDrthjRLX51N9`, Opus 5.5 alto) se releva al 54 % de contexto (40,33 $, 135 266 de
salida), en punto limpio: se espera la `-p7` de MOTOR-16. **Nunca aprobar la tarjeta de confianza.** Archivar sesiones
locales desde la nube **sí funciona** (LOCAL-7, 22-10). PR [coord] de COORDINACIÓN: los fusionas tú con `expectedHeadSha`.

**Decisiones de Titín (21–22-10), ya en el tablero:**
- 1.15.2 **publicada** (appcast y web, 21-10). **1.15.3 cancelada**; la **base 128 (2.0.0) es el hito**, a fondo (DIRECTIVAS).
- **GPU en Mojave, requisito de la 2.0.0**; WebGPU apagado (CVE-2026-5281) hasta su nivel. Maglev apagado hasta el 132
  (tabla de la regla 19, RELEVO-SEGURIDAD).
- **Códec por hardware** como la 1.15 (YouTube en H.264 donde VP9 no va por hardware), mejor por capacidad (VideoToolbox).
- Máquinas de prueba nuevas en CLAUDE.md (MBA 2013, Mac mini y MBP 2012 con Catalina, A1398 con Monterey).
- **OR.2:** crédito de API de 100 $ (caduca 06-11, sin tarjeta) para una sesión local; LOCAL-8 se abrió **por el plan**
  (sin clave en el entorno): sigue sin usar. Siguiente intento: la próxima sesión local larga, por Terminal. **Corrección (22-10): el crédito promocional NO vale para Claude Code** (se aplica a Agent SDK, API, API por lotes, Playground y Agentes gestionados; Claude Code da «Credit balance too low»). LOCAL-9 se abrió por el plan. Usos posibles antes del 06-11: un guion del Agent SDK para lecturas masivas o un Agente gestionado; se decide en el análisis del 23-10.
- Titín quiere la 2.0 **lo antes posible**, pero COORDINACIÓN-11 le recomendó no forzarla esta semana (límite semanal al
  57 %, reinicio **martes 27-10 08:00 Madrid** = 07:00 UTC; ya en horario de invierno). **Viernes 23-10: análisis de gasto por tarea** (CONSUMO.md) con Titín.

**Estado de la 2.0.0 (FM.31) al relevo:**
- brave-core: `nube/base-128` = Brave 1.69.168 puro (6918a99aa6). Rama de integración `nube/base-128-motor`; fijas
  -p1…-p6. **-p6 02c9d0ca4b** = V8 13.1 + niveles 129–131 + anchor + flags + ML-KEM + seguridad S1–S4 + FS.23 + versión
  declarada 131 (UA, Client Hints sin «Brave», platformVersion 11.7.10).
- **Parches de Mojave** (GPU de la Fase 1 + 46 avisos de 10.15: Dawn, color_space_util, HDR, Bluetooth FIDO, LAContext,
  descargas, geolocalización…): LOCAL-8 en brave-core `local/base-128-mojave` 88739f8c7f (`FlyWeb/mojave-128/*.diff`).
  **MOTOR-16 los convierte en patches/ y hace -p7** con el códec por hardware y los tests de blink (41 *_test.cc.patch:
  solo llegaron 2) y la regresión de togglePopover/WPT.
- **Probado en la 6,1:** GPU todo acelerado, 0 caídas, WebGL 60 fps; MotionMark 570 (1.15.2: 412); html5test 579/588;
  **claude.ai con Google funciona entero** (Titín, 22-10). Speedometer 3.0 = 3,99 (desarrollo, sin Maglev; falta la cifra de la 1.15.2).
  WPT 695/699 iguales a CfT 131; JA4 idéntico. Vídeo 1080p (H.264): 1.15.2 12 % vs 128 18 % de un núcleo (repetir en Release).
- **Pérdidas en Mojave:** EyeDropper y takePhoto apagados en 10.14 (la 128 quitó la alternativa de la 116).
- **Riesgo:** Media Router (DIAL) con un cortafuegos que pregunta cuelga el hilo de E/S (Brave lo trae apagado).
- **Pendiente:** -p7; vídeo y descargas/geolocalización en la 6,1 (LOCAL-8); 5,1 (Titín da usuario/host/puerto **solo en la
  sesión de LOCAL**, a `temp/`, ignorado por git); **Fase 2** (marca, sin cartera/Rewards/VPN/Leo ni barra «macOS 11»,
  `navigator.brave`/`braveEthereum`/`solana` fuera, servicios propios, Sparkle **y migración del perfil de la 1.15**);
  Release; resto de máquinas; publicación. **El reparto de la Fase 2 se propone a Titín tras la -p7.**

**Agentes:** MOTOR-16 `session_01R24qB8o9yirUqVC7H1ZVc6` (~20 %); SEGURIDAD-PORTES-5 `session_01H7fz6r296TWMGBgDfYzRgX`
(~40 %, relevo antes de su próximo encargo); INVESTIGACIÓN-MOTOR-2 `session_014AE1uLN6wA98XeE3bdEbbV` (quieta);
CONTENIDOS-WEB-2 `session_015tHV7uDdbAc6uZ1VwmgcqD` (quieta); LOCAL-8 `local_5c6ba9f8-…` (desde la nube
`session_01S8dHbLwEmeH2dsnY88gBrz`, ~25 %). Vigía `session_01XD1RBYQ5oESHWKeqZWSG4e`: **cámbiale el destino** a ti.
MOTOR-14/15, LOCAL-6/7, SEGURIDAD-PORTES-4 y COORDINACIÓN-10: archivadas.

**Lecciones (en TRAMPAS):** la revisión en papel no sustituye a compilar y probar (FS.23 halló 7 arreglos perdidos; el
«cuelgue de GPU» era LuLu). Mensajes cruzados: los agentes empujan a su PR después de que lo fusiones; mira la rama
antes de fusionar y reaplica lo que llegue tarde.

## 21-10 (tarde): COORDINACIÓN-10 → COORDINACIÓN-11 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-10 (`session_01U31mzo4UdTUgf3gkhqxKmb`, Opus 5.5) deja la nota al 45 % de contexto, en punto limpio; se
releva cuando Titín lo pida o al pasar del 50 %. **Nunca aprobar la tarjeta de confianza** (ni tú ni la nube).

**Canales (comprobado hoy):**
- Nube → nube sin aprobar: `send_message`. Nube → 7,1 y → sesiones aprobadas: **rama `buzon`** (`buzon/README.md`);
  reparte **CARTERO-LOCAL** en la 7,1 cada 30 min. **Entrega, pero no anota en `buzon/ENTREGADO.md`** (recordatorio en el
  README). Lo urgente que no llega (pasó con la F15 a LOCAL-6) se lo pides a Titín para que lo pegue en la sesión.
- 7,1 → nube: `SendMessage` directo, llega bien. Reserva: CARTERO-1 de la nube (rutina `trig_01ByndD2HyrSWPyNqauBF7uH`
  desactivada). VIGÍA solo vigila (rutina reactivada, destino COORDINACIÓN-10: **cámbialo** con un mensaje al Vigía).
- El clasificador del modo Auto bloquea ordenar a otra sesión `confirm_repository_trust`. Archivar una sesión aprobada
  (MOTOR-13, COORDINACIÓN-9) solo lo puede hacer Titín.

**Estado al relevo (21-10, ~18:10 Madrid):**
- **1.15.2 ENTREGADA** a PUBLICACIÓN (FM.28): brave-core `nube/motor-131-anchor-f16` af0328adeb, build 27. Camino:
  F9 → F14 (caídas de la 1.15.1 publicada y UAF c215f8e6f0 arreglados) → F15 (la F14 rompía 9 WPT de capa superior) →
  F16 (includes que la Release sin PCH no encontraba). Falta: PUBLICACIÓN firma/sube (no le preguntes a Titín) y da nombre,
  bytes y SHA-256 del DMG en FM.28 → CONTENIDOS-WEB-2 pasa **#420** (web) a listo → lo fusionas. Luego LOCAL mueve `flyweb`.
- **Lecciones (en TRAMPAS):** la revisión en papel (MOTOR y SEGURIDAD) aprobó la F11/F14 y solo las WPT vieron la
  regresión; una Static con PCH no garantiza la Release (`enable_precompiled_headers=false`).
- **FM.31 Fase 0 HECHA:** Chromium 128 limpio compila en la 7,1 (SDK 14.5, Metal de Xcode 15.4) y **arranca en la 6,1 en
  modo software**: 4 rondas (mac_min_system_version, 3 SPI en weak_import, EDR de screen_mac, Dawn hasUnifiedMemory;
  `dcheck_always_on=false`). Queda para la Fase 1: Dawn en 10.14 (~50 usos de API 10.15 sin @available: protegerlos o
  apagar WebGPU), el resto de los 70 avisos y la 5,1. **Decisión pendiente para Titín cuando se plantee la Fase 1:**
  WebGPU apagado al principio (recomendado: menos trabajo; Chrome 128 no da soporte a 10.14) o portar Dawn.
- **1.15.3 (FM.29, view transitions entre documentos):** MOTOR-14 (`session_01PZNSmdebZSnLvAr2v93osp`, sin aprobar) la
  midió (#412: 159 commits, 6–10 h); abre rama cuando la 1.15.2 esté publicada. Lista para la 1.15.3: 01c7c1b09a
  (::backdrop), getComputedStyle-002, 3aa7ad2a0d opcional.
- **Agentes:** LOCAL-6 al 53 %, en punto limpio; **LOCAL-7 lo abre Titín** (texto en mi último mensaje a Titín: el de
  LOCAL-6 en ARRANQUE con «relevo de LOCAL-6 (local_20642d1a-…)»). SEGURIDAD-PORTES-4 (`…011AG2q3`, 35 %) e
  INVESTIGACIÓN-MOTOR-2 (`…014AE1uL`, sin encargo) quietas. SERVIDOR-LOCAL-3 sin encargo. MOTOR-13, COORDINACIÓN-9,
  LOCAL-5, CONOCIMIENTO-1, SEGURIDAD-PORTES-3 e INVESTIGACIÓN-MOTOR-1: archivadas.
- Consumo de COORDINACIÓN-10 al dejar la nota: 28,01 $, 112 275 tokens de salida, 45 % de contexto.

## 21-10: COORDINACIÓN-9 → COORDINACIÓN-10 (leer primero; manda sobre lo de abajo)

COORDINACIÓN-9 (`session_01MMGz9HS8qH5Hzsne92zi7u`, Opus 5.5 alto) se releva el mismo día porque aprobó la tarjeta de
confianza y dejó de recibir mensajes de la nube.

**COORDINACIÓN-10 (`session_01U31mzo4UdTUgf3gkhqxKmb`), 21-10 ~10:05:** el clasificador del modo Auto **bloquea ordenar a
otra sesión que llame a `confirm_repository_trust`** («Auto-Mode Bypass»): la tarjeta del cartero la tiene que pedir Titín
en la sesión del Vigía. Archivar una sesión aprobada (COORDINACIÓN-9) falla desde la nube («requires a trusted device»):
la archiva Titín. Buzón montado (rama `buzon`, `buzon/README.md`). **Corrección:** el CARTERO no es el Vigía sino una sesión nueva, CARTERO-1 `session_01RteKFFeayEirn8fTGKbFnC` (Haiku, aprobada; rutina `trig_01ByndD2HyrSWPyNqauBF7uH` a :37); el Vigía sigue solo vigilando. **Después (Titín, 21-10 ~10:15): el cartero pasa a la 7,1 (CARTERO-LOCAL, Haiku bajo, cada 30 min, `SendMessage` dentro de la Mac, sin tarjeta)**; CARTERO-1 queda de reserva con su rutina desactivada. Sus instrucciones, en `buzon/README.md`.

**Canal entre sesiones (comprobado el 21-10; no documentado, deducido de estos casos):**
- La tarjeta (`confirm_repository_trust`) la aprueba Titín, una vez por sesión. La sesión aprobada puede escribir a la
  7,1 y a sesiones de la nube **sin aprobar**, pero **deja de recibir de cualquier sesión de la nube**, aunque esté
  aprobada: solo le llega lo que sale de los dispositivos de Titín (la 7,1, su móvil).
- Casos: CONOCIMIENTO → COORDINACIÓN-9 (aprobada), rechazado; COORDINACIÓN-9 → MOTOR-13 (aprobada), rechazado;
  COORDINACIÓN-9 → CONOCIMIENTO y → LOCAL-5, entregados; LOCAL-5 → COORDINACIÓN-9, entregado.
- **COORDINACIÓN-10 y todos los agentes de la nube, sin aprobar nunca.** Solo el CARTERO se aprueba. MOTOR-13 ya está
  aprobada: le llegan LOCAL y Titín, no la nube; **MOTOR-14 se abre sin aprobar**.
- Titín (21-10): pasarse el día aprobando no es viable, y el sondeo desde LOCAL tampoco (cada despertar relee su
  contexto, que crece rápido; la 7,1 va saturada con las compilaciones y su trabajo). Pide preparar un *feedback* a
  Anthropic: confianza por entorno o por agente, no por sesión, y Remote Control que no se pierda al reiniciar la app.
- El modo Auto no tiene que ver: aprueba permisos dentro de la sesión. Aun así, a MOTOR-13 el clasificador le pidió
  confirmar una orden de Bash (21-10, ~09:35). Al abrir una sesión con `create_session`, pasar `permission_mode: auto`
  (CONOCIMIENTO-1 se abrió sin él y pidió permiso para `send_later`).

**CARTERO (decisión de Titín, 21-10): el Vigía pasa a cartero, Haiku bajo o medio.**
- Única sesión de la nube aprobada (un toque de Titín, una vez). Para que salga la tarjeta: `send_message` a una sesión
  de la 7,1; el rechazo trae un `content_digest`, y con él `confirm_repository_trust`.
- **Buzón:** rama `buzon` de softmac. Cada mensaje de la nube para la 7,1, un fichero
  `buzon/<DESTINO>/<AAAAMMDD-HHMM>-<ORIGEN>.md`, con push directo a esa rama (sin PR). **Nada de datos personales**:
  la rama es pública. En cada pasada, el cartero hace `git fetch`, reparte los ficheros nuevos con `send_message` al id
  de la tabla de agentes y anota lo entregado en `buzon/ENTREGADO.md`. Sus avisos de vigía a COORDINACIÓN siguen
  (de aprobada a sin aprobar sí llega).
- Rutina `trig_01YbVYXhSWE1L5nFiuvpRXug` («Pasada del vigía», cada hora 8–23 h): **desactivada** por COORDINACIÓN-9
  el 21-10 a las 07:30 UTC; se reactiva al montar el cartero (a 30 min si hace falta).
- Preguntas pendientes del Vigía: regla del desfase de la web (¿dos pasadas seguidas o solo tras la firma?) y si
  «WEB SINCRONIZADA» se manda sin ACCIÓN.
- Sin probar. Primera prueba: un mensaje de COORDINACIÓN-10 a LOCAL-6 por el buzón.

**Estado al relevo (21-10, ~09:55):**
- **OR.1:** fusionados #374, #378, #379 y #380 (TAREAS de 748 a 128 KB; `DIRECTIVAS.md`; `ARRANQUE.md` con los textos de
  relevo; manuales sin historial); #375 y #377 cerrados porque iban dentro de #379 y #378. CONOCIMIENTO-1
  (`session_01TRKSg59fpf5oYiaF2mv6X9`): falta repartir «Trampas» de esta nota entre DIRECTIVAS y los manuales.
- **OR.2:** `docs/CONSUMO.md` (#376), con el plan prudente de pruebas en los relevos.
- **FM.28 (1.15.2):** caída grave del porte (`std::move` en `Element::RecalcOwnStyle`), URGENTE en MOTOR-13, que
  esperaba la aprobación de Titín de una orden de Bash. El arreglo lo compila LOCAL, parando la 128.
- **FM.31:** Chromium 128 compilando desde las 09:36 (SDK 14.5 de Xcode 15.4, `use_siso = false`).
- **Relevos (Titín, 21-10: todos ahora):** SEGURIDAD-PORTES-4 e INVESTIGACIÓN-MOTOR-2 en la nube, que abre COORDINACIÓN-10
  con `create_session` y `permission_mode: auto` (el esfuerzo no se puede fijar ahí: Titín lo pone en la app). LOCAL-6 y
  SERVIDOR-LOCAL-3 en la 7,1, con los textos de `docs/ARRANQUE.md` que pega Titín. LOCAL-5 deja antes su nota de relevo.
  Se archivan las viejas cuando el relevo esté activo. PUBLICACIÓN y SERVIDOR-LOCAL-2 tienen la sesión archivada.
- Revisión programada de COORDINACIÓN-9: `trig_019mJD9YvXyBC2MZKeFwswr5`; bórrala al activarte.
- Límite semanal en aviso hasta el martes 27-10, 08:00 (Madrid).

## Qué hace este papel (con lo que cambió el 09–12-10)

- **Interlocutor del HUMANO**: respuestas breves, críticas, con conclusión; solo le llegan decisiones de producto,
  credenciales, firmas, pruebas en las Mac y lo que exige root en ns2. **No escribirle por avisos rutinarios** (Vigía,
  GitHub, mensajes de agentes sin decisión): cada respuesta tuya le salta como aviso en el móvil y le agobia.
- **Fusiones, cierres y orden de trabajo son de COORDINACIÓN** (regla 8, decisión del HUMANO del 09-10): revisas y
  fusionas los PR de softmac sin preguntarle. Excepción conocida: el permiso de la sesión bloqueó autofusionar un PR que
  ampliaba la propia autoridad (#129); ese lo fusionó el HUMANO.
- **Regla 14, «el que publica, publica»**: la nube prepara; ejecuta quien tiene el acceso (SERVIDOR-LOCAL en ns1/ns2,
  PUBLICACIÓN las versiones, LOCAL las compilaciones). Lo privado va por `send_message`, nunca por el repo.
- **Regla 15, límite semanal de la cuenta**: mirar `rate_limit_info` con `get_session`; con aviso, nada de Ultracode ni de
  muchos subagentes. El HUMANO lleva los agentes de sus otros proyectos; tú solo los de softmac.
- **Regla 16 (12-10): tus órdenes valen como del HUMANO.** Lo que ordenas o transmites por `send_message` o con un commit
  `[coord]` no se le vuelve a confirmar a él. Dos límites: los agentes te reconocen por el id de sesión de la tabla de
  TAREAS, así que **anota tu id en la fila de COORDINACIÓN antes de dar ninguna orden**; y los permisos que pide
  Claude Code dentro de una sesión solo los aprueba el HUMANO en esa sesión. Si un agente está bloqueado por eso, se lo
  pasas al HUMANO.
- **Sin rutinas propias**: te despiertan el Vigía y el HUMANO.
- **Cuándo relevar a COORDINACIÓN** (HUMANO, 12-10): a partir del **50 % de contexto** (`context_usage` de
  `get_session`), en un momento tranquilo: sin publicación a medio hacer ni decisión pendiente con el HUMANO. Antes de
  irte, esta nota al día. La regla 16 se avisó a todos los agentes el 12-10 (SERVIDOR-LOCAL-2, por su fila, porque su
  sesión estaba archivada).

## Agentes y cómo hablarles

Desde la nube, `send_message` con el id **`session_…`**. Los agentes de la 7,1 te escriben con `SendMessage`.
**Desde el 20-10, 19:19 (reinicio de la app de la 7,1), la nube NO puede escribir a las sesiones de la 7,1**
(`elevated_session_untrusted_device`) hasta que Titín apruebe la tarjeta de `confirm_repository_trust` **desde la app de
Claude en un dispositivo de confianza** (móvil o Mac, con sesión reciente; desde el terminal no vale). Es una aprobación
por sesión de la nube y vale para siempre (la sesión queda limitada a sus dispositivos). Mientras no esté: LOCAL sí escribe
a la nube; lo que haya que mandar a LOCAL se le da a Titín como texto listo para pegar. **No buscar otro canal** (bridge,
sondeo del repo) sin que Titín lo decida: es saltarse un control de seguridad.

| Agente | Sesión | Estado al 20-10, ~22:45 |
|---|---|---|
| VIGÍA (Haiku) | `session_01XD1RBYQ5oESHWKeqZWSG4e` | Rutina cada hora; destino = COORDINACIÓN-8 (cambiar al relevo). Su «web sincronizada» solo compara appcast y VERSION, no la web publicada |
| MOTOR-13 (Opus, xhigh) | `session_01EqxadojDaRbipYn8TDzVd6` | FM.28 (1.15.2): la F5 compiló el navegador entero; arreglados el enlazado y los 115 errores de `blink_unittests` (opción A, solo tests). **Sha para LOCAL: `7f864fb08c` (`nube/motor-131-anchor-f7`, lleva FS.22, comprobado con merge-base)**, que Titín pasa en persona. ~6 h 30 min de reloj. Al 18 % |
| SEGURIDAD-PORTES-3 (Opus, medio) | `session_01LKiaD9v2hcna6BUo6CfMBs` | FS.20, FS.21 y FS.22 hechas; visto bueno de la 1.15.2. **Al 76 %: el próximo encargo, a una sesión nueva** |
| INVESTIGACIÓN-MOTOR-1 (Sonnet, alto) | `session_01KEXwPPgTGezmJikFPWgNRA` | FM.27, 30–35 hechas (estudios abajo). Espera 3 datos del G5 (sin prisa). **Al 78 %: el próximo encargo, a una sesión nueva** |
| CONTENIDOS-WEB-2 (Sonnet, medio) | `session_015tHV7uDdbAc6uZ1VwmgcqD` | Libre; le toca la web de la 1.15.2 cuando LOCAL la entregue |
| LOCAL-5 (7,1, Opus, alto) | `local_eb0590c2-…` / `session_01DCZDzGMM8VdHsV5B5JBXmv` | F5 (767c49475b) hecha; le falta compilar `7f864fb08c` (navegador + `blink_unittests`, `-k 0`; el `--gtest_filter` del anchor está en FM.28). **21-10: todo el día Chromium 128** (FM.31); la Release de la 1.15.2 espera a Titín. Descarga de la 128 a medias (429 de googlesource, `-j 2`) |
| PUBLICACIÓN (7,1, Sonnet) | `session_01TTieMjJGykHhdkXAYW8bZG` | Libre (1.15.1 publicada) |
| SERVIDOR-LOCAL-2 (7,1, Sonnet) | `session_01QxM99SrrnUTS2i4XuAHKta` | web-auto con #324 instalado; libre |

Archivados hasta el 20-10: COORDINACIÓN-5/6/7, MOTOR-8 a 12, SEGURIDAD-PORTES-1/2, LOCAL-2 a 4.

Notas de tablero: commits con `[coord]`; reglas, CLAUDE.md y docs por PR, que fusionas tú (pasa a listo y fusiona con
`expectedHeadSha`; antes `git merge-tree` contra `main` y un grep de datos personales/IP). Tu rama de trabajo se queda atrás
tras cada squash: rehazla con `git checkout -B <rama> origin/main` + `git merge -s ours origin/<rama>` (sin force push, que el
permiso bloquea).

## Estado al relevo (20-10, ~22:45)

| Versión | Qué | Estado |
|---|---|---|
| 1.15.1 | Nivel 131 + FM.22 | **Publicada** (firma 16:15; web por web-auto con el arreglo #324 a las 19:27) |
| **1.15.2** | Anchor positioning (FM.28) + 4 CVE críticos (FS.22) + fuga de StyleAnchorScope + KeyboardFocusableScrollers a experimental | Portada; Static de prueba en LOCAL; visto bueno de SEGURIDAD. **Release y publicación cuando vuelva Titín (22-10 o después)** |
| 1.15.3 | View transitions entre documentos (FM.29) | Pendiente, después de la 1.15.2. **Después no se abre el 132** |
| **2.0.0** | Base Chromium 128 + Brave 1.69.168, **mínimo Mojave 10.14** | **Prioridad de Titín.** Fase 0: CVE (FS.20, hecho: 52 pendientes que la 128 ya corrige), Chromium Legacy 127 probado en la 6,1 (va, con 5 caídas de GPU al arrancar sin explicar), compilación limpia de la 128 el 21-10 |

**Decisiones de Titín del 20-10** (todas en TAREAS): orden 1.15.2 → 1.15.3 → migración; no abrir el 132 sobre la 116;
la 128 en paralelo pero nunca dos compilaciones a la vez en la 7,1; mínimo de la 2.0.0 = Mojave (su madre sube a Mojave
el MacBook Air 2013); criba FM.30 aprobada (solo medir botones, LOCAL); G5 aparcado hasta tener fork; Leo y similares
apagados, se borran cuando haya fork; copia de Chromium Legacy en `lamosquita-net/chromium-legacy` (la hizo Titín:
COORDINACIÓN no puede hacer forks fuera de softmac).

**Estudios del 20-10 (INVESTIGACIÓN):** `g5-viabilidad.md`, `criba-fm30.md`, `migracion-128.md` (130–330 h, central ~230),
`chromium-legacy.md`, `legacy-evolucion.md` (Chromium sube el mínimo de macOS en 117, 129 y 139: cada salto de base cuesta
~30–60 h por versión de macOS), `brave-sync-shields.md`, `brave-vs-flyweb.md` (**trampa: constantes de Brave en cabeceras**),
`brave-servicios-nuevos.md`, `brave-170-173.md`, `brave-vs-parches-motor.md`, `cve-117-128-fuera.md` (SEGURIDAD).
**Comprobaciones obligatorias de la Fase 1:** en la fila FM.31.

**Pendiente con Titín:** descargar Xcode 15 (SDK 14) para compilar la 128; aprobar la tarjeta de confianza desde la app;
configurar la 5,1 en el estudio (acceso remoto de LOCAL); dos decisiones menores de FM.35 (política `BraveSyncUrl`, MV2).
Límite semanal en **aviso** (`allowed_warning`) hasta el **martes 27-10, 08:00**: nada de flujos grandes ni muchos agentes.

**Coste observado (`cost_usd` de `get_session`):** lo caro es el contexto largo releído en cada turno, no el modelo.
MOTOR-13 (Opus xhigh) portó el anchor por ~$3; INVESTIGACIÓN (Sonnet alto) ~$39 en 2 días; SEGURIDAD-PORTES-3 (Opus medio)
~$116 en 5 días al 76 %. Relevar antes ahorra más que cambiar de modelo.

## Red del entorno de la nube

El entorno de la nube (el mismo para COORDINACIÓN, el Vigía y los demás agentes de la nube; se hereda en los relevos)
tiene la red en «Personalizado», con la lista por defecto de gestores de paquetes y dos dominios nuestros añadidos por
el HUMANO el 13-10:

- `updates.flyweb.lamosquita.net`: el Vigía lee `stable/appcast.xml` cada hora y avisa si no coincide con
  `FlyWeb/web/VERSION` de `main` («WEB DESFASADA» / «WEB SINCRONIZADA»).
- `flyweb.lamosquita.net`: COORDINACIÓN comprueba la web tras cada publicación (portada, SHA, descarga).

Solo lectura y pocas peticiones. Otro dominio se le pide al HUMANO.

## Trampas de estos días

Las de fondo están en [`docs/DIRECTIVAS.md`](../../docs/DIRECTIVAS.md) y las de MOTOR, LOCAL y PUBLICACIÓN en
[`docs/TRAMPAS.md`](../../docs/TRAMPAS.md) (OR.1, 21-10). Aquí quedan las de COORDINACIÓN.

- **Hablar con propiedad a Titín** (16-10): traer algo de la red es «descargar», nunca «bajar» (lo leyó como bajar de
  versión). Siglas siempre explicadas la primera vez (WPT = Web Platform Tests, no WebGPU).
- **No encadenar avisos ni preguntas a Titín** (16-10): un mensaje con lo que hay que decidir y esperar su respuesta,
  sin mandar otro antes. Lo que ya ha decidido no se le vuelve a plantear (p. ej. las fijadas compartidas se quedan
  encendidas: se portan los arreglos de Brave o se arregla aquí).
- **Un texto de relevo con una condición delante se pierde** (14-10). El de MOTOR-8 iba detrás de «decide antes el
  modelo» y quedó enterrado entre otros avisos: el 129 se retrasó horas. Regla 13: el texto va en un mensaje propio,
  listo para pegar, con modelo y esfuerzo en la primera línea; no se archiva a nadie hasta que su relevo esté activo;
  toda orden queda escrita también en la fila del agente.
- **Relevos de agentes locales: un solo texto, sin `/remote-control`** (regla 13, cambiada el 15-10): la app ya conecta
  Remote Control al abrir la sesión, y una orden con barra pegada junto a texto se descarta entera. El agente lo
  comprueba y, solo si falta, le pide a Titín `/remote-control` sola. LOCAL-2 quedó archivada el 13-10 (~20:30) en mitad de la compilación de
  RubyLB y dejó de recibir mensajes sin que nadie lo notara: si un agente local calla, mirar `get_session`.
- **Antes de decir que algo espera la firma del HUMANO, mirar el appcast** (`curl …/stable/appcast.xml`). El 13-10 se
  le dijo dos veces que faltaba su firma cuando ya había firmado.
- **Una sesión local solo recibe `send_message` con Remote Control activo** y sin archivar. Comprobarlo con
  `list_sessions` (`connection_status`). Si alguien la archiva desde la web, la ventana sigue abierta en la 7,1 pero
  deja de recibir mensajes. Se arregla con `/remote-control` en esa ventana (PUBLICACIÓN, 12-10).
- **Repos de la sesión** (15-10): MOTOR-9 y SEGURIDAD-PORTES-2 se abrieron solo con softmac aunque el texto pedía
  también brave-core, y `add_repo` necesita un permiso de Titín para leer y **otro para escribir** (push). El agente nuevo
  comprueba en el paso 1 qué repos tiene y, si falta brave-core, lo dice en el mensaje de prueba.
- **Script del Vigía**: `--depth=200` en vez de `--shallow-since` (fallaba con más de un día sin commits en `main`).
- **Esfuerzo**: los nombres reales son low, medium, high, `xhigh` («extra») y max. MOTOR va en `xhigh`; max solo para un
  paso atascado.
- **(19-10) Mensajes cruzados:** MOTOR y LOCAL se escriben directamente; si una orden tuya cruza con la suya, deja claro
  cuál vale («la rama -ab no se usa»). Un único punto de compilación por ronda.
- **(19-10) Cuando reinicia la app de la 7,1** vuelven sesiones viejas (LOCAL-4 se reabrió): que Titín archive las viejas.
- **(20-10) Revisar lo que propone SEGURIDAD-PORTES con criterio:** un arreglo parcial en código sensible (URL) se revierte
  si crea un tercer comportamiento; mejor diferencia conocida hasta el porte completo (FM.23).
- **(20-10) Comprobar tú lo que entra en un sha** con `git merge-base --is-ancestor` antes de darlo por bueno: MOTOR-13 dio
  dos shas sin la rama de seguridad que tenía que llevar.
- **(20-10) Notificaciones de GitHub y coste:** cada PR genera dos avisos (suscripción y cierre) y **cada aviso despierta
  a COORDINACIÓN y relee todo su contexto**; con ~30 PR al día y el contexto al 60 % es un gasto real. Agrupar los cambios
  del tablero en pocos PR (uno por tanda de decisiones, no uno por fila) y relevar a tiempo. No escribir a Titín por ellos.
- **(20-10) El reinicio semanal no ha cambiado:** es a las 07:00 UTC (09:00 en verano y 08:00 en invierno en Madrid; el
  25-10 cambia la hora). Medir el gasto por tarea con `cost_usd` de `get_session`, no por intuición.

## Texto de arranque para COORDINACIÓN-9

Abrirla desde la app: nube, repo `softmac`, **Opus 5.5, esfuerzo alto (`high`)**, y pegar:

```
Eres COORDINACIÓN de FlyWeb (monorepo lamosquita-net/softmac; fork lamosquita-net/brave-core): COORDINACIÓN-9, relevo de COORDINACIÓN-8 (session_0133Pd3pUk1DtKWpYpE53qB4). Lee en este orden: CLAUDE.md, docs/TAREAS.md (tabla, reglas 1–20, FM.28, FM.29, FM.31 y FS.20–FS.22) y FlyWeb/docs/coordinacion.md (nota de relevo del 20-10, sobre todo «Agentes y cómo hablarles» y «Trampas»: debatir con Titín antes de mover a nadie).
1. Comprueba con get_session tu modelo, si tienes send_message, tus repos y rate_limit_info. Dímelo en una línea.
2. Dame tu id de sesión y el texto exacto que debo pegar al Vigía para cambiarle el destino.
3. Anota en tu fila de docs/TAREAS.md (commit «[coord]», por PR, que fusionas tú) que COORDINACIÓN es ahora esta sesión. Avisa con send_message a MOTOR-13, SEGURIDAD-PORTES-3, INVESTIGACIÓN-MOTOR y CONTENIDOS-WEB-2 de tu id; a los de la 7,1 (LOCAL-5, PUBLICACIÓN, SERVIDOR-LOCAL-2) prueba también y, si la plataforma lo bloquea, dime qué tengo que aprobar. Archiva session_0133Pd3pUk1DtKWpYpE53qB4.
4. Abre con create_session (este entorno, repo softmac, Opus 5.5, esfuerzo medio) la sesión CONOCIMIENTO-1 para la fila OR.1 de docs/TAREAS.md (optimizar el conocimiento: archivo del tablero, DIRECTIVAS.md, arranque mínimo, manuales de método); revisa y fusiona sus PR.
5. Sigue la 1.15.2 hasta su publicación y la Fase 0 de la migración (compilación de Chromium 128 de LOCAL).
Al HUMANO se le llama Titín. Español, commits en inglés con Co-Authored-By de Claude. Breve, crítico y con conclusión; a mí solo decisiones. No me escribas por avisos rutinarios.
```
