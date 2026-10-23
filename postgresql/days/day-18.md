# Day 18 — Transactions In-Depth: MVCC

**Track:** PostgreSQL · **Stage:** 5 — Transactions & Concurrency · **Difficulty:** Advanced

## Goal

Understand *how* PostgreSQL implements ACID's I — MVCC — and use snapshot thinking to debug concurrency.

## Fundamentals

**MVCC (Multi-Version Concurrency Control)** — PostgreSQL's core concurrency design:

- When you UPDATE a row, PostgreSQL writes a **new version** and marks the old one with the transaction's end
- Each transaction sees a **snapshot**: "only rows committed before I started"
- Result: **readers never block writers; writers never block readers**

```sql
-- feel it (two sessions):
-- S1:
BEGIN;
UPDATE users SET city='Multan' WHERE id = 1;
-- S2 (before S1 commits):
SELECT city FROM users WHERE id = 1;    -- still the OLD city! S2's snapshot predates S1
-- S1:
COMMIT;
-- S2:
SELECT city FROM users WHERE id = 1;    -- NOW Multan (fresh snapshot in autocommit)
```

**Row versions are physically real**: every row carries `xmin` (creating txid) and `xmax` (deleting txid):

```sql
SELECT xmin, xmax, city FROM users WHERE id = 1;
```

**The cost of MVCC** (Day 25's cliffhanger, previewed): dead versions accumulate until **VACUUM** cleans them. Long-running transactions hold snapshots → vacuum can't clean → **bloat**. "That idle psql tab open since Tuesday" is a real production incident class.

**Snapshot machinery you'll actually touch:**

```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- snapshot fixed at first query; re-reads are stable inside this tx
COMMIT;
```

## Why It Matters

MVCC explains three things you'll hit constantly: why writers don't block readers, why long transactions bloat the database, and how "the same row read twice" can differ. This is the deep answer behind every "weird concurrency" bug.

## Mental Model

> MVCC is a **photojournal**: everyone photographs the room from their timestamp — later edits don't change *your* photo (snapshot). The room keeps old furniture until the cleaner (VACUUM) confirms no one's photo still needs it. A tourist who never leaves (long transaction) freezes the cleaners forever — the room fills with old furniture (bloat).

## Practice

### 🟢 Warm Up

[Beginner] **W1.** Run the two-session invisible-update experiment. Write the one-line explanation for S2's two different answers.

[Beginner] **W2.** See versions: `SELECT xmin, xmax, * FROM users WHERE id = 1;` — update the row in a *committed* transaction; re-select — what changed? (New version = new xmin.)

### 🔵 Core

[Intermediate] **C1.** `[Predict]` S1 BEGINs (default), reads a row; S2 updates + commits it; S1 reads again *within the same transaction* — old or new value? What if S1 were REPEATABLE READ? Verify both.

[Intermediate] **C2.** `[From Memory]` the two-line MVCC rule + the consequence for readers/writers.

[Intermediate] **C3.** Dead-row proof: S1 `BEGIN; UPDATE users SET city='X' WHERE id=1;` (uncommitted) — S2 still sees the old version. No lock was ever felt; explain in MVCC terms.

### 🟠 Challenge

[Advanced] **H1.** `[Fix It]` Diagnose and fix the broken queries:

```sql
-- Bug 1: "my transaction sees data that doesn't exist yet" (dirty-read
-- report). Can a plain SELECT ever see uncommitted data under MVCC?
-- What else might the user actually be experiencing?
-- Bug 2: SELECT ... FOR UPDATE in S1; S2's PLAIN SELECT on the same row —
-- blocked or not? Verify, then explain which operations DO block
-- under MVCC. (writers blocking writers)
-- Bug 3: table keeps growing although row counts stay flat. Name the
-- phenomenon, the cause, and the two fixes.
```

[Advanced] **H2.** Write the **write-path memo**: how one UPDATE travels through WAL (Day 4) + MVCC (today) + indexes (Days 13–14) + vacuum (preview). Five sentences max. If you can write this, you have a genuinely senior mental model of the engine.

[Advanced] **H3.** Bloat generator: scratch table, 1 statement `UPDATE t SET n = n+1 FROM generate_series(1,10000);` → check `pg_stat_user_tables.n_dead_tup` before/after commit, then VACUUM and re-check. Write the numbers.

## Interview Questions

1. "How does PostgreSQL achieve read concurrency without blocking readers?" *(MVCC — versions + snapshots.)*
2. "What is table bloat and what causes it?" *(Dead tuples + vacuum lag; long transactions.)*
3. "Can a plain SELECT ever see uncommitted data in PostgreSQL?" *(No — snapshots.)*

## Completion Checklist

- [ ] Understand MVCC, snapshots, xmin/xmax, bloat
- [ ] Completed Warm Up, Core, and Challenge exercises
- [ ] Wrote the write-path memo
