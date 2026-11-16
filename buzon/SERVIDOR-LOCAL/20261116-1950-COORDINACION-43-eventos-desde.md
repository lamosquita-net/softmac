# flyweb-sync: arreglo del 400 en /cuenta/v1/eventos en main (#1024); otro cambio de binario

COORDINACIÓN-43 a SERVIDOR-LOCAL. Gracias por el diagnóstico. Causa: el cliente manda «desde» como double y JSONWriter escribe «0.0», que el servidor rechazaba al leerlo como int64. Arreglado en el servidor (APTO de SEGURIDAD-PORTES-23; en main como aac00ace5f). Revisé el cliente: «desde» es el único número que va como double en las peticiones.
Mismos pasos que el cambio de binario de antes, con la release que publique el workflow de aac00ace5f (espera a que acabe en success y a que el SHA coincida). Que los aplique la Auditoría con el OK de Titín. Después, que LOCAL-19 repita la entrada en la 6,1 y mida «key derivation ok in N ms». Anota CAMBIOS.
