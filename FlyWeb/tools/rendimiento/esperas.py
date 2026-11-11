import re, sys
# Tiempo de espera del hilo principal del proceso de GPU, por causa, en una toma de `sample`.
pat = re.compile(r'^([ +!:|]*)(\d+) (.*)$')
for f in sys.argv[1:]:
    lines = open(f, errors='replace').read().split('\n')
    start = next(i for i, l in enumerate(lines) if 'com.apple.main-thread' in l and 'Thread_' in l)
    end = next(i for i in range(start + 1, len(lines)) if re.search(r'^\s+\d+ Thread_', lines[i]))
    total = int(pat.match(lines[start]).group(2))
    block = lines[start + 1:end]
    # hojas: lineas cuyo siguiente no es mas profundo
    parsed = []
    for l in block:
        m = pat.match(l)
        if m:
            parsed.append((len(m.group(1)), int(m.group(2)), m.group(3)))
    res = {}
    stack = []
    for i, (d, n, s) in enumerate(parsed):
        while stack and stack[-1][0] >= d:
            stack.pop()
        stack.append((d, s))
        leaf = i + 1 >= len(parsed) or parsed[i + 1][0] <= d
        if not leaf:
            continue
        chain = ' > '.join(x[1] for x in stack)
        if 'mach_msg_trap' in s or 'kevent' in s:
            k = 'espera de mensajes (bomba de mensajes)' if 'waitUntil' not in chain else 'espera en Metal'
        elif '__psynch_cvwait' in s or 'semaphore_wait' in s or '__psynch_mutexwait' in s or '__ulock_wait' in s:
            if 'waitUntilScheduled' in chain: k = 'Metal: waitUntilScheduled'
            elif 'waitUntilCompleted' in chain: k = 'Metal: waitUntilCompleted'
            elif 'MTL' in chain or 'AMD' in chain or 'IOAccel' in chain: k = 'Metal/driver: otra espera'
            else: k = 'otra espera (cond/mutex)'
        else:
            k = 'activo'
        res[k] = res.get(k, 0) + n
    print(f)
    print('  muestras del hilo:', total)
    for k, n in sorted(res.items(), key=lambda x: -x[1]):
        print('  %-42s %5d  %5.1f %%' % (k, n, 100.0 * n / total))
