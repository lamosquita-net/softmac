"""B2 en papel, última pasada: clasifica los 138 parches y 418 envoltorios (b2-ausentes.tsv) en se cae / se adapta / se reescribe / ya no hace falta.

Es el paso final de un proceso de varias pasadas hecho en la sesión INVESTIGACIÓN-MOTOR-8 (03-11-2026). Entradas (rutas de trabajo de aquella sesión,
ajustar `W`): los ficheros de b2-ausentes.py (lista y señales), b2-aplica.py (aplica/no aplica sobre 156), el historial de Brave con árboles
(`git fetch --filter=blob:none --shallow-since=2024-09-01 up v1.98.63`; el commit que borró cada fichero: `git log --diff-filter=D --no-renames --name-only -- patches chromium_src`),
una búsqueda de los identificadores `brave/BRAVE_*` de cada fichero en el árbol de 1.98 y la lista de plasters (`git ls-tree -r --name-only v1.98.63 rewrite`).
Las reglas (por asunto del commit de Brave y por ruta) están en `bucket()`; las tablas M y F al final son revisiones a mano de lo que las reglas
no resolvían o clasificaban mal. **Heurístico**: el asunto de un commit de Brave dice por qué quitó el fichero, no si FlyWeb lo sigue necesitando.
La salida es `datos/b2-ausentes.tsv`.
"""
import pickle,re,csv,collections,os
W='/tmp/claude-0/-home-user-softmac/f09290e6-bab8-53ca-8db7-b02163400c27/scratchpad/'
rows=pickle.load(open(W+'rows6.pkl','rb'))
DEADF=re.compile(r'wallet|ethereum|solana|zcash|bitcoin|filecoin|cardano|rewards|brave_ads|\bads\b|vpn|ai_chat|\bleo\b|ipfs|p3a|brave_news|\bnews\b|talk|playlist|speedreader|sidebar|\btor\b|psst|webcompat|brave_player|referral|skus|greaselion|ntp_background|sponsored|crypto wallet|web3|decentralized')
MOVED=re.compile(r'\bmoved?\b|renamed|rename|merged (into|under)|now `|under `//|split|migrate.*to `|`[^`]+` now ')
GONE=re.compile(r'delet|drop|not needed|no longer|obsolete|redundant|unused|unneeded|upstream|already (virtual|in)|removing patch|remove obsolete|remove unneeded|chromium.s browser|remove (any )?remnants|dependency removed|made redundant')
NEWM=re.compile(r'new overrides|new patching|patching approach|patching system|chromium_src. support|overrides approach|convert .* to new')
def bucket(x):
    s=re.sub(r'\s*\(#\d+\)','',x['del_asunto']); sl=s.lower(); p=x['fichero'].lower(); t=x['tipo']
    ev=lambda m: '%s (%s %s)'%(m,x['del_hash'],x['del_fecha'])
    if re.search(r'vertical tab|sidepanel|side_panel|tab_search|tab_drag|compound_tab|tab_strip_scroll|tabs/dragging',sl+' '+p) and t=='envoltorio': return 'se cae','interfaz de Brave (pestañas verticales, panel lateral); P5 pide usar la de Chromium; '+ev(s[:50])
    if x['plataforma']: return 'se cae','otra plataforma (%s); FlyWeb solo macOS'%x['plataforma']
    if (x['funcion'] and DEADF.search(x['funcion'])) or DEADF.search(sl) or DEADF.search(p): return 'se cae','función apagada o podable; '+ev(s[:55])
    if t=='envoltorio' and x['plaster']=='1' or (t=='envoltorio' and x.get('plaster')==1): return 'se adapta','plaster en rewrite/%s.yaml [V]; '%x['objetivo']+ev(s[:50])
    if re.search(r'plaster|ast-grep|make_virtual',sl): return 'se adapta','Brave lo reexpresa con plaster/ast-grep; '+ev(s[:50])
    if x['mov_exacto']: return 'se adapta','movido sin cambios a '+x['mov_exacto']
    if MOVED.search(sl): return 'se adapta','Chromium movió/renombró lo parcheado; '+ev(s[:55])
    if GONE.search(sl): return 'ya no hace falta','Chromium lo quitó o Brave adoptó lo de Chromium; '+ev(s[:55])
    if NEWM.search(sl): return 'se reescribe','Brave cambió de mecanismo (override WebUI nuevo); '+ev(s[:50])
    if re.search(r'reanchor|moves |derived classes under|introduced|`[^`]+` ->|not applicable|reinstate|overload|broken by|under `//brave|to new loc|refactor',sl): return 'se adapta','Brave tuvo que re-anclar o rehacer el override tras un cambio de Chromium; '+ev(s[:50])
    if re.search(r'remove (an )?override|remove #define|removed|simplify|cancel|overly permissive|enabled by default|support feature|fix ',sl): return 'ya no hace falta','Brave retiró o simplificó el override; '+ev(s[:55])
    if x['e128']==1 and x['e156']==0: return 'ya no hace falta','el fichero ya no existe en 156 por ese nombre; '+ev(s[:55])
    if 'conflict-resolved' in sl or re.search(r'chromium \d+ to chromium \d+',sl):
        if x.get('ap156')=='1': return 'se adapta','aplica sobre 156; Brave lo quitó en una subida de Chromium; '+ev('')
        return 'se reescribe','no aplica sobre 156; Brave lo quitó en una subida de Chromium; '+ev('')
    if t=='parche' and x.get('ap156') in('1',1): return 'se adapta','aplica sobre 156; Brave lo cambió por otro motivo: '+ev(s[:55])
    if t=='parche': return 'se reescribe','no aplica sobre 156; Brave lo cambió por otro motivo: '+ev(s[:55])
    return 'revisar','Brave lo quitó por otro motivo: '+ev(s[:55])
