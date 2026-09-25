import re, sys

def tokenize_tuples(values_text):
    tuples, depth, in_str, esc = [], 0, False, False
    start, fields = 0, []
    i = 0
    while i < len(values_text):
        c = values_text[i]
        if in_str:
            if esc: esc = False
            elif c == "'": in_str = False
            i += 1; continue
        if c == "'": in_str = True; i += 1; continue
        if c == '(' and depth == 0:
            depth = 1; start = i+1; fields = []
        elif c == '(': depth += 1
        elif c == ')':
            depth -= 1
            if depth == 0:
                fields.append(values_text[start:i]); tuples.append(fields)
        elif c == ',' and depth == 1:
            fields.append(values_text[start:i]); start = i+1
        i += 1
    return tuples

def count_fields(tup):
    depth, in_str, esc, n = 0, False, False, 1
    for c in tup:
        if in_str:
            if esc: esc = False
            elif c == "'": in_str = False
            continue
        if c == "'": in_str = True
        elif c == '(': depth += 1
        elif c == ')': depth -= 1
        elif c == ',' and depth == 0: n += 1
    return n

for path in sys.argv[1:]:
    text = open(path).read()
    for m in re.finditer(r'INSERT INTO\s+(\w+)\s*\(([^)]+)\)\s*VALUES\s*(.*?);', text, re.S):
        table, cols, vals = m.group(1), m.group(2), m.group(3)
        ncols = len([c for c in cols.split(',') if c.strip()])
        tuples = tokenize_tuples(vals)
        bad = 0
        for t in tuples:
            full = ','.join(t)
            nf = count_fields(full)
            if nf != ncols:
                print(f"  MISMATCH {table}: {ncols} cols vs {nf} values :: {t[0][:70]!r}")
                bad += 1
        status = "OK" if bad == 0 else f"{bad} BAD ROWS"
        print(f"{path}: {table} -> {ncols} cols, {len(tuples)} rows [{status}]")
