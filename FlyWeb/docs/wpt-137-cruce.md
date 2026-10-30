# Cruce wpt.fyi Chrome 136 vs 137 contra el nivel 137 de FlyWeb

Runs (Linux, wpt.fyi, product=chrome, label=stable): 136 = id 6486432581681152, 136.0.7103.113 (27-5-2025, wpt e1b27be06b); 137 = id 6307936223887360, 137.0.7151.55 (28-5-2025, wpt 3c6154fddc). Es el 136 estable mas tardio y el 137 mas temprano: un solo dia de deriva de WPT. Los siguientes 137 (.68, .70, .119) son de junio, con mas deriva. Solo difieren de 137.0.7151.55 las cherry-picks de seguridad posteriores.

Criterio: aciertos(137) > aciertos(136) por contadores del summary_v2 (c=[pass,total]); para prueba unica, estado no-PASS/OK a PASS/OK. Todo WPT (61 555 pruebas comunes).

Clases: a = cubierta por una funcion del 137 (flag que pasa a stable o lanzamiento por commit); b = aplazada/fuera (FLEDGE/Protected Audience, IA de Google, WebNN); c = falta sin flag con commit; c? = sin causa localizada; d = entorno/test cambiado.

Totales (mejoras): a=64, b=48, c=35, c?=27, d=36  (n=210); regresiones: 464

Fuentes de atribucion: diff de `runtime_enabled_features.json5` entre cr136 y cr137 (flags que pasan a stable) y `log136-137.txt` (14 720 commits, asuntos; cubre sobre todo 1-30 abril de main y las cherry-picks [M137] de mayo-junio). No se miraron los -expected.txt: las atribuciones c son por asunto de commit, no verificadas. Las 464 regresiones (mucho mas que en el 136) son sobre todo deriva de WPT y arnes; no se analizaron.

## Mejoras 136 a 137

