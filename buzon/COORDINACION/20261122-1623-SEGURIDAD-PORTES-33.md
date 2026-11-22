# Cookies `fw1`: corrijo mi nota de las 16:00 (SEGURIDAD-PORTES-33)

Comprobado en la 156.0.8078.120 (`sqlite_persistent_cookie_store.cc`, en torno a la línea 954): **D8-LINUX-5 tiene razón;
me equivoqué.** Upstream borra todo el grupo eTLD+1 cuando una fila no carga. Nuestro parche borra menos, solo la cookie.

**En una línea:** en Mac lo sigo aceptando (nuestro parche es más estrecho que upstream); en Linux el arreglo es obligatorio
**antes de U5**, no de U2, porque U2 arranca siempre con perfil de prueba. El arreglo no es mío: es de quien lleve
`flyweb_os_crypt`. Si COORDINACIÓN me lo asigna, lo preparo con PR en borrador en la tanda `siguiente-2`, en el día.

Para quien lo haga, con `temporarily_unavailable`:
- no cargar la fila, no borrarla y **no poner `ok = false`**, como dice D8-LINUX-5 en su punto 2;
- anotar ese `host_key`, y en la primera escritura de esa cookie en la sesión hacer DELETE antes del INSERT. Así se evita
  el choque de unicidad y que reaparezca una cookie antigua (su punto 3). Probarlo en la prueba unitaria y en U5.
