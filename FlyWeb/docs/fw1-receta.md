# Receta de porte del proveedor `fw1` (FM.44, punto 2)

INVESTIGACIÓN-MOTOR-5, 27-10-2026. **Solo papel: nada portado ni compilado.** Parte de [`cifrado.md`](cifrado.md) (FS.25) sin
repetirlo: aquí van los ficheros y líneas, las correcciones al diseño que salen de leer el código, el esqueleto del
parche y lo que cambia al subir de nivel. Lo revisa SEGURIDAD-PORTES (regla 17). Decide Titín: `fw1` va en la 2.0.4.

Marcas: **[V]** leído en el código (`chromium/chromium`, espejo de GitHub, tags `128.0.6613.138`, `143`–`145`); **[I]**
inferencia mía; **[N]** sin comprobar. Las rutas y líneas son de la **128.0.6613.138** salvo que se diga otra cosa.

## 1. Resumen y lo que cambia respecto a `cifrado.md`

1. **Upstream trae un proveedor de llavero para Mac desde el nivel 143** (`components/os_crypt/async/browser/keychain_key_provider.{h,mm}`,
   copyright 2025; no está en el 140, sí en el 143) [V]. **No es `fw1`:** deriva la misma clave de siempre (PBKDF2-SHA1,
   sal `saltysalt`, 1003 iteraciones, 16 bytes), la etiqueta es `v10` y `IsCompatibleWithOsCryptSync()` es `true`.
   Su función es dejar de pasar por OSCrypt síncrono, no cambiar de algoritmo. Se activa con
   `features::kUseKeychainKeyProvider` y precedencia 10 (`browser_process_impl.cc` del 145, l. 1476-1481) [V].
   Sirve de **plantilla de estructura** (hilo, `PostTaskAndReplyWithResult`, `kTemporarilyUnavailable`), no de lógica.
2. **Corrección:** el constructor `Encryptor::Key(span, Algorithm)` es **público** (`encryptor.h`, l. 58, antes del
   `private:` de la l. 62) [V]. **No hace falta ningún `friend`** (`cifrado.md` §2.4 lo daba como probable). El proveedor de
   DPAPI también lo usa tal cual (`dpapi_key_provider.cc:102`) [V].
3. **Peligro que `cifrado.md` no recoge:** el constructor privado de `Key` hace `CHECK_EQ(key.size(), 32)` para
   `kAES256GCM` (`encryptor.cc:61-63`) [V]. Un ítem del llavero corrupto o de otra longitud **tumba el navegador** si el
   proveedor no valida antes. Debe devolver `std::nullopt` (y entonces `Encryptor` cae a OSCrypt síncrono, `v10`).
4. **En Mac no hay `CryptProtectMemory`:** la protección de la clave en memoria (`kProtectEncryptionKey`) está dentro de
   `#if BUILDFLAG(IS_WIN)` (`encryptor.cc:44-56`) [V]. Con `fw1` la clave de 256 bits está en claro en el proceso del navegador y,
   por mojo, en el proceso de red (las cookies, §4). Es paridad con el `v10` actual [I], pero hay que decirlo.
5. **Estimación:** 10–14 h [I] frente a las 16–22 h de `cifrado.md`: sin `friend`, con plantilla upstream, y las pruebas
   y la migración siguen siendo lo caro.

## 2. Qué toca, fichero por fichero (128)