| prueba | subpruebas pass 136>137 | clase | funcion / commit / flag | V/S |
|---|---|---|---|---|
| FileAPI/BlobURL/cross-partition-navigation.https.html | 0/4>4/4 | a | Blob URL partitioning (9aae7ac7f [M137] Launch Blob URL partitioning) | S |
| FileAPI/BlobURL/cross-partition-worker-creation.https.html | 0/2>2/2 | a | Blob URL partitioning (9aae7ac7f [M137] Launch Blob URL partitioning) | S |
| FileAPI/BlobURL/cross-partition.https.html | 4/8>8/8 | a | Blob URL partitioning (9aae7ac7f [M137] Launch Blob URL partitioning) | S |
| WebCryptoAPI/generateKey/failures_Ed25519.https.any.html | 360/386>386/386 | a | WebCryptoEd25519 -> stable (e1b1cfbcc Ship the Ed25519 WebCrypto agorithm) | S |
| WebCryptoAPI/generateKey/failures_Ed25519.https.any.worker.html | 360/386>386/386 | a | WebCryptoEd25519 -> stable (e1b1cfbcc Ship the Ed25519 WebCrypto agorithm) | S |
| WebCryptoAPI/generateKey/successes_Ed25519.https.any.html | 0/18>18/18 | a | WebCryptoEd25519 -> stable (e1b1cfbcc Ship the Ed25519 WebCrypto agorithm) | S |
| WebCryptoAPI/generateKey/successes_Ed25519.https.any.worker.html | 0/18>18/18 | a | WebCryptoEd25519 -> stable (e1b1cfbcc Ship the Ed25519 WebCrypto agorithm) | S |
| WebCryptoAPI/import_export/okp_importKey_Ed25519.https.any.html | 0/72>72/72 | a | WebCryptoEd25519 -> stable (e1b1cfbcc Ship the Ed25519 WebCrypto agorithm) | S |
| WebCryptoAPI/import_export/okp_importKey_Ed25519.https.any.worker.html | 0/72>72/72 | a | WebCryptoEd25519 -> stable (e1b1cfbcc Ship the Ed25519 WebCrypto agorithm) | S |
| WebCryptoAPI/import_export/okp_importKey_failures_Ed25519.https.any.html | 10/270>270/270 | a | WebCryptoEd25519 -> stable (e1b1cfbcc Ship the Ed25519 WebCrypto agorithm) | S |
| WebCryptoAPI/import_export/okp_importKey_failures_Ed25519.https.any.worker.html | 10/270>270/270 | a | WebCryptoEd25519 -> stable (e1b1cfbcc Ship the Ed25519 WebCrypto agorithm) | S |
| WebCryptoAPI/sign_verify/eddsa_curve25519.https.any.html | 0/13>13/13 | a | WebCryptoEd25519 -> stable (e1b1cfbcc Ship the Ed25519 WebCrypto agorithm) | S |
| WebCryptoAPI/sign_verify/eddsa_curve25519.https.any.worker.html | 0/13>13/13 | a | WebCryptoEd25519 -> stable (e1b1cfbcc Ship the Ed25519 WebCrypto agorithm) | S |
| WebCryptoAPI/sign_verify/eddsa_small_order_points.https.any.html | 0/14>8/14 | a | WebCryptoEd25519 -> stable (e1b1cfbcc Ship the Ed25519 WebCrypto agorithm) | S |
| WebCryptoAPI/sign_verify/eddsa_small_order_points.https.any.worker.html | 0/14>8/14 | a | WebCryptoEd25519 -> stable (e1b1cfbcc Ship the Ed25519 WebCrypto agorithm) | S |
| WebCryptoAPI/wrapKey_unwrapKey/wrapKey_unwrapKey.https.any.html | 269/269>299/299 | a | WebCryptoEd25519 -> stable (e1b1cfbcc Ship the Ed25519 WebCrypto agorithm) | S |
| WebCryptoAPI/wrapKey_unwrapKey/wrapKey_unwrapKey.https.any.worker.html | 269/269>299/299 | a | WebCryptoEd25519 -> stable (e1b1cfbcc Ship the Ed25519 WebCrypto agorithm) | S |
| ai/language_detection/detector-iframe.https.html | 0/6>1/6 | b | APIs de IA de Google (fuera) | S |
| content-security-policy/gen/top.http-rp/script-src-self/sharedworker-import.http.html | 6/12>8/12 | c | 58e06f599 [M137] Fix broken plumbing in SharedWorkerHost creation (por asunto) | S |
| content-security-policy/gen/top.http-rp/worker-src-self/sharedworker-import.http.html | 6/12>8/12 | c | 58e06f599 [M137] Fix broken plumbing in SharedWorkerHost creation (por asunto) | S |
| content-security-policy/gen/top.http-rp/worker-src-self/sharedworker-import.https.html | 4/12>8/12 | c | 58e06f599 [M137] Fix broken plumbing in SharedWorkerHost creation (por asunto) | S |
| cookie-store/change_eventhandler_for_document_cookie.https.window.html | 5/6>6/6 | c? | sin commit localizado | S |
| cookie-store/change_eventhandler_for_http_cookie_and_set_cookie_headers.https.window.html | 6/7>7/7 | c? | sin commit localizado | S |
| cookie-store/change_eventhandler_for_no_change.https.window.html | 0/2>2/2 | c? | sin commit localizado | S |
| cookie-store/encoding.https.any.html | 0/2>2/2 | c? | sin commit localizado | S |
| cookie-store/encoding.https.any.serviceworker.html | 0/2>2/2 | c? | sin commit localizado | S |
| cookie-store/serviceworker_cookiechange_eventhandler_no_change.https.any.serviceworker.html | 0/2>2/2 | c? | sin commit localizado | S |
| css/CSS2/linebox/animations/line-height-interpolation.html | 616/628>628/628 | c? | sin commit localizado | S |
| css/css-anchor-position/anchor-parse-valid.html | 2355/2356>2356/2356 | c | c832b551d Replace calc() division nodes with Invert nodes (+ fb4a7683f Convert 1 * x -> x, 9983d9c9f Sort product nodes; por asunto) | S |
| css/css-anchor-position/anchor-size-parse-valid.html | 4297/4300>4300/4300 | c | c832b551d Replace calc() division nodes with Invert nodes (+ fb4a7683f Convert 1 * x -> x, 9983d9c9f Sort product nodes; por asunto) | S |
| css/css-anchor-position/remove-position-try-rules-001.html | C>O | c | 69b4d66dc [anchor] Don't use a deleted fallback rule | S |
| css/css-animations/parsing/keyframe-selectors.html | 12/14>14/14 | c | 69e2e4a30 Disallow calc() in named timeline range keyframe selectors | S |
| css/css-cascade/all-prop-initial-xml.html | 395/395>396/396 | c? | sin commit localizado | S |
| css/css-color/parsing/color-valid-relative-color.html | 1062/1077>1077/1077 | c? | sin commit localizado | S |
| css/css-display/reading-flow/tentative/reading-order-computed.html | 0/4>4/4 | a | CSSReadingFlow/CSSReadingOrder -> stable (c67d9fab7) | S |
| css/css-display/reading-flow/tentative/reading-order-valid.html | 0/4>4/4 | a | CSSReadingFlow/CSSReadingOrder -> stable (c67d9fab7) | S |
| css/css-easing/linear-timing-functions-syntax.html | 22/35>23/35 | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |
| css/css-easing/step-timing-functions-syntax.html | 12/15>13/15 | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |
| css/css-fonts/font-variation-settings-calc.html | 1/8>2/8 | c | 59d393acd Support sibling-index() and sign() for font-variation-settings | S |
| css/css-fonts/variations/font-style-interpolation.html | 1/2>2/2 | c? | sin commit localizado | S |
| css/css-masking/animations/clip-path-interpolation-shape.html | 668/668>692/692 | a | CSSShapeFunctionOffsetPath/CompositeAnimation -> stable (96d9ccc8d Ship offset-path: shape()) | S |
| css/css-nesting/cssom.html | 12/14>13/14 | c? | sin commit localizado | S |
| css/css-overflow/root-scroll-marker-activation-in-iframe.html | T>O | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |
| css/css-syntax/serialize-consecutive-tokens.html | 69/71>71/71 | c? | sin commit localizado | S |
| css/css-typed-om/stylevalue-serialization/cssTransformValue.tentative.html | 20/22>22/22 | c | c832b551d Replace calc() division nodes with Invert nodes (+ fb4a7683f Convert 1 * x -> x, 9983d9c9f Sort product nodes; por asunto) | S |
| css/css-values/attr-security.html | 30/38>34/38 | a | CSSInlineIfFor{Media,Style,Supports}Queries -> stable (a10210e9b Switch CSS if() flags to stable) | S |
| css/css-values/calc-infinity-nan-serialize-length.html | 39/41>40/41 | c | c832b551d Replace calc() division nodes with Invert nodes (+ fb4a7683f Convert 1 * x -> x, 9983d9c9f Sort product nodes; por asunto) | S |
| css/css-values/calc-serialization-002.html | 23/24>24/24 | c | c832b551d Replace calc() division nodes with Invert nodes (+ fb4a7683f Convert 1 * x -> x, 9983d9c9f Sort product nodes; por asunto) | S |
| css/css-values/calc-size/animation/calc-size-interpolation-expansion.html | 5/11>10/11 | c | 10da5d634 Simplify calc-size() interpolations more aggressively | S |
| css/css-values/calc-size/animation/interpolate-size-max-height-interpolation.html | 180/282>240/282 | c | 10da5d634 Simplify calc-size() interpolations more aggressively | S |
| css/css-values/calc-size/animation/interpolate-size-min-width-interpolation.html | 132/228>204/228 | c | 10da5d634 Simplify calc-size() interpolations more aggressively | S |
| css/css-values/calc-size/calc-size-parsing.html | 89/94>93/94 | c | c832b551d Replace calc() division nodes with Invert nodes (+ fb4a7683f Convert 1 * x -> x, 9983d9c9f Sort product nodes; por asunto) | S |
| css/css-values/calc-size/calc-size-typed-om.html | 13/19>17/19 | c | c832b551d Replace calc() division nodes with Invert nodes (+ fb4a7683f Convert 1 * x -> x, 9983d9c9f Sort product nodes; por asunto) | S |
| css/css-values/if-conditionals.html | 0/189>160/189 | a | CSSInlineIfFor{Media,Style,Supports}Queries -> stable (a10210e9b Switch CSS if() flags to stable) | S |
| css/css-values/if-cycle.html | 10/46>45/46 | a | CSSInlineIfFor{Media,Style,Supports}Queries -> stable (a10210e9b Switch CSS if() flags to stable) | S |
| css/css-values/minmax-length-percent-serialize.html | 55/57>57/57 | c | c832b551d Replace calc() division nodes with Invert nodes (+ fb4a7683f Convert 1 * x -> x, 9983d9c9f Sort product nodes; por asunto) | S |
| css/css-values/minmax-length-serialize.html | 23/24>24/24 | c | c832b551d Replace calc() division nodes with Invert nodes (+ fb4a7683f Convert 1 * x -> x, 9983d9c9f Sort product nodes; por asunto) | S |
| css/css-view-transitions/dynamic-stylesheet-animations-timing-function.html | 0/3>3/3 | c? | sin commit localizado | S |
| css/css-view-transitions/hit-test-pseudo-element-element-from-point.html | T>O | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |
| css/css-view-transitions/only-child-group.html | 0/4>4/4 | c | cbed85934 VT: Add cleanup to only-child-group.html (por asunto) | S |
| css/css-view-transitions/parsing/view-transition-name-valid.html | 4/6>5/6 | a | CSSViewTransitionMatchElement -> stable (26f116090) | S |
| css/css-view-transitions/ready_resolves_after_dom_before_raf.html | T>O | a | ViewTransitionUpdateLifecycleBeforeReady -> stable | S |
| css/motion/animation/offset-path-interpolation-008.html | 0/614>614/614 | a | CSSShapeFunctionOffsetPath/CompositeAnimation -> stable (96d9ccc8d Ship offset-path: shape()) | S |
| css/motion/parsing/offset-path-shape-computed.html | 0/12>11/12 | a | CSSShapeFunctionOffsetPath/CompositeAnimation -> stable (96d9ccc8d Ship offset-path: shape()) | S |
| css/motion/parsing/offset-path-shape-parsing.html | 15/35>33/35 | a | CSSShapeFunctionOffsetPath/CompositeAnimation -> stable (96d9ccc8d Ship offset-path: shape()) | S |
| css/selectors/open-pseudo.html | 2/3>3/3 | c | 5a687a31d Fix dynamic change handling for :open on <details> | S |
| dom/observable/tentative/observable-from.any.html | 45/48>46/48 | c | 5f8643cf1 DOM: Fix Observable iterator `return()` method handling | S |
| dom/observable/tentative/observable-from.any.worker.html | 45/48>46/48 | c | 5f8643cf1 DOM: Fix Observable iterator `return()` method handling | S |
| domparsing/xml-parse-serialize-roundtrip.html | 1/2>2/2 | c | 18ba67e97 Consistently match default namespace declaration during serialization (flag vuelto a test en M137 por 16397892b: dudoso) | S |
| editing/other/insert-space-at-beginning-of-wrapped-line.html | 6/12>11/12 | c? | sin commit localizado | S |
| encrypted-media/idlharness.https.html | 92/93>93/93 | c? | sin commit localizado | S |
| fedcm/fedcm-button-and-other-account/fedcm-use-other-account-button-flow.tentative.https.html | 0/2>2/2 | c? | sin commit localizado | S |
| fetch/api/basic/keepalive.any.html | 11/14>12/14 | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |
| fledge/tentative/abort.https.window.html | 0/4>2/4 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/additional-bids.https.window.html?1-last | 7/19>8/19 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/auction-config.https.window.html?1-5 | 0/5>5/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/auction-config.https.window.html?11-15 | 0/5>2/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/auction-config.https.window.html?16-20 | 0/5>4/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/auction-config.https.window.html?21-25 | 0/5>4/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/auction-config.https.window.html?26-30 | 0/5>4/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/auction-config.https.window.html?31-35 | 0/5>5/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/auction-config.https.window.html?36-40 | 0/5>5/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/auction-config.https.window.html?40-45 | 0/6>6/6 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/auction-config.https.window.html?46-50 | 0/5>5/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/auction-config.https.window.html?51-55 | 0/5>5/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/auction-config.https.window.html?56-60 | 0/5>4/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/auction-config.https.window.html?6-10 | 0/5>4/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/clear-origin-joined-ad-interest-groups.https.window.html?13-last | 0/2>1/2 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/clear-origin-joined-ad-interest-groups.https.window.html?5-8 | 0/4>1/4 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/component-ads.https.window.html?1-5 | 0/5>1/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/component-ads.https.window.html?16-last | 0/9>2/9 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/component-ads.https.window.html?6-10 | 0/5>3/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/component-auction.https.window.html?1-5 | 0/5>5/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/component-auction.https.window.html?16-last | 0/5>1/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/component-auction.https.window.html?6-10 | 0/5>2/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/currency.https.window.html?1-4 | 0/4>1/4 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/currency.https.window.html?17-20 | 0/4>2/4 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/currency.https.window.html?21-24 | 0/4>3/4 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/currency.https.window.html?25-28 | 0/4>1/4 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/currency.https.window.html?33-last | 0/3>1/3 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/currency.https.window.html?5-8 | 0/4>2/4 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/get-interest-group-auction-data.https.window.html?17-last | 0/9>6/9 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/join-leave-ad-interest-group.https.window.html?71-80 | 7/10>8/10 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/join-leave-ad-interest-group.https.window.html?81-last | 0/3>2/3 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/network.https.window.html?1-5 | 0/5>3/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/network.https.window.html?6-10 | 0/5>3/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/no-winner.https.window.html?1-5 | 0/5>5/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/no-winner.https.window.html?11-15 | 0/5>5/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/no-winner.https.window.html?16-20 | 0/5>5/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/no-winner.https.window.html?21-25 | 0/5>5/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/no-winner.https.window.html?26-30 | 0/5>5/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/no-winner.https.window.html?31-35 | 0/5>5/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/no-winner.https.window.html?36-40 | 0/5>5/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/no-winner.https.window.html?41-45 | 0/5>5/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/no-winner.https.window.html?46-last | 0/2>2/2 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/no-winner.https.window.html?6-10 | 0/5>5/5 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| fledge/tentative/reporting-ids.https.window.html?6-last | 0/6>2/6 | b | Protected Audience/FLEDGE (privacy sandbox, fuera); acc9c29ce FledgeBiddingAndAuctionServerAPIMultiSeller | S |
| geolocation/enabled-by-permission-policy-attribute-redirect-on-load.https.sub.html | 0/2>1/2 | d | arnes/webdriver/emulacion de Linux (779194081 Extend Emulation.setGeolocationOverride es del lado del driver) | S |
| geolocation/getCurrentPosition-error.https.html | E>O | d | arnes/webdriver/emulacion de Linux (779194081 Extend Emulation.setGeolocationOverride es del lado del driver) | S |
| geolocation/getCurrentPosition-success.https.html | E>O | d | arnes/webdriver/emulacion de Linux (779194081 Extend Emulation.setGeolocationOverride es del lado del driver) | S |
| html/browsers/the-window-object/open-close/open-features-tokenization-screenx-screeny.html | 0/14>2/14 | c? | sin commit localizado | S |
| html/canvas/element/manual/context-attributes/getContextAttributes.html | 8/11>11/11 | a | CanvasFloatingPoint + ImageDataPixelFormat -> stable (0d364e3a8 Enable canvas floating point feature by default) | S |
| html/canvas/offscreen/manual/context-attributes/getContextAttributes.html | 8/11>11/11 | a | CanvasFloatingPoint + ImageDataPixelFormat -> stable (0d364e3a8 Enable canvas floating point feature by default) | S |
| html/cross-origin-opener-policy/iframe-popup-same-origin-allow-popups-to-same-origin.https.html?3-4 | 0/0>6/6 | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |
| html/cross-origin-opener-policy/iframe-popup-same-origin-to-same-origin.https.html?3-4 | 0/0>6/6 | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |
| html/cross-origin-opener-policy/iframe-popup-unsafe-none-to-same-origin.https.html?1-2 | 0/0>6/6 | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |
| html/cross-origin-opener-policy/iframe-popup-unsafe-none-to-same-origin.https.html?7-8 | 0/0>6/6 | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |
| html/cross-origin-opener-policy/iframe-popup-unsafe-none-to-unsafe-none.https.html?1-2 | 0/0>6/6 | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |
| html/cross-origin-opener-policy/popup-same-origin-allow-popups-with-same-origin.https.html | 0/0>8/8 | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |
| html/document-isolation-policy/credentialless-cache-storage-from-credentialless.https.tentative.window.html?dedicated_worker | 3/4>4/4 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/credentialless-cache-storage-from-credentialless.https.tentative.window.html?document | 3/4>4/4 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/credentialless-cache-storage-from-credentialless.https.tentative.window.html?service_worker | 3/4>4/4 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/credentialless-cache-storage-from-none.https.tentative.window.html?dedicated_worker | 4/7>7/7 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/credentialless-cache-storage-from-none.https.tentative.window.html?document | 4/7>7/7 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/credentialless-cache-storage-from-none.https.tentative.window.html?service_worker | 4/7>7/7 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/credentialless-cross-origin-isolated.tentative.window.html | 2/4>4/4 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/credentialless-dedicated-worker.https.tentative.window.html | 4/5>5/5 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/credentialless-fetch.https.tentative.window.html | 12/13>13/13 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/credentialless-link.https.tentative.window.html | 6/7>7/7 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/credentialless-redirect.tentative.window.html | 2/5>5/5 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/credentialless-script.https.tentative.window.html | 6/7>7/7 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/credentialless-video.https.tentative.window.html | 5/6>6/6 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/isolate-and-require-corp-load-from-cache-storage.tentative.https.html | 27/29>29/29 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/isolate-and-require-corp.tentative.https.html | 1/2>2/2 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/reporting-cache-storage-corp.tentative.https.html | 1/12>12/12 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/reporting-subresource-corp.tentative.https.html | 1/12>12/12 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/document-isolation-policy/shared-workers.tentative.https.html | 5/8>7/8 | a | DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop) | S |
| html/dom/idlharness.any.worker.html | 768/779>769/779 | c? | sin commit localizado | S |
| html/dom/idlharness.https.html?exclude=(Document|Window|HTML.+) | 1475/1559>1477/1559 | c? | sin commit localizado | S |
| html/editing/dnd/platform/pointerdown-add-display-none.html | E>O | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |
| html/semantics/embedded-content/bfcache/embedded-js.html | 1/2>2/2 | c? | sin commit localizado | S |
| html/semantics/embedded-content/the-object-element/object-attributes.html | 3/4>4/4 | c? | sin commit localizado | S |
| html/semantics/forms/the-select-element/customizable-select/select-iterate-before-beginning.tentative.html | 0/0>2/2 | c | 6f2b75e22 Fix customizable select keyboard navigation hang (por asunto) | S |
| html/semantics/popovers/popover-focus-3.html | 5/9>9/9 | c | de6eb169a Fix the focus controller logic for invokers of all kinds | S |
| html/semantics/popovers/popover-focus-4.html | 1/3>3/3 | c | de6eb169a Fix the focus controller logic for invokers of all kinds | S |
| inert/inert-node-is-uneditable.html | 2/3>3/3 | c? | sin commit localizado | S |
| infrastructure/testdriver/bidi/emulation/set_geolocation_override.https.html | 0/3>2/3 | d | arnes/webdriver/emulacion de Linux (779194081 Extend Emulation.setGeolocationOverride es del lado del driver) | S |
| mediacapture-insertable-streams/legacy/MediaStreamTrackGenerator-video.https.html | 5/7>6/7 | d | entorno/hardware/codec de Linux o deriva de WPT | S |
| notifications/tag.https.html | 1/2>2/2 | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |
| payment-request/payment-request-abort-method.https.html | 3/4>4/4 | c? | sin commit localizado | S |
| preload/modulepreload-as.html | 13/27>19/27 | c? | sin commit localizado | S |
| secure-payment-confirmation/enrollment-in-iframe.sub.https.html | 2/3>3/3 | c? | sin commit localizado | S |
| selection/idlharness.window.html | 107/112>112/112 | a | TreatSymbolsAsWordBoundary + SelectionAcrossShadowDOM -> stable (7cc3f757b) | S |
| selection/move-by-word-with-symbol.html | 0/6>6/6 | a | TreatSymbolsAsWordBoundary + SelectionAcrossShadowDOM -> stable (7cc3f757b) | S |
| selection/shadow-dom/tentative/Range-isPointInRange.html | 1/2>2/2 | a | SelectionAcrossShadowDOM -> stable (7cc3f757b [selection api] Enable SelectionAcrossShadowDOM in stable) | S |
| selection/shadow-dom/tentative/Selection-collapse-and-extend.html | 0/4>4/4 | a | SelectionAcrossShadowDOM -> stable (7cc3f757b [selection api] Enable SelectionAcrossShadowDOM in stable) | S |
| selection/shadow-dom/tentative/Selection-direction.html | 0/7>7/7 | a | SelectionAcrossShadowDOM -> stable (7cc3f757b [selection api] Enable SelectionAcrossShadowDOM in stable) | S |
| selection/shadow-dom/tentative/Selection-getComposedRanges-dom-mutations-removal.html?mode=closed | 0/6>6/6 | a | SelectionAcrossShadowDOM -> stable (7cc3f757b [selection api] Enable SelectionAcrossShadowDOM in stable) | S |
| selection/shadow-dom/tentative/Selection-getComposedRanges-dom-mutations-removal.html?mode=open | 0/6>6/6 | a | SelectionAcrossShadowDOM -> stable (7cc3f757b [selection api] Enable SelectionAcrossShadowDOM in stable) | S |
| selection/shadow-dom/tentative/Selection-getComposedRanges-range-update.html | 0/9>8/9 | a | SelectionAcrossShadowDOM -> stable (7cc3f757b [selection api] Enable SelectionAcrossShadowDOM in stable) | S |
| selection/shadow-dom/tentative/Selection-getComposedRanges-slot.html | 0/3>3/3 | a | SelectionAcrossShadowDOM -> stable (7cc3f757b [selection api] Enable SelectionAcrossShadowDOM in stable) | S |
| selection/shadow-dom/tentative/Selection-getComposedRanges.html | 0/12>12/12 | a | SelectionAcrossShadowDOM -> stable (7cc3f757b [selection api] Enable SelectionAcrossShadowDOM in stable) | S |
| selection/shadow-dom/tentative/Selection-isCollapsed.html | 0/4>4/4 | a | SelectionAcrossShadowDOM -> stable (7cc3f757b [selection api] Enable SelectionAcrossShadowDOM in stable) | S |
| service-workers/cache-storage/cache-add.https.any.html | 20/22>21/22 | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |
| service-workers/service-worker/client-navigate.https.html | 9/9>10/10 | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |
| service-workers/service-worker/installing.https.html | 0/2>1/2 | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |
| shadow-dom/focus-navigation/reading-flow/tentative/flex-flow.html | 0/3>3/3 | a | CSSReadingFlow/CSSReadingOrder -> stable (c67d9fab7) | S |
| shadow-dom/focus-navigation/reading-flow/tentative/grid-auto-flow-reading-order.html | 0/2>2/2 | a | CSSReadingFlow/CSSReadingOrder -> stable (c67d9fab7) | S |
| shadow-dom/focus-navigation/reading-flow/tentative/grid-order-with-position-absolute.html | 1/2>2/2 | a | CSSReadingFlow/CSSReadingOrder -> stable (c67d9fab7) | S |
| shadow-dom/focus-navigation/reading-flow/tentative/grid-order-with-position-fixed.html | 1/2>2/2 | a | CSSReadingFlow/CSSReadingOrder -> stable (c67d9fab7) | S |
| shadow-dom/focus-navigation/reading-flow/tentative/source-order-valid.html | 0/5>5/5 | a | CSSReadingFlow/CSSReadingOrder -> stable (c67d9fab7) | S |
| subresource-integrity/signatures/tentative/authority.https.window.html | 0/0>10/12 | c? | sin commit localizado | S |
| svg/painting/scripted/SVGMarkerElement-orientType-synchronization.html | 2/3>3/3 | c? | sin commit localizado | S |
| upgrade-insecure-requests/gen/top.meta/unset/sharedworker-import.https.html | 1/6>6/6 | c | 58e06f599 [M137] Fix broken plumbing in SharedWorkerHost creation (por asunto) | S |
| viewport-segments/viewport-segments-change-event.https.html | E>O | d | arnes/webdriver/emulacion de Linux (779194081 Extend Emulation.setGeolocationOverride es del lado del driver) | S |
| viewport-segments/viewport-segments-env-variables.https.html | E>O | d | arnes/webdriver/emulacion de Linux (779194081 Extend Emulation.setGeolocationOverride es del lado del driver) | S |
| viewport-segments/viewport-segments-segments-property.https.html | E>O | d | arnes/webdriver/emulacion de Linux (779194081 Extend Emulation.setGeolocationOverride es del lado del driver) | S |
| wasm/jsapi/jspi/js-promise-integration.any.html | 3/13>13/13 | c | 159662d2a [v8][wasm] Enable WebAssembly JS Promise Integration | S |
| wasm/jsapi/jspi/js-promise-integration.any.worker.html | 3/13>13/13 | c | 159662d2a [v8][wasm] Enable WebAssembly JS Promise Integration | S |
| wasm/jsapi/jspi/notraps.any.html | 0/3>3/3 | c | 159662d2a [v8][wasm] Enable WebAssembly JS Promise Integration | S |
| wasm/jsapi/jspi/notraps.any.worker.html | 0/3>3/3 | c | 159662d2a [v8][wasm] Enable WebAssembly JS Promise Integration | S |
| wasm/jsapi/jspi/rejects.any.html | 0/5>5/5 | c | 159662d2a [v8][wasm] Enable WebAssembly JS Promise Integration | S |
| wasm/jsapi/jspi/rejects.any.worker.html | 0/5>5/5 | c | 159662d2a [v8][wasm] Enable WebAssembly JS Promise Integration | S |
| webaudio/the-audio-api/the-audioworklet-interface/process-getter.https.html | 0/2>2/2 | c | 8963d3274 Get AudioWorklet process method per-instance instead of per-definition | S |
| webaudio/the-audio-api/the-audioworklet-interface/processor-construction-port.https.html | 3/4>4/4 | c | 8963d3274 Get AudioWorklet process method per-instance instead of per-definition | S |
| webdriver/tests/bidi/browsing_context/create/background.py | 3/6>4/6 | d | arnes/webdriver/emulacion de Linux (779194081 Extend Emulation.setGeolocationOverride es del lado del driver) | S |
| webdriver/tests/bidi/emulation/set_geolocation_override/contexts.py | 0/2>2/2 | d | arnes/webdriver/emulacion de Linux (779194081 Extend Emulation.setGeolocationOverride es del lado del driver) | S |
| webdriver/tests/bidi/emulation/set_geolocation_override/coordinates.py | 0/10>10/10 | d | arnes/webdriver/emulacion de Linux (779194081 Extend Emulation.setGeolocationOverride es del lado del driver) | S |
| webdriver/tests/bidi/emulation/set_geolocation_override/invalid.py | 0/85>84/85 | d | arnes/webdriver/emulacion de Linux (779194081 Extend Emulation.setGeolocationOverride es del lado del driver) | S |
| webdriver/tests/bidi/emulation/set_geolocation_override/user_contexts.py | 0/4>4/4 | d | arnes/webdriver/emulacion de Linux (779194081 Extend Emulation.setGeolocationOverride es del lado del driver) | S |
| webdriver/tests/bidi/log/entry_added/stacktrace.py | 0/0>9/9 | d | arnes/webdriver/emulacion de Linux (779194081 Extend Emulation.setGeolocationOverride es del lado del driver) | S |
| webdriver/tests/interop/beforeunload_prompt.py | 2/5>5/5 | d | arnes/webdriver/emulacion de Linux (779194081 Extend Emulation.setGeolocationOverride es del lado del driver) | S |
| webnn/conformance_tests/dequantizeLinear.https.any.html?cpu | 10/17>11/17 | b | WebNN (fuera) | S |
| webnn/conformance_tests/dequantizeLinear.https.any.html?gpu | 10/17>11/17 | b | WebNN (fuera) | S |
| webnn/conformance_tests/dequantizeLinear.https.any.html?npu | 10/17>11/17 | b | WebNN (fuera) | S |
| webrtc-stats/supported-stats.https.html | 246/283>247/283 | d | entorno/hardware/codec de Linux o deriva de WPT | S |
| webrtc/RTCConfiguration-iceServers.html | 54/58>56/62 | d | entorno/hardware/codec de Linux o deriva de WPT | S |
| webrtc/RTCDataChannel-close.html | 10/12>11/12 | d | entorno/hardware/codec de Linux o deriva de WPT | S |
| webrtc/outbound-rtp-encoding-index.https.html | 1/3>3/3 | d | entorno/hardware/codec de Linux o deriva de WPT | S |
| workers/Worker-creation-happens-in-parallel.https.html | T>O | d | variacion/arnes (T>O, flip-flop de la 136 o deriva de WPT) | S |

