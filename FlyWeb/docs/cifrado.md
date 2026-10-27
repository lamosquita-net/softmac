# Cifrado por software en FlyWeb (FS.25, estudio y diseño)

SEGURIDAD-PORTES-7, 27-10-2026. **Estudio, sin portar nada.** Base: Chromium 128.0.6613.138 + brave-core -p21
(3cc4ce116c). Directiva de Titín del 27-10 (`docs/DIRECTIVAS.md`): algoritmos estándar, AES-256-GCM, la aceleración de
cada CPU sin exigir AVX, módulo cambiable y nada de T2 ni Secure Enclave. Decide Titín.

Marcas: **[V]** = comprobado en el código de la 128 o de su BoringSSL (f01108e4, la de `DEPS`); **[F]** = fuente
publicada (al final); **[E]** = estimación mía, sin medir. El estado del cifrado en la -p21 lo levanta MOTOR-21
(FM.42, `mojave-128.md`, «Claves y cifrado en reposo»). Aquí solo se resume lo que necesita el diseño.

## Resumen y recomendación

1. **La 128 ya trae el módulo cambiable:** `os_crypt_async` con *key providers* y AES-256-GCM. En Mac está vacío y
   todo sigue en el `v10` de siempre: AES-128-CBC sin autenticar, con una clave que se guarda en el llavero clásico.
   **Propuesta:** un *key provider* de Mac (unas 150 líneas) que guarde una clave de 256 bits en el mismo llavero
   clásico. Funciona en 10.14 y no usa T2.
2. **Lo que se gana:** cifrado autenticado (nadie puede alterar los datos sin que se note), una clave de 256 bits y
   un procedimiento escrito para cambiar de algoritmo. **Lo que no se gana:** protección frente a un *infostealer*
   que consiga la contraseña de sesión. El llavero clásico la tiene igual que ahora (§2.6). No hay que venderlo como
   más de lo que es.
3. **ChaCha20-Poly1305 no se activa por CPU, de momento.** Si la 5,1 es Westmere, las tres Mac tienen AES-NI y
   PCLMUL. Sin AES-NI, BoringSSL usa `vpaes`, que es de tiempo constante y tarda microsegundos en registros pequeños.
   Elegir el algoritmo por CPU añade dos caminos sin necesidad. Se deja como algoritmo ya preparado en el módulo y se
   decide con la medida de §6.
4. **OpenCL: descartado** (§5): pierde en latencia en registros pequeños y además está obsoleto.
5. **Passkeys:** se sigue con el teléfono o la llave USB, como decidió Titín. No a un autenticador propio por ahora.
   KeePassXC solo es posible compilando nosotros una versión para 10.14 (§3).
6. **Postcuántico:** el cifrado en reposo no cambia. Lo urgente es otra cosa: **la 128 solo tiene el Kyber de
   borrador**, que los servidores están retirando. Propongo una fila FS aparte para portar X25519MLKEM768 (§4).
7. **Contradicción con la directiva, para FM.42:** el autenticador Touch ID de la 128 crea passkeys en el Secure
   Enclave en cualquier Mac con T2, también en 10.14 (dato de MOTOR-21). Es la 7,1 si la app firmada lleva el
   entitlement. La directiva dice «nada de T2», así que propongo apagarlo.

## 1. Qué hay en la 128

### 1.1 OSCrypt síncrono (Mac) [V]

- **Constantes** (`components/os_crypt/sync/os_crypt_mac.mm`): prefijo `v10`, **AES-128-CBC** con un IV de 16
  espacios y sin MAC.
- **Clave:** PBKDF2-HMAC-SHA1 con sal `saltysalt` y 1003 iteraciones, sobre una contraseña de 16 bytes aleatorios en
  Base64 (`keychain_password_mac.mm`).
- **Dónde se guarda la contraseña:** en el llavero clásico (`SecKeychainFind/AddGenericPassword`,
  `crypto/apple_keychain_mac.cc`), con servicio «FlyWeb Safe Storage» y cuenta «FlyWeb» (brave-core
  `chromium_src/.../keychain_password_mac.mm`). No usa APIs de 10.15 ni el Secure Enclave.