| # | Fichero (cr128) | Qué se hace | Líneas [V] |
|---|---|---|---|
| 1 | `components/os_crypt/async/browser/key_provider.h` | Nada: la interfaz de la 128 es `GetKey(KeyCallback)` con `KeyCallback = OnceCallback<void(const std::string& tag, std::optional<Encryptor::Key>)>` | 15-17, 35, 41, 47 |
| 2 | `components/os_crypt/async/browser/BUILD.gn` | Añadir `if (is_mac) { source_set("fw1_key_provider") {...} }` junto al `if (is_win)` de `dpapi_key_provider` y su prueba en `unit_tests` | 47-62 y 64-82 |
| 3 | `components/os_crypt/async/browser/fw1_key_provider_mac.{h,mm}` (nuevos) | El proveedor (§3). **Dónde vivir:** en brave-core como fichero nuevo, p. ej. `bc/components/flyweb_os_crypt/` [I; comprobar la convención de `patches/` y `chromium_src/` con `ls`], para que no choque con ninguna actualización de `components/os_crypt` | — |
| 4 | `chrome/browser/browser_process_impl.cc` | `#include` junto a los de Windows y un bloque `#if BUILDFLAG(IS_MAC)` **entre el `#endif // IS_WIN` y `os_crypt_async_ = ...`** | include ~l. 156-158; bloque entre 1375 y 1377 |
| 5 | `components/os_crypt/async/common/{algorithm.mojom,encryptor.cc}` | Solo si se añade ChaCha (`cifrado.md` lo deja desactivado): enum `kChaCha20Poly1305`, casos en `Key::Key` (l. 61), `Encrypt` (l. 106) y `Decrypt` (l. 147) | 7, 61-63, 106, 147 |
| 6 | `components/password_manager/core/browser/features/password_features.cc` | Poner `kUseAsyncOsCryptInLoginDatabase` a `ENABLED` (hoy `DISABLED_BY_DEFAULT`); parche de una línea | 191-193 |
| 7 | `components/os_crypt/async/browser/DEPS` | Permitir `+crypto/apple_keychain.h` si hace falta | — |

**Punto de registro (fichero 4).** En la 128, `providers` es un `vector<pair<size_t, unique_ptr<KeyProvider>>>` (l. 1339-1340),
y la lista de Windows ocupa 1350-1375 [V]. La precedencia es única (`os_crypt_async.cc:43`: «Cannot have two providers with
same precedence») y manda el más alto entre los que tienen `UseForEncryption()` (l. 98-99) [V]. Propuesta: `fw1` con
precedencia **20** (más que los 10 de DPAPI y que los 10 del proveedor Keychain de upstream, para cuando llegue).

**Cookies [V].** `profile_network_context_service.cc:1083` llama a `AddCookieEncryptionManagerToNetworkContextParams` si
`kUseOsCryptAsyncForCookieEncryption` (en `chrome/browser/browser_features.cc:361`, **activada por defecto**).
`CookieEncryptionProviderImpl::GetEncryptor` (`chrome/browser/net/cookie_encryption_provider_impl.cc:14-19`) entrega el
`Encryptor` **completo** (con `fw1`) al servicio de red por mojo: las cookies nuevas saldrán `fw1` sin tocar nada más.

**Contraseñas [V].** `LoginDatabase::Init(std::unique_ptr<Encryptor>)` está en
`components/password_manager/core/browser/password_store/login_database.cc:1113` y solo la usa la ruta con
`kUseAsyncOsCryptInLoginDatabase`. **Aun con la feature, `login_database.cc` sigue llamando a `OSCrypt::` directamente**
(l. 986, 1073, 1312, 1953, 2168: metadatos y `IsEncryptionAvailable`): esos quedan en `v10` y deben seguir funcionando
(el `v10` no se retira nunca).

**Lo que queda en `v10` y hay que listar con `git grep` (LOCAL, en el checkout de la 7,1):**
`git grep -nE "OSCrypt::(En|De)cryptString|OSCryptImpl" -- '*.cc' '*.mm' ':!*unittest*' ':!*test*'`. De memoria [N]:
autorrelleno (`Web Data`), claves de extensiones y sync de Chromium; en brave-core, cualquier uso que quede tras quitar Wallet.

## 3. Esqueleto del proveedor (plantilla; no compila sin retocar)

Plantilla estructural: el `keychain_key_provider.mm` del 145 [V]. Lo que **sí cambia**: ítem propio, 32 bytes aleatorios sin
KDF, tag `fw1`, `IsCompatibleWithOsCryptSync() == false`, y validar la longitud.

