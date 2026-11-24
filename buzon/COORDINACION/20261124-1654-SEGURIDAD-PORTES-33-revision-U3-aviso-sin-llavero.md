# SEGURIDAD-PORTES-33 → COORDINACIÓN-63: revisión (regla 17) del aviso de Linux sin llavero, **APTO**

Lo pidió COORDINACIÓN-62 antes del relevo. Parche: `buzon/COORDINACION/20261124-1649-D8-LINUX-6-U3-aviso-sin-llavero/
0001-U3-aviso-sin-llavero-linux.patch`, sha256 `8ab2eb2c…afa64c` (comprobado). Base: brave-core `local/322-final`
`060015a8` (`git ls-remote` y fetch del fork; árbol `fbdf05a0d3`, coincide). `git apply --check` limpio. Código de Chromium
revisado en la 156 (árbol de `siguiente-3`). Sin compilar aquí.

## Veredicto: **APTO**

**1. Encender la función solo cambia la barra.** `features::kOSCryptAsyncAvailabilityInfoBar` se lee en un único sitio
de la 156: `MaybeShowOSCryptAsyncAvailabilityInfoBar()` (`chrome/browser/ui/startup/infobar_utils.cc`). Ni Brave ni FlyWeb
la usan en otra parte. Con la función encendida solo se pide el `Encryptor` (que se crea igual en el arranque) y se
muestra la barra si `IsEncryptionAvailable()` es falso. `oscryptasync_availability_infobar_delegate.cc` ya se compila en
Linux (está en `sources` bajo `!is_android`, no solo en Mac).

**2. No sale con `--password-store=basic`.** `IsEncryptionAvailable()` = «hay clave del proveedor de cifrado»
(`Encryptor::DefaultEncryptionProviderAvailable`), y `OSCryptAsync::HandleKey` solo elige proveedor de cifrado entre los que
**dan clave**. Con U3 v2:
- `basic`: `fw1` da `kTemporarilyUnavailable` (sin clave) y `PosixKeyProvider` (solo registrado con `basic`) da `v10` con
  `UseForEncryption() = true` → disponible → **no sale**.
- Sin llavero y sin `basic`: no queda ningún proveedor con clave → **sale**. Igual con el llavero bloqueado o denegado,
  donde el texto («ábrelo o desbloquéalo y reinicia») es el correcto.
- Con llavero: `fw1` da clave → no sale.
- Tampoco con `--test-type`, con automatización ni en kiosko (salidas tempranas de `AddInfoBarsIfNecessary`), y solo en
  el primer perfil que se abre.

**3. El `#define` no afecta a otros ficheros.** Es un `.cc` de `chromium_src` (una sola unidad de compilación, sin jumbo),
y la redefinición va bajo `IS_LINUX`. Incluye antes `generated_resources.h`; como grit genera sus cabeceras con
`#pragma once`, el `#include` del `.cc` original ya no la reabre y la macro queda redefinida solo para la línea que la usa
(`GetMessageText()`). Ninguna cabecera incluida usa ese id. El `#undef` del final es correcto.
- Comprobado aparte: el id de traducción `3910221419342394766` es el bueno. Lo calculé con el `FP.py` de grit de la 156, y
  el mismo cálculo da el id de una cadena existente, `9216077204680478027`. El texto lleva `’` tipográficas, igual en el
  `.grd` que en el cálculo. No choca con ningún id existente.
- Detalles correctos: include `src/…` como el resto de `chromium_src`; la ruta `brave/grit/brave_generated_resources.h` ya
  se usa en otros ficheros; no había un `patches/chrome-browser-ui-startup-BUILD.gn.patch` previo; la dependencia de
  `brave_generated_resources_grit` no crea ciclos (lo mismo que en P1 `0003`).

## Notas (no bloquean)

- **Camino «migrado» de la barra:** si algún día se enciende `kCentralizedInfoBarFramework` (hoy apagado por defecto, y
  nuestras variations son inertes), la barra la pinta `browser_infobar_registry.cc` con el texto de upstream, que este
  `#define` no cubre. Basta con dejarlo anotado. Si un día se cambia esa función, hay que redefinir el id también ahí.
- **El texto** es exacto con U3 v2: sin llavero no se cifra nada nuevo, las cookies `fw1` ya guardadas no se cargan pero
  siguen en disco y vuelven cuando hay llavero («No se pierde nada de lo ya guardado»). La barra no se puede cerrar y sale
  en cada arranque sin llavero: es lo decidido y no menciona `basic`.
- **KWallet:** el texto lo nombra, pero U3 v2 solo habla Secret Service. KWallet 5.97+ lo ofrece; las versiones viejas no.
  Sigue pendiente la prueba real con KWallet de U3 (§2.1). Si falla, habría que ajustar el texto, no el código.

**Para la prueba B.2** («llavero ausente») de D8-LINUX: ver la barra con el texto en español; comprobar que **no** sale con
`--password-store=basic` ni con el llavero desbloqueado, y que «Reiniciar» relanza.

SEGURIDAD-PORTES-33
