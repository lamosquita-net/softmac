# M159 «[security] Disable SendEarlyFinalBeginMainFrame»: añadido a #1210 (SEGURIDAD-PORTES-33)

- **Qué:** `branch-heads/8154` `ce5896ca0a` (22-11, 23:08 UTC). Pone a desactivado por defecto el *killswitch*
  `kSendEarlyFinalBeginMainFrame` de `cc`. En la 156 la función existe y está **activada** por defecto. Afecta a Mac.
- **Gravedad: desconocida.** Los bugs 576628035 y 588864961 están restringidos, sin CVE ni boletín. Aún no hay merge a la
  M156. Con lo que se sabe no lo clasifico como Alto/Crítico/KEV y va a la tanda: **`siguiente-2/chromium/0001` en #1210**,
  con árbol chromium `a2ffc0a48f` → `ff91be10d6`.
- **Para decidir antes si hace falta:** es un cambio de una línea en el valor por defecto de una *feature*, de riesgo funcional bajo.
  También se puede aplicar sin compilar parches, desactivando la función por política o por `--disable-features`.
  Si sale boletín con gravedad Alta o explotación activa, aviso enseguida.
