# D8-LINUX-6 → COORDINACIÓN-64: log del fallo `[chromium-rawptr]` y estado de la prueba 1 de U3

(Pegado por D8-LINUX-6 en el chat; lo sube COORDINACIÓN-64.)

**Dónde salió:** `out/PilotoA` (`is_component_build=true`, `is_official_build=false`, `dcheck_always_on=true`, plugins de
clang de serie), objetivo `brave_unit_tests`, árbol brave-core `bc71debc89` (U3 final 1–5). Paró en [11519/13768], 25-11
17:34. Fallan 2 objetos; la Release oficial (`Release-322-linux`) no pasa el plugin y compila. Cabecera:
`brave/browser/sync/account/flyweb_sync_account_service.h`, último commit `236a04edbe`.

```
FAILED: obj/brave/browser/ui/ui/brave_settings_ui.o
In file included from ../../brave/browser/ui/webui/brave_settings_ui.cc:23:
In file included from ../../brave/browser/ui/webui/settings/brave_sync_handler.h:13:
../../brave/browser/sync/account/flyweb_sync_account_service.h:263:51: error: [chromium-rawptr] Use raw_ptr<T> instead of a raw pointer.
  263 |     const brave_sync::crypto::account::ChainKeys* proof_keys = nullptr;
../../brave/browser/sync/account/flyweb_sync_account_service.h:264:51: error: [chromium-rawptr] Use raw_ptr<T> instead of a raw pointer.
  264 |     const brave_sync::crypto::account::ChainKeys* new_chain_keys = nullptr;
3 warnings and 2 errors generated.
FAILED: obj/brave/browser/ui/ui/brave_sync_handler.o
(los mismos dos errores, 263:51 y 264:51)
```

Las 3 warnings son `-Wunnecessary-virtual-specifier` en `ad_block_subscription_download_manager.h:49/52/55`, de upstream,
no paran. Campos de la struct `CallSpec`, junto a `std::unique_ptr<ChainKeys> owned_keys`. D8-LINUX comprobará el arreglo
en `out/PilotoA` recompilando esos dos objetos.

**Prueba 1 de U3:** `out/PilotoB` = args de PilotoA + `enable_check_raw_ptr_fields=false`; recompila el árbol entero
(61 909 pasos; 21 327 a las ~19:30, `-j20`, 2 GB libres de 30). Al acabar: `brave_unit_tests
--gtest_filter='Fw1FileKeyProviderTest.*:*EncryptorLegacy*:*TemporarilyUndecryptableRowIsKept*'` e informe.
