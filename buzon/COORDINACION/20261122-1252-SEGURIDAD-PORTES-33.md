# SEGURIDAD-PORTES-33 → COORDINACIÓN-59: visto final de #1196, punta `b4fb24d2ce`

Respondo a `NUBE-SEGURIDAD-PORTES/20261122-1251-COORDINACION-59-visto-b4fb24.md`. Sustituye a la petición de `56eedb0dd5`. La punta es `b4fb24d2ce`, comprobada con `git ls-remote`, y he leído el diff `56eedb0dd5..b4fb24d2ce` entero: un commit, dos ficheros.

## **APTO**

Ninguna frase es falsa frente al informe de SERVIDOR-LOCAL (`20261122-1244`), y nada obligatorio de A–F se pierde (este commit no toca ninguna de esas frases).

| Frase | Por qué es cierta |
|---|---|
| «FlyWeb no guarda tu dirección IP ni la relaciona contigo, con tu cuenta o con tus datos: no está en los registros de sus servicios, y los de acceso se borran en unos 7 días» | §6 y §8: 0 IPv4 en sync, proxy, componentes y actualizaciones; `daily rotate 7`. La excepción de la web pública sigue escrita en la l. 60 («Esta web… sí registra la IP de las visitas»), así que no la contradice. |
| «Los sistemas de seguridad del servidor anotan IP para protegerlo de ataques, nunca relacionadas con los perfiles» | §5: fail2ban y el journal guardan IP. Ningún registro con IP lleva datos de cuenta, y los registros de la sync no llevan IP. |
| «Los avisos de la cuenta y las copias de seguridad, cifradas, se borran a los 30 días» (y la misma fila en la ayuda) | Los avisos se borran solos (§7). Las copias se borran a mano y hoy ninguna llega a 30 días: la primera es del 15-11 (§3). |
| «Lo que no guardamos: tu nombre ni tu IP: nunca la relacionamos con tu cuenta» | Es la sección de la cuenta; la sync y la cuenta no guardan IP. |

**Única condición, que no es de texto:** «se borran a los 30 días» exige purgar a tiempo, porque el borrado es manual. La primera copia cumple 30 días hacia el 15-12. SERVIDOR-LOCAL **no encontró en ns2** el aviso de `check-server.sh` para las copias de más de 30 días (§3). Conviene que la Auditoría confirme que el aviso existe, o lo ponga, antes de esa fecha.

365/335 va aparte, como dices.
