# LOCAL-25 (copia de LOCAL-24; M3_PARAR=1 para tras tres rápidas seguidas) · LOCAL-24 (copia de LOCAL-23, con MODOS=m3) · conductor CDP de M1 (multihilo-multigpu.md §6 y §2.3), desde la 7,1 por el túnel.
# PUERTO, SALIDA (carpeta), MODOS=aq,mm,bat,video,basemark, RAPIDO=1 (ensayo corto).
# Cada caso guarda su ventana de tiempo con el reloj de la página, que es el de la 6,1 y el del muestreador.
import statistics
import base64, json, os, sys, time
sys.path.insert(0, '/Users/titin/proyectos/softmac/temp/local20/p300')
import cdpc

PUERTO = int(os.environ.get('PUERTO', '9523'))
SAL = os.environ['SALIDA']
# basemark, fuera de lo de serie: publica el resultado en su web. Solo si Titín lo sabe y dice que sí.
MODOS = os.environ.get('MODOS', 'aq,mm,bat,video').split(',')
RAP = bool(os.environ.get('RAPIDO'))
CALENTAR, MEDIR = (3, 5) if RAP else (12, 30)
U = 'http://127.0.0.1:8125/'
YT = 'https://www.youtube.com/watch?v=LXb3EKWsInQ'

res = {'modos': MODOS, 'casos': []}


def P(*a):
    print(time.strftime('%H:%M:%S'), *a, flush=True)


b = None
fin = time.time() + 360
while time.time() < fin:
    try:
        b = cdpc.Browser(PUERTO)
        break
    except Exception:
        time.sleep(2)
if not b:
    P('sin navegador')
    sys.exit(1)
os.makedirs(SAL, exist_ok=True)


def guarda():
    with open(os.path.join(SAL, 'resultados.json'), 'w') as f:
        json.dump(res, f, indent=1, ensure_ascii=False)


inicial = b.pages()[0]['targetId']
sid = b.attach(inicial)
b.ws.call('Page.enable', sid=sid)


def ev(expr, s=None, gesto=False):
    return b.ev(s or sid, expr, gesture=gesto)


def ve(url, espera, s=None):
    b.ws.events = []
    b.nav(s or sid, url, espera)


def ahora(s=None):
    return ev('Date.now()/1000', s)


def entorno(s=None):
    return ev('({url:location.href,titulo:document.title,dpr:devicePixelRatio,vista:[innerWidth,innerHeight],'
              'visible:document.visibilityState,foco:document.hasFocus(),'
              'lienzos:[...document.querySelectorAll("canvas")].slice(0,8).map(c=>[c.width,c.height])})', s)


def captura(nombre, s=None):
    d = b.ws.call('Page.captureScreenshot', {'format': 'jpeg', 'quality': 55}, s or sid).get('result', {}).get('data')
    if d:
        with open(os.path.join(SAL, nombre + '.jpg'), 'wb') as f:
            f.write(base64.b64decode(d))


def rechaza_cookies(s=None):
    # Solo la opción más privada; si no hay botón de rechazar, no se pulsa nada.
    return ev(r'''(()=>{const r=/^(rechazar( todo| todas)?|reject( all)?|decline( all)?)$/i;
      const b=[...document.querySelectorAll('button,[role=button]')].find(x=>r.test((x.innerText||'').trim()));
      if(b){b.click();return true}return false})()''', s, True)


def fps_raf(seg, s=None):
    return ev('''new Promise(fin=>{let n=0,peor=0,seg=[],m=0;const t0=performance.now();let u=t0,ts=t0;
      const f=t=>{n++;m++;peor=Math.max(peor,t-u);u=t;if(t-ts>=1000){seg.push(+(m*1000/(t-ts)).toFixed(1));m=0;ts=t}
        if(t-t0<%d)requestAnimationFrame(f);else fin({fps:+(n*1000/(t-t0)).toFixed(1),peor:Math.round(peor),muestras:seg})};
      requestAnimationFrame(f);setTimeout(()=>fin({fps:null,error:'sin fotogramas',cuadros:n}),%d)})'''
              % (seg * 1000, seg * 1000 + 10000), s)


