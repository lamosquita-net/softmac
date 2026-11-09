# De COORDINACIÓN-36 a ARQUITECTURA · diseño de la sync con cuenta (3.2, F7.7)

Orden de Titín (09-11): empieza ya el diseño de la 3.2, en paralelo con la 3.1. Es papel: no hace falta ninguna máquina.

Entregable: `FlyWeb/docs/sync-cuenta.md`, por PR en softmac (lo reviso y fusiono yo; **el diseño lo aprueba Titín**,
hito 1 de `plan-3x.md` §5.2; antes de su sí, ni una línea de código).

Contenido: los puntos 1–5 de `plan-3x.md` §5.1 (derivación de claves sin que el servidor vea la contraseña; aprobación
entre aparatos; recuperación; RGPD y privacidad; transición desde las 24 palabras) con el flujo ya elegido por Titín
(06-11) y las condiciones de COORDINACIÓN-30, **más el punto 6 nuevo** (lecciones del 09-11, en main por #895):
- dos botones con alcance clarísimo («salir en este Mac» frente a «borrar la cuenta en todos», con confirmación);
- ninguna operación «en curso» sin tiempo límite, error claro y reintento;
- claves locales ilegibles (llavero cambiado) como estado propio, con «volver a unir este Mac»;
- volver a unir sin duplicar («sustituir lo local por lo de la cuenta» además de «combinar»);
- cadena borrada desde otro Mac (DISABLED_BY_ADMIN): aviso y salida, no página muerta;
- servidor: contadores anónimos de borrados de cuenta y de DISABLED_BY_ADMIN;
- la 2.x no abre un perfil ya migrado a la 3.x.
Contexto útil: el servidor actual es `FlyWeb/servidor/sync` (go-sync con SQLite, cifrado de extremo a extremo); la página
de ajustes de la 3.0.0 estaba desenganchada (FS.43, `FlyWeb/parches/3.0.2-sync-ajustes/`), no el motor.
Revisión obligatoria de SEGURIDAD antes del hito 1: deja en el documento una sección «Para la revisión de seguridad».
Ningún dato personal de Titín en el documento. Respuesta y dudas, a COORDINACIÓN-36 (`session_01MwmK2gmWuLtoTHjfCXLggq`).
