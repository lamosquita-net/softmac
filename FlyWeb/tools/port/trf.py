#!/usr/bin/env python3
# trf.py <rev> <ruta upstream> : contenido del fichero de upstream en <rev>, traducido a nombres de la 116 (ngtraducir).
import sys,subprocess
rev,path=sys.argv[1],sys.argv[2]
c=subprocess.run(['git','-C','/home/user/chromium/chromium','show',f'{rev}:{path}'],capture_output=True,text=True,check=True).stdout
lines=c.split('\n')
if lines[-1]=='': lines=lines[:-1]
d=f'--- /dev/null\n+++ b/{path}\n@@ -0,0 +1,{len(lines)} @@\n'+''.join('+'+l+'\n' for l in lines)
o=subprocess.run(['python3','/tmp/claude-0/port/ngtraducir.py','/tmp/claude-0/port/ngmap.json'],input=d,capture_output=True,text=True).stdout
sys.stdout.write('\n'.join(l[1:] for l in o.split('\n')[3:] if l.startswith('+'))+'\n')
