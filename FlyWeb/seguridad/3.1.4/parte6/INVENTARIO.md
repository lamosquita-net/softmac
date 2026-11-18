# FlyWeb 3.1.4, parte 6: inventario de los 54 bajos de Chrome 158

SEGURIDAD-PORTES-28, 18-11-2026, por orden de COORDINACIÓN-49 (decisión de Titín, 18-11: en la 3.1.4 entra toda la
seguridad que aplica a Mac, aunque pida un gesto del usuario o instalar algo). Lo portado y el veredicto, en
[`CONTENIDO.md`](CONTENIDO.md).

## Método

- **Nota de la 158 estable** (17-11, 11:12 PT; feed Atom con `redirect=false`): 204 arreglos, **54 bajos**. Ninguno
  está en las notas de Extended Stable de la 156 (cruce por número de bug con todas las entradas del feed).
- **Commit de cada bug:** líneas `Bug:`/`Fixed:` en la historia de `158.0.8127.66` (22 834 commits desde
  `156.0.8078.0`, espejo de GitHub con `--filter=tree:0`). Los que no salen ahí (V8, WebRTC, Tint, ANGLE, libaom,
  libvpx, devtools-frontend), con `search/commits` en sus espejos. **Los 54 tienen commit.**
- **8078 y la serie:** ninguno está en la 8078 hasta la .110 (`log` de `156.0.8078.110`) ni después
  (`+log/156.0.8078.110..refs/branch-heads/8078`, gitiles, 18-11 ~15:30 UTC), ni en las partes 1–3. **Dos ya están en la
  parte 4** (mismo commit, que arreglaba también un medio): 6c67a1fe y c06e1d94.
- **8127 después de la .66** (`+log/158.0.8127.66..refs/branch-heads/8127`): ningún arreglo más de estos bugs.
- **Arreglos posteriores en `main`** (`search/commits` por bug con `committer-date:>2026-10-26`): solo 2643f6e87f
  (554558674) y 0777cdb316 (564769937); ver «Preguntas» en `CONTENIDO.md`.
- **Aplicabilidad:** `git apply --check` sobre el árbol `986d591616` y lectura del código y de lo que lo activa en
  la 156 y en brave-core `15c050d35a`.

## Resumen

| | Nº |
|---|---|
| Bajos de la 158 | 54 |
| Ya en la parte 4 | 2 |
| **Entran en la parte 6** | **35** (chromium 0001–0032; V8 4; devtools-frontend 2; WebRTC, libaom y libvpx 1 cada uno) |
| Fuera: no se compila en Mac (Android, ChromeOS, Aura, Windows, *host* de *remoting*) | 8 |
| Fuera: código apagado o quitado en FlyWeb | 9 |

## Los 54

«Parche» remite a `parte6/`. «a mano»: ver la nota del commit y `CONTENIDO.md`.