- Las 1003 iteraciones no son un fallo en sí: la entrada son 128 bits aleatorios, no una contraseña humana, y
  estirarla no aporta nada.
- **El fallo es CBC sin autenticar:** quien pueda escribir en el perfil puede alterar el texto cifrado sin que se
  detecte.

### 1.2 `os_crypt_async` [V]

- **`KeyProvider`** (`components/os_crypt/async/browser/key_provider.h`) tiene tres métodos: `GetKey(callback(tag,
  Key))`, `UseForEncryption()` e `IsCompatibleWithOsCryptSync()`.
- **`OSCryptAsync`** ordena los proveedores por precedencia y monta un `KeyRing` (etiqueta → clave). Comprueba que
  ninguna etiqueta sea prefijo de otra. Cifra con el proveedor de más precedencia que tenga `UseForEncryption()`.
- **`Encryptor`** (`common/encryptor.cc`) cifra con `crypto::Aead(AES_256_GCM)`. El nonce es aleatorio de 12 bytes y
  no hay AAD. La salida es `etiqueta ‖ nonce ‖ cifrado ‖ tag de 16 bytes`. Solo existe
  `mojom::Algorithm::kAES256GCM`.
  - **Cifrar:** si no hay proveedor de cifrado, usa OSCrypt síncrono (`v10`).
  - **Descifrar:** busca la etiqueta y, si no la encuentra, usa OSCrypt síncrono. **Por eso la migración es
    automática.**
- **Proveedores en la 128: solo de Windows.** DPAPI usa `v10` y App-Bound `v20`. Se registran en
  `browser_process_impl.cc` dentro de `#if BUILDFLAG(IS_WIN)`. **En Mac la lista está vacía.**
- **Quién lo usa en la 128:**
  - Las cookies sí, con `kUseOsCryptAsyncForCookieEncryption` activada por defecto.
  - `Login Data` (contraseñas), solo con `kUseAsyncOsCryptInLoginDatabase`, que viene **desactivada**.
  - Web Data (autorrelleno) sigue en OSCrypt síncrono (`SystemEncryptor`).
- **¿Sirve ya como módulo cambiable?** Sí en el diseño, a medias en el uso. Cambiar de algoritmo es cambiar de
  proveedor y etiqueta. Falta que todos los consumidores pasen por `os_crypt_async` y que el enum de algoritmos
  tenga más de uno.

### 1.3 Librería y CPU [V]

- **AEAD:** `crypto/aead.h` ofrece `AES_256_GCM`, `AES_256_GCM_SIV` y `CHACHA20_POLY1305`.
- **AES-256-GCM en BoringSSL** se elige por CPUID y **nada exige AVX**:

| CPU | AES | GHASH | Mac |
|---|---|---|---|
| AES-NI + PCLMUL + AVX + MOVBE | `aesni_gcm` (cosido) | — | 7,1 (Cascade Lake). La 6,1 (Ivy Bridge) no tiene MOVBE: va como la fila siguiente |
| AES-NI + PCLMUL, sin AVX | AES-NI CTR | `gcm_*_clmul` | 5,1 si es Westmere; 6,1 |
| Sin AES-NI | `vpaes` (SSSE3, tiempo constante) | `gcm_*_ssse3` | 5,1 si fuera Nehalem (un 4,1 flasheado) |

- **ChaCha20-Poly1305** en asm necesita solo SSE4.1.
- **CPU de la 5,1: hay que comprobarla.** `docs/entorno-mojave.md` dice «2× Westmere, 8 núcleos». MOTOR-21 la anota
  como Nehalem. Con dos zócalos y 8 núcleos encajan el E5620 (Westmere, con AES-NI) y el E5520 de un 4,1 flasheado
  (Nehalem, sin AES-NI). Es el primer paso de §6.

