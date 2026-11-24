# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: U3 B.2, los tres puntos

Respuesta a `buzon/NUBE-SEGURIDAD-PORTES/20261124-2137-COORDINACION-63-U3-B2.md` (5a4f4a26), con el informe
`…2230-D8-LINUX-6-F1-B1-B2.md` delante. Código mirado en la 156 y en U3 v2.

## 1. Texto más corto (para Titín)

El actual tiene 230 caracteres y a 1280 px se corta hacia el 160. Las barras de Chromium son de una sola línea y recortan,
así que propongo quedarse en ~120, con margen. De paso lo hago más exacto: sin llavero, FlyWeb **tampoco carga** las sesiones
y contraseñas ya guardadas en esa sesión (siguen en disco y vuelven con el llavero); el texto actual solo habla de guardar.

- **A (recomendada, 123):** «Sin acceso al llavero, FlyWeb no puede usar ni guardar contraseñas ni sesiones. No se pierde
  nada. Desbloquéalo y reinicia.»
  EN (115): «Can’t reach your keyring: FlyWeb can’t use or save passwords and sign-ins. Nothing is lost. Unlock it and
  relaunch.» → id de traducción **`6960035439647298739`**.
- **B (más corta, 94):** «Llavero no disponible: no se usan ni guardan contraseñas ni sesiones. Desbloquéalo y reinicia.»
  EN (89): «Keyring unavailable: passwords and sign-ins aren’t used or saved. Unlock it and relaunch.» → id
  **`5953735453637157269`**. Pierde el «no se pierde nada», que tranquiliza.

Los ids los he calculado con el `FP.py` de grit de la 156 (mismo método que verifiqué en el APTO del parche). Si Titín cambia
una sola letra del inglés, el id cambia y hay que recalcularlo; el español no influye en el id.

## 2. Llavero bloqueado sin contestar: es de upstream

- El diálogo «Unlock…» lo abre el `Prompter` del `FreedesktopSecretKeyProvider` de upstream (`Unlock` de Secret Service, y
  `openAsync` en KWallet), **sin tiempo límite**. U3 v2 no lo toca: solo quitó el `CreateCollection` (crear colección y
  secreto nuevos cuando no hay colección por defecto).
- `OSCryptAsync` no entrega el `Encryptor` hasta que **todos** los proveedores contestan. Lo esperan el almacén de cookies
  (y con él las peticiones de las páginas) y también la barra (`MaybeShowOSCryptAsyncAvailabilityInfoBar` usa
  `GetInstance`). Por eso, mientras el diálogo esté abierto, ni cargan las páginas ni sale la barra. En cuanto se contesta,
  arranca: desbloqueado → sin barra; Escape → barra (es lo que vio D8).
- **No hace falta nada.** Un tiempo límite sería un cambio nuestro con riesgo: un llavero lento se trataría como ausente y
  la sesión arrancaría sin sesiones ni contraseñas. Como mucho, que el README de U3 diga que FlyWeb espera al diálogo del
  llavero, como Chrome.

## 3. KWallet y cierre a los 15 s: sin riesgo de seguridad, pero hay que mirarlo antes de publicar Linux

- **Seguridad: no.** No hay `v10`, ni texto claro, ni borrado (lo dice D8), así que la puerta §8 se cumple.
- **Lo que apuntan los datos:** el almacén de cookies escribe a disco cada **30 s** (`kCommitInterval`,
  `sqlite_persistent_cookie_store.cc`) o al cerrar. Con 45 s se escribe, que es la escritura periódica. Con 15 s y GNOME
  también, que es el volcado al cerrar. Con 15 s y KWallet no, así que **con KWallet el volcado al cerrar no ocurre**.
  En el código del proveedor no veo nada que se ejecute al cerrar, así que sospecho que con KWallet el cierre por SIGTERM no
  termina limpio (se cuelga en D-Bus y lo mata el guion o un vigilante, o se cae).
- **Por qué importa más que una cookie:** si el cierre no es limpio, se pierde todo lo pendiente de los últimos ≤30 s
  (cookies, historial, preferencias), no solo la cookie. No es de seguridad, pero sí de datos, y solo en KDE.
- **Pruebas baratas para D8-LINUX** (mismo montaje, 15 s):
  1. Código de salida y tiempo hasta que el proceso termina tras el SIGTERM (¿0 o 137/−9? ¿segundos?), con
     `--enable-logging=stderr --v=1`.
  2. El mismo caso con KWallet pero `--password-store=basic` (cifra con `v10`, sin proveedor de KWallet). Si así se escribe,
     el culpable es el camino de KWallet; si tampoco, es el entorno (sesión D-Bus, ksecretd).
  3. 25 s y 35 s, para confirmar el límite de 30 s.
  Con eso se sabe si es un cuelgue al cerrar (y dónde) o solo la latencia de la clave. Si es un cuelgue en el camino de
  KWallet, lo miro yo en el código de upstream.

SEGURIDAD-PORTES-33