| Bug | CVE | Componente | Arreglo | Estado |
|---|---|---|---|---|
| 474737096 | CVE-2026-130939 | LocalNetworkAccess | 44be2964 | **entra**: chromium 0007 (a mano, solo contexto) |
| 392139161 | CVE-2026-130935 | Referrer | 190a65e0 + 473844a0 | **entra**: chromium 0022 y 0025 |
| 497098609 | CVE-2026-131088 | WebAppInstalls | 6c67a1fe | **ya en la parte 4** (`parte4/chromium/0007`) |
| 502048148 | CVE-2026-131041 | Editing | b5776ae9 | **entra**: chromium 0023 |
| 502803648 | CVE-2026-131016 | DevTools | b2f73173 | **entra**: chromium 0014 (a mano) |
| 506142100 | CVE-2026-131040 | Extensions | 5095ebef, fad4d6c9, f2d0bee9 | **entra**: chromium 0006, 0008, 0015 |
| 511803678 | CVE-2026-130925 | Downloads | fd5816cb | **entra**: chromium 0010 |
| 513198336 | CVE-2026-130921 | WebRTC | webrtc 326fd06bb4 | **entra**: webrtc 0001 (sin la prueba) |
| 513329281 | CVE-2026-130912 | Network | a156403f | **entra**: chromium 0032 |
| 513841847 | CVE-2026-130967 | DevTools | cbc0babb | **entra**: chromium 0017 (a mano, solo contexto) |
| 514008162 | CVE-2026-131009 | Passwords | 71b45ec0 | **entra**: chromium 0029 |
| 518998812 | CVE-2026-130978 | Media | 977af44a | fuera: ChromeOS |
| 519999855 | CVE-2026-130931 | Extensions | c06e1d94 | **ya en la parte 4** (`parte4/chromium/0018`) |
| 521476204 | CVE-2026-130908 | Passwords | 2a144f74 | **entra**: chromium 0028 |
| 536479671 | CVE-2026-131099 | ANGLE | angle c1d961037f (+ 44892ec146) | fuera: backend Vulkan, apagado |
| 540124890 | CVE-2026-131072 | HID | 3564afa6 | fuera: WebHID apagado |
| 550780268 | CVE-2026-131034 | SurfaceCapture | 2665b0b2 | **entra**: chromium 0030 |
| 551608036 | CVE-2026-131073 | Passwords | 01ca9927, 8bb4a4aa | fuera: cambio automático de contraseña, apagado |
| 553136985 | CVE-2026-130983 | DevTools | 07df9ad1 | **entra**: chromium 0004 |
| 553152493 | CVE-2026-131105 | Glic | f3326a52, 4454b951 | fuera: Glic, apagado |
| 553152636 | CVE-2026-130911 | DevTools | devtools-frontend 42c22bbeaa | **entra**: devtools-frontend 0001 |
| 553154509 | CVE-2026-131102 | FileSystem | 29c826c4 | fuera: FSA local apagado |
| 553259600 | CVE-2026-121101 | DevTools | 5cd7a5cb, e0b66956, 75c0c828, d6cb7844 | **entra**: chromium 0002, 0003, 0019 (a mano, un `#include`), 0020 |
| 553263303 | CVE-2026-130916 | DevTools | v8 0b3bd2b | **entra**: brave-core 0001 (`patches/v8`) |
| 554558674 | CVE-2026-131018 | DevTools | d59f8fb6 | **entra**: chromium 0026 (a mano, solo contexto) |
| 562909022 | CVE-2026-131085 | PermissionElement | 4cbb0608 | **entra**: chromium 0012 |
| 562910021 | CVE-2026-130981 | Enterprise | 8397133b | **entra**: chromium 0021 (solo el texto de la política) |
| 562957022 | CVE-2026-130973 | Sensor | e1278b78 | **entra**: chromium 0016 |
| 562971921 | CVE-2026-131027 | Browser | fceca5d3 | **entra**: chromium 0005 |
| 564769937 | CVE-2026-131012 | Services | c50c2dd3 | **entra**: chromium 0031 |
| 566504721 | CVE-2026-131029 | Extensions | 7811f3b4 | **entra**: chromium 0009 |
| 567397860 | CVE-2026-131049 | SignIn | c47d214e | fuera: DBSC de la cuenta de Google, apagado |
| 567765567 | CVE-2026-130955 | Mobile | 72224870, c8846de4 | fuera: Android |
| 567944558 | CVE-2026-131035 | Media | libaom e161f898a0 | **entra**: libaom 0001 (sin la prueba) |
| 568576341 | CVE-2026-130927 | DevTools | bdfe61c9 | **entra**: chromium 0013 |
| 568967707 | CVE-2026-130949 | Passwords | 63cf207d | fuera: Android |
| 568979550 | CVE-2026-130906 | DevTools | 18077609 → reland 66b8eb89 | **entra**: chromium 0011 (el *reland*, sin pruebas) |
| 568986689 | CVE-2026-131005 | DevTools | v8 336a6b3 | **entra**: brave-core 0001 (`patches/v8`) |
| 568989951 | CVE-2026-130920 | Payments | 4049c540 | fuera: Android |
| 569008693 | CVE-2026-130953 | Core | 72fa76ad [M158] | fuera: Aura |
| 569010448 | CVE-2026-130922 | UI | bb0c440c | fuera: Android |
| 569017013 | CVE-2026-130964 | DevTools | devtools-frontend 852dcde1bd | **entra**: devtools-frontend 0002 (a mano) |
| 569127860 | CVE-2026-130993 | Script | 18c85439 | fuera: código vacío en brave-core |
| 571722742 | CVE-2026-130998 | Parser | 87deb2e2 | **entra**: chromium 0001 |
| 572312093 | CVE-2026-130950 | V8 | v8 fb3bcc3 | **entra**: brave-core 0001 (`patches/v8`) |
| 573244957 | CVE-2026-131055 | Editing | 62e6a3a7 | **entra**: chromium 0018 (a mano, el json5) |
| 573591801 | CVE-2026-130919 | Printing | edf25217 | fuera: Windows |
| 573760540 | CVE-2026-131001 | Video | libvpx 0a6d123f0c | **entra**: libvpx 0001 (sin la prueba nueva) |
| 574212789 | CVE-2026-130966 | Tint | dawn 197c7eeec4 | fuera: WebGPU apagado |
| 574412712 | CVE-2026-131098 | V8 | v8 0ac2b27 | **entra**: brave-core 0001 (`patches/v8`; época 36) |
| 574643577 | CVE-2026-131037 | Chromoting | c9868270 | fuera: *host* de Chrome Remote Desktop |
| 575048405 | CVE-2026-130972 | PictureInPicture | 9e42f026 | **entra**: chromium 0027 |
| 575506658 | CVE-2026-130918 | Views | 850273ef | **entra**: chromium 0024 (a mano) |
| 576501766 | CVE-2026-130904 | SiteSettings | 1845772a | fuera: geolocalización aproximada, apagada |

