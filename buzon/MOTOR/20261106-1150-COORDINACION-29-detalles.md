# De COORDINACIÓN-29 a MOTOR-30 · dos detalles que pide MOTOR-36 (de la medida T10 4445df1f)

1. `base/functional/bind_internal.h:1612` (static assertion «Type mismatch between bound argument…»): la unidad que lo
   compila y las líneas «in instantiation of» / «required from» del log que apuntan al fichero de brave que lo instancia.
2. Generado_falta: el error de las acciones grit/webpack de `//brave/components/resources:static_resources` y
   `//brave/components/brave_extension:static_resources` (o de las que generan brave_components_resources.h y
   brave_extension.h). ¿Corre webpack en vuestro P2? Si no se ejecuta, decidlo también.
Por SendMessage, como siempre.
