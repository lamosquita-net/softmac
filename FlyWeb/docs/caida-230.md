# Caída del renderer en la 2.3.0 (nivel 134)

LOCAL-14, 28-10-2026 ~23:15. Build: brave-core `nube/motor-134` 858f858dc3, build 35, Release `symbol_level 0`, 7,1.

## Resumen

**`canvas.getContext('webgl')` y `getContext('webgl2')` tumban el renderer en cuanto se llaman.** Es un CHECK de
V8 13.4 en `v8::FunctionTemplate::NewWithCFunctionOverloads` al montar la plantilla de `WebGLRenderingContext`:
V8 13.4 exige que las variantes rápidas (Fast API, `[NoAllocDirectCall]`) de una misma operación tengan **distinto
número de argumentos**. Los IDL de WebGL de la base 128 declaran variantes con el mismo número de argumentos, una con
matriz tipada y otra con `sequence<>`: `uniform1fv`, `uniform2fv`, … (168 `[NoAllocDirectCall]` en
`modules/webgl/*.idl`).

```
v8/src/api/api.cc (13.4.114.21), NewWithCFunctionOverloads:
  // Check that all overloads of the fast API callback have different numbers of parameters.
  CHECK_NE(c_function_overloads.data()[i].ArgumentCount(), c_function_overloads.data()[j].ArgumentCount());
```

GitHub, YouTube y Wikipedia caen porque crean un contexto WebGL al cargar.

## Pila (lldb, `--single-process`, símbolos de `FlyWeb Framework.unstripped`)

`EXC_BREAKPOINT (EXC_I386_BPT)` en `Chrome_InProcRendererThread`, instrucción `ud2` (`0f 0b`) = `IMMEDIATE_CRASH` de un CHECK.

```
#0  v8::FunctionTemplate::NewWithCFunctionOverloads(...) +410        ← CHECK_NE
#1  blink::bindings::(anonymous)::InstallOperation(...) +236
#2  blink::V8WebGLRenderingContext::InstallInterfaceTemplate(...) +1124
#3  blink::WrapperTypeInfo::GetV8ClassTemplate(...) +229
#4  blink::V8ObjectConstructor::CreateInterfaceObject(...) +45
#5  blink::V8PerContextData::ConstructorForTypeSlowCase(...) +261
#6  blink::V8PerContextData::CreateWrapperFromCacheSlowCase(...) +95
#7  blink::V8DOMWrapper::CreateWrapper(...) +470
#8  blink::ScriptWrappable::Wrap(...) +36
#9  blink::v8_html_canvas_element::GetContextOperationCallback(...) +1088
#10 Builtins_CallApiCallbackGeneric +176
#11 Builtins_InterpreterEntryTrampoline +309
#12… JavaScript de la página (marcos del intérprete)
```

## Reproducción mínima

Página `webgl-l14.html?ctx=<tipo>` (crea `document.createElement('canvas').getContext(tipo)`), headless en la 7,1:

| Contexto | Resultado |
|---|---|
| `2d` | bien (`CanvasRenderingContext2D`) |
| `bitmaprenderer` | bien (`ImageBitmapRenderingContext`) |
| `webgl` | **cae** a los 0,9 s |
| `webgl2` | **cae** a los 0,9 s |

## Pruebas que lo descartan todo lo demás

GitHub en la 7,1, una carga por línea:

| Prueba | Resultado |
|---|---|
| sin nada | cae (3–4 s) |
| `--js-flags=--jitless` / `--no-turbofan` / `--no-sparkplug` | cae |
| `--js-flags=--no-reuse-scope-infos` | cae |
| `--js-flags=--single-threaded` | cae |
| `--js-flags=--single-threaded-gc` | cae |
| `--js-flags=--no-flush-bytecode` | cae |
| `--js-flags=--no-extensible-ro-snapshot` | cae |
| `--disable-blink-features=` HighlightInheritance / HTMLDialogLightDismiss / ExposeCSSFontFeatureValuesRule / CSSAdvancedAttrFunction | cae |
| `--no-sandbox` | cae (no es el sandbox; `log show` sin «deny») |
| `--blink-settings=scriptEnabled=false` | **no cae** |
| `--enable-logging=stderr --v=0 --vmodule=*bad_message*=1,*render_process_host*=1` | cae; ninguna línea de «bad message», mojo ni validación (no lo mata el navegador) |
| example.com con `--js-flags=--expose-gc` y 10 × (`append(div)`; `gc()`) | no cae |