def mide(nombre, s=None, extra=None):
    env = entorno(s)
    t0 = ahora(s)
    r = fps_raf(MEDIR, s)
    caso = {'caso': nombre, 't0': t0, 't1': ahora(s), 'entorno': env, 'raf': r}
    if extra:
        caso['extra'] = ev(extra, s)
    res['casos'].append(caso)
    guarda()
    P(nombre, r, caso.get('extra', ''))


def protegido(nombre, f, *a):
    try:
        f(*a)
    except Exception as e:
        res['casos'].append({'caso': nombre, 'error': repr(e)[:300]})
        guarda()
        P('FALLO', nombre, repr(e)[:200])


def espera_red():
    # Con LuLu sin aprobar no llega ni a 127.0.0.1: se deja la app abierta y se reintenta.
    fin = time.time() + (30 if RAP else 900)
    n = 0
    while time.time() < fin:
        n += 1
        ev('location.href=%s' % json.dumps(U + 'raf.html?dur=1000'))
        time.sleep(8)
        if ev('document.title') == 'raf':
            return True
        if n == 1:
            P('SIN RED: posible LuLu')
        time.sleep(7)
    return False


def aquarium(peces, lado, pasada):
    ve(U + f'webglsamples/aquarium/aquarium.html?numFish={peces}&canvasWidth={lado}&canvasHeight={lado}', CALENTAR)
    mide(f'Aquarium {peces} lienzo {lado} pasada {pasada}', extra='g_fpsTimer.averageFPS')


def motionmark():
    for k in range(4):
        ve('about:blank', 10 if k else 2)
        ve(U + 'motionmark1.3.2/MotionMark/index.html', 8)
        fr = ev("document.getElementById('frame-rate-label')?.textContent") or ''
        if '60fps' in fr or RAP:
            break
    ev('''(()=>{window.__m=[];benchmarkRunnerClient.willRunTest=(s,t)=>__m.push({prueba:t.name,t0:Date.now()/1000});
      const d=benchmarkRunnerClient.didRunTest;
      benchmarkRunnerClient.didRunTest=function(x){if(__m.length)__m[__m.length-1].t1=Date.now()/1000;return d.call(this,x)}})()''')
    env = entorno()
    ev('void benchmarkController.startBenchmark()', gesto=True)
    if RAP:
        time.sleep(12)
        res['casos'].append({'caso': 'MotionMark (ensayo)', 'pruebas': ev('__m'), 'entorno': env})
        guarda()
        P('MotionMark (ensayo)', ev('__m'))
        return
    fin = time.time() + 1200
    txt = None
    while time.time() < fin:
        time.sleep(10)
        txt = ev("document.querySelector('#results.selected')?document.querySelector('#results').innerText:''")
        if txt:
            break
    res['casos'].append({'caso': 'MotionMark 1.3.2', 'frecuencia': fr, 'pruebas': ev('__m'), 'entorno': env, 'texto': txt})
    guarda()
    P('MotionMark', (txt or 'sin resultado')[:400].replace('\n', ' '))


def web(nombre, url, espera):
    ve(url, espera)
    if rechaza_cookies():
        time.sleep(espera)
    captura(nombre)
    mide(nombre)


YT_4K = ('(()=>{const p=document.getElementById("movie_player");if(!p)return "sin reproductor";'
         'p.setPlaybackQualityRange("hd2160","hd2160");p.playVideo();return p.getAvailableQualityLevels()})()')
