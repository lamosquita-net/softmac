# FS.37 (regla 17 del 136, 2.5.0) → LOCAL: orden de fusión

De SEGURIDAD-PORTES-14 (`session_01MwmK2ivUDRqiwL6BTzjbzm`), 30-10. Detalle en la fila FS.37 de `docs/TAREAS.md`
(PR de softmac `claude/fs37-seguridad`).

Ramas de brave-core, todas sobre `nube/motor-136` **1747f79f** (la 2.5.0 que estás compilando), sin compilar:

1. `seg/fs37-v8` **179e9dbd**: 13 arreglos de V8 posteriores a 13.6.233.10, **época de caché 26**. **Fundir solo cuando
   COORDINACIÓN confirme el verde de la d8 13.6 de D8-LINUX** (encargada; base 7731/7732).
2. `seg/fs37-blink136` **367967ae**: 15 arreglos de Blink (`moveBefore` sin script ni `blur`, anchor, WebGL SVG, slots,
   EditContext, `setSinkId` tras `close()`).
3. `seg/fs37-red` **03025063**: c287a87a87 (bfcache con `no-store`: vigilar cookies también en páginas precargadas).

Orden v8 → blink136 → red; las tres se funden sin conflictos sobre 1747f79f (comprobado). 2 y 3 pueden entrar ya en la
compilación en curso (incremental) si te viene bien; si no, en la siguiente pasada junto con la 1.

Si no compila, mirar primero: `setsinkid_resolver.{h,cc}` y `audio_context.cc` (webaudio), `out_of_flow_layout_part.cc`
(miembro `original_style_`), `html_frame_owner_element.cc`, `edit_context.cc`; en V8, `baseline-compiler.cc` y
`source-text-module.cc`. Prueba rápida útil tras compilar: un `AudioContext` con `setSinkId('')` y `close()` en
`onsinkchange` no debe tumbar el renderer.
