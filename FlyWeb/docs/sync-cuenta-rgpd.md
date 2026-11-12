# FlyWeb 3.2 — sync con cuenta: propuesta de papeles del RGPD

ARQUITECTURA, 12-11-2026, por la decisión 8 de Titín sobre [`sync-cuenta.md`](sync-cuenta.md) §13: «primero una
propuesta nuestra». Son tres borradores: registro de actividades (art. 30), contrato de encargado con OVH (art. 28) y
procedimiento de brechas (art. 33 y 34).

**Qué es y qué no es.** Es un punto de partida técnico, hecho por quien ha diseñado el sistema y sabe qué datos hay y
dónde. **No soy abogado y esto no es asesoramiento legal:** antes de darlo por bueno lo tiene que leer quien lleve lo
legal, junto con el texto de privacidad (W2).

**Datos personales: ninguno en este fichero.** Lo que identifica al responsable va con marcadores («RESPONSABLE»,
«NIF», «DOMICILIO», «CONTACTO-PRIVACIDAD»). La copia rellena la guarda Titín **fuera del repositorio**, que es
público.

Marcas: **[V]** comprobado en la fuente citada; **[I]** inferido o sin comprobar; **[P]** propuesta.

## 1. Registro de actividades de tratamiento (art. 30.1)

Por qué hace falta: la exención de las organizaciones pequeñas (art. 30.5) no vale cuando el tratamiento **no es
ocasional**, y una cuenta que se usa a diario no lo es (revisión de SEGURIDAD, C6c).

**Ficha del tratamiento «Cuentas de sincronización de FlyWeb»**

| Apartado (art. 30.1) | Contenido |
|---|---|
| a) Responsable | «RESPONSABLE», «NIF», «DOMICILIO». Contacto: «CONTACTO-PRIVACIDAD». Sin delegado de protección de datos [I: no parece obligatorio a esta escala; que lo confirme quien lleve lo legal] |
| b) Fines | Sincronizar los datos del navegador entre los equipos del usuario; verificar que quien entra en la cuenta controla el email; avisar de las operaciones sobre la cuenta y del borrado por inactividad |
| Base jurídica | Ejecución del servicio que el usuario solicita (art. 6.1.b). Avisos de seguridad: los mismos, como parte del servicio |
| c) Interesados | Usuarios de FlyWeb que crean una cuenta de sincronización |
| c) Datos | **Dirección de correo** (cifrada, y su HMAC). **Modelo y nombre de cada equipo**, el nombre elegido por el usuario (cifrado). Identificador seudónimo de la cadena (clave pública). Fechas de alta y de último uso. **Datos sincronizados** (contraseñas, marcadores, historial, ajustes): cifrados en el equipo del usuario; el responsable no puede leerlos. **Semilla envuelta** con una clave derivada de la contraseña, si el usuario pone contraseña. Sin IP, sin nombre de la persona, sin registro de peticiones |
| Categorías especiales | Ninguna que el responsable pueda ver. El historial y las contraseñas sincronizadas podrían revelarlas, pero van cifrados de extremo a extremo |
| d) Destinatarios | Ninguno. No se cede a terceros. Encargado del tratamiento: el proveedor de alojamiento (§2) |
| e) Transferencias internacionales | Ninguna: servidor en Francia (UE) [V, `docs/SERVIDOR.md:13`]. Comprobar lo mismo para la copia de seguridad (§2) |
| f) Plazos de supresión | Cuenta y datos: hasta que el usuario los borra, o 365 días sin uso (aviso por correo 30 días antes). Historial sincronizado: 14 días. Códigos por correo: 10 minutos. Registro del servidor de correo: 7 días. Copias de seguridad: 30 días. Borrado pedido sin ningún equipo: se ejecuta a los 14 días |
| g) Medidas de seguridad (art. 32) | Cifrado de extremo a extremo de los datos sincronizados; email y nombres cifrados con una clave que no está en la base de datos; contraseña nunca enviada al servidor, que guarda un verificador con scrypt; doble verificación por correo; aviso al usuario de cada operación; copias cifradas con una clave que no está en los servidores; sin IP ni registro de peticiones; acceso por SSH con clave y cortafuegos estricto |

**Riesgo que hay que dejar escrito en el registro** (decisión 2 de Titín): si alguien se lleva la base de datos,
puede probar contraseñas sin conexión; las débiles darían acceso a los datos sincronizados de esa cuenta. Medidas:
estiramiento costoso en el cliente y en el servidor, aviso al crear la contraseña, y la opción de cuenta sin
contraseña. Con esto y la escala (decenas de usuarios), SEGURIDAD no ve necesaria una evaluación de impacto
(art. 35); conviene que el registro diga que se valoró.

