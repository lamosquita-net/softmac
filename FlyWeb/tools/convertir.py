#!/usr/bin/env python3
"""FM.54 F0: convert brave-core `flyweb` patch history into commits of a tree.

For every brave-core commit that changes the patches of one repository
(`src`: patches/*.patch; `v8`: patches/v8/*.patch), build that repository's
tree the way `npm run apply_patches` builds it (reset the touched files to the
clean base, then `git apply --ignore-space-change --ignore-whitespace` in
name order) and record it as a commit with the same author, committer, dates
and message, plus Flynk trailers. Merges stay merges (history simplified to
the patch paths with --full-history --simplify-merges).

Everything happens in a temporary index of the target repository: no working
tree, no checkout. Same input, same SHAs: the conversion can be repeated on
`motor/139` (F1) and must give the same commits for the shared part.

Usage:
  convertir.py --kind src --brave B.git --range v1.69.168..flyweb \
      --repo flynk/chromium.git --base 128.0.6613.138 --ref refs/heads/flynk
  convertir.py --kind v8 --brave B.git --range v1.69.168..flyweb \
      --repo flynk/v8.git --base <v8 revision of the 128 DEPS> \
      --ref refs/heads/flynk-v8 [--fetch https://chromium.googlesource.com/v8/v8.git]
"""

import argparse
import os
import re
import subprocess
import sys
import tempfile

APPLY_ARGS = ['--ignore-space-change', '--ignore-whitespace']
V8_REVISION_FILE = 'FlyWeb/v8-revision'
CONFIG_GNI = 'build/config.gni'


def git(gitdir, *args, env=None, inp=None, check=True):
    e = dict(os.environ)
    e.pop('GIT_DIR', None)
    if env:
        e.update(env)
    r = subprocess.run(['git', '--git-dir', gitdir, *args], input=inp,
                       capture_output=True, env=e)
    if check and r.returncode:
        raise RuntimeError('git %s: %s' % (' '.join(args[:3]),
                                            r.stderr.decode(errors='replace')))
    return r


def out(gitdir, *args, **kw):
    return git(gitdir, *args, **kw).stdout.decode().strip()