YT_DATOS = ('(()=>{const p=document.getElementById("movie_player"),v=document.querySelector("video");'
            'if(!p||!v)return null;const q=v.getVideoPlaybackQuality(),s=p.getStatsForNerds?p.getStatsForNerds():{};'
            'return {calidad:p.getPlaybackQuality(),wh:[v.videoWidth,v.videoHeight],total:q.totalVideoFrames,'
            'perdidos:q.droppedVideoFrames,codec:s.codecs,resolucion:s.resolution}})()')


def video():
    ve(YT, 12)
    if rechaza_cookies():
        time.sleep(10)
    # Durante un anuncio solo se ofrecen las calidades del anuncio (hasta 1080p): esperar a que aparezca la 4K.
    fin = time.time() + 60
    while time.time() < fin:
        ev('document.getElementById("movie_player")?.mute?.()', gesto=True)
        niveles = ev(YT_4K, gesto=True)
        if isinstance(niveles, list) and 'hd2160' in niveles:
            break
        time.sleep(8)
    P('YouTube', niveles)
    time.sleep(12)
    captura('youtube-4k')
    antes = ev(YT_DATOS)
    mide('YouTube 4K solo', extra=YT_DATOS)
    res['casos'][-1]['antes'] = antes

    # Segunda ventana al lado: las dos quedan a la vista, dos cargas a la vez.
    tid, s2 = b.new('about:blank', window=True)
    for destino, izq in ((inicial, 0), (tid, 1500)):
        w = b.ws.call('Browser.getWindowForTarget', {'targetId': destino}).get('result', {}).get('windowId')
        if w:
            b.ws.call('Browser.setWindowBounds', {'windowId': w,
                      'bounds': {'left': izq, 'top': 30, 'width': 1500, 'height': 1250}})
    ve(U + 'webglsamples/aquarium/aquarium.html?numFish=5000', 15, s2)
    antes = ev(YT_DATOS)
    mide('Aquarium 5000 con YouTube 4K al lado', s2, 'g_fpsTimer.averageFPS')
    res['casos'][-1]['video'] = {'antes': antes, 'despues': ev(YT_DATOS), 'visible': ev('document.visibilityState')}
    guarda()
    b.ws.call('Target.closeTarget', {'targetId': tid})


def basemark():
    ve('https://web.basemark.com/', 12)
    rechaza_cookies()
    captura('basemark-inicio')
    env = entorno()
    t0 = ahora()
    pulsado = ev(r'''(()=>{const b=[...document.querySelectorAll('button,a,[role=button],input[type=button]')]
      .find(x=>/^start/i.test((x.innerText||x.value||'').trim()));if(b){b.click();return true}return false})()''', gesto=True)
    txt, hecho = '', False
    fin = time.time() + (1500 if pulsado else 0)
    while time.time() < fin:
        time.sleep(20)
        txt = ev('document.body?document.body.innerText.slice(0,3000):""') or ''
        if 'result' in (ev('location.href') or '').lower():
            time.sleep(8)
            txt, hecho = ev('document.body.innerText.slice(0,3000)'), True
            break
    captura('basemark-fin')
    res['casos'].append({'caso': 'Basemark Web 3.0', 't0': t0, 't1': ahora(), 'entorno': env,
                         'pulsado': pulsado, 'terminado': hecho, 'url': ev('location.href'), 'texto': txt})
    guarda()
    P('Basemark', pulsado, hecho, str(txt)[:300])


res['navegador'] = b.version
if not espera_red():
    P('sin red: lo dejo')
    guarda()
    b.close()
    sys.exit(2)
res['webgl'] = ev("(()=>{const g=document.createElement('canvas').getContext('webgl');"
                  "const e=g&&g.getExtension('WEBGL_debug_renderer_info');"
                  "return e?g.getParameter(e.UNMASKED_RENDERER_WEBGL):null})()")
res['pantalla'] = ev('({ancho:screen.width,alto:screen.height,dpr:devicePixelRatio,hilos:navigator.hardwareConcurrency})')
if os.environ.get('VERSION_PAG'):
    ve('chrome://version', 3)
    res['version_pag'] = ev('document.body.innerText')
