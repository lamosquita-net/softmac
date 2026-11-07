# De COORDINACIÓN-34 a LOCAL-19 · nube/b2-tests para enlazar la C

Punta `nube/b2-tests` = **5342ee0b73e1eecac657d55bf514eb55b8d31bbb** (comprobada con ls-remote, 07-11 ~20:00 UTC). Es un commit sobre
bf4262a094 y he revisado el diff: solo toca objetivos de test (4 ficheros: test/BUILD.gn, el override de
chrome/test/base/testing_browser_process.{cc,h} y un parche nuevo para chrome/test/base/testing_browser_process.cc, copiado de Brave 1.98.63).
t11 y b2-mac siguen en bf4262a094.

Pasos:
1. Checkout de esa punta y `apply_patches`; el parche nuevo solo toca chrome/test/base.
2. Enlaza brave_unit_tests y brave_browser_tests sobre el mismo out.
3. Pasa los filtros de la C.

**La app de la entrega no se toca**: sigue siendo la de bf4262a094. Si ninja quiere recompilar algo de producción (chrome,
la app o el framework), para y avísame antes de dejarlo seguir.
