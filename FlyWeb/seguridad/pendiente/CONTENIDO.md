# Seguridad pendiente: para la siguiente versión de FlyWeb

**Decisión de Titín (19-11-2026, vía COORDINACIÓN-51):** la 3.1.4 build 47 queda publicada tal cual y **no hay 3.1.5 por
ahora**. Lo que llegó a la rama 8078 después de compilarla espera aquí y entra en **la siguiente versión que salga**:
la próxima tanda de seguridad (Chrome 159) o la 3.2.0, la que llegue antes.

**Si alguno de estos bugs resulta Alto o Crítico, entra en el catálogo KEV de CISA o se explota, se avisa enseguida a
COORDINACIÓN**, que propondrá una 3.1.5 a Titín.

Lo prepara y lo vigila SEGURIDAD-PORTES (desde la -32). Cada arreglo nuevo de la 8078, o de la rama de la 159 cuando
salga, que aplique a Mac se añade aquí con APTO: `chromium/` con número correlativo, `angle/` aparte, y su línea en
`SHA256SUMS`.

## Base

Los dos parches se hicieron y comprobaron sobre los árboles **finales de la 3.1.4** (build 47):

| Repo | Base | Parches de aquí | Árbol resultante |
|---|---|---|---|
| chromium | árbol **`e7162cd585`** (`local/314-adapt` `aaa7d7508d` + `3.1.4/integracion/chromium` 0002–0004; sin el commit de fijación) | `chromium/0001` | **`2c8ef28a99`** |
| ANGLE | árbol **`db885a866b`** (`f10470c77e` + `3.0.1/angle` 0001–0012 + `parches/3.1-angle` 0001–0004 + `3.1.4/angle` 0001–0003) | `angle/0001` | **`fb21437e81`** |
| brave-core | `local/3.1.4-adapt` **`e660929`** (V8 15.6.75.66 con todos los `patches/v8`) | `brave-core/0001` | **`90134a4e08`** |

Si la siguiente versión cambia de base (p. ej. la 3.2.0 o la 159), **hay que volver a comprobar que aplican**; puede que
la base nueva ya los traiga.

## Rama 8078 después de la build 47

| Commit de la 8078 | Qué | ¿Mac? | Parche |
|---|---|---|---|
| `0ca9887568` (19-11 08:32 UTC) | *Roll* de ANGLE `f4f835734108..0b547a1161fb`: **41c5deee45** y 0b547a1161 | 41c5deee45 sí; 0b547a1161 no (abajo) | `angle/0001` |
| `b243cdcc16` (19-11 09:19 UTC) | «[M156] Disallow creating symbolic links in the macOS network service sandbox» | Sí (solo Mac) | `chromium/0001` |

| `ff774db0a2` (19-11 16:03 UTC) | *Roll* de Dawn `6d772bc9e5c5..062164c3c784` | **Por revisar** (abajo) | — |
| V8 15.6 `9f5c567b62` (.72, 16:01 UTC) | **d68cecd900** [M156] «[debug] Invalidate kNotAssigned assumptions on debugger context stores» | Sí | `brave-core/0001` |

Sin tag .112 (la rama ya llevaba `chrome/VERSION` en .112 desde `aac2cdd377`).

## `angle/0001`: ANGLE 41c5deee45 (bug 574209990, merge 579732514)

Validación del *frontend* de libANGLE (`src/libANGLE/validationES3.cpp`): `glTexSubImage*D` aceptaba `GL_RGB8` y
`GL_RGB565` con `GL_UNSIGNED_INT_2_10_10_10_REV_EXT` sin `GL_OES_required_internalformat` ni
`GL_EXT_texture_type_2_10_10_10_REV`, porque la comprobación de extensiones solo estaba en el camino de creación. Ahora
`ValidES3ExtensionFormatCombination` mira las extensiones en los dos caminos. Se compila y se usa en Mac, con Metal y
con el respaldo GL.

- Aplica limpio con `git am` sobre `db885a866b` y deja el árbol en `fb21437e81`. Mismo `patch-id` que el original
  (`53571bf905`).
- Los campos que usa (`requiredInternalformatOES`, `depthTextureOES`, `depth32OES`, `textureType2101010REVEXT`) existen
  en `gles_extensions_autogen.h`, y los dos únicos llamantes de la función quedan actualizados.
