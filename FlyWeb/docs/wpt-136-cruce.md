# Cruce wpt.fyi Chrome 135 vs 136 contra el nivel 136 de FlyWeb

Runs (Linux, wpt.fyi, product=chrome, label=stable): 135 = id 5142546559008768, 135.0.7049.114 (29-4-2025, wpt 1d1ca6bbce); 136 = id 5095641221169152, 136.0.7103.49 (30-4-2025, wpt e115cf56cd). Las revisiones de WPT difieren en un solo dia: pocos falsos positivos (50 pruebas con totales distintos, marcadas d). No hay run estable posterior mas cercano: el 136.0.7103.x mas proximo en el tiempo es el .49; los .92/.94/.113 son de mayo (mas deriva de WPT). Solo cambian en el 136 las cherry-picks de seguridad posteriores a .49.

Criterio: aciertos(136) > aciertos(135) por contadores del summary_v2 (c=[pass,total]); para prueba unica, estado no-PASS/OK a PASS/OK. Directorios de la lista del nivel 135 (css, html, dom, editing, navigation-api, fetch/fetch-later, observable, wai-aria, accname, core-aam, html-aam) y ademas el resto de WPT (webnn: 137 pruebas, todas d). navigation-api, fetch, observable, wai-aria, accname, core-aam, html-aam: 0 mejoras.

Clases: a = cubierta por una funcion del 136 (flag que pasa a stable o ship); b = aplazada/fuera; c = falta sin flag con commit; c? = sin causa localizada; d = entorno/test cambiado.

Totales (mejoras): a=63, b=15, c=84, c?=64, d=172  (n=398); regresiones: 86

Fuentes de atribucion: diff de `runtime_enabled_features.json5` entre 135.0.7049.117 y 136.0.7103.116 (flags nuevas/que pasan a stable) y `git log` de asuntos entre ambos tags (15 310 commits, 3-3 a 31-3-2025 en main). developer.chrome.com y chromestatus dan 403: la lista de funciones sale del diff de flags, no de las notas de version. No se miraron los -expected.txt (clon sin blobs): las atribuciones de grupo son por asunto de commit, no verificadas por borrado de expectativa.

## Mejoras 135 a 136

