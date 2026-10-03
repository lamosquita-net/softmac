# F7.5 — Contraseñas del llavero de macOS en FlyWeb (estudio, 03/10/2026)

> **Actualización (HUMANO, 03/10):** usa mucho Safari, tiene muchísimas contraseñas y **el llavero de iCloud activo**,
> y necesita en el 5,1 del estudio las que guardó hace poco en la 7,1 o la 6,1. **Con iCloud activo, ni A ni B sirven**
> (§1: el llavero de iCloud está cerrado a las apps que no son de Apple; B solo vería el llavero local). Opciones
> reales en §5. Pendiente de decisión del HUMANO.

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

## 5. Con el llavero de iCloud activo (caso real del HUMANO)

| Opción | Mojave (5,1, 6,1) | Sequoia (7,1) | Sincroniza entre Macs | Coste |
|---|---|---|---|---|
| **1. Gestor propio** (p. ej. Bitwarden con servidor Vaultwarden en ns2) | Sí, extensión en FlyWeb | Sí: FlyWeb, Safari, iPhone | Sí, al momento | Cambiar de costumbre; migrar una vez (exportar CSV desde la app Contraseñas de Sequoia → importar); un servicio más en ns2 |
| **2. Extensión «Contraseñas de iCloud»** en FlyWeb | No (exige macOS 14) | Probablemente (probar en la 116; el manifiesto de mensajería nativa debe estar en la carpeta de FlyWeb) | Sí (iCloud) | Bajo; solo arregla la 7,1 |
| **3. Exportar e importar CSV de vez en cuando** | Sí, copia | Sí | No | Manual cada vez |

Recomendación de NUBE: **1**, la única que cubre «guardo en un Mac y la uso al momento en otro, también en Mojave»,
y coherente con la política del proyecto (código abierto, servidor propio, nada pasa por terceros). Si el HUMANO
prefiere seguir con iCloud, la 2 en la 7,1 y la 3 en los Mojave es lo máximo posible.

### 5.1 Comprobado (NUBE, 03/10, en `bitwarden/clients`)

- **Extensión en FlyWeb (Chromium 116): hay un problema serio.** Hasta `browser-v2026.9.1` el manifiesto pide
  `minimum_chrome_version` 102; **desde `browser-v2026.9.2` pide 134**. La Web Store no ofrece a FlyWeb versiones que
  exijan más de 116, así que la extensión **se queda congelada en 2026.9.1** y no recibe más parches de seguridad. Los
  permisos de la 2026.9.x (`offscreen`, `sidePanel`, `scripting`…) existen en la 116, pero el mínimo declarado no
  garantiza que funcione: hay que probarla.
- **App de escritorio:** Electron 43 → no funciona en Mojave (Electron dejó 10.13/10.14 en la v27). En Mojave solo
  queda la extensión.
- **Safari (7,1):** la extensión de Safari va dentro de la app de escritorio; en Sequoia, sin problema.
- **Consecuencia:** la opción 1 en Mojave depende de una extensión sin parches para el gestor de contraseñas, justo
  la pieza más sensible. Es el mismo riesgo asumido con Chromium 116, pero conviene decidirlo a sabiendas. Variantes:
  1a. aceptar la 2026.9.1 congelada (y que Vaultwarden siga aceptando clientes de esa versión, normalmente durante
      bastante tiempo, sin garantía);
  1b. mantener nosotros una versión de la extensión (GPL-3.0) con parches seleccionados: mucho trabajo, no lo
      recomiendo;
  1c. otro gestor con extensión que siga soportando Chromium 116 (KeePassXC + KeePassXC-Browser con el fichero `.kdbx`
      sincronizado por BackupDrive; por comprobar qué versión de KeePassXC funciona aún en 10.14): sin servidor, pero la sincronización no es «al
      momento» y hay conflictos si se edita en dos Macs a la vez. Por comprobar si su extensión actual sigue en ≤ 116.

## 6. Requisito del HUMANO (03/10): que funcione en Mojave sin quedarse congelado, en servidor propio

- **Descartados los gestores externos:** la extensión de Bitwarden exige Chromium 134 desde la 2026.9.2, y
  KeePassXC-Browser exige Chromium 124 (manifiesto actual, versión 1.10.4.1). Las dos se quedarían congeladas en
  FlyWeb 116. La extensión es la pieza que ve las contraseñas: no se acepta sin parches.
- **Propuesta de NUBE: la sincronización de FlyWeb contra un servidor propio.** Brave 1.57 trae «Sincronizar» (Sync
  v2), que incluye contraseñas, marcadores, historial y ajustes. Hoy está con URL inerte (`build.sh`). El servidor de
  Brave es código abierto: [`brave/go-sync`](https://github.com/brave/go-sync) (MPL-2.0, Go), y su protocolo es el
  de Chromium 116.0.5845.183, el mismo que nuestra base.
  - **No se congela:** es código del propio navegador, que ya mantenemos; no depende de una extensión ajena.
  - **No hay cuentas ni usuario:** los dispositivos se unen con un código de 24 palabras, y todo va **cifrado de
    extremo a extremo** (la clave sale de ese código). El servidor de ns2 solo guarda datos cifrados; ni nosotros
    podemos leerlos.
  - **Código en el navegador:** casi nada (la URL de sync en `build.sh` y revisar que la página de Sincronizar no
    nombre a Brave).
  - **Servidor:** `go-sync` usa DynamoDB y Redis. En ns2: DynamoDB Local (Java; Amazon no lo recomienda para
    producción, aunque para pocos usuarios bastaría) o ScyllaDB Alternator (compatible con la API de DynamoDB, más
    pesado). Hay que fijar un commit de `go-sync` compatible con 1.57 y probarlo en local antes de tocar ns2.
  - **Lo que no cubre:** Safari y el iPhone siguen en iCloud. Migración: exportar CSV desde Contraseñas (Sequoia)
    → importar en FlyWeb → se sincroniza al resto. A partir de ahí habría dos almacenes (iCloud para Safari/iPhone,
    FlyWeb para FlyWeb), salvo que dejes de guardar en Safari.
- **Decidido (HUMANO, 03/10):** sistema propio, el de menos mantenimiento (§7).

## 7. Decisión y estado (03/10)

- **HUMANO:** OCLP descartado (los Mac antiguos siguen en Mojave); sistema propio, el que menos mantenimiento dé;
  importará sus contraseñas por CSV (exportadas desde Contraseñas en la Sequoia).
- **NUBE:** hecho el servidor, `FlyWeb/servidor/sync` (ver su `README.md`): go-sync de Brave con SQLite y caché en
  memoria, un binario y un fichero en ns2. En el navegador solo cambia la URL (`build.sh`, paso 41 de
  `integracion.md`).
- **Falta:** instalarlo en ns2 y probarlo con FlyWeb en la 7,1, la 6,1 y la 5,1.
- **Cómo lo usará el HUMANO:** Ajustes › Sincronizar en la 7,1 → cadena nueva (guardar el código de 24 palabras en
  sitio seguro: sin él no hay forma de recuperar los datos, ni nosotros podemos); unir la 6,1 y la 5,1 con el código;
  importar el CSV en uno solo y borrar el CSV.
- **Lo que no cambia:** Safari y el iPhone siguen con iCloud; FlyWeb tiene su propio almacén sincronizado.