## 2. Diseño propuesto

### 2.1 El módulo: `KeychainKeyProviderMac`

Es un `KeyProvider` nuevo, solo para Mac, en `chrome/browser/os_crypt/` (como los de Windows) o en `chromium_src` de
brave-core:

- **Etiqueta `fw1`.** No es prefijo de `v10` ni de `v20`, y tampoco al revés. Así no choca con ninguna etiqueta de
  upstream.
- **`GetKey`:** lee o crea una entrada genérica en el **llavero clásico**, con servicio «FlyWeb Safe Storage» y
  cuenta «FlyWeb fw1». El valor es una clave de 32 bytes de `crypto::RandBytes` (BoringSSL → `getentropy`, que existe
  desde 10.12), en Base64. Devuelve `Encryptor::Key(clave, kAES256GCM)`.
- **`UseForEncryption()=true`, `IsCompatibleWithOsCryptSync()=false`.** El `v10` sigue registrado por la vía de
  OSCrypt síncrono, solo para descifrar.
- **Sin KDF de contraseña:** la clave ya es aleatoria. HKDF (RFC 5869) solo haría falta si un día se quieren
  subclaves por consumidor. No lo propongo ahora: cada subclave es otra etiqueta y no protege frente a nadie más.
- **Agilidad (el procedimiento que pide la directiva):** subir de algoritmo o rotar la clave es añadir un proveedor
  con etiqueta nueva (`fw2`) y más precedencia. El anterior se queda con `UseForEncryption()=false`, solo para leer.
  **Nunca se borra una clave antigua del llavero** mientras puedan quedar datos con su etiqueta.

### 2.2 Algoritmo y límites

- **AES-256-GCM** con nonce aleatorio de 96 bits: es lo que ya hace el `Encryptor` [V].
- **Límite de NIST** (SP 800-38D §8.3) [F]: 2³² cifrados por clave con IV aleatorio. Con un millón de escrituras de
  cookies al día, que es mucho para un perfil, se llegaría al límite en unos 11 años [E].
- **Propuesta de rotación:** una etiqueta nueva con cada versión mayor de FlyWeb, o como mucho cada pocos años. Es
  más sencillo que llevar un contador.
- **ChaCha20-Poly1305 (RFC 8439)** [F]: añadir `kChaCha20Poly1305` al enum `algorithm.mojom` y su caso en
  `Encryptor` cuesta poco, y deja la agilidad probada. **No lo actives por CPU** (punto 3 del resumen):
  - Si se activa, cada perfil puede llevar los dos algoritmos y **descifrar siempre los dos**.
  - Un perfil copiado de una Mac a otra debe abrir igual.
- **AES-256-GCM-SIV (RFC 8452)** [F], resistente a la repetición de nonce: es la alternativa si alguna vez se pasa
  a nonces deterministas. Hoy no hace falta.

### 2.3 Migración de los perfiles con `v10`

1. **Perezosa**, la que ya hace la 128: lo nuevo se escribe con `fw1` y lo viejo se descifra con `v10` hasta que se
   reescriba.
2. **Contraseñas:** activar `kUseAsyncOsCryptInLoginDatabase`. Hay que comprobar que la 128 es estable con ella en
   Mac, porque upstream la tenía apagada. Si no, las contraseñas se quedan en `v10`.
3. **Activa (opcional):** una tarea en segundo plano que, al arrancar, reescribe las cookies y contraseñas `v10`.
   Sin ella, una contraseña guardada que no cambia nunca seguiría con `v10` para siempre.
4. **Vuelta atrás:** una FlyWeb 2.0.x sin el parche **no lee `fw1`**. Las cookies se perderían (hay que volver a
   iniciar sesión) y las contraseñas reescritas no se leerían. Sparkle no baja de versión, pero una reinstalación a
   mano sí puede. Hay que decirlo en las notas de la versión y no borrar nunca la clave `v10`.
5. **Sync** (go-sync, cifrado de extremo a extremo) no cambia: el cifrado en reposo es local.

