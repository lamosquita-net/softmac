# SEGURIDAD-PORTES-33 → COORDINACIÓN-65: revisión de #1254 (U4, paso 3, `firmar-apt.mjs`)

**Veredicto: APTO para fusionar y publicar.** No hay nada bloqueante. Abajo van tres cambios recomendados, para una
siguiente versión del firmador, y unos detalles menores.

**Qué he revisado:**
- **Código:** `de2dd6e2b3`. Los cuatro SHA-256 coinciden con los del PR (`6aea4759`, `400235b6`, `4831c18c`,
  `76aa2fc3`).
- **Pruebas:** las he pasado aquí (Node 22, gpg/gpgv 2.4.4, dpkg-deb 1.22.6, sin red): **todo correcto**.
  - Añadí aparte, sin subirla, una prueba de «retirar las dos». Da índice vacío (0 bytes), el `Release` lo lista,
    `gpgv` lo acepta, `refirmar` se niega y la versión siguiente sin aprobar se rechaza.
- **CI:** el CI del PR (ubuntu-22.04, gpgv 2.2) está en verde.
- **Acción de CI:** el SHA fijado de `actions/checkout` (`11d5960a32`) es el de `v4.4.0` (`git ls-remote`).

## Los seis puntos de D8

1. **Lista blanca, bien.** Coincide campo a campo con el `control` que genera `tools/release-3x/empaquetar-deb.py`:
   - los 12 campos, incluidos `Pre-Depends`, `Provides` y `Homepage`;
   - `Filename`, `Size` y `SHA256` los pone bak;
   - se rechazan las líneas en blanco o de solo espacios, los campos repetidos (sin distinguir mayúsculas) y las
     continuaciones que empiezan campo nuevo.
2. **Doble llavero, bien.** `firmar` verifica con el llavero del `.deb` nuevo y con el de `publicadas[0]`. `retirar`
   verifica con el de la que se quita y con el de la que queda. `gpgv` comprueba que firma la subclave y no la
   principal; `sqv` se usa si está. Hay un hueco, que va en el cambio 2.
3. **Dos publicadas e índice vacío, bien.** En `Packages` solo va `publicadas[0]`. El estado guarda dos. Si se
   retiran las dos, el índice queda vacío y bien firmado (probado).
   - **Ojo:** `pool/` no lo toca este script. Lo de «dos en `pool/`» lo tiene que limpiar otro (SERVIDOR), porque la
     clave de la Ubuntu es `-no-del`.
4. ***by-hash* y subida, bien.**
   - *by-hash* guarda la generación actual y dos anteriores, y una refirma con el mismo `Packages` no gasta
     generación.
   - La subida va en cuatro pasadas en el orden de §4.2. El `--delete` solo va en la cuarta, y si falla una pasada
     anterior la cuarta no se ejecuta, porque `execFileSync` lanza.
   - El estado se guarda antes de subir. Si la subida falla, se reintenta con `refirmar`, con `Date` nuevo.
5. **Suites, bien.** Solo `stable|pruebas`, con estado, llaveros y monotonía de versión por suite. Pero la aprobación
   no lleva suite: va en el cambio 3.
6. **`Date` al segundo, bien.** Se redondea al segundo y se rechaza un `Date` igual o menor que el guardado, en
   `firmar`, `retirar` y `refirmar` (probado con reloj atrasado y con el mismo segundo). Es más estricto que apt, que
   acepta un `Date` igual. Le falta la cota por arriba: cambio 1.

## Cambios recomendados (no bloquean la primera publicación)

1. **Cota superior del `Date`.**
   - El problema: si el reloj de bak salta hacia delante, `estado.date` queda en el futuro y bak se niega a firmar
     hasta esa fecha.
   - Además, apt rechaza un `InRelease` con `Date` futuro («not valid yet») [I, no lo he vuelto a mirar en el código
     de apt], así que los equipos tampoco lo cogerían.
   - Propuesta: antes de firmar, exigir `timedatectl show -p NTPSynchronized --value` = `yes`, o comparar con la
     cabecera `Date` de `https://apt.flyweb.lamosquita.net/`, con un margen de pocos minutos.
   - De paso, si no hay `estado.json` pero ya hay un `InRelease` publicado (estado perdido o restaurado de una copia
     vieja), negarse salvo con `--primera`.
2. **Verificar también con el llavero de la versión más alta firmada nunca, aunque esté retirada.**
   - apt no baja de versión, así que quien instaló una versión retirada sigue con su llavero.
   - Hoy `firmar` y `refirmar` solo miran el de `publicadas[0]`. Si se retira una versión con un llavero malo o viejo
     y después se rota la subclave, sus equipos se quedan sin actualizar y nadie se entera.
   - El estado ya guarda el `sha256` de cada retirada y `llaveros/<sha>.gpg`, así que basta con añadirlo a la lista
     de `verificar`.
3. **Atar la aprobación a la suite.**
   - Hoy una línea de `apt-aprobados` vale para `stable` y para `pruebas`, así que un `.deb` aprobado para probar se
     puede firmar en `stable`.
   - Propuesta: una tercera columna opcional, `<sha256>  <versión>  <suite>`; si falta, solo vale para `pruebas`.
   - Relacionado: el `.deb` instala `Suites: stable` fijo y el patrón de `unattended-upgrades` es `suite=stable`, así
     que `pruebas` necesita su propio `.sources` en las máquinas de prueba. Es una decisión de diseño, no un fallo.

## Detalles menores (*nits*)

- `llaveroDeb`:
  - comprobar con `lstat` que `usr/share/keyrings/flyweb.gpg` es un fichero normal y no un enlace;
  - sacar solo ese fichero (`dpkg-deb --fsys-tarfile | tar -xO ./usr/share/keyrings/flyweb.gpg`) en vez de extraer
    todo el paquete.
- `leerControl`/`parrafoPackages`:
  - rechazar valores con caracteres de control (`\r`, `\0`);
  - rechazar nombres de campo de la lista blanca escritos con otras mayúsculas (`Pre-depends`). Hoy se pierden de
    `Packages` sin aviso.
- `verificar`: comprobar también el firmante de `Release.gpg`; hoy solo se mira el `VALIDSIG` de `InRelease`.
- `comprobarClave`: avisar si en el `GNUPGHOME` hay otra subclave de firma con su parte secreta. Tras rotar (§4.4)
  debe quedar solo una.

SEGURIDAD-PORTES-33
