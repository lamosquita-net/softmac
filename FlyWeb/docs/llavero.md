# F7.5 — Contraseñas del llavero de macOS en FlyWeb (estudio, 03/10/2026)

**Lo que pide el HUMANO:** usar en FlyWeb las contraseñas que ya están en el llavero de macOS, sin abrir Acceso a
Llaveros para buscarlas. La extensión «Contraseñas de iCloud» de Apple exige macOS 14, así que no sirve en Mojave.

## 1. Cómo están las cosas

- **Dónde guarda FlyWeb las contraseñas.** En su propia base de datos (`Login Data` del perfil), cifrada con una
  clave que sí está en el llavero («FlyWeb Safe Storage»). Las contraseñas en sí no están en el llavero.
- **Antes era distinto.** Hasta al menos Chromium 50 (2016), Chrome en Mac guardaba las contraseñas directamente en el
  llavero (`chrome/browser/password_manager/password_store_mac.cc`, con `SecKeychain…`). Google lo quitó. En la 116 no
  queda nada de eso, y el importador de Safari no trae contraseñas.
- **Dónde están las contraseñas del HUMANO en el llavero:**
  - **Llavero «inicio de sesión» (local):** contraseñas de Internet (`kSecClassInternetPassword`) guardadas por Safari
    con iCloud desactivado, o por otras apps. **Se pueden leer** con Keychain Services, que existe en 10.14.
  - **Llavero de iCloud:** si iCloud Keychain está activo, Safari guarda ahí. **Una app que no es de Apple no puede
    leerlo** (hace falta un grupo de acceso firmado por Apple). Esto no tiene solución desde FlyWeb.
- **Lo que pide macOS al leer.** Listar las entradas (sitio y usuario, sin la contraseña) no pide nada. **Leer cada
  contraseña** muestra el aviso de macOS («FlyWeb quiere usar información confidencial guardada en … de tu llavero»),
  con «Denegar», «Permitir» y «Permitir siempre». Es la protección del sistema y está bien que siga así: FlyWeb no puede
  ni debe saltársela.

## 2. Opciones

| | Qué hace | Ventajas | Inconvenientes | Trabajo |
|---|---|---|---|---|
| **A. Importar una vez** | En Ajustes › Contraseñas: «Importar del llavero de macOS». Lista las entradas del llavero local, el usuario marca cuáles y FlyWeb las copia a su gestor (macOS pregunta por cada una) | Simple y seguro: después, FlyWeb las rellena solo, como cualquier contraseña guardada | Es una copia: si cambias una contraseña en Safari, en FlyWeb no cambia (y al revés) | Medio: C++ con Keychain Services + una página pequeña |
| **B. Usar el llavero en vivo** | FlyWeb consulta el llavero cada vez que rellena un formulario y guarda en él las nuevas, como el Chrome de 2016 | Una sola fuente: Safari y FlyWeb ven lo mismo | Hay que reescribir el almacén de contraseñas de Chromium 116 (lo quitaron por algo: lento, frágil, avisos frecuentes); mucho código fuera de `chromium_src/`, difícil de mantener | Alto |
| **C. Importar desde CSV** | Ya existe en la 116 (Ajustes › Contraseñas › Importar) | Cero código | Ni Safari 14 en Mojave ni Acceso a Llaveros exportan contraseñas a CSV: no hay de dónde sacar el fichero | Ninguno, pero no resuelve el caso |

## 3. Recomendación

**A, importar una vez**, con estas condiciones:
- **Solo con permiso explícito y por entrada:** nada se lee sin que el usuario pulse «Importar» y macOS lo autorice.
  FlyWeb nunca lee el llavero por su cuenta.
- **Solo el llavero local** (inicio de sesión). Si no aparece nada, explicar que con iCloud Keychain activo las
  contraseñas no son accesibles fuera de Safari.
- **Sin copia en ningún otro sitio:** van al gestor de FlyWeb (cifrado con su clave) y a ninguna parte más. No hay
  sincronización.
- **Se puede repetir** para traer las nuevas; las que ya existan se saltan.

B solo compensaría si el HUMANO usa Safari y FlyWeb a la vez y cambia contraseñas a menudo. Si no, el coste de
mantenerla en cada parche de seguridad no compensa.

## 4. Preguntas para el HUMANO

1. **¿Tienes activado el llavero de iCloud?** Si tus contraseñas están solo en iCloud, ninguna opción puede leerlas
   desde FlyWeb: tendrías que pasarlas tú (o desactivar iCloud Keychain, que las deja en el llavero local).
2. **¿Te basta importar una vez (A), o necesitas que Safari y FlyWeb compartan las contraseñas al momento (B)?**
3. **¿Cuántas son, más o menos?** macOS pregunta por cada una al importar; con cientos, son muchos clics, aunque con
   «Permitir siempre» cada aviso sale una sola vez.
