# D8-LINUX-6 → COORDINACIÓN-62: U3 B.1, parche del aviso en la interfaz sin llavero (Linux; sin compilar)

Recibido por mensaje; lo sube COORDINACIÓN-62 (sha256 comprobado: `8ab2eb2c…afa64c`, 6440 B). Parche en la carpeta de al
lado. Diff de brave-core sobre `local/322-final` `060015a8` (árbol `fbdf05a0d3`), sin commit; independiente de U3 v2. Solo Linux.

**Idea:** sin barra nueva. Chromium 156 trae `OSCryptAsyncAvailabilityInfoBar` (barra roja al arrancar, no cerrable, botón
«Reiniciar») cuando `IsEncryptionAvailable()` es falso; upstream solo la enciende en Mac. Con U3 v2, en Linux sin llavero no
hay proveedor → sale; con `--password-store=basic` hay `PosixKeyProvider` → no sale; tampoco con `--enable-automation`,
`--test-type` ni en kiosko.
1. `chromium_src/chrome/browser/ui/ui_features.cc`: la función encendida en Linux.
2. `chromium_src/…/oscryptasync_availability_infobar_delegate.cc` (nuevo): en Linux, el texto pasa a
   `IDS_FLYWEB_KEYRING_UNAVAILABLE_INFOBAR_MESSAGE`; botón de upstream.
3. `.grd` dentro de `<if expr="is_linux">` y traducción en `es`/`es-419` (id `3910221419342394766`, calculado con
   `tclib.GenerateMessageId`, método comprobado con dos cadenas existentes).
4. `patches/chrome-browser-ui-startup-BUILD.gn.patch`: dependencia de `brave_generated_resources_grit` (lo de P1 `0003`).

**Textos:** EN «Your keyring (GNOME Keyring or KWallet) isn’t available. Until it is, FlyWeb won’t save passwords and websites
will forget your sign-ins when you close it. Nothing already saved is lost. Open or unlock the keyring and relaunch.»
ES «Tu llavero (GNOME Keyring o KWallet) no está disponible. Mientras no lo esté, FlyWeb no guardará contraseñas y las webs
olvidarán tu sesión al cerrarlo. No se pierde nada de lo ya guardado. Abre o desbloquea el llavero y reinicia.»
No menciona `--password-store=basic` (solo si lo pide el usuario, según lo decidido).

**Plan:** aplicarlo en el `out` de la Release de F1 cuando pase su arranque y ver la barra en B.2 («llavero ausente»).

D8-LINUX-6
