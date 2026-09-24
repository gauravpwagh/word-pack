# Behaviour oracle for docs/IMPORT_FORMAT.md (Python, verified against fixtures/).
# The Flutter app must implement the same behaviour in Dart (lib/domain/importer.dart);
# its tests compare against the golden files in fixtures/expected/, which this script generates:
#   python3 reference/import_parser.py
import csv, io, json, re, pathlib

POS = {'n':'noun','noun':'noun','v':'verb','verb':'verb','j':'adjective','adj':'adjective','adjective':'adjective',
       'a':'adverb','adv':'adverb','adverb':'adverb','r':'adverb','pron':'pronoun','pronoun':'pronoun',
       'prep':'preposition','preposition':'preposition','conj':'conjunction','conjunction':'conjunction',
       'interj':'interjection','int':'interjection','interjection':'interjection','phr':'phrase','phrase':'phrase',
       'idiom':'idiom','abbr':'abbreviation','abbreviation':'abbreviation'}
POS_RE = re.compile(r'^([A-Za-z]{1,12})\.\s+(.*)$')

def decode(b):
    try: return b.decode('utf-8-sig')
    except UnicodeDecodeError: return b.decode('cp1252')

def unquote_line(l):
    l = re.sub(r',+$', '', l.strip()).strip()
    if len(l) >= 2 and l[0] == '"' and l[-1] == '"': l = l[1:-1].replace('""', '"')
    return l.strip()

def split_pos(rest):
    m = POS_RE.match(rest)
    if m and m.group(1).lower() in POS: return m.group(1).lower(), m.group(2).strip()
    return None, rest

def canonical(pos_raw):
    if pos_raw is None: return None
    return POS.get(pos_raw, 'other')

def parse(b):
    text = decode(b); lines = text.splitlines()
    nb = [l for l in lines if l.strip()]
    out, skipped = [], []
    if nb and sum(' - ' in l for l in nb) / len(nb) >= 0.8:
        fmt = 'dash'
        for n, raw in enumerate(lines, 1):
            l = unquote_line(raw)
            if not l: continue
            i = l.find(' - ')
            if i <= 0: skipped.append({'line': n, 'reason': 'NO_SEPARATOR'}); continue
            term = ' '.join(l[:i].split()); p, d = split_pos(l[i+3:].strip())
            if not d: skipped.append({'line': n, 'reason': 'EMPTY_DEFINITION'}); continue
            out.append((n, term, p, d))
    else:
        fmt = 'columns'
        try: dialect = csv.Sniffer().sniff(text[:4096], delimiters=',;\t')
        except csv.Error: dialect = csv.excel
        rows = list(csv.reader(io.StringIO(text), dialect))
        hdr = [c.strip().lower() for c in rows[0]] if rows else []
        names = {'term': ['term','word'], 'pos': ['pos','part of speech','part_of_speech','type'],
                 'definition': ['definition','meaning','definitions']}
        idx = {k: j for k, al in names.items() for j, h in enumerate(hdr) if h in al}
        start = 1 if 'term' in idx and 'definition' in idx else 0
        if not start:
            w = max((len(r) for r in rows), default=0)
            idx = {'term': 0, 'definition': 1} if w == 2 else {'term': 0, 'pos': 1, 'definition': 2}
        for n, r in enumerate(rows[start:], start + 1):
            if not any(c.strip() for c in r): continue
            g = lambda k: r[idx[k]].strip() if k in idx and idx[k] < len(r) else ''
            term = ' '.join(g('term').split()); d = g('definition'); pr = g('pos').rstrip('.').lower() or None
            if not term: skipped.append({'line': n, 'reason': 'EMPTY_TERM'}); continue
            if not d: skipped.append({'line': n, 'reason': 'EMPTY_DEFINITION'}); continue
            if pr is None: pr, d = split_pos(d)
            out.append((n, term, pr, d))
    seen, words, dup = set(), [], 0
    for n, t, p, d in out:
        k = (t.lower(), p and canonical(p), ' '.join(d.lower().split()))
        if k in seen: dup += 1; continue
        seen.add(k); words.append({'line': n, 'term': t, 'pos_raw': p, 'pos': canonical(p), 'definition': d})
    return {'format': fmt, 'words': words, 'skipped': skipped, 'duplicates_removed': dup}

if __name__ == '__main__':
    root = pathlib.Path(__file__).resolve().parent.parent / 'fixtures'
    for f in sorted(root.iterdir()):
        if f.suffix in ('.txt', '.csv'):
            r = parse(f.read_bytes())
            (root / 'expected' / (f.name + '.json')).write_text(json.dumps(r, indent=1, ensure_ascii=False) + '\n')
            print(f.name, r['format'], len(r['words']), r['skipped'], r['duplicates_removed'])
