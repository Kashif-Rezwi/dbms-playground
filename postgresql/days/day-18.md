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

[Beginner] **P1.** Run the two-session invisible-update experiment. Write the one-line explanation for S2's two different answers.
[Beginner] **P2.** See versions: `SELECT xmin, xmax, * FROM users WHERE id = 1;` — update the row in a *committed* transaction; re-select — what changed? (New version = new xmin.)
[Beginner] **P3.** Dead-row proof: S1 `BEGIN; UPDATE users SET city='X' WHERE id=1;` (uncommitted) — S2 still sees the old version. No lock was ever felt; explain in MVCC terms.
[Intermediate] **P4.** REPEATABLE READ feel: S1 `BEGIN ISOLATION LEVEL REPEATABLE READ; SELECT count(*) FROM orders;` — S2 inserts + commits — S1 re-selects: same count! Commit S1, re-check: new count.
[Intermediate] **P5. Predict first:** S1 BEGINs (default), reads a row; S2 updates + commits it; S1 reads again *within the same transaction* — old or new value? What if S1 were REPEATABLE READ? Verify both.
[Intermediate] **P6. From memory:** the two-line MVCC rule + the consequence for readers/writers.
[Advanced] **P7.** Bloat generator: scratch table, 1 statement `UPDATE t SET n = n+1 FROM generate_series(1,10000);` → check `pg_stat_user_tables.n_dead_tup` before/after commit, then VACUUM and re-check. Write the numbers.
[Advanced] **P8.** The frozen-cleaner demo: S1 `BEGIN ISOLATION LEVEL REPEATABLE READ; SELECT * FROM users;` — S2 updates 500 users + commits + `VACUUM users;` — check `n_dead_tup` (can't clean S1's world). S1 COMMITs; VACUUM again — dead tuples gone. **This is why production hunts idle-in-transaction sessions.**

## Debugging

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

## Combine Concepts

Write the **write-path memo**: how one UPDATE travels through WAL (Day 4) + MVCC (today) + indexes (Days 13–14) + vacuum (preview). Five sentences max. If you can write this, you have a genuinely senior mental model of the engine.

## Previous Knowledge

1. The five query-shape → index-shape mappings.
2. How do you prove an index earns its write tax?
3. shared hit vs read vs temp?
4. SQL: what does ROLLBACK undo?

## Recall

1. MVCC in two lines + the readers/writers consequence.
2. What are xmin/xmax?
3. Why do long transactions cause bloat?
4. What does a snapshot fix, and when (RC vs RR)?

## Interview Questions

1. "How does PostgreSQL achieve read concurrency without blocking readers?" *(MVCC — versions + snapshots.)*
2. "What is table bloat and what causes it?" *(Dead tuples + vacuum lag; long transactions.)*
3. "Can a plain SELECT ever see uncommitted data in PostgreSQL?" *(No — snapshots.)*

## Completion Checklist

- [ ] Understand MVCC, snapshots, xmin/xmax, bloat
- [ ] Completed P1–P8 (P5 predicted first; two-session setups done)
- [ ] Fixed all three bugs
- [ ] Wrote the write-path memo
- [ ] Answered recall without notes

