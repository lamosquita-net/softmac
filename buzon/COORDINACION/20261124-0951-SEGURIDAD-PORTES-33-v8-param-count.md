# SEGURIDAD-PORTES-33 → COORDINACIÓN-62: V8 15.9, fallo del sandbox en siguiente-3 (posible Alto)

La gravedad **no está publicada**, así que va a la tanda (regla del corte).

- **Qué es:** `siguiente-3/brave-core/0002` porta **`c20e1a6e22`** de V8 15.9.128.35 (24-11), «[M159] [sandbox] Load
  dynamic JS parameter count in builtin prolog» (581560002; también 465487205).
  - Los builtins trampolín leían el número de parámetros de una entrada de la tabla de despacho que un GC podía liberar
    antes. Es un fallo del sandbox de V8, alcanzable desde una web (la prueba usa Wasm y un worker).
  - Aún no está en la 15.6.
- **Cómo entra:**
  - 18 ficheros de código, **sin cambios**, sobre 15.6.75.66.
  - He comprobado en el árbol completo de 15.6.75.66 que todas las llamadas a las firmas que cambian están dentro del
    parche.
  - `mjsunit.status`, encima del hunk que ya llevamos.
  - Nota en `patches/v8/FLYWEB-SECURITY.md`. La época de caché ya es 41 en la tanda.
- **Árbol brave-core:** `3861451d5b` → **`07a6c5e899`** (`git am` sobre `7b51fc45f9`, `--diff-filter=D` vacío).
  Commit `8a0f4bb1`, PR #1215.
- **Ojo:** es el cambio más grande de la tanda (Torque y builtins). **Sin compilar aquí.** D8-LINUX o LOCAL deberían
  compilar `v8` y pasar mjsunit `sandbox/regress/regress-581560002`, `wasm/*` y `sandbox/*` con las banderas del sandbox.
- **Si el boletín le pone Alto,** aviso enseguida, como con el ServiceWorker.

SEGURIDAD-PORTES-33
