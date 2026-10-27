# Uso: chkint.py <dir gen> → interceptores generados con la API v8::Intercepted:
# toda función que devuelve v8::Intercepted debe acabar en return (última sentencia de nivel superior) y no tener "return;".
import re,sys,os
def clean(src):
    out=[];i=0;n=len(src)
    while i<n:
        c=src[i]
        if c=='/' and i+1<n and src[i+1]=='/':
            while i<n and src[i]!='\n': i+=1
            continue
        if c=='/' and i+1<n and src[i+1]=='*':
            i=src.find('*/',i+2); i=n if i<0 else i+2; continue
        if c in '"\'':
            q=c; out.append(q+q); i+=1
            while i<n and src[i]!=q:
                i+= 2 if src[i]=='\\' else 1
            i+=1; continue
        out.append(c); i+=1
    return ''.join(out)
sig=re.compile(r'^(?:static )?(v8::Intercepted|void) ([\w:]+)\(([^)]*PropertyCallbackInfo<([^>]*)>& info)\) \{$',re.M)
bad=[];n=0;files=0
for root,_,fs in os.walk(sys.argv[1]):
    for f in fs:
        if not f.endswith('.cc'): continue
        src=clean(open(os.path.join(root,f)).read()); files+=1
        for m in sig.finditer(src):
            rt,name,args,ci=m.groups()
            i=m.end(); d=1; j=i
            while d>0:
                c=src[j]; d+= (c=='{') - (c=='}'); j+=1
            body=src[i:j-1]
            if rt!='v8::Intercepted':
                if re.search(r'(Getter|Setter|Query|Deleter|Definer|Descriptor)Callback$',name) and ('uint32_t index' in args or 'v8::Local<v8::Name> v8_property_name' in args):
                    bad.append((f,name,'interceptor void'))
                continue
            n+=1
            if re.search(r'\breturn\s*;',body): bad.append((f,name,'return; sin valor'))
            # sentencias de nivel superior
            items=[];d=0;cur=''
            for c in body:
                cur+=c
                if c=='{': d+=1
                elif c=='}':
                    d-=1
                    if d==0: items.append(cur.strip()); cur=''
                elif c==';' and d==0: items.append(cur.strip()); cur=''
            items=[x for x in items if x]
            last=items[-1] if items else ''
            if not last.startswith('return'): bad.append((f,name,'última sentencia: '+last[:70].replace('\n',' ')))
print('ficheros',files,'funciones Intercepted',n,'problemas',len(bad))
for b in bad[:30]: print(' ',*b)
