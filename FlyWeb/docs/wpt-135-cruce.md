# Cruce wpt.fyi Chrome 134 vs 135 contra inv135-blink.md

Runs (Linux, wpt.fyi): 134 = id 5078304292077568, 134.0.6998.165 (1-4-2025, wpt 83852c0f8d); 135 = id 5142546559008768, 135.0.7049.114 (29-4-2025, wpt 1d1ca6bbce). Revisiones de WPT distintas: tests nuevos/cambiados dan falsos positivos (marcados d).
Criterio: aciertos(135) > aciertos(134) por contadores del summary_v2, o estado de prueba única no-PASS/OK a OK. Directorios: css, html, dom, editing, navigation-api, fetch/fetch-later, observable, wai-aria, accname, core-aam, html-aam.

Clases: a = fila del inventario a portar; b = aplazada/fuera; c = falta, con commit; c? = falta/sin causa localizada; d = entorno/test cambiado/ya en 134.

Totales: a=330, b=5, c=68, c?=28, d=27  (n=458)

| prueba | subpruebas pass 134>135 | clase | fila inventario / commit / flag | V/S |
|---|---|---|---|---|
| css/CSS2/floats/floats-placement-vertical-001b.xht | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/CSS2/generated-content/before-after-table-whitespace-001.xht | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/CSS2/linebox/animations/line-height-interpolation.html | 570/570>616/628 | d | test WPT cambiado entre las dos revisiones (totales distintos) | S |
| css/css-anchor-position/anchor-invalid-fallback.html | 36/36>39/39 | d | test WPT cambiado entre las dos revisiones (totales distintos) | S |
| css/css-anchor-position/anchor-scroll-position-try-001.html | 5/6>6/6 | a | fila CSSAnchorRememberedScrollOffset (3b7bcf05af, b8a2fd50e3); posible extra 88e081e06af (punto de recalculo al cambiar fallback) | S |
| css/css-anchor-position/anchor-scroll-position-try-006.html | 4/6>6/6 | a | fila CSSAnchorRememberedScrollOffset (3b7bcf05af, b8a2fd50e3); posible extra 88e081e06af (punto de recalculo al cambiar fallback) | S |
| css/css-anchor-position/anchor-scroll-position-try-007.html | 4/5>5/5 | a | fila CSSAnchorRememberedScrollOffset (3b7bcf05af, b8a2fd50e3); posible extra 88e081e06af (punto de recalculo al cambiar fallback) | S |
| css/css-anchor-position/anchor-transition-004.html | 0/1>1/1 | a | fila CSSAnchorRememberedScrollOffset (3b7bcf05af, b8a2fd50e3); posible extra 88e081e06af (punto de recalculo al cambiar fallback) | S |
| css/css-anchor-position/position-area-scrolling-001.tentative.html | 4/6>6/6 | a | fila CSSAnchorRememberedScrollOffset (3b7bcf05af, b8a2fd50e3); posible extra 88e081e06af (punto de recalculo al cambiar fallback) | S |
| css/css-anchor-position/position-area-scrolling-002.tentative.html | 4/6>6/6 | a | fila CSSAnchorRememberedScrollOffset (3b7bcf05af, b8a2fd50e3); posible extra 88e081e06af (punto de recalculo al cambiar fallback) | S |
| css/css-anchor-position/position-area-scrolling-003.tentative.html | 4/6>6/6 | a | fila CSSAnchorRememberedScrollOffset (3b7bcf05af, b8a2fd50e3); posible extra 88e081e06af (punto de recalculo al cambiar fallback) | S |
| css/css-anchor-position/position-area-scrolling-005.html | 3/11>11/11 | a | fila CSSAnchorRememberedScrollOffset (3b7bcf05af, b8a2fd50e3); posible extra 88e081e06af (punto de recalculo al cambiar fallback) | S |
| css/css-anchor-position/position-area-scrolling-006.html | 1/5>5/5 | a | fila CSSAnchorRememberedScrollOffset (3b7bcf05af, b8a2fd50e3); posible extra 88e081e06af (punto de recalculo al cambiar fallback) | S |
| css/css-anchor-position/position-area-scrolling-007.html | 1/7>3/7 | a | fila CSSAnchorRememberedScrollOffset (3b7bcf05af, b8a2fd50e3); posible extra 88e081e06af (punto de recalculo al cambiar fallback) | S |
| css/css-anchor-position/position-try-fallbacks-003.html | 6/8>8/8 | a | fila CSSAnchorRememberedScrollOffset (3b7bcf05af, b8a2fd50e3); posible extra 88e081e06af (punto de recalculo al cambiar fallback) | S |
| css/css-animations/idlharness.html | 94/97>95/98 | d | test WPT cambiado entre las dos revisiones (totales distintos) | S |
| css/css-animations/parsing/animation-trigger-exit-range-end-invalid.html | 12/12>13/13 | b | AnimationTrigger (fila "no entran"); test cambiado | V |
| css/css-animations/parsing/animation-trigger-exit-range-start-invalid.html | 9/9>10/10 | b | AnimationTrigger (fila "no entran"); test cambiado | V |
| css/css-borders/tentative/parsing/corner-shape-invalid.html | 13/13>15/15 | b | CSSCornerShape (fila "no entran") | V |
| css/css-cascade/all-prop-initial-xml.html | 390/390>394/394 | a | fila CSSInert (66c0b303f4) + ae21fa404d | S |
| css/css-cascade/all-prop-revert-layer.html | 335/336>337/338 | a | fila CSSInert (66c0b303f4) + ae21fa404d | S |
| css/css-color/color-mix-missing-components.html | 0/1>1/1 | c | d3d0ae5bf4d (carry-forward de componentes faltantes en color-mix, Bug 387132019; color.cc +176) | S |
| css/css-conditional/container-queries/scroll-state/scroll-state-scrollable-layout-change-002.html | 1/2>2/2 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-content/quotes-025.html | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-content/quotes-027.html | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-easing/linear-timing-functions-syntax.html | 22/34>23/35 | d | test WPT cambiado entre las dos revisiones (totales distintos) | S |
| css/css-easing/step-timing-functions-syntax.html | 12/14>13/15 | d | test WPT cambiado entre las dos revisiones (totales distintos) | S |
| css/css-font-loading/idlharness.https.html | 74/142>75/143 | d | test WPT cambiado entre las dos revisiones (totales distintos) | S |
| css/css-fonts/font-variation-settings-calc.html | 0/4>1/8 | d | test WPT cambiado entre las dos revisiones (totales distintos) | S |
| css/css-fonts/parsing/font-palette-values-invalid.html | 26/26>27/27 | d | test WPT cambiado entre las dos revisiones (totales distintos) | S |
| css/css-fonts/test_font_feature_values_parsing.html | 263/300>265/302 | d | test WPT cambiado entre las dos revisiones (totales distintos) | S |
| css/css-highlight-api/painting/custom-highlight-painting-text-shadow-invalidation.html | 0/0>0/0 | c | 7dafeb6822f (text-shadow en Custom Highlights, 25-2-2025; highlight_style_utils.cc 10 líneas) | S |
| css/css-highlight-api/painting/custom-highlight-painting-text-shadow.html | 0/0>0/0 | c | 7dafeb6822f (text-shadow en Custom Highlights, 25-2-2025; highlight_style_utils.cc 10 líneas) | S |
| css/css-images/conic-gradient-angle-negative.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/conic-gradient-angle.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/conic-gradient-center.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/color-stops-parsing.html | 150/162>162/162 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-analogous-missing-components-002.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-longer-hue-hsl-002.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-longer-hue-hsl-003.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-longer-hue-hsl-006.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-longer-hue-hsl-008.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-longer-hue-hsl-009.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-longer-hue-hsl-010.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-longer-hue-hsl-011.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-longer-hue-hsl-012.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-longer-hue-lch-002.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-longer-hue-lch-003.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-longer-hue-lch-006.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-longer-hue-lch-008.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-longer-hue-lch-009.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-longer-hue-lch-010.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-longer-hue-lch-011.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-longer-hue-lch-012.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-single-stop-001.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-single-stop-002.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-single-stop-003.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-single-stop-004.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-single-stop-005.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-single-stop-006.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-single-stop-007.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-single-stop-008.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-single-stop-longer-hue-hsl-002.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-single-stop-longer-hue-hsl.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/gradient-single-stop-longer-hue-oklch.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/gradient/linear-gradient-relative-currentcolor-stop.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/image-set/image-set-parsing.html | 134/136>136/142 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/multiple-position-color-stop-conic.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/normalization-conic-2.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/normalization-conic-degenerate.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/normalization-conic.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/object-view-box-fit-fill-video.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/out-of-range-color-stop-conic.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-images/tiled-conic-gradients.html | 0/0>0/0 | c | de30a22358e (gradiente con 1 solo stop, css-images-3/4, Bug 344620213) + ae4b6e17166, c61a6575eb5 (crash/serialización) + 7523f80eaa6 (hue longer fuera de los stops, Bug 387475844); sin flag; gradient_value.cc +gradient.cc +paint_shader.cc | S |
| css/css-inline/text-box-trim/new-fc-001.html | 0/0>0/0 | c | 6078e755853 (text-box-trim en hijos new-BFC; block_layout_algorithm.cc) | S |
| css/css-inline/text-box-trim/text-box-trim-multicol-013.html | 0/5>5/5 | c | 80505a9e751 (text-box-trim en spanners de columnas; column_layout_algorithm.cc) | S |
| css/css-lists/nested-marker-styling.html | 0/0>0/0 | a | CSSMarkerNestedPseudoElement (20c4cc86a4) | S |
| css/css-masking/animations/clip-path-interpolation-shape-control-points.tentative.html | 0/306>306/306 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/animations/clip-path-interpolation-shape.html | 0/668>668/668 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/animations/clip-path-shape-interpolation-001.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/animations/clip-path-shape-interpolation-002.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/animations/clip-path-shape-interpolation-003.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/animations/clip-path-shape-interpolation-004.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/clip-path-shape-001.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/clip-path-shape-002-units.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/clip-path-shape-002.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/clip-path-shape-003.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/clip-path-shape-004.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/clip-path-shape-005.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/clip-path-shape-006.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/clip-path-shape-007.tentative.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/clip-path-shape-008.tentative.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/clip-path-shape-009.tentative.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/clip-path-shape-010.tentative.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/clip-path-shape-hline-vline-keywords.tentative.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/clip-path/clip-path-shape-winding.html | 0/0>0/0 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-masking/parsing/clip-path-shape-parsing.html | 20/40>40/40 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-multicol/column-pseudo-background-color.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-multicol/parsing/column-pseudo-computed.html | 0/4>3/4 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-multicol/parsing/column-pseudo-valid.html | 0/4>2/4 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-creates-computed-style.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-001.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-002.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-003.html | 3/8>8/8 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-004.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-005.html | 3/8>8/8 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-006.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-007.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-008.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-010.html | 1/9>9/9 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-011.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-012.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-013.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-014.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-counters.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-dynamic-style-update.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-focus-004.html | 0/11>1/11 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-scroll-marker-reattach-target-current.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-style-change-triggers-relayout.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/column-updates-computed-style.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/inheritance.html | 8/18>12/18 | a | fila CSSLogicalOverflow (2d63b38fdf) | S |
| css/css-overflow/line-clamp/line-clamp-auto-010.tentative.html | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-overflow/logical-overflow-001.html | 0/2>2/2 | a | fila CSSLogicalOverflow (2d63b38fdf) | S |
| css/css-overflow/overflow-shorthand-002.html | 0/2>2/2 | a | fila CSSLogicalOverflow (2d63b38fdf) | S |
| css/css-overflow/parsing/overflow-computed.html | 29/34>34/34 | a | fila CSSLogicalOverflow (2d63b38fdf) | S |
| css/css-overflow/parsing/overflow-valid.html | 14/18>18/18 | a | fila CSSLogicalOverflow (2d63b38fdf) | S |
| css/css-overflow/parsing/scroll-buttons-valid.html | 0/37>37/37 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/parsing/scroll-markers-computed.html | 0/9>9/9 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/parsing/scroll-markers-valid.html | 0/7>7/7 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-button-activation-content-hit-test.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-button-hover-remove.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-button-hover.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-buttons-001.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-buttons-002.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-buttons-003.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-buttons-004.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-buttons-activation-with-columns.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-buttons-activation.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-buttons-appearance.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-buttons-disabled-rtl.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-buttons-disabled-snapping.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-buttons-disabled-vertical-ltr.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-buttons-disabled.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-buttons-enabled-rtl.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-buttons-enabled-vertical-ltr.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-buttons-enabled.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-buttons-layout-parent.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-buttons-scroll-distance.html | 0/2>2/2 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-001.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-002.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-003.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-004.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-005.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-006.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-007.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-008.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-009.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-010.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-011.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-012.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-013.html | 0/2>2/2 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-15.html | 0/2>2/2 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-activation-retains-focus.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-activation-scroll.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-controls-scroll-tracking-001.html | 0/2>2/2 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-controls-scroll-tracking-002.html | 0/2>2/2 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-controls-scroll-tracking-003.html | 0/2>2/2 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-counters.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-dynamic.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-focus-visible.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-focus-within.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-001.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-002.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-003.html | 0/5>5/5 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-005.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-007.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-008.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-009.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-011.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-012.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-013.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-014.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-015.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-016.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-017.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-018.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-019.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-020.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-add-dynamic-001.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-add-dynamic-002.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-add-dynamic-003.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-add-dynamic-004.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-keeps-active-in-view.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-layout-parent.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-group-snap-aligns-to-active.tentative.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-hover-logical.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-hover-remove.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-hover.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-navigation-cycles.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-next-focus.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-selection-in-2d.html | 0/0>0/0 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-selection-in-padded-scroller.html | 0/2>2/2 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-marker-selection-picks-closest.html | 0/7>7/7 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-markers-focus-active-element.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-markers-focus-on-scrolling.html | 0/2>2/2 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/scroll-markers-updated-by-programmatic-scroll.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/target-current-scroll-marker-update.html | 0/1>1/1 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/targeted-scroll-marker-selection-with-transition.tentative.html | 0/2>2/2 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-overflow/targeted-scroll-marker-selection.tentative.html | 0/4>4/4 | a | fila 1 carousel (CSSPseudoScrollMarkers/Buttons/Column; flip 27a528fe68) | S |
| css/css-page/margin-boxes/background-001-print.html | 0/0>0/0 | b | PageMarginBoxes (escapes: sin cambios) | S |
| css/css-pseudo/highlight-cascade/highlight-currentcolor-painting-text-shadow-001.html | 0/0>0/0 | c | 7dafeb6822f (text-shadow en Custom Highlights, 25-2-2025; highlight_style_utils.cc 10 líneas) | S |
| css/css-pseudo/highlight-cascade/highlight-currentcolor-painting-text-shadow-002.html | 0/0>0/0 | c | 7dafeb6822f (text-shadow en Custom Highlights, 25-2-2025; highlight_style_utils.cc 10 líneas) | S |
| css/css-pseudo/highlight-styling-003.html | 0/0>0/0 | c | 7dafeb6822f (text-shadow en Custom Highlights, 25-2-2025; highlight_style_utils.cc 10 líneas) | S |
| css/css-pseudo/highlight-styling-004.html | 0/0>0/0 | c | 7dafeb6822f (text-shadow en Custom Highlights, 25-2-2025; highlight_style_utils.cc 10 líneas) | S |
| css/css-pseudo/highlight-styling-005.html | 0/0>0/0 | c | 7dafeb6822f (text-shadow en Custom Highlights, 25-2-2025; highlight_style_utils.cc 10 líneas) | S |
| css/css-pseudo/parsing/tree-abiding-pseudo-elements.html | 39/41>41/41 | a | carousel + CSSNestedPseudoElements (20c4cc86a4) | S |
| css/css-pseudo/selection-contenteditable-011.html | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-ruby/block-ruby-003.html | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-scoping/svg-id-ref-001.html | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-scroll-snap/snap-after-initial-layout/initial-snap-matches-scroll.html | 0/1>1/1 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-shapes/shape-functions/shape-function-computed.tentative.html | 0/31>31/31 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-shapes/shape-functions/shape-function-valid.tentative.html | 0/51>51/51 | a | fila CSSShapeFunction (5646d3a9a1) | V |
| css/css-syntax/serialize-consecutive-tokens.html | 68/68>69/71 | d | test WPT cambiado entre las dos revisiones (totales distintos) | S |
| css/css-text-decor/text-emphasis-position-property-002.html | 0/0>0/0 | c | f64b0a258a3 (text-emphasis-position: auto, 2-3-2025; css_properties.json5 + painters) | S |
| css/css-text-decor/text-emphasis-position-property-002a.html | 0/0>0/0 | c | f64b0a258a3 (text-emphasis-position: auto, 2-3-2025; css_properties.json5 + painters) | S |
| css/css-text-decor/text-emphasis-position-property-002b.html | 0/0>0/0 | c | f64b0a258a3 (text-emphasis-position: auto, 2-3-2025; css_properties.json5 + painters) | S |
| css/css-text-decor/text-emphasis-position-property-002c.html | 0/0>0/0 | c | f64b0a258a3 (text-emphasis-position: auto, 2-3-2025; css_properties.json5 + painters) | S |
| css/css-text-decor/text-emphasis-position-property-006.html | 0/0>0/0 | c | f64b0a258a3 (text-emphasis-position: auto, 2-3-2025; css_properties.json5 + painters) | S |
| css/css-text-decor/text-emphasis-position-property-006a.html | 0/0>0/0 | c | f64b0a258a3 (text-emphasis-position: auto, 2-3-2025; css_properties.json5 + painters) | S |
| css/css-text-decor/text-emphasis-position-property-006b.html | 0/0>0/0 | c | f64b0a258a3 (text-emphasis-position: auto, 2-3-2025; css_properties.json5 + painters) | S |
| css/css-text-decor/text-emphasis-position-property-006c.html | 0/0>0/0 | c | f64b0a258a3 (text-emphasis-position: auto, 2-3-2025; css_properties.json5 + painters) | S |
| css/css-text-decor/text-emphasis-position-property-006d.html | 0/0>0/0 | c | f64b0a258a3 (text-emphasis-position: auto, 2-3-2025; css_properties.json5 + painters) | S |
| css/css-text-decor/text-emphasis-position-property-006e.html | 0/0>0/0 | c | f64b0a258a3 (text-emphasis-position: auto, 2-3-2025; css_properties.json5 + painters) | S |
| css/css-text-decor/text-emphasis-position-property-006f.html | 0/0>0/0 | c | f64b0a258a3 (text-emphasis-position: auto, 2-3-2025; css_properties.json5 + painters) | S |
| css/css-text-decor/text-emphasis-position-property-006g.html | 0/0>0/0 | c | f64b0a258a3 (text-emphasis-position: auto, 2-3-2025; css_properties.json5 + painters) | S |
| css/css-text/white-space/trailing-ideographic-space-break-spaces-002.html | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-text/white-space/trailing-ideographic-space-break-spaces-004.html | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-transitions/after-change-style-inherited-try-fallback.html | 0/1>1/1 | a | CascadedAfterChangeStyle (208c850572) | S |
| css/css-transitions/after-change-style-inherited.html | 1/6>6/6 | a | CascadedAfterChangeStyle (208c850572) | S |
| css/css-transitions/idlharness.html | 63/63>64/64 | d | test WPT cambiado entre las dos revisiones (totales distintos) | S |
| css/css-transitions/starting-style-cascade.html | 4/6>6/6 | a | CascadedAfterChangeStyle (208c850572) | S |
| css/css-typed-om/stylevalue-objects/parseAll-invalid.html | 5/5>6/6 | a | fila CSSInert (66c0b303f4) + ae21fa404d | S |
| css/css-ui/interactivity-inert-click-002.html | 0/1>1/1 | a | fila CSSInert (66c0b303f4) + ae21fa404d | S |
| css/css-ui/interactivity-inert-click.html | 1/2>2/2 | a | fila CSSInert (66c0b303f4) + ae21fa404d | S |
| css/css-ui/interactivity-inert-find.html | 2/3>3/3 | a | fila CSSInert (66c0b303f4) + ae21fa404d | S |
| css/css-ui/interactivity-inert-focus.html | 2/3>3/3 | a | fila CSSInert (66c0b303f4) + ae21fa404d | S |
| css/css-ui/interactivity-inert-fullscreen-ua.html | 0/5>5/5 | a | fila CSSInert (66c0b303f4) + ae21fa404d | S |
| css/css-ui/interactivity-inert-html-attribute-ua.html | 0/4>4/4 | a | fila CSSInert (66c0b303f4) + ae21fa404d | S |
| css/css-ui/interactivity-inert-modal-dialog-ua.html | 0/5>5/5 | a | fila CSSInert (66c0b303f4) + ae21fa404d | S |
| css/css-ui/parsing/interactivity-computed.html | 0/46>46/46 | a | fila CSSInert (66c0b303f4) + ae21fa404d | S |
| css/css-ui/parsing/interactivity.html | 3/9>9/9 | a | fila CSSInert (66c0b303f4) + ae21fa404d | S |
| css/css-values/animations/scale-interpolation-crash.html | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-values/attr-all-types.html | 135/139>136/139 | a | §4 b93ddf3764 (attr() fallback vacío) | S |
| css/css-values/calc-infinity-nan-computed.html | 43/45>45/45 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-values/minmax-length-serialize.html | 22/22>23/24 | d | test WPT cambiado entre las dos revisiones (totales distintos) | S |
| css/css-values/random-invalid.tentative.html | 18/18>25/25 | d | test WPT cambiado entre las dos revisiones (totales distintos) | S |
| css/css-view-transitions/event-pseudo-name.html | 0/1>1/1 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-view-transitions/fractional-translation-from-transform.html | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-view-transitions/input-targets-root-while-render-blocked.html | 0/1>1/1 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-view-transitions/navigation/at-rule-opt-in-auto.html | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-view-transitions/navigation/with-types/at-rule-opt-in-auto-with-types-no-cascade.html | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-viewport/zoom/scroll-top-test-with-zoom.html | 1/2>2/2 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-writing-modes/available-size-020.html | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/css-writing-modes/available-size-021.html | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| css/cssom-view/idlharness.html | 354/412>355/413 | d | test WPT cambiado entre las dos revisiones (totales distintos) | S |
| css/filter-effects/svg-feimage-005.html | 0/0>0/0 | c | 8692b015aaf (preserveAspectRatio en feImage, Fixed 397258346) | S |
| css/selectors/caret-color-visited-inheritance.html | 0/0>0/0 | c | b39d6582c8e (herencia de todos los estilos :visited, 19-2-2025; privacidad: regla 17) | S |
| css/selectors/text-emphasis-visited-inheritance.html | 0/0>0/0 | c | b39d6582c8e (herencia de todos los estilos :visited, 19-2-2025; privacidad: regla 17) | S |
| css/selectors/text-fill-color-visited-inheritance.html | 0/0>0/0 | c | b39d6582c8e (herencia de todos los estilos :visited, 19-2-2025; privacidad: regla 17) | S |
| dom/idlharness.any.serviceworker.html | 217/217>219/219 | a | ObservableAPI (EventTarget.when) o AOM; S | S |
| dom/idlharness.any.sharedworker.html | 217/217>219/219 | a | ObservableAPI (EventTarget.when) o AOM; S | S |
| dom/idlharness.any.worker.html | 217/217>219/219 | a | ObservableAPI (EventTarget.when) o AOM; S | S |
| dom/nodes/MutationObserver-textContent.html | 2/4>4/4 | a | SameValueTextContentFiresMutationObservers (9be8c38c3b) | V |
| dom/observable/tentative/idlharness.html | 2/36>36/36 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-catch.any.html | 0/9>9/9 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-catch.any.worker.html | 0/9>9/9 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-constructor.any.html | 0/43>43/43 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-constructor.any.worker.html | 0/43>43/43 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-constructor.window.html | 0/4>4/4 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-drop.any.html | 0/7>7/7 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-drop.any.worker.html | 0/7>7/7 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-event-target.any.html | 0/3>3/3 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-event-target.any.worker.html | 0/3>3/3 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-event-target.window.html | 0/2>2/2 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-every.any.html | 0/10>10/10 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-every.any.worker.html | 0/10>10/10 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-filter.any.html | 0/6>6/6 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-filter.any.worker.html | 0/6>6/6 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-finally.any.html | 0/10>10/10 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-finally.any.worker.html | 0/10>10/10 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-find.any.html | 0/6>6/6 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-find.any.worker.html | 0/6>6/6 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-first.any.html | 0/5>5/5 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-first.any.worker.html | 0/5>5/5 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-flatMap.any.html | 0/7>7/7 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-flatMap.any.worker.html | 0/7>7/7 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-forEach.any.html | 0/6>6/6 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-forEach.any.worker.html | 0/6>6/6 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-forEach.window.html | 0/2>2/2 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-from.any.html | 0/47>45/48 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-from.any.worker.html | 0/47>45/48 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-inspect.any.html | 0/13>13/13 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-inspect.any.worker.html | 0/13>13/13 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-last.any.html | 0/5>5/5 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-last.any.worker.html | 0/5>5/5 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-map.any.html | 0/6>6/6 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-map.any.worker.html | 0/6>6/6 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-map.window.html | 0/1>1/1 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-reduce.any.html | 0/8>8/8 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-reduce.any.worker.html | 0/8>8/8 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-some.any.html | 0/7>7/7 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-some.any.worker.html | 0/7>7/7 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-switchMap.any.html | 0/6>6/6 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-switchMap.any.worker.html | 0/6>6/6 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-take.any.html | 0/6>6/6 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-take.any.worker.html | 0/6>6/6 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-takeUntil.any.html | 0/12>12/12 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-takeUntil.any.worker.html | 0/12>12/12 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-takeUntil.window.html | 0/2>2/2 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-toArray.any.html | 0/6>6/6 | a | fila ObservableAPI (10a2f47aff) | V |
| dom/observable/tentative/observable-toArray.any.worker.html | 0/6>6/6 | a | fila ObservableAPI (10a2f47aff) | V |
| editing/other/copy-elements-with-css-vars.tentative.html | 1/2>2/2 | a | ResolveVarStylesOnCopy (49ca6f6089) | V |
| editing/other/plain-text-copy-paste-of-paragraph-ending-with-non-layed-out-content.html | 7/9>9/9 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| editing/run/indent.html | 1250/1321>1252/1321 | a | AdjustStartOfParagraphToMoveDuringIndent (528bccdc9f) | V |
| html/browsers/history/the-location-interface/location_hash_set_empty_string.html | 0/1>1/1 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| html/canvas/offscreen/manual/text/canvas.2d.offscreen.worker.direction.inherit.html | 0/0>0/0 | d | test manual; arreglo ba17fa15dea (22-1) ya está en el 134 | S |
| html/cross-origin-opener-policy/iframe-popup-same-origin-allow-popups-to-same-origin-allow-popups.https.html?3-4 | 0/0>6/6 | d | entorno/flaky (harness, media, COOP) | S |
| html/cross-origin-opener-policy/iframe-popup-same-origin-allow-popups-to-same-origin-allow-popups.https.html?9-last | 0/0>3/3 | d | entorno/flaky (harness, media, COOP) | S |
| html/cross-origin-opener-policy/iframe-popup-same-origin-allow-popups-to-same-origin.https.html?5-6 | 0/0>6/6 | d | entorno/flaky (harness, media, COOP) | S |
| html/cross-origin-opener-policy/iframe-popup-same-origin-to-same-origin.https.html?5-6 | 0/0>6/6 | d | entorno/flaky (harness, media, COOP) | S |
| html/dom/aria-element-reflection-disconnected.html | 0/2>2/2 | a | AOMAriaRelationshipProperties (163f516c9a) + HTMLCommandAttributes (CommandEvent/oncommand) | S |
| html/dom/aria-element-reflection-labelledby.html | 0/4>4/4 | a | AOMAriaRelationshipProperties (163f516c9a) + HTMLCommandAttributes (CommandEvent/oncommand) | S |
| html/dom/aria-element-reflection.html | 5/27>26/27 | a | AOMAriaRelationshipProperties (163f516c9a) + HTMLCommandAttributes (CommandEvent/oncommand) | S |
| html/dom/idlharness.https.html?exclude=(Document|Window|HTML.+) | 1540/1634>1550/1637 | a | AOMAriaRelationshipProperties (163f516c9a) + HTMLCommandAttributes (CommandEvent/oncommand) | S |
| html/dom/idlharness.https.html?include=(Document|Window) | 1041/1055>1047/1055 | a | AOMAriaRelationshipProperties (163f516c9a) + HTMLCommandAttributes (CommandEvent/oncommand) | S |
| html/dom/idlharness.https.html?include=HTML.+ | 3890/3975>3896/3977 | a | AOMAriaRelationshipProperties (163f516c9a) + HTMLCommandAttributes (CommandEvent/oncommand) | S |
| html/editing/the-hidden-attribute/beforematch-element-fragment-navigation.html | 9/9>10/10 | d | test WPT cambiado entre las dos revisiones (totales distintos) | S |
| html/infrastructure/common-dom-interfaces/collections/htmloptionscollection.html | 22/24>23/24 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/infrastructure/safe-passing-of-structured-data/shared-array-buffers/window-simple-success.https.html | 15/16>16/16 | d | entorno/flaky (harness, media, COOP) | S |
| html/rendering/non-replaced-elements/lists/lists-styles-quirks.html | 1795/2070>1941/2070 | a | CorrectStylesForLists (923e985590) | S |
| html/rendering/non-replaced-elements/lists/lists-styles.html | 1809/2070>1955/2070 | a | CorrectStylesForLists (923e985590) | S |
| html/rendering/non-replaced-elements/phrasing-content-0/b-strong-styles.html | 0/0>0/0 | a | StrongBolder (0f34660cbc) | V |
| html/rendering/replaced-elements/images/revoked-blob-print.html | 0/0>0/0 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| html/rendering/replaced-elements/the-option-element/option-label-whitespace.html | 0/0>0/0 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/embedded-content/bfcache/embedded-mp4.html | 1/2>2/2 | d | entorno/flaky (harness, media, COOP) | S |
| html/semantics/embedded-content/the-video-element/resize-during-playback.html | 1/2>2/2 | d | entorno/flaky (harness, media, COOP) | S |
| html/semantics/forms/the-input-element/radio-input-cancel.html | 1/1>2/2 | a | RadioInputNextButtonInScope (1130886598) | S |
| html/semantics/forms/the-input-element/radio-keyboard-navigation-order.html | 0/1>1/1 | a | RadioInputNextButtonInScope (1130886598) | S |
| html/semantics/forms/the-select-element/customizable-select/border-rendering.tentative.html | 0/0>0/0 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/button-in-popover.tentative.html | 0/2>2/2 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/closed-listbox-rendering.tentative.html | 0/0>0/0 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/focus-ring-rendering.tentative.html | 0/0>0/0 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/option-list.tentative.html | 0/1>1/1 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-accessibility-minimum-target-size.tentative.html | 0/6>6/6 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-appearance-button-after-option.tentative.html | 0/0>0/0 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-appearance-button-after-span.tentative.html | 0/0>0/0 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-appearance-button-after-text.tentative.html | 0/0>0/0 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-appearance-fallback-bottom-left-scroller.tentative.html | 0/0>0/0 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-appearance-fallback-bottom-right-scroller.tentative.html | 0/0>0/0 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-appearance-fallback-top-left-scroller.tentative.html | 0/0>0/0 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-appearance-fallback-top-left.tentative.html | 0/0>0/0 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-appearance-fallback-top-right-scroller.tentative.html | 0/0>0/0 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-appearance-fallback-top-right.tentative.html | 0/0>0/0 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-button-behaviors.tentative.html | 1/2>2/2 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-click-drag-option.tentative.html | 0/2>2/2 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-dialog-mode-focus.tentative.html | 0/2>2/2 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-disabled.tentative.html | 0/2>2/2 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-events-2.tentative.html | 4/7>7/7 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-events.tentative.html | 0/2>2/2 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-explicit-size.tentative.html | 0/0>0/0 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-fallback-datalist-animations.tentative.html | 0/1>1/1 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-focus-visible-with-mouse.tentative.html | 0/1>1/1 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-home-end-pagedown-pageup-detailed.optional.html | 0/4>4/4 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-home-end-pagedown-pageup.tentative.html | 0/4>4/4 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-initial-focus-display-animation.tentative.html | 0/1>1/1 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-inside-top-layer.tentative.html | 2/4>4/4 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-keyboard-behavior.tentative.html | 2/10>10/10 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-keyboard-focus-change-for-hidden-options.tentative.html | 0/1>1/1 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-mouse-behavior.tentative.html | 4/8>8/8 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-option-arrow-scroll.tentative.html | 0/2>2/2 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-option-hover-styles.tentative.html | 0/1>1/1 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-parsing.tentative.html | 14/15>15/15 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-picker-exit-animation.tentative.html | 0/1>1/1 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-picker-hover-active-pseudo.tentative.html | 0/4>4/4 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-picker-interactive-element-focus.tentative.html | 0/1>1/1 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-picker-starting-style.tentative.html | 0/1>1/1 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-pseudo-open.tentative.html | 0/2>2/2 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-synthetic-events.tentative.html | 0/2>2/2 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-type-to-search.tentative.html | 0/1>1/1 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/select-value-selectedOption.tentative.html | 9/11>11/11 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/selectedcontent-restore.tentative.html | 0/1>1/1 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/selectedcontent.tentative.html | 0/3>3/3 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/customizable-select/switch-picker-appearance.tentative.html | 0/9>5/9 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/forms/the-select-element/select-option-focusable.tentative.html | 0/1>1/1 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/semantics/interactive-elements/the-dialog-element/dialog-closedby-corner-cases.html | 0/0>18/18 | d | HTMLDialogLightDismiss ya stable en el 134 (a42fbb916e0, 22-1); test reescrito (totales cambian) | S |
| html/semantics/interactive-elements/the-dialog-element/dialog-closedby-start-open.html | 1/2>2/2 | d | HTMLDialogLightDismiss ya stable en el 134 (a42fbb916e0, 22-1); test reescrito (totales cambian) | S |
| html/semantics/interactive-elements/the-dialog-element/dialog-requestclose.html | 39/39>75/75 | d | HTMLDialogLightDismiss ya stable en el 134 (a42fbb916e0, 22-1); test reescrito (totales cambian) | S |
| html/semantics/popovers/popover-light-dismiss-command.html | 3/14>14/14 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/semantics/the-button-element/command-and-commandfor/button-event-dispatch-content-attribute.html | 0/2>2/2 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/semantics/the-button-element/command-and-commandfor/button-event-dispatch.html | 19/39>39/39 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/semantics/the-button-element/command-and-commandfor/button-type-behavior.html | 10/23>23/23 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/semantics/the-button-element/command-and-commandfor/button-type-reflection.html | 9/27>18/27 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/semantics/the-button-element/command-and-commandfor/command-reflection.html | 8/16>16/16 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/semantics/the-button-element/command-and-commandfor/event-dispatch-shadow.html | 0/2>2/2 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/semantics/the-button-element/command-and-commandfor/event-interface.html | 0/22>22/22 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/semantics/the-button-element/command-and-commandfor/interface.html | 1/11>11/11 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/semantics/the-button-element/command-and-commandfor/on-dialog-behavior.html | 25/50>50/50 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/semantics/the-button-element/command-and-commandfor/on-dialog-disconnect.html | 0/1>1/1 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/semantics/the-button-element/command-and-commandfor/on-popover-behavior.html | 14/27>28/28 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/semantics/the-button-element/command-and-commandfor/on-popover-disconnect.html | 0/1>1/1 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/semantics/the-button-element/interest-target/interesttarget-outline-appearance.tentative.html | 0/0>0/0 | b | InterestTarget (experimental, fuera; 110c2fe0229 es del 136) | S |
| html/syntax/parsing/html5lib_tests7.html?run_type=uri | 31/33>32/33 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/syntax/parsing/html5lib_tests7.html?run_type=write | 31/33>32/33 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/syntax/parsing/html5lib_tests7.html?run_type=write_single | 31/33>32/33 | a | fila CustomizableSelect/SelectParserRelaxation (425a3d1c5f) / OptionLabelAttributeWhitespace (06f3c0350d) | S |
| html/webappapis/scripting/events/event-handler-all-global-events.html | 362/375>367/375 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/webappapis/scripting/events/event-handler-attributes-body-window.html | 348/376>351/376 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/webappapis/scripting/events/event-handler-attributes-frameset-window.html | 347/376>350/376 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/webappapis/scripting/events/event-handler-attributes-windowless-body.html | 224/236>226/236 | a | fila HTMLCommandAttributes (85364ff7e3, 17926bb6ea oncommand) | S |
| html/webappapis/timers/setinterval-settimeout-clamping.html | 1/2>2/2 | c | 0399f3f3d6f (SetIntervalWithoutClamp, base::Feature en blink/common/features.cc + dom_timer.cc/timer.cc) + a78ea6f24da | V |
| navigation-api/navigate-event/event-constructor.html | 4/6>6/6 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-anchor-cross-origin.html | 0/0>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-anchor-download-userInitiated.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-anchor-download.html | 0/4>4/4 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-anchor-fragment.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-anchor-same-origin-cross-document.html | 0/0>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-anchor-userInitiated.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-anchor-with-target.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-destination-getState-navigate.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-destination-getState-reload.html | 0/0>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-form-get.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-form-reload.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-form-requestSubmit.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-form-traverse.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-form-userInitiated.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-form-with-target.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-form.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-history-back-after-fragment.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-history-back-after-pushState.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-history-back-cross-document.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-history-go-0.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-history-pushState.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-history-replaceState.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-iframe-location.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-location.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-meta-refresh.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-navigation-back-cross-document.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-navigation-back-same-document.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-navigation-navigate.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-svg-anchor-fragment.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-to-srcdoc.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-window-open-self.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/navigate-event/navigate-window-open.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/ordering-and-transition/reload-no-popstate.html | 0/1>1/1 | a | NavigateEventSourceElement (61a28abed5) / NavigateEventPopstateLimitations (cd6fd72eb9) | S |
| navigation-api/precommit-handler/precommitHandler-push.html | 0/3>2/3 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| navigation-api/precommit-handler/precommitHandler-redirect-throws.html | 5/7>6/8 | d | test WPT cambiado entre las dos revisiones (totales distintos) | S |
| navigation-api/precommit-handler/precommitHandler-reload.html | 0/3>2/3 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| navigation-api/precommit-handler/precommitHandler-replace.html | 0/3>2/3 | c? | sin commit localizado por mensaje en 4-2..4-3-2025 (o cambio de test/Finch); revisar con -expected.txt | S |
| wai-aria/idlharness.window.html | 95/111>109/111 | a | AOMAriaRelationshipProperties (163f516c9a) + HTMLCommandAttributes (CommandEvent/oncommand) | S |