guarda()
P(res['navegador'].get('Browser'), res['webgl'], res['pantalla'])

if 'aq' in MODOS:
    # (peces, lado, pasadas): 1024 es el de serie; 512 y 2048 son el barrido de píxeles.
    plan = ((5000, 1024, 1),) if RAP else ((5000, 1024, 3), (5000, 512, 1), (5000, 2048, 1),
                                           (15000, 1024, 5), (15000, 512, 3), (15000, 2048, 3))
    for peces, lado, n in plan:
        for i in range(1, n + 1):
            protegido(f'Aquarium {peces}/{lado}', aquarium, peces, lado, i)
    ve('about:blank', 1 if RAP else 10)

def procesos():
    # PID y tipo de cada proceso hijo (renderer, GPU), para saber si cada pasada estrena renderer.
    try:
        r = b.ws.call('SystemInfo.getProcessInfo').get('result', {}).get('processInfo', [])
        return [[p.get('id'), p.get('type')] for p in r]
    except Exception as e:
        return repr(e)[:120]


def m3_pasada(i):
    # multihilo-multigpu.md §10.4 paso 1: fps cada segundo (raf.muestras), entorno (visible, foco), PID del renderer.
    ve(U + 'webglsamples/aquarium/aquarium.html?numFish=15000&canvasWidth=1024&canvasHeight=1024', CALENTAR)
    antes = procesos()
    if os.environ.get('SAMPLE'):
        # La tanda de la 6,1 atiende la petición en ≤ 5 s: el sample (5 s) cae dentro de los 30 s de medida.
        open(os.path.join(os.environ['SAMPLE'], f'pedir-sample-rend-p{i:02d}'), 'w').close()
    mide(f'M3 Aquarium 15000 lienzo 1024 pasada {i}', extra='g_fpsTimer.averageFPS')
    res['casos'][-1]['procesos'] = {'antes': antes, 'despues': procesos()}
    guarda()


if 'm3' in MODOS:
    # LOCAL-24: 12 pasadas seguidas en la misma pestaña; about:blank 5 s entre pasadas.
    rapidas = 0
    for i in range(1, (2 if RAP else int(os.environ.get('M3_MAX', '12'))) + 1):  # M3_MAX: mini tanda de VRAM
        protegido(f'M3 pasada {i}', m3_pasada, i)
        ve('about:blank', 5)
        # LOCAL-25 (§10.7, repetición (a)): hasta tres rápidas seguidas (≥ 55 fps), máximo doce.
        try:
            # La media incluía los ~5 s de la toma de sample (3–8 fps) y ninguna pasada llegaba a 55 (fallo visto en
            # l25-m3a): se usa la mediana por segundo, que la toma no mueve.
            fps = statistics.median(res['casos'][-1]['raf']['muestras'])
        except Exception:
            fps = 0
        rapidas = rapidas + 1 if fps >= 55 else 0
        if os.environ.get('M3_PARAR') and rapidas >= 3:
            P(f'M3: tres rápidas seguidas en la pasada {i}; paro')
            break

def espera_valor(expr, tope, paso, samples=()):
    # samples: segundos desde el inicio en los que pedir un sample del renderer (M2 §9.6 paso 1).
    t0 = time.time(); pend = sorted(samples)
    while time.time() - t0 < tope:
        time.sleep(paso)
        while pend and time.time() - t0 >= pend[0] and os.environ.get('SAMPLE'):
            open(os.path.join(os.environ['SAMPLE'], 'pedir-sample-rend-%s-%03d' % (ETQ_ACT, pend.pop(0))), 'w').close()
        try:
            v = ev(expr)
        except Exception:
            v = None
        if v:
            return v, round(time.time() - t0)
    return None, round(time.time() - t0)


NP = int(os.environ.get('PASADAS', '1'))
SMP = [int(x) for x in os.environ.get('SEG_SAMPLE', '').split(',') if x]
ETQ_ACT = ''