### 2.4 El parche [E]

Son unos 6–8 ficheros, en `seg/cifrado-fw1` de brave-core:

- `keychain_key_provider_mac.{h,mm}`, más su `BUILD.gn`.
- El bloque `IS_MAC` en `browser_process_impl.cc`.
- Probablemente un `friend` en `encryptor.h`: los proveedores de Windows lo son para construir `Encryptor::Key`.
- Opcionales: el enum y el caso de ChaCha, la tarea de migración activa y el cambio de valor de la feature de
  `Login Data`.
- Pruebas: las de `components_unittests` de `os_crypt_async` y una de proveedor con un llavero falso
  (`MockAppleKeychain`).

**No toca Blink ni V8.** Por la regla 2, tampoco coincide con ningún `.patch` de motor.

### 2.5 Sin T2

- El llavero clásico y `getentropy` existen en 10.14 y en todas las Mac.
- Se usa el mismo camino en todas, también en la 7,1, para no tener dos comportamientos.
- `kSecUseDataProtectionKeychain` exige 10.15 [F] y no se usa.

### 2.6 Lo que no protege

Un *infostealer* de macOS (AMOS, Banshee…) pide la contraseña de sesión con un diálogo falso y vuelca el llavero
[F, Jamf]. Con eso tiene la clave, sea `v10` o `fw1`.

- **Windows** lo frena con App-Bound (un servicio con privilegios que comprueba quién pide la clave) [F, Google
  2024]. En Mac no hay nada equivalente en 10.14.
- **Lo que sí ayuda:** la ACL de la entrada del llavero ligada a la firma de FlyWeb (Team ID). Hay que comprobar que
  el llavero clásico la aplica a la entrada nueva. Así, otra app no la lee sin el aviso de macOS.
- **Una contraseña maestra propia** (Argon2id o scrypt, `crypto/symmetric_key` ya tiene scrypt) sería la única
  defensa real. Cambia la experiencia de uso y la decide Titín; no la incluyo.

## 3. Passkeys por software

**Estándares:** WebAuthn Level 3, que es Recomendación del W3C desde el 25-08-2026 [F], y CTAP 2.x. Las passkeys
son claves ES256 (ECDSA P-256). Opciones:

| | Funciona en 10.14 | Riesgo | Coste [E] |
|---|---|---|---|
| **A. Teléfono (híbrido) o llave USB** (lo de ahora) | Sí | La clave está fuera de la Mac: lo mejor de las cuatro | 0 |
| **B. Bitwarden** | **No**: la extensión pide Chromium 134 desde la 2026.10.0, y la app de escritorio pide macOS 12 [F, GitHub] | — | — |
| **C. KeePassXC + KeePassXC-Browser** | La extensión (pide la 124) sí entra en la 128. **KeePassXC con passkeys (2.7.7+) exige 10.15**: la última versión oficial para 10.14 es la 2.7.2, sin passkeys [F, GitHub]. Habría que compilarla nosotros para 10.14 (Qt 5.15 llega a 10.13) | La extensión inyecta un `navigator.credentials` propio en la página, que es el tipo de enganche de «Passkeys Pwned» [F, SquareX 2025]. Mantener un gestor compilado por nosotros | 8–16 h la primera compilación y pruebas, más una compilación con cada versión de seguridad (GPL-3.0) |
| **D. Autenticador propio en FlyWeb** (claves ES256 de BoringSSL cifradas con `fw1`; verificación con la contraseña de macOS por `LAContext`, que existe desde 10.10) | Sí | Pasamos a custodiar las claves. Sin sincronizar, la passkey se pierde con la Mac; sincronizarla es diseñar otro protocolo | 40–80 h más una revisión de seguridad externa |

- **Recomendación:** A. C solo si Titín quiere passkeys en la Mac sin teléfono, con su mantenimiento a la vista. D
  no, por ahora.
- `chrome.webAuthenticationProxy` [V] no es una API de proveedores de passkeys: es un proxy de sesión pensado para
  escritorio remoto.
