#!/usr/bin/env python3
# audit.py <área>: ficheros que el diff traducido de cada commit toca y que el commit del área no cambió (posible
# pérdida silenciosa en m3.sh). MOTOR-13.
import sys,subprocess,re,os
A=sys.argv[1]; W=f'/tmp/claude-0/port/w-{A}'; P='/tmp/claude-0/port'
log=subprocess.run(['git','-C',W,'log','--format=%H %s'],capture_output=True,text=True).stdout.split('\n')
for l in log:
    if not l: continue
    h,s=l.split(' ',1); c=s.split()[0]
    if not re.fullmatch(r'[0-9a-f]{11}',c): continue
    dp=f'{P}/{c}.ng.diff'
    if not os.path.exists(dp): continue
    want=set(re.findall(r'^\+\+\+ b/(\S+)',open(dp).read(),re.M))
    got=set(subprocess.run(['git','-C',W,'show','--name-only','--format=',h],capture_output=True,text=True).stdout.split())
    miss=[f for f in want-got if os.path.exists(os.path.join(W,f)) or True]
    miss=[f for f in miss if not re.search(r'selectlist|permission_shadow|selectmenu|about_flags|flag_descriptions|flag-metadata|android_webview|fieldtrial',f)]
    if miss: print(c, s[12:70], '|', ' '.join(m.replace('third_party/blink/renderer/','') for m in sorted(miss)))
