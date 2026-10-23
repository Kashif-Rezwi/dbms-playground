# Day 12 — Practical PG Patterns Round-Up (Stage Self-Check)

**Track:** PostgreSQL · **Stage:** 3 — PG Features · **Difficulty:** Intermediate

## Goal

Collect the small-but-vital patterns that didn't fit earlier, then self-check Stage 1–3 before the performance stage begins.

## Fundamentals — The Grab-Bag That Matters

**1. UPSERT** (`ON CONFLICT`) — insert-or-update atomically:

```sql
INSERT INTO stats (user_id, login_count) VALUES (1, 1)
ON CONFLICT (user_id) DO UPDATE SET login_count = stats.login_count + 1;
-- ... RETURNING *;  -- and ON CONFLICT DO NOTHING for safe retries
```

**2. `INSERT ... ON CONFLICT DO NOTHING` + unique constraint = idempotent retries** (P5's SQL bank lesson, engine-native).

**3. `LIMIT 1` guards and `FOR UPDATE SKIP LOCKED` preview** — job-queue pattern:

```sql
-- claim one job, skipping rows other workers hold:
UPDATE jobs SET status='running', worker = 'w1'
WHERE id = (SELECT id FROM jobs WHERE status='pending'
            ORDER BY created_at LIMIT 1 FOR UPDATE SKIP LOCKED)
RETURNING *;
```

**4. `GROUPING` / `ROLLUP` taste** — subtotals:

```sql
SELECT city, count(*) FROM users GROUP BY ROLLUP (city);
```

**5. `NULLS FIRST/LAST`, `IS DISTINCT FROM`** — NULL-aware compare:

```sql
WHERE a IS DISTINCT FROM b    -- true when different OR one is NULL — NULL-safe <>
```

**6. Advisory locks preview** (Day 20 deep-dive: `SELECT pg_advisory_xact_lock(42);`).

## Stage Self-Check (before Day 13)

Can you, without notes: create a database and schema, choose types for money/time/text, write a table with identity + partial-unique + FK + CHECK, create and refresh a materialized view, write a volatility-tagged function, attach a trigger for `updated_at`/audit, decide columns-vs-JSONB? **If any answer is "no", that day's recall is tomorrow's breakfast.**

## Practice

### 🟢 Warm Up

[Beginner] **W1.** Build a `stats(user_id PK, login_count)` table; run the upsert twice for user 1; verify count = 2 — explain why it's atomic.

[Beginner] **W2.** `IS DISTINCT FROM` drill: with NULLs in `bio`, compare `WHERE bio <> NULL` vs `WHERE bio IS DISTINCT FROM NULL`.

### 🔵 Core

[Intermediate] **C1.** `[Predict]` upsert with `DO UPDATE SET login_count = stats.login_count + 1` run 5 times in *concurrent* sessions (simulate with 5 sequential — then reason about true concurrency: is `login_count + 1` safe under two simultaneous upserts? Why?).

[Intermediate] **C2.** `[From Memory]` an idempotent "record webhook" insert (unique on (event_id), DO NOTHING).

[Intermediate] **C3.** Build a 3-worker job queue table (pending/running/done + 10 jobs); run the SKIP LOCKED claim in two sessions; verify each worker got *different* jobs with zero waiting. One line: what would plain `FOR UPDATE` have done?

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```sql
-- Bug 1: upsert gives "there is no unique or exclusion constraint
-- matching the ON CONFLICT specification". What's missing?
-- Bug 2: job queue workers sometimes process the SAME job twice.
-- What pattern was skipped? (claim-then-process with FOR UPDATE/SKIP LOCKED)
-- Bug 3: SELECT * FROM t WHERE col <> NULL; returns nothing, and the dev
-- insists NULL-rows should "obviously" match too. Two correct tools
-- (IS DISTINCT FROM / IS NOT NULL) and the semantic reason <> fails.
```

[Advanced] **H2.** The mini-ETL: a `daily_stats` table (day, signups, orders, revenue) fed by an **upsert-from-source** statement (`INSERT ... SELECT ... ON CONFLICT (day) DO UPDATE SET ...`) over `ecommerce` — idempotent: run it twice, same numbers (prove it!). This exact pattern is how real pipelines become re-runnable.

[Advanced] **H3.** Pattern match: for each problem — upsert, SKIP LOCKED, ROLLUP, IS DISTINCT FROM, advisory lock — one line on *why* it's the right tool and what the naive version gets wrong.

## Interview Questions

1. "How do you implement insert-or-update safely?" *(ON CONFLICT + the constraint requirement.)*
2. "How would you build a job queue in PostgreSQL?" *(SKIP LOCKED claim pattern — say it.)*
3. "Why is a webhook handler idempotent by design, and how does the database help?" *(UNIQUE + DO NOTHING.)*

## Completion Checklist

- [ ] Understand upsert, SKIP LOCKED, ROLLUP, IS DISTINCT FROM
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Completed the idempotent mini-ETL
- [ ] Honest self-check written; gaps scheduled