## 2. Contrato de encargado (art. 28)

Hay encargado cuando otro trata los datos por cuenta del responsable. Aquí:

| Quién | Qué trata | Qué hay que tener |
|---|---|---|
| **OVH** (ns2) | aloja la máquina donde están `sync.db`, el servidor de correo y sus registros | contrato de encargado |
| **Donde esté bak** | la copia cifrada de `sync.db` | si es otro proveedor, otro contrato de encargado; si es una máquina propia, nada [I: no sé dónde está alojado bak] |
| **ns1** | solo si acaba haciendo de relé de correo (`sync-cuenta.md` §10) | lo mismo que ns2 |

**OVH: qué he podido ver y qué no.** En su página de contratos figura, entre las condiciones generales, un «Contrato
de tratamiento de datos personales», y aparte un documento de «Subencargados de OVH» [I: los he visto citados en un
resumen de la página <https://www.ovhcloud.com/es-es/terms-and-conditions/contracts/>, consultada el 12-11-2026; **no
he leído los dos documentos** ni he podido confirmar si se aplican solos al contratar o hay que firmar algo].

**Lo que tiene que hacer Titín** (no se puede hacer desde aquí: está en su área de cliente):

1. Descargar el contrato de tratamiento de datos que corresponde al servicio de ns2 y guardarlo con la fecha.
2. Comprobar si forma parte de las condiciones aceptadas al contratar o si hay que aceptarlo aparte.
3. Repasar que cubre lo que exige el art. 28.3:

| Art. 28.3 | Qué debe decir el contrato |
|---|---|
| a) | que OVH trata los datos solo siguiendo instrucciones documentadas del cliente |
| b) | confidencialidad de su personal |
| c) | medidas de seguridad del art. 32 |
| d) | condiciones para subcontratar: lista de subencargados y aviso de cambios |
| e) | ayuda para atender los derechos de los interesados |
| f) | ayuda con la seguridad y **con las brechas: en qué plazo avisa OVH al cliente** |
| g) | devolución o borrado de los datos al terminar el servicio |
| h) | información para demostrar el cumplimiento y permitir auditorías |

4. Mirar en la lista de subencargados si alguno está fuera de la UE para el servicio contratado.
5. Apuntar en el registro (§1, fila d) el nombre exacto del contrato y su fecha.

Lo que más importa para el §3 es la letra f: el plazo de 72 horas del responsable cuenta desde que **él** tiene
constancia, y depende de que OVH avise pronto.

## 3. Procedimiento de brechas (art. 33 y 34)

**Qué es una brecha aquí:** que alguien sin permiso acceda a datos personales, o que se pierdan o se alteren. El
email de un usuario ya es un dato personal.

### 3.1 Pasos

| Paso | Quién | Plazo |
|---|---|---|
| 1. Detectar y anotar la hora en que se tiene constancia | quien lo vea (SERVIDOR, SEGURIDAD, un usuario) avisa a «RESPONSABLE» | al momento |
| 2. Contener: cortar el acceso, conservar los registros, no borrar nada | SERVIDOR, con permiso de Titín | horas |
| 3. Valorar el alcance con la tabla de 3.2 | «RESPONSABLE», con SEGURIDAD | primeras 24 h |
| 4. Decidir si se notifica a la AEPD | «RESPONSABLE» | — |
| 5. Notificar a la AEPD, si procede | «RESPONSABLE» | **72 horas desde que se tiene constancia** [V] |
| 6. Comunicar a los usuarios afectados, si el riesgo es alto (art. 34) | «RESPONSABLE» | sin dilación |
| 7. Anotar la brecha en el registro interno, **se notifique o no** (art. 33.5) [V] | «RESPONSABLE» | al cerrar |

Datos comprobados en la página de la AEPD sobre brechas [V,
<https://www.aepd.es/derechos-y-deberes/cumple-tus-deberes/medidas-de-cumplimiento/brechas-de-datos-personales-notificacion>,
consultada el 12-11-2026]:

- Se notifica por vía electrónica, con el **formulario de notificación de brechas de datos personales** de la Sede
  Electrónica de la AEPD.
- El plazo es de 72 horas desde que la organización tiene constancia de la brecha.
- La AEPD ofrece dos herramientas gratuitas para decidir: **Asesora Brecha** (si hay que notificar a la AEPD,
  art. 33) y **Comunica-Brecha RGPD** (si hay que avisar a los afectados, art. 34). No deciden por el responsable.
