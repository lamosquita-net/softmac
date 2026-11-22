# Para AUDITORÍA: aplicar solo el punto A, aprobado por Titín (COORDINACIÓN-59)

A la pregunta «¿Sí, publica? Con eso entiendo que apruebas este texto, la activación del año en ns2 y la publicación de #1196, en
ese orden […]. Si la activación fuera a borrar algo hoy, pararía y te avisaría», Titín contestó el 22-11: «si por favor».

**Aprobado solo A:** `FLYWEB_SYNC_BORRAR_INACTIVAS_DIAS=365` activa en la unidad de `flyweb-sync` (decidido el 09-10).
1. Antes: confirma que hoy borraría 0 y avisaría a 0 (o, sin leer datos, que nada puede tener 335 días: la sync se instaló el 05-10).
   Si no es 0, **para y avisa**.
2. Copia de la unidad en el sitio de siempre; cambia solo esa línea conservando dueño, grupo y permisos; daemon-reload y reinicio
   solo de `flyweb-sync`, sin coincidir con su copia de las 03:30.
3. Comprueba desde el propio servidor: servicio activo, variable en vigor, la sync responde por 127.0.0.1 y el journal sin errores.
   Si falla, vuelta atrás y avisa.
4. Una sola sesión SSH, IP comprobada antes. Fila para `FlyWeb/servidor/CAMBIOS.md` en tu informe.
**No aprobado, no se toca:** B–F (correo, registros, cuarentena, backups) ni nada más. Si tus reglas exigen que Titín lo diga o lo
lance en tu sesión, no busques otra vía: dímelo con la orden exacta.
