# ftc.py <etiqueta>... : estado de cada función en testing/variations/fieldtrial_testing_config.json por versión
# (estudios con «mac», primer experimento, que es el que aplica Chromium). Lee sw/ftc-<etiqueta>.json (de
# `git show <etiqueta>:testing/variations/fieldtrial_testing_config.json`) y deja ftc.pkl para compararlo con el
# valor por defecto del código (MOTOR-9, nivel 130, motor.md §10). Brave compila sin esta configuración.
import json,sys,glob,re
def load(p):
    d=json.load(open(p))
    st={}
    for study,cfgs in d.items():
        for cfg in cfgs:
            if 'mac' not in cfg.get('platforms',[]): continue
            exps=cfg.get('experiments',[])
            if not exps: continue
            e=exps[0]
            for f in e.get('enable_features',[]): st[f]=('on',study)
            for f in e.get('disable_features',[]): st[f]=('off',study)
            break
    return st
tags=sys.argv[1:]
S={t:load(f'sw/ftc-{t}.json') for t in tags}
import pickle; pickle.dump(S,open('ftc.pkl','wb'))
for t in tags: print(t,len(S[t]))
