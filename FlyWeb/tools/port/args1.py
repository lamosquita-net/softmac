#!/usr/bin/env python3
# Uso: args1.py <fichero>... → llamadas de un solo argumento a ToScriptWrappable/ToWrappableUnsafe/GetInternalField<...>
import re,sys
pat=re.compile(r'\b(ToScriptWrappable|ToWrappableUnsafe|GetInternalField<[^>]*>)\(')
for p in sys.argv[1:]:
    try: s=open(p,encoding='utf-8',errors='replace').read()
    except IsADirectoryError: continue
    for m in pat.finditer(s):
        i=m.end(); depth=1; commas=0; j=i
        while j<len(s) and depth:
            c=s[j]
            if c in '([{<' and not (c=='<' and s[j-1]==' '): depth+= 1 if c in '([{' else 0
            if c in ')]}': depth-=1
            elif c==',' and depth==1: commas+=1
            j+=1
        args=s[i:j-1].strip()
        if commas==0 and args:
            ln=s.count('\n',0,m.start())+1
            # saltar declaraciones/definiciones
            line=s[s.rfind('\n',0,m.start())+1:s.find('\n',m.start())]
            if re.search(r'(inline|static|PLATFORM_EXPORT|CORE_EXPORT)\s.*\b'+re.escape(m.group(1).split('<')[0])+r'\(',line) and ('v8::' in args.split()[0] if args else False): continue
            print(f"{p}:{ln}: {m.group(1)}({args[:70]})")
