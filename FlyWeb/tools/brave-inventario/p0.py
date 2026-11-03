import subprocess, re, os, sys, json, collections
R='/home/user/lamosquita-net/brave-core'  # ruta del checkout de brave-core
files=subprocess.check_output(['git','-C',R,'ls-files','-z']).decode('utf8','replace').split('\0')
files=[f for f in files if f]
BIN=re.compile(r'\.(png|jpg|jpeg|gif|icns|ico|woff2?|ttf|otf|pdf|zip|gz|webp|mp4|webm|ogg|mp3|wav|bin|dat|jar|aar|so|a|dylib|riv|lottie|car)$',re.I)
# (feature, estado, regex sobre ruta en minusculas)
RULES=[
 ('wallet','muerta',r'brave_wallet|wallet|ethereum|solana|zcash|bitcoin|filecoin|decentralized_dns|crypto_wallets|trezor|web3|ledger_bridge|unstoppable'),
 ('rewards/ads/skus','muerta',r'brave_rewards|rewards|brave_ads|(^|/)ads(/|_)|bat_ads|bat-ads|challenge_bypass|(^|/)skus|brave_adaptive_captcha|greaselion|brave_referrals|referral|ad_notification|ntp_background_images|sponsored|brave_mobile_subscription|mobile_subscription'),
 ('ai (Leo/Rewriter)','muerta',r'ai_chat|ai_rewriter|leo_assistant|/leo/|brave_leo|aichat'),
 ('vpn','muerta',r'brave_vpn|(^|/)vpn'),
 ('news','muerta',r'brave_news|(^|/)news(/|_)'),
 ('ipfs','muerta',r'ipfs'),
 ('player/psst/webcompat/day_zero','muerta',r'brave_player|psst|webcompat|day_zero|script_injector'),
 ('p3a/stats/metricas','muerta',r'p3a|brave_stats|misc_metrics|brave_federated|time_period_storage|web_discovery'),
 ('talk','muerta',r'brave_talk|(^|/)talk'),
 ('tor','sin decision',r'(^|[/_-])tor([/_-]|$)|onion'),
 ('speedreader','sin decision',r'speedreader'),
 ('playlist','sin decision',r'playlist'),
 ('sidebar','sin decision',r'sidebar'),
 ('webtorrent/wayback/search/commander','sin decision',r'webtorrent|wayback|brave_search|commander|request_otr|brave_private_new_tab|(^|/)hub/'),
 ('NTP/bienvenida de Brave (sustituidas)','reemplazada',r'brave_new_tab_ui|brave_welcome|ntp_|new_tab|onboarding|welcome'),
 ('Shields y privacidad','viva',r'brave_shields|adblock|ad_block|cosmetic|debounce|query_filter|url_sanitizer|farbling|https_upgrade|de_amp|ephemeral_storage|brave_page_graph|brave_perf_predictor|body_sniffer|rpill|safe_builtins|privacy_sandbox|localhost_permission|content_settings|permissions'),
 ('sync','viva',r'brave_sync|(^|/)sync|sync_device_info'),
 ('updater/componentes/servicios','viva',r'component_updater|update_client|brave_service_keys|brave_domains|constants|variations|version_info|widevine|safe_browsing|safebrowsing|captive_portal'),
 ('identidad/l10n/recursos','viva',r'strings|l10n|locales|\.grd|\.xtb|vector_icons|theme|branding|flyweb|resources|img/|policy|first_run|shell_integration|^app/'),
]
RULES=[(n,e,re.compile(p)) for n,e,p in RULES]
def feat(path):
    p=path.lower()
    for n,e,rx in RULES:
        if rx.search(p): return n,e
    return 'resto (nucleo/UI/otros)','resto'
def cat(path):
    top=path.split('/')[0]
    if top=='patches': return 'patches'
    if top=='chromium_src': return 'chromium_src'
    if top=='ios': return 'ios'
    if top=='android': return 'android'
    if top=='third_party': return 'third_party'
    if top=='test' or '/test/' in path or re.search(r'(_unittest|_browsertest|_test)\.(cc|mm|ts|tsx|js|kt|java|swift)$',path) or 'storybook' in path: return 'tests'
    return 'src'
agg=collections.defaultdict(lambda:[0,0,0])
tot=collections.defaultdict(lambda:[0,0,0])
rows=[]
content={}
for f in files:
    full=os.path.join(R,f)
    try:
        st=os.lstat(full)
        if os.path.islink(full): size=0; lines=0; data=b''
        else:
            size=st.st_size
            if BIN.search(f): lines=0; data=b''
            else:
                data=open(full,'rb').read(); lines=data.count(b'\n')
    except Exception: size=lines=0; data=b''
    fe,es=feat(f); c=cat(f)
    a=agg[(fe,es,c)]; a[0]+=1;a[1]+=lines;a[2]+=size
    t=tot[c]; t[0]+=1;t[1]+=lines;t[2]+=size
    if c in('patches','chromium_src','src') and data and len(data)<2_000_000:
        content[f]=data
json.dump({'agg':{'|'.join(k):v for k,v in agg.items()},'tot':dict(tot)},open(sys.argv[1],'w'))
# referencias a funciones muertas desde ficheros de otras funciones
DEADRX={n:rx for n,e,rx in RULES if e=='muerta'}
INC=re.compile(rb'(?:brave/|//brave/)((?:components|browser|ios|android|ui|common|renderer|utility|services|app|chromium_src)/[A-Za-z0-9_\-./]+)')
edge=collections.Counter(); ex=collections.defaultdict(list)
patch_dead=collections.Counter(); patch_total=0; patch_only=0
cs_dead=0; cs_total=0
for f,data in content.items():
    fe,es=feat(f); c=cat(f)
    refs=set()
    for m in INC.finditer(data):
        r=m.group(1).decode('utf8','ignore').lower()
        for n,rx in DEADRX.items():
            if rx.search(r): refs.add(n)
    if c=='patches':
        patch_total+=1
        # funcion muerta por nombre del parche (fichero de Chromium que toca) o por contenido
        if es=='muerta' or refs: patch_dead['toca/refiere funcion muerta']+=1
        if refs: 
            for n in refs: patch_dead[n]+=1
        if es=='muerta' and not refs: patch_dead['solo nombre']+=1
    if c=='chromium_src':
        cs_total+=1
        if es=='muerta' or refs: cs_dead+=1
    if es in ('viva','resto','sin decision','reemplazada') and refs and c in('src','chromium_src'):
        comp='/'.join(f.split('/')[:2]) if c=='src' else 'chromium_src'
        for n in refs:
            edge[(comp,n)]+=1
            if len(ex[(comp,n)])<2: ex[(comp,n)].append(f)
out={'patch_total':patch_total,'patch_dead':dict(patch_dead),'cs_total':cs_total,'cs_dead':cs_dead,
     'edges':[[k[0],k[1],v,ex[k]] for k,v in edge.most_common(60)]}
json.dump(out,open(sys.argv[1]+'.dep','w'),indent=1)
print('ok',len(files))