```cpp
// fw1_key_provider_mac.mm  (esqueleto)
constexpr char kKeyTag[]     = "fw1";
constexpr char kServiceName[] = "FlyWeb Safe Storage";   // el de v10 (bc/chromium_src/.../keychain_password_mac.mm:14-15)
constexpr char kAccountName[] = "FlyWeb fw1";             // ítem distinto del de v10 ("FlyWeb")

std::optional<Encryptor::Key> GetKeyTask(const crypto::AppleKeychain& kc) {
  UInt32 len = 0; void* data = nullptr;
  OSStatus s = kc.FindGenericPassword(strlen(kServiceName), kServiceName,
                                      strlen(kAccountName), kAccountName, &len, &data, nullptr);
  std::string b64;
  if (s == noErr) { b64.assign(static_cast<char*>(data), len); kc.ItemFreeContent(data); }
  else if (s == errSecItemNotFound) {                      // crear: 32 bytes -> Base64 -> AddGenericPassword
    b64 = base::Base64Encode(base::RandBytesAsVector(Encryptor::Key::kAES256GCMKeySize));
    if (kc.AddGenericPassword(..., b64.size(), b64.data(), nullptr) != noErr) return std::nullopt;
  } else { return std::nullopt; }
  std::string raw;
  if (!base::Base64Decode(b64, &raw) || raw.size() != Encryptor::Key::kAES256GCMKeySize)
    return std::nullopt;                                   // NUNCA construir Key con otra longitud: CHECK
  return Encryptor::Key(base::as_byte_span(raw), mojom::Algorithm::kAES256GCM);
}
void Fw1KeyProvider::GetKey(KeyCallback cb) {
  base::ThreadPool::PostTaskAndReplyWithResult(            // Apple: el llavero, fuera del hilo de UI
      FROM_HERE, {base::TaskPriority::USER_BLOCKING, base::MayBlock()},
      base::BindOnce([]{ crypto::AppleKeychain kc; return GetKeyTask(kc); }),
      base::BindOnce([](KeyCallback cb, std::optional<Encryptor::Key> k){ std::move(cb).Run(kKeyTag, std::move(k)); }, std::move(cb)));
}
bool Fw1KeyProvider::UseForEncryption() { return true; }
bool Fw1KeyProvider::IsCompatibleWithOsCryptSync() { return false; }
```

- **Pruebas con llavero falso:** `crypto::MockAppleKeychain` (`crypto/mock_apple_keychain.h`) [V]; el proveedor debe aceptar
  un `const AppleKeychain&` inyectable (como el `KeychainKeyProvider(keychain_for_testing)` del 145).
  El interruptor `os_crypt::switches::kUseMockKeychain` ya lo respetan OSCrypt síncrono (`os_crypt_mac.mm:99-106`) y el proveedor
  de upstream; `fw1` debe respetarlo igual, o las pruebas de navegador pedirán el llavero real.
- **Longitud del ítem y Base64:** guardar Base64 (como el `v10`) evita bytes no imprimibles en Acceso a Llaveros [I].
- **Si la lectura falla** (usuario deniega, llavero bloqueado): `nullopt` → `Encryptor::EncryptString` cae a OSCrypt síncrono y
  **escribe `v10`** (`encryptor.cc:205-220`) [V]. Es degradación segura, pero silenciosa: añadir un contador (histograma) para saber
  cuántos arranques la sufren [I].

## 4. Interacciones que pueden romper algo

| Riesgo | Detalle | Qué hacer |
|---|---|---|
| **Servicio de red / cookies** | La clave viaja por mojo al servicio de red (sandbox de utilidad) [V: `GetEncryptor` entrega `Encryptor`] | Es el mismo canal que usa Windows; probar cookies tras reiniciar |
| **`kEncryptSyncCompat`** | `Encryptor::Clone(kEncryptSyncCompat)` solo elige proveedores con `is_os_crypt_sync_compatible_` (`encryptor.cc:293-300`) [V]. `fw1` no lo es, así que esos clones **no cifran con `fw1`** y caen a `v10` | Listar quién llama con esa opción (`git grep kEncryptSyncCompat`); es comportamiento esperado, pero define qué datos migran |
| **Descifrado de lo `fw1` por un consumidor que solo conoce `v10`** | Un código que lea una cookie/contraseña con OSCrypt síncrono verá el prefijo `fw1` y fallará | Revisar los usos directos de `OSCrypt::` (§2) y que todos los de lectura pasen por `Encryptor` |
| **Vuelta atrás** | Una 2.0.x sin el parche no lee `fw1` (`cifrado.md` §2.3); no se borra nunca la clave `v10` | Notas de versión; prueba de bajar de versión con un perfil real |
| **Ítem borrado por el usuario** | Si borra «FlyWeb Safe Storage / FlyWeb fw1» en Acceso a Llaveros, se crea una clave nueva y **se pierde lo cifrado**. Con `v10` hoy pasa lo mismo [I] | Documentarlo; no hay mitigación sin una copia (decide Titín) |
| **Dos binarios, un ítem** | Release, Development y Beta comparten servicio y cuenta (no varían con el canal) [I; comprobar `chromium_src`] | La ACL del ítem queda ligada a quien lo creó: probar que la Release firmada lee el ítem que creó una Development sin diálogo |
| **Clave en memoria sin protección** | Sin equivalente de `CryptProtectMemory` (§1.4) | Decirlo; no es peor que `v10` [I] |
| **Perfil copiado a otra Mac** | El ítem va en el llavero local: el perfil no abre las cookies/contraseñas `fw1` en otra Mac (igual que `v10`) [V por diseño] | Sync no cambia (cifrado de extremo a extremo propio) |