c=collections.Counter()
for x in rows:
    x['clase'],x['motivo']=bucket(x); c[(x['tipo'],x['clase'])]+=1
for k,v in sorted(c.items()): print(v,k)
pickle.dump(rows,open(W+'rows7.pkl','wb'))
for x in rows:
    if x['clase']=='revisar' : print(x['fichero'][:90],x['del_asunto'][:60])

# --- revisión manual de los 36 envoltorios sin clase automática (INVESTIGACIÓN-MOTOR-8, lectura del asunto del commit de Brave) ---
M={
 'base/json/json_reader.h':('ya no hace falta','Chromium usa la implementación Rust por defecto ([cr132])'),
 'component_updater/component_updater_utils':('se reescribe','sin commit en el historial desde 2024-09-02: Brave lo quitó antes; FlyWeb lo usa (serializador del actualizador de componentes): leer a mano'),
 'extensions/extension_service.cc':('se adapta','Brave rehízo el override de ComponentLoader ([cr137])'),
 'external_protocol/external_protocol_handler.h':('se cae','WebTorrent quitado de Brave (sin decisión en FlyWeb)'),
 'external_protocol_handler_unittest':('ya no hace falta','prueba'),
 'history_utils_unittest':('se reescribe','«Only use brave:// scheme for display» (#34610): Brave convierte brave:// a chrome:// al principio; hay que ver cómo lo hace flyweb:// (identidad)'),
 'profile_io_data':('se reescribe','«Only use brave:// scheme for display» (#34610): revisar con el esquema flyweb://'),
 'content/browser/webui/web_ui_impl.cc':('se reescribe','«Only use brave:// scheme for display» (#34610): revisar con el esquema flyweb://'),
 'content/renderer/render_thread_impl.cc':('se reescribe','«Only use brave:// scheme for display» (#34610): revisar con el esquema flyweb://'),
 'local_or_syncable_bookmark_sync_service_factory':('ya no hace falta','kNtpSimplificationBookmarkBar ya viene encendida [I]'),
 'browser_window_features.cc':('se adapta','Brave lo movió a //brave/browser/ui/browser_window/internal ([cr140])'),
 'recent_tabs_sub_menu_model_unittest':('ya no hace falta','prueba'),
 'browser_non_client_frame_view':('se adapta','renombrado en Chromium ([cr142], sin «NonClient»); afecta a las vistas de marco de macOS'),
 'rounded_omnibox_results_frame':('se adapta','[cr150] expone kElevation'),
 'translate_icon_view':('ya no hace falta','iconos de la barra de Brave [I]'),
 'host_content_settings_map.h':('revisar','asunto del commit: «Update check_chromium_src script»; sin más pistas'),
 'manta/features.cc':('ya no hace falta','[cr140] kMantaService ya viene por defecto'),
 'location_bar_model_util.cc':('se adapta','icono de Shields en la barra de direcciones (Shields es viva)'),
 'tracking_protection_onboarding':('revisar','Brave REVIRTIÓ el override que apagaba el onboarding de Tracking Protection: decidir a mano si FlyWeb lo quiere apagado (regla 20)'),
 'search_engine_choice_utils.cc':('revisar','Brave REVIRTIÓ el override que apagaba la comprobación del flag de elección de buscador: decidir a mano (DuckDuckGo por defecto)'),
 'sync/engine/model_type':('se adapta','sync: ModelType → DataType (renombrado)'),
 'crypto/symmetric_key':('ya no hace falta','KDF sin CHECKs: Chromium cambió a la interfaz kdf ([cr131])'),
 'google_api_keys-inc.cc':('se adapta','«not to be reincluded»: Brave cambió el override'),
}
for x in rows:
    if x['clase']=='revisar':
        for k,(c_,m_) in M.items():
            if k in x['fichero']: x['clase'],x['motivo']=c_,m_+'; '+('%s %s'%(x['del_hash'],x['del_fecha']) if x['del_hash'] else 'sin commit'); break
