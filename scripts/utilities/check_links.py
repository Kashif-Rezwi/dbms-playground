import os, re, sys
root = "/Users/kashifrezwi/Developer/dbms-playground"
broken = []
checked = 0
for dirpath, dirs, files in os.walk(root):
    if '.git' in dirpath: continue
    for f in files:
        if not f.endswith('.md'): continue
        p = os.path.join(dirpath, f)
        text = open(p, encoding='utf-8').read()
        for m in re.finditer(r'\]\(([^)\s]+)\)', text):
            rel = m.group(1)
            if rel.startswith('http') or rel.startswith('#'): continue
            if not rel.endswith('.md') and '.' not in os.path.basename(rel): continue
            target = os.path.normpath(os.path.join(dirpath, rel))
            checked += 1
            if not os.path.exists(target):
                broken.append(f"{p} -> {rel}")
print(f"checked {checked} relative links")
if broken:
    print("BROKEN:")
    for b in broken: print(" ", b)
else:
    print("all links resolve OK")