## 5. Lo que cambia al subir de nivel (para MOTOR)

Cuando se porte el nivel 143, hay **dos cosas que coinciden en el mismo sitio** (`browser_process_impl.cc`) y una renombrada.

1. **Registro:** upstream añade su `KeychainKeyProvider` (precedencia 10) tras `kUseKeychainKeyProvider` (145, l. 1476-1481) [V].
   `fw1` (precedencia 20) se mantiene **encima**. Dejar `kUseKeychainKeyProvider` en su valor por defecto (apagada en
   el 145 [N: comprobar `browser_features.cc` del 145]); si la activaran, no estorba: `fw1` sigue cifrando y el suyo solo lee `v10`.
2. **Renombres que rompen el esqueleto** (128 → 145) [V]:

| 128 | 145 |
|---|---|
| `crypto/apple_keychain.h`, `crypto::AppleKeychain` | `crypto/apple/keychain.h`, `crypto::apple::Keychain`; `Keychain::DefaultKeychain()` |
| `crypto/mock_apple_keychain.h` | `crypto/apple/mock_keychain.h` |
| `components/os_crypt/sync/keychain_password_mac.*` | `components/os_crypt/common/keychain_password_mac.h` |
| `KeyCallback(const std::string& tag, std::optional<Key>)` | `KeyCallback(tag, base::expected<Key, KeyError>)` con `KeyError::kTemporarilyUnavailable` |
| enum `Algorithm {kAES256GCM}` | `{kAES256GCM, kAES128CBC}` (`algorithm.mojom` del 145: `kAES128CBC` «compatible con v11 de Linux») |

3. **Qué se gana:** con el `KeyError` de upstream, el reintento ante «temporalmente no disponible» lo hace `OSCryptAsync`, y
   `fw1` deja de bajar a `v10` por un fallo puntual del llavero. Es una razón para adoptar el nuevo `KeyCallback` en cuanto se porte.
4. **Seguimiento:** `os_crypt_async` cambia casi cada nivel (131: `secret_portal_key_provider`; 135: Linux; 150: `os_crypt_win`, `posix_key_provider`).
   La regla 17 pide a SEGURIDAD-PORTES releer `encryptor.cc` y `os_crypt_async.cc` en cada nivel: son los dos ficheros que
   `fw1` toca o de los que depende.

## 6. Pruebas y orden de trabajo (propuesta para la 2.0.4)

| Paso | Qué | Dónde | Horas [I] |
|---|---|---|---|
| 0 | `sysctl -n machdep.cpu.features` en la 5,1 (AES, PCLMULQDQ) | Titín o LOCAL | 0,1 |
| 1 | Proveedor + registro + BUILD.gn + prueba con `MockAppleKeychain` (`components_unittests`, filtro `*OSCrypt*`) | nube (SEGURIDAD-PORTES o MOTOR) | 6–8 |
| 2 | `kUseAsyncOsCryptInLoginDatabase` activada y migración perezosa: perfil `v10` real → cookies y contraseñas legibles, escritas nuevas `fw1`; `sqlite3` sobre `Cookies` y `Login Data` para ver el prefijo | LOCAL, 6,1 y 7,1 | 3–4 |
| 3 | Vuelta atrás con la 2.0.3 sobre un perfil con datos `fw1` (documentar la pérdida de cookies) | LOCAL | 1 |
| 4 | Arranque en frío: `OSCrypt.AsyncInitialization.Time` en `chrome://histograms`, con y sin ítem; ítem corrupto (longitud ≠ 32) **no cae** | LOCAL | 1 |
| 5 | Revisión de seguridad (regla 17): `encryptor.cc`, `os_crypt_async.cc` y arreglos de upstream posteriores | SEGURIDAD-PORTES | 2 |

