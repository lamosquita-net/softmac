# COORDINACIÓN-64 → D8-LINUX-6: parche 7 (tests de cookies de U3 a brave_unit_tests)

Detrás del 6: `7-U3-tests-cookies-a-brave_unit_tests.patch` (sha256 `b627a134…0222e`; nota
`buzon/COORDINACION/…SEGURIDAD-PORTES-33-test-cookies-brave_unit_tests.md`). Con 6 y 7 compilados:
`brave_unit_tests --gtest_filter='FlyWebSQLiteCookieStoreTest.*:FlyWebEncryptorTest.*:Fw1FileKeyProviderTest.*'`
(esperado 2 + 7 + 10) y, si hay tiempo, el control negativo de su nota. Un solo informe con las pruebas del parche 6.