- La importación y exportación de passkeys entre gestores (FIDO CXP/CXF) sigue en borrador [F]: no resuelve nada
  hoy.

## 4. Postcuántico: qué cambia y qué no

- **No cambia: el cifrado en reposo con AES-256.**
  - Grover deja AES-256 en unos 128 bits efectivos [F, NIST IR 8105].
  - CNSA 2.0 de la NSA (2022) mantiene AES-256 [F].
  - `fw1` ya es AES-256; `v10` (AES-128) es otra razón para migrar.
- **Cambia: la parte asimétrica.**
  - **Intercambio de claves TLS:** la 128 solo trae `X25519Kyber768Draft00` (0x6399), activo por defecto
    (`kPostQuantumKyber`) [V]. **No trae ML-KEM** (FIPS 203, 2024) [V]. Chrome pasó a X25519MLKEM768 (0x11EC) en la
    131 [F, Google 2024]. A medida que los servidores retiran el borrador, FlyWeb negocia X25519 a secas, que es
    vulnerable a «guardar ahora, descifrar después».
    - **Propuesta: fila FS nueva** para portar ML-KEM y el grupo híbrido a la BoringSSL de la 128, más el cambio en
      `net/`.
    - Coste [E]: 6–12 h, más la prueba contra servidores reales. Es lo que más rinde de esta sección.
  - **Firmas:** los certificados web y WebAuthn (ES256) siguen con ECDSA. ML-DSA (FIPS 204) en COSE tiene solo
    códigos provisionales de IANA (−48/−49/−50) [F]. No hay nada que portar hasta que lo adopten los sitios y las
    llaves.
  - **Sync propio:** lo que dependa de claves asimétricas en Brave Sync queda para revisar; no lo he mirado.

## 5. OpenCL

- **Cifras de CPU:** con AES-NI y PCLMUL, AES-GCM cuesta unos 3,5 ciclos/byte en Westmere, 2,5–2,7 en Sandy o Ivy
  Bridge, 1,3 en Haswell (AES-256) y 0,65 en Skylake [F, Gueron 2013 y 2016; Mozilla 805604]. Sin AES-NI, el AES de
  tiempo constante por software anda por 8–22 c/B [F, Käsper-Schwabe 2009].
  - Un registro de 4 KB (una contraseña o una cookie grande) son **~4 µs en la 5,1 y ~1 µs en la 7,1** [E, de esas
    cifras a ~3,4 GHz].
  - Sin AES-NI, del orden de 10–25 µs [E].
- **Con GPU:** las cifras publicadas son de **rendimiento por lotes** (decenas o cientos de Gb/s; Manavski 2007; los
  trabajos de CUDA de 2017; SSLShader en NSDI 2011 solo gana agrupando) [F].
  - No encontré cifras de latencia para registros pequeños.
  - Lanzar un kernel y copiar por PCIe cuesta del orden de decenas de µs por llamada [E, sin fuente verificada]. Eso
    ya es más que todo el cifrado en la CPU.
- **Además:**
  - Apple lo dejó obsoleto en 10.14 [F].
  - La clave pasaría a la memoria de la GPU, compartida con WebGL.
  - Las GPU de las Mac son muy distintas entre sí, y el proceso GPU es justo el que más se cae en Mojave (FM.31).
- **Conclusión: descartado.** Solo tendría sentido cifrando gigabytes de golpe, y el navegador no lo hace.

## 6. Plan de medida, coste y orden