**Total 10–14 h.** ChaCha y la reescritura activa de `v10` siguen fuera, como en `cifrado.md`.

## 6 bis. Fallos de `fw1` vistos al ejecutar la 2.5.0 y lo que sigue en `v10` (MOTOR-40, 30-10)

Tres fallos que solo salieron al arrancar en la 7,1 (detalle en `version-2.5.0.md`), más uno de revisión:
1. Caída al arrancar (`CHECK(password_sync_bridge_)`): brave-core 8ef2fe9cd5.
2. Contraseñas nuevas en `v10` (`kEncryptSyncCompat`): 096c7d72f0.
3. Caída de workers (V8 13.6, no es de `fw1`): 8bec0800e4.
4. **Borrado en silencio** de las contraseñas `fw1` en la primera fusión de sync si la clave `fw1` no carga o se
   regenera (`DeleteUndecryptableLogins` solo mira la clave `v10`): `nube/fw1-no-borrar` ddd9687f.

**Sigue en `v10` (OSCrypt síncrono, no `os_crypt_async`; FS después de la 2.6.0):** tarjetas e IBAN de autofill
(`autofill/.../webdata/system_encryptor.cc`), tokens OAuth (`signin/public/webdata/token_service_table.cc`,
`device_oauth2_token_store_desktop.cc`), claves de sync (`sync/nigori/nigori_storage_impl.cc`,
`sync/service/sync_service_crypto.cc`), GCM (`gcm_driver/system_encryptor.cc`), enclave de WebAuthn (`enclave_manager.cc`),
`app_shim_registry.cc`, `hash_password_manager.cc` y `cookie_config/cookie_store_util.cc`. Ya en `fw1`: cookies y
contraseñas. Volver a la 2.4.0 deja ilegible lo guardado o cambiado con la 2.5.0.

**Sin probar al ejecutar (LOCAL, 30-10):** clave `fw1` ausente con sync, dos perfiles a la vez, importar y exportar,
sync con servidor real.

## 7. Qué nos aleja de upstream

- Un fichero nuevo (+ su prueba) y **dos parches pequeños**: bloque `IS_MAC` en `browser_process_impl.cc` (≈10 líneas) y la
  feature de contraseñas (1 línea). Con ChaCha, `algorithm.mojom` y `encryptor.cc` crecen: por eso se deja para después.
- Coste de mantenimiento: el bloque de registro se rebasa en cada nivel donde upstream toque esa lista (131, 135, 143, 150 lo
  hicieron) [V]. Es el mismo punto que ya parchea el resto del fork.
- Riesgo de seguridad mayor: **añadir una clave de 256 bits no mejora la defensa frente a un infostealer** (`cifrado.md` §2.6):
  no hay que presentarlo en la web como más de lo que es. Lo que sí aporta es el cifrado autenticado (GCM).

## Fuentes

- Código: chromium/chromium en los tags `128.0.6613.138`, `143`–`145`: `components/os_crypt/async/{browser,common}/*`,
  `chrome/browser/browser_process_impl.cc`, `chrome/browser/net/cookie_encryption_provider_impl.cc`,
  `chrome/browser/net/profile_network_context_service.cc`, `chrome/browser/browser_features.cc`,
  `components/password_manager/core/browser/{features/password_features.cc,password_store/login_database.cc}`,
  `components/os_crypt/sync/{os_crypt_mac.mm,keychain_password_mac.mm}`, `crypto/apple_keychain.h`.
- Dentro del repo: [`cifrado.md`](cifrado.md), [`mojave-128.md`](mojave-128.md) («Claves y cifrado en reposo»).
- NIST SP 800-38D §8.3 (límite de nonces aleatorios en AES-GCM), tal como lo cita `cifrado.md`.
- **Límites:** no hay checkout de brave-core aquí; las rutas `bc/…` y los `patches/` se dan por `cifrado.md` y `mojave-128.md`. No se
  ha mirado la 116 salvo que `components/os_crypt/async/browser/` ya existía con `key_provider.h` y `os_crypt_async.cc`.