| prueba | subpruebas pass 135>136 | clase | funcion / commit / flag | V/S |
|---|---|---|---|---|
| ai/language_detection/detector-locale.https.window.html | 0/4>1/4 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| compute-pressure/compute_pressure_duplicate_updates.https.window.html?globalScope=dedicated_worker | E>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| compute-pressure/compute_pressure_duplicate_updates.https.window.html?globalScope=window | 1/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| content-security-policy/gen/top.http-rp/script-src-self/sharedworker-import.http.html | 6/12>8/12 | c | ce4ad062d Return worker in error state instead of throw for CSP blocked worker | S |
| content-security-policy/gen/top.meta/worker-src-self/sharedworker-import.http.html | 5/12>8/12 | c | ce4ad062d Return worker in error state instead of throw for CSP blocked worker | S |
| content-security-policy/worker-src/dedicated-none.sub.html | 0/2>2/2 | c | ce4ad062d Return worker in error state instead of throw for CSP blocked worker | S |
| content-security-policy/worker-src/dedicated-worker-src-child-fallback-blocked.sub.html | 0/1>1/1 | c | ce4ad062d Return worker in error state instead of throw for CSP blocked worker | S |
| content-security-policy/worker-src/shared-none.sub.html | 0/2>2/2 | c | ce4ad062d Return worker in error state instead of throw for CSP blocked worker | S |
| content-security-policy/worker-src/shared-worker-src-child-fallback-blocked.sub.html | 0/1>1/1 | c | ce4ad062d Return worker in error state instead of throw for CSP blocked worker | S |
| css/compositing/root-element-background-margin-opacity.html | F>P | c? | sin commit localizado | S |
| css/css-anchor-position/position-area-anchor-outside.html | 0/11>11/11 | c | 628b74a88 [anchor] Allow position-area to expand the containing-block rect (sin flag) | S |
| css/css-anchor-position/position-area-anchor-partially-outside.html | 0/11>11/11 | c | 628b74a88 [anchor] Allow position-area to expand the containing-block rect (sin flag) | S |
| css/css-anchor-position/position-area-in-grid.html | 0/2>2/2 | c | 628b74a88 [anchor] Allow position-area to expand the containing-block rect (sin flag) | S |
| css/css-anchor-position/position-area-scrolling-007.html | 3/7>7/7 | c | 628b74a88 [anchor] Allow position-area to expand the containing-block rect (sin flag) | S |
| css/css-anchor-position/position-visibility-anchors-visible-both-position-fixed.html | F>P | c | 9a3fe1090 Ignore common container for position-visibility: anchors-visible (sin flag) | S |
| css/css-anchor-position/position-visibility-anchors-visible-with-position.html | F>P | c | 9a3fe1090 Ignore common container for position-visibility: anchors-visible (sin flag) | S |
| css/css-anchor-position/property-interpolations.html | 534/546>546/546 | c | 4914a98ba Resolve calc() inside anchor() at computed value time / 26f9fcb21 (probable) | S |
| css/css-animations/animate-with-background-color-oklch-001.html | F>P | c | 6628ad417 Fix the background color animation between color spaces (srgb/oklch) | S |
| css/css-animations/animate-with-background-color-oklch-002.html | 0/2>2/2 | c | 6628ad417 Fix the background color animation between color spaces (srgb/oklch) | S |
| css/css-cascade/all-prop-initial-xml.html | 394/394>395/395 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| css/css-cascade/all-prop-revert-layer.html | 337/338>338/339 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| css/css-color-adjust/inheritance.html | 4/8>6/8 | a | print-color-adjust enviado: e81066c28 Ship print-color-adjust | S |
| css/css-color-adjust/parsing/print-color-adjust.html | 0/4>2/4 | a | print-color-adjust enviado: e81066c28 Ship print-color-adjust | S |
| css/css-color-hdr/computed.html | 0/21>20/21 | a | CSSDynamicRangeLimit pasa a stable: 7bb8923dd Enable dynamic-range-limit CSS property, b728122aa | S |
| css/css-color-hdr/inheritance.html | 0/2>2/2 | a | CSSDynamicRangeLimit pasa a stable: 7bb8923dd Enable dynamic-range-limit CSS property, b728122aa | S |
| css/css-color-hdr/interpolation.html | 0/64>64/64 | a | CSSDynamicRangeLimit pasa a stable: 7bb8923dd Enable dynamic-range-limit CSS property, b728122aa | S |
| css/css-color-hdr/parsing.html | 16/29>28/29 | a | CSSDynamicRangeLimit pasa a stable: 7bb8923dd Enable dynamic-range-limit CSS property, b728122aa | S |
| css/css-color/currentcolor-005.html | F>P | c | bf7905fb3 Invalidate fill/stroke color expressions on currentcolor changes (probable) | S |
| css/css-color/parsing/color-computed-relative-color.html | 1047/1071>1056/1071 | c? | 23e73b3fb infinito en relative colors (parcial); 30/1077>1062/1077 sugiere cambio de estructura del test o un fallo global; revisar | S |
| css/css-color/parsing/color-valid-color-mix-function.html | 582/587>586/587 | c | 0e03d2b8b Fix percentage serialization for color-mix() (probable) | S |
| css/css-color/parsing/color-valid-relative-color.html | 30/1077>1062/1077 | c? | 23e73b3fb infinito en relative colors (parcial); 30/1077>1062/1077 sugiere cambio de estructura del test o un fallo global; revisar | S |
| css/css-contain/content-visibility/content-visibility-svg-path.html | 5/9>7/9 | c? | sin commit localizado | S |
| css/css-contain/content-visibility/content-visibility-svg-rect.html | 2/4>4/4 | c? | sin commit localizado | S |
| css/css-contain/content-visibility/content-visibility-svg-text.html | 4/5>5/5 | c? | sin commit localizado | S |
| css/css-display/reading-flow/tentative/reading-flow-computed.html | 6/7>7/7 | c | e278a7b65 [reading-flow] Implement source-order keyword (flag experimental en 136; aplazable) | S |
| css/css-display/reading-flow/tentative/reading-flow-valid.html | 6/7>7/7 | c | e278a7b65 [reading-flow] Implement source-order keyword (flag experimental en 136; aplazable) | S |
| css/css-flexbox/abspos/flex-abspos-staticpos-align-self-safe-001.html | F>P | c | 7e14bcd97 Safe alignment in statically positioned OOFs (sin flag) | S |
| css/css-flexbox/abspos/flex-abspos-staticpos-align-self-safe-002.html | F>P | c | 7e14bcd97 Safe alignment in statically positioned OOFs (sin flag) | S |
| css/css-flexbox/gap-019.html | F>P | c? | sin commit localizado por asunto | S |
| css/css-flexbox/intrinsic-size/row-002.html | F>P | a | LayoutFlexNewRowAlgorithm pasa a stable: a309eab0e Rename and enable the flag for new intrinsic size algorithm | S |
| css/css-flexbox/intrinsic-size/row-003.html | F>P | a | LayoutFlexNewRowAlgorithm pasa a stable: a309eab0e Rename and enable the flag for new intrinsic size algorithm | S |
| css/css-flexbox/intrinsic-size/row-004.html | F>P | a | LayoutFlexNewRowAlgorithm pasa a stable: a309eab0e Rename and enable the flag for new intrinsic size algorithm | S |
| css/css-flexbox/intrinsic-size/row-005.html | 1/9>3/9 | a | LayoutFlexNewRowAlgorithm pasa a stable: a309eab0e Rename and enable the flag for new intrinsic size algorithm | S |
| css/css-flexbox/intrinsic-size/row-007.html | F>P | a | LayoutFlexNewRowAlgorithm pasa a stable: a309eab0e Rename and enable the flag for new intrinsic size algorithm | S |
| css/css-flexbox/intrinsic-size/row-008.html | 0/11>2/11 | a | LayoutFlexNewRowAlgorithm pasa a stable: a309eab0e Rename and enable the flag for new intrinsic size algorithm | S |
| css/css-flexbox/intrinsic-size/row-use-cases-001.html | 0/6>3/6 | a | LayoutFlexNewRowAlgorithm pasa a stable: a309eab0e Rename and enable the flag for new intrinsic size algorithm | S |
| css/css-flexbox/parsing/flex-computed.html | 11/14>12/14 | c | 6bab48d8b Use ConsumeNumber() for flex shorthand (sin flag) | S |
| css/css-flexbox/parsing/flex-invalid.html | 4/6>6/6 | c | 6bab48d8b Use ConsumeNumber() for flex shorthand (sin flag) | S |
| css/css-flexbox/parsing/flex-valid.html | 12/16>14/16 | c | 6bab48d8b Use ConsumeNumber() for flex shorthand (sin flag) | S |
| css/css-fonts/font-default-04.html | F>P | c? | sin commit localizado por asunto (arreglos de render/crash sin flag) | S |
| css/css-fonts/font-display/font-display-feature-policy-02.tentative.html | F>P | c? | sin commit localizado por asunto (arreglos de render/crash sin flag) | S |
| css/css-fonts/font-variant-caps.html | F>P | c? | sin commit localizado por asunto (arreglos de render/crash sin flag) | S |
| css/css-fonts/font-variant-east-asian.html | F>P | c? | sin commit localizado por asunto (arreglos de render/crash sin flag) | S |
| css/css-fonts/font-variant-ligatures.html | F>P | c? | sin commit localizado por asunto (arreglos de render/crash sin flag) | S |
| css/css-fonts/font-variant-numeric.html | F>P | c? | sin commit localizado por asunto (arreglos de render/crash sin flag) | S |
| css/css-fonts/font-variant-position.html | F>P | c? | sin commit localizado por asunto (arreglos de render/crash sin flag) | S |
| css/css-grid/abspos/grid-abspos-staticpos-align-self-safe-001.html | F>P | c | 7e14bcd97 Safe alignment in statically positioned OOFs (sin flag) | S |
| css/css-grid/alignment/grid-item-aspect-ratio-stretch-4.html | F>P | c | a8ad9ea3a [layout] Coerce the natural block-size to respect the aspect-ratio | S |
| css/css-images/gradient/conic-gradient-001.html | F>P | c | dd20dbfcd Fix conic-gradient edge cases | S |
| css/css-images/gradient/gradient-analogous-missing-components-004.html | F>P | c | 7348ba7ff Fix carry-forward of missing components for gradients / 5e41c6f31 kSRGB default | S |
| css/css-images/gradient/gradient-eval-004.html | F>P | c? | familia de gradientes de marzo (7348ba7ff, 5e41c6f31); sin certeza | S |
| css/css-images/gradient/gradient-infinity-001.html | F>P | c | 527ca73e9 Fix infinity causes SkGradientShader::MakeLinear to fail | S |
| css/css-images/gradient/gradient-none-interpolation.html | F>P | c | 7348ba7ff Fix carry-forward of missing components for gradients / 5e41c6f31 kSRGB default | S |
| css/css-images/gradient/gradient-powerless-hue-hsl.html | F>P | c | 7348ba7ff Fix carry-forward of missing components for gradients / 5e41c6f31 kSRGB default | S |
| css/css-images/gradient/gradient-powerless-hue-hwb.html | F>P | c | 7348ba7ff Fix carry-forward of missing components for gradients / 5e41c6f31 kSRGB default | S |
| css/css-images/gradient/gradient-powerless-hue-lch.html | F>P | c | 7348ba7ff Fix carry-forward of missing components for gradients / 5e41c6f31 kSRGB default | S |
| css/css-images/gradient/gradient-powerless-hue-oklch.html | F>P | c | 7348ba7ff Fix carry-forward of missing components for gradients / 5e41c6f31 kSRGB default | S |
| css/css-images/object-fit-none-png-001c.html | F>P | c? | sin commit localizado (png/object-fit); posible 652700872 Remove 1:1 aspect ratio on error in LayoutImage | S |
| css/css-images/object-fit-none-png-002c.html | F>P | c? | sin commit localizado (png/object-fit); posible 652700872 Remove 1:1 aspect ratio on error in LayoutImage | S |
| css/css-images/object-fit-scale-down-png-001c.html | F>P | c? | sin commit localizado (png/object-fit); posible 652700872 Remove 1:1 aspect ratio on error in LayoutImage | S |
| css/css-images/object-fit-scale-down-png-002c.html | F>P | c? | sin commit localizado (png/object-fit); posible 652700872 Remove 1:1 aspect ratio on error in LayoutImage | S |
| css/css-images/parsing/gradient-interpolation-method-invalid.html | 283/292>292/292 | c | 2d96077a6 Make CSS Parser reject invalid gradients | S |
| css/css-images/radial-gradient-container-relative-units-001.html | F>P | c | 565e9ba05 Fix presence check for container relative units in radial-gradient() | S |
| css/css-images/radial-gradient-container-relative-units-002.html | F>P | c | 565e9ba05 Fix presence check for container relative units in radial-gradient() | S |
| css/css-images/radial-gradient-container-relative-units-003.html | F>P | c | 565e9ba05 Fix presence check for container relative units in radial-gradient() | S |
| css/css-images/radial-gradient-container-relative-units-004.html | F>P | c | 565e9ba05 Fix presence check for container relative units in radial-gradient() | S |
| css/css-masking/clip-path/animations/clip-path-animation-geometry-box-delay.html | C>P | c? | sin commit localizado por asunto (arreglos de render/crash sin flag) | S |
| css/css-masking/clip-path/animations/clip-path-animation-reference-delay.html | C>P | c? | sin commit localizado por asunto (arreglos de render/crash sin flag) | S |
| css/css-masonry/tentative/parsing/masonry-track-invalid.html | C>39/39 | b | masonry (fuera, flag experimental): 696961e5f | S |
| css/css-overflow/column-scroll-marker-015-crash.html | C>P | b | carousel (aplazado): 3e785ee6c, a7623c31b, 438da0020, 0c9f84c18 scroll-marker | S |
| css/css-overflow/column-scroll-marker-focus-001.html | 3/9>9/9 | b | carousel (aplazado): 3e785ee6c, a7623c31b, 438da0020, 0c9f84c18 scroll-marker | S |
| css/css-overflow/column-scroll-marker-focus-003.html | 0/5>5/5 | b | carousel (aplazado): 3e785ee6c, a7623c31b, 438da0020, 0c9f84c18 scroll-marker | S |
| css/css-overflow/column-scroll-marker-focus-004.html | 1/11>11/11 | b | carousel (aplazado): 3e785ee6c, a7623c31b, 438da0020, 0c9f84c18 scroll-marker | S |
| css/css-overflow/keyboard-scroll.html | 2/3>3/3 | c? | probable carousel/scroll-marker (b); sin certeza | S |
| css/css-overflow/root-scroll-marker.html | F>P | b | carousel (aplazado): 3e785ee6c, a7623c31b, 438da0020, 0c9f84c18 scroll-marker | S |
| css/css-overflow/scroll-marker-014-crash.html | C>P | b | carousel (aplazado): 3e785ee6c, a7623c31b, 438da0020, 0c9f84c18 scroll-marker | S |
| css/css-overflow/scrollbar-gutter-fixedpos-002.html | F>P | c | a218ae496 [scrollbar-gutter] Make fixedpos respect the root scrollbar-gutter; 2797fa283 (ScrollbarGutterFixedPosBugfix, stable) | S |
| css/css-overflow/scrollbar-gutter-with-background-gradient.html | F>P | c | a218ae496 [scrollbar-gutter] Make fixedpos respect the root scrollbar-gutter; 2797fa283 (ScrollbarGutterFixedPosBugfix, stable) | S |
| css/css-position/overlay/overlay-transition-finished.html | F>P | c? | sin commit localizado por asunto (arreglos de render/crash sin flag) | S |
| css/css-properties-values-api/var-reference-registered-properties.html | 12/16>15/16 | a | 7b65a6f1e Ship CSSTypeAgnosticVarFallback | S |
| css/css-ruby/ruby-inlinize-fieldset-crash.html | C>P | c | 634a7e2ac RubyLB: Fix a CHECK failure with a FIELDSET with display:contents (crash) | S |
| css/css-scoping/host-has-internal-004.html | F>P | c | c1561689f Set all :has() in compound match in shadow tree if compound contains :host; 2fe4cb727 | S |
| css/css-scroll-snap/snap-after-relayout/multiple-aligned-targets/prefer-focused-nested-containers.html | 0/1>1/1 | c? | sin commit localizado por asunto (arreglos de render/crash sin flag) | S |
| css/css-sizing/aspect-ratio/replaced-element-043.html | 117/180>180/180 | c | 652700872 Remove 1:1 aspect ratio on error in LayoutImage (LayoutImageForceAspectRatioOfOneOnError retirado) | S |
| css/css-sizing/aspect-ratio/replaced-element-044.html | 3/4>4/4 | c | 652700872 Remove 1:1 aspect ratio on error in LayoutImage (LayoutImageForceAspectRatioOfOneOnError retirado) | S |
| css/css-sizing/aspect-ratio/replaced-element-045.html | F>P | c | 652700872 Remove 1:1 aspect ratio on error in LayoutImage (LayoutImageForceAspectRatioOfOneOnError retirado) | S |
| css/css-sizing/aspect-ratio/replaced-element-046.html | F>P | c | 652700872 Remove 1:1 aspect ratio on error in LayoutImage (LayoutImageForceAspectRatioOfOneOnError retirado) | S |
| css/css-sizing/fit-content-min-inline-size.html | F>P | c | e8db6a7a4 [layout] Fix fit-content on min/max inline-sizes for contributions; fcd3f5f53 | S |
| css/css-sizing/keyword-sizes-for-intrinsic-contributions.html | 32/36>36/36 | c | e8db6a7a4 [layout] Fix fit-content on min/max inline-sizes for contributions; fcd3f5f53 | S |
| css/css-tables/fixed-layout-2.html | 15/18>18/18 | c | TableIsAutoFixedLayout (flag nueva en stable, arreglo de layout de tablas); commit no localizado por asunto | S |
| css/css-tables/percent-height-replaced-in-percent-cell-003.html | F>P | c | TableIsAutoFixedLayout (flag nueva en stable, arreglo de layout de tablas); commit no localizado por asunto | S |
| css/css-tables/percent-height-replaced-in-percent-cell-004.html | F>P | c | TableIsAutoFixedLayout (flag nueva en stable, arreglo de layout de tablas); commit no localizado por asunto | S |
| css/css-text/line-break/line-break-anywhere-001.html | F>P | c? | sin commit localizado por asunto (arreglos de render/crash sin flag) | S |
| css/css-values/acos-asin-atan-atan2-computed.html | 40/45>42/45 | c | 1abd013ba Only allow numeric literals for attr(<attr-unit>); 61f96086e Support non-simplifiable trigonometric functions (15-4, probable cherry-pick) | S |
| css/css-values/attr-all-types.html | 136/139>138/139 | c | 1abd013ba Only allow numeric literals for attr(<attr-unit>); 61f96086e Support non-simplifiable trigonometric functions (15-4, probable cherry-pick) | S |
| css/css-values/ch-unit-002.html | F>P | c | 79495045a Fix ch unit not depends on writing-mode and text-orientation; 239c7072c quita ch-unit-002 de NeverFix | S |
| css/css-values/ch-unit-011.html | F>P | c | 79495045a Fix ch unit not depends on writing-mode and text-orientation; 239c7072c quita ch-unit-002 de NeverFix | S |
| css/css-values/ch-unit-017.html | F>P | c | 79495045a Fix ch unit not depends on writing-mode and text-orientation; 239c7072c quita ch-unit-002 de NeverFix | S |
| css/css-values/ch-unit-018.html | F>P | c | 79495045a Fix ch unit not depends on writing-mode and text-orientation; 239c7072c quita ch-unit-002 de NeverFix | S |
| css/css-values/ic-unit-015.html | F>P | c | 79495045a Fix ch unit not depends on writing-mode and text-orientation; 239c7072c quita ch-unit-002 de NeverFix | S |
| css/css-view-transitions/navigation/root-and-nested-element-transition.html | T>P | c? | candidatos: db52e4a99 (view-transition-name: auto), b8db38057/10665cffd (pausa de animaciones en reftests, cambio de test); regresiones P>T en navigation | S |
| css/css-view-transitions/navigation/with-types/at-rule-types-shared-elements.html | F>P | c? | candidatos: db52e4a99 (view-transition-name: auto), b8db38057/10665cffd (pausa de animaciones en reftests, cambio de test); regresiones P>T en navigation | S |
| css/css-view-transitions/ready_resolves_after_dom_before_raf.html | 0/1>1/1 | c? | candidatos: db52e4a99 (view-transition-name: auto), b8db38057/10665cffd (pausa de animaciones en reftests, cambio de test); regresiones P>T en navigation | S |
| css/css-view-transitions/start-view-transtion-skips-active.html | 0/1>1/1 | c? | candidatos: db52e4a99 (view-transition-name: auto), b8db38057/10665cffd (pausa de animaciones en reftests, cambio de test); regresiones P>T en navigation | S |
| css/css-will-change/will-change-stacking-context-mask-image-1.html | F>P | c? | sin commit localizado por asunto (arreglos de render/crash sin flag) | S |
| css/css-writing-modes/ch-units-vrl-003.html | F>P | c | 79495045a Fix ch unit not depends on writing-mode and text-orientation; 239c7072c quita ch-unit-002 de NeverFix | S |
| css/css-writing-modes/ch-units-vrl-004.html | F>P | c | 79495045a Fix ch unit not depends on writing-mode and text-orientation; 239c7072c quita ch-unit-002 de NeverFix | S |
| css/css-writing-modes/text-orientation-mixed-vlr-100.html | F>P | c? | posible 79495045a (writing-mode/text-orientation); sin certeza | S |
| css/css-writing-modes/text-orientation-mixed-vrl-100.html | F>P | c? | posible 79495045a (writing-mode/text-orientation); sin certeza | S |
| css/css-writing-modes/text-orientation-sideways-vlr-100.html | F>P | c? | posible 79495045a (writing-mode/text-orientation); sin certeza | S |
| css/css-writing-modes/text-orientation-sideways-vrl-100.html | F>P | c? | posible 79495045a (writing-mode/text-orientation); sin certeza | S |
| css/cssom-view/scrollTo-zoom.html | F>P | c? | sin commit localizado por asunto (arreglos de render/crash sin flag) | S |
| css/filter-effects/empty-element-with-filter-002.html | F>P | c | 669f3441a Paint reference filters with empty ref boxes; d586e3a9e Move ensuring empty ref filter chunk to PaintLayerPainter | S |
| css/filter-effects/empty-element-with-filter-003.html | F>P | c | 669f3441a Paint reference filters with empty ref boxes; d586e3a9e Move ensuring empty ref filter chunk to PaintLayerPainter | S |
| css/filter-effects/feComposite-intersection-feTile-input-svg.html | F>P | c | 669f3441a Paint reference filters with empty ref boxes; d586e3a9e Move ensuring empty ref filter chunk to PaintLayerPainter | S |
| css/filter-effects/feComposite-intersection-feTile-input.html | F>P | c | 669f3441a Paint reference filters with empty ref boxes; d586e3a9e Move ensuring empty ref filter chunk to PaintLayerPainter | S |
| document-picture-in-picture/propagate-user-activation-to-opener.https.html | 0/1>1/1 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| dom/events/scrolling/scrollend-event-fires-on-visual-viewport.html | 0/2>2/2 | c? | sin commit localizado (scrollend en visual viewport) | S |
| dom/lists/DOMTokenList-coverage-for-attributes.html | 174/175>175/175 | a | SvgAnchorElementRelAttributes stable (5cbc8cc71): relList en SVGAElement | S |
| dom/nodes/moveBefore/object-crash-regression.html | C>1/1 | c | 5619643c2 DOM: Fix moveBefore() <object> element subframe crash | S |
| dom/nodes/moveBefore/style-applies.html | 0/1>1/1 | c | caf55a633 Reapply style after a moveBefore | S |
| editing/crashtests/designMode-caret-change.html | T>P | c? | sin commit localizado (crash designMode) | S |
| editing/edit-context/edit-context-focus.tentative.html | 0/1>1/1 | c | 05b7a8695 / 8385b1405 [EditContext] fixes | S |
| editing/edit-context/edit-context-input.tentative.html | 11/14>12/14 | c | 05b7a8695 / 8385b1405 [EditContext] fixes | S |
| encrypted-media/clearkey-check-status-for-hdcp.https.html | 0/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| fedcm/fedcm-multi-idp/fedcm-multi-idp-abort.https.html | 0/1>1/1 | a | df11fdf9a [FedCM] Enable multi IDP by default (FedCmMultipleIdentityProviders stable) | S |
| fedcm/fedcm-multi-idp/fedcm-multi-idp-basic.https.html | 0/2>2/2 | a | df11fdf9a [FedCM] Enable multi IDP by default (FedCmMultipleIdentityProviders stable) | S |
| fedcm/fedcm-multi-idp/fedcm-multi-idp-context.https.html | 0/2>2/2 | a | df11fdf9a [FedCM] Enable multi IDP by default (FedCmMultipleIdentityProviders stable) | S |
| fedcm/fedcm-multi-idp/fedcm-multi-idp-mediation-optional.https.html | 0/3>1/3 | a | df11fdf9a [FedCM] Enable multi IDP by default (FedCmMultipleIdentityProviders stable) | S |
| fedcm/fedcm-multi-idp/fedcm-multi-idp-mediation-silent.https.html | 0/3>1/3 | a | df11fdf9a [FedCM] Enable multi IDP by default (FedCmMultipleIdentityProviders stable) | S |
| fullscreen/api/element-request-fullscreen-cross-origin.sub.html | 0/1>1/1 | c? | sin commit localizado por asunto | S |
| hsts/only-top-level-navigation-hsts-upgrade.tentative.sub.html | 0/1>1/1 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| html/browsers/browsing-the-web/read-media/cross-origin-video.html | 0/1>1/1 | c? | sin commit localizado por asunto | S |
| html/browsers/the-window-object/open-close/open-features-negative-innerwidth-innerheight.html | 0/6>6/6 | c? | sin commit localizado (open features/tamano inicial) | S |
| html/browsers/the-window-object/open-close/open-features-negative-width-height.html | 0/6>6/6 | c? | sin commit localizado (open features/tamano inicial) | S |
| html/browsers/the-window-object/open-close/open_initial_size.html | 0/1>1/1 | c? | sin commit localizado (open features/tamano inicial) | S |
| html/canvas/element/manual/compositing/colr-glyph-composition.html | F>P | c | 7c3cc6ec1 CanvasTextNG: DirectionalOverride support (direction rtl) (probable) | S |
| html/canvas/element/manual/text/canvas.2d.lang.dynamic.html | F>P | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/element/manual/text/canvas.2d.lang.html | F>P | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/element/manual/text/canvas.2d.lang.inherit.disconnected.canvas.html | F>P | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/element/text/2d.text.lang.default.html | 0/1>1/1 | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/element/text/2d.text.measure.lang.html | 0/1>1/1 | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/element/text/2d.text.measure.lang.inherit.html | 0/1>1/1 | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/element/text/direction-inherit-rtl.html | F>P | c | 7c3cc6ec1 CanvasTextNG: DirectionalOverride support (direction rtl) (probable) | S |
| html/canvas/element/text/direction-rtl.html | F>P | c | 7c3cc6ec1 CanvasTextNG: DirectionalOverride support (direction rtl) (probable) | S |
| html/canvas/offscreen/manual/text/canvas.2d.offscreen.lang.html | F>P | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/offscreen/manual/text/canvas.2d.offscreen.lang.inherit.html | F>P | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/offscreen/manual/text/canvas.2d.offscreen.transferred.lang.html | F>P | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/offscreen/manual/text/canvas.2d.offscreen.transferred.lang.inherit.document.html | F>P | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/offscreen/manual/text/canvas.2d.offscreen.transferred.lang.inherit.html | F>P | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/offscreen/manual/text/canvas.2d.offscreen.worker.lang.html | F>P | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/offscreen/manual/text/canvas.2d.offscreen.worker.lang.inherit.html | F>P | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/offscreen/text/2d.text.lang.default.html | 0/1>1/1 | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/offscreen/text/2d.text.lang.default.worker.html | 0/1>1/1 | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/offscreen/text/2d.text.measure.lang.html | 0/1>1/1 | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/offscreen/text/2d.text.measure.lang.inherit.html | 0/1>1/1 | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/canvas/offscreen/text/2d.text.measure.lang.worker.html | 0/1>1/1 | a | fe51f0bbd Enable Canvas Text lang attribute (+ b15db6c6e, 0623f7ba4 quitan expectativas) | S |
| html/cross-origin-embedder-policy/credentialless/reporting-subresource-corp.https.window.html | 0/1>1/1 | c? | sin commit localizado por asunto | S |
| html/cross-origin-embedder-policy/dedicated-worker.https.html | 11/14>12/14 | c? | sin commit localizado por asunto | S |
| html/cross-origin-opener-policy/iframe-popup-unsafe-none-to-same-origin.https.html?7-8 | C>6/6 | c? | sin commit localizado por asunto | S |
| html/dom/idlharness.any.worker.html | 767/779>768/779 | c? | sin commit localizado por asunto | S |
| html/dom/idlharness.https.html?exclude=(Document|Window|HTML.+) | 1550/1637>1553/1637 | c? | sin commit localizado por asunto | S |
| html/dom/render-blocking/element-render-blocking-040.html | 0/1>1/1 | c | be2d207b9 Process element render-blocking when an element is inserted | S |
| html/dom/render-blocking/element-render-blocking-041.html | 0/1>1/1 | c | be2d207b9 Process element render-blocking when an element is inserted | S |
| html/editing/the-hidden-attribute/hidden-ua-stylesheet.html | 6/8>8/8 | c? | sin commit localizado por asunto | S |
| html/editing/the-hidden-attribute/hidden-until-found-idl.html | 0/1>1/1 | c? | sin commit localizado por asunto | S |
| html/rendering/non-replaced-elements/phrasing-content-0/br-wbr-content/content-property.tentative.html | F>P | c | 02eeb8bae Fix <br> rendering with text in content property | S |
| html/rendering/non-replaced-elements/the-fieldset-and-legend-elements/fieldset-multicol-only-column-count.html | 0/1>1/1 | c | 979183f18 Fieldset: Handle column properties correctly | S |
| html/rendering/non-replaced-elements/the-fieldset-and-legend-elements/fieldset-multicol-only-column-width.html | 0/1>1/1 | c | 979183f18 Fieldset: Handle column properties correctly | S |
| html/rendering/replaced-elements/the-option-element/option-label-whitespace-2.html | F>P | c? | sin commit localizado por asunto | S |
| html/semantics/embedded-content/bfcache/embedded-type-only.html | 1/2>2/2 | c? | sin commit localizado por asunto | S |
| html/semantics/embedded-content/the-iframe-element/iframe-loading-lazy-nav-form-submit.html | 0/1>1/1 | c? | sin commit localizado por asunto | S |
| html/semantics/embedded-content/the-iframe-element/iframe-loading-lazy-nav-location-replace-set-src.html | 0/1>1/1 | c? | sin commit localizado por asunto | S |
| html/semantics/embedded-content/the-img-element/image-loading-lazy-below-viewport-dynamic.html | 0/1>1/1 | c? | sin commit localizado por asunto | S |
| html/semantics/forms/the-select-element/customizable-select/select-appearance-disabled.tentative.html | F>P | b | select personalizable (aplazado): 53987479a Add customizable select disabled styles | S |
| html/semantics/the-button-element/command-and-commandfor/on-video-behavior.tentative.html | 5/12>6/12 | c? | posible HTMLCommandRequestClose (flag experimental nueva); sin certeza | S |
| html/semantics/the-button-element/interest-target/interesttarget-user-select.tentative.html | 0/1>1/1 | b | interesttarget (aplazado): f89ecde3d, 5ea167e6c | S |
| intersection-observer/clip-path-animation.html | 0/1>1/1 | c? | sin commit localizado por asunto | S |
| long-animation-frame/tentative/loaf-source-location-redirect.html | 11/12>12/12 | c? | sin commit localizado por asunto | S |
| mixed-content/gen/top.meta/unset/sharedworker-import.https.html | 5/8>8/8 | c | ce4ad062d Return worker in error state instead of throw for CSP blocked worker | S |
| payment-request/payment-request-canmakepayment-method.https.html | 1/6>2/6 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| permissions-policy/reporting/camera-potential-report-only.https.html | 0/1>1/1 | a | PotentialPermissionsPolicyReporting stable: 868cb645c Enable Permissions Policy reports for iframes | S |
| permissions-policy/reporting/camera-potential-reporting.https.html | 0/1>1/1 | a | PotentialPermissionsPolicyReporting stable: 868cb645c Enable Permissions Policy reports for iframes | S |
| service-workers/cache-storage/cache-add.https.any.serviceworker.html | 20/22>21/22 | c? | sin commit localizado por asunto | S |
| service-workers/cache-storage/cache-storage.https.any.html | 9/10>10/10 | c? | sin commit localizado por asunto | S |
| service-workers/cache-storage/cache-storage.https.any.serviceworker.html | 9/10>10/10 | c? | sin commit localizado por asunto | S |
| service-workers/cache-storage/cache-storage.https.any.sharedworker.html | 9/10>10/10 | c? | sin commit localizado por asunto | S |
| service-workers/cache-storage/cache-storage.https.any.worker.html | 9/10>10/10 | c? | sin commit localizado por asunto | S |
| shadow-dom/focus/text-selection-with-delegatesFocus-text-control.html | 0/1>1/1 | c? | sin commit localizado por asunto | S |
| speculation-rules/prefetch/tentative/service-worker/basic.sub.https.html?origin=same-site&sw=fetch-handler | 0/1>1/1 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/prefetch/tentative/service-worker/basic.sub.https.html?origin=same-site&sw=fetch-handler-to-fallback | 0/1>1/1 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/prefetch/tentative/service-worker/basic.sub.https.html?origin=same-site&sw=no-fetch-handler | 0/1>1/1 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/prerender/protocol-handler-register.https.html | 0/1>1/1 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/prerender/protocol-handler-unregister.https.html | 0/1>1/1 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/speculation-tags/cross-site-to-same-site-redirection-prefetch.https.html | 0/1>1/1 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/speculation-tags/deduped-and-sorted-tags.https.html?type=prefetch | 0/5>5/5 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/speculation-tags/deduped-and-sorted-tags.https.html?type=prerender | 0/5>5/5 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/speculation-tags/invalid-tags.https.html?tag-level=rule&type=prefetch | 8/10>10/10 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/speculation-tags/invalid-tags.https.html?tag-level=rule&type=prerender | 8/10>10/10 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/speculation-tags/invalid-tags.https.html?tag-level=ruleset&type=prefetch | 0/10>10/10 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/speculation-tags/invalid-tags.https.html?tag-level=ruleset&type=prerender | 0/10>10/10 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/speculation-tags/no-tags.https.html | 0/2>2/2 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/speculation-tags/prerender-target-hint.https.html | 0/1>1/1 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/speculation-tags/valid-tags.https.html?tag-level=rule&type=prefetch | 0/8>8/8 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/speculation-tags/valid-tags.https.html?tag-level=rule&type=prerender | 0/8>8/8 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/speculation-tags/valid-tags.https.html?tag-level=ruleset&type=prefetch | 0/8>8/8 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speculation-rules/speculation-tags/valid-tags.https.html?tag-level=ruleset&type=prerender | 0/8>8/8 | a | SpeculationRulesTag stable: 82ca828bd Enables SpeculationRulesTag by default | S |
| speech-api/SpeechRecognition-availableOnDevice.https.html | 1/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| subresource-integrity/signatures/tentative/accept-signature.parser-inserted.html | 0/4>4/4 | b | SRI Message Signatures (flag experimental en 136): d5222f4c0, 39c9cd54f, a99541aeb | S |
| subresource-integrity/signatures/tentative/accept-signature.window.html | 5/7>7/7 | b | SRI Message Signatures (flag experimental en 136): d5222f4c0, 39c9cd54f, a99541aeb | S |
| subresource-integrity/signatures/tentative/client-initiated.cross-origin.window.html | 13/14>14/14 | b | SRI Message Signatures (flag experimental en 136): d5222f4c0, 39c9cd54f, a99541aeb | S |
| subresource-integrity/signatures/tentative/client-initiated.same-origin.window.html | 9/10>10/10 | b | SRI Message Signatures (flag experimental en 136): d5222f4c0, 39c9cd54f, a99541aeb | S |
| subresource-integrity/signatures/tentative/scheme.window.html | 4/6>6/6 | b | SRI Message Signatures (flag experimental en 136): d5222f4c0, 39c9cd54f, a99541aeb | S |
| subresource-integrity/signatures/tentative/unknown-parameter.window.html | 8/12>12/12 | b | SRI Message Signatures (flag experimental en 136): d5222f4c0, 39c9cd54f, a99541aeb | S |
| svg/geometry/svg-get-bounding-client-rect-in-non-rendered-elements.html | 0/1>1/1 | a | RestrictGetBoundingClientRectForHiddenSVGElements (flag stable nueva): 8e0b5b604 | S |
| svg/idlharness.window.html | 1625/1805>1632/1805 | a | SvgAnchorElementRelAttributes stable: 5cbc8cc71 | S |
| svg/linking/scripted/a.rel-getter-01.svg | 1/2>2/2 | a | SvgAnchorElementRelAttributes stable: 5cbc8cc71 | S |
| svg/linking/scripted/a.rel-noreferrer-policy.html | 0/1>1/1 | a | SvgAnchorElementRelAttributes stable: 5cbc8cc71 | S |
| svg/linking/scripted/rellist-feature-detection.svg | 0/1>1/1 | a | SvgAnchorElementRelAttributes stable: 5cbc8cc71 | S |
| svg/painting/color-mix-currentcolor-fill-stroke-repaint.html | F>P | c | bf7905fb3 Invalidate fill/stroke color expressions on currentcolor changes | S |
| svg/types/scripted/SVGGeometryElement.isPointInFill-01.svg | 0/7>7/7 | c | 1c8516ad0 Use DOMPointInit for getCharNumAtPosition, isPointInFill, isPointInStroke | S |
| svg/types/scripted/SVGGeometryElement.isPointInStroke-01.svg | 0/11>11/11 | c | 1c8516ad0 Use DOMPointInit for getCharNumAtPosition, isPointInFill, isPointInStroke | S |
| trusted-types/modify-attributes-in-callback.html | 2/9>4/9 | c | 30c762f7b / 0d6a1aff7 [Trusted Types] concurrent modifications / order of checks | S |
| trusted-types/set-attributes-mutations-in-callback.tentative.html | 116/248>200/248 | c | 30c762f7b / 0d6a1aff7 [Trusted Types] concurrent modifications / order of checks | S |
| web-animations/crashtests/effectively-infinite-timing-parameters.html | C>P | c? | sin commit localizado | S |
| webauthn/conditional-mediation.https.html | 1/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webcodecs/video-encoder-rescaling.https.any.html?h264_annexb | 13/18>18/18 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webcodecs/video-encoder-rescaling.https.any.html?h264_avc | 13/18>18/18 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webcodecs/video-encoder-rescaling.https.any.worker.html?h264_annexb | 13/18>18/18 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webcodecs/video-encoder-rescaling.https.any.worker.html?h264_avc | 13/18>18/18 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webcodecs/videoFrame-copyTo.any.html | 17/18>18/18 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webcodecs/videoFrame-copyTo.any.worker.html | 17/18>18/18 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webdriver/tests/bidi/browsing_context/download_will_begin/download_will_begin.py | 1/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webdriver/tests/bidi/browsing_context/set_viewport/invalid.py | 45/48>48/48 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webdriver/tests/bidi/browsing_context/set_viewport/user_contexts.py | 0/8>8/8 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webdriver/tests/bidi/input/file_dialog_opened/file_dialog_opened.py | 0/5>5/5 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webdriver/tests/bidi/input/file_dialog_opened/tentative/show_open_file_picker.py | 0/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webdriver/tests/bidi/integration/navigation.py | 1/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webdriver/tests/bidi/session/capabilities/unhandled_prompt_behavior/file/accept.py | T>4/4 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webdriver/tests/bidi/session/capabilities/unhandled_prompt_behavior/file/dismiss.py | T>4/4 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webdriver/tests/bidi/web_extension/install/install.py | 0/3>1/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webdriver/tests/bidi/web_extension/install/invalid.py | 5/40>33/40 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webdriver/tests/bidi/web_extension/uninstall/invalid.py | 0/7>7/7 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webdriver/tests/classic/accept_alert/accept.py | T>9/9 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/byob_readtensor.https.any.serviceworker.html?cpu | 0/13>13/13 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/byob_readtensor.https.any.serviceworker.html?gpu | 0/13>13/13 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/byob_readtensor.https.any.serviceworker.html?npu | 0/13>13/13 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/byob_readtensor.https.any.sharedworker.html?cpu | 0/11>11/11 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/byob_readtensor.https.any.sharedworker.html?gpu | 0/11>11/11 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/byob_readtensor.https.any.sharedworker.html?npu | 0/11>11/11 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/dequantizeLinear.https.any.html?cpu | 8/17>10/17 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/dequantizeLinear.https.any.html?gpu | 8/17>10/17 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/dequantizeLinear.https.any.html?npu | 8/17>10/17 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/identity.https.any.serviceworker.html?cpu | 0/1>14/14 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/identity.https.any.serviceworker.html?gpu | 0/1>14/14 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/identity.https.any.serviceworker.html?npu | 0/1>14/14 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/identity.https.any.sharedworker.html?cpu | 0/1>14/14 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/identity.https.any.sharedworker.html?gpu | 0/1>14/14 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/identity.https.any.sharedworker.html?npu | 0/1>14/14 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/inputs-are-not-modified.https.any.serviceworker.html?cpu | 0/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/inputs-are-not-modified.https.any.serviceworker.html?gpu | 0/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/inputs-are-not-modified.https.any.serviceworker.html?npu | 0/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/inputs-are-not-modified.https.any.sharedworker.html?cpu | 0/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/inputs-are-not-modified.https.any.sharedworker.html?gpu | 0/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/inputs-are-not-modified.https.any.sharedworker.html?npu | 0/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/neg.https.any.html?cpu | 16/16>17/18 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/neg.https.any.html?gpu | 16/16>17/18 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/neg.https.any.html?npu | 16/16>17/18 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/parallel-dispatch.https.any.serviceworker.html?cpu | 0/9>9/9 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/parallel-dispatch.https.any.serviceworker.html?gpu | 0/9>9/9 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/parallel-dispatch.https.any.serviceworker.html?npu | 0/9>9/9 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/parallel-dispatch.https.any.sharedworker.html?cpu | 0/9>9/9 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/parallel-dispatch.https.any.sharedworker.html?gpu | 0/9>9/9 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/parallel-dispatch.https.any.sharedworker.html?npu | 0/9>9/9 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/qdq_subgraph.https.any.html?cpu | 4/5>5/5 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/qdq_subgraph.https.any.html?gpu | 4/5>5/5 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/qdq_subgraph.https.any.html?npu | 4/5>5/5 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/qdq_subgraph.https.any.serviceworker.html?cpu | 0/1>5/5 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/qdq_subgraph.https.any.serviceworker.html?gpu | 0/1>5/5 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/qdq_subgraph.https.any.serviceworker.html?npu | 0/1>5/5 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/qdq_subgraph.https.any.sharedworker.html?cpu | 0/1>5/5 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/qdq_subgraph.https.any.sharedworker.html?gpu | 0/1>5/5 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/qdq_subgraph.https.any.sharedworker.html?npu | 0/1>5/5 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/qdq_subgraph.https.any.worker.html?cpu | 4/5>5/5 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/qdq_subgraph.https.any.worker.html?gpu | 4/5>5/5 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/qdq_subgraph.https.any.worker.html?npu | 4/5>5/5 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/quantizeLinear.https.any.html?cpu | 6/15>7/15 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/quantizeLinear.https.any.html?gpu | 6/15>7/15 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/quantizeLinear.https.any.html?npu | 6/15>7/15 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/reshape.https.any.html?cpu | 32/33>33/33 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/reshape.https.any.html?gpu | 32/33>33/33 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/reshape.https.any.html?npu | 32/33>33/33 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/scalars.https.any.serviceworker.html?cpu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/scalars.https.any.serviceworker.html?gpu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/scalars.https.any.serviceworker.html?npu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/scalars.https.any.sharedworker.html?cpu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/scalars.https.any.sharedworker.html?gpu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/scalars.https.any.sharedworker.html?npu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/shared_arraybuffer_constant.https.any.serviceworker.html?cpu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/shared_arraybuffer_constant.https.any.serviceworker.html?gpu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/shared_arraybuffer_constant.https.any.serviceworker.html?npu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/conformance_tests/subgraph.https.any.serviceworker.html?cpu | 0/1>46/46 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/subgraph.https.any.serviceworker.html?gpu | 0/1>46/46 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/subgraph.https.any.serviceworker.html?npu | 0/1>46/46 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/subgraph.https.any.sharedworker.html?cpu | 0/1>46/46 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/subgraph.https.any.sharedworker.html?gpu | 0/1>46/46 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/subgraph.https.any.sharedworker.html?npu | 0/1>46/46 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/tensor.https.any.serviceworker.html?cpu | 0/2>33/33 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/tensor.https.any.serviceworker.html?gpu | 0/2>33/33 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/tensor.https.any.serviceworker.html?npu | 0/2>33/33 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/tensor.https.any.sharedworker.html?cpu | 0/2>32/32 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/tensor.https.any.sharedworker.html?gpu | 0/2>32/32 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/conformance_tests/tensor.https.any.sharedworker.html?npu | 0/2>32/32 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webnn/idlharness.https.any.serviceworker.html | 226/609>608/609 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/idlharness.https.any.sharedworker.html | 226/609>608/609 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/build-more-than-once.https.any.serviceworker.html?cpu | 0/8>8/8 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/build-more-than-once.https.any.serviceworker.html?gpu | 0/8>8/8 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/build-more-than-once.https.any.serviceworker.html?npu | 0/8>8/8 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/build-more-than-once.https.any.sharedworker.html?cpu | 0/8>8/8 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/build-more-than-once.https.any.sharedworker.html?gpu | 0/8>8/8 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/build-more-than-once.https.any.sharedworker.html?npu | 0/8>8/8 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant-changed-buffer.https.any.serviceworker.html?cpu | 0/4>4/4 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant-changed-buffer.https.any.serviceworker.html?gpu | 0/4>4/4 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant-changed-buffer.https.any.serviceworker.html?npu | 0/4>4/4 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant-changed-buffer.https.any.sharedworker.html?cpu | 0/4>4/4 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant-changed-buffer.https.any.sharedworker.html?gpu | 0/4>4/4 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant-changed-buffer.https.any.sharedworker.html?npu | 0/4>4/4 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant.https.any.html?cpu | 24/25>25/25 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant.https.any.html?gpu | 24/25>25/25 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant.https.any.html?npu | 24/25>25/25 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant.https.any.serviceworker.html?cpu | 0/25>25/25 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant.https.any.serviceworker.html?gpu | 0/25>25/25 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant.https.any.serviceworker.html?npu | 0/25>25/25 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant.https.any.sharedworker.html?cpu | 0/25>25/25 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant.https.any.sharedworker.html?gpu | 0/25>25/25 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant.https.any.sharedworker.html?npu | 0/25>25/25 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant.https.any.worker.html?cpu | 24/25>25/25 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant.https.any.worker.html?gpu | 24/25>25/25 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/constant.https.any.worker.html?npu | 24/25>25/25 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/createContext.https.any.serviceworker.html?cpu | 1/10>10/10 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/createContext.https.any.serviceworker.html?gpu | 1/10>10/10 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/createContext.https.any.serviceworker.html?npu | 1/10>10/10 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/createContext.https.any.sharedworker.html?cpu | 1/10>10/10 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/createContext.https.any.sharedworker.html?gpu | 1/10>10/10 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/createContext.https.any.sharedworker.html?npu | 1/10>10/10 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/destroyContext.https.any.serviceworker.html?cpu | 0/11>11/11 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/destroyContext.https.any.serviceworker.html?gpu | 0/11>11/11 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/destroyContext.https.any.serviceworker.html?npu | 0/11>11/11 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/destroyContext.https.any.sharedworker.html?cpu | 0/11>11/11 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/destroyContext.https.any.sharedworker.html?gpu | 0/11>11/11 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/destroyContext.https.any.sharedworker.html?npu | 0/11>11/11 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/destroyGraph.https.any.serviceworker.html?cpu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/destroyGraph.https.any.serviceworker.html?gpu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/destroyGraph.https.any.serviceworker.html?npu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/destroyGraph.https.any.sharedworker.html?cpu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/destroyGraph.https.any.sharedworker.html?gpu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/destroyGraph.https.any.sharedworker.html?npu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/input.https.any.serviceworker.html?cpu | 0/9>9/9 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/input.https.any.serviceworker.html?gpu | 0/9>9/9 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/input.https.any.serviceworker.html?npu | 0/9>9/9 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/input.https.any.sharedworker.html?cpu | 0/9>9/9 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/input.https.any.sharedworker.html?gpu | 0/9>9/9 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/input.https.any.sharedworker.html?npu | 0/9>9/9 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/invalid-rank.https.any.serviceworker.html?cpu | 0/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/invalid-rank.https.any.serviceworker.html?gpu | 0/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/invalid-rank.https.any.serviceworker.html?npu | 0/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/invalid-rank.https.any.sharedworker.html?cpu | 0/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/invalid-rank.https.any.sharedworker.html?gpu | 0/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/invalid-rank.https.any.sharedworker.html?npu | 0/2>2/2 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/pooling-and-reduction-keep-dims.https.any.serviceworker.html?cpu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/pooling-and-reduction-keep-dims.https.any.serviceworker.html?gpu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/pooling-and-reduction-keep-dims.https.any.serviceworker.html?npu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/pooling-and-reduction-keep-dims.https.any.sharedworker.html?cpu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/pooling-and-reduction-keep-dims.https.any.sharedworker.html?gpu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/pooling-and-reduction-keep-dims.https.any.sharedworker.html?npu | 0/3>3/3 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/unprintableNames.https.any.serviceworker.html?cpu | 0/1>1/1 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/unprintableNames.https.any.serviceworker.html?gpu | 0/1>1/1 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/unprintableNames.https.any.serviceworker.html?npu | 0/1>1/1 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/unprintableNames.https.any.sharedworker.html?cpu | 0/1>1/1 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/unprintableNames.https.any.sharedworker.html?gpu | 0/1>1/1 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webnn/validation_tests/unprintableNames.https.any.sharedworker.html?npu | 0/1>1/1 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webrtc-stats/getStats-remote-candidate-ufrag.html | 0/1>1/1 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webrtc/RTCConfiguration-iceServers.html | 51/55>54/58 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webrtc/RTCDataChannel-close.html | 10/12>11/12 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webrtc/RTCIceTransport.html | 9/17>10/17 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| webrtc/RTCPeerConnection-addTransceiver.https.html | 12/12>18/20 | d | prueba WPT cambiada entre las dos revisiones (totales distintos) | S |
| webrtc/RTCRtpReceiver-video-jitterBufferTarget-stats.html | 0/1>1/1 | d | entorno/hardware/codec/driver/permiso de Linux o prueba con ajuste de WPT; fuera del motor de maquetacion | S |
| xhr/progressevent-constructor.html | 7/10>10/10 | c | 5ad24b5ad Change loaded and total attributes in ProgressEvent to double | S |