- Aunque se concluya que no hay riesgo, la brecha, sus efectos y las medidas tomadas se documentan.

Lo que pide la notificación (art. 33.3): qué ha pasado; categorías y número aproximado de personas y de registros;
contacto; consecuencias probables; medidas tomadas o propuestas. Si no se tiene todo a las 72 horas, se manda lo que
haya y se completa después (art. 33.4).

### 3.2 Casos previsibles en la sync con cuenta

| Qué ha pasado | Qué se ha llevado | Riesgo para los usuarios | Propuesta [P] |
|---|---|---|---|
| Copia cifrada de bak expuesta, **sin** la clave privada | un fichero que no se puede abrir | ninguno apreciable | documentar; valorar con Asesora Brecha; en principio no hay que avisar a los usuarios (art. 34.3.a: datos ininteligibles) |
| Registro del servidor de correo expuesto | direcciones de correo de quien recibió algo en 7 días | bajo: que se sepa que usan FlyWeb; correo no deseado | documentar y valorar la notificación |
| **`sync.db` robada**, sin las credenciales de systemd | datos cifrados; emails y nombres cifrados; **verificador y envoltura de las cuentas con contraseña** | **alto para quien tenga una contraseña débil:** se puede adivinar sin conexión y abre sus contraseñas, marcadores e historial. Ninguno para las cuentas sin contraseña | **notificar a la AEPD y avisar a todos los usuarios con contraseña** |
| `sync.db` robada **con** las credenciales | lo anterior y los emails y nombres en claro | lo anterior, y además se sabe de quién es cada cuenta | lo mismo, y rotar las dos credenciales |
| ns2 comprometido en marcha | lo anterior y la clave de entrada de quien haya entrado mientras tanto | lo anterior, con el ataque a la contraseña más barato | lo mismo; parar el servicio hasta reinstalar |
| Fallo nuestro: un aviso llega a otra dirección, o una cuenta ve aparatos de otra | lo que diga el aviso | bajo, pero es una brecha | documentar, corregir y valorar |

**Qué decir a los usuarios cuando se ha llevado la base** (plantilla; sale del análisis de `sync-cuenta.md` §7):

> Asunto: Aviso de seguridad de FlyWeb: cambia tu contraseña y tu clave de sincronización
>
> El «FECHA» alguien accedió sin permiso al servidor de sincronización de FlyWeb y copió su base de datos. Tus
> contraseñas, marcadores e historial están cifrados y no se pueden leer directamente. Pero quien tenga la copia
> puede intentar adivinar la contraseña de tu cuenta de FlyWeb, y si lo consigue podrá leerlos.
>
> Qué te pedimos que hagas, en «Cuenta y sincronización»:
> 1. Cambia la contraseña de la cuenta por una larga que no uses en otro sitio.
> 2. Pulsa «Cambiar la clave de sincronización» y guarda las 24 palabras nuevas.
> 3. Si tu contraseña anterior era corta o la usabas en otros sitios, cambia también las contraseñas importantes que
>    tenías guardadas en FlyWeb.
>
> Qué hemos hecho: «MEDIDAS». Para cualquier duda: «CONTACTO-PRIVACIDAD».

Por qué los pasos 1 y 2 van juntos: la copia robada tiene los datos cifrados con la clave vieja. Cambiar la
contraseña no los protege; cambiar la clave de sincronización tampoco borra lo ya copiado, pero deja fuera todo lo
que se guarde después. El paso 3 es el único que protege lo que ya estaba en la copia.

### 3.3 Registro interno de brechas (art. 33.5)

Una hoja con: fecha y hora de constancia; qué pasó; datos y número de personas afectadas; consecuencias; medidas;
si se notificó a la AEPD y cuándo, o por qué no; si se avisó a los usuarios y cuándo. Se guarda **fuera del
repositorio**.

## 4. Lo que falta y de quién es

| Qué | Quién |
|---|---|
| Rellenar los marcadores en la copia local | Titín |
| Conseguir y repasar el contrato de OVH (§2) y decir dónde está bak | Titín |
| Confirmar con SERVIDOR los 7 días del registro de correo y la copia cifrada a 30 días | COORDINACIÓN → SERVIDOR-LOCAL |
| Revisión legal de estos tres borradores y de W2 | quien lleve lo legal |
| Decidir si la rotación de las copias a 30 días es un borrado automático (`sync-cuenta.md` §13, D) | Titín |
