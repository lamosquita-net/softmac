import json,urllib.request,ssl,time,subprocess,os
ctx=ssl.create_default_context(cafile='/root/.ccr/ca-bundle.crt')
d=json.load(open('gl150-commits.json'))
def gj(u):
  for k in range(6):
    try: return json.loads(urllib.request.urlopen(u,context=ctx,timeout=90).read().decode()[5:])
    except Exception: time.sleep(5*(k+1))
os.makedirs('angleall',exist_ok=True)
if not os.path.exists('angleall/.git'): subprocess.run(['git','init','-q','angleall'])
F={}
for cve,v in d.items():
  for r,s,dt,m in v['commits']:
    if m.startswith('Roll ') or s in F: continue
    if r=='chromium/chromium':
      j=gj(f"https://chromium.googlesource.com/chromium/src/+/{s}?format=JSON")
      F[s]=[x.get('new_path') if x.get('new_path')!='/dev/null' else x.get('old_path') for x in (j or {}).get('tree_diff',[])]
    else:
      subprocess.run(['git','-C','angleall','fetch','-q','--depth','2','--filter=blob:none','https://github.com/google/angle',s],capture_output=True)
      F[s]=subprocess.run(['git','-C','angleall','diff','--name-only',s+'^',s],capture_output=True,text=True).stdout.split()
    print(cve,s[:10],len(F[s]),flush=True)
    time.sleep(1)
json.dump(F,open('gl150-files.json','w'),indent=1)
