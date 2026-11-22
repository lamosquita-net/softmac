# U3: decisiones propias de Linux (papel)

D8-LINUX, 22-11-2026, encargo de COORDINACIÓN-60. Hito U3 de `FlyWeb/docs/plataformas.md`. **Nada compilado ni instalado.**
Fuentes: brave-core `local/321-final` `f204a99733` y Chromium 156.0.8078.110 `04545e38be`.
Marcas: **[V]** leído en el código; **[P]** reproducido; **[I]** inferencia; **[S]** sin comprobar. Lo de claves lo revisa
SEGURIDAD-PORTES (regla 17).

## 1. Conclusión

1. **Hoy una FlyWeb de Linux guardaría como Brave y con cifrado de adorno si falla el llavero.** Hay que arreglarlo antes
   del primer perfil: los nombres y la etiqueta no se cambian después sin migración.
2. **El `.deb` heredado no se genera** [P], y arreglando solo ese fallo **daría de alta el repositorio y la clave de
   Google** en el equipo del usuario [P la plantilla].
3. Recomiendo: `fw1` sobre Secret Service o KWallet, sin caer en silencio a `v10`; `apt` propio firmado en bak como
   único actualizador; un perfil de AppArmor en el paquete, sin `--no-sandbox`.

## 2. Dónde vive la clave

Lo que hay:

- `Fw1KeyProvider` es solo de Mac [V]. En Linux quedan los de Chromium: portal (15, solo descifra de serie), Secret
  Service o KWallet (10, `v11`, AES-128-CBC) y `PosixKeyProvider` (5, `v10`) [V `browser_process_impl.cc`].
- **`v10` es una clave fija y pública** (derivada de «peanuts») y cifra siempre que el de 10 falle: sin llavero, denegado
  o `--password-store=basic` [V]. El usuario no se entera.
- **Un fallo del llavero es `kPermanentlyUnavailable`** [V], justo lo que `fw1` evita en Mac porque el llamante puede borrar.
  El parche de `login_database.cc` protege `fw1` y `v10`, **no `v11`** [V]: una contraseña `v11` ilegible puede borrarse
  [I]. El de cookies solo protege `fw1`: una `v11` ilegible tira todo su eTLD+1 [V].
- **El parche heredado busca el secreto de Brave** (`application=brave`, «Brave Safe Storage», «Brave Keys») [V]: con
  Brave instalado, FlyWeb usaría su misma clave [I].
- La regla de «dato sin prefijo = texto claro heredado» está activa en Linux [V `encryptor.cc`], donde no hay 2.x que
  migrar y `v10` siempre cuenta como proveedor: sobra [I].

| Opción | Qué | Coste | Valoración |
|---|---|---|---|
| A | `v11` de Chromium con nombres de FlyWeb | un parche de 3 líneas | CBC sin autenticar; luego habría que migrar |
| **B (recomendada)** | El proveedor de Chromium, con nombres de FlyWeb, secreto de 32 bytes, HKDF-SHA256, AES-256-GCM y etiqueta `fw1` | parche pequeño y pruebas | Mismo formato que en Mac, sin migración, reutiliza el D-Bus de Secret Service y KWallet |
| C | Proveedor `fw1` propio con su código de D-Bus | varios cientos de líneas | Duplica upstream sin ganar nada |
| D | Portal de secretos | — | Upstream aún no cifra con él de serie |

Con B:

- **Nombres:** `application=flyweb`, «FlyWeb Safe Storage», carpeta «FlyWeb Keys».
- **Fallo del llavero:** `kTemporarilyUnavailable`, nunca permanente.
- **Sin llavero no se cifra con `v10` en silencio.** Propuesta: no guardar contraseñas, semilla ni token de la sync y
  decirlo. `--password-store=basic`, solo si lo pide el usuario. **Decide Titín.**
- **Portal:** no se registra en la primera versión.
- **Texto claro heredado:** limitar la regla a Mac.
- **Límite honrado:** Secret Service no separa aplicaciones; otro proceso del mismo usuario puede leer el secreto [I].
  No se vende como defensa frente a un infostealer (igual que `cifrado.md` §2.6).

Carpeta de perfil: hoy `~/.config/BraveSoftware/Brave-Browser` [V `chrome_paths_linux.cc`], **la de Brave**. Debe ser
`~/.config/LaMosquita/FlyWeb`, como la identidad de Mac, también antes del primer arranque.

## 3. Actualizaciones: `apt`

- `enable_sparkle` ya es falso fuera de Mac y `enable_update_notifications` está apagado [V]. No se escribe actualizador.
- **Repositorio:** `apt.flyweb.lamosquita.net` en ns2, estático, suite `stable`, componente `main`, `amd64`, `InRelease`.
- **Clave:** OpenPGP nueva, solo para `apt`, en bak. La firma del `InRelease` es el gesto manual de cada versión, como
  hoy la EdDSA. Subclave de firma con caducidad y `Valid-Until` con margen para no romper si una tanda se retrasa.
