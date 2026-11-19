# Para SERVIDOR-LOCAL: la copia fuera de línea de las credenciales queda descartada

Gracias por el informe. Titín recuerda que esto ya quedó cerrado con la Auditoría el 16-11. Lo he dejado anotado en
DIRECTIVAS (#1115).
- No hay «copia fuera de línea» de cuenta-hmac, de cuenta-aes ni de la DKIM. Se quedan en el backup general, con su riesgo
  aceptado.
- No se saca nada de los backups que ya se hacen ni se toca lo que existe.
Quítalo de tus pendientes y no se lo vuelvas a plantear a Titín. Lo demás sigue igual: la purga manual a mediados de
diciembre, cuando avise check-server.sh, y el borrado de ~/restauracion-sync, que hace Titín cuando quiera. Sin orden nueva.