c=collections.Counter((x['tipo'],x['clase']) for x in rows)
print(sorted(c.items()))
pickle.dump(rows,open(W+'rows8.pkl','wb'))

# --- falsos positivos de la regla de funciones apagadas, corregidos a mano ---
F={
 'chrome_browsing_data_remover_delegate':('se adapta','plaster ([cr152]); la parte de IPFS cae con la poda'),
 'rss_links_fetcher_browsertest':('ya no hace falta','prueba; [cr150] código RSS movido a brave'),
 'chrome/browser/history/history_utils.cc':('se reescribe','«Only use brave:// scheme for display» (#34610): revisar con flyweb://'),
 'browser_navigator.cc':('se adapta','[cr149] browser_navigator pasó a su propio directorio'),
 'unexpire_flags.cc':('ya no hace falta','Brave quitó guardas de canal [I]'),
 'key_storage_kwallet':('se cae','KWallet es Linux/KDE (no cartera cripto); [cr149] Chromium borró os_crypt/sync'),
 'page_info/DEPS':('ya no hace falta','Brave quitó #define de page_info'),
 'accessibility_features.cc':('se adapta','ScreenAI (el ID de ScreenAI está previsto en brave-170-173)'),
 'extensions-sidebar.html':('ya no hace falta','página de extensiones de Chrome: el «sidebar» no es el de Brave [I]'),
 'absl/random/random.h':('ya no hace falta','limpieza de Brave'),
 'perf_benchmark.py':('se cae','herramientas de rendimiento de Brave'),
 'material_ui_color_mixer':('ya no hace falta','tema Nala de Brave; P5: usar el de Chromium'),
 'focus_ring':('ya no hace falta','tema Nala de Brave; P5: usar el de Chromium'),
}
for x in rows:
    for k,(c_,m_) in F.items():
        if k in x['fichero']:
            x['clase'],x['motivo']=c_,m_+('; %s %s'%(x['del_hash'],x['del_fecha']) if x['del_hash'] else ''); break
for x in rows:
    if x['tipo']=='envoltorio' and x.get('ident_faltan') and x['clase'] in ('se adapta','ya no hace falta'):
        x['clase']='se reescribe'; x['motivo']='los identificadores %s ya no están en el fichero de 156; '%x['ident_faltan'][:60]+x['motivo']
rows.sort(key=lambda x:(x['tipo'],x['fichero']))
cols=['tipo','fichero','objetivo','clase','motivo','e128','e156','ap128','ap156','ap156_c1','ident_faltan','plaster','plataforma','funcion','modificado_flyweb','mov_exacto','del_hash','del_fecha','del_asunto']
with open(W+'b2-ausentes.tsv','w',newline='') as fh:
    w=csv.DictWriter(fh,fieldnames=cols,delimiter='\t',extrasaction='ignore'); w.writeheader(); w.writerows(rows)
c=collections.Counter((x['tipo'],x['clase']) for x in rows); print(sorted(c.items()))
pickle.dump(rows,open(W+'rows9.pkl','wb'))
