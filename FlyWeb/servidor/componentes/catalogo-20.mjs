// list_catalog.json para FlyWeb 2.0 (Brave 1.69, FilterListCatalogEntry en brave_shields/core/browser).
//
// Un solo catálogo unificado: las listas por defecto y la de primera parte van como entradas ocultas con los ID y las
// claves de sus componentes de la 1.x (se reutilizan: el mismo list.txt lo leen las dos versiones), y las regionales con
// los de siempre. Las banderas (hidden, default_enabled, first_party_protections, permission_mask, platforms) se copian
// del catálogo de Brave. Las entradas por defecto de listas.json son UNA lista fusionada (un solo componente): sale una
// sola entrada, la primera, y todas deben tener las mismas banderas (si no, no se genera nada).

const BANDERAS = ['hidden', 'default_enabled', 'first_party_protections', 'permission_mask', 'platforms']

// e: entrada del catálogo de Brave; k: { id, b64 } de nuestro componente.
export const entradaV2 = (e, k) => ({
  uuid: e.uuid, url: e.sources?.[0]?.url ?? '', title: e.title, langs: e.langs ?? [],
  support_url: e.support_url ?? e.sources?.[0]?.support_url ?? '', desc: e.desc ?? '',
  hidden: e.hidden ?? false, default_enabled: e.default_enabled ?? false,
  first_party_protections: e.first_party_protections ?? false, permission_mask: e.permission_mask ?? 0,
  ...(e.platforms && { platforms: e.platforms }),
  list_text_component: { component_id: k.id, base64_public_key: k.b64 }
})

// buscar(uuid) → entrada de Brave; clave(nombre) → { id, b64 }.
export function construirCatalogoV2 (listas, buscar, clave) {
  const salida = []
  const fusionada = (nombre, uuids) => {
    const es = uuids.map(buscar)
    if (!es.length) throw new Error(`${nombre}: listas.json no tiene entradas`)
    const fingerprint = (e) => JSON.stringify(BANDERAS.map((b) => e[b] ?? null))
    for (const e of es) {
      if (fingerprint(e) !== fingerprint(es[0])) {
        throw new Error(`${nombre}: ${e.uuid} y ${es[0].uuid} tienen banderas distintas en el catálogo de Brave; no se pueden fusionar`)
      }
    }
    salida.push(entradaV2(es[0], clave(nombre)))
  }
  fusionada('defecto', listas.defecto)
  fusionada('primera-parte', listas.primera_parte)
  for (const uuid of listas.regionales) salida.push(entradaV2(buscar(uuid), clave(`lista-${uuid}`)))
  return salida
}