## Arreglo propuesto (para MOTOR)

Portar lo que hizo Chromium al pasar a V8 13.4: quitar `[NoAllocDirectCall]` de las variantes de WebGL que comparten
número de argumentos (o dejar una sola variante rápida por operación) en `modules/webgl/*.idl`. No relajar el CHECK
de V8. Después, comprobar con `webgl-l14.html` (`webgl` y `webgl2`) y la prueba de humo: claude.ai, GitHub, YouTube
y Wikipedia en la 7,1 y la 6,1.

## Después del arreglo de WebGL (fa6ccf3c76): segunda caída, solo en Mojave

**7,1 (macOS 15):** humo de WebGL 15/15 bien (`webgl-humo-l14.html`, `webgl` y `webgl2`, `uniform*v` en sus dos
formas); claude.ai, GitHub, YouTube y Wikipedia cargan sin «Target crashed».

**6,1 (Mojave 10.14.6, FirePro D500), 29-10 00:41:** WebGL bien (`2d`, `webgl`, `webgl2` y humo con «hecho 0 fallos»,
un solo proceso GPU), pero **Wikipedia, YouTube, GitHub y claude.ai caen a los 1,5–4,6 s**; example.com (sin JS) no.
Cae igual con `--js-flags=--jitless` (no es el JIT ni AVX2); con `--no-maglev` cae GitHub.

Volcados de Crashpad de la 6,1 (`~/Library/Application Support/LaMosquita/FlyWeb/Crashpad/pending`), leídos en la 7,1:
`EXC_CRASH` de `EXC_BAD_INSTRUCTION`/SIGILL, rip en `_sigtramp` de libsystem_platform, hilos de V8 (Scavenger,
BackgroundCompileTask) y el mensaje de libplatform en el volcado:

```
BUG IN CLIENT OF LIBPLATFORM: Invalid options
```

**Causa:** `v8/src/base/platform/mutex.cc` de V8 13.4 (4fad600bd5 «[mutex] Readd adaptive spin», dic. 2024) bloquea
`SpinningMutex` con `os_unfair_lock_lock_with_options(…, OS_UNFAIR_LOCK_DATA_SYNCHRONIZATION | OS_UNFAIR_LOCK_ADAPTIVE_SPIN)`
si el símbolo débil existe. En 10.14 existe, pero `OS_UNFAIR_LOCK_ADAPTIVE_SPIN` es de 10.15: libplatform lo rechaza
con una trampa. Chromium 134 ya no admite 10.14/10.15, por eso no lo protege. En la 7,1 no se ve.

**Arreglo (LOCAL-14, brave-core `local/2.3.0-mojave` 479bcaf1e2 = fa6ccf3c76 + un parche):**
`patches/v8/src-base-platform-mutex.cc.patch`: antes de macOS 10.15 (`__builtin_available`), `os_unfair_lock_lock`
sin opciones. Para MOTOR: llevarlo a `nube/motor-134` y revisar en cada V8 nuevo cualquier API o opción de 10.15+
que solo se compruebe con un símbolo débil.

**Comprobación en la 6,1 (29-10 10:11, guion `probar-230.command`, DMG 479bcaf1e2): VERDE.** WebGL y base64 de 1 a 8 MB
«hecho 0 fallos»; example.com, Wikipedia, YouTube, GitHub y claude.ai cargan sin volcados de Crashpad; d8 13.4.114.21
mjsunit 2195/2227, igual que la 7,1, sin SIGILL. Falta la 5,1 con el mismo guion.
