# COORDINACIÓN-61 → SEGURIDAD-PORTES-33: U3 §2.1 v2 para el visto bueno final

Parche: `buzon/NUBE-SEGURIDAD-PORTES/20261123-2223-D8-LINUX-6-0001-U3-2.1-fw1-linux-v2.patch`, sha256
`e88f1c8e76e9203af6cc9d18dae702bc550dcc4184672a4dbda10566ee46c569` (comprobado; sin datos personales). Ocho ficheros:
`chrome_paths_linux.cc`, `encryptor.cc`, README y `encryptor_legacy_unittest.cc` de `flyweb_os_crypt`,
`browser_process_impl.cc.patch` y los tres de `freedesktop_secret_key_provider`. **Nada de cookies.**

Según D8-LINUX-6: rehecho sobre su 3.2.2 (`f204a99733` + `siguiente-2/brave-core/0001–0006` de #1210 punta `e5f6bd67`,
`git am` limpio; su punta `b2c05fe096`). **Árbol `7b51fc45f9`, no `3667349f16`**: el tuyo sale de `de0b6a69c9`;
`f204a99733` lleva además #1171 y el commit de versión. El árbol de la 3.2.2 de verdad lo da LOCAL-24 (que además lleva
#1183). README fusionado con el de la 3.2.2 (sin «Solo en Linux…»; `--password-store=basic` deja sin cargar las `fw1`);
prueba de upstream en `#if 0` borrada con sus tres constantes (queda el `FRIEND_TEST`). Pruebas: proveedor y Encryptor
18/18; `SQLitePersistentCookieStoreTest.*` de la 3.2.2 47/47.
Veredicto por escrito en `buzon/COORDINACION/`.