## Fuera, con su comprobación

| Bug | Motivo | Comprobación |
|---|---|---|
| 518998812 | ChromeOS | El cambio de `cast_mirroring_service_host.cc` va dentro de `#if BUILDFLAG(IS_CHROMEOS)` y el resto es `chrome/browser/ash/` |
| 567765567, 568967707, 568989951, 569010448 | Android | Java de Android, `credential_leak_controller_android.cc` y el *hunk* de `chrome_password_manager_client.cc` dentro de `#if BUILDFLAG(IS_ANDROID)`, `PaymentManifestVerifier.java`, `ui/android/` |
| 569008693 | Aura | Solo `web_contents_view_aura.*` y `ui/aura/`; Mac usa `WebContentsViewMac` (Cocoa) |
| 573591801 | Windows | `pdf_to_emf_converter.cc` está bajo `if (is_win)` en `chrome/browser/printing/BUILD.gn` |
| 574643577 | No está en el navegador | `remoting/host` y `remoting/protocol` son el *host* de Chrome Remote Desktop, un producto aparte; `chrome/browser/BUILD.gn` solo depende de `//remoting/host/chromeos` |
| 536479671 | Apagado | ANGLE compila su backend Vulkan en Mac (`angle.gni`: `is_mac`), pero solo se usa con SwiftShader, y en la 156 SwiftShader exige `--enable-unsafe-swiftshader` o `--use-angle=swiftshader` (`IsSwiftShaderAllowedByCommandLine`; `kAllowSwiftShaderFallback` DISABLED). brave-core no lo cambia. WebGL de FlyWeb va por Metal (u OpenGL antes de macOS 11) |
| 574212789 | Apagado | Tint es de Dawn (WebGPU): `kWebGPUService` DISABLED en brave-core (`chromium_src/gpu/config/gpu_finch_features.cc`) y Graphite fuera |
| 540124890 | Apagado | `HidService` sale si `blink::features::kWebHID` está apagado (`hid_service.cc`, líneas 163 y 211); brave-core lo apaga (FlyWeb 3.0.2, `chromium_src/third_party/blink/common/features.cc`) |
| 553152493 | Apagado | `GlicEnabling::ProfileEnablement::IsEnabled()` exige `primary_account_is_capable` (cuenta de Google con sesión en el navegador) y brave-core pone `prefs::kSigninAllowed` = false (`browser/profiles/brave_profile_manager.cc`). f3326a52 solo borra la fontanería de arrastre que usaba Glic |
| 551608036 | Apagado | `ChromePasswordChangeService::GetGeneralAvailability()` exige `ShouldModelExecutionBeAllowedForUser()` (ejecución de modelos de Google, con sesión de Google) |
| 567397860 | Apagado | `bound_session_credentials` es el DBSC de la cuenta de Google en Chrome: `kEnableBoundSessionCredentials` solo está encendido en Windows (`signin_switches.cc`) y sin sesión de Google no hay registro |
| 553154509 | Apagado | La burbuja de restaurar permisos de FSA solo sale con *handles* locales; brave-core apaga `kFileSystemAccessAPI` y con él `FileSystemAccessLocal` (`renderer/brave_content_renderer_client.cc`): sin selectores ni *handles* locales |
| 576501766 | Apagado | `GEOLOCATION_WITH_OPTIONS` solo se usa con `kApproximateGeolocationPermission`, DISABLED fuera de Android en la 156 |
| 569127860 | Quitado | 18c85439 arregla `DetectFrameworkVersions()`, al que solo llama `DetectJavascriptFrameworksOnLoad()`, que brave-core deja vacío (`chromium_src/.../detect_javascript_frameworks.cc`) |
