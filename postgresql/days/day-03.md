# Day 03 — Tables + PostgreSQL Data Types

**Track:** PostgreSQL · **Stage:** 1 — Setup · **Difficulty:** Beginner → Intermediate

## Goal

Choose PostgreSQL's types with intent — especially money, timestamps, and text — instead of defaulting to TEXT for everything.

## Fundamentals

PostgreSQL's type system is rich. The decisions you'll actually make:

```sql
CREATE TABLE example (
    id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  -- Day 5
    name        TEXT NOT NULL,
    email       TEXT NOT NULL UNIQUE,
    price       NUMERIC(8,2) NOT NULL,          -- EXACT decimal, 2 places
    weight      REAL,                            -- approximate float
    qty         INT CHECK (qty >= 0),
    big_qty     BIGINT,
    is_active   BOOLEAN DEFAULT TRUE,
    born_on     DATE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),  -- WITH time zone
    tags        TEXT[],
    meta        JSONB,
    ip          INET
);
```

**The five decisions that matter:**

1. **Money → `NUMERIC(10,2)`** — never FLOAT/REAL (binary floats can't represent 0.10 exactly; money errors are unacceptable). NUMERIC is exact but slower — for money, always worth it.
2. **Timestamps → `TIMESTAMPTZ`** — stores an absolute instant; display adapts to the session's timezone. `TIMESTAMP` (no tz) is ambiguous across timezones and causes real bugs.
3. **Text → `TEXT`** — unlimited; `VARCHAR(n)` only when the *limit itself* is a business rule.
4. **Integers** — `INT` (2.1 billion max), `BIGINT` when ids will grow (or counts could overflow).
5. **Special types** — arrays (`TEXT[]`), `JSONB` (queryable documents, Day 11), `INET`, `UUID`, `INTERVAL`, `ENUM`s (Day 12's argument against them).

**Type rules are enforced**: inserting `price = 'abc'` fails; inserting `'2025-13-45'` fails. The type *is* a constraint (SQL Day 19's point, one level deeper).

## Why It Matters

Types are your first, cheapest data-quality guarantee and a major performance lever (smaller types = more rows per page = faster scans). "It works with TEXT" is how prototypes die in production.

## Mental Model

> A type is a **container shape**: a `NUMERIC(8,2)` box only fits numbers with 2 decimal places; a TIMESTAMPTZ box stamps every entry in *absolute universal time* so any reader can translate it to their local clock.

## Practice

[Beginner] **P1.** Create the `example` table above (your DB of choice). Insert two rows; verify. Then deliberately insert bad values for `price`, `born_on`, `ip` — read all three errors.
[Beginner] **P2.** `SELECT 0.1::float + 0.2::float;` vs `SELECT 0.1::numeric + 0.2::numeric;` — explain the output difference in one sentence. This is *why money is NUMERIC*.
[Intermediate] **P3.** Timezone proof: `SET timezone TO 'Asia/Karachi'; SELECT now();` then `SET timezone TO 'UTC'; SELECT now();` — same instant, different display. Now insert a `TIMESTAMP` (no tz) row with the Karachi wall-clock and select it after switching — what ambiguity did you just witness?
[Intermediate] **P4.** Arrays: insert `tags` with two rows, then `SELECT * FROM example WHERE 'red' = ANY(tags);` and `WHERE tags @> ARRAY['red','xl'];` (contains).
[Intermediate] **P5. Predict first:** what does this return and why?

```sql
SELECT '5' + 3;
```

*(String + number... but there's a cast. PostgreSQL coerces literal strings. What about a TEXT column + 3? Try both variants.)*
[Intermediate] **P6. From memory:** a `payments` table DDL with exact-money amount, method (text), paid_at (timestamp with tz), and a CHECK that amount > 0.
[Advanced] **P7.** Storage reality: `SELECT pg_column_size(price_column)` for NUMERIC(8,2) vs a REAL holding 12345.67. Then size whole rows with `pg_total_relation_size` on a 100-row test table in two type-versions. Report: exact-money costs how much storage?

## Debugging

```sql
-- Bug 1: the balance is ALWAYS slightly off in reports.
ALTER TABLE accounts ADD COLUMN balance FLOAT;  -- what's wrong, how bad, fix?

-- Bug 2 (silent tz bug): event times shift by hours in some regions.
created_at TIMESTAMP            -- diagnose + fix (TIMESTAMPTZ + data migration note)

-- Bug 3: insert fails with "value too long for type character varying(10)"
-- but the app "always allowed short names". What changed, what are the options?
```

## Combine Concepts

Rebuild a slice of `ecommerce` properly: `products_pg` with all your new opinions (NUMERIC price, TIMESTAMPTZ created_at, TEXT[] tags, stock INT + CHECK). Insert 3 rows, then run one SQL-track query (top-3 by price) against *it* — same language, better foundations.

## Previous Knowledge

1. Schema vs database — the isolation rule.
2. What is `search_path`?
3. SQL: what does CHECK enforce, and when does it fire?
4. SQL: LEFT JOIN + WHERE trap — one line.

## Recall

1. Money → which type, and the one-sentence reason FLOAT is disqualified?
2. TIMESTAMPTZ vs TIMESTAMP — which do real apps use and why?
3. TEXT vs VARCHAR(n) — when does VARCHAR win?
4. Name three "special" PG types and one use each.

## Interview Questions

1. "Why shouldn't you store money as FLOAT?" *(0.1+0.2 story.)*
2. "What's the difference between TIMESTAMP and TIMESTAMPTZ?"
3. "How do PostgreSQL types help data quality beyond validation?"

## Completion Checklist

- [ ] Understand the five big type decisions
- [ ] Completed P1–P7 (P5 predicted first; P2's float demo understood)
- [ ] Fixed all three bugs
- [ ] Completed the products_pg combine task
- [ ] Answered recall without notes