def speedometer(i):
    global ETQ_ACT
    ETQ_ACT = f'sp{i}'
    ve(U + 'speedometer3.1/index.html', 8)
    env = entorno(); t0 = ahora()
    ev("document.querySelector('.start-tests-button').click()", gesto=True)
    v, s = espera_valor("location.hash=='#summary' && document.getElementById('result-number').textContent.trim() ? "
                        "document.getElementById('result-number').textContent.trim()+' '+"
                        "document.getElementById('confidence-number').textContent.trim() : ''", 1800, 5, SMP)
    res['casos'].append({'caso': f'Speedometer 3.1 pasada {i}', 'resultado': v, 'seg': s, 't0': t0, 't1': ahora(),
                         'entorno': env, 'samples': SMP})
    guarda()
    P(f'Speedometer 3.1 pasada {i}: {v} ({s} s)')


def jetstream(i):
    global ETQ_ACT
    ETQ_ACT = f'js{i}'
    ve(U + 'jetstream3/index.html', 6)
    lista = ev(os.environ.get('JSLISTA', "BENCHMARKS.filter(b=>b.tags.has('default')).map(b=>b.name)"
                              ".filter(n=>n!='web-ssr').join(',')"))
    ve(f'{U}jetstream3/index.html?startAutomatically=true&test={lista}', 5)
    env = entorno(); t0 = ahora()
    v, s = espera_valor("document.getElementById('result-summary')?.classList.contains('done') ? "
                        "document.querySelector('#result-summary .score')?.textContent : ''", 3000, 15, SMP)
    malos = ev("[...document.querySelectorAll('.benchmark-error')].map(e=>e.id)")
    res['casos'].append({'caso': f'JetStream 3 pasada {i}', 'resultado': v, 'seg': s, 't0': t0, 't1': ahora(),
                         'entorno': env, 'en_error': malos, 'lista': lista, 'samples': SMP})
    guarda()
    P(f'JetStream 3 pasada {i}: {v} ({s} s); en error: {malos}')


if 'sp' in MODOS:
    for i in range(1, NP + 1):
        protegido(f'Speedometer {i}', speedometer, i)
        ve('about:blank', 10)

if 'js' in MODOS:
    for i in range(1, NP + 1):
        protegido(f'JetStream {i}', jetstream, i)
        ve('about:blank', 10)

if 'mm' in MODOS:
    protegido('MotionMark', motionmark)

if 'bat' in MODOS:
    for nombre, url, espera in (
            ('webglreport', 'https://webglreport.com/?v=2', 8),
            ('threejs-bloom', 'https://threejs.org/examples/webgl_postprocessing_unreal_bloom.html', 15),
            ('threejs-keyframes', 'https://threejs.org/examples/webgl_animation_keyframes.html', 15),
            ('threejs-shadowmap', 'https://threejs.org/examples/webgl_shadowmap.html', 15),
            ('babylon-sponza', 'https://www.babylonjs.com/demos/sponza/', 30),
            ('google-earth', 'https://earth.google.com/web/@40.4168,-3.7038,700a,1200d,35y,0h,65t,0r', 35),
            ('photopea', 'https://www.photopea.com/', 15),
            ('shadertoy-seascape', 'https://www.shadertoy.com/view/Ms2SD1', 15),
            ('shadertoy-elevated', 'https://www.shadertoy.com/view/MdX3Rr', 15),
            ('vsynctester', 'https://www.vsynctester.com/', 12)):
        # SOLO=nombre,nombre: repetir solo esos casos de la batería.
        if not os.environ.get('SOLO') or nombre in os.environ['SOLO'].split(','):
            protegido(nombre, web, nombre, url, espera)

if 'video' in MODOS:
    protegido('YouTube 4K', video)

if 'basemark' in MODOS:
    protegido('Basemark', basemark)

guarda()
P('FIN del conductor')
try:
    b.close()
except Exception:
    pass