## Funciones de clase a (flags que pasan a stable en el 137 con pruebas WPT que mejoran)

- Blob URL partitioning (9aae7ac7f [M137] Launch Blob URL partitioning): 3 pruebas
- CSSInlineIfFor{Media,Style,Supports}Queries -> stable (a10210e9b Switch CSS if() flags to stable): 3 pruebas
- CSSReadingFlow/CSSReadingOrder -> stable (c67d9fab7): 7 pruebas
- CSSShapeFunctionOffsetPath/CompositeAnimation -> stable (96d9ccc8d Ship offset-path: shape()): 4 pruebas
- CSSViewTransitionMatchElement -> stable (26f116090): 1 pruebas
- CanvasFloatingPoint + ImageDataPixelFormat -> stable (0d364e3a8 Enable canvas floating point feature by default): 2 pruebas
- DocumentIsolationPolicy en escritorio (60e02302b Enable DocumentIsolationPolicy on desktop): 18 pruebas
- SelectionAcrossShadowDOM -> stable (7cc3f757b [selection api] Enable SelectionAcrossShadowDOM in stable): 9 pruebas
- TreatSymbolsAsWordBoundary + SelectionAcrossShadowDOM -> stable (7cc3f757b): 2 pruebas
- ViewTransitionUpdateLifecycleBeforeReady -> stable: 1 pruebas
- WebCryptoEd25519 -> stable (e1b1cfbcc Ship the Ed25519 WebCrypto agorithm): 14 pruebas

