# SERVIDOR-LOCAL → COORDINACIÓN-66: por qué el correo del código cae en Spam de Gmail (ns2, solo lectura, DNS desde ns2)

## Lo comprobado: la autenticación está bien
| Punto | Resultado |
|---|---|
| SPF `lamosquita.net` | incluye la IPv4 de ns2 y su /64 IPv6; `~all` |
| DKIM | selector `ns2`, RSA 2048, `d=lamosquita.net`, alineado con `From: noreplyflyweb@lamosquita.net`; se firmó en los dos envíos |
| DMARC | `p=quarantine; pct=30`; con SPF y DKIM alineados pasa |
| PTR / HELO | IPv4 e IPv6 de salida con PTR `smtp2.lamosquita.net` que resuelve de vuelta; HELO igual |
| IPv6 | hay salida IPv6 (el de las 21:16 salió por IPv6), con PTR y en el SPF |
| TLS de salida | `smtp_tls_security_level = may` |
| Listas negras (IPv4) | sin entrada en Spamhaus ZEN, SpamCop ni Barracuda |
| Entregas a Gmail en los registros | 32 aceptadas, 0 aplazadas o rebotadas |
| Retraso | Postfix entregó cada código en ≤1,5 s y Gmail contestó 250: la demora, si la hubo, fue después, en Gmail |

## Causa probable (no demostrada)
No veo fallo técnico. Queda el filtro de Gmail: remitente nuevo y de muy poco volumen, mensaje corto en texto plano con un código, y la frase «alguien conoce tu contraseña: cámbiala», típica de suplantación. La reputación de la IP compartida con otros dominios de ns2 no la puedo medir.

## Falta, de Titín (decide)
En Gmail, en uno de los dos correos: ⋮ → «Mostrar original». Copiar solo: la tabla de arriba (SPF, DKIM, DMARC y «entregado en N segundos») y el bloque `Authentication-Results`, **tachando su dirección**. Y la frase del aviso «¿Por qué está este mensaje en Spam?».

## Propuesta (nada aplicado; todo con el sí de Titín)
1. Ya, sin servidor: «No es spam» y un filtro en su Gmail para `from:noreplyflyweb@lamosquita.net` → «No enviar nunca a Spam». Solo arregla su cuenta.
2. Texto del código (PR en la sync, hay que instalar binario): quitar o suavizar «alguien conoce tu contraseña: cámbiala».
3. Pantalla del cliente y web: «Si no lo ves, mira en Spam».
4. Comprobar que `noreplyflyweb@lamosquita.net` existe como buzón o alias en Workspace (no lo puedo ver).
5. Google Postmaster Tools para `lamosquita.net` (un TXT de verificación en DNS) para ver reputación real.
No recomiendo tocar DMARC, SPF ni DKIM por esto.
