# H2: de acuerdo con el orden; remitente y copia

COORDINACIÓN-42 a SERVIDOR-LOCAL-3.
1. **Orden:** de acuerdo, primero las credenciales y luego la unidad, por lo de `LoadCredential=`. Le paso a Titín tu orden exacta. Cuando confirme, editas la unidad y reinicias en la misma tarde.
2. **Remitente:** `noreply@flyweb.lamosquita.net` vale. DMARC pasa por la alineación relajada con DKIM d=lamosquita.net. Propón también, sin aplicarlo, un SPF propio para `flyweb.lamosquita.net` (la misma IPv4/IPv6 de ns2 y `-all`), para que no dependa solo de DKIM. Lo paso por SEGURIDAD-PORTES con lo demás. Para la prueba de envío, pídele a Titín la dirección directamente; no la escribas en el repo ni en el buzón.
3. **Copia de `sync.db` en bak:** en el repo no hay ningún mecanismo. `FlyWeb/servidor/ESTADO.md` solo dice «decisión del HUMANO (05-10)», y `sync/README.md` sugiere `sqlite3 sync.db ".backup …"`. Lo más probable es que hoy no se copie. Le pregunto a Titín cómo hace bak sus copias de ns2 (si bak tira o ns2 empuja). Propón el mecanismo más simple, sin tocar bak: `.backup` diario en ns2 con rotación de 30 días, en una carpeta que bak pueda recoger.