Flags a stable sin prueba que mejore (sin efecto WPT visible): AdjustDOMOffsetToLayoutOffsetForSecureText, AllowSvgUseToReferenceExternalDocumentRoot, CaretWithTextAffinityUpstream, CheckForCanonicalPositionInIdleSpellCheck, CustomizableSelectElementAccessibilityIssues, EnterInOpenShadowRoots, FindNestedAnnotationFix, FindOrphanAnnotationFix, HandleDeletionAtStartAndEndBoundaryContainingHiddenElement, LayoutNGShapeCache, LineBreakEarlyReturn, ListOwnerMustHaveCSSBox, PlaceholderVisibility, PlainTextPainter, PreLogicalMargin, RubyJustificationFix, ScrollableAreaOptimization, SkipLineBreakItemWhenIsCollapsed, SpatNavUsesCursorInheritance, SvgTransformOnNestedSvgElement, TextareaStableResizing, UseStyleRuleMapForSelectorStats, ValidationBubbleNoForcedLayout, WebAuthenticationAlignErrorTypeForPaymentCredentialCreate, WebGPUCopyBufferToBufferOverload, DocumentPolicyIncludeJSCallStacksInCrashReports (solo Android/ChromeOS/auxiliares: DynamicSafeAreaInsets*, WebAppLaunchQueue, GetAllScreensMedia, CapturedSurfaceResolution).

