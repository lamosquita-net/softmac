import json,subprocess,os,sys,urllib.request,ssl,base64,re,shutil,time
ctx=ssl.create_default_context(cafile='/root/.ccr/ca-bundle.crt')
BASE={'chromium/chromium':('gh','chromium/chromium','128.0.6613.138'),
 'google/skia':('gh','google/skia','938144dd79c6e3664a3c0bbd019daedddf655ffa'),
 'google/angle':('gh','google/angle','713102774487cf1a8b3f433529eb8181cbcec31a'),
 'libyuv':('gs','libyuv/libyuv','a6a2ec654b1be1166b376476a7555c89eca0c275')}
def get(u,raw=True):
  for k in range(5):
    try: return urllib.request.urlopen(u,context=ctx,timeout=90).read()
    except urllib.error.HTTPError as e:
      if e.code==404: return None
      time.sleep(4*(k+1))
    except Exception: time.sleep(4*(k+1))
  return None
def diff(repo,sha):
  if repo=='libyuv':
    t=get(f"https://chromium.googlesource.com/libyuv/libyuv/+/{sha}%5E%21/?format=TEXT"); return base64.b64decode(t).decode()
  h={'chromium/chromium':'chromium.googlesource.com/chromium/src','google/skia':'skia.googlesource.com/skia','google/angle':'chromium.googlesource.com/angle/angle'}[repo]
  t=get(f"https://{h}/+/{sha}%5E%21/?format=TEXT"); return base64.b64decode(t).decode() if t else ''
def basefile(repo,path):
  k,r,rev=BASE[repo]
  if k=='gh': return get(f"https://raw.githubusercontent.com/{r}/{rev}/{path}")
  t=get(f"https://chromium.googlesource.com/{r}/+/{rev}/{path}?format=TEXT"); return base64.b64decode(t) if t else None
def check(repo,sha,wd):
  d=diff(repo,sha); 
  if os.path.exists(wd): shutil.rmtree(wd)
  os.makedirs(wd); open(wd+'/p.diff','w').write(d)
  files=re.findall(r'^diff --git a/(\S+) b/(\S+)',d,re.M)
  res={'files':len(files),'missing':[],'newfiles':0}
  for a,b in files:
    if re.search(r'^new file mode',d.split('diff --git a/'+a)[1].split('diff --git')[0],re.M): res['newfiles']+=1; continue
    c=basefile(repo,a)
    if c is None: res['missing'].append(a); continue
    os.makedirs(os.path.dirname(wd+'/t/'+a),exist_ok=True); open(wd+'/t/'+a,'wb').write(c)
  os.makedirs(wd+'/t',exist_ok=True)
  r=subprocess.run(['git','apply','--check','--verbose','../p.diff'],cwd=wd+'/t',capture_output=True,text=True)
  res['apply']=r.returncode==0; res['err']=[l for l in r.stderr.splitlines() if 'error' in l][:8]
  # per file
  pf={}
  for a,b in files:
    r2=subprocess.run(['git','apply','--check','--include='+a,'../p.diff'],cwd=wd+'/t',capture_output=True,text=True)
    pf[a]=r2.returncode==0
  res['perfile']=pf
  # fuzzy with patch
  r3=subprocess.run(['patch','-p1','--dry-run','-F3','-i','../p.diff'],cwd=wd+'/t',capture_output=True,text=True)
  res['patch_fuzz_ok']=r3.returncode==0; res['patch_out']=[l for l in r3.stdout.splitlines() if 'FAILED' in l or 'fuzz' in l or "can't find" in l.lower()][:10]
  return res
if __name__=='__main__':
  out={}
  for line in open(sys.argv[1]):
    cve,repo,sha=line.split()[:3]
    out[cve+' '+sha]=check(repo,sha,'w/'+cve+'-'+sha[:8])
    print(cve,sha[:10],json.dumps({k:v for k,v in out[cve+' '+sha].items() if k!='perfile'})[:600],flush=True)
  json.dump(out,open('results.json','w'),indent=1)
