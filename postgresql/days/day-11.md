# Day 11 — JSONB, Arrays & Special Types

**Track:** PostgreSQL · **Stage:** 3 — PG Features · **Difficulty:** 🟡→🔴

## 🎯 Goal

Use PostgreSQL's hybrid-relational superpowers — arrays, JSONB, ranges, enums — deliberately, with the trade-offs stated.

## 🧠 Fundamentals

**JSONB** — JSON stored binary: queryable, indexable, typed:

```sql
CREATE TABLE events (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    kind text NOT NULL,
    data JSONB NOT NULL
);
INSERT INTO events (kind, data) VALUES
    ('signup', '{"user": "ayesha", "plan": "pro", "tags": ["beta", "mobile"]}');

SELECT data->>'user' AS user, data->>'plan' AS plan FROM events;
SELECT * FROM events WHERE data @> '{"plan": "pro"}';      -- containment
SELECT data->'tags' FROM events;                            -- JSON array
CREATE INDEX ON events USING GIN (data);                    -- queryable @ speed
```

Key operators: `->` (json), `->>` (text), `@>` (contains), `?` (key exists).

**When JSONB, when columns?** Fixed fields every row shares → **columns** (types, constraints, statistics, per-column indexes). Open-ended, per-customer, or genuinely nested/bag-shaped data → **JSONB**. The failure mode: "we didn't want to design" → a schemaless blob with no integrity (SQL Day 27's Schema B).

**Arrays** — the tidy middle for *small, uniform* lists:

```sql
ALTER TABLE products ADD COLUMN tags TEXT[];
SELECT * FROM products WHERE 'sql' = ANY(tags);
SELECT * FROM products WHERE tags && ARRAY['sql','book'];   -- overlap
CREATE INDEX ON products USING GIN (tags);
```

**Ranges** — `int4range`, `daterange`, `tstzrange` + the `&&` overlap operator (you met it in Day 7's EXCLUDE):

```sql
SELECT '[2025-01-01, 2025-03-01)'::daterange @> '2025-02-15'::date;   -- contains
```

**Enums** — `CREATE TYPE status AS ENUM ('todo','doing','done')` — compact, ordered, but **adding values needs a type change** and *removing is painful*. Usually a TEXT + CHECK beats an enum in team settings.

## 🔍 Why It Matters

"Store it as JSON" is one of the most common modern design questions. Knowing when JSONB is *right* (flexible payload) vs *wrong* (avoiding schema design) is a real seniority signal.

## 💡 Mental Model

> Columns are a **filing cabinet** (everything in its labeled drawer, audited). JSONB is a **drawer of labeled folders** — flexible, searchable (GIN index = the folder-search robot), but nobody checks what you put in a folder. Arrays are a **sticky note on the folder** — fine for small uniform scribbles, not a filing system.

## 🛠️ Practice

🟢 **P1.** Create `events`, insert 3 varied rows (one with nested objects), and pull `->>'user'` from each.
🟢 **P2.** Containment: find events `@> '{"plan": "pro"}'`. Then key-exists `WHERE data ? 'tags'`. Explain the difference in one line.
🟡 **P3.** Add the GIN index; EXPLAIN a containment query before and after on `perf_lab`-sized fake JSON (generate 100k events with generate_series; vary plan among 3 values). Did the index win? When would the planner still scan?
🟡 **P4.** Arrays: `tags` on a products copy; three queries: exact tag (ANY), overlap (&&), and "array has at least 2 tags" (array_length).
🟡 **P5. ⭐ Predict first:** `SELECT '[1,2]'::jsonb @> '[2]'` vs `SELECT '[1,2]'::int[] @> ARRAY[2]` — both true? What did each contain-check actually compare?
🟡 **P6. From memory:** insert a JSONB row, then UPDATE one nested key: `UPDATE events SET data = jsonb_set(data, '{plan}', '"free"') WHERE id = 1;` — from memory after one look.
🔴 **P7.** The design gauntlet — for each, JSONB or columns? One-line defense: (a) user profile: name, email, signup date; (b) per-integration settings for 200 connector types; (c) product prices; (d) webhook event payloads you must replay later; (e) multi-language product descriptions (5 languages, growing).
🔴 **P8.** Statistics truth: with 100k events, `WHERE data->>'plan' = 'pro'` (plain comparison) vs `@> '{"plan":"pro"}'` (containment + GIN). EXPLAIN both — one index-assistable, one not. Explain why the *shape* of the predicate decides.

## 🐛 Debugging

```sql
-- Bug 1: "cannot extract element from a scalar" — some rows have data
-- storing a plain string, not an object. How do you find them?
-- (WHERE jsonb_typeof(data) <> 'object')
-- Bug 2: performance cliff — data->>'plan' queries scan everything.
-- Two fixes (expression index on the extracted value; containment + GIN).
-- Bug 3 (design): someone stored the ENTIRE order (user, items, totals)
-- as JSONB "for flexibility" and now needs "revenue per product". What
-- must they now write, and what would they have written with columns?
```

## 🧩 Combine Concepts

The hybrid table (the real-world pattern): `customers` with real columns (id, email, created_at) + `prefs JSONB` (theme, notification flags, dashboard layout — *actually optional/varying*). Write: (1) all customers with theme = dark; (2) a CHECK that `prefs ? 'theme'` OR prefs IS NULL... (3) your design memo one-paragraph: what did columns buy you, what did JSONB buy you?

## 🔁 Previous Knowledge

1. BEFORE vs AFTER triggers.
2. What are triggers' three legitimate jobs?
3. Function volatility tags — the three.
4. SQL: what's a correlated subquery?

## 🧠 Recall

1. `->` vs `->>` — what does each return?
2. What does `@>` mean, and which index serves it?
3. The rule for columns vs JSONB (one line)?
4. Why are enums often a trap?

## 🎤 Interview Questions

1. "When would you use JSONB instead of regular columns?" *(Open-ended/varying payloads; fixed facts → columns.)*
2. "How do you index JSONB queries?" *(GIN for containment; expression indexes for extracted values.)*
3. "What are the downsides of storing everything as JSON?" *(No constraints, no types, no per-column stats, planner blindness.)*

## ✅ Completion Checklist

- [ ] Understand JSONB operators, GIN, arrays, ranges, enum trade-offs
- [ ] Completed P1–P8 (P5 predicted first)
- [ ] Fixed all three bugs
- [ ] Completed the hybrid-table design task
- [ ] Answered recall without notes
