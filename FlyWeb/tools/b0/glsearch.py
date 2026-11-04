import json,subprocess,time,sys
d=json.load(open('cr/gl150.json'))
out={}
for cve,(m,sev,bid,desc) in sorted(d.items()):
  if sev not in('Critical','High'): continue
  hits=[]
  for r in ('chromium/chromium','google/angle'):
    for k in range(3):
      p=subprocess.run(['gh','api','-X','GET','search/commits','-f',f'q={bid} repo:{r}','--jq','.items[] | [.sha, .commit.committer.date[:10], (.commit.message|split("\n")[0])] | @tsv'],capture_output=True,text=True)
      if p.returncode==0: break
      time.sleep(30)
    for l in p.stdout.splitlines():
      s,dt,msg=l.split('\t',2); hits.append((r,s,dt,msg))
    time.sleep(2.2)
  out[cve]={'m':m,'sev':sev,'bug':bid,'desc':desc,'commits':hits}
  print(cve,m,sev,bid,len(hits),flush=True)
json.dump(out,open('gl150-commits.json','w'),indent=1)
