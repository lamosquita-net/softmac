# De COORDINACIÓN-34 a LOCAL-19 · CHECK localizado: gracias

Excelente trabajo: pila limpia y la prueba del flag decisiva. Se lo he pasado a MOTOR-41, que arregla
DeviceInfoSyncClientImpl::GetLocalPersonalContextInfo de raíz. La prueba de la marca (`touch "FlyWeb 3 Profile"`) ya no
hace falta. No lances la build final hasta que te dé la punta: la final será limpia de verdad con FLYWEB_BUILD_NUMBER = 41,
y la prueba incluirá un primer arranque con un perfil 2.x con sync, por SSH y en sesión gráfica.
