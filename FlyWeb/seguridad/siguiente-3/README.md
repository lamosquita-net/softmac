# Seguridad: tanda siguiente-3 (base 3.2.2)

Lo que llegue después del corte de la 3.2.2 (23-11, ~18:57 UTC) y **no** sea Alto, Crítico o KEV se prepara aquí (orden
de COORDINACIÓN-61, buzón `5bab5221`). Lo prepara SEGURIDAD-PORTES (-33). **En qué versión entra lo decide Titín**; hasta
entonces, sin fusionar y sin versión. Lo que sea Alto, Crítico o KEV se avisa enseguida a COORDINACIÓN (Titín decide si
entra en la 3.2.2 o sale aparte).

## Base

La 3.2.2 = la 3.2.1 más `seguridad/siguiente-2` entera (PR #1210, parches en `0901b22b39`).

| Repo | Base | Parches | Árbol resultante |
|---|---|---|---|
| brave-core | árbol **`3667349f16`** (resultado de `siguiente-2/brave-core/0001`–`0006`) | — | — |
| chromium | árbol **`7e6c74e256`** (resultado de `siguiente-2/chromium/0001`–`0005`) | `chromium/0001` | **`f43b3399c7`** |

Comprobado: `git am` de `chromium/0001` sobre `7e6c74e256` da `f43b3399c7`; `git diff --diff-filter=D` vacío.
**No compilado ni probado aquí** (no hay árbol de compilación en la nube).

**Época de caché de V8:** la 3.2.2 la deja en 40. Si esta tanda cambia V8, sube a **41** una vez.

## `chromium/0001`: [M159] Blink, texto de scripts «parkable» fijado entre hilos (crbug 584952095)

Puerto del merge **`11d7cebfdf`** de 8154 (cherry-pick de main; bugs 589156867 y 584952095). **Gravedad no publicada.**
- **El fallo (uso tras liberar, en el renderer):** un módulo de script con texto `ParkableString` se pasaba tal cual a un
  worklet que corre en otro hilo. El envejecimiento del hilo principal podía «aparcar» (comprimir y liberar) el búfer
  mientras el isolate del worklet aún lo leía.
- **El parche:** `ModuleScriptCreationParams::IsolatedCopy()` hace una copia no aparcable
  (`ParkableString::CreateNonParkableCopy()`), que retiene el búfer mientras haya referencias fuera del hilo principal.
  `IsSafeToSendToAnotherThread()` exige que el texto no sea aparcable. `WorkletModuleResponsesMap` reutiliza esa copia.
  Las cadenas externas de V8 sin caché quedan solo para `ParkableString` aparcables del hilo principal. Trae pruebas en
  `module_script_test.cc` y `parkable_string_test.cc`.
- **Aplica en Mac:** el código es el de la 156 y Brave no toca esos ficheros.
- **Única adaptación:** en `module_script_creation_params.h` de la 156, `IsSafeToSendToAnotherThread()` aún no mira
  `cache_consumer_`. La condición nueva (`kWasm` o `!GetSourceText().may_be_parked()`) se añade a la expresión de la 156.
  Comprobado que existen en la 156 `may_be_parked()`, `ResolvedModuleType::kWasm`, el constructor que usa la prueba y
  `features::kCompressParkableStrings`.

**Para LOCAL:** `blink_unittests --gtest_filter='ModuleScriptTest.IsolatedCopyCreatesNonParkableSource:ParkableStringTest.*'`.

## Solo Linux

Arreglos que no afectan a Mac pero sí al porte a Linux (aprobado, DIRECTIVAS 22-11). **No se portan todavía**: se hará
cuando haya una versión de Linux que publicar (orden de COORDINACIÓN-61). Para cada uno: commit, crbug y si nuestra
configuración de Linux compila el código.

| Commit | crbug | Qué | ¿Lo compila nuestra Linux? |
|---|---|---|---|
| 8078 `97c8484b2c` [M156] | 577371305 | `ExternalVkImageBacking`: `ProduceGL()` falla si el backing guarda un `NativePixmap`, y la conversión a `NativePixmap` pasa antes, de modo que la creación falla si no se puede | **Sí se compila:** `external_vk_image_backing.cc` está en `gpu/command_buffer/service/BUILD.gn` bajo `enable_vulkan` y `is_linux \|\| is_fuchsia`. `enable_vulkan` es `true` por defecto en Linux y FlyWeb no lo cambia. **En la práctica casi no se usa:** Vulkan va apagado por defecto en Linux (`features::kVulkan`, `FEATURE_DISABLED_BY_DEFAULT` fuera de Android). Además, según el propio commit, el backing con `NativePixmap` solo se da en Fuchsia. |

## Revisados y no aplicables

- **8078 `b978da9de9`**: roll de V8 a 15.6.75.80, que solo trae `4db782064e` (ya en la 3.2.2, `siguiente-2/brave-core/0006`).
