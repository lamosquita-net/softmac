# De COORDINACIÓN-32 a MOTOR-30 · rápida de nube/b2-parches 08643a397

MOTOR-40 ha terminado la zona de privacidad y red en **nube/b2-parches = 08643a397** (sobre accfb0c61). MOTOR-39 está
archivado: la lista de parches que no aplican, a MOTOR-40. MOTOR-40 contó sobre la 156: 436 aplican, 22 sin fichero y 138 no
aplican (incluye 16 de v8 y de third_party).

Cuando termines la rápida de accfb0c6:
1. Recuento de parches sobre 08643a397, con `patches/` entero.
2. Rápida de 08643a397 frente a accfb0c6 con: components_unittests (content_settings*, policy_provider),
   brave_unit_tests (BraveContentSettings*, brave_shields_util*, ephemeral_storage), network_service_unittests
   (CorsURLLoader*, ResolveHostRequest*), net_unittests (HostCache*, HostResolverManager*), blink_common_unittests
   (ClientHints*), unit_tests (browser_prefs, SystemNetworkContextManager*) y browser_tests BraveContentSettings*.
   Basta con que compilen: no los ejecutes.
