# Para CONTENIDOS-WEB-3: la sync con cuenta en la web (COORDINACIÓN-59)

Titín (22-11): la 3.2.0 (publicada el 21-11) trajo la **sync con cuenta** y la web no lo explica. Comprobado en el código de la
versión publicada (brave-core `local/320g-final` 4d7ccceaf3: `components/brave_sync/crypto/account_crypto.cc`,
`browser/sync/account/`). La web no menciona la cuenta en ninguna página.

**Fuentes (léelas antes de escribir):** `FlyWeb/docs/sync-cuenta.md` (diseño; §1 resumen, §9 estados, §10–§11), `FlyWeb/docs/sync-cuenta-rgpd.md`,
`FlyWeb/parches/3.2-sync-cuenta/README.md` y sus cadenas de la página «Cuenta y sincronización» (0003, 0004),
`FlyWeb/servidor/sync/cuenta/README.md`. Lo que diga la web tiene que coincidir con lo que hace el código: si dudas, pregunta.

**Un solo PR, solo `FlyWeb/web/`** (la web la publica `web-auto` con PR + VERSION; nunca a mano):
1. **`novedades.html`**, en la 3.2.0: una entrada «Sincronización con cuenta». Un Mac nuevo entra con email, contraseña y un
   código por email, sin teclear las 24 palabras. Los datos siguen cifrados en tu Mac y nosotros no podemos leerlos. Las 24
   palabras quedan como clave de recuperación.
2. **`ayuda/sincronizar/index.html`**, rehecha para la cuenta: crear la cuenta, añadir un Mac, la contraseña olvidada (se cambia
   desde un Mac que ya sincroniza; sin ningún Mac, con las 24 palabras), los avisos («¿Has sido tú?», clave cambiada desde
   otro Mac), borrar la cuenta y los datos, y cuánto se guardan. Sigue valiendo para quien sincroniza solo con las 24 palabras.
3. **Privacidad (W2):** qué guarda ns2 por la cuenta (email, verificador, semilla cifrada, aparatos…), para qué, cuánto tiempo
   (incluida la copia de bak, que se borra a los 30 días), quién es el encargado (OVH) y cómo se ejerce cada derecho.
   **Sin datos personales de Titín:** el responsable, el NIF y el domicilio van con marcadores (RESPONSABLE, NIF, DOMICILIO,
   CONTACTO-PRIVACIDAD); los rellena Titín fuera de GitHub. Avisa en el PR de que el texto legal lo tiene que revisar quien
   lleve lo legal.

**Antes de pedir la fusión:** visto de SEGURIDAD-PORTES (que no prometa nada que el cifrado no cumpla; pídeselo por escrito en
`buzon/NUBE-SEGURIDAD-PORTES/`) y **Titín lee los textos** (COORDINACIÓN se los pasa). Estilo: el de la web actual, frases cortas,
español de España. Respuestas e informes, por escrito en `buzon/COORDINACION/`. Lee `buzon/NUBE-CONTENIDOS-WEB/` al empezar
cada turno. Relevo al 35 % de contexto, con nota.
