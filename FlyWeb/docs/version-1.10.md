# FlyWeb 1.10 — nivel de motor 126 (LOCAL, 09-10-2026)

**Estado:** Release **157.64.15** compilado, probado y notarizado de brave-core `seg/v8-12.6` **c3d250ff**
(= `nube/motor-126` + arreglos de LOCAL + seguridad FS.8). Entregado a PUBLICACIÓN en la fila FM.14 del tablero
(regla 11). **Se publica por orden del HUMANO (09-10) sin esperar a sus pruebas de PDF a mano**, que hará con la
1.10 ya instalada; si salen fallos, se parchea en una 1.10.x. Detalle técnico: `motor.md`,
«Nivel 126»; FS.8 en `TAREAS.md`; lecciones de compilación en `software/entregas/relevo-LOCAL-1.10.md`.

| Dato | Valor |
|---|---|
| Versión visible / `CFBundleVersion` | 1.10 / 157.64.15 (`FLYWEB_BUILD_NUMBER=15`) |
| V8 | 12.6.228.49 (Chrome 126 + M126-LTS + correcciones posteriores de FS.8) |
| DMG | `FlyWeb-1.10.dmg`, sha256 `75379aaf53e34e1483146b4322014dd1778f1265d671551ef545a463614aef03`, 165 201 280 bytes |
| `flyweb` tras la firma | fast-forward a c3d250ff (lo mueve LOCAL) |

## Para la web

*(Lenguaje de usuario, para CONTENIDOS-WEB; regla 12 del tablero.)*

- **Motor al nivel de Chrome 126.** Las webs ven FlyWeb como Chrome 126, porque ya tiene las funciones web
  estándar (Baseline) de Chrome 126. El motor de
  JavaScript (V8) pasa a ser el de Chrome 126.
- **Funciones web nuevas:** `URL.parse()` (las webs comprueban direcciones sin provocar errores) y `toJSON()` en la
  geolocalización (las webs de mapas y de reparto pueden guardar o enviar tu posición en un paso).
- **JavaScript algo más rápido:** el motor optimiza mejor algunos bucles y accesos a objetos.
- **PDF:** el visor de PDF (formularios que se rellenan, campos que se calculan solos, JavaScript de los PDF, como los
  de Hacienda o de organismos) pasa a funcionar sobre el nuevo motor de JavaScript. En pruebas automáticas con más de 280 PDF se
  comporta igual que la 1.9.
- **Se mantiene todo lo anterior:** pestañas fijadas en todas las ventanas (con su interruptor en Ajustes → Aspecto) y
  controles de formulario verticales.
- **Seguridad:** el motor de JavaScript de Chrome 126 trae entera la rama de soporte prolongado de Google para
  Chrome 126, y FlyWeb le añade las correcciones posteriores que le aplican, incluidas varias de la rama de soporte
  prolongado de Chrome 132 (2025). Siguen apagados el compilador Maglev, la parte más reciente del optimizador
  Turboshaft y el puente genérico entre WebAssembly y JavaScript.

Nada cambia en los ajustes ni en los datos del usuario. Al actualizar, la caché de código de JavaScript se regenera sola
(primeras visitas un poco más lentas).
