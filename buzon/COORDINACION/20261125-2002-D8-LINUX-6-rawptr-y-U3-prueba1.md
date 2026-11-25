# D8-LINUX-6 → COORDINACIÓN-64: raw_ptr (PR #1242) y prueba 1 de U3

(Pegado por D8-LINUX-6 en el chat; lo sube COORDINACIÓN-64.) Respuesta a `buzon/D8-LINUX/20261125-1956-…`, puntos 1 y 3.

## 1. raw_ptr, PR #1242
- `0012-sync-raw_ptr-for-the-borrowed-keys-in-AccountService.patch`, sha256 `b49c4344…` (coincide con SHA256SUMS).
- `git am` en el brave-core de u2/src: commit local `c46fb2d5f3`. Árbol brave-core con U3 1–5 + 0012: `1409971398`.
- `out/PilotoA` (plugin `chromium-rawptr` activo): `brave_settings_ui.o` y `brave_sync_handler.o` [2/2] rc=0, 0 avisos;
  además los objetos de los `.cc` que incluyen la cabecera (`flyweb_sync_account_service.cc`, `_factory.cc`,
  `brave_profile_prefs.cc`) [24/24] rc=0.
- PilotoA iba en 11 519 de 13 768 pasos: no asegura que no salgan otros errores rawptr más adelante.
- PilotoB ya había terminado antes del parche: sin tocar.

## 3. Prueba 1 de U3, `out/PilotoB`
PilotoA + `enable_check_raw_ptr_fields=false`, árbol `bc71debc89` (U3 1–5). 61 909/61 909, rc=0, 88 min. En
`dbus-run-session`, `--ozone-platform=headless`, sin DISPLAY (sin headless la suite moría al iniciar GL).
- `Fw1FileKeyProviderTest.*`: **10/10** (CreatesKeyFileOnFirstUse, ReusesKeyAndNeverReplacesIt, SameKeyAcrossStarts,
  SameFormatAsMac, BadFileIsTemporaryAndKept, OneTrailingNewlineIsAccepted, WidePermissionsAreNarrowed, SymlinkIsRefused,
  UnwritableDirectoryIsTemporary, ReadsV10AndEncryptsFw1).
- `FlyWebEncryptorTest.*` (`encryptor_legacy_unittest.cc`; el filtro `*EncryptorLegacy*` no casaba): **7/7**, todos los de
  Linux (los dos `Unprefixed*` son `#if IS_MAC`).
- `TemporarilyUndecryptableRowIsKept` (parche 5): **no pasado.** Está en `net_unittests`, que no compila en un árbol de
  brave por algo ajeno a U3 (`net/cookies/cookie_monster_unittest.cc:1812, 2312, 2421`: «no viable conversion from
  unique_ptr<ChromiumCookieMonster> to unique_ptr<CookieMonster>», renombrado de `chromium_src`). Lo que cambia el parche 5
  está probado de extremo a extremo en el caso 5 (fila 1→1, vuelve el valor viejo).

Nota: `u3final-compila.sh` acepta solo los árboles `b31e0eb683` y `bc71debc89`; con 0012 es `1409971398`.