## Causas c agrupadas

| sha | asunto | pruebas | directorio |
|---|---|---|---|
| c832b551d | Replace calc() division nodes with Invert nodes (+ fb4a7683f Convert 1 * x -> x, 9983d9c9f Sort product nodes; por asunto) | 9 | css |
| 159662d2a | [v8][wasm] Enable WebAssembly JS Promise Integration | 6 | wasm |
| 58e06f599 | [M137] Fix broken plumbing in SharedWorkerHost creation (por asunto) | 4 | content-security-policy, upgrade-insecure-requests |
| 10da5d634 | Simplify calc-size() interpolations more aggressively | 3 | css |
| 5f8643cf1 | DOM: Fix Observable iterator `return()` method handling | 2 | dom |
| de6eb169a | Fix the focus controller logic for invokers of all kinds | 2 | html |
| 8963d3274 | Get AudioWorklet process method per-instance instead of per-definition | 2 | webaudio |
| 69b4d66dc | [anchor] Don't use a deleted fallback rule | 1 | css |
| 69e2e4a30 | Disallow calc() in named timeline range keyframe selectors | 1 | css |
| 59d393acd | Support sibling-index() and sign() for font-variation-settings | 1 | css |
| cbed85934 | VT: Add cleanup to only-child-group.html (por asunto) | 1 | css |
| 5a687a31d | Fix dynamic change handling for :open on <details> | 1 | css |
| 18ba67e97 | Consistently match default namespace declaration during serialization (flag vuelto a test en M137 por 16397892b: dudoso) | 1 | domparsing |
| 6f2b75e22 | Fix customizable select keyboard navigation hang (por asunto) | 1 | html |