| Paso | Qué | Dónde | Horas [E] |
|---|---|---|---|
| 0 | `sysctl -n machdep.cpu.brand_string machdep.cpu.features` (¿AES y PCLMULQDQ?) | 5,1, 6,1 y 7,1 (Titín o LOCAL) | 0,1 |
| 1 | `bssl speed` de la BoringSSL f01108e4, compilada en la 7,1 con destino 10.14: AES-256-GCM y ChaCha20-Poly1305 con 16, 256, 1350, 4096 y 16384 bytes. Repetir con AES-NI enmascarado por `OPENSSL_ia32cap`, si esta BoringSSL lo admite (por comprobar), para ver el caso sin AES-NI | las tres | 2 |
| 2 | Prototipo del parche (§2.4) con pruebas unitarias | nube (SEGURIDAD-PORTES) | 8–12 |
| 3 | Compilación, prueba de migración con un perfil `v10` real, vuelta atrás documentada, `chrome://histograms` (arranque con N cookies, carga de contraseñas) antes y después | LOCAL en la 7,1; repetir en la 5,1 | 4–6 |
| 4 | Revisión de seguridad del parche (regla 17) | SEGURIDAD-PORTES | 2 |

**Total del módulo: unas 16–22 h.** La fila de ML-KEM (6–12 h) y la opción C de passkeys (8–16 h) van aparte, si
Titín las aprueba.

**Orden que propongo:**

1. El paso 0 ya, porque cuesta 5 minutos y decide lo de ChaCha.
2. La fila de ML-KEM, por delante del módulo: es una exposición real en la red.
3. El módulo `fw1` en una 2.0.x, sin ChaCha activo.
4. Apagar el autenticador Touch ID/SE en FM.42.

## Fuentes

- NIST FIPS 197 (AES, 2001, rev. 2023); SP 800-38D (GCM, 2007, §8.3); SP 800-132 (PBKDF2, 2010); SP 800-108r1
  (2022); IR 8105 (2016); FIPS 203/204/205 (13-08-2024). https://csrc.nist.gov/
- RFC 5869 (HKDF), RFC 8439 (ChaCha20-Poly1305), RFC 8452 (AES-GCM-SIV).
- NSA, CNSA 2.0 (sept. 2022), vía draft-becker-cnsa2-tls-profile-03.
- S. Gueron, «AES-GCM software performance on the current high end CPUs», DIAC 2013,
  https://2013.diac.cr.yp.to/slides/gueron.pdf; CFRG interim 2016,
  https://www.ietf.org/proceedings/interim-2016-cfrg-01/slides/slides-interim-2016-cfrg-1-7.pdf; Mozilla bug 805604.
- E. Käsper, P. Schwabe, «Faster and Timing-Attack Resistant AES-GCM», CHES 2009, https://eprint.iacr.org/2009/129.
- Cloudflare, «Do the ChaCha» (2015); S. Manavski, «CUDA compatible GPU as an efficient hardware accelerator for AES
  cryptography», IEEE ICSPC 2007; Jang et al., «SSLShader», NSDI 2011.
- Apple: OpenCL obsoleto en 10.14 (WWDC 2018; AppleInsider 04-06-2018); `kSecUseDataProtectionKeychain` (10.15),
  developer.apple.com.
- Google Security Blog: «Improving the security of Chrome cookies on Windows» (30-07-2024); «A new path for Kyber on
  the web» (13-09-2024).
- W3C WebAuthn Level 3 (Recomendación, 25-08-2026); FIDO CXP (borrador, 03-10-2024); IANA COSE ML-DSA provisional
  (public-webauthn, abr. 2025).
- SquareX, «Passkeys Pwned», DEF CON 33 (2025); Jamf, infostealers en macOS; Büttner y Gruschka, ICISSP 2025.
- Código: chromium/chromium 128.0.6613.138 (`components/os_crypt/`, `crypto/`, `device/fido/mac/`,
  `browser_process_impl.cc`); google/boringssl f01108e4 (`crypto/fipsmodule/modes/gcm.c`, `aes/internal.h`,
  `cipher_extra/internal.h`); bitwarden/clients y keepassxreboot/keepassxc (manifiestos y `release-tool`).
- **Sin verificar en la fuente primaria:** la cifra de 3,5 c/B en Westmere (vía Wikipedia), las iteraciones de OWASP,
  la latencia de GPU por llamada y el número exacto de líneas del parche.