- **En el usuario:** `/usr/share/keyrings/flyweb.gpg` y un `flyweb.sources` con `Signed-By`. Nada en `trusted.gpg.d`. Sin
  cron: el que trae Chromium vuelve a crear el repositorio [V `repo.cron`].
- **Versión del paquete:** hoy saldría `156.0.8078.120-1` [P], igual para dos FlyWeb con la misma base y `apt` no
  actualizaría. Propuesta: `<flyweb_version>-<build>` (`3.2.1-49`), monótona como el build.
- **Aviso de reinicio:** tras `apt` el proceso viejo sigue con ficheros nuevos en disco. Comprobar en U5 [S].
- **Depende de F3:** `VERSION`, web-auto y descargas para más de un sistema, antes de U4.

## 4. El paquete heredado está roto

| Fallo | Prueba | Arreglo |
|---|---|---|
| `installer.py` de la 156 exige `RDN` y el `.info` de brave-core no lo trae: `KeyError` | [P] | `.info` propio completo (`RDN=net.lamosquita.flyweb`, `ENROLLMENTDIR`, licencia…) |
| `apt.include` escribe `dl.google.com/linux/chrome-stable/deb` y la clave de Google, y `postinst` lo ejecuta | [P la plantilla; V la llamada] | `apt.include` y `key.include` propios |
| Brave quitó `clean_sources_lists` del `postrm`: al desinstalar, ese repositorio se queda | [V] | quitar ese parche con el `apt.include` propio |
| `brave_installer.include` no lo llama nadie en la 156: faltan `brave_resources.pak` y los `brave_*_percent.pak` | [V] | añadirlos a los artefactos de `installer.py` |
| Nombre, ruta, textos y correo de Brave (`brave-browser`, `/opt/brave.com/brave`, `support@brave.com`) | [V] | `flyweb`, `/opt/lamosquita/flyweb`, textos y correo público de FlyWeb |
| Icono y `WM_CLASS` `brave-browser`; el ejecutable se llama `brave` | [V] | `flyweb`; puede ser solo al empaquetar |

Los 9 parches de Linux que he probado (instalador, llavero, integración) **aplican limpios** sobre la .110 [P]: el
problema no lo enseña `apply_patches`. El resto del porte lo mide U2.

## 5. AppArmor

- Ubuntu 26.04 restringe los espacios de nombres sin privilegios (`kernel.apparmor_restrict_unprivileged_userns=1`) [P en
  la máquina de D8-LINUX].
- Chromium 156 ya trae la plantilla (`flags=(unconfined)` con `userns`) y su `postinst` la copia y la carga si hay abi 4.0
  [V]. **Se reutiliza**, con perfil `flyweb-stable` y ruta `/opt/lamosquita/flyweb/flyweb`.
- No heredar la ruta de Brave: Ubuntu ya trae un perfil `brave` [P].
- Mantener `chrome-sandbox` setuid como respaldo, como upstream. Al purgar, retirar el perfil.
- Para probar antes del `.deb`, un perfil para la ruta de `out/`, que instala Titín. **Nunca `--no-sandbox` ni apagar la
  restricción del sistema.**

## 6. Huella

`flyweb_min_macos_version` solo se aplica en Mac [V], así que en Linux `platformVersion` sería el de Chromium. La
versión completa declarada (.82) se eligió por ser la última Stable **de Mac**: para Linux hay que elegir la suya antes
de U6. El UA dirá Linux x86_64; no se disfraza de Mac.

## 7. Lo que decide Titín

1. Clave: B (recomendada) o A.
2. Sin llavero: no guardar y avisar (recomendado) o permitir el cifrado débil con aviso.
3. Nombres, que luego no se cambian: paquete `flyweb`, `/opt/lamosquita/flyweb`, `~/.config/LaMosquita/FlyWeb`,
   `net.lamosquita.flyweb`.
4. `apt` propio con clave nueva en bak (recomendado).
5. Correo público del mantenedor del paquete (es un dato que se publica).

## 8. Orden y pruebas

| Cuándo | Qué | Puerta |
|---|---|---|
| Antes del primer arranque de U2 | perfil, nombres del llavero, proveedor B | revisión de SEGURIDAD-PORTES; siempre perfil de prueba |
| U4 | `.info`, paks, `apt.include`, versión, AppArmor | `dpkg-deb -c` y scripts sin «google» ni «brave.com»; instalar y purgar en una máquina desechable |
| U5 | GNOME y KDE; llavero cerrado, denegado y ausente; clave perdida con sync | ninguna contraseña ni cookie borrada por un fallo del llavero; nada `v10` sin pedirlo |
| U5 | sandbox | `flyweb://sandbox` con espacios de nombres y seccomp en verde |

**Sin comprobar:** KWallet real; que el resto de brave-core compile en Linux; cómo reaccionan los demás consumidores de
`Encryptor` (tokens, semilla de la sync) sin clave; el `.deb` completo (solo he ejecutado la carga de la configuración y
la plantilla de `apt`).