## Regresiones 135 a 136 (sin analizar a fondo)

| prueba | subpruebas pass 135>136 | clase | nota | V/S |
|---|---|---|---|---|
| client-hints/viewport-size/viewport-size-subresource.https.html | 1/1>0/1 | d | variacion pequena/arnes | S |
| css/css-break/transform-024-print.html | P>F | d | PageMarginBoxes: flag retirada (ya estaba stable); P>F en pruebas print = arnes de impresion de Linux | S |
| css/css-easing/linear-timing-functions-syntax.html | 23/35>22/35 | d | variacion pequena/arnes | S |
| css/css-easing/step-timing-functions-syntax.html | 13/15>12/15 | d | variacion pequena/arnes | S |
| css/css-fonts/variations/font-weight-interpolation.html | 2/2>1/2 | d | variacion pequena/arnes | S |
| css/css-page/margin-boxes/alignment-001-print.html | P>F | d | PageMarginBoxes: flag retirada (ya estaba stable); P>F en pruebas print = arnes de impresion de Linux | S |
| css/css-page/margin-boxes/background-001-print.html | P>F | d | PageMarginBoxes: flag retirada (ya estaba stable); P>F en pruebas print = arnes de impresion de Linux | S |
| css/css-page/margin-boxes/content-004-print.html | P>F | d | PageMarginBoxes: flag retirada (ya estaba stable); P>F en pruebas print = arnes de impresion de Linux | S |
| css/css-page/margin-boxes/content-005-print.html | P>F | d | PageMarginBoxes: flag retirada (ya estaba stable); P>F en pruebas print = arnes de impresion de Linux | S |
| css/css-page/margin-boxes/content-006-print.html | P>F | d | PageMarginBoxes: flag retirada (ya estaba stable); P>F en pruebas print = arnes de impresion de Linux | S |
| css/css-page/margin-boxes/content-007-print.html | P>F | d | PageMarginBoxes: flag retirada (ya estaba stable); P>F en pruebas print = arnes de impresion de Linux | S |
| css/css-page/margin-boxes/content-008-print.html | P>F | d | PageMarginBoxes: flag retirada (ya estaba stable); P>F en pruebas print = arnes de impresion de Linux | S |
| css/css-page/margin-boxes/content-009-print.html | P>F | d | PageMarginBoxes: flag retirada (ya estaba stable); P>F en pruebas print = arnes de impresion de Linux | S |
| css/css-page/page-background-005-print.html | P>F | d | PageMarginBoxes: flag retirada (ya estaba stable); P>F en pruebas print = arnes de impresion de Linux | S |
| css/css-page/page-box-008-print.html | P>F | d | PageMarginBoxes: flag retirada (ya estaba stable); P>F en pruebas print = arnes de impresion de Linux | S |
| css/css-page/page-box-009-print.html | P>F | d | PageMarginBoxes: flag retirada (ya estaba stable); P>F en pruebas print = arnes de impresion de Linux | S |
| css/css-page/page-size-010-print.html | P>F | d | PageMarginBoxes: flag retirada (ya estaba stable); P>F en pruebas print = arnes de impresion de Linux | S |
| css/css-pseudo/highlight-painting-004.html | P>F | d | variacion pequena/arnes | S |
| css/css-pseudo/selection-contenteditable-011.html | P>F | d | variacion pequena/arnes | S |
| css/css-sizing/contain-intrinsic-size/animation/contain-intrinsic-size-interpolation.html | 432/432>344/432 | c? | interpolaciones de contain-intrinsic-size/calc-size: bajan muchas subpruebas; probable timeout o cambio, revisar | S |
| css/css-sizing/intrinsic-percent-non-replaced-001.html | P>F | d | variacion pequena/arnes | S |
| css/css-sizing/intrinsic-percent-non-replaced-004.html | P>F | d | variacion pequena/arnes | S |
| css/css-values/animations/line-height-lh-transition.html | 1/1>0/1 | d | variacion pequena/arnes | S |
| css/css-values/calc-min-height-block-1.html | P>F | d | variacion pequena/arnes | S |
| css/css-values/calc-min-width-block-intrinsic-1.html | P>F | d | variacion pequena/arnes | S |
| css/css-values/calc-size/animation/calc-size-width-interpolation.html | 656/842>462/842 | c? | interpolaciones de contain-intrinsic-size/calc-size: bajan muchas subpruebas; probable timeout o cambio, revisar | S |
| css/css-view-transitions/event-pseudo-name.html | 1/1>0/1 | c? | regresion P>T/1>0 de view transitions; candidato 32888ea7e Nested VT: Disable ViewTransitionCaptureAndDisplay | S |
| css/css-view-transitions/mix-blend-mode-only-on-transition.html | 1/1>0/1 | c? | regresion P>T/1>0 de view transitions; candidato 32888ea7e Nested VT: Disable ViewTransitionCaptureAndDisplay | S |
| css/css-view-transitions/navigation/opt-in-removed-during-transition.html | P>T | c? | regresion P>T/1>0 de view transitions; candidato 32888ea7e Nested VT: Disable ViewTransitionCaptureAndDisplay | S |
| css/css-view-transitions/navigation/pagereveal-setup-transition.html | P>T | c? | regresion P>T/1>0 de view transitions; candidato 32888ea7e Nested VT: Disable ViewTransitionCaptureAndDisplay | S |
| css/css-view-transitions/navigation/pageswap-fired-before-old-state-capture.html | P>T | c? | regresion P>T/1>0 de view transitions; candidato 32888ea7e Nested VT: Disable ViewTransitionCaptureAndDisplay | S |
| css/css-view-transitions/navigation/prerender-removed-during-navigation.html | P>T | c? | regresion P>T/1>0 de view transitions; candidato 32888ea7e Nested VT: Disable ViewTransitionCaptureAndDisplay | S |
| css/css-view-transitions/navigation/reload-crash.html | P>T | c? | regresion P>T/1>0 de view transitions; candidato 32888ea7e Nested VT: Disable ViewTransitionCaptureAndDisplay | S |
| css/css-view-transitions/navigation/root-element-transition.html | P>T | c? | regresion P>T/1>0 de view transitions; candidato 32888ea7e Nested VT: Disable ViewTransitionCaptureAndDisplay | S |
| css/css-view-transitions/only-child-group.html | 4/4>0/4 | c? | regresion P>T/1>0 de view transitions; candidato 32888ea7e Nested VT: Disable ViewTransitionCaptureAndDisplay | S |
| css/css-view-transitions/unset-and-initial-view-transition-name.html | 1/1>0/1 | c? | regresion P>T/1>0 de view transitions; candidato 32888ea7e Nested VT: Disable ViewTransitionCaptureAndDisplay | S |
| css/filter-effects/blur-text.html | P>F | d | variacion pequena/arnes | S |
| css/selectors/dir-style-04.html | P>F | d | variacion pequena/arnes | S |
| fs/FileSystemFileHandle-cross-primitive-locking.https.tentative.worker.html | 66/90>64/90 | d | variacion pequena/arnes | S |
| html/browsers/browsing-the-web/history-traversal/event-order/before-load-hash-twice.html | 1/1>0/1 | d | variacion pequena/arnes | S |
| html/browsers/the-window-object/open-close/open-features-non-integer-left.html | 7/12>6/12 | c? | window.open features: regresion; probable relacionada con open features fix | S |
| html/browsers/the-window-object/open-close/open-features-non-integer-screeny.html | 11/12>5/12 | c? | window.open features: regresion; probable relacionada con open features fix | S |
| html/browsers/the-window-object/open-close/open-features-non-integer-top.html | 9/12>3/12 | c? | window.open features: regresion; probable relacionada con open features fix | S |
| html/browsers/the-window-object/open-close/open-features-tokenization-screenx-screeny.html | 7/14>2/14 | c? | window.open features: regresion; probable relacionada con open features fix | S |
| html/browsers/the-window-object/open-close/open-features-tokenization-top-left.html | 10/16>2/16 | c? | window.open features: regresion; probable relacionada con open features fix | S |
| html/cross-origin-opener-policy/iframe-popup-same-origin-allow-popups-to-same-origin.https.html?9-last | 3/3>C | d | C (crash/timeout de arnes) en lote | S |
| html/cross-origin-opener-policy/iframe-popup-same-origin-to-same-origin.https.html?1-2 | 6/6>C | d | C (crash/timeout de arnes) en lote | S |
| html/cross-origin-opener-policy/iframe-popup-same-origin-to-same-origin.https.html?7-8 | 6/6>C | d | C (crash/timeout de arnes) en lote | S |
| html/cross-origin-opener-policy/iframe-popup-same-origin-to-unsafe-none.https.html?3-4 | 6/6>C | d | C (crash/timeout de arnes) en lote | S |
| html/cross-origin-opener-policy/iframe-popup-same-origin-to-unsafe-none.https.html?9-last | 3/3>C | d | C (crash/timeout de arnes) en lote | S |
| html/cross-origin-opener-policy/iframe-popup-unsafe-none-to-same-origin.https.html?1-2 | 6/6>C | d | C (crash/timeout de arnes) en lote | S |
| html/cross-origin-opener-policy/iframe-popup-unsafe-none-to-same-origin.https.html?3-4 | 6/6>C | d | C (crash/timeout de arnes) en lote | S |
| html/cross-origin-opener-policy/javascript-url.https.html?1-2 | 2/2>C | d | C (crash/timeout de arnes) en lote | S |
| html/semantics/embedded-content/bfcache/embedded-mp4.html | 2/2>1/2 | d | variacion pequena/arnes | S |
| html/semantics/embedded-content/the-iframe-element/iframe-loading-lazy-nav-meta-refresh.optional.html | 1/1>0/1 | d | variacion pequena/arnes | S |
| html/semantics/embedded-content/the-object-element/object-attributes.html | 4/4>3/4 | d | variacion pequena/arnes | S |
| mathml/presentation-markup/operators/operator-dictionary-arabic-002.html | P>F | d | variacion pequena/arnes | S |
| media-source/dedicated-worker/mediasource-worker-play-terminate-worker.html | 20/30>13/30 | d | variacion pequena/arnes | S |
| mixed-content/gen/top.http-rp/opt-in/sharedworker-import.https.html | 10/10>8/10 | d | variacion pequena/arnes | S |
| old-tests/submission/Microsoft/history/history_000.htm | 25/25>24/25 | d | variacion pequena/arnes | S |
| scroll-animations/scroll-timelines/animation-with-transform.html | P>F | d | variacion pequena/arnes | S |
| scroll-animations/scroll-timelines/two-animations-attach-to-same-scroll-timeline-cancel-one.html | P>F | d | variacion pequena/arnes | S |
| scroll-animations/scroll-timelines/two-animations-attach-to-same-scroll-timeline.html | P>F | d | variacion pequena/arnes | S |
| service-workers/cache-storage/cache-add.https.any.sharedworker.html | 21/22>20/22 | d | variacion pequena/arnes | S |
| service-workers/service-worker/getregistrations.https.html | 6/6>3/6 | d | variacion pequena/arnes | S |
| speculation-rules/prerender/clients-matchall.https.html | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| speculation-rules/prerender/cross-origin-isolated.https.html?target_hint=_blank | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| speculation-rules/prerender/cross-origin-isolated.https.html?target_hint=_self | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| speculation-rules/prerender/csp-script-src-self.https.html?target_hint=_self | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| speculation-rules/prerender/fetch-intercepted-by-service-worker.https.html | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| speculation-rules/prerender/navigation-intercepted-by-service-worker.https.html | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| speculation-rules/prerender/navigator-plugins.https.html | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| speculation-rules/prerender/referrer-policy-no-referrer.https.html | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| speculation-rules/prerender/referrer-policy-origin.https.html | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| speculation-rules/prerender/referrer-policy-strict-origin.https.html | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| speculation-rules/prerender/referrer.https.html | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| speculation-rules/prerender/restriction-idle-detection.https.html | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| speculation-rules/prerender/restriction-local-file-system-access.https.html | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| speculation-rules/prerender/restriction-presentation-request.https.html | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| speculation-rules/prerender/restriction-prompt-by-before-unload.https.html | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| speculation-rules/prerender/restriction-request-picture-in-picture.https.html | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| speculation-rules/prerender/windowclient-navigate.https.html | 1/1>0/1 | d | prerender: cambios de WPT/arnes (1>0 en lote); revisar solo si FlyWeb usa prerender | S |
| upgrade-insecure-requests/gen/iframe-blank-inherit.meta/unset/sharedworker-import-data.https.html | 6/6>1/6 | d | variacion pequena/arnes | S |
| web-animations/timing-model/timelines/timelines.html | 5/5>4/5 | d | variacion pequena/arnes | S |
| webaudio/the-audio-api/the-mediaelementaudiosourcenode-interface/mediaElementAudioSourceToScriptProcessorTest.html | 3/3>2/3 | d | variacion pequena/arnes | S |
| webvtt/rendering/cues-with-video/processing-model/audio_has_no_subtitles.html | P>F | d | variacion pequena/arnes | S |
