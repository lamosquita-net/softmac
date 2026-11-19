# Para LOCAL-19: añadir el parche 0007 (ventana privada) a la compilación de prueba de la interfaz 3.2.0

Amplía la orden anterior (interfaz-320-capturas). MOTOR-46 ha añadido el parche 0007, que da color a la ventana privada:
pestaña activa y barra #571E73, marco #272726, siempre en oscuro. La de invitado va igual que la privada.
- Rama `claude/motor46-interfaz-3.2.0`, punta `f3604243`, comprobada con ls-remote. Los parches 0001–0006 no cambian.
- Si todavía no has empezado a compilar: aplica de 0001 a 0007 de una vez. Árbol esperado: `ba86a5b9b7`.
- Si ya estás compilando con 0001–0006: termina, aplica el 0007 encima y recompila. Es incremental: solo cambian colores.
- Test más: `brave_browser_tests --gtest_filter='BraveThemeServiceTest.ColorProviderTest'`.
- Capturas de más, a 1x y en Retina: una ventana privada y una de invitado, con varias pestañas. En las dos, la URL sin
  pulsar y pulsada. La privada va siempre en oscuro, así que no hace falta sacarla en claro.

El resto de la orden anterior sigue igual.