class Converter:
    def __init__(self, a):
        self.a = a
        self.brave = a.brave
        self.repo = a.repo
        self.kind = a.kind
        if self.kind == 'src':
            self.pspec = [':(glob)patches/*.patch']
        else:
            self.pspec = [':(glob)patches/v8/*.patch', V8_REVISION_FILE]
        self.tmp = tempfile.mkdtemp(prefix='convertir-')
        self.env = {'GIT_INDEX_FILE': os.path.join(self.tmp, 'index')}
        self.targets_cache = {}   # patch blob -> [paths]
        self.blob_text = {}       # patch blob -> bytes
        self.map = {}             # brave commit -> new commit
        self.state = {}           # new commit -> (base commit, tree)
        self.index_tree = None
        self.failures = []
        self.default_base = out(self.repo, 'rev-parse', a.base + '^{commit}')

    # --- brave-core side -------------------------------------------------
    def is_patch(self, path):
        if self.kind == 'src':
            return path.startswith('patches/') and path.count('/') == 1 \
                and path.endswith('.patch')
        return path.startswith('patches/v8/') and path.count('/') == 2 \
            and path.endswith('.patch')

    def patches_at(self, commit):
        """{patch path: blob} of the patch set at a brave-core commit."""
        d = 'patches/' if self.kind == 'src' else 'patches/v8/'
        res = {}
        for line in out(self.brave, 'ls-tree', commit, d).splitlines():
            meta, path = line.split('\t', 1)
            _, typ, blob = meta.split()
            if typ == 'blob' and self.is_patch(path):
                res[path] = blob
        return res

    def text(self, blob):
        if blob not in self.blob_text:
            self.blob_text[blob] = git(self.brave, 'cat-file', 'blob',
                                       blob).stdout
        return self.blob_text[blob]

    def targets(self, blob):
        if blob not in self.targets_cache:
            paths = set()
            for m in re.finditer(rb'^diff --git a/(\S+) b/(\S+)$',
                                 self.text(blob), re.M):
                paths.add(m.group(1).decode())
                paths.add(m.group(2).decode())
            self.targets_cache[blob] = sorted(paths)
        return self.targets_cache[blob]

    def base_of(self, commit):
        if self.kind == 'src':
            return self.default_base
        r = git(self.brave, 'show', '%s:%s' % (commit, V8_REVISION_FILE),
                check=False)
        if r.returncode:
            return self.default_base
        for line in r.stdout.decode().splitlines():
            line = line.strip()
            if line and not line.startswith('#'):
                return self.ensure_commit(line)
        return self.default_base

    def ensure_commit(self, sha):
        if git(self.repo, 'cat-file', '-e', sha + '^{commit}',
               check=False).returncode == 0:
            return sha
        if not self.a.fetch:
            raise RuntimeError('missing base %s and no --fetch' % sha)
        print('  fetching %s' % sha, flush=True)
        git(self.repo, 'fetch', '-q', '--depth=1', self.a.fetch, sha)
        return sha

    def level(self, commit):
        r = git(self.brave, 'show', '%s:%s' % (commit, CONFIG_GNI),
                check=False)
        m = re.search(rb'^flyweb_engine_level\s*=\s*(\d+)', r.stdout, re.M)
        return m.group(1).decode() if m else '128'

    # --- target side ----------------------------------------------------
    def load(self, tree):
        if self.index_tree != tree:
            git(self.repo, 'read-tree', tree, env=self.env)
            self.index_tree = tree

    def reset_paths(self, base, paths):
        if not paths:
            return
        have = {}
        for line in out(self.repo, 'ls-tree', '-r', '-z', base, '--',
                        *paths).split('\0'):
            if line:
                meta, p = line.split('\t', 1)
                have[p] = meta
        info = []
        for p in paths:
            if p in have:
                mode, _, sha = have[p].split()
                info.append('%s %s\t%s' % (mode, sha, p))
            else:
                info.append('0 %s\t%s' % ('0' * 40, p))
        git(self.repo, 'update-index', '--index-info', env=self.env,
            inp=('\n'.join(info) + '\n').encode())

    def apply(self, pname, blob):
        f = os.path.join(self.tmp, 'p.patch')
        with open(f, 'wb') as fh:
            fh.write(self.text(blob))
        r = git(self.repo, 'apply', '--cached', '--whitespace=nowarn',
                *APPLY_ARGS, f, env=self.env, check=False)
        if r.returncode:
            # The temporary path must not reach the commit message, or the
            # SHAs would change from one run to the next.
            lines = r.stderr.decode(errors='replace').replace(
                f, pname).strip().splitlines()
            errs = [l for l in lines if l.startswith('error:')]
            return (errs or lines)[:1]
        return None

    def build(self, start_tree, base, old, new, full):
        """Tree for patch set `new`, starting from `start_tree` built from
        patch set `old` (or from the clean base when `full`)."""
        if full:
            self.load(out(self.repo, 'rev-parse', base + '^{tree}'))
            todo = sorted(new)
        else:
            self.load(start_tree)
            changed = {p for p in set(old) | set(new)
                       if old.get(p) != new.get(p)}
            reset = set()
            for p in changed:
                if p in old:
                    reset.update(self.targets(old[p]))
                if p in new:
                    reset.update(self.targets(new[p]))
            # Re-apply every current patch that touches a reset file.
            todo = set(p for p in changed if p in new)
            grew = True
            while grew:
                grew = False
                for p, b in new.items():
                    if p not in todo and reset.intersection(self.targets(b)):
                        todo.add(p)
                        reset.update(self.targets(b))
                        grew = True
            self.reset_paths(base, sorted(reset))
            todo = sorted(todo)
        failed = []
        for p in todo:
            err = self.apply(p, new[p])
            if err:
                failed.append((p, err))
        tree = out(self.repo, 'write-tree', env=self.env)
        self.index_tree = tree
        return tree, failed

    # --- commits ---------------------------------------------------------
    def classify(self, msg, paths):
        m = msg.lower()
        if re.search(r'cve-\d|security|seguridad|\bfs\d', m):
            return 'security'
        if re.search(r'\bdisable|graphite|\bleo\b|finch|apagad', m):
            return 'disable'
        if re.search(r'privacy|privacidad|farbl|fingerprint', m):
            return 'privacy'
        if re.search(r'brand|identity|identidad|icon', m):
            return 'identity'
        if paths and all(p == 'DEPS' for p in paths):
            return 'dep'
        if re.search(r'mojave|10\.14|catalina|compat', m) or (
                paths and all(is_mac(p) for p in paths)):
            return 'compat'
        if re.search(r'\bport|level \d{3}|nivel \d{3}|\b1[3-5]\d\b', m):
            return 'port'
        return 'unknown'

    def commit(self, orig, tree, parents, failed, paths, merge=False):
        fmt = '%an%x00%ae%x00%ad%x00%cn%x00%ce%x00%cd%x00%B'
        an, ae, ad, cn, ce, cd, body = out(
            self.brave, 'log', '-1', '--date=raw', '--format=' + fmt,
            orig).split('\0', 6)
        trailers = ['Flynk-Level: ' + self.level(orig)]
        if not merge:
            trailers.append('Flynk-Class: ' + self.classify(body, paths))
            if paths and all(is_mac(p) for p in paths):
                trailers.append('Flynk-Platform: mac')
        trailers.append('Brave-Core-Commit: ' + orig)
        for p, err in failed:
            trailers.append('Flynk-Convert-Failed: %s (%s)' %
                            (p, ' '.join(err)[:120]))
        msg = body.rstrip('\n') + '\n\n' + '\n'.join(trailers) + '\n'
        env = {'GIT_AUTHOR_NAME': an, 'GIT_AUTHOR_EMAIL': ae,
               'GIT_AUTHOR_DATE': ad, 'GIT_COMMITTER_NAME': cn,
               'GIT_COMMITTER_EMAIL': ce, 'GIT_COMMITTER_DATE': cd}
        args = ['commit-tree', tree]
        for p in parents:
            args += ['-p', p]
        return out(self.repo, *args, env=env, inp=msg.encode())

    def convert_root(self, orig):
        """State of a commit outside the range: clean base + its patches,
        with the upstream base as parent."""
        base = self.base_of(orig)
        new = self.patches_at(orig)
        tree, failed = self.build(None, base, {}, new, True)
        self.failures += [(orig, p, e) for p, e in failed]
        c = self.commit(orig, tree, [base], failed, [])
        self.map[orig] = c
        self.state[c] = (base, tree, orig)
        return c

    def run(self):
        lines = out(self.brave, 'rev-list', '--reverse', '--topo-order',
                    '--parents', '--full-history', '--simplify-merges',
                    self.a.range,
                    *['^' + x for x in self.a.exclude],
                    '--', *self.pspec).splitlines()
        print('%s: %d commits' % (self.kind, len(lines)), flush=True)
        head = None
        for n, line in enumerate(lines, 1):
            orig, *oparents = line.split()
            # --exclude: a merge parent inside an excluded history (the 1.x
            # line that "flyweb follows the release" merges bring in) is
            # dropped, not converted as a root.
            oparents = [p for p in oparents if not any(
                git(self.brave, 'merge-base', '--is-ancestor', p, x,
                    check=False).returncode == 0
                for x in self.a.exclude)]
            if not oparents:
                oparents = [out(self.brave, 'rev-parse',
                                self.a.range.split('..')[0] + '^{commit}')]
            parents = [self.map.get(p) or self.convert_root(p)
                       for p in oparents]
            pbase, ptree, porig = self.state[parents[0]]
            base = self.base_of(orig)
            old = self.patches_at(porig)
            new = self.patches_at(orig)
            full = base != pbase
            tree, failed = self.build(ptree, base, old, new, full)
            self.failures += [(orig, p, e) for p, e in failed]
            if full:
                parents.append(base)
            paths = sorted({t for p in set(old) | set(new)
                            if old.get(p) != new.get(p)
                            for b in (old.get(p), new.get(p)) if b
                            for t in self.targets(b)})
            c = self.commit(orig, tree, parents, failed, paths,
                            merge=len(oparents) > 1)
            self.map[orig] = c
            self.state[c] = (base, tree, orig)
            head = c
            if n % 25 == 0 or n == len(lines):
                print('  %d/%d %s -> %s' % (n, len(lines), orig[:10], c[:10]),
                      flush=True)
        git(self.repo, 'update-ref', self.a.ref, head)
        with open(self.a.map, 'w') as fh:
            for o, c in self.map.items():
                fh.write('%s\t%s\n' % (o, c))
        print('%s = %s (tree %s)' % (self.a.ref, head,
                                     self.state[head][1]))
        print('apply failures: %d' % len(self.failures))
        for o, p, e in self.failures:
            print('  %s %s %s' % (o[:10], p, ' '.join(e)))


def is_mac(p):
    return bool(re.search(r'(^|/)mac(/|$)|_mac\.|\.mm$|cocoa', p))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--kind', choices=['src', 'v8'], required=True)
    ap.add_argument('--brave', required=True)
    ap.add_argument('--range', required=True)
    ap.add_argument('--repo', required=True)
    ap.add_argument('--base', required=True)
    ap.add_argument('--ref', required=True)
    ap.add_argument('--map', required=True)
    ap.add_argument('--fetch')
    ap.add_argument('--exclude', action='append', default=[],
                    help='brave-core commit whose history is left out '
                         '(e.g. the last 1.x flyweb commit); repeatable')
    Converter(ap.parse_args()).run()


if __name__ == '__main__':
    sys.exit(main())
