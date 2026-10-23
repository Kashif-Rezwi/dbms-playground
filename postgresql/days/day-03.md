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

### 🟢 Warm Up

[Beginner] **W1.** Create the `example` table from Fundamentals (in your test schema from Day 2). Insert two valid rows, then deliberately insert bad values for `price`, `born_on`, and `ip` to observe how PostgreSQL's type system acts as a constraint.

[Beginner] **W2.** Compare binary float vs exact numeric precision:

```sql
SELECT 0.1::float + 0.2::float;
SELECT 0.1::numeric + 0.2::numeric;
```

Explain the output difference in one sentence and explain why money must always use `NUMERIC`.

### 🔵 Core

[Intermediate] **C1.** Timezone demonstration: run `SET timezone TO 'Asia/Karachi'; SELECT now();` followed by `SET timezone TO 'UTC'; SELECT now();`. Then insert a `TIMESTAMP` (without time zone) row with a local wall-clock time and inspect it after switching session timezones to observe the timestamp ambiguity.

[Intermediate] **C2.** Arrays: insert `tags` into `example` with two rows, then query using `WHERE 'red' = ANY(tags);` and `WHERE tags @> ARRAY['red','xl'];` (contains).

[Intermediate] **C3.** `[Predict]` Predict what this query returns before executing it, and explain why:

```sql
SELECT '5' + 3;
```

Now test what happens when you attempt to add an integer to a column defined as `TEXT`.

[Intermediate] **C4.** `[From Memory]` Write the DDL for a `payments` table without notes: include an exact-money amount, method (`TEXT`), `paid_at` (`TIMESTAMPTZ`), and a `CHECK` constraint ensuring amount > 0.

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix these schema definition bugs:

```sql
-- Bug A: Financial balance precision drift in account reports
ALTER TABLE accounts ADD COLUMN balance FLOAT;

-- Bug B: Event times shift across timezones in multi-region deployments
created_at TIMESTAMP;
```

Explain the root cause for each bug and write the production-grade column definitions.

[Advanced] **H2.** Combine PostgreSQL types with SQL queries: rebuild a slice of the `ecommerce` catalog as `products_pg` using explicit types (`NUMERIC` price, `TIMESTAMPTZ` created_at, `TEXT[]` tags, and `INT` stock with a `CHECK` constraint). Insert 3 rows and run a top-3 by price query against it.

## Interview Questions

1. "Why shouldn't you store money as FLOAT?" *(0.1+0.2 story.)*
2. "What's the difference between TIMESTAMP and TIMESTAMPTZ?"
3. "How do PostgreSQL types help data quality beyond validation?"

## Completion Checklist

- [ ] Understand the five big type decisions
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Can explain the 0.1 + 0.2 float trap and timezone handling out loud
