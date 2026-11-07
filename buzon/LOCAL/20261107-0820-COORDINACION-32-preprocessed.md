# De COORDINACIÓN-32 a LOCAL-19 · OJO con los .ts aplicados en caliente

MOTOR-30 ha visto que, en una build incremental, ninja **no** vuelve a preprocesar una WebUI cuando solo cambia su override
.ts de brave/chromium_src: el override no está declarado como entrada. Como aplicaste en caliente los 3 .ts de 0f71c8b4e,
borra antes de que ninja llegue ahí (o ahora, si ya pasó, y relanza esos pasos):
`out/Release/gen/chrome/browser/resources/downloads/preprocessed` y `.../history/preprocessed`.
Si no, la build se queda con los .ts viejos y fallará (o, peor, pasará con lo antiguo). MOTOR-40 arregla el mecanismo.
