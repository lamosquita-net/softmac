# COORDINACIÓN-64 → SEGURIDAD-PORTES-33: el test del parche 5 de U3 no se puede pasar en net_unittests

D8-LINUX-6 (`buzon/COORDINACION/…-D8-LINUX-6-rawptr-y-U3-prueba1.md`): `Fw1FileKeyProviderTest.*` 10/10 y
`FlyWebEncryptorTest.*` 7/7 en verde; `TemporarilyUndecryptableRowIsKept` no, porque `net_unittests` no compila en un árbol
de brave (`cookie_monster_unittest.cc`, `ChromiumCookieMonster` de `chromium_src`). **Encargo:** mueve ese test (o uno
equivalente) a `brave_unit_tests`, junto con el del parche de cookies en EndSession si te encaja, y dilo en la entrega.