- `validationES3.cpp` pasa `clang++ -fsyntax-only` con el parche.
- La prueba nueva va en `TextureTest.cpp` (`angle_end2end_tests`; no entra en la build del navegador).
- **Gravedad: no se sabe.** El bug está restringido y no aparece en ningún texto público leído (búsqueda web y notas
  de Chrome Releases; los cuerpos de las entradas de escritorio del 27-10, el 29-10 y el 3-11 llegaron vacíos). No hay
  CVE ni consta explotación. Google lo portó a la M156 (*extended stable*). Estimación sin confirmar: Medio.
- **Para LOCAL:** `git am` sobre su ANGLE y volver a fijar el gitlink de `third_party/angle` y `angle_revision` en `DEPS`
  (como con `3.1.4/angle/`). No toca chromium ni brave-core.

**No aplica: 0b547a1161** (bug 550489336, merge 579732851), «GL: Double clear for robust resource init on Mali and
Adreno». Es una solución del backend GL que solo se enciende con GPU Mali o Adreno ≤ 6xx (`renderergl_utils.cpp`:
`isMali || IsAdreno6xxOrOlder`). Ningún Mac lleva esas GPU. Mismo criterio que 569191970 (PowerVR, `3.1.4/CONTENIDO.md` §D).

### Veredicto (regla 17): **APTO**, `angle/0001`

Es el *cherry-pick* de upstream sin cambios. Solo endurece la validación: subir una textura `RGB8`/`RGB565` con el tipo
`2_10_10_10_REV` sin las dos extensiones da `GL_INVALID_OPERATION`, como ya pasaba al crearla. Las combinaciones de ES
3.0 (`GL_UNSIGNED_BYTE`, `GL_UNSIGNED_SHORT_5_6_5`) no cambian. Prueba: `angle_end2end_tests --gtest_filter='*TextureTest*'`
si se compilan; a mano, una página WebGL 2 que dibuje texturas.

## `chromium/0001`: b243cdcc16 (bugs 577326267 y 578671128)

El perfil de sandbox del servicio de red de Mac (`sandbox/policy/mac/network.sb`) prohíbe crear enlaces simbólicos
(`(deny file-write-create (vnode-type SYMLINK))`) en sus directorios de almacenamiento y caché. Lleva el interruptor
`kMacSandboxAllowNetworkSymlinkCreation` (`content/browser/sandbox_parameters_mac.{h,mm}`), **apagado** por defecto,
que se pasa al perfil como `ALLOW_NETWORK_SYMLINK_CREATION`. La constante `kParam…` la genera `generate_params.py` a
partir del `define` del `.sb`.

- Las líneas `+`/`-` son idénticas a las de upstream. Solo se recolocó la del `.h` junto a `kMacSandboxAllowRendererPidinfo`,
  que añadió `3.1.5/chromium/0024` (choque solo de contexto). El `patch-id` cambia por eso (`dc4849b6ac` frente a
  `9563de45a9`).
- Comprobado con `git am`: sobre `local/314-adapt` `aaa7d7508d`, `3.1.4/integracion/chromium` 0002–0004 reproducen sus
  árboles (`25a6269c6b`, `32203fc124`, `e7162cd585`), y este parche deja **`2c8ef28a99`**.
- brave-core no tiene parches ni `chromium_src` para estos ficheros (`local/3.1.4-adapt` `e660929`).
- **Mojave:** `vnode-type` y `file-write-create` ya se usan en `common.sb` y `gpu.sb`, que funcionan en 10.14. `unless`
  es nuevo en nuestros `.sb` (`common.sb` usa `when`, su pareja). Nuestras *variations* son inertes, así que el
  interruptor no se puede encender a distancia: si algo fallara, solo se arregla con otra build.

### Veredicto (regla 17): **APTO**, `chromium/0001`

Riesgo: si el perfil no compilara en 10.14, el servicio de red no arrancaría y no habría red. Por eso la prueba en
Mojave es **obligatoria**:

0. **Antes de compilar**, en Terminal de la 6,1:
   `sandbox-exec -p '(version 1)(allow default)(unless #f (deny file-write-create (vnode-type SYMLINK)))' /bin/ln -s /tmp/a /tmp/sbx-test`
   debe fallar con «Operation not permitted»; con `(unless #t …)` y otro nombre, debe crear el enlace. Si da error de
   sintaxis, el perfil no compila en 10.14: avisar antes de compilar.
