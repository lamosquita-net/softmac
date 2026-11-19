# Para LOCAL-19: dictamen de SEGURIDAD-PORTES-31 sobre browser_tests y unit_tests (build 47)

**Veredicto: APTO.** Ningún fallo apunta a la serie y no se toca ningún parche. Pruebas a mano en la 6,1: recibidas, gracias.

**Antes de FS.47 (obligatorio):**
1. `content_unittests --gtest_filter='LocalNetworkAccessUtilTest.*'`, con el binario de local/314-tests. Si existe,
   `content_browsertests --gtest_filter='LocalNetworkAccessBrowserTest.*NoStatePrefetch*'`.
   Es la verificación del parche de prerender (parte5/integracion/chromium/0001 = 44be2964ef). En FlyWeb no está apagado: solo
   se alcanza si alguien permite las cookies de terceros (Brave las bloquea por defecto y por eso NoStatePrefetch cancela).
2. Confirma que en local/314-tests **adaptaste la prueba de parte4/0005** (ErrorDocument_DisallowsActions). En el mojom de la 156,
   OnSelectionChange no tiene callback y, tal como está en el repo, no compilaría.

**Comprobaciones baratas que quiero que consten (en el log que ya tienes, o con una pasada corta):**
3. CrxInstaller.InstallFailsDuringProfileShutdown: debe fallar ASSERT_FALSE(GetProfileByPath). Si falla EXPECT_EQ(PROFILE_SHUTTING_DOWN), avísame.
4. DevToolsTest.TestOpenSearchResultsInNewTab: «opened_url» debe ser la URL del buscador. Si sale about:blank, avísame (sería parte6/0026).
5. PDF, prueba de control: ReadAnythingEntryPointControllerOmniboxBrowserTest.CheckIfShouldSuggestReadingMode_ShorterPdfIsNotCandidate.
   Si falla igual, el fallo es de Brave o del entorno.
6. LNA NullIP en la 6,1: `python3 -m http.server 8765 --bind 127.0.0.1 &`, luego `curl -m5 -v http://0.0.0.0:8765/` y
   `/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode`. Si curl se cuelga, es el entorno.

**Notas para FS.47 y PRUEBAS.txt:**
- browser_tests se corrió **sin los filtros de brave-core** (test/filters/*.filter). PasswordAutofillAgentTest/PasswordGeneration
  (l.140-141), CrossProfileDebugger (l.1809), TestOpenSearchResultsInNewTab (l.1546) y unit_tests -DevToolsUIBindingsTest.* (l.736)
  ya están excluidos allí. Al filtro de FlyWeb le falta ExtensionCrxInstallerTest.InstallFailsDuringProfileShutdown, que Brave filtra
  porque desactiva kDestroyProfileOnBrowserClose. Anótalo; el filtro se arregla aparte, no en esta build.
- PasswordGeneration (40): bucle de CosmeticFiltersJSHandler::OnRemoteDisconnect (Brave). 3.1.4/chromium/0013 toca
  PasswordAutofillAgent, pero con el frame vivo se comporta igual.
- WebRtc SetRemoteDescription (4): causa sin determinar, no bloqueante. Ningún parche de la serie toca P2PTransportChannel. La videollamada a mano va bien.

**Lo que sigue pendiente de Titín:** las pruebas de interfaz con la 6,1 desbloqueada (aviso de LNA, miniaturas, fijadas, diálogo de
la extensión con PDF, enlace de la consola de DevTools) y la decisión de chrome/VERSION (.111). No toques el árbol. Me preguntas
antes de escribir FS.47.
