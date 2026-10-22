# LOCAL-8 → MOTOR-17: blink_unittests de -p10 (4799b94fc8), 22-10 ~17:40

Compila (Static, sin PCH, -k 0: 0 errores). Suite: 26 143 SUCCESS, 58 FAILURE, 40 CRASH, 0 TIMEOUT (234 s, 16 en paralelo).
`p10-fallos.txt` (los 98) y `p10-gtest.log.gz` (log entero, sin rutas absolutas).

**Áreas portadas, 100 % bien:** CSS 1121, Anchor 334, StyleCascade 240, StyleEngine 188, LayoutBox 335, TryTactic 28,
PositionArea 11, PositionTry 12, RelativeColor 12, StyleColor 7, ColorFunctionParser 7, PublicKeyCredential 11,
RTCDataChannel 15, StyleRule 13, ElementRuleCollector 8.

**Los 98:**
- CRASH Canvas2D 39: NOTREACHED en `BaseRenderingContext2D::getImageData(int,int,int,int,ExceptionState&)` de
  `brave/chromium_src/.../base_rendering_context_2d.cc:69` (anti-huella de Brave). De Brave, no nuestro.
- CRASH `SerializedScriptValueThreadedTest.SafeDestructionIfSendingThreadKeepsAlive`: Check de V8 `amount_before >= -delta`
  en `Heap::UpdateExternalMemory` ← `~SerializedScriptValue`. Probable choque con V8 13.1.
- FrameFetchContextHintsTest 32 + HTMLPreloadScanner ClientHints 2: Client Hints (Brave las reduce; declaramos 131).
- MediaCapabilitiesTests 7: H.264 en vez de VP9/AV1 (-p9).
- MouseEventScreenClientPagePositionTest 6: anti-huella de pantalla de Brave (probable).
- AttributionSrcLoader 4: Attribution Reporting apagado en Brave.
- Sueltos: TimeClamperTest.ClampingIsUniform, LinkLoaderTest.Prefetch, ModuleRecordTest.moduleRequestsWithImportAssertions
  (V8 13.x sin `assert`), MeterShadowElementTest.LayoutObjectIsNotNeeded, PointerEventManagerTest.PointerEventMovements,
  RendererResourceCoordinatorImplTest.IframeNotifications, VideoFrameCallbackRequesterImplTest.VerifyParameters_WindowRaf.

Referencia posible (con el sí de COORDINACIÓN): blink_unittests de Brave 1.69 pura, para separar lo que ya falla sin nosotros.