1. Arranque y red con el perfil ya existente: 3–4 webs y claude.ai (inicio de sesión y un chat en *streaming*). El
   «FlyWeb Helper (Network Service)» sigue vivo, sin reinicios.
2. Cerrar y reabrir: siguen la sesión de claude.ai y la de la sync, y HSTS (`Default/Network/`: Cookies,
   TransportSecurity, Network Persistent State).
3. Caché de disco: una web pesada dos veces. `~/Library/Caches/LaMosquita/FlyWeb/Default/Cache/Cache_Data` crece y la
   segunda carga sale «(disk cache)» en DevTools.
4. Descargas: un `.zip` y un `.dmg` grandes, con pausa y reanudación.
5. Perfil en volumen Samba (`--user-data-dir=/Volumes/<recurso>/flyweb-prueba`): navegar, iniciar sesión y reabrir.
   La regla impide **crear** enlaces simbólicos, no seguirlos: un perfil o una caché que ya sean enlace deben seguir
   funcionando.
6. Sync propia, actualización de componentes y comprobación de Sparkle.
7. Console.app durante 1–6, filtrando por «Sandbox» y por el Network Service. No debe haber «failed to compile». Cada
   «deny(1) file-write-create» es una ruta que intentó crear un enlace: se anota y se pasa a SEGURIDAD-PORTES.

Pruebas automáticas: `content_unittests --gtest_filter='*SandboxMac*'` y `sandbox_mac_unittests`.

## `brave-core/0001`: V8 d68cecd900 (bugs 583479274 y 587681789; V8 15.6.75.72)

Cuando el depurador escribe en una variable de contexto que el *parser* marcó `kNotAssigned`, el código optimizado
seguía tratándola como constante. Con el arreglo, el *isolate* anota que `kNotAssigned` ya no es fiable, desoptimiza
el código existente, y TurboFan (`bytecode-graph-builder.cc`, `js-heap-broker.cc`) y Maglev (`maglev-reducer-inl.h`)
dejan de plegar esas variables como constantes (`debug-scopes.cc`, `runtime-scopes.cc`, `isolate.{h,cc}`). Solo se
alcanza con el depurador conectado (DevTools o una extensión con `chrome.debugger`). Aplica a Mac (V8).

- Los siete ficheros de código son idénticos byte a byte en la 15.6.75.66 y en el padre del arreglo (`a97fec97ff`,
  .71), y ningún `patches/v8` de brave-core los toca: *cherry-pick* limpio. Cada fichero va como `patches/v8/*.patch`
  nuevo (formato de brave-core), más la prueba `test/inspector/debugger/context-set-unassigned-optimized{.js,-expected.txt}`.
- Comprobado: los nueve parches por fichero aplican sobre la .66 y `git apply --cached` del `.patch` de aquí sobre
  `local/3.1.4-adapt` `e660929` da el árbol **`90134a4e08`**. Los avisos de espacios al aplicar son las líneas de
  contexto de los diffs anidados (normal en `patches/`).
- **Época de caché:** no se sube aquí (todo parche de V8 la sube, `docs/SEGURIDAD.md`); la fija quien lo integre en
  la versión siguiente.
- **Gravedad: no consta** (bug restringido). Sin indicios de explotación.
- **Falta, antes de entrar:** d8/mjsunit con y sin Maglev y la suite `inspector` (D8-LINUX), en especial
  `debugger/context-set-unassigned-optimized`. **Sin eso en verde, no entra** (como los demás parches de V8).

### Veredicto (regla 17): **APTO** (condicionado a D8-LINUX en verde), `brave-core/0001`

Es el *cherry-pick* de upstream sin cambios. Efecto visible: con el depurador abierto, cambiar una variable de un
*closure* desde DevTools desoptimiza el código que la usaba (más lento solo mientras se depura; sin efecto fuera del
depurador).

## Dawn `6d772bc9e5c5..062164c3c784` (roll `ff774db0a2`): por revisar

`dawn.googlesource.com` está bloqueado desde la nube (como en la 3.1.2 y la 3.1.3): no se pueden leer los commits.
**Que LOCAL lo mire en su checkout** (`git log 6d772bc9e5c5..062164c3c784` en `third_party/dawn`) y diga si hay
arreglos de seguridad que toquen el backend Metal o el código común de Dawn; si los hay, van a `pendiente/dawn/`.
