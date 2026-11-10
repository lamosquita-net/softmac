#!/usr/bin/env python3
"""Count generic cosmetic rules that make Blink create a [style] attribute bucket.

Mimics adblock-rust 0.13 (cosmetic_filter_cache_builder.rs add_generic_filter):
generic = no positive hostname/entity; negated-only rules also count as generic.
misc_generic = plain CSS selector that does not start with '.' or '#'.
Those go into hide_selectors on every page (unless $generichide).

Then mimics Blink rule_set.cc bucketing on the rightmost compound of each
comma-separated complex selector: id > class > attribute (last attribute in the
compound wins) > tag/universal. A complex selector lands in the 'style' bucket
when its rightmost compound has no #id, no .class, and its last attribute
selector is [style...].

Usage: contar_style.py fuentes.tsv txtdir
"""
import re, sys, collections

PROCEDURAL = (':has-text(', ':-abp-', ':xpath(', ':upward(', ':remove(', ':style(',
              ':matches-css', ':min-text-length(', ':watch-attr(', ':matches-path(',
              ':matches-attr(', ':matches-prop(', ':others(', ':shadow(', ':contains(',
              ':remove-attr(', ':remove-class(', ':matches-media(', ':if(', ':if-not(',
              ':nth-ancestor(', ':spath(', ':-abp-has(', ':-abp-contains(')


def split_top(s, sep):
    out, depth, br, q, cur = [], 0, 0, None, ''
    for ch in s:
        if q:
            cur += ch
            if ch == q:
                q = None
            continue
        if ch in '"\'':
            q = ch
        elif ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
        elif ch == '[':
            br += 1
        elif ch == ']':
            br -= 1
        if ch == sep and depth == 0 and br == 0:
            out.append(cur)
            cur = ''
        else:
            cur += ch
    out.append(cur)
    return out


def rightmost_compound(cx):
    # drop combinators at top level: whitespace, >, +, ~
    tokens, depth, br, q, cur = [], 0, 0, None, ''
    for ch in cx.strip():
        if q:
            cur += ch
            if ch == q:
                q = None
            continue
        if ch in '"\'':
            q = ch
        elif ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
        elif ch == '[':
            br += 1
        elif ch == ']':
            br -= 1
        if depth == 0 and br == 0 and (ch.isspace() or ch in '>+~'):
            if cur:
                tokens.append(cur)
            cur = ''
        else:
            cur += ch
    if cur:
        tokens.append(cur)
    return tokens[-1] if tokens else ''


def strip_parens_and_brackets(comp):
    """Return compound text at top level with (...) removed, and list of attr names."""
    top, attrs, depth, br, q, cur_attr = '', [], 0, 0, None, None
    for ch in comp:
        if q:
            if cur_attr is not None and br == 1:
                pass
            if ch == q:
                q = None
            continue
        if ch in '"\'':
            q = ch
            continue
        if ch == '(':
            depth += 1
            continue
        if ch == ')':
            depth -= 1
            continue
        if depth:
            continue
        if ch == '[':
            br += 1
            cur_attr = ''
            continue
        if ch == ']':
            br -= 1
            name = re.split(r'[~|^$*]?=|\s', cur_attr.strip(), maxsplit=1)[0]
            attrs.append(name.lower())
            cur_attr = None
            continue
        if br:
            cur_attr += ch
            continue
        top += ch
    return top, attrs


def bucket(cx):
    comp = rightmost_compound(cx)
    top, attrs = strip_parens_and_brackets(comp)
    # pseudo-elements: ::before etc. do not change id/class/attr extraction for our purpose
    if '#' in top:
        return 'id'
    if re.search(r'(^|[^\\])\.', top):
        return 'class'
    if attrs:
        return 'attr:' + attrs[-1]
    return 'tag'


def parse_line(line):
    line = line.strip()
    if not line or line.startswith('!') or line.startswith('['):
        return None
    m = re.match(r'^([^#]*?)(##|#@#|#\?#|#\$#|#\$\?#|#@\$#|#@\?#)(.+)$', line)
    if not m:
        return None
    doms, sep, sel = m.groups()
    if sep != '##':
        return None  # exceptions, procedural-only, style injections
    if sel.startswith('+js(') or sel.startswith('^'):
        return None
    if any(p in sel for p in PROCEDURAL):
        return None
    if doms:
        ds = [d.strip() for d in doms.split(',') if d.strip()]
        if any(not d.startswith('~') for d in ds):
            return None  # hostname-specific: only on its sites
        return ('neg', sel)
    return ('gen', sel)


def main():
    fuentes, txtdir = sys.argv[1], sys.argv[2]
    per_list = collections.defaultdict(set)
    style_rules = collections.defaultdict(set)
    misc_total = collections.defaultdict(set)
    for row in open(fuentes):
        uuid, h, url = row.split()
        try:
            text = open(f'{txtdir}/{h}.txt', encoding='utf-8', errors='replace').read()
        except FileNotFoundError:
            print('missing', url, file=sys.stderr)
            continue
        for line in text.splitlines():
            r = parse_line(line)
            if not r:
                continue
            kind, sel = r
            if sel.startswith('.') or sel.startswith('#'):
                continue  # class/id keyed: only when the page has that class/id
            misc_total[uuid].add(sel)
            for cx in split_top(sel, ','):
                if bucket(cx) == 'attr:style':
                    style_rules[uuid].add((sel, url.rsplit('/', 1)[-1], kind))
                    break
    allstyle = set()
    for u in misc_total:
        print(f'{u}: misc_generic={len(misc_total[u])} with [style] bucket={len(style_rules[u])}')
        allstyle |= {s for s, _, _ in style_rules[u]}
    print('TOTAL distinct [style]-bucket generic selectors:', len(allstyle))
    print()
    for u in style_rules:
        for sel, src, kind in sorted(style_rules[u]):
            print(f'{u[:8]}\t{src}\t{kind}\t{sel}')


if __name__ == '__main__':
    main()
